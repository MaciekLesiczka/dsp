var d3 = require('d3')
var dc = require('dc')
crossfilter = require('crossfilter')
reductio = require('reductio')

var blogReductio = function () {
    return reductio()
    .filter(function(x){return x.type === 'blog'})
}

var projReductio = function () {
    return reductio()
    .filter(function(x){return x.type === 'proj'})
}

var projectReducer = projReductio()
    .exception(function(d) { return d.source; })
    .exceptionCount(true)
var postReducer = blogReductio()
    .exception(function(d) { return d.id; })
    .exceptionCount(true)

var blogReducer = blogReductio()
    .exception(function(d) { return d.source; })
    .exceptionCount(true)

d3.csv('data/20160602_all_events.csv', function(data){
    var getDate = function(d) {return new Date(d.getFullYear() , d.getMonth(), d.getDate())}
    var parseDate = d3.time.format("%Y-%m-%d").parse;
    data.forEach(function(d) {
        d.date = getDate( parseDate(d.date));
    });

    var ndx = crossfilter(data)
        var dimensions = {
        date : ndx.dimension(function(d) {return d.date;}),
        source: ndx.dimension(function(d) {return d.source}),
        id:ndx.dimension(function(d) {return d.id})
    }

    var postCounter = blogReductio().count(true)
    var commitCounter = projReductio().count(true)
    var projectsPerDay = projectReducer(dimensions.date.group());
    var postsPerDay = postReducer(dimensions.date.group());
    var projsCount = projectReducer(dimensions.source.groupAll())
    var commitsCount = commitCounter(dimensions.id.groupAll())
    var blogsCount = blogReducer(dimensions.source.groupAll())
    var postsCount = postCounter(dimensions.id.groupAll())

    minDate = dimensions.date.bottom(1)[0].date;
    maxDate = dimensions.date.top(1)[0].date;
    width = Math.min(window.innerWidth,700)
    var buildUp = function(chart){
        return chart.width(width).height(300)
        .dimension(dimensions.date)
        .renderHorizontalGridLines(true)
        .x(d3.time.scale().domain([minDate,maxDate]))

        .valueAccessor(function(d) { return d.value.exceptionCount; })
    }

    buildUp(dc.lineChart("#chart-line-projectsperday"))
        .group(projectsPerDay)
        .colors(['#377eb8'])


    buildUp(dc.lineChart("#chart-line-postsperday"))
        .group(postsPerDay)
        .brushOn(false)
        .colors(['#e41a1c'])

    var createNumberDisplay = function(group,elementId, propertyName){
        dc.numberDisplay(elementId)
         .transitionDuration(0)
         .formatNumber(d3.format("d"))
         .valueAccessor(function(d){return d[propertyName];})
         .group(group)
    }

    createNumberDisplay(projsCount,'#project-box', 'exceptionCount')
    createNumberDisplay(commitsCount,'#commit-box', 'count')
    createNumberDisplay(blogsCount,'#blog-box', 'exceptionCount')
    createNumberDisplay(postsCount,'#post-box', 'count')

    dc.renderAll();
})
