(function() {
  var Access, FlameError, every, flatPaths, get, intersection, isArray, isEmpty, isPlainObject, isString, keys, merge, reduce, set, union;

  every = require('lodash/every');

  get = require('lodash/get');

  intersection = require('lodash/intersection');

  isArray = require('lodash/isArray');

  isEmpty = require('lodash/isEmpty');

  isPlainObject = require('lodash/isPlainObject');

  isString = require('lodash/isString');

  keys = require('lodash/keys');

  merge = require('lodash/merge');

  reduce = require('lodash/reduce');

  set = require('lodash/set');

  union = require('lodash/union');

  FlameError = require('./flame-error');

  ({flatPaths} = require('./helpers'));

  Access = (function() {
    class Access {
      constructor(mask) {
        var e, flat, ok;
        flat = flatPaths(mask);
        ok = reduce(keys(flat), (function(r, k) {
          return r && (isArray(flat[k])) && (every(flat[k], isString));
        }), true);
        if (!(isPlainObject(mask)) || !ok) {
          e = "An Access must be initalized with a plain object of role arrays.";
          throw new FlameError(e);
          return;
        }
        this.mask = flat;
        return;
      }

      screen(obj, roles) {
        var e;
        if (!(isPlainObject(obj))) {
          e = "The first argument to Access.mask() must be a plain object.";
          throw new FlameError(e);
          return;
        }
        if (!(isArray(roles)) || !(every(roles, isString))) {
          e = "The second argument to Access.mask() must be an array of roles.";
          throw new FlameError(e);
          return;
        }
        return reduce(keys(this.mask), ((r, k) => {
          if (isEmpty(intersection(roles, this.mask[k]))) {
            return r;
          } else {
            return merge({}, set({}, k, get(obj, k)), r);
          }
        }), {});
      }

      fields(roles) {
        var e;
        if (!(isArray(roles)) || !(every(roles, isString))) {
          e = "The first argument to Access.fields() must be an array of roles.";
          throw new FlameError(e);
          return;
        }
        return reduce(keys(this.mask), ((r, k) => {
          if (isEmpty(intersection(roles, this.mask[k]))) {
            return r;
          } else {
            return union(r, [k]);
          }
        }), []);
      }

    };

    Access.prototype.type = 'Access';

    return Access;

  }).call(this);

  module.exports = Access;

}).call(this);
