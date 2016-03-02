library(wordcloud)
library(ggplot2)

df = read.csv('../../data/tech_ngrams_filtered.csv',encoding = "utf-8")

pal <- brewer.pal(9,"YlGnBu")
pal <- pal[-(1:3)]

wordcloud(df$ngram,df$count,min.freq=2,  random.order=T,rot.per=0.35, use.r.layout=FALSE, colors=pal)

top10 = head(df[order(df$count, decreasing = T),],10)

top10$ngram = factor(top10$ngram,levels=top10[order(top10$count, decreasing=F),]$ngram)


ggplot(top10, aes(ngram,count, fill="#253494")) + geom_bar(stat="identity") + 
coord_flip()+
geom_text(aes(x=ngram, y=count, label=count, 
              hjust=2), 
          position = position_dodge(width=1))+
theme(axis.line=element_blank(),
      axis.text.x=element_blank(),
      
      axis.ticks=element_blank(),
      axis.title.x=element_blank(),
      axis.title.y=element_blank(),
      legend.position="none",
      panel.background=element_blank(),
      panel.border=element_blank(),
      panel.grid.major=element_blank(),
      panel.grid.minor=element_blank(),
      plot.background=element_blank())