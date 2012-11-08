# Short Memory, a simple node.js in-memory caching library.
# ©2012 Aejay Goehring and available under the MIT license:

# Permission is hereby granted, free of charge, to any person obtaining a copy 
# of this software and associated documentation files (the "Software"), to 
# deal in the Software without restriction, including without limitation the 
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or 
# sell copies of the Software, and to permit persons to whom the Software is 
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in 
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN 
# THE SOFTWARE.

# https://github.com/aejay/short-memory

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
    if typeof options is 'function'
      callback = options
      options = {}
    if typeof callback is 'function'
      _this.debug && console.log "Debug: set has a callback; running async"
      process.nextTick ()->
        value = _this.setInternal key, data, options
        callback value[0], value[1]
      return null
    else
      _this.debug && console.log "Debug: get has no callback; running sync"
      return (_this.setInternal key, data, options)[1]
  
  setInternal: (key, data, options) ->
    try 
      options?= {}
      options.maxAge?= _this.maxAge
      options.deathTime?= _this.deathTime
      memorable = new Memorable key, data, options
      _this.heap[key] = memorable
      _this.debug && console.log "Debug: set heap[" + key + "] to " + data
      return [null, memorable.data]
    catch ex
      console.error "Unable to set memorable: #{ex}"
      return [{type:"exception", message: ex}, null]
  
  get: (key, callback)->
    _this = this
    if typeof callback is 'function'
      _this.debug && console.log "Debug: get has a callback; running async"
      process.nextTick ()->
        value = _this.getInternal key
        callback value[0], value[1]
      return null
    else
      _this.debug && console.log "Debug: get has no callback; running sync"
      return (_this.getInternal key)[1]
  
  getInternal: (key)->
    _this.debug && console.log "Debug: getting key " + key + " from heap"
    value = _this.heap[key]
    if typeof value is 'undefined'
      _this.debug && console.log "Debug: not found"
      return [{type:"notfound", message:"Key " + key + " not found in heap."}, null]
    else
      if not value.isGood
        _this.debug && console.log "Debug: expired or invalid"
        _this.destroy key
        return [{type:"notvalid", message:"Key " + key + " expired or invalid."}, null]
      else
        _this.debug && console.log "Debug: found it!"
        return [null, value.data]
  
  # Performs setback to get data if empty or invalid
  # Ultimately, callback gets called with end data
  getOrSet: (key, setback, options, callback)->
    _this = this
    if typeof options is 'function'
      callback = options
      options = {}
    if typeof callback is 'function'
      _this.debug && console.log "Debug: getOrSet; getting async"
      _this.get key, (err, data)->
        if not err
          _this.debug && console.log "Debug: getOrSet; key exists, calling back"
          callback null, data
          if _this.heap[key].isNearDeath()
            _this.debug && console.log "Debug: getOrSet; key is near death; will set after get"
            if options.async
              process.nextTick ()->
                setback key, (data)->
                  _this.set key, data, options
            else
              process.nextTick ()->
                _this.set key, setback key, options
        else
          _this.debug && console.log "Debug: getOrSet; key invalid, setting back"
          if options.async
            _this.debug && console.log "Debug: getOrSet; setback is async"
            setback key, (data)->
              _this.set key, data, options, callback
          else
            _this.debug && console.log "Debug: getOrSet; setback is sync"
            _this.set key, setback(key), options, callback
    else
      _this.debug && console.log "Debug: getOrSet; getting sync"
      value = _this.getInternal key
      if not value[0]
        if _this.heap[key].isNearDeath()
          _this.debug && console.log "Debug: getOrSet; key is near death; will set after get"
          if options.async
            throw "Cannot call getOrSet async without a callback!"
          process.nextTick ()->
            _this.set key, setback key, options
        return value[1]
      else
        _this.debug && console.log "Debug: getOrSet; no valid key; setting"
        if options.async
          throw "Cannot call getOrSet async without a callback!"
        return _this.setInternal key, setback(), options
    _this.get key, (error, value)->
      if error
        if error.type is "notfound" or error.type is "invalid"
              data = setback()
              return _this.set key, data, options, callback
        callback error
      else
        callback null, value
    
  destroy: (key, callback)->
    if typeof callback is 'function'
      process.nextTick ()->
        _this.debug && console.log "Debug: destroying key sync " + key
        callback delete _this.heap[key]
    else
      _this.debug && console.log "Debug: destroying key sync " + key
      return delete _this.heap[key]
  
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
  
  isHealthy: (key) ->
    entry = _this.heap[key]
    if entry
      return (entry.isGood() and not entry.isNearDeath())
    else
      return false

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
    return Date.now() > (_this.expires - (_this.deathTime * 1000))
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