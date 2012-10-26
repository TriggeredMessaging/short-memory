class Memorable
  key: ""
  data: {}
  time: new Date()
  invalid: false
  size: 0
  expires: 0
  deathTime: 0
  constructor: (key, data, options) ->
    if typeof key is 'undefined' then throw "Memorable missing key element"
    if typeof data is 'undefined' then throw "Memorable missing data element"
    options?= {}
    options.maxAge?= 0
    options.nearDeath?= 0
    @key = key
    @data = data
    if maxAge isnt 0
      @Expires = @Time.now + (maxAge * 1000)
    @nearDeath = options.nearDeath
    @size = @calculateSize()
  isGood: ->
    return not @invalid or @expires is 0 or @time.now < @expires
  isNearDeath: ->
    return @time.now > (@expires - (DeathTime * 1000))
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

module.exports = Memorable