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


dsp.langs=fread('../../data/gh_langs.csv')
#uncomment line below to get languages directly from github instead (and you can go for coffee)
#dsp.langs = dsp.get.langs(repos)

dsp.langs = dsp.langs[,sum(bytes), by =.(repo_owner,lang)]
names(dsp.langs) = c('repo_owner','lang', 'bytes')
dsp.langs


(function(){
  data = data.frame(table(as.sorted.factor(dsp.langs$lang)))
  data$label = data$Freq
  data$label[data$label<4]=''
  ggplot(data) + 
    geom_bar(aes(x=Var1, y=Freq), stat='identity') +
    geom_text(aes(x=Var1, y=Freq, label=label, hjust=1.3), colour='white', position = position_dodge(width=1))+
    coord_flip() +
    xlab('')+
    dsp_theme()+
  ylab('Projects count')+
  ggtitle('Languages occurrence')
})()


(function(){
  lang.by.bytes = data.table(dsp.langs)[, sum(bytes), by = lang]
  lang.by.bytes$lang = factor(lang.by.bytes$lang,lang.by.bytes[order(lang.by.bytes$V1,decreasing = F)]$lang)  
  lang.by.bytes$kbytes = lang.by.bytes$V1/1024
  ggplot(lang.by.bytes) + geom_bar(aes(x = lang,y=kbytes), stat='identity')+ coord_flip()   +
  theme_minimal()+
  xlab('')+
  ggtitle('Overall code size')
})()

(function(){
  #.SD gives 1 row in subset groupped by repo_name
  lang.main = data.table(dsp.langs)[order(repo_owner, -bytes)][, .SD[1], by=repo_owner]
  data = data.frame(table(as.sorted.factor(lang.main$lang)))
  data$label = data$Freq
  data$label[data$label<2]=''
  ggplot(data) + 
    geom_bar(aes(x=Var1, y=Freq), stat='identity') +
    geom_text(aes(x=Var1, y=Freq, label=label, hjust=1.3), colour='white', position = position_dodge(width=1))+
    coord_flip() +
    xlab('')+
    dsp_theme()+
  ylab('Projects count') +
    ggtitle('Main languages')
})()


(function(){
  dsp.langs.so.posts = fread('../../data/dsp_langs_in_so_popularity.csv')
  dsp.langs.so.posts$lang = factor(dsp.langs.so.posts$lang,dsp.langs.so.posts[order(posts)]$lang)
  ggplot(dsp.langs.so.posts) + 
    theme_minimal() + 
    geom_bar(aes(x = lang,y=posts), stat='identity') + coord_flip()+
    xlab('') +
    ylab('Tagged posts on Stackoverflow in March 2016') +
    ggtitle('DSP languages popularity on StackOverflow')
})()







