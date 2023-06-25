map        = require 'lodash/map'

Serializer = require '@/lib/serializer'


class Query


  type: 'Query'

  # fbq = fb query, s = serializer, f(s) = field(s), v(s) = value(s)
  ops =
    'eq':            (fbq, s, f, v) -> (fbq.where (s.fmt[s.fmts.field.db] f), '==', v)
    'not-eq':        (fbq, s, f, v) -> (fbq.where (s.fmt[s.fmts.field.db] f), '!=', v)
    'gt':            (fbq, s, f, v) -> (fbq.where (s.fmt[s.fmts.field.db] f), '>', v)
    'gte':           (fbq, s, f, v) -> (fbq.where (s.fmt[s.fmts.field.db] f), '>=', v)
    'lt':            (fbq, s, f, v) -> (fbq.where (s.fmt[s.fmts.field.db] f), '<', v)
    'lte':           (fbq, s, f, v) -> (fbq.where (s.fmt[s.fmts.field.db] f), '<=', v)
    'includes':      (fbq, s, f, v) -> (fbq.where (s.fmt[s.fmts.field.db] f), 'array-contains', v)
    'includes-any': (fbq, s, f, vs) -> (fbq.where (s.fmt[s.fmts.field.db] f), 'array-contains-any', vs)
    'eq-any':       (fbq, s, f, vs) -> (fbq.where (s.fmt[s.fmts.field.db] f), 'in', vs)
    'not-eq-any':   (fbq, s, f, vs) -> (fbq.where (s.fmt[s.fmts.field.db] f), 'not-in', vs)
    'order-by':      (fbq, s, f, d) -> (fbq.orderBy (s.fmt[s.fmts.field.db] f), (d ? 'asc'))
    'limit':            (fbq, _, n) -> (fbq.limit n)
    # 'start-at':            (fbq, x) -> (fbq.startAt x)
    # 'end-at':              (fbq, x) -> (fbq.endAt x)
    # 'start-after' :        (fbq, x) -> (fbq.startAfter x)
    # 'end-after':           (fbq, x) -> (fbq.endAfter x)
    # 'select':          (fbq, fs...) -> (fbq.select fs...)


  constructor: (q = [], serializer = null) ->
    @.serializer = serializer ? (new Serializer())
    @.q = q
    return


  prepare: (cr) ->
    fbq = cr
    for statement in @.q
      fbq = (ops[statement[0]] fbq, @.serializer, ...statement[1..])
    return fbq




module.exports = Query
