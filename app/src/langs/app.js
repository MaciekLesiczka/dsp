
var d3 = require('d3')
var ParallelCoordinates = require('./parallelcoordinates')

	d3.csv("langs.csv", function(d){
        
         d['posts'] =  +d['posts']; ; 
         d['repos_cnt'] = parseInt(d['repos_cnt']);
         d['main_cnt'] = +d['main_cnt']; 
         d['code_size_kb'] = +d['code_size_kb']; 
         return d       
    } ,function(data){

        
		var events={};        
        
		pc=ParallelCoordinates(data,{			
			container:"#pc",
			scale:"linear",
			columns:["lang","code_size_kb","repos_cnt","main_cnt","posts"],			
			title_column:"lang",
			scale_map:{				
				"lang":"ordinal",				
				"repos_cnt":"ordinal",
				"posts":"ordinal",
				"main_cnt":"ordinal",
				"code_size_kb":"ordinal"
			},
			use:{
				"lang":"code_size_kb"
			},
			sorting:{
				"lang":d3.ascending
			},
			formats:{
				"year":"d"
			},
			dimensions:["lang","repos_cnt","posts","main_cnt","code_size_kb"],
			column_map:{
				"lang":["Project","Language"],
                "code_size_kb":['Code Size', 'in KB'],		
				"repos_cnt":["Projects", "Count"],				
				"main_cnt":"Main Language",
                "posts":["Stack Overflow", "posts"],						
			},
			help:{
				"lang":"<h5>Project Language</h5>Programming language of the DSP Projects.<br/>Ordered by current overall code size.",
				"repos_cnt":"<h5>Projects Count</h5>Total number of projects that use given language.",
				"posts":"<h5>StackOverflow posts</h5>Number of posts in StackOverflow tagged by given language per March 2016.",
				"main_cnt":"<h5>Main Language</h5>Number of projects where given language is the leading one.<br /> Calculated by code size.",
				"code_size_kb":"<h5>Total Code size in KB</h5>Total code size across all projects, in kilobytes.",				
			},
			duration:1000,
			path:"server/exports/",
			extension:"csv"
		});
	});

	

		 
