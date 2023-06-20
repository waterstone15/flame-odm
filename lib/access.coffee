every         = require 'lodash/every'
FlameError    = require '@/lib/flame-error'
get           = require 'lodash/get'
intersection  = require 'lodash/intersection'
isArray       = require 'lodash/isArray'
isEmpty       = require 'lodash/isEmpty'
isPlainObject = require 'lodash/isPlainObject'
isString      = require 'lodash/isString'
keys          = require 'lodash/keys'
merge         = require 'lodash/merge'
union         = require 'lodash/union'
reduce        = require 'lodash/reduce'
set           = require 'lodash/set'
{ flatPaths } = require '@/lib/helpers'



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


  paths: (roles) ->

    if !(isArray roles) || !(every roles, isString)
      e = "The first argument to Access.paths() must be an array of roles."
      throw (new FlameError e)
      return

    return (reduce (keys @.mask), ((r, k) =>
      if (isEmpty (intersection roles, @.mask[k]))
        return r
      else
        return (union r, [k])
    ), [])


module.exports = Access
