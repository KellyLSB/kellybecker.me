Marked     = require('marked')
Highlight  = require('highlight.js')


Marked.setOptions
  renderer: new Marked.Renderer()
  gfm: true
  tables: true
  breaks: false
  pedantic: false
  sanitize: true
  smartLists: true
  smartypants: true
  highlight: (code, lang) =>
    if lang
      Highlight.highlight(lang, code).value
    else
      Highlight.highlightAuto(code).value


module.exports = ->
  String.prototype.repeat = (x, y) ->
    new Array((x * (y || 1)) + 1).join(@)

  String.prototype.anchorname = (ns) ->
    name = if ns then ns + '-' + @ else @
    name.toLowerCase().replace(/[^\w]+/gi, '-')

  String.prototype.anchorlink = (ns) ->
    '#' + @.anchorname(ns)

  String.prototype.markdown = ->
    Marked(@)

  Array.prototype.unique = ->
    cache = {}; for data, index in @
      if cache[data] then continue
      cache[data] = true
      data
