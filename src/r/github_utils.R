library(github)
format.git.date<- function(datestring)  as.POSIXct(datestring, format = "%Y-%m-%dT%H:%M:%SZ",  tz = "CET")

contest.announcement = as.POSIXct("2016-02-01",tz = "CET")
contest.start = as.POSIXct("2016-03-01",tz = "CET")
contest.week2 = as.POSIXct("2016-03-07",tz = "CET")
