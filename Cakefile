fs            = require 'fs'
path          = require 'path'
#{extend}      = require './lib/coffee-script/helpers'
CoffeeScript  = require 'coffee-script'
{spawn, exec} = require 'child_process'
children = require 'child_process'

# Built file header.
header = """
  /**
   * short-memory; Copyright 2012 Aejay Goehring. 
   * Licensed under MIT License. 
   * See LICENSE for details. 
   */

"""

headermin = """
  /* short-memory; Copyright 2012 Aejay Goehring. Licensed under MIT License; See LICENSE for details. */

"""

option '-m', '--minify', 'define whether to also minify build or watch'

task 'build', 'build the short-memory library from source', build = (options) ->
  #proc = children.exec (path.normalize "./node_modules/coffee-script/bin/coffee") + " -l -c -o lib/ src/", (err, stdout, stderr) ->
  #  console.info stdout
  #  console.error stderr
  #  if err then console.error 'exec error: ' + err
  #proc = children.spawn "node", [path.normalize("./node_modules/coffee-script/bin/coffee"), '-l', '-c', '-o', 'lib/', 'src/'], (err, stdout, stderr) ->
  #proc.stdout.on  'data', (buffer) -> console.info buffer.toString()
  #proc.stderr.on  'data', (buffer) -> console.error buffer.toString()
  #proc.on         'exit', (status) ->
  #  if status != 0 then process.exit(1)
  for file in (fs.readdirSync 'src')
    output = 'lib/' + file
    contents = fs.readFileSync 'src/' + file, "utf8"
    if file.match(/\.coffee$/)
      console.log "Compiling: " + path.normalize("src/" + file)
      output = 'lib/' + (file.replace /\.coffee$/, ".js")
      contents = header + CoffeeScript.compile contents
    else
      console.log "Copying: " + path.normalize("src/" + file)
    fs.writeFileSync(output, contents, "utf8");
  if options.minify
    files = []
    for file in (fs.readdirSync 'lib')
      if file.match(/\.js$/) and not file.match(/\.min.js$/)
        files.push path.normalize 'lib/' + file
    uglify = require 'uglify-js2'
    for file in files
      console.log "Minifying: " + file
      code = uglify.minify file, {outSourceMap: path.basename file.replace /\.js$/, ".min.map" }
      fs.writeFileSync file.replace(/\.js$/, ".min.js"), headermin + code.code, "utf8"
      fs.writeFileSync file.replace(/\.js$/, ".min.map"), code.map, "utf8"

task 'watch', 'watch the source files for changes, and build', watch = (options) ->
  invoke 'build'
  for file in (fs.readdirSync 'src')
    if file.match(/\.coffee$/)
      fs.watchFile (path.normalize "src/" + file), (curr, prev) ->
        if curr.mtime isnt prev.mtime
          console.log "Saw change in #{file}; rebuilding."
          invoke 'build'
  return true
