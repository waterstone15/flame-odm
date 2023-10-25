any           = require 'lodash/some'
each          = require 'lodash/each'
find          = require 'lodash/find'
get           = require 'lodash/get'
isEmpty       = require 'lodash/isEmpty'
isFunction    = require 'lodash/isFunction'
isPlainObject = require 'lodash/isPlainObject'
isString      = require 'lodash/isString'
keys          = require 'lodash/keys'
matches       = require 'lodash/matches'
merge         = require 'lodash/merge'
set           = require 'lodash/set'

Access        = require './access'
Adapter       = require './adapter'
FlameError    = require './flame-error'
Record        = require './record'
Serializer    = require './serializer'
Validator     = require './validator'
{ flatPaths } = require './helpers'


class Model


  type: 'Model'


  constructor: (type, defaults, rs...) ->
    if (any [ !(isString type), (isEmpty type), !(isPlainObject defaults) ])
      e = "A Model must be initalized with a type and a defaults object as the
        first two arguments."
      throw (new FlameError e)
      return

    @.type       = type
    @.defaults   = defaults

    @.access     = (find rs, (matches { type: 'Access' }))        ? null
    @.adapter    = (find rs, (matches { type: 'Adapter' }))       ? (new Adapter())
    @.config     = (find rs, (matches { type: 'Config' }))        ? null
    @.serializer = (find rs, (matches { type: 'Serializer' }))    ? (new Serializer())
    @.validator  = (find rs, (matches { type: 'Validator' }))     ? null
    @.data       = @.obj()

    cf = (get @, 'config.opts.collection_field')
    @.collection = if cf then (get @.data, cf) else @.type
    return


  obj: ->
    f = (flatPaths @.defaults)
    o = {}
    (each (keys f), (k) =>
      v = if (isFunction f[k]) then (f[k] @.type, @.defaults) else f[k]
      (set o, k, v)
    )
    return o


  extend: (type, defaults, rs...) ->

    if (any [ !(isString type), (isEmpty type), !(isPlainObject defaults) ])
      e = "A Model must be extended with a type and a defaults object as the
        first two arguments."
      throw (new FlameError e)
      return

    df = (merge {}, @.defaults, defaults)

    ac = (find rs, (matches { type: 'Access' }))        ? @.access
    ad = (find rs, (matches { type: 'Adapter' }))       ? @.adapter
    cf = (find rs, (matches { type: 'Config' }))        ? @.config
    se = (find rs, (matches { type: 'Serializer' }))    ? @.serializer
    va = (find rs, (matches { type: 'Validator' }))     ? @.validator

    return (new @.constructor type, df, ac, ad, cf, se, va)


  create: (values = {}, rs...) ->

    if !(isPlainObject values)
      e = "A Model instance must be created with a values object as the first
        argument."
      throw (new FlameError e)
      return

    vs = (merge {}, @.defaults, values)
    ac = (find rs, (matches { type: 'Access' }))        ? @.access
    ad = (find rs, (matches { type: 'Adapter' }))       ? @.adapter
    cf = (find rs, (matches { type: 'Config' }))        ? @.config
    se = (find rs, (matches { type: 'Serializer' }))    ? @.serializer
    va = (find rs, (matches { type: 'Validator' }))     ? @.validator

    return (new Record @.type, null, vs, ac, ad, cf, se, va)


  fragment: (id, values = {}, rs...) ->

    if !(isString id) || !(isPlainObject values)
      e = "A Model fragment must be created with an id and a values object as the
      first and second arguments."
      throw (new FlameError e)
      return

    vs = (merge {}, @.defaults, values)
    ac = (find rs, (matches { type: 'Access' }))        ? @.access
    ad = (find rs, (matches { type: 'Adapter' }))       ? @.adapter
    cf = (find rs, (matches { type: 'Config' }))        ? @.config
    se = (find rs, (matches { type: 'Serializer' }))    ? @.serializer
    va = (find rs, (matches { type: 'Validator' }))     ? @.validator

    return (new Record @.type, id, vs, ac, ad, cf, se, va)


  count: (query) ->
    return await (@.adapter.count @, query)


  del: ->


  find: (query, fields = null, transaction = null) ->
    return await (@.adapter.find @, query, fields, transaction)


  get: (id, fields = null, transaction = null) ->
    return await (@.adapter.get @, id, fields, transaction)


  getAll: (ids = [], fields = null) ->
    return await (@.adapter.getAll @, ids, fields)


  findAll: (query, fields = null, transaction = null) ->
    return await (@.adapter.findAll @, query, fields, transaction)


  page: (pager)->
    return await (@.adapter.page @, pager)


  traverse: ->


module.exports = Model
