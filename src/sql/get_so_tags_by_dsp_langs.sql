;with
langs
as
(
		  select 'Ruby' lang ,'ruby' tag
union all select 'Dart','dart'
union all select 'HTML','html'
union all select 'Python','python'
union all select 'C#','c#'
union all select 'Batchfile','batch-file'
union all select 'C','c'
union all select 'C++','c++'
union all select 'Lua','lua'
union all select 'Shell','shell'
union all select 'Java','java'
union all select 'CSS','css'
union all select 'JavaScript','javascript'
union all select 'Arduino','arduino'
union all select 'ASP','asp-classic'
union all select 'CoffeeScript','coffeescript'
union all select 'GLSL','glsl'
union all select 'Objective-C','objective-c'
union all select 'ApacheConf','apache'
union all select 'PHP','php'
union all select 'M4','m4'
union all select 'Makefile','makefile'
union all select 'D','d'
union all select 'Smalltalk','smalltalk'
union all select 'F#','f#'
union all select 'Swift','swift'
union all select 'PowerShell','powershell'
union all select 'TypeScript','typescript'
union all select 'Scala','scala'
union all select 'PureScript','purescript'
union all select 'Pascal','pascal'
union all select 'Puppet','puppet'
union all select 'Elixir','elixir'
union all select 'QMake','qmake'
union all select 'CMake','cmake'
union all select 'Emacs Lisp','elisp'
union all select 'Haskell','haskell'
union all select 'NSIS','nsis'
union all select 'Xtend','xtend'
union all select 'Groff','groff'
union all select 'R','r'
union all select 'GDScript','gdscript'
union all select 'Cucumber','cucumber'
union all select 'VimL','viml'
union all select 'Assembly','assembly'
union all select 'Perl','perl'
union all select 'XSLT','xslt'
union all select 'ANTLR','antlr'
union all select 'Processing','processing'
union all select 'Go','go'
union all select 'Protocol Buffer','protocol-buffers'
union all select 'ActionScript','actionscript'
union all select 'Smarty','smarty'
union all select 'Web Ontology Language','owl'
)
select count(*), lang
       from Posts p
       join PostTags pt
         on pt.PostId = p.Id
       join Tags t on t.Id = pt.TagId
       join langs l on l.tag = t.TagName
       where p.CreationDate >= '20160301'       
       --and t.TagName in (select tag from langs) 
       group by l.lang







