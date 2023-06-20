isEmpty       = require 'lodash/isEmpty'
isPlainObject = require 'lodash/isPlainObject'
keys          = require 'lodash/keys'

flatPaths = (obj) ->
  o = {}
  
  walk = (_o, path = '') ->
    for k in (keys _o)
      if (isPlainObject _o[k]) && !(isEmpty _o[k])
        (walk _o[k], "#{path}#{k}.")
      else
        o["#{path}#{k}"] = _o[k]

  (walk obj)
  return o

module.exports = {
  flatPaths
}
