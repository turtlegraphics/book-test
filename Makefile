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
#
# Better not use anything but a valid two-digit chapter number, because there's
# not really any error checking.
#

pdfoutputdir = _bookPDF

# reusable clean-up command move the detritus of latex building into
#    the pdf output directory
define clean-up-pdf 
mv *.log $(pdfoutputdir)
mv *.thm $(pdfoutputdir)
mv *.idx $(pdfoutputdir)
mv *.ilg $(pdfoutputdir)
mv *.ind $(pdfoutputdir)
mv *.photocredit $(pdfoutputdir)
endef

ifndef chapter

#
# Full book build
#

html: 
	Rscript -e "bookdown::render_book('index.Rmd', 'bookdown::gitbook')"

pdf:
	rm -f _main.md
	Rscript -e "bookdown::render_book('index.Rmd', 'bookdown::pdf_book', output_dir = '$(pdfoutputdir)')"
	-$(clean-up-pdf)
else

#
# Single chapter build
#

outname = chapter-$(chapter)
inname := $(shell ls $(chapter)-*.Rmd) # find chapter name by listing directory
chapters = "['index.Rmd','$(inname)']"

chapter_number_file = _single_chapter_build_number.txt

pdf: _bookdown_chapter.yml $(chapter_number_file)
	rm -f _main.md
	Rscript -e "bookdown::render_book('index.Rmd', 'bookdown::pdf_book', output_dir = '$(pdfoutputdir)', config_file = '_bookdown_chapter.yml', output_file = '$(outname)')"
	-$(clean-up-pdf)

html: _bookdown_chapter.yml
	Rscript -e "bookdown::render_book('index.Rmd', 'bookdown::gitbook',config_file = '_bookdown_chapter.yml', output_file = '$(outname)')"


# sed/awk magic to replace the rmd_files with the correct chapters
# .INTERMEDIATE tag means this file will get deleted after the build
.INTERMEDIATE: _bookdown_chapter.yml
_bookdown_chapter.yml:
	echo $(chapters)
	sed '/^rmd_files/,/]/d' _bookdown.yml |\
	awk -v n=5 -v s="rmd_files: $(chapters)" 'NR == n {print s} {print}' > _bookdown_chapter.yml

# This puts the chapter number into a temporary file.
# To build a pdf of a single chapter and have it numbered correctly,
# this file is read in the pre-chapter-script and used to output a latex
# chapter numbering command
.INTERMEDIATE: $(chapter_number_file)
$(chapter_number_file):
	echo $(chapter) > $(chapter_number_file)

endif # end of single chapter build

.PHONY:
clean:
	rm -f _main.md _main.rds _book/*.tex _book/*.pdf *.log *.thm
	rm -f $(pdfoutputdir)/*.md $(pdfoutputdir)/*.log $(pdfoutputdir)/*.tex $(pdfoutputdir)/*.idx $(pdfoutputdir)/*.ilg $(pdfoutputdir)/*.ind $(pdfoutputdir)/*.photocredit $(pdfoutputdir)/*.thm $(pdfoutputdir)/*.pdf
	rm -f bookdown*.bak
	rm -f tmp-pdfcrop-*.tex
	rm -f *.rds


