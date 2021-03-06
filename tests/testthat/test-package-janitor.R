library(testthat)

# ---- package_janitor ---------------------------------------------------------
context("Package Janitor")

test_that("Smoke test w/o update", {
  path <- base::file.path(devtools::inst(name="OuhscMunge"), "package-dependency-list.csv")
  OuhscMunge:::package_janitor(path_package_dependencies=path, update_packages=FALSE, verbose=TRUE)
})
