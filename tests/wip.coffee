de = require 'dotenv'
de.config({  path: '.env' })

ma = require 'module-alias'
(ma.addAlias '@flame-odm', __dirname + '../../')

chai   = require 'chai'
assert = chai.assert

rejects  = require '@flame-odm/test-helpers/rejects'
resolves = require '@flame-odm/test-helpers/resolves'

Adapter    = require '@flame-odm/lib/adapter'
Model      = require '@flame-odm/lib/model'
Serializer = require '@flame-odm/lib/serializer'
Validator  = require '@flame-odm/lib/validator'
Q          = require '@flame-odm/lib/query'
Config     = require '@flame-odm/lib/config'

_            = require 'lodash'
random       = require '@stablelib/random'
{ all }      = require 'rsvp'
{ DateTime } = require 'luxon'

describe 'WIP', ->

  it '::', ->

    ok = false

    s = (new Serializer { prefixes: []})

    c = (new Config {
      created_at_field: 'created_at'
      deleted_at_field: 'deleted_at'
      deleted_field:    'deleted'
      id_field:         'id'
      updated_at_field: 'updated_at'
    })

    m = (new Model 'Alpha', {
      created_at: -> DateTime.local().setZone('utc').toISO()
      deleted:    -> false
      deleted_at: -> null
      id:         -> (random.randomString 36)
      updated_at: -> DateTime.local().setZone('utc').toISO()
      letter:     -> null
    }, c, s)


    col_first_q = (new Q [
      [ 'order-by', 'letter', 'asc' ]
      [ 'order-by', 'id', 'asc' ]
    ])
    col_last_q = (new Q [
      [ 'order-by', 'letter', 'desc' ]
      [ 'order-by', 'id', 'desc' ]
    ])
    page_q = (new Q [
      [ 'order-by', 'letter', 'desc' ]
      [ 'order-by', 'id', 'desc' ]
      [ 'gt', 'letter', 'a' ]
      [ 'lt', 'letter', 'c' ]
    ])
    predecessor_q = (new Q [
    ])
    successor_q = (new Q [
    ])

    # [ 'a', 'b', 'c', 'd', 'e' ]

    page = await (m.findAll page_q, [ 'id', 'letter', ])
    console.log page

    col_first = await (m.find col_first_q, [ 'id', 'letter' ])
    console.log page

    col_last  = await (m.find col_last_q,  [ 'id', 'letter' ])
    console.log page

    ok = true
    (assert ok)
    return
