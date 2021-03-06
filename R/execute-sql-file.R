#' @name execute_sql_file
#' @export
#'
#' @title Execute a SQL file
#'
#' @description Read a SQL file, and execute its text using the `odbc` and `DBI` packages.
#'
#' @param path_sql A vector to of names to convert.  Required character.
#' @param dsn The name of a [DSN](https://en.wikipedia.org/wiki/Data_source_name) defined on your local machine  Required character.
#' @param execute Indicates if `DBI::dbExecute()` should be used
#' (which typically returns a scalar).  Otherwise, `DBI::dbGetQuery()` is used,
#' (which will return a `tibble::tibble`).  Required `logical`.
#' @param minimum_row_count If `execute` is false, the returned dataset should have at least this many rows, or an error will be thrown.  Default of 0.  Required integer.
#'
#' @return A vector of converted names.
#'
#' @author Will Beasley
#'
#' @examples
#' \dontrun{
#' execute_sql_file("inst/hdid-select.sql", "cdw_cache_staging")
#' execute_sql_file("inst/condense-date.sql", "cdw_cache_staging")
#' }

execute_sql_file <- function( path_sql, dsn, execute=TRUE, minimum_row_count=0L ) {
  checkmate::expect_file_exists(path_sql)
  checkmate::assert_character(path_sql, min.chars=2, min.len=1, max.len=1, any.missing=F)
  checkmate::assert_character(dsn     , min.chars=2, min.len=1, max.len=1, any.missing=F)
  checkmate::assert_logical(  execute              , len=1, any.missing=F)

  sql   <- readr::read_file(path_sql)
  checkmate::assert_character(sql     , min.chars=2, min.len=1, max.len=1, any.missing=F)

  tryCatch({
    channel <- odbc::dbConnect(odbc::odbc(), dsn)
    if( execute ) {
      returned_value <- DBI::dbExecute(channel, sql)
    } else {
      returned_value <- DBI::dbGetQuery(channel, sql) %>%
        tibble::as_tibble()

      OuhscMunge::verify_data_frame(returned_value, minimum_row_count=minimum_row_count)
    }
  }, finally={
    odbc::dbDisconnect(channel)
  })

  return( returned_value )
}
