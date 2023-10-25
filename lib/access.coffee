every         = require 'lodash/every'
get           = require 'lodash/get'
intersection  = require 'lodash/intersection'
isArray       = require 'lodash/isArray'
isEmpty       = require 'lodash/isEmpty'
isPlainObject = require 'lodash/isPlainObject'
isString      = require 'lodash/isString'
keys          = require 'lodash/keys'
merge         = require 'lodash/merge'
reduce        = require 'lodash/reduce'
set           = require 'lodash/set'
union         = require 'lodash/union'

FlameError    = require './flame-error'
{ flatPaths } = require './helpers'



class Access


  type: 'Access'


  constructor: (mask) ->

    flat = (flatPaths mask)

    ok = (reduce (keys flat), ((r, k) ->
      return r && (isArray flat[k]) && (every flat[k], isString)
    ), true)

    if !(isPlainObject mask) || !ok
      e = "An Access must be initalized with a plain object of role arrays."
      throw (new FlameError e)
      return

    @.mask = flat
    return


  screen: (obj, roles) ->

    if !(isPlainObject obj)
      e = "The first argument to Access.mask() must be a plain object."
      throw (new FlameError e)
      return

    if !(isArray roles) || !(every roles, isString)
      e = "The second argument to Access.mask() must be an array of roles."
      throw (new FlameError e)
      return

    return (reduce (keys @.mask), ((r, k) =>
      if (isEmpty (intersection roles, @.mask[k]))
        return r
      else
        return (merge {}, (set {}, k, (get obj, k)), r)
    ), {})


  fields: (roles) ->

    if !(isArray roles) || !(every roles, isString)
      e = "The first argument to Access.fields() must be an array of roles."
      throw (new FlameError e)
      return

    return (reduce (keys @.mask), ((r, k) =>
      if (isEmpty (intersection roles, @.mask[k]))
        return r
      else
        return (union r, [k])
    ), [])


module.exports = Access
