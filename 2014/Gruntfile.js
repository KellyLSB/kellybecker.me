module.exports = function(grunt) {
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),

    compass: {
      options: {
        importPath: ['bower_components/foundation/scss'],
        outputStyle: 'expanded'
        //outputStyle: 'compressed'
      },                 // Task
      dist: {                   // Target
        options: {
          cssDir: 'css',
          sassDir: 'scss',
          specify: ['scss/app.scss']
        }
      }
    },

    uglify: {
      options: {
        compress: {
          drop_console: true
        },
        mangle: {
          except: ['jQuery', 'Backbone']
        },
        beautify: {
          width: 80,
          beautify: true
        }
        //beautify: false
      },
      dist: {
        files: {
          'js/app.min.js': [
            'bower_components/modernizr/modernizr.js',
            'bower_components/jquery/dist/jquery.min.js',
            'bower_components/foundation/js/foundation.min.js',
            'sjs/**/*.js'
          ]
        }
      }
    },

    watch: {
      grunt: { files: ['Gruntfile.js'] },

      compass: {
        files: 'scss/**/*.scss',
        tasks: ['compass']
      },

      uglify: {
        files: 'sjs/**/*.js',
        tasks: ['uglify']
      }
    }
  });

  grunt.loadNpmTasks('grunt-sass');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-compass');
  grunt.loadNpmTasks('grunt-contrib-uglify');

  grunt.registerTask('build', ['compass', 'uglify']);
  grunt.registerTask('default', ['build','watch']);
}
