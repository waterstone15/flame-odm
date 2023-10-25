(function() {
  var Serializer, camelCase, capitalize, get, identity, includes, isArray, isEmpty, isFunction, isString, kebabCase, keys, mapKeys, replace, set, snakeCase, split;

  camelCase = require('lodash/camelCase');

  capitalize = require('lodash/capitalize');

  get = require('lodash/get');

  identity = require('lodash/identity');

  includes = require('lodash/includes');

  isArray = require('lodash/isArray');

  isEmpty = require('lodash/isEmpty');

  isFunction = require('lodash/isFunction');

  isString = require('lodash/isString');

  kebabCase = require('lodash/kebabCase');

  keys = require('lodash/keys');

  mapKeys = require('lodash/mapKeys');

  replace = require('lodash/replace');

  set = require('lodash/set');

  snakeCase = require('lodash/snakeCase');

  split = require('lodash/split');

  Serializer = (function() {
    class Serializer {
      constructor(opt = {}) {
        var ref, ref1;
        this.prefixes = (isArray(opt.prefixes)) ? opt.prefixes : null;
        this.separator = (isString(opt.separator)) ? opt.separator : '-';
        this.fmts = {
          field: {
            db: (ref = get(opt, 'fmt.db.field')) != null ? ref : 'kebab',
            plain: (ref1 = get(opt, 'fmt.obj.field')) != null ? ref1 : 'snake'
          }
        };
        return;
      }

      fromDB(obj) {
        var i, k, len, o, p_fmt, prefix, ref, t_fmt, tail;
        o = {};
        ref = keys(obj);
        for (i = 0, len = ref.length; i < len; i++) {
          k = ref[i];
          prefix = (split(k, this.separator, 1))[0];
          tail = replace(k, `${prefix}${this.separator}`, '');
          if (includes(this.prefixes, prefix)) {
            p_fmt = this.fmt[this.fmts.field.plain](prefix);
            t_fmt = this.fmt[this.fmts.field.plain](tail);
            set(o, `${p_fmt}.${t_fmt}`, obj[k]);
          } else {
            o[this.fmt[this.fmts.field.plain](k)] = obj[k];
          }
        }
        return o;
      }

      toDB(obj) {
        var i, j, k, k_fmt, len, len1, o, p, p_fmt, ref, ref1;
        o = {};
        if (isEmpty(this.prefixes)) {
          o = mapKeys(obj, (v, k) => {
            return this.fmt[this.fmts.field.db](k);
          });
        } else {
          ref = this.prefixes;
          for (i = 0, len = ref.length; i < len; i++) {
            p = ref[i];
            ref1 = keys(obj[p]);
            for (j = 0, len1 = ref1.length; j < len1; j++) {
              k = ref1[j];
              p_fmt = this.fmt[this.fmts.field.db](p);
              k_fmt = this.fmt[this.fmts.field.db](k);
              o[`${p_fmt}${this.separator}${k_fmt}`] = obj[p][k];
            }
          }
        }
        return o;
      }

    };

    Serializer.prototype.type = 'Serializer';

    Serializer.prototype.fmt = {
      camel: function(s) {
        return camelCase(s);
      },
      kebab: function(s) {
        return kebabCase(s);
      },
      pascal: function(s) {
        return capitalize(camelCase(s));
      },
      snake: function(s) {
        return snakeCase(s);
      }
    };

    return Serializer;

  }).call(this);

  module.exports = Serializer;

}).call(this);
