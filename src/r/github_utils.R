format.git.date<- function(datestring)  as.POSIXct(datestring, format = "%Y-%m-%dT%H:%M:%SZ",  tz = "GMT")

contest.announcement = as.POSIXct("2016-02-01",tz = "GMT")
contest.start = as.POSIXct("2016-03-01",tz = "GMT")
