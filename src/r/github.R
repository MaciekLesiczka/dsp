library(ggplot2)
source('common.r')
source('github_login.R')
source('github_get_commits.R')

repos = read.csv("../../data/repos.csv")

dsp.commits = get.dsp.commits(repos)


dsp.commits.march = subset(dsp.commits,commit>=contest.start)

#write.csv( dsp.commits, "../../data/dsp.commits.csv",fileEncoding="UTF-8")

#Punchcard
dsp.commits.first.week.date.parts = data.frame(
  weekday = factor(weekdays(dsp.commits.first.week$commit), levels=c("wtorek", "środa", "czwartek", "piątek", "sobota", "niedziela") ),
  hour = sapply(dsp.commits.first.week$commit, function(x) as.POSIXlt(x)$hour)
)

write.csv( table(dsp.commits.first.week.date.parts), "../js/data.csv",fileEncoding="UTF-8")


#General stats

dsp.languages = dsp.get.languages(repos)

basic.stats = function(commits){
  result = c(sum(commits$additions)-sum(commits$deletions), 
                                   length(unique(commits$repo_name)),
                                   length(commits$commit))
  names(result)=c("lines of code", "active repos", "commits")
  result
}

 sapply(dsp.commits$commit, function(x){
# todo: calculate contest week number   
   
 })

dsp.commits.week1 = subset(dsp.commits,
  as.Date(commit)>=contest.start.date &
  as.Date(commit)<contest.start.date+6
)

dsp.commits.week2 = subset(dsp.commits,
  as.Date(commit)>=(contest.start.date +6) &
  as.Date(commit)<(contest.start.date+6+7)
)
 
dsp.commits.week3 = subset(dsp.commits,
                           as.Date(commit)>=(contest.start.date +6 + 7) &
                           as.Date(commit)<(contest.start.date+6+7 + 7)
) 

second.week.in.active.repos.from.first.week = subset(dsp.commits.week2, repo_owner %in% dsp.commits.week1$repo_owner)


table(dsp.commits$repo_owner)



basic.stats(dsp.commits)       
basic.stats(dsp.commits.march)
basic.stats(dsp.commits.week1)
basic.stats(dsp.commits.week2)
basic.stats(dsp.commits.week3)
basic.stats(second.week.in.active.repos.from.first.week)






dsp.commits.freq = data.frame(table(dsp.commits$repo_name))

ggplot(data.frame(table(subset(dsp.commits.freq, Freq!=0)$Freq)), aes(Var1,Freq)) + geom_bar(stat="identity",fill="lightskyblue3") + 
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


unique(dsp.commits$repo_name)


