#! /usr/bin/env bash

cd ~/test
curl https://raw.githubusercontent.com/jpolonsky/erm_finan_rep/master/test.Rnw >> test.Rnw

Rscript -e "library(knitr); knit('test.Rnw')"
pdflatex test.tex

rm test.aux test.log test.out test.Rnw test.tex ./figure/fig_pop-1.pdf
rmdir figure
mv test.pdf ~/Dropbox