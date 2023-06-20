each          = require 'lodash/each'
every         = require 'lodash/every'
FlameError    = require '@/lib/flame-error'
functions     = require 'lodash/functions'
get           = require 'lodash/get'
isArray       = require 'lodash/isArray'
isEmpty       = require 'lodash/isEmpty'
isPlainObject = require 'lodash/isPlainObject'
isString      = require 'lodash/isString'
keys          = require 'lodash/keys'
{ flatPaths } = require '@/lib/helpers'


class Validator

  
  type: 'Validator'


  constructor: (v) ->
    (v = (flatPaths v)) if (isEmpty (functions v))

    if !(isPlainObject v)
      e = "A Validator must be initalized with a 1 (or 2) level plain object of
        validator functions."
      throw (new FlameError e)
      return

    v_ok = (every (keys v), ((_k) -> v[_k].length == 2))

    if !v_ok
      e = "Each Validator function must have an arity of 2. The first parameter
        is the value being checked and the second parameter is the object
        being validated."
      throw (new FlameError e)
      return

    @.v = v
    return

  
  errors: (obj, fields) ->
    fields ?= (keys @.v)

    if !(isPlainObject obj)
      e = "The first argument to Validator.ok(obj, fields) should be a 1 (or 2)
        level plain object."
      throw (new FlameError e)
      return

    if !(isArray fields) || !(every fields, isString)
      e = "The optional second argument to Validator.ok(obj, fields) should be an
        array of strings."
      throw (new FlameError e)
      return

    errs = {}
    (each fields, ((_k) =>
      (errs[_k] = true) if !(@.v[_k](get obj, _k))
      return
    ))
    return errs


  ok: (obj, fields) ->
    fields ?= (keys @.v)

    if !(isPlainObject obj)
      e = "The first argument to Validator.ok(obj, fields) should be a 1 (or 2)
        level plain object."
      throw (new FlameError e)
      return

    if !(isArray fields) || !(every fields, isString)
      e = "The optional second argument to Validator.ok(obj, fields) should be an
        array of strings."
      throw (new FlameError e)
      return

    return (every fields, ((_k) => @.v[_k](get obj, _k)))


module.exports = Validator
