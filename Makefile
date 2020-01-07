#
# usage:
#
# make
# make pdf
#    Will make the pdf version of the book
#
# make chapter=03
#    Will build a pdf with only chapter 03 in it.
#
# make html
#    Will build the html version of the book
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

html: 
	Rscript -e "bookdown::render_book('index.Rmd', 'bookdown::gitbook')"

ifndef chapter
# Full book pdf build
pdf:
	Rscript -e "bookdown::render_book('index.Rmd', 'bookdown::pdf_book')"

else
# Single chapter build
outname = chapter-$(chapter)
inname := $(shell ls $(chapter)-*.Rmd) # find chapter name by listing directory
chapters = "['index.Rmd','$(inname)']"
pdf: _bookdown_chapter.yml
	Rscript -e "bookdown::render_book('index.Rmd', 'bookdown::pdf_book',config_file = '_bookdown_chapter.yml', output_file = '$(outname)')"

endif

# sed/awk magic to replace the rmd_files with the correct chapters
# .INTERMEDIATE tag means this file will get deleted after the build
.INTERMEDIATE: _bookdown_chapter.yml
_bookdown_chapter.yml:
	echo $(chapters)
	sed '/^rmd_files/,/]/d' _bookdown.yml |\
	awk -v n=5 -v s="rmd_files: $(chapters)" 'NR == n {print s} {print}' > _bookdown_chapter.yml

.PHONY:
clean:
	rm -f _main.md _main.rds _book/*.tex _book/*.pdf chapter-*.log chapter-*.pdf chapter-*.tex
	rm -f bookdown*.bak
	rm render*.rds
	rm tmp-pdfcrop-*.tex

