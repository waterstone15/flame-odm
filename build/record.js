(function() {
  var Access, Adapter, Config, FlameError, Record, Serializer, Validator, any, compact, each, find, flatPaths, get, isEmpty, isFunction, isPlainObject, isString, keys, matches, random, set, union, uniq;

  any = require('lodash/some');

  compact = require('lodash/compact');

  each = require('lodash/each');

  find = require('lodash/find');

  get = require('lodash/get');

  isEmpty = require('lodash/isEmpty');

  isFunction = require('lodash/isFunction');

  isPlainObject = require('lodash/isPlainObject');

  isString = require('lodash/isString');

  keys = require('lodash/keys');

  matches = require('lodash/matches');

  random = require('@stablelib/random');

  set = require('lodash/set');

  union = require('lodash/union');

  uniq = require('lodash/uniq');

  Access = require('./access');

  Adapter = require('./adapter');

  Config = require('./config');

  FlameError = require('./flame-error');

  Serializer = require('./serializer');

  Validator = require('./validator');

  ({flatPaths} = require('./helpers'));

  Record = (function() {
    class Record {
      constructor(type, id = null, values, ...rs) {
        var cf, e, idf, ref, ref1, ref2, ref3, ref4;
        if (any([!(isString(type)), isEmpty(type), !(isPlainObject(values))])) {
          e = "A Record must be initalized with a type, an id, and a values object as the first three arguments.";
          throw new FlameError(e);
          return;
        }
        this.type = type;
        this.values = values;
        this.access = (ref = find(rs, matches({
          type: 'Access'
        }))) != null ? ref : null;
        this.adapter = (ref1 = find(rs, matches({
          type: 'Adapter'
        }))) != null ? ref1 : new Adapter();
        this.config = (ref2 = find(rs, matches({
          type: 'Config'
        }))) != null ? ref2 : null;
        this.serializer = (ref3 = find(rs, matches({
          type: 'Serializer'
        }))) != null ? ref3 : new Serializer();
        this.validator = (ref4 = find(rs, matches({
          type: 'Validator'
        }))) != null ? ref4 : new Validator();
        this.data = this.obj();
        cf = get(this, 'config.opts.collection_field');
        idf = get(this, 'config.opts.id_field');
        this.collection = cf ? get(this.data, cf) : this.type;
        this.id = id != null ? id : (idf ? get(this.data, idf) : random.randomString(36));
        return;
      }

      obj() {
        var f, o;
        if (!this.data) {
          f = flatPaths(this.values);
          o = {};
          each(keys(f), (k) => {
            var v;
            v = (isFunction(f[k])) ? f[k](this.type, this.values) : f[k];
            return set(o, k, v);
          });
          this.data = o;
        }
        return this.data;
      }

      ok(fields = null) {
        return this.validator.ok(this.data, fields);
      }

      errors(fields = null) {
        return this.validator.errors(this.data, fields);
      }

      async save(transaction = null) {
        return (await (this.adapter.save(this, transaction)));
      }

      async update(fields = [], transaction = null) {
        var fs;
        fs = uniq(union([], fields, compact([get(this, 'config.opts.updated_at_field')])));
        return (await (this.adapter.update(this, fs, transaction)));
      }

    };

    Record.prototype.type = 'Record';

    return Record;

  }).call(this);

  module.exports = Record;

}).call(this);
