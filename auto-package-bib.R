# This script is set to run automatically at the end of each chapter
# in the _bookdown.yml configuration file

#
# It automatically writes all packages to the end of the file "packages.bib"
# which is created in the index.Rmd file
#
packs <- .packages()
packs <- packs[packs!='base']
bib <- unlist(knitr::write_bib(packs))
if (!is.null(bib)) {
  bibfile <- file("packages.bib","a")
  writeLines(bib,bibfile)
  close(bibfile)
}