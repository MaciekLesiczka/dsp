library(wordcloud)

df = read.csv("../data/tech_ngrams_filtered.csv",encoding = "utf-8")

pal <- brewer.pal(9,"YlGnBu")
pal <- pal[-(1:3)]

wordcloud(df$ngram,df$count,min.freq=2,  random.order=T,rot.per=0.35, use.r.layout=FALSE, colors=pal)