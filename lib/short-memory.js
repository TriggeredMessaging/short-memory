/**
 * short-memory; Copyright 2012 Aejay Goehring. 
 * Licensed under MIT License. 
 * See LICENSE for details. 
 */
(function() {
  var Memorable, ShortMemory, isNode, root, window, _ref;

  if (Function.prototype.bind && (typeof console === "object" || typeof console === "function") && typeof console.log === "object") {
    ["log", "info", "warn", "error", "assert", "dir", "clear", "profile", "profileEnd"].forEach((function(method) {
      return console[method] = this.call(console[method], console);
    }), Function.prototype.bind);
  }

  window = window || global;

  if (!window.log) {
    window;

    window.log = function() {
      var args, script;
      log.history = log.history || [];
      log.history.push(arguments_);
      if (typeof console !== "undefined" && typeof console.log === "function") {
        if ((Array.prototype.slice.call(arguments_)).length === 1 && typeof Array.prototype.slice.call(arguments_)[0] === "string") {
          return console.log((Array.prototype.slice.call(arguments_)).toString());
        } else {
          return console.log(Array.prototype.slice.call(arguments_));
        }
      } else if (!Function.prototype.bind && typeof console !== "undefined" && typeof console.log === "object") {
        return Function.prototype.call.call(console.log, console, Array.prototype.slice.call(arguments_));
      } else {
        args = arguments_;
        if (!document.getElementById("firebug-lite")) {
          script = document.createElement("script");
          script.type = "text/javascript";
          script.id = "firebug-lite";
          script.src = "https://getfirebug.com/firebug-lite.js";
          document.getElementsByTagName("HEAD")[0].appendChild(script);
          return setTimeout((function() {
            return window.log.apply(window, args);
          }), 2000);
        } else {
          return setTimeout((function() {
            return window.log.apply(window, args);
          }), 500);
        }
      }
    };
  }

  Object.keys = Object.keys || (function() {
    var DontEnums, DontEnumsLength, hasDontEnumBug, hasOwnProperty;
    hasOwnProperty = Object.prototype.hasOwnProperty;
    hasDontEnumBug = !{
      toString: null
    }.propertyIsEnumerable("toString");
    DontEnums = ['toString', 'toLocaleString', 'valueOf', 'hasOwnProperty', 'isPrototypeOf', 'propertyIsEnumerable', 'constructor'];
    DontEnumsLength = DontEnums.length;
    return function(o) {
      var DontEnum, key, obj, result, _i, _len;
      if (typeof o !== "object" && typeof o !== "function" || o === null) {
        throw new TypeError("Object.keys called on a non-object");
      }
      result = [];
      for (key in o) {
        obj = o[key];
        if (hasOwnProperty.call(o, key)) {
          result.push(key);
        }
      }
      if (hasDontEnumBug) {
        for (_i = 0, _len = DontEnums.length; _i < _len; _i++) {
          DontEnum = DontEnums[_i];
          if (hasOwnProperty.call(o, DontEnum)) {
            result.push(DontEnum);
          }
        }
      }
      return result;
    };
  })();

  if ((_ref = this.process) == null) {
    this.process = {};
  }

  if (!this.process.nextTick) {
    this.process.nextTick = function(task) {
      return setTimeout(task, 0);
    };
  }

  ShortMemory = (function() {
    var _this;

    ShortMemory.prototype.heap = {};

    ShortMemory.prototype.maxSize = 0;

    ShortMemory.prototype.maxCount = 0;

    ShortMemory.prototype.maxAge = 0;

    ShortMemory.prototype.pruneTime = 5;

    ShortMemory.prototype.deathTime = 0;

    ShortMemory.prototype.debug = false;

    _this = ShortMemory;

    function ShortMemory(options) {
      var _ref1, _ref2, _ref3, _ref4, _ref5, _ref6;
      _this = this;
      if (options == null) {
        options = {};
      }
      if ((_ref1 = options.maxSize) == null) {
        options.maxSize = 0;
      }
      if ((_ref2 = options.maxCount) == null) {
        options.maxCount = 0;
      }
      if ((_ref3 = options.maxAge) == null) {
        options.maxAge = 0;
      }
      if ((_ref4 = options.deathTime) == null) {
        options.deathTime = 0;
      }
      if ((_ref5 = options.pruneTime) == null) {
        options.pruneTime = 5;
      }
      if ((_ref6 = options.debug) == null) {
        options.debug = false;
      }
      _this.maxSize = options.maxSize;
      _this.maxCount = options.maxCount;
      _this.maxAge = options.maxAge;
      _this.debug = options.debug;
      _this.pruneTime = options.pruneTime * 1000;
      _this.deathTime = options.deathTime;
      (function(_this) {
        return ShortMemory.prototype.prune.call(_this);
      })(_this);
    }

    ShortMemory.prototype.set = function(key, data, options, callback) {
      if (typeof options === 'function') {
        callback = options;
        options = {};
      }
      if (typeof callback === 'function') {
        _this.debug && console.log("Debug: set has a callback; running async");
        process.nextTick(function() {
          var value;
          value = _this.setInternal(key, data, options);
          return callback(value[0], value[1]);
        });
        return null;
      } else {
        _this.debug && console.log("Debug: get has no callback; running sync");
        return (_this.setInternal(key, data, options))[1];
      }
    };

    ShortMemory.prototype.setInternal = function(key, data, options) {
      var memorable, _ref1, _ref2;
      try {
        if (options == null) {
          options = {};
        }
        if ((_ref1 = options.maxAge) == null) {
          options.maxAge = _this.maxAge;
        }
        if ((_ref2 = options.deathTime) == null) {
          options.deathTime = _this.deathTime;
        }
        memorable = new Memorable(key, data, options);
        _this.heap[key] = memorable;
        _this.debug && console.log("Debug: set heap[" + key + "] to " + data);
        return [null, memorable.data];
      } catch (ex) {
        console.error("Unable to set memorable: " + ex);
        return [
          {
            type: "exception",
            message: ex
          }, null
        ];
      }
    };

    ShortMemory.prototype.get = function(key, callback) {
      _this = this;
      if (typeof callback === 'function') {
        _this.debug && console.log("Debug: get has a callback; running async");
        process.nextTick(function() {
          var value;
          value = _this.getInternal(key);
          return callback(value[0], value[1]);
        });
        return null;
      } else {
        _this.debug && console.log("Debug: get has no callback; running sync");
        return (_this.getInternal(key))[1];
      }
    };

    ShortMemory.prototype.getInternal = function(key) {
      var value;
      _this.debug && console.log("Debug: getting key " + key + " from heap");
      value = _this.heap[key];
      if (typeof value === 'undefined') {
        _this.debug && console.log("Debug: not found");
        return [
          {
            type: "notfound",
            message: "Key " + key + " not found in heap."
          }, null
        ];
      } else {
        if (!value.isGood) {
          _this.debug && console.log("Debug: expired or invalid");
          _this.destroy(key);
          return [
            {
              type: "notvalid",
              message: "Key " + key + " expired or invalid."
            }, null
          ];
        } else {
          _this.debug && console.log("Debug: found it!");
          return [null, value.data];
        }
      }
    };

    ShortMemory.prototype.getOrSet = function(key, setback, options, callback) {
      var value;
      _this = this;
      if (typeof options === 'function') {
        callback = options;
        options = {};
      }
      if (typeof callback === 'function') {
        _this.debug && console.log("Debug: getOrSet; getting async");
        _this.get(key, function(err, data) {
          if (!err) {
            _this.debug && console.log("Debug: getOrSet; key exists, calling back");
            callback(null, data);
            if (_this.heap[key].isNearDeath()) {
              _this.debug && console.log("Debug: getOrSet; key is near death; will set after get");
              if (options.async) {
                return process.nextTick(function() {
                  return setback(key, function(data) {
                    return _this.set(key, data, options);
                  });
                });
              } else {
                return process.nextTick(function() {
                  return _this.set(key, setback(key, options));
                });
              }
            }
          } else {
            _this.debug && console.log("Debug: getOrSet; key invalid, setting back");
            if (options.async) {
              _this.debug && console.log("Debug: getOrSet; setback is async");
              return setback(key, function(data) {
                return _this.set(key, data, options, callback);
              });
            } else {
              _this.debug && console.log("Debug: getOrSet; setback is sync");
              return _this.set(key, setback(key), options, callback);
            }
          }
        });
      } else {
        _this.debug && console.log("Debug: getOrSet; getting sync");
        value = _this.getInternal(key);
        if (!value[0]) {
          if (_this.heap[key].isNearDeath()) {
            _this.debug && console.log("Debug: getOrSet; key is near death; will set after get");
            if (options.async) {
              throw "Cannot call getOrSet async without a callback!";
            }
            process.nextTick(function() {
              return _this.set(key, setback(key, options));
            });
          }
          return value[1];
        } else {
          _this.debug && console.log("Debug: getOrSet; no valid key; setting");
          if (options.async) {
            throw "Cannot call getOrSet async without a callback!";
          }
          return _this.setInternal(key, setback(), options);
        }
      }
      return _this.get(key, function(error, value) {
        var data;
        if (error) {
          if (error.type === "notfound" || error.type === "invalid") {
            data = setback();
            return _this.set(key, data, options, callback);
          }
          return callback(error);
        } else {
          return callback(null, value);
        }
      });
    };

    ShortMemory.prototype.destroy = function(key, callback) {
      if (typeof callback === 'function') {
        return process.nextTick(function() {
          _this.debug && console.log("Debug: destroying key sync " + key);
          return callback(delete _this.heap[key]);
        });
      } else {
        _this.debug && console.log("Debug: destroying key sync " + key);
        return delete _this.heap[key];
      }
    };

    ShortMemory.prototype.prune = function() {
      var count, key, memorable, overCount, overSize, prunable, pruned, size, _i, _j, _k, _len, _len1, _len2, _ref1, _ref2;
      clearTimeout(_this.timer);
      prunable = [];
      pruned = 0;
      _ref1 = _this.heap;
      for (key in _ref1) {
        memorable = _ref1[key];
        if (!memorable.isGood()) {
          prunable.push(key);
        }
      }
      for (_i = 0, _len = prunable.length; _i < _len; _i++) {
        key = prunable[_i];
        pruned++;
        _this.destroy(key);
      }
      if (_this.maxCount !== 0) {
        count = Object.keys(_this.heap).length;
        if (count > _this.maxCount) {
          overCount = count - _this.maxCount;
          prunable = Object.keys(_this.heap).slice(0, overCount);
          for (_j = 0, _len1 = prunable.length; _j < _len1; _j++) {
            key = prunable[_j];
            pruned++;
            _this.destroy(key);
          }
        }
      }
      if (_this.maxSize !== 0) {
        size = _this.calculateSize();
        if (size > _this.maxSize) {
          overSize = size - _this.maxSize;
          prunable = [];
          _ref2 = _this.heap;
          for (key in _ref2) {
            memorable = _ref2[key];
            prunable.push(key);
            overSize -= memorable.size;
            if (overSize <= 0) {
              break;
            }
          }
          for (_k = 0, _len2 = prunable.length; _k < _len2; _k++) {
            key = prunable[_k];
            pruned++;
            _this.destroy(key);
          }
        }
      }
      _this.timer = setTimeout(function() {
        return ShortMemory.prototype.prune.call(_this);
      }, _this.pruneTime);
      return pruned;
    };

    ShortMemory.prototype.calculateSize = function() {
      var i, memorable, size, _ref1;
      size = 0;
      _ref1 = _this.heap;
      for (i in _ref1) {
        memorable = _ref1[i];
        size += memorable.size;
      }
      return size;
    };

    ShortMemory.prototype.isHealthy = function(key) {
      var entry;
      entry = _this.heap[key];
      if (entry) {
        return entry.isGood() && !entry.isNearDeath();
      } else {
        return false;
      }
    };

    return ShortMemory;

  })();

  Memorable = (function() {
    var _this;

    Memorable.prototype.key = "";

    Memorable.prototype.data = {};

    Memorable.prototype.invalid = false;

    Memorable.prototype.size = 0;

    Memorable.prototype.expires = 0;

    Memorable.prototype.deathTime = 0;

    _this = Memorable;

    function Memorable(key, data, options) {
      var _ref1, _ref2;
      _this = this;
      if (typeof key === 'undefined') {
        throw "Memorable missing key element";
      }
      if (typeof data === 'undefined') {
        throw "Memorable missing data element";
      }
      if (options == null) {
        options = {};
      }
      if ((_ref1 = options.maxAge) == null) {
        options.maxAge = 0;
      }
      if ((_ref2 = options.deathTime) == null) {
        options.deathTime = 0;
      }
      _this.key = key;
      _this.data = data;
      if (options.maxAge !== 0) {
        _this.expires = Date.now() + (options.maxAge * 1000);
      }
      _this.deathTime = options.deathTime;
      _this.size = _this.calculateSize();
    }

    Memorable.prototype.isGood = function() {
      return !_this.invalid && (_this.expires === 0 || Date.now() < _this.expires);
    };

    Memorable.prototype.isNearDeath = function() {
      return Date.now() > (_this.expires - (_this.deathTime * 1000));
    };

    Memorable.prototype.invalidate = function() {
      return _this.invalid = true;
    };

    Memorable.prototype.calculateSize = function() {
      var bytes, check, clearFuncs, func, isChecked, stack, uncheck, value;
      clearFuncs = [];
      stack = [_this.data];
      bytes = 0;
      func = null;
      isChecked = function(item) {
        return item["__c"] || false;
      };
      check = function(item) {
        return item["__c"] = true;
      };
      uncheck = function(item) {
        return delete item["__c"];
      };
      while (stack.length) {
        value = stack.pop();
        (function(value) {
          var i, val;
          if (typeof value === 'string') {
            return bytes += value.length * 2;
          } else if (typeof value === 'boolean') {
            return bytes += 4;
          } else if (typeof value === 'number') {
            return bytes += 8;
          } else if (typeof value === 'object' && !isChecked(value)) {
            clearFuncs.push(function() {
              return uncheck(value);
            });
            for (i in value) {
              val = value[i];
              if (value.hasOwnProperty(i)) {
                stack.push(val);
              }
            }
            return check(value);
          }
        })(value);
      }
      while (func = clearFuncs.pop()) {
        func.call();
      }
      return bytes;
    };

    return Memorable;

  })();

  root = this;

  isNode = false;

  if (typeof module !== 'undefined' && module.exports) {
    module.exports = ShortMemory;
  }

  root.ShortMemory = ShortMemory;

  root.Memorable = Memorable;

}).call(this);
