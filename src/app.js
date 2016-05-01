var d3 = require('d3-jetpack')

var options = {
    bar :{                
        color:'#6baed6',
        selected:'#3182bd',
        padding:0.3
    },
    width:450,
    height:350, 
    margin:{
        left:100,
        top:40,
        bottom:25
    },
    description:{
        width:150
    }
}    

options.barWidth = options.width - options.margin.left
options.barHeight = options.height - options.margin.top - options.margin.bottom

d3.csv('data/categories.csv',
 function(d){
     d.count = parseInt(d.count)
     return d;
 },
 function(categories){    
    categories.sort(d3.descendingKey('count'));
            
    var xScale =
        d3.scale.linear()
                .domain([0,d3.max(categories.map(function(x){return x.count}))])
                .range([0,options.barWidth])     
    var yScale = 
        d3.scale.ordinal()
                .domain(categories.map(function(x){return x.category}))
                .rangeRoundBands([0,options.barHeight],options.bar.padding,0)    
    var yAxis = d3.svg.axis().scale(yScale).orient('left')   
    
    var chart = d3.select('#container')
      .append('g')
      .translate([options.margin.left,options.margin.top])
         
    var bars = chart
      .selectAll('g.bar-group')
      .data(categories)
      .enter()
      .append('g')
      .classed('bar-group', true)
      .translate(function(x) {return[0,yScale(x.category)]})
      .on('mouseover', function(d){                
         d3.select(this).select('rect').style('fill', options.bar.selected)
         d3.select('#description').select('span').text(d.description)
      })
      .on('mouseout', function(d){
          d3.select(this).select('rect').style('fill', options.bar.color)
          d3.select('#description').select('span').text('')
      });
      
    bars.append('rect')       
       .attr('height',yScale.rangeBand()) 
       .attr('width',function(d){return xScale(d.count); })              
       .style('fill',options.bar.color)

      
    bars.append('text')
       .classed('number',true)
       .attr('y',yScale.rangeBand()/2)
       .attr('x',function(d){return xScale(d.count)-3; })                     
       .attr('dy','.35em')
       .text(function(d){return d.count});
              
    yAxis(chart)   
          
    d3.select('#container')         
        .append('text')
        .classed('title',true)
        .text('DSP \'16 Projects' )                
        .attr('y', options.margin.top/2)
        .attr('dy','.35em')      
        
    d3.select('#description')
      .style('width',options.description.width)
      .style('left', options.width - options.description.width)
      .style('height',options.height - options.margin.bottom)            
})
