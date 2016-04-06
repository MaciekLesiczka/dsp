#Calculates charts and numbers for 2016-04-05-dsp_first_month
source('common.r')
library(googleVis)
library(sqldf)


posts = fread("../../data/posts_link_archive/20160405_all.csv", colClasses = c('character', 'character', 'Date'))
commits = fread("../../data/commits_archive/20160405.csv")

posts.march = posts[date >= contest.start.date & date < as.Date('2016-04-01')]
commits.march = commits[commit >= contest.start.date & commit < as.Date('2016-04-01')]

#BASE STATS
list(blogs.cnt = length(unique(posts.march$feed_url)),
posts.cnt = nrow(posts.march),
repos.cnt = length(unique(commits.march$repo_name)),
commits.cnt = nrow(commits.march),
lines.cnt = sum(commits.march$additions) - sum(commits.march$deletions))


blogs.cnt = table(posts.march$feed_url)
blogs.cnt = data.table(
    feed_url = names(blogs.cnt),
    posts = as.numeric(blogs.cnt)
)


#TREND
posts.march.cnt = table(posts.march$date)

posts.march.cnt = data.table(
day = as.Date(names(posts.march.cnt)),
posts = as.numeric(posts.march.cnt))


active.projs = data.table(commits.march)[,.(commit,repo_owner)]
active.projs$commit = as.Date(active.projs$commit)

setkey(active.projs, commit, repo_owner)
active.projs = unique(active.projs)


active.projs = table(active.projs$commit)
active.projs = data.table(
day = as.Date(names(active.projs)),
projects = as.numeric(active.projs))



setkey(active.projs, day)

setkey(posts.march.cnt, day)

Line = gvisLineChart(active.projs[posts.march.cnt], options = list(height = 350))
x = plot(Line)


#BASE STATS 5 weeks


posts.5weeks = posts[date >= contest.start.date & date < as.Date('2016-04-05')]
commits.5weeks = commits[commit >= contest.start.date & commit < as.Date('2016-04-05')]


list(blogs.cnt = length(unique(posts.5weeks$feed_url)),
posts.cnt = nrow(posts.5weeks),
repos.cnt = length(unique(commits.5weeks$repo_name)),
commits.cnt = nrow(commits.5weeks),
lines.cnt = sum(commits.5weeks$additions) - sum(commits.5weeks$deletions))



to.table = function(data) {
    data = table(data)
    data.table(
    name = names(data),
    count = as.numeric(data))
}

posts.cnt.5weeks = to.table(posts.5weeks$feed_url)
posts.cnt.march = to.table(posts.march$feed_url)

get.proj.date = function(commits.in.range) {
    df = data.table(repo_owner = commits.in.range$repo_owner, date = as.Date(commits.in.range$commit))
    setkey(df, repo_owner, date)
   to.table(unique(df)$repo_owner)
}

commits.5weeks.proj.date = get.proj.date(commits.5weeks)
commits.march.proj.date = get.proj.date(commits.march)

ggplot(to.table(commits.march.proj.date$count), aes(x = as.numeric(name), y = count)) + geom_bar(stat = 'identity')

summary(commits.5weeks.proj.date)
summary(posts.cnt.5weeks)

list(
blogs6 = nrow(posts.cnt.5weeks[count >= 6]),
blogs10 = nrow(posts.cnt.5weeks[count >= 10]))

#render top 20
devs = read.csv("../../data/devs.csv", encoding = "UTF-8")
feeds = fread("../../data/post_rss.csv", encoding = "UTF-8")
top20projs = data.table(head(commits.march.proj.date[rev(order(count))],20))
top20blogs = data.table(head(posts.cnt.march[rev(order(count))], 23))


top20projs = 
sqldf(
'select first_name || " " || last_name as name, d.project_title, p.count
from top20projs p 
join devs d on d.repo_owner = p.name
order by count desc
')
top20blogs = 
sqldf(
'select first_name || " " || last_name as name, d.blog_url, p.count
from top20blogs p 
join feeds f on f.feed_url = name
join devs d on d.blog_url = f.blog_url
order by count desc
')
