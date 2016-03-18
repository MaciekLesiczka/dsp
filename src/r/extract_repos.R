library(github)


devs = read.csv("../../data/devs.csv", encoding = "UTF-8")


all.org.repos = lapply(as.character(subset(devs,repo_name=="/all/")$repo_owner), function(owner){
  reps_request = get.organization.repositories(owner)
  
  if(reps_request$code != 200 && reps_request$code != 304){
    print(paste("error for",owner,reps_request$code))
    NULL
  }
  else{
    names = sapply(reps_request$content, function(r) r$name)
    list(rep(owner,length(names)),names)
    
  }
})

all.org.repos.df = data.frame(
  repo_owner=unlist(sapply(all.org.repos, function(x)x[1])),
  repo_name=unlist(sapply(all.org.repos, function(x)x[2]))
)


all.repos = subset(subset(devs,repo_name!="/all/"), repo_name!="")[, c("repo_owner","repo_name")]

repos = rbind(all.repos,all.org.repos.df)

write.csv(repos, "../../data/repos.csv",row.names = F)