short-memory
============

Simple node.js in-memory caching library.

Creates basic structures for storing arbitrary data for future use, able to be
limited by entry count, entry age, or cache size.

## Installation

This app is not yet available in NPM. To install it through NPM, use the following:

    $ npm install git://github.com/aejay/short-memory.git

## Simple usage
```js
var ShortMemory = require('short-memory');

var options = {};

var cache = new ShortMemory(options);

// Set and get can be called async or sync by providing or excluding a callback
// function. Sync requests return the result directly to the calling expression;
cache.set("First!", {important: "data"});

// async requests have the result passed to the given function.
cache.get("First!", function(err, result) {
  // Logs: {important: "data"}
  console.log(err || result);
});
```

## Options

ShortMemory can be initialized with several options, which you can use to limit 
the size and alter the behavior of the cache:
_this.maxSize = options.maxSize;
      _this.maxCount = options.maxCount;
      _this.maxAge = options.maxAge;
      _this.debug = options.debug;
      _this.pruneTime = options.pruneTime * 1000;
      _this.deathTime = options.deathTime;
```js
var options = {
  // How long, in seconds, it takes for an entry to expire and become prunable.
  // Defaults to 0, which does not set expirations for entries. This can be
  // over-ridden by the options passed when setting a cache entry.
  maxAge: 60,
  
  // How large the (estimated*) size of the cache can be before pruning old
  // entries. Defaults to 0, which does not set a maximum size.
  maxSize: 5000,
  // * Size estimations are best-guess. This method should be last resort,
  // perhaps used as a fail-safe against enormous data retention.
  
  // How many entries the cache can hold before pruning the oldest entries.
  // Defaults to 0, which allows any number of entries.
  maxCount: 100,
  
  // How often the system checks for and destroys obsolete entries, in
  // seconds. Defaults to 5.
  pruneTime: 5,
  
  
  // When an entry is this many seconds from expiring, the system should
  // return the current value on request and kick off a process to update
  // the value afterwards. This is used by the getOrSet function. This 
  // can be over-ridden by the options passed when setting a cache entry.
  deathTime: 0,
  
  // Writes verbose output to the console for debugging purposes.
  debug: false
  
};
var cache = new ShortMemory(options);
```

## Functions

```js
var cache = new ShortMemory({maxCount: 10});
```

### .set(key, value, [options], [callback])

Sets the key to the given value. When successful, it responds with the
value of the given entry. When unsuccessful, it responsds with the
appropriate error code.

```js
cache.set("name", "Andrew");

cache.set("food", "Pizza", function(err, result) {
  console.log(err || result);
});

cache.set("animal", "Panda", {maxAge: 120, deathTime: 30}, function(err, result) {
  // maxAge and deathTime can be over-ridden on an entry basis
});
```