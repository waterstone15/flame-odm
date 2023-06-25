de = require 'dotenv'
de.config({  path: '.env' })

ma = require 'module-alias'
(ma.addAlias '@', __dirname + '../../')

chai   = require 'chai'
assert = chai.assert

rejects  = require '@/test-helpers/rejects'
resolves = require '@/test-helpers/resolves'

Adapter    = require '@/lib/adapter'
Model      = require '@/lib/model'
Serializer = require '@/lib/serializer'
Validator  = require '@/lib/validator'
Q          = require '@/lib/query'
Config     = require '@/lib/config'

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

    m = (new Model 'Thing', {
      created_at: -> DateTime.local().setZone('utc').toISO()
      deleted:    -> false
      deleted_at: -> null
      id:         -> (random.randomString 36)
      updated_at: -> DateTime.local().setZone('utc').toISO()
    }, c, s)

    r1 = (m.create { a: 2 })
    r2 = (m.create { a: 3 })
    r3 = (m.create { a: 4 })
    await (r1.save())
    await (r2.save())
    await (r3.save())

    rs = await (m.getAll [ r1.id, r2.id, r3.id ])
    console.log rs

    ok = true
    (assert ok)
    return
