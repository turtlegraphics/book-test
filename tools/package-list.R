# This script is set to run automatically at the end of each chapter
# in the _bookdown.yml configuration file

#
# It automatically writes all packages to the end of the file "package-list.log"
# which was first created in the index.Rmd file
#
packs <- .packages()
if (!is.null(packs)) {
  packfile <- file("package-list.log","a")
  writeLines(packs,packfile)
  close(packfile)
}