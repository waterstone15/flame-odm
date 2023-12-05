require('dotenv').config()

ma = require 'module-alias'
(ma.addAlias '@flame-odm', __dirname + '../../')

chai   = require 'chai'
assert = chai.assert

rejects  = require '@flame-odm/test-helpers/rejects'
resolves = require '@flame-odm/test-helpers/resolves'

Adapter    = require '@flame-odm/lib/adapter'
Config     = require '@flame-odm/lib/config'
Model      = require '@flame-odm/lib/model'
Pager      = require '@flame-odm/lib/pager'
Q          = require '@flame-odm/lib/query'
Serializer = require '@flame-odm/lib/serializer'
Validator  = require '@flame-odm/lib/validator'

_            = require 'lodash'
random       = require '@stablelib/random'
{ all }      = require 'rsvp'
{ DateTime } = require 'luxon'

util         = require 'node:util'

describe 'WIP', ->

  it '::', ->
    ok = false
    ok = true
    (assert ok)
    return
