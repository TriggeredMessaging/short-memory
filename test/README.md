Test Results:
```

  ShortMemory
    .maxAge
      ◦ should be a number: [2K[0G      ✔ should be a number 
      ◦ should default to 0: [2K[0G      ✔ should default to 0 
    .maxSize
      ◦ should be a number: [2K[0G      ✔ should be a number 
      ◦ should default to 0: [2K[0G      ✔ should default to 0 
    .maxCount
      ◦ should be a number: [2K[0G      ✔ should be a number 
      ◦ should default to 0: [2K[0G      ✔ should default to 0 
    .pruneTime
      ◦ should be a number: [2K[0G      ✔ should be a number 
      ◦ should default to 5: [2K[0G      ✔ should default to 5 
    .deathTime
      ◦ should be a number: [2K[0G      ✔ should be a number 
      ◦ should default to 0: [2K[0G      ✔ should default to 0 
      ◦ should never be more than pruneTime: [2K[0G      ✔ should never be more than pruneTime 
    .debug
      ◦ should be a boolean: [2K[0G      ✔ should be a boolean 
      ◦ should default to false: [2K[0G      ✔ should default to false 
    .set(key, value)
      ◦ should assume the cache options by default: [2K[0G      ✔ should assume the cache options by default 
      ◦ should return the stored value on success: [2K[0G      ✔ should return the stored value on success 


  ✔ 15 tests complete (96 ms)


```

Test Definitions:

# TOC
   - [ShortMemory](#shortmemory)
     - [.maxAge](#shortmemory-maxage)
     - [.maxSize](#shortmemory-maxsize)
     - [.maxCount](#shortmemory-maxcount)
     - [.pruneTime](#shortmemory-prunetime)
     - [.deathTime](#shortmemory-deathtime)
     - [.debug](#shortmemory-debug)
     - [.set(key, value)](#shortmemory-setkey-value)
     - [.set(key, value, options)](#shortmemory-setkey-value-options)
     - [.set(key, value, callback)](#shortmemory-setkey-value-callback)
     - [.set(key, value, options, callback)](#shortmemory-setkey-value-options-callback)
<a name=""></a>
 
<a name="shortmemory"></a>
# ShortMemory
<a name="shortmemory-maxage"></a>
## .maxAge
should be a number.

```js
return defaultCache.maxAge.should.be.a('number');
```

should default to 0.

```js
return defaultCache.maxAge.should.equal(0);
```

<a name="shortmemory-maxsize"></a>
## .maxSize
should be a number.

```js
return defaultCache.maxSize.should.be.a('number');
```

should default to 0.

```js
return defaultCache.maxSize.should.equal(0);
```

<a name="shortmemory-maxcount"></a>
## .maxCount
should be a number.

```js
return defaultCache.maxCount.should.be.a('number');
```

should default to 0.

```js
return defaultCache.maxCount.should.equal(0);
```

<a name="shortmemory-prunetime"></a>
## .pruneTime
should be a number.

```js
return defaultCache.pruneTime.should.be.a('number');
```

should default to 5.

```js
return defaultCache.pruneTime.should.equal(5);
```

<a name="shortmemory-deathtime"></a>
## .deathTime
should be a number.

```js
return defaultCache.deathTime.should.be.a('number');
```

should default to 0.

```js
return defaultCache.deathTime.should.equal(0);
```

should never be more than pruneTime.

```js
return (function() {
  return testCache = new ShortMemory({
    maxAge: 5,
    deathTime: 10
  });
}).should["throw"]();
```

<a name="shortmemory-debug"></a>
## .debug
should be a boolean.

```js
return defaultCache.debug.should.be.a('boolean');
```

should default to false.

```js
return defaultCache.debug.should.be["false"];
```

<a name="shortmemory-setkey-value"></a>
## .set(key, value)
should assume the cache options by default.

```js
var entry, expiry;
expiry = Date.now() + (testCache.maxAge * 1000);
testCache.set("test", "value");
entry = testCache.heap["test"];
entry.expires.should.be.approximately(expiry, 5);
return entry.deathTime.should.equal(testCache.deathTime);
```

should return the stored value on success.

```js
}
```


