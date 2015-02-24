#! /usr/bin/env bash

cd ~/Desktop
curl https://raw.githubusercontent.com/jpolonsky/erm_finan_rep/master/erm_finan_report.Rnw >> erm_finan_report.Rnw
curl -o logo_who.pdf 'http://www.pdf-archive.com/2015/02/24/logo-who/logo-who.pdf' 
curl -o logo_prime.pdf 'http://www.pdf-archive.com/2015/02/24/logo-prime/logo-prime.pdf' 

Rscript -e "library(knitr); knit('erm_finan_report.Rnw')"
pdflatex erm_finan_report.tex

rm erm_finan_report.aux erm_finan_report.log erm_finan_report.out erm_finan_report.Rnw erm_finan_report.tex ./figure/fig_pop-1.pdf logo_prime.pdf logo_who.pdf
rmdir figure
# mv erm_finan_report.pdf ~/Desktop
#mv erm_finan_report.pdf 'ERM financial report.pdf'

old_filename="erm_finan_report.pdf"
new_filename=${old_filename%.*}$(date "+_%Y%m%d").${old_filename##*.}
mv "$old_filename" "$new_filename"

exit 0