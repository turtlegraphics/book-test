#
# This script runs at the beginning of every chapter to set up packages we
# use to generate parts of the book.
#
# The _bookdown.yml file has the line:
#    before_chapter_script: pre-chapter-script.R
# which causes this behavior
#

# tidy all source code by default
knitr::opts_chunk$set(tidy=TRUE)

# restrict R output width to 72 so it won't overflow the PDF page width
options(width = 72)
