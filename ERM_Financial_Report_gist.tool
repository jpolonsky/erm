#! /usr/bin/env bash

# source ~/.bash_profile
export PATH=$PATH:/usr/texbin

cp ~/Dropbox/who/erm_finan_report/'2012 pledges and contributions.xlsx' ~/Desktop
cd ~/Desktop

# curl https://raw.githubusercontent.com/jpolonsky/erm_finan_rep/master/ERM_Financial_Report_online_mac.Rnw >> ERM_Financial_Report_online.Rnw

curl https://gist.githubusercontent.com/jpolonsky/0a10a4026e0a7304d783/raw/66496d1a884d5953d2e39779364e256222d17902/ERM_Financial_Report_online_mac.Rnw >> ERM_Financial_Report_online.Rnw

curl https://gist.githubusercontent.com/jpolonsky/0a10a4026e0a7304d783/raw/811c2c4370b5d2ab88245ca46979fea62e2f4bc3/titlepage.tex >> titlepage.tex

curl -o logo_who.pdf 'http://www.pdf-archive.com/2015/02/24/logo-who/logo-who.pdf' 
curl -o logo_prime.pdf 'http://www.pdf-archive.com/2015/02/24/logo-prime/logo-prime.pdf' 

Rscript -e "library(knitr); knit('ERM_Financial_Report_online.Rnw')"
#Rscript -e "knitr::knit('ERM_Financial_Report_online.Rnw')" ## Does not work!!!
pdflatex ERM_Financial_Report_online.tex

old_filename="ERM_Financial_Report_online.pdf"
# new_filename=${old_filename%.*}$(date "+_%Y%m%d").${old_filename##*.}
new_filename=ERM_Financial_Report$(date "+_%Y%m%d").pdf
mv "$old_filename" "$new_filename"

rm ERM_Financial_Report_online.* ./figure/*.pdf logo* '2012 pledges and contributions.xlsx' 'titlepage.tex'
rmdir figure
# mv ERM_Financial_Report_online.pdf ~/Desktop
# mv ERM_Financial_Report_online.pdf 'ERM ERM_Financial_Report_online report.pdf'


mv "$new_filename" ~/Dropbox/who/erm_finan_report/
open ~/Dropbox/who/erm_finan_report/"$new_filename" ~/Dropbox/who/erm_finan_report

# uuencode "$new_filename" "$new_filename" | mail -s "Updated ERM financial report" jonny.polonsky@gmail.com

## ssh jonathanpolonsky@10.29.10.99
## ssh 10.29.10.99 "source ~/.bash_profile; $(< ~/"GITHUB repos/erm_finan_rep/ERM Financial Report.tool")"

## ssh jonathanpolonsky@Jonathans-MacBook-Pro
## ssh Jonathans-MacBook-Pro "source ~/.bash_profile; $(< ~/"GITHUB repos/erm_finan_rep/ERM Financial Report.tool")"

exit 0