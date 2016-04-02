d3 = require('d3')
require('d3-jetpack')

require('d3-transform')

var tags = {};
var cloud = require('d3.layout.cloud-browserify')
var fill = d3.scale.category20();
var cloudSize = 500;
var hintHeight = 20;
var pane = d3.select("body").select('div.container-fluid').select("#techcloud")
    .select('svg')
    .attr("width", cloudSize)
    .attr("height", cloudSize + hintHeight);
var selectedColor = function (i) {
    return d3.rgb(fill(i)).darker(3)
}


var selectTagOnDetailsPane = function (d, i) {
    var details = d3.select('#techcloud').select('div.dev-list');
    details.selectAll('span').html(d.text)


    var links = details.select('div.dev-links').selectAll('a').data(tags[d.text]);

    var populate = function(selection) {
        selection
            .attr('href', function(d) { return d })
            .html(function(d) { return d })
            .attr('class', 'small')
            .attr('target','_blank');
    }

    populate(links);    
    populate(links.enter().append('a'));
    links.exit().remove();

    d3.select(this).style('fill', selectedColor(i))
}

var draw = function (words) {
    var transform = d3.svg.transform()
        .translate(function (d) { return [d.x, d.y] })
        .rotate(function (d) { return d.rotate })

    var hint = pane
        .append('text.hint')
        .text('click on a tag to keep selection')
        .attr('x', 5)
        .attr('y',cloudSize + hintHeight/2)
        .style('font-size', '12px')
        .style('font-style', 'italic')
        .style('fill', '#999');



    pane.append("g.wordcloud")
        .translate([layout.size()[0] / 2, layout.size()[1] / 2])
        .selectAll("text")
        .data(words)
        .enter()
        .append("text.tag")
        .style("font-size", function(d) { return d.size + "px"; })
        .style("fill", function(d, i) { return fill(i); })
        .style("cursor", "pointer")
        .attr("text-anchor", "middle")
        .text(function(d) { return d.text; })
        .on('mouseover', function(d, i) {
            if (!words.selected) {
                selectTagOnDetailsPane.bind(this)(d, i);
            }
        })
        .on('mouseout', function(d, i) {
            if (!words.selected && words.selected !== d) {
                var details = d3.select('#techcloud').select('div.dev-list');
                details.selectAll('span').html('')
                details.selectAll('a').remove()                
                d3.select(this).style('fill', fill(i))
            }
        })
        .on('click', function(d, i) {
            if (words.selected === d) {
                words.selected = undefined;
            } else {
                words.selected = d;
                selectTagOnDetailsPane.bind(this)(d, i);

            }
            refreshSelection(words)
            hint.transition()
                .delay(500)
                .duration(1000)
                .style('fill', '#fff')
        })
        //.transition()
        //.duration(1300)
        .attr("transform", transform);
}


var refreshSelection = function(words) {
    pane.select('g.wordcloud').selectAll('text').data(words).style('fill', function(d, i) {
     if (words.selected===d) {
         return selectedColor(i);
     }
     else {
         return fill(i);
     }
    })
}



var layout = cloud()
d3.csv('tech_tags.csv', function (data) {


    data.forEach(function (x) { tags[x.tag] = x.devs.split(',') })

    var freqRange = d3.extent(data, function (x) { return parseInt(x.count) })
    wordScale = d3.scale.linear().domain(freqRange).range([15, 100])
    var tagLettrCountMedian = d3.median(data, function (x) { return x.tag.length })

    
    

    layout
        .size([cloudSize, cloudSize])
        .words(data.map(function (d) {
            return { text: d.tag, size: wordScale(d.count) };
          }))
        .padding(1)
        .rotate(function (d) { return d.text.length <  tagLettrCountMedian ? 90 : 0; })
        .font("Impact")
        .fontSize(function (d) { return d.size; })
        .on("end", draw);

    layout.start();

});


pane.append('g.details').translate([cloudSize, 50])
