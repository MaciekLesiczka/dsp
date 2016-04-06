source('github_utils.r')


get.all.repository.commits = function(owner, repo) {
    result = NULL    
    sha = NULL
    repeat {
        request = get.repository.commits(owner, repo, per_page = 100, sha = sha)
        if (request$code != 200 && request$code != 304) {
            print(paste(request$content$message, "for", owner, ", repo", repo))
            commits = NULL
        } else {
            commits = sapply(request$content, function(r) date = r$commit$committer$date)
            if (length(commits) > 0) {
                comstats = lapply(request$content, function(r) {
                    if (r$commit$committer$date >= contest.start) {
                        stats = get.repository.commit(owner, repo, r$sha)$content$stats
                        c(stats$additions, stats$deletions)
                    } else {
                        c(0, 0)
                    }
                })
                commits = data.frame(commit = commits, repo_owner = owner, repo_name = repo,
                                           additions = sapply(comstats, function(x) x[1]),
                                           deletions = sapply(comstats, function(x) x[2]))
            }
            else {
                commits = NULL
            }
        }
        if (is.null(commits)) {
            break
        }
        if (is.null(result)) {
            #first hit
            result = commits
        } else {
            result = unique(rbind(result, commits))
        }

        parents = tail(request$content, n = 1)[[1]]$parents
        if (length(parents)) {
            sha = parents[[1]]$sha
        } else {
            break
        }
        print('loading another page...')
    }
    result
}


get.dsp.commits = function(repos){
  all.commits = apply(repos,1,function(x){
    owner = as.character(x['repo_owner'])
    repo = as.character(x['repo_name'])
    
    request = get.all.repository.commits(owner, repo)
  })
  
  all.commits = all.commits[!sapply(all.commits, is.null)]
  all.commits = Reduce(function(...) merge(..., all=T), all.commits)
  all.commits$commit = format.git.date(all.commits$commit)
  all.commits 
}



