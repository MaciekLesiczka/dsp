library(ggplot2)
source('common.r')
source('github_login.R')
source('github_get_commits.R')

repos = read.csv("../../data/repos.csv")



dsp.commits = get.dsp.commits(repos)


dsp.commits.first.week = subset(dsp.commits,commit>=contest.start&commit<contest.week2)

#write.csv( dsp.commits.first.week, "../data/dsp.commits.first.week.csv",fileEncoding="UTF-8")

dsp.get.languages = function(repos){ 
  unique(unlist(apply(repos,1,function(x){
  owner = as.character(x[1])
  repo = as.character(x[2])
  
  request = get.repository.languages(owner, repo)
  if(request$code != 200 && request$code != 304){
    print(paste(request$content$message, "for", owner, ", repo", repo))
    NULL
  }
  else{
    languages = names(request$content)
    print (languages)
    languages
  }
})))
}

#Punchcard
dsp.commits.first.week.date.parts = data.frame(
  weekday = factor(weekdays(dsp.commits.first.week$commit), levels=c("wtorek", "środa", "czwartek", "piątek", "sobota", "niedziela") ),
  hour = sapply(dsp.commits.first.week$commit, function(x) as.POSIXlt(x)$hour)
)

write.csv( table(dsp.commits.first.week.date.parts), "../js/data.csv",fileEncoding="UTF-8")


#General stats
dsp.commits.first.week.stats = c(sum(dsp.commits.first.week$additions)-sum(dsp.commits.first.week$deletions), 
  length(unique(dsp.commits.first.week$repo_name)),
  length(dsp.commits.first.week$commit),
  length(dsp.languages))
names(dsp.commits.first.week.stats)=c("lines of code", "active repos", "commits", "languages")
dsp.commits.first.week.stats


dsp.languages = dsp.get.languages()


dsp.commits.first.week.freq = data.frame(table(dsp.commits.first.week$repo_name))

ggplot(data.frame(table(subset(dsp.commits.first.week.freq, Freq!=0)$Freq)), aes(Var1,Freq)) + geom_bar(stat="identity",fill="lightskyblue3") + 
  coord_flip() + 
  theme_minimal()+
  geom_text(aes(x=Var1, y=Freq, label=Freq, 
                hjust=2), 
            position = position_dodge(width=1))+
  theme(axis.line=element_blank(),
        axis.text.x=element_blank(),
        axis.text=element_text(size=12),
        axis.ticks=element_blank(),
        legend.position="none",
        panel.background=element_blank(),
        panel.border=element_blank(),
        panel.grid.major=element_blank(),
        panel.grid.minor=element_blank(),
        plot.background=element_blank())+
        ylab("Repositories count")+
        xlab("Commits count")+
  ggtitle("Commits count histogram")

    

summary(subset(dsp.commits.first.week.freq, Freq!=0))

length(subset(dsp.commits.first.week.freq, Freq>10)$Freq)


# remove outliers (big commits) from the list
newlines = dsp.commits.first.week$additions-dsp.commits.first.week$deletions
newlineswithoutoutliers = newlines[newlines<1000& newlines>-1000]

plot(ecdf(newlineswithoutoutliers))
c(LoC=sum(newlineswithoutoutliers), summary(newlineswithoutoutliers)[4])





