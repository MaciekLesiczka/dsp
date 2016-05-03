source('common.r')


tweets = read.csv("../../data/twitter_dates.csv")


library(googleVis)

tweetsAggrs = data.frame(table(as.Date(tweets$time)))


names(tweetsAggrs) = c('time', 'tweets/day')

Line = gvisLineChart(tweetsAggrs, options = list(height = 350, title='Tweets with #dajsiepoznac'))
x = plot(Line)