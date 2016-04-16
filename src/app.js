d3 = require('d3')

var options = {
    bar :{                
        color:'#6baed6',
        padding:0.25
    },
    width:400,
    height:400,
    margin:{
        left:100
    }
}    

options.barMaxSize = options.width - options.margin.left

d3.csv('data/categories.csv',
 function(d){
     d.count = parseInt(d.count)
     return d;
 },
 function(categories){    
    categories = categories.sort(function(a, b) { return d3.descending(a.count, b.count); });
            
    var xScale =
        d3.scale.linear()
                .domain([0,d3.max(categories.map(function(x){return x.count}))])
                .range([0,options.barMaxSize])     
    console.log()
    var yScale = 
        d3.scale.ordinal()
                .domain(categories.map(function(x){return x.category}))
                .rangeRoundBands([0,options.height],options.bar.padding)    
    var yAxis = d3.svg.axis().scale(yScale).orient('left')        
    var bar = d3.select('#container')
      .selectAll('rect')
      .data(categories)
      .enter()
      .append('g')
      .attr('transform', 'translate(' + options.margin.left + ',' + '0)')
    
    bar.append('rect')
       .attr('y',function(x){return yScale(x.category)})
       .attr('height',yScale.rangeBand())
       .attr('width',function(d){return xScale(d.count); })              
       .style('fill',options.bar.color)
      
    bar.append('text')
       .classed('number',true)
       .attr('y',function(x){return yScale(x.category)+yScale.rangeBand()/2})
       .attr('x',function(d){return xScale(d.count)-3; })
       .attr('height',yScale.rangeBand()/2)              
       .attr('dy','.35em')
       .text(function(d){return d.count});
       
    d3.select('#container')
      .append('g')
      .attr('transform', 'translate(' + options.margin.left + ',' + '0)')
      .call(yAxis)            
})


