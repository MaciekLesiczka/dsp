'use strict'
var gulp = require('gulp');
var gutil = require('gulp-util');
var source = require('vinyl-source-stream');

var browserify = require('browserify');
var watchify = require('watchify');
var browserSync = require('browser-sync');


gulp.task('browserify',function(){
	var b = browserify({
		entries:'app.js',
		cache:{},
		packageCache:{},
		plugin:[watchify]
	});		
	b.on('update', bundle);
	b.on('log', gutil.log); 
	
	function bundle(){		
		b.bundle()
			.on('error', gutil.log.bind(gutil, 'Browserify Error'))
			.pipe(source('bundle.js'))        
			.pipe(gulp.dest('./js/'));
	}
	bundle();
})

gulp.task('copy', function(){
	return gulp.src('../data/sample.csv')
	.pipe(gulp.dest('./data/'));
})

var reload = browserSync.reload;
gulp.task('serve', function() {
  browserSync({
    server: {
      baseDir: '.'
    }
  });
	gulp.watch(['*.html', 'js/**/*.js'], {cwd: '.'}, reload);
});

gulp.task('default', ['copy', 'browserify', 'serve'])