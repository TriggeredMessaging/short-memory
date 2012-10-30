
# This console.log wrapper is the work of Craig Patik, coffeefied.
# (Will split into separate, concat file later)

# Credits:

# Copyright (c) 2012 Craig Patik

# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to
# the following conditions:

# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Tell IE9 to use its built-in console
if Function::bind and (typeof console is "object" or typeof console is "function") and typeof console.log is "object"
  ["log", "info", "warn", "error", "assert", "dir", "clear", "profile", "profileEnd"].forEach ((method) ->
    console[method] = @call(console[method], console)
  ), Function::bind

# log() -- The complete, cross-browser (we don't judge!) console.log wrapper for his or her logging pleasure
window = window || global

unless window.log
  window
  window.log = ->
    log.history = log.history or [] # store logs to an array for reference
    log.history.push arguments_
    
    # Modern browsers
    if typeof console isnt "undefined" and typeof console.log is "function"
      
      # Single argument, which is a string
      if (Array::slice.call(arguments_)).length is 1 and typeof Array::slice.call(arguments_)[0] is "string"
        console.log (Array::slice.call(arguments_)).toString()
      else
        console.log Array::slice.call(arguments_)
    
    # IE8
    else if not Function::bind and typeof console isnt "undefined" and typeof console.log is "object"
      Function::call.call console.log, console, Array::slice.call(arguments_)
    
    # IE7 and lower, and other old browsers
    else
      args = arguments_
      
      # Inject Firebug lite
      unless document.getElementById("firebug-lite")
        
        # Include the script
        script = document.createElement("script")
        script.type = "text/javascript"
        script.id = "firebug-lite"
        
        # If you run the script locally, point to /path/to/firebug-lite/build/firebug-lite.js
        script.src = "https://getfirebug.com/firebug-lite.js"
        
        # If you want to expand the console window by default, uncomment this line
        #document.getElementsByTagName('HTML')[0].setAttribute('debug','true');
        document.getElementsByTagName("HEAD")[0].appendChild script
        setTimeout (->
          window.log.apply window, args
        ), 2000
      else
        
        # FBL was included but it hasn't finished loading yet, so try again momentarily
        setTimeout (->
          window.log.apply window, args
        ), 500
        
# The following cross-browser keys fix is thanks to [Andy E](http://stackoverflow.com/users/94197/andy-e)

Object.keys = Object.keys or do->
  hasOwnProperty = Object.prototype.hasOwnProperty
  hasDontEnumBug = !{toString:null}.propertyIsEnumerable("toString")
  DontEnums = [
    'toString',
    'toLocaleString'
    'valueOf'
    'hasOwnProperty'
    'isPrototypeOf'
    'propertyIsEnumerable'
    'constructor'
  ]
  DontEnumsLength = DontEnums.length
  return (o)->
    if typeof o isnt "object" and typeof o isnt "function" or o is null
      throw new TypeError "Object.keys called on a non-object"
    result = []
    for key, obj of o
      if hasOwnProperty.call o, key
        result.push key
    if hasDontEnumBug
      for DontEnum in DontEnums
        if hasOwnProperty.call o, DontEnum
          result.push DontEnum
    return result

this.process?= {}

if not this.process.nextTick
  this.process.nextTick = (task)->
    setTimeout task, 0

