#! /usr/bin/env bash

# source ~/.bash_profile
export PATH=$PATH:/usr/texbin

cp ~/Dropbox/who/erm_finan_report/'2012 pledges and contributions.xlsx' ~/Desktop
cd ~/Desktop

curl https://raw.githubusercontent.com/jpolonsky/erm_finan_rep/master/ERM_Financial_Report_online.Rnw >> ERM_Financial_Report_online.Rnw

curl -o logo_who.pdf 'http://www.pdf-archive.com/2015/02/24/logo-who/logo-who.pdf' 
curl -o logo_prime.pdf 'http://www.pdf-archive.com/2015/02/24/logo-prime/logo-prime.pdf' 

# Rscript -e "library(knitr); knit('ERM_Financial_Report_online.Rnw')"
Rscript -e "if(!require(knitr)) {install.packages("knitr"); require(knitr)}; knit('ERM_Financial_Report_online.Rnw')"
pdflatex ERM_Financial_Report_online.tex

old_filename="ERM_Financial_Report_online.pdf"
# new_filename=${old_filename%.*}$(date "+_%Y%m%d").${old_filename##*.}
new_filename=ERM_Financial_Report$(date "+_%Y%m%d").pdf
mv "$old_filename" "$new_filename"

# rm ERM_Financial_Report_online.aux ERM_Financial_Report_online.log ERM_Financial_Report_online.out ERM_Financial_Report_online.Rnw ERM_Financial_Report_online.tex ./figure/fig_pop-1.pdf logo_prime.pdf logo_who.pdf '2012 pledges and contributions.xlsx'
rm ERM_Financial_Report_online.aux ERM_Financial_Report_online.log ERM_Financial_Report_online.out ERM_Financial_Report_online.Rnw ERM_Financial_Report_online.tex ./figure/fig_pop-1.pdf logo_prime.pdf logo_who.pdf '2012 pledges and contributions.xlsx'
rmdir figure
# mv ERM_Financial_Report_online.pdf ~/Desktop
# mv ERM_Financial_Report_online.pdf 'ERM ERM_Financial_Report_online report.pdf'


mv "$new_filename" ~/Dropbox/who/erm_finan_report/

# uuencode "$new_filename" "$new_filename" | mail -s "Updated ERM financial report" jonny.polonsky@gmail.com

## ssh jonathanpolonsky@10.29.10.99
## ssh 10.29.10.99 "source ~/.bash_profile; $(< ~/"GITHUB repos/erm_finan_rep/ERM Financial Report.tool")"

## ssh jonathanpolonsky@Jonathans-MacBook-Pro
## ssh Jonathans-MacBook-Pro "source ~/.bash_profile; $(< ~/"GITHUB repos/erm_finan_rep/ERM Financial Report.tool")"

exit 0