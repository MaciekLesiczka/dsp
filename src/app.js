var d3 = require('d3')

var padding ={
    top:10,
    left:10
}

var options = {
    bar :{
        size:10,
        distance:14,
        color:'#bdbdbd'
    },    
}

d3.csv('data/categories.csv', function(categories){
    
    d3.select('#container')
    .selectAll('rect')
    .data(categories)
    .enter()
    .append('rect')
    
    .attr('y',function(_,i){return i*options.bar.distance + padding.top
        })
    .attr('height',options.bar.size)
    .attr('width',function(d){return d.count; })
    .attr('x',padding.left)
    .style('fill',options.bar.color)    
})


