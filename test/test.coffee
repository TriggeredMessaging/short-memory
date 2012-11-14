assert = require("should");
ShortMemory = require("../lib-cov/short-memory.js");

describe 'ShortMemory', ->
  defaultCache = null
  testCache = null
  beforeEach (done)->
    defaultCache = new ShortMemory
    testCache = new ShortMemory
      maxAge: 3,
      maxSize: 500,
      maxCount: 10,
      pruneTime: 1,
      deathTime: 2
    done()
  describe '.maxAge', ->
    it 'should be a number', ->
      defaultCache.maxAge.should.be.a 'number'
    it 'should default to 0', ->
      defaultCache.maxAge.should.equal 0
  describe '.maxSize', ->
    it 'should be a number', ->
      defaultCache.maxSize.should.be.a 'number'
    it 'should default to 0', ->
      defaultCache.maxSize.should.equal 0
  
  describe '.maxCount', ->
    it 'should be a number', ->
      defaultCache.maxCount.should.be.a 'number'
    it 'should default to 0', ->
      defaultCache.maxCount.should.equal 0
  
  describe '.pruneTime', ->
    it 'should be a number', ->
      defaultCache.pruneTime.should.be.a 'number'
    it 'should default to 5', ->
      defaultCache.pruneTime.should.equal 5
  
  describe '.deathTime', ->
    it 'should be a number', ->
      defaultCache.deathTime.should.be.a 'number'
    it 'should default to 0', ->
      defaultCache.deathTime.should.equal 0
    it 'should never be more than pruneTime', ->
      (() ->
        testCache = new ShortMemory
          maxAge: 5
          deathTime:10
      ).should.throw()
  
  describe '.debug', ->
    it 'should be a boolean', ->
      defaultCache.debug.should.be.a 'boolean'
    it 'should default to false', ->
      defaultCache.debug.should.be.false
  
  describe '.set(key, value)', ->
    it 'should assume the cache options by default', ->
      expiry = Date.now() + (testCache.maxAge * 1000)
      testCache.set "test", "value"
      entry = testCache.heap["test"]
      entry.expires.should.be.approximately expiry, 5
      entry.deathTime.should.equal testCache.deathTime
    it 'should return the stored value on success', ->
      
  
  describe '.set(key, value, options)', ->
  
  describe '.set(key, value, callback)', ->
  
  describe '.set(key, value, options, callback)', ->
  