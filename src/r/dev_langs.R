source('github_utils.r')


repos = read.csv("../../data/repos.csv")

dsp.get.langs = function(repos){ 
  
  all.langs = apply(repos,1,function(x){
    owner = as.character(x['repo_owner'])
    repo = as.character(x['repo_name'])
    
    request = get.repository.languages(owner, repo)
    if(request$code != 200 && request$code != 304){
      print(paste(request$content$message, "for", owner, ", repo", repo))
      NULL
    }
    else{
      print (names(request$content))
      if(length(request$content)>0){
        languages = data.frame(
          lang =names(request$content),
          bytes = as.numeric(request$content),
          repo_owner = owner,
          repo_name = repo)  
      }
      else{
        NULL
      }
    }
  })
  
  all.langs = all.langs[!sapply(all.langs, is.null)]
  all.langs = Reduce(function(...) merge(..., all=T), all.langs)
  all.langs 
}


#dsp.langs=fread('../../data/gh_langs.csv')
#uncomment line below to get languages directly from github instead (and you can go for coffee)
dsp.langs = dsp.get.langs(repos)

dsp.langs = dsp.langs[,sum(bytes), by =.(repo_owner,lang)]





dsp.lang.stats =
(function() {
    dsp.lang.stats = data.table(data.frame(table(as.sorted.factor(dsp.langs$lang))))
    names(dsp.lang.stats) = c('lang', 'ocurrence')
    setkey(dsp.lang.stats, lang)
    by.size = data.table(dsp.langs)[, sum(bytes) / 1024, by = lang]
    setkey(by.size, lang)
    names(by.size) = c('lang', 'code_size_kb')
    dsp.lang.stats = dsp.lang.stats[by.size]

    #.SD gives 1 row in subset groupped by repo_name
    lang.main = data.table(dsp.langs)[order(repo_owner, - bytes)][, .SD[1], by = repo_owner]
    lang.main = data.frame(table(as.sorted.factor(lang.main$lang)))
    lang.main = data.table(lang.main)
    names(lang.main) = c('lang', 'repos')
    setkey(lang.main, lang)    
    lang.main[dsp.lang.stats]
    dsp.lang.stats = lang.main[dsp.lang.stats]
    dsp.lang.stats[is.na(repos)]$repos = 0

    dsp.langs.so.posts = fread('../../data/dsp_langs_in_so_popularity.csv')  
    setkey(dsp.langs.so.posts, lang)    
    dsp.lang.stats = dsp.langs.so.posts[dsp.lang.stats]
    dsp.lang.stats[is.na(posts)]$posts = 0
    dsp.lang.stats
})()
write.csv(dsp.lang.stats, "../../data/dsp.lang.stats.csv", fileEncoding = "UTF-8", row.names=F)





(function(){
  data = dsp.lang.stats
  data$lang = factor(data$lang, data[order(data$ocurrence, decreasing = F)]$lang)
  data$label = data$ocurrence
  data$label[data$label<4]=''
  ggplot(data) + 
    geom_bar(aes(x=lang, y=ocurrence), stat='identity') +
    geom_text(aes(x=lang, y=ocurrence, label=label, hjust=1.3), colour='white', position = position_dodge(width=1))+
    coord_flip() +
    xlab('')+
    dsp_theme()+
  ylab('Projects count')+
  ggtitle('Languages occurrence')
})()

(function(){
  lang.by.bytes = dsp.lang.stats
  lang.by.bytes$lang = factor(lang.by.bytes$lang, lang.by.bytes[order(lang.by.bytes$code_size_kb, decreasing = F)]$lang)
  ggplot(lang.by.bytes) + geom_bar(aes(x = lang, y = code_size_kb), stat = 'identity') + coord_flip() +
  theme_minimal()+
  xlab('')+
  ggtitle('Overall code size')
})()

(function() {
    data = dsp.lang.stats[repos != 0]
    data$lang = factor(data$lang, data[order(data$repos, decreasing = F)]$lang)
    data$label = data$repos
    data$label[data$label < 2] = ''
    ggplot(data) +
    geom_bar(aes(x = lang, y = repos), stat = 'identity') +
    geom_text(aes(x = lang, y = repos, label = label, hjust = 1.3), colour = 'white', position = position_dodge(width = 1)) +
    coord_flip() +
    xlab('') +
    dsp_theme() +
    ylab('Projects count') +
    ggtitle('Main languages')
})()

(function() {
    data = dsp.lang.stats
    data$lang = factor(data$lang, data[order(data$posts, decreasing = F)]$lang)
    ggplot(data) +
    theme_minimal() +
    geom_bar(aes(x = lang, y = posts), stat = 'identity') + coord_flip() +
    xlab('') +
    ylab('Tagged posts on Stackoverflow in March 2016') +
    ggtitle('DSP languages popularity on StackOverflow')
})()







