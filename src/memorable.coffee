class Memorable
  Key: ""
  Data: {}
  Time: new Date()
  Invalid: false
  Expires: 0
  constructor: (key, data, options) ->
    if typeof key is 'undefined' then throw "Memorable missing key element"
    if typeof data is 'undefined' then throw "Memorable missing data element"
    options?= {}
    options.maxAge?= 0
    @Key = key
    @Data = data
    if maxAge isnt 0
      @Expires = @Time.now + (maxAge * 1000)
  IsExpired: ->
    return @Expires is 0 or @Time.now < @Expires
  Invalidate ->
    @Invalid = true

module.exports = Memorable