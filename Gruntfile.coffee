module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')

    exec:
      update_foundation:
        command: [
          'rm -Rf _src/vendor/foundation',
          'mkdir -p _src/vendor/foundation',
          [ 'curl -L -k -s https://github.com/zurb/foundation/archive/v5.2.2.tar.gz',
            'tar -xzvf - --strip-components=1 -C _src/vendor/foundation' ].join(' | '),
          'cd _src/vendor/foundation',
          'npm install && bower install',
          'grunt build:assets',
          'cd <%= dir %>',
          'cp _src/vendor/foundation/dist/assets/css/normalize.css _src/scss/includes/layout/_normalize.css'
        ].join(' && ')
        stdout: true
        stderr: true
      development_copy_assets:
        command: [
          'rm -Rf ./_build/assets/img ./_build/assets/pdf',
          'cp -Rf ./_src/img ./_build/assets/img',
          'cp -Rf ./_src/pdf ./_build/assets/pdf'
        ].join(' && ')
        stdout: true
        stderr: true
      release_copy_assets:
        command: [
          'rm -Rf ./img ./assets/pdf',
          'cp -Rf ./_src/img ./assets/img',
          'cp -Rf ./_src/pdf ./assets/pdf'
        ].join(' && ')
        stdout: true
        stderr: true


    justjaded:
      options:
        buildDir: '_build'
        debug: true
        pretty: true
        jadeData: {}
        jadeInit: require('./_inc/jade_init')
      development:
        files:
          'index.html': '_src/jade/index.jade'
          'resume.html': '_src/jade/resume.jade'
          'resume/full.html': '_src/jade/resume.jade'
          'resume/cover.html': '_src/jade/resume.jade'
          'resume/summarized.html': '_src/jade/resume.jade'
          'resume/lexicon.html': '_src/jade/resume.jade'
          'template.html': '_src/jade/template.jade'
      release:
        options:
          pretty: false
          debug: false
        files:
          'index.html': '_src/jade/index.jade'
          'resume.html': '_src/jade/resume.jade'
          'resume/full.html': '_src/jade/resume.jade'
          'resume/cover.html': '_src/jade/resume.jade'
          'resume/summarized.html': '_src/jade/resume.jade'
          'resume/lexicon.html': '_src/jade/resume.jade'
          'template.html': '_src/jade/template.jade'


    compass:
      options:
        sassDir: '_src/scss'
        specify: ['_src/scss/app.scss']
        importPath: ['_src/vendor/foundation/scss']
        outputStyle: 'expanded'
      development:
        options:
          cssDir: '_build/assets/css'
      release:
        options:
          cssDir: 'assets/css'
          outputStyle: 'compressed'


    uglify:
      options:
        compress:
          drop_console: true
        mangle:
          except: [
            'jQuery',
            'Backbone'
          ]
        beautify:
          width: 80,
          beautify: true
      development:
        options:
          beautify: true
        files:
          '_build/assets/js/app.js': [
            '_src/vendor/foundation/dist/docs/assets/js/modernizr.js',
            '_src/vendor/foundation/dist/docs/assets/js/jquery.js',
            '_src/vendor/foundation/dist/assets/js/foundation.js',
            # '_src/js/**/*.coffee',
            '_src/js/**/*.js'
          ]
      release:
        options:
          beautify: false
        files:
          'assets/js/app.js': [
            '_src/vendor/foundation/dist/docs/assets/js/modernizr.js',
            '_src/vendor/foundation/dist/docs/assets/js/jquery.js',
            '_src/vendor/foundation/dist/assets/js/foundation.js',
            # '_src/js/**/*.coffee',
            '_src/js/**/*.js'
          ]


    watch:
      grunt:
        files: ['Gruntfile.js']

      justjaded:
        files: [
          '_src/jade/**/*.jade',
          '_src/yaml/**/*.yaml'
        ]
        tasks: ['justjaded:development']

      compass:
        files: '_src/scss/**/*.scss'
        tasks: ['compass:development']

      uglify:
        files: [
          '_src/sjs/**/*.coffee',
          '_src/sjs/**/*.js'
        ]
        tasks: ['uglify:development']


  # Load in tasks from packages
  grunt.loadNpmTasks 'jaded'
  grunt.loadNpmTasks 'grunt-exec'
  grunt.loadNpmTasks 'grunt-contrib-jade'
  grunt.loadNpmTasks 'grunt-contrib-compass'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-watch'

  # Build development site
  grunt.registerTask 'build:development', [
    'exec:development_copy_assets',
    'compass:development',
    'uglify:development'
    'justjaded:development'
  ]

  # Build production sit
  grunt.registerTask 'build', [
    'exec:release_copy_assets',
    'justjaded', 'compass', 'uglify'
  ]

  # Update Vendors
  grunt.registerTask 'vendor:update', [
    'exec:update_foundation',
  ]

  # Default Task
  grunt.registerTask 'default', ['build:development', 'watch']

  # Release Task
  grunt.registerTask 'release', ['build']
