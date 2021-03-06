#' @name upload_sqls_rodbc
#' @export
#' @title Upload to a SQL Server database using RODBC
#'
#' @description The function performs some extra configuration to improve robustness.
#'
#' @param d Dataset to be uploaded to the dataset.  The object must inherit from `data.frame`.
#' @param table_name Name of the database destination table.
#' @param dsn_name Name of the locally-defined DSN passed to [RODBC::odbcConnect()](RODBC::odbcConnect()).
#' @param clear_table If `TRUE`, calls [RODBC::sqlClear()](RODBC::sqlClear()) before writing to the table.
#' @param create_table If the table structure has not yet been defined in the database, it will be created if `create_table` is `TRUE`.
#' @param convert_logical_to_integer Convert all `logical` columns to `integer`.  This helps the database store the values as bits.
#' @param transaction Should the clear and upload steps be wrapped in a rollback transaction? 
#' @param verbose Write a message about the status of a successful upload. 
#' 
#' @details 
#' If `transaction` is `TRUE` and the upload fails, the table is rolled back to the state before function was callled.
#' This includes rolling back the (optional) clearing of records, and uploading the new records.
#' Decide if it's more robust to rollback to the previous state, or if it's better to leave the table in the incomplete state.
#' The latter is helpful diagnosing which record caused the write to fail; look at the last successful record contained in the database
#'
#' @examples
#' \dontrun{
#' requireNamespace("OuhscMunge")
#'
#' OuhscMunge::upload_sqls_rodbc(
#'   d                          = ds_client,          # Some data.frame that exists in RAM
#'   table_name                 = "tbl_client",
#'   dsn_name                   = "miechv_eval",
#'   create_table               = FALSE,
#'   clear_table                = TRUE,
#'   transaction                = TRUE,
#'   verbose                    = TRUE,
#'   convert_logical_to_integer = TRUE
#' )
#' }


upload_sqls_rodbc <- function( 
  d, 
  table_name, 
  dsn_name, 
  clear_table                   = FALSE, 
  create_table                  = FALSE, 
  convert_logical_to_integer    = FALSE, 
  transaction                   = FALSE, 
  verbose                       = TRUE 
) {
  
  checkmate::assert_class(    d                             , "data.frame"          , null.ok    =F)
  checkmate::assert_character(table_name                    , min.chars=1L  , len=1L, any.missing=F)
  checkmate::assert_character(dsn_name                      , min.chars=1L  , len=1L, any.missing=F)
  
  checkmate::assert_logical(  clear_table                                   , len=1L, any.missing=F)
  checkmate::assert_logical(  create_table                                  , len=1L, any.missing=F)
  checkmate::assert_logical(  convert_logical_to_integer                    , len=1L, any.missing=F)
  checkmate::assert_logical(  transaction                                   , len=1L, any.missing=F)
  checkmate::assert_logical(  verbose                                       , len=1L, any.missing=F)
  
  start_time <- base::Sys.time()
  print(start_time)

  if( convert_logical_to_integer ) {
    d <- dplyr::mutate_if(d, is.logical, as.integer)
  }
  
  requireNamespace("RODBC")
  channel <- RODBC::odbcConnect(dsn = dsn_name)

  tryCatch( {
    if( transaction ) {
      RODBC::odbcSetAutoCommit(channel, autoCommit = FALSE)
    }

    if( verbose ) {
      # RODBC::getSqlTypeInfo("Microsoft SQL Server")
      RODBC::odbcGetInfo(channel)
    }

    if( !create_table & clear_table ) {
      RODBC::sqlClear(channel, table_name)
    }

    if( create_table ) {
      RODBC::sqlSave(channel, d, table_name, append=TRUE, rownames=FALSE, fast=FALSE)
    } else {
      column_info           <- RODBC::sqlColumns(channel, table_name)
      var_types             <- as.character(column_info$TYPE_NAME)
      names(var_types)      <- as.character(column_info$COLUMN_NAME)  #varTypes

      RODBC::sqlSave(channel, d, table_name, append=TRUE, rownames=FALSE, fast=TRUE, varTypes=var_types)
    }

    if( transaction ) {
      RODBC::odbcEndTran(channel, commit = TRUE)
    }

    if( verbose ) {
      duration <- round(as.numeric(difftime(Sys.time(), start_time, units="mins")), 3)
      message("The table `", table_name, "` was written over dsn `", dsn_name, "` in ", duration, " minutes.")
    }
  }, error = function( e ) {

    if( transaction ) {
      RODBC::odbcEndTran(channel, commit = FALSE)
    }
    stop("Writing to the database was not successful.  Attempted to write table `", table_name, "` over dsn `", dsn_name, "`.\n", e)

  }, finally = {
    RODBC::odbcClose(channel)
  })
}
