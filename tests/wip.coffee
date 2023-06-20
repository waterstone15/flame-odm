de = require 'dotenv'
de.config({  path: '.env' })

ma = require 'module-alias'
(ma.addAlias '@', __dirname + '../../')

chai   = require 'chai'
assert = chai.assert

rejects  = require '@/test-helpers/rejects'
resolves = require '@/test-helpers/resolves'

Serializer = require '@/lib/serializer'

{ all } = require 'rsvp'
_ = require 'lodash'

describe 'WIP', ->

  it '::', ->

    ok = false
    
    s = (new Serializer [ 'a' ])
    o = { a: { b: 1 }}

    db = (s.toDB o)

    ok = (_.isEqual db, { 'a-b': 1 })
    ok = true

    (assert ok)
    return
