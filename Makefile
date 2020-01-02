html: 
	Rscript -e "bookdown::render_book('index.Rmd', 'bookdown::gitbook')"

pdf:
	Rscript -e "bookdown::render_book('index.Rmd', 'bookdown::pdf_book')"

chapter: _bookdown.yml
	sed '/^rmd_files/,/]/d' _bookdown.yml |\
	awk -v n=4 -v s="rmd_files: ['index.Rmd','01-intro.Rmd']" 'NR == n {print s} {print}' > _bookdown_chapter.yml
	Rscript -e "bookdown::render_book('index.Rmd', 'bookdown::pdf_book',config_file = '_bookdown_chapter.yml', output_file = 'chapter-01')"
