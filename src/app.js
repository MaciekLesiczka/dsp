d3 = require('d3')

// web  mobile     iot    game    tool    data windows 
// 121      46      30      50      53      16      28 


var categories = [
   {name:'web', count: 121},
   {name:'mobile', count: 46},
   {name:'iot', count: 30},
   {name:'game', count: 50},
   {name:'tool', count: 53},
   {name:'data', count: 16},
   {name:'windows', count: 28}
]

var padding ={
    top:10,
    left:10
}

var options = {
    bar :{
        size:8,
        distance:10
    },    
}

d3.select('#container')
  .selectAll('rect')
  .data(categories)
  .enter()
  .append('rect')
  .attr('x',padding.left)
  .attr('y',function(_,i){return i*options.bar.distance + padding.top})
  .attr('height',options.bar.size)
  .attr('width',function(d){return d.count; })
  .style('fill', "#bdbdbd")
