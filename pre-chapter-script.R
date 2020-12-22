#
# This script runs at the beginning of every chapter to set up packages we
# use to generate parts of the book.
#
# The _bookdown.yml file has the line:
#    before_chapter_script: pre-chapter-script.R
# which causes this behavior
#
suppressMessages(suppressWarnings(library(ggplot2)))
suppressMessages(suppressWarnings(library(dplyr)))

options(width = 72)
