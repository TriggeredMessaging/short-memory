fs            = require 'fs'
path          = require 'path'
#{extend}      = require './lib/coffee-script/helpers'
CoffeeScript  = require 'coffee-script'
{spawn, exec} = require 'child_process'

# Built file header.
header = """
  /**
   * short-memory Compiler
   */
"""

sources = [
  'coffee-script', 'grammar', 'helpers'
  'lexer', 'nodes', 'rewriter', 'scope'
].map (filename) -> "src/#{filename}.coffee"

# Run a CoffeeScript through our node/coffee interpreter.
run = (args, cb) ->
  proc =         spawn 'node', ['node_modules/coffee-script/bin/coffee'].concat(args)
  proc.stderr.on 'data', (buffer) -> console.log buffer.toString()
  proc.on        'exit', (status) ->
    process.exit(1) if status != 0
    cb() if typeof cb is 'function'

# Log a message with a color.
log = (message, color, explanation) ->
  console.log color + message + reset + ' ' + (explanation or '')

option '-p', '--prefix [DIR]', 'set the installation prefix for `cake install`'

task 'build', 'build the CoffeeScript language from source', build = (cb) ->
  files = []
  compiledFiles = []
  for file in (fs.readdirSync 'src')
    if file.match(/\.coffee$/)
      files.push path.normalize 'src/' + file
      compiledFiles.push path.normalize 'lib/' + (file.replace /\.coffee$/, ".js")
  run ['-c', '-o', 'lib'].concat(files), cb
  uglify = require 'uglify-js2'
  for file in compiledFiles
    code = uglify.minify file, {outSourceMap: path.basename file.replace /\.js$/, ".min.map" }
    fs.writeFileSync file.replace(/\.js$/, ".min.js"), code.code, "utf8"
    fs.writeFileSync file.replace(/\.js$/, ".min.map"), code.map, "utf8"