any           = require 'lodash/some'
compact       = require 'lodash/compact'
each          = require 'lodash/each'
find          = require 'lodash/find'
FlameError    = require '@/lib/flame-error'
get           = require 'lodash/get'
isEmpty       = require 'lodash/isEmpty'
isFunction    = require 'lodash/isFunction'
isPlainObject = require 'lodash/isPlainObject'
isString      = require 'lodash/isString'
keys          = require 'lodash/keys'
matches       = require 'lodash/matches'
random        = require '@stablelib/random'
set           = require 'lodash/set'
union         = require 'lodash/union'
uniq          = require 'lodash/uniq'
{ flatPaths } = require '@/lib/helpers'

Access        = require '@/lib/access'
Adapter       = require '@/lib/adapter'
Config        = require '@/lib/config'
Serializer    = require '@/lib/serializer'
Validator     = require '@/lib/validator'


class Record


  type: 'Record'


  constructor: (type, id = null, values, rs...) ->
    if (any [ !(isString type), (isEmpty type), !(isPlainObject values) ])
      e = "A Record must be initalized with a type, an id, and a values object as the
        first three arguments."
      throw (new FlameError e)
      return

    @.type       = type
    @.values     = values

    @.access     = (find rs, (matches { type: 'Access' }))        ? null
    @.adapter    = (find rs, (matches { type: 'Adapter' }))       ? (new Adapter())
    @.config     = (find rs, (matches { type: 'Config' }))        ? null
    @.serializer = (find rs, (matches { type: 'Serializer' }))    ? (new Serializer())
    @.validator  = (find rs, (matches { type: 'Validator' }))     ? (new Validator())
    @.data       = @.obj()

    cf  = (get @, 'config.opts.collection_field')
    idf = (get @, 'config.opts.id_field')

    @.collection = if cf then (get @.data, cf) else @.type
    @.id         = (id ? (if idf then (get @.data, idf) else (random.randomString 36)))
    return


  obj: ->
    if !@.data
      f = (flatPaths @.values)
      o = {}
      (each (keys f), (k) =>
        v = if (isFunction f[k]) then (f[k] @.type, @.values) else f[k]
        (set o, k, v)
      )
      @.data = o
    return @.data


  ok: (fields = null) ->
    return (@.validator.ok @.data, fields)


  errors: (fields = null) ->
    return (@.validator.errors @.data, fields)


  save: (transaction = null) ->
    return await (@.adapter.save @, transaction)


  update: (fields = [], transaction = null) ->
    fs = (uniq (union [], fields, (compact [ (get @, 'config.opts.updated_at_field') ])))
    return await (@.adapter.update @, fs, transaction)


module.exports = Record
