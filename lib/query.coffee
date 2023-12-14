map        = require 'lodash/map'
each       = require 'lodash/each'

Serializer = require './serializer'


class Query


  type: 'Query'

  # firestore query (fbq), serializer (s), fields (f), values (v)
  ops =
    'eq':            (fbq, s, f, v) -> (fbq.where (s.fmt[s.fmts.field.db] f), '==', v)
    'eq-any':       (fbq, s, f, vs) -> (fbq.where (s.fmt[s.fmts.field.db] f), 'in', vs)
    'gt':            (fbq, s, f, v) -> (fbq.where (s.fmt[s.fmts.field.db] f), '>', v)
    'gte':           (fbq, s, f, v) -> (fbq.where (s.fmt[s.fmts.field.db] f), '>=', v)
    'includes':      (fbq, s, f, v) -> (fbq.where (s.fmt[s.fmts.field.db] f), 'array-contains', v)
    'includes-any': (fbq, s, f, vs) -> (fbq.where (s.fmt[s.fmts.field.db] f), 'array-contains-any', vs)
    'limit':            (fbq, _, n) -> (fbq.limit n)
    'lt':            (fbq, s, f, v) -> (fbq.where (s.fmt[s.fmts.field.db] f), '<', v)
    'lte':           (fbq, s, f, v) -> (fbq.where (s.fmt[s.fmts.field.db] f), '<=', v)
    'not-eq':        (fbq, s, f, v) -> (fbq.where (s.fmt[s.fmts.field.db] f), '!=', v)
    'not-eq-any':   (fbq, s, f, vs) -> (fbq.where (s.fmt[s.fmts.field.db] f), 'not-in', vs)
    'order-by':      (fbq, s, f, d) -> (fbq.orderBy (s.fmt[s.fmts.field.db] f), (d ? 'asc'))
    'start-at':         (fbq, _, v) -> (fbq.startAt v...)


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
