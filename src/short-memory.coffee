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

class ShortMemory
  heap: {}
  Memorable: Memorable
  maxSize: 0
  maxCount: 0
  maxAge: 0
  pruneTime: 5
  deathTime: 0
  debug: false
  
  constructor: (options)->
    options?= {}
    options.maxSize?= 0
    options.maxCount?= 0
    options.maxAge?= 0
    options.deathTime?= 0
    options.pruneTime?= 5
    options.debug?= false
    
    @maxSize = options.maxSize
    @maxCount = options.maxCount
    @maxAge = options.maxAge
    @debug = options.debug
    @pruneTime = options.pruneTime * 1000
    @deathTime = options.deathTime
    
    _this = this
    do (_this) ->
      ShortMemory.prototype.prune.call(_this)
    
  
  set: (key, data, options, callback)->
    #try 
      options?= {}
      options.maxAge?= @maxAge
      options.deathTime?= @deathTime
      memorable = new @Memorable key, data, options
      @heap[key] = memorable
      callback null, memorable.data
    #catch ex
    #  console.error "Unable to set memorable: #{ex}"
    #  callback ex
  
  # Returns error:notfound if there is no valid entry
  get: (key, callback)->
    _this = @
    process.nextTick ->
      value = _this.heap[key]
      if typeof value is 'undefined'
        callback
          type: "notfound"
          message: "Key #{key} not found in heap."
      else
        if not value.isGood
          @destroy key
          callback
            type: "invalid"
            message: "Key #{key} is invalid or expired."
        else
          callback null, value.data
  
  # Performs setback to get data if empty or invalid
  # Ultimately, callback gets called with end data
  getOrSet: (key, options, callback, setback)->
    _this = @
    @get key, (error, value)->
      if error
        if error.type is "notfound" or error.type is "invalid"
              data = setback()
              return _this.set key, data, options, callback
        callback error
      else
        callback null, value
    
  destroy: (key)->
    @debug && console.log "Destroying key " + key
    delete @heap[key]
  
  prune: ->
    clearTimeout @timer
    prunable = []
    pruned = 0
    # Destroy invalid/expired keys first
    for key, memorable of @heap
      if not memorable.isGood()
        prunable.push key
    for key in prunable
      pruned++
      @destroy key
    # Destroy overcount
    if @maxCount isnt 0
      count = Object.keys(@heap).length
      if count > @maxCount
        overCount = count - @maxCount
        prunable = Object.keys(@heap).slice(0, overCount)
        for key in prunable
          pruned++
          @destroy key
    # Destroy oversize
    if @maxSize isnt 0
      size = @calculateSize()
      if size > @maxSize
        overSize = size - @maxSize
        prunable = []
        for key, memorable of @heap
          prunable.push key
          overSize -= memorable.size
          if overSize <= 0 then break
        for key in prunable
          pruned++
          @destroy key
    _this = this
    @timer = setTimeout(
      (_this) ->
        ShortMemory.prototype.prune.call(_this)
      @pruneTime
      _this
    )
    return pruned
  
  calculateSize: ->
    size = 0
    for i, memorable of @heap
      size += memorable.size
    return size

class Memorable
  key: ""
  data: {}
  invalid: false
  size: 0
  expires: 0
  deathTime: 0
  constructor: (key, data, options) ->
    if typeof key is 'undefined' then throw "Memorable missing key element"
    if typeof data is 'undefined' then throw "Memorable missing data element"
    options?= {}
    options.maxAge?= 0
    options.deathTime?= 0
    @key = key
    @data = data
    if options.maxAge isnt 0
      @expires = Date.now() + (options.maxAge * 1000)
    @deathTime = options.deathTime
    @size = @calculateSize()
  isGood: ->
    return not @invalid and (@expires is 0 or Date.now() < @expires)
  isNearDeath: ->
    return Date.now() > (@expires - (DeathTime * 1000))
  invalidate: ->
    @invalid = true
  calculateSize: ->
    clearFuncs = []
    stack = [@data]
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