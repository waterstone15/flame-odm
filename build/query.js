(function() {
  var Query, Serializer, each, map;

  map = require('lodash/map');

  each = require('lodash/each');

  Serializer = require('./serializer');

  Query = (function() {
    var ops;

    class Query {
      // 'select':          (fbq, fs...) -> (fbq.select fs...)
      // 'end-at':              (fbq, x) -> (fbq.endAt x)
      // 'start-after' :        (fbq, x) -> (fbq.startAfter x)
      // 'end-after':           (fbq, x) -> (fbq.endAfter x)
      constructor(q = [], serializer = null) {
        this.serializer = serializer != null ? serializer : new Serializer();
        this.q = q;
        return;
      }

      prepare(col_ref, serializer = null) {
        var fbq, s;
        s = serializer != null ? serializer : this.serializer;
        fbq = col_ref;
        each(this.q, function(statement) {
          fbq = ops[statement[0]](fbq, s, ...statement.slice(1));
        });
        return fbq;
      }

    };

    Query.prototype.type = 'Query';

    // fbq = firestore query, s = serializer, f = fields, v = values
    ops = {
      'eq': function(fbq, s, f, v) {
        return fbq.where(s.fmt[s.fmts.field.db](f), '==', v);
      },
      'not-eq': function(fbq, s, f, v) {
        return fbq.where(s.fmt[s.fmts.field.db](f), '!=', v);
      },
      'gt': function(fbq, s, f, v) {
        return fbq.where(s.fmt[s.fmts.field.db](f), '>', v);
      },
      'gte': function(fbq, s, f, v) {
        return fbq.where(s.fmt[s.fmts.field.db](f), '>=', v);
      },
      'lt': function(fbq, s, f, v) {
        return fbq.where(s.fmt[s.fmts.field.db](f), '<', v);
      },
      'lte': function(fbq, s, f, v) {
        return fbq.where(s.fmt[s.fmts.field.db](f), '<=', v);
      },
      'includes': function(fbq, s, f, v) {
        return fbq.where(s.fmt[s.fmts.field.db](f), 'array-contains', v);
      },
      'includes-any': function(fbq, s, f, vs) {
        return fbq.where(s.fmt[s.fmts.field.db](f), 'array-contains-any', vs);
      },
      'eq-any': function(fbq, s, f, vs) {
        return fbq.where(s.fmt[s.fmts.field.db](f), 'in', vs);
      },
      'not-eq-any': function(fbq, s, f, vs) {
        return fbq.where(s.fmt[s.fmts.field.db](f), 'not-in', vs);
      },
      'order-by': function(fbq, s, f, d) {
        return fbq.orderBy(s.fmt[s.fmts.field.db](f), d != null ? d : 'asc');
      },
      'limit': function(fbq, _, n) {
        return fbq.limit(n);
      },
      'start-at': function(fbq, v) {
        return fbq.startAt(v);
      }
    };

    return Query;

  }).call(this);

  module.exports = Query;

}).call(this);
