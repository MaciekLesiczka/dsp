var d3 = require('d3')
var dc = require('dc')
crossfilter = require('crossfilter')
reductio = require('reductio')
 

d3.csv('data/20160507_all_events.csv', function(data){    
    var getDate = d => new Date(d.getFullYear() , d.getMonth(), d.getDate())    
    var parseDate = d3.time.format("%Y-%m-%d").parse;
    data.forEach(function(d) {
        d.date = getDate( parseDate(d.date));
        d.total= 1;
    });
         
    var ndx = crossfilter(data)
    
    var projectReducer = reductio()
        .filter(x=> x.type === 'proj') 
        .exception(function(d) { return d.source; })
        .exceptionCount(true)
    var postReducer = reductio()
        .filter(x=> x.type === 'blog') 
        .exception(function(d) { return d.id; })
        .exceptionCount(true)
    
    var blogReducer = reductio()
        .filter(x=> x.type === 'blog') 
        .exception(function(d) { return d.source; })
        .exceptionCount(true)
    
    dateDim = ndx.dimension(function(d) {return d.date;});
    var projDim = ndx.dimension(function(d) {return d.source}) 
       
    var idDim = ndx.dimension(function(d) {return d.id})
       
    var postCounter = reductio()        
           .filter(x=> x.type === 'blog')
           .count(true)
    var commitCounter = reductio()        
           .filter(x=> x.type === 'proj')
           .count(true)
    var projectsPerDay = projectReducer(dateDim.group());
    var postsPerDay = postReducer(dateDim.group()); 
     
    
            
    var projsCount = projectReducer(projDim.groupAll())   
    var commitsCount = commitCounter(idDim.groupAll())         
    var blogsCount = blogReducer(projDim.groupAll())
    var postsCount = postCounter(idDim.groupAll())
    
    minDate = dateDim.bottom(1)[0].date;
    maxDate = dateDim.top(1)[0].date;

    // var lineChart1 =dc.lineChart("#chart-line-projectsperday") 
    // lineChart1 
    //     .width(700).height(300)
    //     .dimension(dateDim)
    //     .group(projectsPerDay)
    //     .valueAccessor(function(d) { return d.value.exceptionCount; })                
    //     .x(d3.time.scale().domain([minDate,maxDate]))
           
(function() {
    var compositeChart = dc.compositeChart;
    dc.compositeChart = function(parent, chartGroup) {
        var _chart = compositeChart(parent, chartGroup);
        
        _chart._brushing = function () {
            var extent = _chart.extendBrush();
            var rangedFilter = null;
            if(!_chart.brushIsEmpty(extent)) {
                rangedFilter = dc.filters.RangedFilter(extent[0], extent[1]);
            }

            dc.events.trigger(function () {
                if (!rangedFilter) {
                    _chart.filter(null);
                } else {
                    _chart.replaceFilter(rangedFilter);
                }
                _chart.redrawGroup();
            }, dc.constants.EVENT_DELAY);
        };
        
        return _chart;
    };
})();    
    
    var comp = dc.compositeChart("#chart-line-projectsperday")
    .width(700).height(300)
    .dimension(dateDim)
    .legend(dc.legend().x(50).y(10).itemHeight(13).gap(5))
    
    .x(d3.time.scale().domain([minDate,maxDate]));
    
    lineChart1 = dc.lineChart(comp)   
        
        .group(projectsPerDay,"123")
        .brushOn(true)        
        .colors(['#248221'])
        .valueAccessor(function(d) { return d.value.exceptionCount; })                
    lineChart2 = dc.lineChart(comp)                 
        .group(postsPerDay,"121")
        .brushOn(true)
        .valueAccessor(function(d) { return d.value.exceptionCount; })        
    
    comp.compose([lineChart1,lineChart2])
    
    
    dc.numberDisplay('#project-box')
      .formatNumber(d3.format(".3s"))
      .valueAccessor(function(d){return d.exceptionCount})
      .group(projsCount)
    dc.numberDisplay('#commit-box')
      .formatNumber(d3.format(".3s"))
      .valueAccessor(function(d){return d.count})
      .group(commitsCount)   
    dc.numberDisplay('#blog-box')
      .formatNumber(d3.format(".3s"))
      .valueAccessor(function(d){return d.exceptionCount})
      .group(blogsCount)  
    dc.numberDisplay('#post-box')
      .formatNumber(d3.format(".3s"))
      .valueAccessor(function(d){return d.count})
      .group(postsCount)              
        
    dc.renderAll(); 

})
