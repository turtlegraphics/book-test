#
# usage:
#
# make
#   Build a pdf solutions manual
#

chapters = solutions-01.pdf solutions-02.pdf solutions-03.pdf\
           solutions-04.pdf solutions-05.pdf

manual.pdf: $(chapters) coverpage.pdf
	gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=manual.pdf coverpage.pdf $(chapters)

coverpage.pdf:
	pdflatex coverpage.tex

solutions-%.pdf: solutions-%.Rmd
	Rscript -e "rmarkdown::render('$<', output_format ='pdf_document')"

.PHONY:
clean:
	rm $(chapters) coverpage.pdf
	rm -rf coverpage.aux coverpage.log coverpage.thm



