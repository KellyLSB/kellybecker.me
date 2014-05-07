module.exports = class YamlGlobInclude
  @_: null


  @getTemplateName: (file, indexof) ->

    # Get the fully qualified path of the file
    # then split it into an Array.
    file = @_.node.path.resolve(file).split '/'

    # Get the index of the _src value.
    src_index = file.indexOf indexof || '_src'

    # Use the index to get the name of the file being parsed including
    # the subdirectories. The yaml file will have the same directory structure.
    file.slice(src_index + 2, file.length).join('/').replace /\.[\w\d]*$/, ''


  # Get Yaml Config
  @getPageData: (file, basepath) ->

    # Get the template name to locate yaml
    file = @getTemplateName(file, basepath)

    # Ge the final file name and then load the YAML file
    file = @_.node.path.resolve('.', "_src/yaml/#{file}.yaml")

    @reducePageData(@loadFile(file))


  @reducePageData: (data, format) ->

    # If no format provided then just return.
    if !format && ! data.format
      return data

    # Set page format if not already set.
    if ! format then format = data.format

    # Change all the data!
    for key, val of data

      # If the value is an object and provides
      # a forma thten lets map the data down.
      if typeof val is 'object' && val[format]

        # If the format provides another object then
        # go ahead and run that data through the processor as well.
        data[key] = if typeof val[format] is 'object'
          @reducePageData(val[format], format)
        else val[format]

        # Continue through the loop
        continue

      # If the value is an object and does not provide
      # a format then iterate over that data as well.
      if typeof val is 'object'

        # Run the data through!
        data[key] = @reducePageData(val, format)

        # Continue through the loop
        continue

    # Return the new data
    data


  # Parse the yaml document from a file.
  @loadFile: (file) ->
    file = @_.node.path.resolve(file)
    hash = @_.lib.yaml.safeLoad @_.node.fs.readFileSync(file, 'utf8')
    @postIncludes(hash, file)


  # Load a Glob of yaml files
  @loadGlob: (glob, parent) ->
    files = @processGlob(glob, parent)
    @loadFile(file) for file in files


  # Process the glob and return
  # all yaml documents matched.
  @processGlob: (glob, parent) ->

    # If glob is relative to a file
    glob = if parent

      # Get the dirname of the parent
      root = @_.node.path.dirname(parent)

      # Resolve include path
      #console.log path
      @_.node.path.resolve(root, glob)

    # Resolve glob path if not included
    else @_.node.path.resolve(glob)

    # Get the relativity and normalize the path
    glob = @_.node.path.relative(process.cwd(), glob)
    glob = @_.node.path.normalize(glob)

    # Process the path(s) and return
    # a list of all the matching yaml files
    files = @_.lib.glob.sync(glob).filter (file) =>
      file.match(/\.yaml$/) && @_.node.fs.existsSync(file)


  # Process value includes (post-load)
  @postIncludes: (hash, parent) ->

    # Loop through the data
    # to determine the if
    # includes are required
    for key, data of hash

      # Handle recursion
      if typeof data is 'object'
        hash[key] = @postIncludes(data, parent)
        continue

      # If the data is not a string
      # do not match and continue
      if ! typeof data is 'string'
        continue

      # If data does contain an include then include it!
      if match = data.match(/^include\ (.*)$/)
        hash[key] = @loadGlob(match[1], parent)

    # Return Hash
    hash