class ShortMemory
  heap: {}
  maxSize: 0
  maxCount: 0
  maxAge: 0
  pruneTime: 5
  deathTime: 0
  debug: false
  _this = this
  
  constructor: (options)->
    _this = this
    options?= {}
    options.maxSize?= 0
    options.maxCount?= 0
    options.maxAge?= 0
    options.deathTime?= 0
    options.pruneTime?= 5
    options.debug?= false
    
    _this.maxSize = options.maxSize
    _this.maxCount = options.maxCount
    _this.maxAge = options.maxAge
    _this.debug = options.debug
    _this.pruneTime = options.pruneTime * 1000
    _this.deathTime = options.deathTime
    
    do (_this) ->
      ShortMemory.prototype.prune.call(_this)
    
  
  set: (key, data, options, callback)->
    #try 
      options?= {}
      options.maxAge?= _this.maxAge
      options.deathTime?= _this.deathTime
      memorable = new Memorable key, data, options
      _this.heap[key] = memorable
      callback null, memorable.data
    #catch ex
    #  console.error "Unable to set memorable: #{ex}"
    #  callback ex
  
  # Returns error:notfound if there is no valid entry
  get: (key, callback)->
    _this = this
    if typeof callback is 'function'
      process.nextTick ->
        value = _this.heap[key]
        if typeof value is 'undefined'
          return callback
            type: "notfound"
            message: "Key #{key} not found in heap."
        else
          if not value.isGood
            _this.destroy key
            return callback
              type: "invalid"
              message: "Key #{key} is invalid or expired."
          else
            return callback null, value.data
    else
      value = _this.heap[key]
      if typeof value is 'undefined'
        return null
      else
        if not value.isGood
          _this.destroy key
          return null
        else
          return value.data
      
  
  # Performs setback to get data if empty or invalid
  # Ultimately, callback gets called with end data
  getOrSet: (key, options, callback, setback)->
    _this = this
    _this.get key, (error, value)->
      if error
        if error.type is "notfound" or error.type is "invalid"
              data = setback()
              return _this.set key, data, options, callback
        callback error
      else
        callback null, value
    
  destroy: (key)->
    _this.debug && console.log "Destroying key " + key
    delete _this.heap[key]
  
  prune: ->
    clearTimeout _this.timer
    prunable = []
    pruned = 0
    # Destroy invalid/expired keys first
    for key, memorable of _this.heap
      if not memorable.isGood()
        prunable.push key
    for key in prunable
      pruned++
      _this.destroy key
    # Destroy overcount
    if _this.maxCount isnt 0
      count = Object.keys(_this.heap).length
      if count > _this.maxCount
        overCount = count - _this.maxCount
        prunable = Object.keys(_this.heap).slice(0, overCount)
        for key in prunable
          pruned++
          _this.destroy key
    # Destroy oversize
    if _this.maxSize isnt 0
      size = _this.calculateSize()
      if size > _this.maxSize
        overSize = size - _this.maxSize
        prunable = []
        for key, memorable of _this.heap
          prunable.push key
          overSize -= memorable.size
          if overSize <= 0 then break
        for key in prunable
          pruned++
          _this.destroy key
    _this.timer = setTimeout(
      () ->
        ShortMemory.prototype.prune.call(_this)
      _this.pruneTime
    )
    return pruned
  
  calculateSize: ->
    size = 0
    for i, memorable of _this.heap
      size += memorable.size
    return size

class Memorable
  key: ""
  data: {}
  invalid: false
  size: 0
  expires: 0
  deathTime: 0
  _this = this
  constructor: (key, data, options) ->
    _this = this
    if typeof key is 'undefined' then throw "Memorable missing key element"
    if typeof data is 'undefined' then throw "Memorable missing data element"
    options?= {}
    options.maxAge?= 0
    options.deathTime?= 0
    _this.key = key
    _this.data = data
    if options.maxAge isnt 0
      _this.expires = Date.now() + (options.maxAge * 1000)
    _this.deathTime = options.deathTime
    _this.size = _this.calculateSize()
  isGood: ->
    return not _this.invalid and (_this.expires is 0 or Date.now() < _this.expires)
  isNearDeath: ->
    return Date.now() > (_this.expires - (DeathTime * 1000))
  invalidate: ->
    _this.invalid = true
  calculateSize: ->
    clearFuncs = []
    stack = [_this.data]
    bytes = 0
    func = null
    isChecked = (item)->
      item["__c"] || false;
    check = (item)->
      item["__c"] = true;
    uncheck = (item)->
      delete item["__c"]
    while(stack.length)
      value = stack.pop()
      do(value)->
        if typeof value is 'string'
          bytes += value.length * 2
        else if typeof value is 'boolean'
          bytes += 4
        else if typeof value is 'number'
          bytes += 8
        else if typeof value is 'object' and not isChecked value
          clearFuncs.push ->
            uncheck value
          for i,val of value
            if value.hasOwnProperty i
              stack.push val
          check value
    while func = clearFuncs.pop()
      func.call()
    return bytes

root = this
isNode = false
if typeof module isnt 'undefined' and module.exports
  module.exports = ShortMemory
root.ShortMemory = ShortMemory
root.Memorable = Memorable