ma = require 'module-alias'
(ma.addAlias '@flame-odm', __dirname + '../../')

chai   = require 'chai'
assert = chai.assert

Validator = require '@flame-odm/lib/validator'

_ = require 'lodash'


describe 'Validator --', ->

  it 'A Validator can be constructed with an object (flat).', ->
    ok = false
    
    vs = { hello: (v, o) -> false }

    try
      v = (new Validator vs)
      ok = true
    catch e
      _.noop()

    (assert ok)
    return

  it 'A Validator can be constructed with an object (deep).', ->
    ok = false
    
    vs = { world: { hello: (v, o) -> false }}

    try
      v = (new Validator vs)
      ok = true
    catch e
      _.noop()

    (assert ok)
    return
  
  it 'A Validator can not be constructed with bad functions (flat).', ->
    ok = false
    
    vs = { hello: (v) -> false }

    try
      v = (new Validator vs)
    catch e
      ok = true

    (assert ok)
    return

  it 'A Validator can not be constructed with bad functions (deep).', ->
    ok = false
    
    vs = { globe: { hello: (v) -> false }}

    try
      v = (new Validator vs)
    catch e
      ok = true

    (assert ok)
    return

  it 'A Validator can be used to validate an object (flat).', ->
    ok = false
    
    vs = { hello: (v, o) -> v == 'world' }

    v = (new Validator vs)
    ok = (v.ok { hello: 'world' })

    (assert ok)
    return

  it 'A Validator can be used to invalidate an object (flat).', ->
    ok = false
    
    vs = { hello: (v, o) -> v == 'world' }

    v = (new Validator vs)
    ok = !(v.ok { hello: 'globe' })

    (assert ok)
    return

  it 'A Validator can be used to validate an object (deep).', ->
    ok = false
    
    vs = { blue: { hello: (v, o) -> v == 'world' }}

    v = (new Validator vs)
    ok = (v.ok { blue: { hello: 'world' }})

    (assert ok)
    return

  it 'A Validator can be used to invalidate an object (deep).', ->
    ok = false
    
    vs = { blue: { hello: (v, o) -> v == 'world' }}

    v = (new Validator vs)
    ok = !(v.ok { blue: { hello: 'globe' }})

    (assert ok)
    return

  it 'A Validator can be used to enumerate invalid values in an object (flat).', ->
    ok = false
    
    vs =
      hello:  (v, o) -> v == 'world'
      hello2: (v, o) -> v == 'world2'

    v = (new Validator vs)
    errors = (v.errors { hello: 'globe', hello2: 'globe' })
    
    ok = (_.isEqual errors, { 'hello': true, 'hello2': true })

    (assert ok)
    return

  it 'A Validator can be used to enumerate invalid values in an object (deep).', ->
    ok = false
    
    vs = { blue: { hello: (v, o) -> v == 'world' }}

    v = (new Validator vs)
    errors = (v.errors { blue: { hello: 'globe' }})
    
    ok = (_.isEqual errors, { 'blue.hello': true })

    (assert ok)
    return
