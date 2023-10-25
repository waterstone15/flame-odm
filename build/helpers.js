(function() {
  var flatPaths, isEmpty, isPlainObject, keys;

  isEmpty = require('lodash/isEmpty');

  isPlainObject = require('lodash/isPlainObject');

  keys = require('lodash/keys');

  flatPaths = function(obj) {
    var o, walk;
    o = {};
    walk = function(_o, path = '') {
      var i, k, len, ref, results;
      ref = keys(_o);
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        k = ref[i];
        if ((isPlainObject(_o[k])) && !(isEmpty(_o[k]))) {
          results.push(walk(_o[k], `${path}${k}.`));
        } else {
          results.push(o[`${path}${k}`] = _o[k]);
        }
      }
      return results;
    };
    walk(obj);
    return o;
  };

  module.exports = {flatPaths};

}).call(this);
