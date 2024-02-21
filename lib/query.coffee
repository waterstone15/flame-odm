each       = require 'lodash/each'
Serializer = require './serializer'


class Query


  type: 'Query'


  # fbq = firestore query, s = serializer, fs = fields, v(s) = value(s)
  ops =
    'eq':            (fbq, s, fs, v) -> (fbq.where (s.fmt[s.fmts.field.db] fs), '==', v)
    'eq-any':       (fbq, s, fs, vs) -> (fbq.where (s.fmt[s.fmts.field.db] fs), 'in', vs)
    'gt':            (fbq, s, fs, v) -> (fbq.where (s.fmt[s.fmts.field.db] fs), '>', v)
    'gte':           (fbq, s, fs, v) -> (fbq.where (s.fmt[s.fmts.field.db] fs), '>=', v)
    'includes':      (fbq, s, fs, v) -> (fbq.where (s.fmt[s.fmts.field.db] fs), 'array-contains', v)
    'includes-any': (fbq, s, fs, vs) -> (fbq.where (s.fmt[s.fmts.field.db] fs), 'array-contains-any', vs)
    'limit':             (fbq, _, n) -> (fbq.limit n)
    'lt':            (fbq, s, fs, v) -> (fbq.where (s.fmt[s.fmts.field.db] fs), '<', v)
    'lte':           (fbq, s, fs, v) -> (fbq.where (s.fmt[s.fmts.field.db] fs), '<=', v)
    'not-eq':        (fbq, s, fs, v) -> (fbq.where (s.fmt[s.fmts.field.db] fs), '!=', v)
    'not-eq-any':   (fbq, s, fs, vs) -> (fbq.where (s.fmt[s.fmts.field.db] fs), 'not-in', vs)
    'order-by':      (fbq, s, fs, d) -> (fbq.orderBy (s.fmt[s.fmts.field.db] fs), (d ? 'asc'))
    'start-at':         (fbq, _, v)  -> (fbq.startAt v...)


  constructor: (q = [], serializer = null) ->
    @.serializer = serializer ? (new Serializer())
    @.q = q
    return


  prepare: (col_ref, serializer = null) ->
    s = serializer ? @.serializer
    fbq = col_ref
    (each @.q, (statement) ->
      fbq = (ops[statement[0]] fbq, s, ...statement[1..])
      return
    )
    return fbq


module.exports = Query
