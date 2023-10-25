(function() {
  var Access, Adapter, FlameError, Model, Record, Serializer, Validator, any, each, find, flatPaths, get, isEmpty, isFunction, isPlainObject, isString, keys, matches, merge, set;

  any = require('lodash/some');

  each = require('lodash/each');

  find = require('lodash/find');

  get = require('lodash/get');

  isEmpty = require('lodash/isEmpty');

  isFunction = require('lodash/isFunction');

  isPlainObject = require('lodash/isPlainObject');

  isString = require('lodash/isString');

  keys = require('lodash/keys');

  matches = require('lodash/matches');

  merge = require('lodash/merge');

  set = require('lodash/set');

  Access = require('./access');

  Adapter = require('./adapter');

  FlameError = require('./flame-error');

  Record = require('./record');

  Serializer = require('./serializer');

  Validator = require('./validator');

  ({flatPaths} = require('./helpers'));

  Model = (function() {
    class Model {
      constructor(type, defaults, ...rs) {
        var cf, e, ref, ref1, ref2, ref3, ref4;
        if (any([!(isString(type)), isEmpty(type), !(isPlainObject(defaults))])) {
          e = "A Model must be initalized with a type and a defaults object as the first two arguments.";
          throw new FlameError(e);
          return;
        }
        this.type = type;
        this.defaults = defaults;
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
        }))) != null ? ref4 : null;
        this.data = this.obj();
        cf = get(this, 'config.opts.collection_field');
        this.collection = cf ? get(this.data, cf) : this.type;
        return;
      }

      obj() {
        var f, o;
        f = flatPaths(this.defaults);
        o = {};
        each(keys(f), (k) => {
          var v;
          v = (isFunction(f[k])) ? f[k](this.type, this.defaults) : f[k];
          return set(o, k, v);
        });
        return o;
      }

      extend(type, defaults, ...rs) {
        var ac, ad, cf, df, e, ref, ref1, ref2, ref3, ref4, se, va;
        if (any([!(isString(type)), isEmpty(type), !(isPlainObject(defaults))])) {
          e = "A Model must be extended with a type and a defaults object as the first two arguments.";
          throw new FlameError(e);
          return;
        }
        df = merge({}, this.defaults, defaults);
        ac = (ref = find(rs, matches({
          type: 'Access'
        }))) != null ? ref : this.access;
        ad = (ref1 = find(rs, matches({
          type: 'Adapter'
        }))) != null ? ref1 : this.adapter;
        cf = (ref2 = find(rs, matches({
          type: 'Config'
        }))) != null ? ref2 : this.config;
        se = (ref3 = find(rs, matches({
          type: 'Serializer'
        }))) != null ? ref3 : this.serializer;
        va = (ref4 = find(rs, matches({
          type: 'Validator'
        }))) != null ? ref4 : this.validator;
        return new this.constructor(type, df, ac, ad, cf, se, va);
      }

      create(values = {}, ...rs) {
        var ac, ad, cf, e, ref, ref1, ref2, ref3, ref4, se, va, vs;
        if (!(isPlainObject(values))) {
          e = "A Model instance must be created with a values object as the first argument.";
          throw new FlameError(e);
          return;
        }
        vs = merge({}, this.defaults, values);
        ac = (ref = find(rs, matches({
          type: 'Access'
        }))) != null ? ref : this.access;
        ad = (ref1 = find(rs, matches({
          type: 'Adapter'
        }))) != null ? ref1 : this.adapter;
        cf = (ref2 = find(rs, matches({
          type: 'Config'
        }))) != null ? ref2 : this.config;
        se = (ref3 = find(rs, matches({
          type: 'Serializer'
        }))) != null ? ref3 : this.serializer;
        va = (ref4 = find(rs, matches({
          type: 'Validator'
        }))) != null ? ref4 : this.validator;
        return new Record(this.type, null, vs, ac, ad, cf, se, va);
      }

      fragment(id, values = {}, ...rs) {
        var ac, ad, cf, e, ref, ref1, ref2, ref3, ref4, se, va, vs;
        if (!(isString(id)) || !(isPlainObject(values))) {
          e = "A Model fragment must be created with an id and a values object as the first and second arguments.";
          throw new FlameError(e);
          return;
        }
        vs = merge({}, this.defaults, values);
        ac = (ref = find(rs, matches({
          type: 'Access'
        }))) != null ? ref : this.access;
        ad = (ref1 = find(rs, matches({
          type: 'Adapter'
        }))) != null ? ref1 : this.adapter;
        cf = (ref2 = find(rs, matches({
          type: 'Config'
        }))) != null ? ref2 : this.config;
        se = (ref3 = find(rs, matches({
          type: 'Serializer'
        }))) != null ? ref3 : this.serializer;
        va = (ref4 = find(rs, matches({
          type: 'Validator'
        }))) != null ? ref4 : this.validator;
        return new Record(this.type, id, vs, ac, ad, cf, se, va);
      }

      async count(query) {
        return (await (this.adapter.count(this, query)));
      }

      del() {}

      async find(query, fields = null, transaction = null) {
        return (await (this.adapter.find(this, query, fields, transaction)));
      }

      async get(id, fields = null, transaction = null) {
        return (await (this.adapter.get(this, id, fields, transaction)));
      }

      async getAll(ids = [], fields = null) {
        return (await (this.adapter.getAll(this, ids, fields)));
      }

      async findAll(query, fields = null, transaction = null) {
        return (await (this.adapter.findAll(this, query, fields, transaction)));
      }

      async page(pager) {
        return (await (this.adapter.page(this, pager)));
      }

      traverse() {}

    };

    Model.prototype.type = 'Model';

    return Model;

  }).call(this);

  module.exports = Model;

}).call(this);
