source('common.r')

feed = fread("../../data/feed.csv",encoding="UTF-8")
devs = fread("../../data/devs.csv",encoding="UTF-8")

setkey(devs, blog_url)
setkey(feed, blog_url)

blogs = unique(feed$blog_url)
blogs.w.feed = unique(feed[feed_url!='']$blog_url)
blogs.w.summary = unique(feed[summary!='']$blog_url)
blogs.w.lang = unique(feed[lang!='']$blog_url)

#just for getting numbers about missing data
blogs.no.feed = blogs[!(blogs%in%blogs.w.feed)]
blogs.no.summary = blogs.w.feed[!(blogs.w.feed %in% blogs.w.summary)]
blogs.no.lang = blogs[!(blogs.w.summary%in%blogs.w.lang) ]


blog.langs = feed[lang%in% c('en', 'pl'),.(blog_url,lang)]
setkey(blog.langs,blog_url,lang )
blog.langs = unique(blog.langs)


blog.lang.freqs = table(blog.langs$blog_url)
#how many blogs with muliple langs out there?
blog.lang.w.many.langs = names(blog.lang.freqs[blog.lang.freqs!=1])

blog.langs.detected = blog.langs[blog_url %in% names(blog.lang.freqs[blog.lang.freqs==1])]

blog.langs.detected[lang == 'en']$lang = 'angielski'
blog.langs.detected[lang == 'pl']$lang = 'polski'


ggplot(data.frame(table(blog.langs.detected$lang)/nrow(blog.langs.detected)), aes(x=Var1)) +
  geom_bar(aes(y=Freq), stat = "identity",fill="lightskyblue3") +
  geom_text(aes(y=Freq,label= percent_format()(Freq), hjust=0.4,vjust=1.5),size=7, colour='white', position = position_dodge(width=1))  +
  theme(axis.line=element_blank(),
      axis.text.y=element_blank(),
      axis.text=element_text(size=20),
      axis.ticks=element_blank(),
      axis.title.x=element_blank(),
      axis.title.y=element_blank(),
      legend.position="none",
      panel.background=element_blank(),
      panel.border=element_blank(),
      panel.grid.major=element_blank(),
      panel.grid.minor=element_blank(),
      plot.background=element_blank())+
  ggtitle("Język blogów")


feed.w.summary = data.frame(feed[date!='', .(blog_url, feed_url,date, link)])
#feedparser convert dates to UTC automatically
feed.w.summary$date = as.POSIXlt( as.POSIXct(feed.w.summary$date,tz = "UTC"), tz="CET")
feed.week1 = subset(feed.w.summary,date>=contest.start & date<= contest.week2)
feed.week1 =unique(subset(feed.week1 ,grepl('comment', feed_url)==FALSE)[,c('blog_url','date','link')])
blog.post.cnt =data.frame( table(feed.week1$blog_url))

names(blog.post.cnt) = c('blog_url','posts')

blog.post.cnt[blog.post.cnt$posts>3,]$posts=4
blog.post.cnt =data.frame(table(blog.post.cnt$posts))
blog.post.cnt$Var1 = as.numeric(blog.post.cnt$Var1)

blog.post.cnt$status = 'not_enough'
blog.post.cnt[blog.post.cnt$Var1>=2,]$status = 'ok'
blog.post.cnt[blog.post.cnt$Var1>3,]$Var1='4 i więcej'

ggplot(blog.post.cnt, aes(x=Var1,fill=status)) + geom_bar(aes(y=Freq),stat="identity") + 
  coord_flip() + 
  theme_minimal()+
  scale_fill_manual(values=c("#999999", "#009E73")) +
  geom_text(aes(x=Var1, y=Freq, label=Freq,
                hjust=1.7 ), colour="white",size=7,
            position = position_dodge(width=1))+
  theme(axis.line=element_blank(),
        axis.text.x=element_blank(),
        axis.text=element_text(size=20),
        axis.title=element_text(size=20),
        axis.ticks=element_blank(),
        legend.position="none",
        panel.background=element_blank(),
        panel.border=element_blank(),
        panel.grid.major=element_blank(),
        panel.grid.minor=element_blank(),
        plot.background=element_blank())+
  ylab("Liczba blogów")+
  xlab("Ilość postów")




