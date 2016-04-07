var d3 = require('d3')

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


d3.select('#container')
  .selectAll('rect')
  .data(categories)
  .enter()
  .append('rect')
  .attr('x',10)
  .attr('y',function(_,i){return i*10})
  .attr('height',8)
  .attr('width',function(d){return d.count; })
