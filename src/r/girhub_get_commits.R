library(github)




get.dsp.commits = function(repos){
  all.commits = apply(repos,1,function(x){
    owner = as.character(x[1])
    repo = as.character(x[2])
    
    request = get.repository.commits(owner, repo)
    if(request$code != 200 && request$code != 304){
      print(paste(request$content$message, "for", owner, ", repo", repo))
      NULL
    }
    else{
      commits =sapply(request$content, function(r) date= r$commit$committer$date)
      if(length(commits) > 0){
        comstats = lapply(request$content, function(r) {
          if( r$commit$committer$date>=contest.start & r$commit$committer$date<contest.week2){
            stats = get.repository.commit(owner,repo,r$sha)$content$stats
            c(stats$additions, stats$deletions)
          }
          else{
            c(0,0)
          }
        })
        data.frame(commit = commits, repo_owner = owner, repo_name = repo, 
                   additions = sapply(comstats, function(x) x[1]),
                   deletions = sapply(comstats, function(x) x[2]))  
      }
      else{
        NULL
      }
    }
  })
  
  all.commits = all.commits[!sapply(all.commits, is.null)]
  all.commits = Reduce(function(...) merge(..., all=T), all.commits)
  all.commits$commit = format.git.date(all.commits$commit)
  all.commits 
}