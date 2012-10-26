class ShortMemory
  heap: {}
  Memorable: require './memorable.js'
  maxSize: 0
  maxRecords: 0
  maxAge: 0
  pruneTime: 5
  deathTime: 0
  debug: false
  
  constructor: (options)->
    options?= {}
    options.maxSize?= 0
    options.maxRecords?= 0
    options.maxAge?= 0
    options.deathTime?= 0
    options.pruneTime?= 5
    options.debug?= false
    
    @maxSize = options.maxSize
    @maxRecords = options.maxRecords
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
    @get key, (error, value)->
      if error
        if error.type is "notfound" or error.type is "invalid"
          process.nextTick ->
            data = setback()
            return @set key, data, options, callback
        return error
      else
        return value
    
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
        console.log _this
        ShortMemory.prototype.prune.call(_this)
      @pruneTime
      _this
    )
    return pruned
  
  calculateSize: ->
    size = 0
    for i, memorable of @heap
      size += memorable.Size
    return size
    

module.exports = ShortMemory