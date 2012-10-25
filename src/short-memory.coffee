class ShortMemory
  heap = []
  memorable = require './memorable.js'
  MaxSize: 0
  MaxRecords: 0
  MaxAge: 0
  
  Size: ()->
    clearFuncs = []
    stack = [heap]
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

module.exports = ShortMemory