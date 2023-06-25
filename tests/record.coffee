ma = require 'module-alias'
(ma.addAlias '@', __dirname + '../../')

chai   = require 'chai'
assert = chai.assert

Access     = require '@/lib/access'
Model      = require '@/lib/model'
Serializer = require '@/lib/serializer'
Validator  = require '@/lib/validator'

_ = require 'lodash'


describe 'Record --', ->

  it 'A Record can be validated.', ->
    ok = false

    m = (new Model 'Thing', {
      a: 1
      b: -> 2
    })

    r = (m.create { a: 2 })

    ok = r.ok()
    (assert ok)
    return

  it 'A Record can enumerate errors.', ->
    ok = false

    m = (new Model 'Thing', {
      a: 1
      b: -> 2
    })

    r = (m.create { a: 2 })

    e = r.errors()
    ok = (_.isEqual e, {})
    (assert ok)
    return

  it 'A Record with errors can be validated.', ->
    ok = false

    m = (new Model 'Thing', {
      a: 1
      b: -> 2
    })
    v = (new Validator { a: (v, o) -> false })

    r = (m.create { a: 2 }, v)

    ok = !r.ok()
    (assert ok)
    return

  it 'A Record with errors can enumerate errors.', ->
    ok = false

    m = (new Model 'Thing', {
      a: 1
      b: -> 2
    })
    v = (new Validator { a: (v, o) -> false })

    r = (m.create { a: 2 }, v)

    e = r.errors()

    ok = (_.isEqual e, { a: true })
    (assert ok)
    return

  it 'A Record with errors can be validated by field.', ->
    ok = false

    m = (new Model 'Thing', {
      a: 1
      b: -> 2
    })
    v = (new Validator {
      a: (v, o) -> false
      b: (v, o) -> false
    })

    r = (m.create { a: 2, b: 1 }, v)

    ok = !(r.ok [ 'a' ])
    (assert ok)
    return

  it 'A Record with errors can enumerate errors by field.', ->
    ok = false

    m = (new Model 'Thing', {
      a: 1
      b: -> 2
    })
    v = (new Validator {
      a: (v, o) -> false
      b: (v, o) -> false
    })

    r = (m.create { a: 2, b: 1 }, v)

    e = (r.errors [ 'a' ])

    ok = (_.isEqual e, { a: true })
    (assert ok)
    return

