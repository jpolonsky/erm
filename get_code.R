source_github <- function(u) {
    # load package
    require(RCurl)
    
    # read script lines from website and evaluate
    script <- getURL(u, ssl.verifypeer = FALSE)
    eval(parse(text = script), envir = .GlobalEnv)
}  

source_github("https://raw.githubusercontent.com/jpolonsky/erm_finan_rep/master/my_functions.R")
source_github("https://raw.githubusercontent.com/jpolonsky/erm_finan_rep/master/L3_emergencies_2015.R")
source_github("https://raw.githubusercontent.com/jpolonsky/erm_finan_rep/master/test.R")
#source_github("https://raw.githubusercontent.com/jpolonsky/erm_finan_rep/master/get_code.R")