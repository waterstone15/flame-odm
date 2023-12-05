cloneDeep  = require 'lodash/cloneDeep'
each       = require 'lodash/each'
get        = require 'lodash/get'
includes   = require 'lodash/includes'
isInteger  = require 'lodash/isInteger'
join       = require 'lodash/join'
last       = require 'lodash/last'
map        = require 'lodash/map'
reduce     = require 'lodash/reduce'
union      = require 'lodash/union'

Query      = require './query'
FlameError = require './flame-error'
Serializer = require './serializer'


class Pager


  type: 'Pager'

  allowed = [
    'eq'
    'eq-any'
    'gt'
    'gte'
    'includes'
    'includes-any'
    'lt'
    'lte'
    'not-eq'
    'not-eq-any'
    'order-by'
    'page-size'
  ]


  constructor: (q = [], opts = {}) ->
    if !(reduce q, ((out, constraint) -> (out && (includes allowed, constraint[0]))), true)
      e = "The first argument to a Pager may only use the following constraings: #{(join allowed, ', ')}."
      throw (new FlameError e)
      return

    @.q    = q
    @.size = opts.size ? 10
    return


  queries: (cursor = null) ->

    start_at_q = (=>
      if cursor
        order_fields = (reduce @.q, ((acc, _q) ->
          return if (_q[0] == 'order-by') then (union acc, [ _q[1] ]) else acc
        ), [])
        order_values = (map order_fields, ((_f) -> (get cursor.obj, _f)))
        return [[ 'start-at', order_values ]]
      else
        return []
    )()

    collection_q = (cloneDeep @.q)
    reversed_q   = (map (cloneDeep collection_q), ((_q) ->
      asc = (_q.length == 2) || ((_q.length == 3) && ((last _q) == 'asc'))
      return if asc then [_q[0..1]..., 'desc'] else [_q[0..1]..., 'asc']
    ))

    if (cursor && cursor.position == 'page-end')
      [ collection_q, reversed_q ] = [ reversed_q, collection_q ]

    itemz_q  = (union (cloneDeep collection_q), [[ 'limit', @.size + 1 ]], start_at_q)
    priorz_q = (union (cloneDeep reversed_q), [[ 'limit', 2 ]], start_at_q)
    tail_q   = (union (cloneDeep collection_q), start_at_q)

    return {
      collection: (new Query collection_q)
      reversed:   (new Query reversed_q)
      itemz:      (new Query itemz_q)
      priorz:     (new Query priorz_q)
      tail:       (new Query tail_q)
    }


module.exports = Pager
