each        = require 'lodash/each'
map         = require 'lodash/map'
Serializer  = require './serializer'
{ Filter }  = require 'firebase-admin/firestore'


class Query


  type: 'Query'


  # fbq = firestore query, s = serializer, f = field, v(s) = value(s), cl(s) = clause(s)
  filters =
    'eq':                 (s, f, v) -> (Filter.where (s.fmt[s.fmts.field.db] f), '==', v)
    'eq-any':            (s, f, vs) -> (Filter.where (s.fmt[s.fmts.field.db] f), 'in', vs)
    'gt':                 (s, f, v) -> (Filter.where (s.fmt[s.fmts.field.db] f), '>', v)
    'gte':                (s, f, v) -> (Filter.where (s.fmt[s.fmts.field.db] f), '>=', v)
    'includes':           (s, f, v) -> (Filter.where (s.fmt[s.fmts.field.db] f), 'array-contains', v)
    'includes-any':      (s, f, vs) -> (Filter.where (s.fmt[s.fmts.field.db] f), 'array-contains-any', vs)
    'lt':                 (s, f, v) -> (Filter.where (s.fmt[s.fmts.field.db] f), '<', v)
    'lte':                (s, f, v) -> (Filter.where (s.fmt[s.fmts.field.db] f), '<=', v)
    'not-eq':             (s, f, v) -> (Filter.where (s.fmt[s.fmts.field.db] f), '!=', v)
    'not-eq-any':        (s, f, vs) -> (Filter.where (s.fmt[s.fmts.field.db] f), 'not-in', vs)

  ops =
    'and':         (fbq, s, cls...) -> (fbq.where (andClause cls, s))
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
    'or':          (fbq, s, cls...) -> (fbq.where (orClause cls, s))
    'order-by':      (fbq, s, f, d) -> (fbq.orderBy (s.fmt[s.fmts.field.db] f), (d ? 'asc'))
    'start-at':        (fbq, _, v)  -> (fbq.startAt v...)


  orClause = (cls = [], serializer = null) ->
    s = serializer ? @.serializer
    return (Filter.or ...(map cls, ((cl) -> filters[cl[0]] s, ...cl[1..])))


  andClause = (cls = [], serializer = null) ->
    s = serializer ? @.serializer
    return (Filter.and ...(map cls, ((cl) -> filters[cl[0]] s, ...cl[1..])))


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
