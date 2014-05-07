module.exports = class SiteConfig

  # Node core
  node: {
    fs: require('fs')
    path: require('path')
  }


  # Included libraries
  lib: {
    glob:      require('glob')
    yaml:      require('js-yaml')
    yaml_glob: require('./yaml_glob')
    jade_glob: require('jade-glob-include')
    marked:    require('marked')
    highlight: require('highlight.js')
  }


  # Constructor
  constructor: (@configFile) ->

    # Initialize Yaml Glob Include
    @initYamlGlob()

    # Load in Site Configuration
    @config = @lib.yaml_glob.loadFile(@configFile)


  # Jade Glob Includer
  initJadeGlob: (jade) ->
    @lib.jade_glob.tmpDir('_src/tmp').patch(jade)
    true


  # Yaml Glob Includer
  initYamlGlob: ->
    @lib.yaml_glob._ = @
    true


  # Setup Markdown Parser
  initMarked: ->
    @lib.marked.setOptions
      renderer: new @lib.marked.Renderer()
      gfm: true
      tables: true
      breaks: false
      pedantic: false
      sanitize: true
      smartLists: true
      smartypants: true
      highlight: (code, lang) =>
        if lang
          @lib.highlight.highlight(lang, code).value
        else
          @lib.highlight.highlightAuto(code).value


  # String Extensions
  initClassExtensions: ->
    $ = @

    String.prototype.repeat = (x, y) ->
      new Array((x * (y || 1)) + 1).join(this)

    String.prototype.anchorname = (ns) ->
      name = if ns then ns + '-' + @ else @
      name.toLowerCase().replace(/[^\w]+/gi, '-')

    String.prototype.anchorlink = (ns) ->
      '#' + this.anchorname(ns)

    String.prototype.markdown = ->
      $.lib.marked(@)

    Array.prototype.unique = ->
      cache = {}; for data, index in @
        if cache[data] then continue
        cache[data] = true
        data


  # Jade Template Helpers
  jadeHelpers:
    function: ->


  # Get Jade Page Data
  jadePageData: (dest, file) ->

    # Get the base path from the destination file
    basepath = @node.path.basename(@node.path.dirname(@getBuildDirectory(dest)))

    # Get the page data
    @lib.yaml_glob.getPageData(dest, basepath)


  # Get Asset Path
  jadeAssetPath: (dest) ->

    # Get the destination file directory
    destdir = @node.path.dirname(dest)

    # Get the build directory from the destination directory
    buildir = @getBuildDirectory(destdir)

    # Get the asset directory from the build directory
    assetdir = @node.path.resolve(buildir, 'assets')

    # Return relative asset path from destination file
    @node.path.relative(destdir, assetdir)


  # Get full build directory from dest file
  getBuildDirectory: (dest) ->

    # Determine the build path from file dirname
    if dest.match(/_build/)
      @node.path.resolve(process.cwd(), '_build')
    else
      @node.path.resolve(process.cwd())
