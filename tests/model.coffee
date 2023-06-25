ma = require 'module-alias'
(ma.addAlias '@', __dirname + '../../')

chai   = require 'chai'
assert = chai.assert

Access     = require '@/lib/access'
Model      = require '@/lib/model'
Serializer = require '@/lib/serializer'
Validator  = require '@/lib/validator'

_ = require 'lodash'


describe 'Model --', ->

  it 'An Model can be created.', ->
    ok = false

    try
      m = (new Model 'Thing', {
        a: 1
        b: 2
      })
      ok = true
    catch m
      _.noop()

    (assert ok)
    return

  it 'An Model be converted into a plain object.', ->
    ok = false

    m = (new Model 'Thing', {
      a: 1
      b: -> 2
      c: { d: (t, d) -> d.a }
      e: (t, d) -> t
    })

    ok = (_.isEqual m.obj(), { a: 1, b: 2, c: { d: 1 }, e: 'Thing' })
    (assert ok)
    return

  it 'An Model can be extended.', ->
    ok = false

    m = (new Model 'Thing', {
      a: 1
      b: -> 2
      c: { d: (t, d) -> d.a }
      e: (t, d) -> t
    })

    m2 = (m.extend 'SubThing', { a: 2, f: 3 })

    ok = (_.isEqual m2.obj(), { a: 2, b: 2, c: { d: 2 }, e: 'SubThing' , f: 3 })
    (assert ok)
    return

  it 'A Record of a Model can be created.', ->
    ok = false

    m = (new Model 'Thing', {
      a: 1
      b: -> 2
      c: { d: (t, d) -> d.a }
      e: (t, d) -> t
    })

    r = (m.create { a: 2 })

    ok = (_.isEqual r.obj(), { a: 2, b: 2, c: { d: 2 }, e: 'Thing'})
    (assert ok)
    return


