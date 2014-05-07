module.exports = (grunt) ->
  $ = new (require('./_inc/index'))('_config.yaml')


  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')
    dir: process.cwd()
    config: $.config


    exec:
      update_foundation:
        command: [
          'rm -Rf <%= config.vendor.foundation.path %>',
          'mkdir -p <%= config.vendor.foundation.path %>',
          [ 'curl -L -k -s https://github.com/zurb/foundation/archive/v5.2.2.tar.gz',
            'tar -xzvf - --strip-components=1 -C <%= config.vendor.foundation.path %>' ].join(' | '),
          'cd <%= config.vendor.foundation.path %>',
          'npm install && bower install',
          'grunt build:assets',
          'cd <%= dir %>',
          'cp <%= config.vendor.foundation.path %>/dist/assets/css/normalize.css _src/scss/includes/layout/_normalize.css'
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


    jade:
      options:
        pretty: true
        compileDebug: true
        data: (dest, file) ->
          # Patch: Jade Glob
          $.initJadeGlob this.jade
          $.initClassExtensions()

          helpers: $.jadeHelpers
          assetPath: $.jadeAssetPath(dest)
          pageData: $.jadePageData(dest, file.shift())
          timestamp: "<%= grunt.template.today() %>"
      development:
        files:
          '_build/index.html': '_src/jade/index.jade'
          '_build/resume.html': '_src/jade/resume.jade'
          '_build/resume/full.html': '_src/jade/resume.jade'
          '_build/resume/cover.html': '_src/jade/resume.jade'
          '_build/resume/summarized.html': '_src/jade/resume.jade'
          '_build/template.html': '_src/jade/template.jade'
      release:
        options:
          pretty: false
          compileDebug: false
        files:
          'index.html': '_src/jade/index.jade'
          'resume.html': '_src/jade/resume.jade'
          'resume/full.html': '_src/jade/resume.jade'
          'resume/cover.html': '_src/jade/resume.jade'
          'resume/summarized.html': '_src/jade/resume.jade'
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
            '<%= config.vendor.foundation.path %>/dist/docs/assets/js/modernizr.js',
            '<%= config.vendor.foundation.path %>/dist/docs/assets/js/jquery.js',
            '<%= config.vendor.foundation.path %>/dist/assets/js/foundation.js',
            # '_src/js/**/*.coffee',
            '_src/js/**/*.js'
          ]
      release:
        options:
          beautify: false
        files:
          'assets/js/app.js': [
            '<%= config.vendor.foundation.path %>/dist/docs/assets/js/modernizr.js',
            '<%= config.vendor.foundation.path %>/dist/docs/assets/js/jquery.js',
            '<%= config.vendor.foundation.path %>/dist/assets/js/foundation.js',
            # '_src/js/**/*.coffee',
            '_src/js/**/*.js'
          ]


    watch:
      grunt:
        files: ['Gruntfile.js']

      jade:
        files: [
          '_src/jade/**/*.jade',
          '_src/yaml/**/*.yaml'
        ]
        tasks: ['jade:development']

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
    'jade:development'
  ]

  # Build production sit
  grunt.registerTask 'build', [
    'exec:release_copy_assets',
    'jade', 'compass', 'uglify'
  ]

  # Update Vendors
  grunt.registerTask 'vendor:update', [
    'exec:update_foundation',
    'exec:update_modernizr',
    'exec:update_jquery'
  ]

  # Default Task
  grunt.registerTask 'default', ['build:development', 'watch']

  # Release Task
  grunt.registerTask 'release', ['build']
