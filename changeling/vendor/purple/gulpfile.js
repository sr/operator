'use strict';

var gulp = require('gulp');
var runSequence = require('run-sequence');

var bump = require('gulp-bump');
var concat = require('gulp-concat');
var git = require('gulp-git');
var minifyCSS = require('gulp-minify-css');
var rename = require('gulp-rename');
var sass = require('gulp-sass');
var uglify = require('gulp-uglify');

var args = require('yargs').argv;

var config = {
  PURPLE_SCSS: './sass/',
  PURPLE_JS: './js/',
  DIST_DIR: './dist/',
  JQUERY_JS: './bower_components/jquery/dist/jquery.js',
  BOOTSTRAP_DIR: './bower_components/bootstrap-sass-official/assets/javascripts/bootstrap/'
};

// Compile and minify Sass

gulp.task('styles', function() {
  var cssDest = config.DIST_DIR + 'css';

  return gulp.src(config.PURPLE_SCSS + 'purple.scss')
    .pipe(sass({includePaths: ['bower_components']}))
    .pipe(gulp.dest(cssDest))
    .pipe(rename({suffix: '.min'}))
    .pipe(minifyCSS())
    .pipe(gulp.dest(cssDest));
});


// Concatenate and minify Javascript

gulp.task('scripts', function() {
  var jsDest = config.DIST_DIR + 'js';

  return gulp.src([config.JQUERY_JS,
                   config.BOOTSTRAP_DIR + 'tooltip.js', config.BOOTSTRAP_DIR + '*.js',
                   config.PURPLE_JS + 'purple.js'])
    .pipe(concat('purple.js'))
    .pipe(gulp.dest(jsDest))
    .pipe(rename({suffix: '.min'}))
    .pipe(uglify())
    .pipe(gulp.dest(jsDest));
});


// Convenience method to bump package version
// `gulp bump [--type=major|minor|patch]` (defaults to patch)

gulp.task('bump', function() {
  var type = args.type || '';

  return gulp.src(['./bower.json'])
    .pipe(bump({type: type}))
    .pipe(gulp.dest('./'));
});


// Helper methods for tagging

var tagVersion = function() {
  var bower = require('./bower.json');
  return 'v' + bower.version;
};

var tagMessage = function() {
  return 'Release ' + tagVersion();
};

// Create the tag for the commit

gulp.task('tag-git-commit', function() {
  return gulp.src('./bower.json')
    .pipe(git.add({}))
    .pipe(git.commit(tagMessage(), {}));
});

gulp.task('tag-git-tag', ['tag-git-commit'], function(){
  git.tag(tagVersion(), tagMessage());
});

// The `tag-git-commit` synchronous sub-task is required because of a gulp-git
// bug. See: https://github.com/stevelacy/gulp-git/issues/14
gulp.task('tag', ['tag-git-tag'], function() {
  git.push('origin', 'master', {args: '--tags'}).end();
});


gulp.task('default', ['styles', 'scripts'], function() {});


gulp.task('watch', ['default'], function() {
  gulp.watch(config.PURPLE_SCSS + '**/*.scss', ['styles']);
  gulp.watch(config.PURPLE_JS + '**/*.js', ['scripts']);
});


gulp.task('release', function(callback) {
  runSequence('bump', 'tag', callback);
});
