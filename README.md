short-memory
============

Simple node.js in-memory caching library.

Creates basic structures for storing arbitrary data for future use, able to be
limited by entry count, entry age, or cache size.

## Installation

This app is not yet available in npm's repository. To install it through npm, use 
the following:

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
// Let's start with the following assumption:
var ShortMemory = require("short-memory");
var cache = new ShortMemory({maxCount: 10});
```

### .set(key, value [, options] [, callback])

Sets the key to the given value. When successful, it responds with the
value of the given entry's value. This function can be called asynchronously
by providing a callback function, which receives data in the expected
`(err, data)` format.

When called synchronously, the value of the key is returned to the calling 
expression when successful; when unsuccessful, it returns `null`.

```js
cache.set("name", "Andrew");

cache.set("food", "Pizza", function(err, data) {
  if (err) throw err;
  else console.log(data);
});

cache.set("animal", "Panda", {maxAge: 120, deathTime: 30}, function(err, result) {
  // maxAge and deathTime can be over-ridden on an entry basis
});
```

### .get(key [, callback])

Retrieves the value for the given key. This responds just as .set does.If
async, it calls back with `(err, data)`. If sync, it either returns the value
of the key, or `null`.

```js
// "Andrew"
console.log(cache.get("name"));

cache.get("food", function(err, data) {
  if (err) throw err;
  // "Pizza"
  else console.log(data);
});

// "Panda"
cache.get("animal", console.log.bind(console));
```

### .getOrSet(key, setback [, options] [, callback])

This is what you will most likely use, but I thought I'd explain those other
two first.

Retrieves the value of the given key. If the key has expired or does not exist,
it calls setback, which it expects to return the new value. It then updates the
value, and returns the new value.

A callback can be specified to run asynchronously. Additionally, if the `async`
option is set to `true`, the setback will be called with next function that 
wraps the key update and given callback function. See the third example.

Additionally, if the key has a `deathTime` of anything other than 0, cache entries
get treated differently by this function. If an entry is requested that is within
its `deathTime` (given seconds away from its expiration), the function will return
or callback with the current value immediately, and then follow up with an update
after-the-fact. (Instant gratification, deferred update, all goodness.)

```js
// Since "name" exists and is valid, Andrew is returned
var myName = cache.getOrSet(
  "name",
  // If it didn't, it would update and return "Aejay"
  function() {
    return "Aejay";
  }
);

var myFood;
cache.getOrSet(
  "food",
  // If "food" didn't exist, we would use our own LookupFunction to figure out
  // the value, which would then be stored and the callback would set myFood to
  // the new value.
  function(key) {
    return LookupFunction(key);
  },
  // Since "food" exists, though, myFood gets set to "Pizza"
  function(err, data) {
    myFood = data;
  }
);

// Pandas are not practical pets.
var myAnimal;
cache.getOrSet(
  "animal",
  // The "next" function is provided to us when we specify the async option.
  function(key, next) {
    // If we have an async version of our LookupFunction, we can use it here...
    LookupFunctionAsync(key, function(data) {
      // ... and assign its response to the value by calling the given next() function
      next(data);
      // next sets the key to the given value, and then fires the callback parameter.
    });
  },
  {async:true},
  // Ultimately, our callback gets called. Since "animal" does exist, myAnimal
  // gets set to "Panda".
  function(err, data) {
    myAnimal = data;
  }
);
// Seriously, though, kids. Leave the care of endangered species to the professionals!
```

### .destroy(key [, callback])

Does what it sounds like. You can use this function to manually discard an
entry in your cache. Will respond with `true` if it succeeded, or `false` if
the key did not exist or could not (for whatever odd reason) be deleted.

```js
// true
cache.destroy("food");
// null
cache.get("food");

// false (it doesn't exist)
cache.destroy("Planet Pluto");
// still null
cache.get("Planet Pluto");

// Sorry if that destroys your childhood like it did mine.
```

### .isHealthy(key)

This function is only useful if a key has an expiration (`maxAge`) and a
`deathTime`. It can be used to determine if a key is healthy (ie: it is not
expired, and is not within `deathTime` seconds from expiring). If it is not
healthy, the application may choose to manually update the entry, or take
whatever other needed course of action.

```js
// false (We destroyed it, remember? Destruction isn't healthy.)
cache.isHealthy("food");

// true
cache.isHealthy("animal");
```

## Building

If you'd like to compile the coffeescript to javascript yourself, simply use
cake:

```
$ cake
Cakefile defines the following tasks:

cake build                # build the short-memory library from source
cake watch                # watch the source files for changes, and build

  -m, --minify       define whether to also minify build or watch

$ cake build
Compiling: src\short-memory.coffee
```

## Credits

This library was inspired by [memcached](http://memcached.org/) (in spirit, 
but not in source).

Browser compatibility (for those who might need it) is made possible thanks to
[Craig Patik](https://github.com/cpatik)'s 
[console.log wrapper](https://github.com/cpatik/console.log-wrapper), and 
[Andy E](http://stackoverflow.com/users/94197/andy-e)'s 
["safer Object.keys compatibility"](http://whattheheadsaid.com/2010/10/a-safer-object-keys-compatibility-implementation)

## License

&copy;2012 Aejay Goehring and available under the MIT license:

Permission is hereby granted, free of charge, to any person obtaining a copy of 
this software and associated documentation files (the "Software"), to deal in 
the Software without restriction, including without limitation the rights to 
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
of the Software, and to permit persons to whom the Software is furnished to do 
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all 
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN 
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
