library(testthat)


# ---- metadata ----------------------------------------------------------------
context("metadata")

test_that("column rename -OrchardSprays", {
  expected <-
', "decrease"             = "`decrease`"
 , "rowpos"               = "`rowpos`"
 , "colpos"               = "`colpos`"
 , "treatment"            = "`treatment`"'

  testthat::expect_output(
    column_rename_headstart(datasets::OrchardSprays)
    , expected
  )
})

test_that("column rename -Iris", {
  expected <-
', "sepal_length"            = "`Sepal.Length`"
 , "sepal_width"             = "`Sepal.Width`"
 , "petal_length"            = "`Petal.Length`"
 , "petal_width"             = "`Petal.Width`"
 , "species"                 = "`Species`"'

  testthat::expect_output(
    column_rename_headstart(datasets::iris)
    , expected
  )
})


test_that("column rename w/o snake-Iris", {
  expected <-
', "Sepal.Length"            = "`Sepal.Length`"
 , "Sepal.Width"             = "`Sepal.Width`"
 , "Petal.Length"            = "`Petal.Length`"
 , "Petal.Width"             = "`Petal.Width`"
 , "Species"                 = "`Species`"'

  testthat::expect_output(
    column_rename_headstart(datasets::iris, try_snake_case=FALSE)
    , expected
  )
})
test_that("column class -OrchardSprays", {
  expected <-
', "decrease"   = "numeric"
 , "rowpos"     = "numeric"
 , "colpos"     = "numeric"
 , "treatment"  = "factor"'

  testthat::expect_output(
    column_class_headstart(datasets::OrchardSprays)
    , expected
  )
})
test_that("column class -Iris", {
  expected <-
', "Sepal.Length"  = "numeric"
 , "Sepal.Width"   = "numeric"
 , "Petal.Length"  = "numeric"
 , "Petal.Width"   = "numeric"
 , "Species"       = "factor"'

  testthat::expect_output(
    column_class_headstart(datasets::iris)
    , expected
  )
})
test_that("column value -OrchardSprays", {
  expected <-
', "A"  = "A"
 , "B"  = "B"
 , "C"  = "C"
 , "D"  = "D"
 , "E"  = "E"
 , "F"  = "F"
 , "G"  = "G"
 , "H"  = "H"'

  testthat::expect_output(
    column_value_headstart(datasets::OrchardSprays$treatment)
    , expected
  )
})
