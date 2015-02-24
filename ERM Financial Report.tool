#! /usr/bin/env bash

cp ~/Dropbox/who/l3_emergencies/data/'2012 pledges and contributions.xlsx' ~/Desktop
cd ~/Desktop

curl https://raw.githubusercontent.com/jpolonsky/erm_finan_rep/master/ERM_Financial_Report.Rnw >> ERM_Financial_Report.Rnw
curl -o logo_who.pdf 'http://www.pdf-archive.com/2015/02/24/logo-who/logo-who.pdf' 
curl -o logo_prime.pdf 'http://www.pdf-archive.com/2015/02/24/logo-prime/logo-prime.pdf' 

Rscript -e "library(knitr); knit('ERM_Financial_Report.Rnw')"
pdflatex ERM_Financial_Report.tex

rm ERM_Financial_Report.aux ERM_Financial_Report.log ERM_Financial_Report.out ERM_Financial_Report.Rnw ERM_Financial_Report.tex ./figure/fig_pop-1.pdf logo_prime.pdf logo_who.pdf '2012 pledges and contributions.xlsx'
rmdir figure
# mv ERM_Financial_Report.pdf ~/Desktop
# mv ERM_Financial_Report.pdf 'ERM financial report.pdf'

old_filename="ERM_Financial_Report.pdf"
new_filename=${old_filename%.*}$(date "+_%Y%m%d").${old_filename##*.}
mv "$old_filename" "$new_filename"

# uuencode ERM_Financial_Report_20150224.pdf ERM_Financial_Report_20150224.pdf | mail -s "Updated ERM financial report" jonny.polonsky@gmail.com
uuencode "$new_filename" "$new_filename" | mail -s "Updated ERM financial report" jonny.polonsky@gmail.com

exit 0