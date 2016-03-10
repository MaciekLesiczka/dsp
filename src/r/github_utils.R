source('common.r')
library(github)
format.git.date<- function(datestring)  as.POSIXct(datestring, format = "%Y-%m-%dT%H:%M:%SZ",  tz = "CET")
