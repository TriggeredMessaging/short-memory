class ShortMemory
  heap: []
  Memorable: require './memorable.js'
  MaxSize: 0
  MaxRecords: 0
  MaxAge: 0
  
  constructor = (options)->
    options?= {}
    options.maxSize?= 0
    options.maxRecords?= 0
    options.maxAge?= 0
    
    @MaxSize = maxSize
    @MaxRecords = maxRecords
    @MaxAge = maxAge
  
  Set: (key, data, options, callback)->
    try 
      memorable = new Memorable key, data, options
      heap.push memorable
    catch ex
      console.error "Unable to set memorable: #{ex}"
  
  # Returns error:empty if there is no valid entry
  Get: (key, callback)->
  
  # Performs elseback to get data if empty
  GetOrElse: (key, options, callback, elseback)->
  
  
  CalculateSize: ->
    size = 0
    for memorable in @heap
      size += memorable.Size
    return size
    

module.exports = ShortMemory