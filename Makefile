#
# usage:
#
# make
# make html
#    Will build the html version of the book
#
# make html chapter=03
#    Will build an html book with only chapter 03 in it (not very useful)
#
# make pdf
#    Will make the pdf version of the book
#
# make pdf chapter=03
# make chapter=03
#    Will build a pdf with only chapter 03 in it.
#

#
# The make chapter=03 recipe is a little fragile.  It first makes a new
# yml build file by erasing the rmd_files definition from _bookdown.yml
# and then inserting rmd_files with just the index and the chapter desired.
# This file is stored as _bookdown_chapter.yml so it's non-destructive.
# Then _bookdown_chapter.yml is passed to render_book, and eventually delted.
# Better not use anything but a valid two-digit chapter number, because there's
# not really any error checking.
#

ifndef chapter
# Full book build
html: 
	Rscript -e "bookdown::render_book('index.Rmd', 'bookdown::gitbook')"

pdf:
	Rscript -e "bookdown::render_book('index.Rmd', 'bookdown::pdf_book')"

else
# Single chapter build
outname = chapter-$(chapter)
inname := $(shell ls $(chapter)-*.Rmd) # find chapter name by listing directory
chapters = "['index.Rmd','$(inname)']"
pdf: _bookdown_chapter.yml
	Rscript -e "bookdown::render_book('index.Rmd', 'bookdown::pdf_book',config_file = '_bookdown_chapter.yml', output_file = '$(outname)')"

html: _bookdown_chapter.yml
	Rscript -e "bookdown::render_book('index.Rmd', 'bookdown::gitbook',config_file = '_bookdown_chapter.yml', output_file = '$(outname)')"


# sed/awk magic to replace the rmd_files with the correct chapters
# .INTERMEDIATE tag means this file will get deleted after the build
.INTERMEDIATE: _bookdown_chapter.yml
_bookdown_chapter.yml:
	echo $(chapters)
	sed '/^rmd_files/,/]/d' _bookdown.yml |\
	awk -v n=5 -v s="rmd_files: $(chapters)" 'NR == n {print s} {print}' > _bookdown_chapter.yml

endif # end of single chapter build

.PHONY:
clean:
	rm -f _main.md _main.rds _book/*.tex _book/*.pdf chapter-*.log chapter-*.pdf chapter-*.tex
	rm -f bookdown*.bak
	rm render*.rds
	rm tmp-pdfcrop-*.tex

