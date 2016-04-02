'use strict'
var gulp = require('gulp');
var gutil = require('gulp-util');
var source = require('vinyl-source-stream');
var browserify = require('browserify');


var getBundle = function(component){
    var b = browserify({
		entries:'./'+component+'/app.js',
		cache:{},
		packageCache:{},		
	});			
	b.on('log', gutil.log); 
	
	return function bundle(){		
		b.bundle()
			.on('error', gutil.log.bind(gutil, 'Browserify Error'))
			.pipe(source('bundle.js'))        
			.pipe(gulp.dest('./'+component+'/'));
	}
    
}

gulp.task('browserify',function(){    
    getBundle('langs')()
    getBundle('cloud')()
})


gulp.task('default', ['browserify'])
