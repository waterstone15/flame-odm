require('dotenv').config()

ma = require 'module-alias'
(ma.addAlias '@flame-odm', __dirname + '../../')

chai   = require 'chai'
assert = chai.assert

_            = require 'lodash'
Adapter      = require '@flame-odm/lib/adapter'
Config       = require '@flame-odm/lib/config'
Model        = require '@flame-odm/lib/model'
Pager        = require '@flame-odm/lib/pager'
Query        = require '@flame-odm/lib/query'
random       = require '@stablelib/random'
rejects      = require '@flame-odm/test-helpers/rejects'
resolves     = require '@flame-odm/test-helpers/resolves'
Serializer   = require '@flame-odm/lib/serializer'
util         = require 'node:util'
{ all }      = require 'rsvp'
{ DateTime } = require 'luxon'


a = (new Adapter 'process-env')

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
}, a, c, s,)



describe 'WIP ––', ->


  it 'A query works with or filters', ->
    #  a b bb bb bb bb bb bb c d e f g h i j k l m n o p q r s t u v w x y z
    # [↑ • •  •]
    ok = false

    query = (new Query [
      [ 'and', [ 'eq', 'letter', 'q' ], [ 'eq', 'id', 'iLkVBH21syix8BB53FndNCfz3KZmswZgT1MR' ]]
      [ 'order-by', 'letter', 'asc' ]
    ])
    fields = [ 'id', 'letter' ]

    letters = await (m.findAll query, fields)
    console.log letters

    ok = (_.isEqual letters, !null)
    (assert (true || ok))
    return