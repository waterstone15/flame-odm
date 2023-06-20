ma = require 'module-alias'
(ma.addAlias '@', __dirname + '../../')

chai   = require 'chai'
assert = chai.assert

Serializer = require '@/lib/serializer'

_ = require 'lodash'


describe 'Serializer --', ->

  it 'A Serializer can convert a plain-formatted objects into DB-formatted objects (deep).', ->
    ok = false
    
    s = (new Serializer { prefixes: [ 'a', 'z' ] })
    o = { a: { b: 1, c: 2 }, z: { b_d: 1, c: 2 }}

    db = (s.toDB o)

    ok = (_.isEqual db, { 'a-b': 1, 'a-c': 2, 'z-b-d': 1, 'z-c': 2 })

    (assert ok)
    return

  it 'A Serializer can convert a DB-formatted objects into plain-formatted objects (deep).', ->
    ok = false
    
    s = (new Serializer { prefixes: [ 'a', 'z' ] })
    o = { 'a-b': 1, 'a-c': 2, 'z-b-d': 1, 'z-c': 2 }

    db = (s.fromDB o)

    ok = (_.isEqual db, { a: { b: 1, c: 2 }, z: { b_d: 1, c: 2 }})

    (assert ok)
    return

  it 'A Serializer can convert a plain-formatted objects into DB-formatted objects (flat).', ->
    ok = false
    
    s = (new Serializer())
    o = { a: 1, z_x: 1}

    db = (s.toDB o)

    ok = (_.isEqual db, { a: 1, 'z-x': 1 })

    (assert ok)
    return

  it 'A Serializer can convert a DB-formatted objects into plain-formatted objects (flat).', ->
    ok = false
    
    s = (new Serializer())
    o = { a: 1, 'z-x': 1 }

    db = (s.fromDB o)

    ok = (_.isEqual db, { a: 1, z_x: 1 })

    (assert ok)
    return