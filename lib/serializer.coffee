camelCase     = require 'lodash/camelCase'
capitalize    = require 'lodash/capitalize'
get           = require 'lodash/get'
includes      = require 'lodash/includes'
isArray       = require 'lodash/isArray'
isEmpty       = require 'lodash/isEmpty'
isString      = require 'lodash/isString'
kebabCase     = require 'lodash/kebabCase'
keys          = require 'lodash/keys'
mapKeys       = require 'lodash/mapKeys'
replace       = require 'lodash/replace'
set           = require 'lodash/set'
snakeCase     = require 'lodash/snakeCase'
split         = require 'lodash/split'


class Serializer


  type: 'Serializer'

  fmt =
    camel:  (s) -> (camelCase s)
    kebab:  (s) -> (kebabCase s)
    pascal: (s) -> (capitalize (camelCase s))
    snake:  (s) -> (snakeCase s)


  constructor: (opt = {}) ->
    @.prefixes  = if (isArray opt.prefixes)   then opt.prefixes  else null
    @.separator = if (isString opt.separator) then opt.separator else '-'
    @.fmt =
      db:
        field: (get opt, 'fmt.db.field')  ? 'kebab'
      plain:
        field: (get opt, 'fmt.obj.field') ? 'snake'
    return


  fromDB: (obj) ->
    o = {}
    for k in (keys obj)
      prefix = (split k, @.separator, 1)[0]
      tail   = (replace k, "#{prefix}#{@.separator}", '')
      if (includes @.prefixes, prefix)
        p_fmt = (fmt[@.fmt.plain.field] prefix)
        t_fmt = (fmt[@.fmt.plain.field] tail)
        (set o, "#{p_fmt}.#{t_fmt}", obj[k])
      else
        o[(fmt[@.fmt.plain.field] k)] = obj[k]
    return o


  toDB: (obj) ->
    o = {}
    if (isEmpty @.prefixes)
      o = (mapKeys obj, (v, k) => (fmt[@.fmt.db.field] k))
    else
      for p in @.prefixes
        for k in (keys obj[p])
          p_fmt = (fmt[@.fmt.db.field] p)
          k_fmt = (fmt[@.fmt.db.field] k)
          o["#{p_fmt}#{@.separator}#{k_fmt}"] = obj[p][k]
    return o



module.exports = Serializer
