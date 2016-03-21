library(data.table)
library(ggplot2)
library(scales)
contest.announcement = as.POSIXct("2016-02-01",tz = "CET")
contest.start = as.POSIXct("2016-03-01")
contest.start.date = as.Date("2016-03-01")
contest.week2 = as.POSIXct("2016-03-08")
theme_set(theme_grey(base_size = 18)) 

as.sorted.factor = function(data){
  aggregated = table(data)
  aggregated = aggregated[aggregated!=0]
  factor(data,names(aggregated)[order(as.numeric(aggregated),decreasing = F)])
}


dsp_theme = function(){
  theme_minimal() + theme(axis.line=element_blank(),axis.ticks=element_blank(),axis.text.x=element_blank(),panel.grid.major=element_blank())
}

plot.factor = function(data, hjust=1.3){
  ggplot( data.frame(table(as.sorted.factor(data)))) + 
    geom_bar(aes(x=Var1, y=Freq), stat='identity') +
    geom_text(aes(x=Var1, y=Freq, label=Freq, hjust=hjust), colour='white', position = position_dodge(width=1))+
    coord_flip() +
    xlab('')+
    dsp_theme()
}
