d3 = require('d3-jetpack')
d3.hive = require('./d3-hive.js')  
 
d3.csv('./data/links.csv',
 function(links){


    var degrees = function(radians) { 
        return radians / Math.PI * 180 - 90;
    }
       

     
    linkSet = {                
    }
    
    links.forEach(x=>
        {   
            var getNode=x=>{            
                return (linkSet[x]=linkSet[x]||{
                    id:x,
                    sourcesCount:0,
                    targetsCount:0
                });
            }
            var node = getNode(x.source)              
            node.targetsCount++;
            var node = getNode(x.target)
            node.sourcesCount++;
        })
    
    targets = []
    both = []
        
    sources = []
    all = []
    for(var x in linkSet)    
    {
        var node =linkSet[x]; 
        if(node.targetsCount){
            if(node.sourcesCount){                
                both.push(node)   
                node.axis = 1
            }            
            else{
                targets.push(node)
                node.axis = 2
            }
        }
        else{
            sources.push(node)
            node.axis = 0
        }
        all.push(node)
    }
    
    
    var options = {
        width :400*2,
        height:500*2,
        axisWidth:140*2,
        axis:{
            startOffset:40*2,
            endOffset:180*2,
        }        
    }
    
    sources.sort(d3.descendingKey('sourcesCount'))
    both.sort(d3.descendingKey('targetCount'))
    targets.sort(d3.descendingKey('sourcesCount'))
    
    var pointsScale = function(axisNodes){
        return d3
            .scale.ordinal()
            .domain(axisNodes.map(x=>x.id))
            .rangePoints([options.axis.startOffset+15, options.axis.endOffset-15])      
    } 
    
    var axes = [sources,both,targets]
    
    scales = axes.map(x=> pointsScale(x)) 
    
    var angle = d3.scale.ordinal().domain(d3.range(axes.length+1)).rangePoints([0, 2 * Math.PI])
    var angleDegree = x=>degrees(angle(x)) 
    var svg = 
        d3.select('body')
          .append('svg')    
          .classed('chart', true)
          .attr('width',options.width)
          .attr('height', options.height)
          .append('g')
          .translate([options.width/2,options.height/2])
          
    svg.selectAll('.axis')
       .data(d3.range((axes.length)))
       .enter()
       .append('line')
       .classed('axis', true)
       .attr('x1',options.axis.startOffset)       
       .attr('transform',d=>'rotate('+angleDegree(d)+')')       
    .attr('x2',options.axis.endOffset)
            
    svg.selectAll('circle')
        .data(all)
        .enter().append('circle')
        .attr('cx',x=> scales[x.axis](x.id))
        .attr('r',5)
        .attr('transform',x=>'rotate('+angleDegree(x.axis)+')')    
    
    svg.selectAll(".link")
       .data(links)
       .enter().append("path")
       .attr("class", "link")
       .attr("d", d3.hive.link()
                  .angle(function(d) { return angle(linkSet[d].axis); })
       .radius(function(d) {
           var node = linkSet[d] 
           return scales[node.axis](node.id); }))
       .style("stroke", 'black');              
}) 

