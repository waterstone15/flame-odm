(function() {
  var FlameError, Validator, each, every, flatPaths, functions, get, isArray, isEmpty, isFunction, isPlainObject, isString, keys;

  each = require('lodash/each');

  every = require('lodash/every');

  functions = require('lodash/functions');

  get = require('lodash/get');

  isArray = require('lodash/isArray');

  isEmpty = require('lodash/isEmpty');

  isFunction = require('lodash/isFunction');

  isPlainObject = require('lodash/isPlainObject');

  isString = require('lodash/isString');

  keys = require('lodash/keys');

  FlameError = require('./flame-error');

  ({flatPaths} = require('./helpers'));

  Validator = (function() {
    class Validator {
      constructor(v) {
        var e, v_ok;
        if (isEmpty(functions(v))) {
          (v = flatPaths(v));
        }
        if (!(isPlainObject(v))) {
          e = "A Validator must be initalized with a 1 (or 2) level plain object of validator functions.";
          throw new FlameError(e);
          return;
        }
        v_ok = every(keys(v), (function(_k) {
          return v[_k].length === 2;
        }));
        if (!v_ok) {
          e = "Each Validator function must have an arity of 2. The first parameter is the value being checked and the second parameter is the object being validated.";
          throw new FlameError(e);
          return;
        }
        this.v = v;
        return;
      }

      errors(obj, fields) {
        var e, errs;
        if (fields == null) {
          fields = keys(this.v);
        }
        if (!(isPlainObject(obj))) {
          e = "The first argument to Validator.ok(obj, fields) should be a 1 (or 2) level plain object.";
          throw new FlameError(e);
          return;
        }
        if (!(isArray(fields)) || !(every(fields, isString))) {
          e = "The optional second argument to Validator.ok(obj, fields) should be an array of strings.";
          throw new FlameError(e);
          return;
        }
        errs = {};
        each(fields, ((_k) => {
          if (!(isFunction(this.v[_k]))) {
            e = `You cannot enumerate the errors of a field that has no validator function.\n Field: ${_k}`;
            throw new FlameError(e);
            return;
          }
          if (!(this.v[_k](get(obj, _k)))) {
            (errs[_k] = true);
          }
        }));
        return errs;
      }

      ok(obj, fields) {
        var e;
        if (fields == null) {
          fields = keys(this.v);
        }
        if (!(isPlainObject(obj))) {
          e = "The first argument to Validator.ok(obj, fields) should be a 1 (or 2) level plain object.";
          throw new FlameError(e);
          return;
        }
        if (!(isArray(fields)) || !(every(fields, isString))) {
          e = "The optional second argument to Validator.ok(obj, fields) should be an array of strings.";
          throw new FlameError(e);
          return;
        }
        return every(fields, ((_k) => {
          if (!(isFunction(this.v[_k]))) {
            e = `You cannot validate a field that has no validator function.\n Field: ${_k}`;
            throw new FlameError(e);
            return;
          }
          return this.v[_k](get(obj, _k));
        }));
      }

    };

    Validator.prototype.type = 'Validator';

    return Validator;

  }).call(this);

  module.exports = Validator;

}).call(this);
