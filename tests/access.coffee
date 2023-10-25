ma = require 'module-alias'
(ma.addAlias '@flame-odm', __dirname + '../../')

chai   = require 'chai'
assert = chai.assert

Access = require '@flame-odm/lib/access'

_ = require 'lodash'


describe 'Access --', ->

  it 'An Access can be created.', ->
    ok = false
    
    m =
      hello: [ 'a' ]
      global:
        world: [ 'a', 'b', 'c' ]
      thing:
        one: [ 'c' ]

    try
      a = (new Access m)
      ok = true
    catch
      _.noop()

    (assert ok)
    return

  it 'An Access can be used to screen an object by role.', ->
    ok = false

    m =
      a: [ 'a' ]
      b: { c: [ 'a', 'b', 'c' ]}
      d: { e: [ 'c' ]}

    a = (new Access m)

    obj =
      a: 1
      b: { c: 2 }
      d: { e: 3 }

    o = (a.screen obj, [ 'a' ])

    ok = (_.isEqual o, { a: 1, b: { c: 2 }})

    (assert ok)
    return

  it 'An Access can be used to generate a list of fields a role can access.', ->
    ok = false

    m =
      a: [ 'a' ]
      b: { c: [ 'a', 'b', 'c' ]}
      d: { e: [ 'c' ]}

    a = (new Access m)

    o = (a.fields [ 'c' ])

    ok = (_.isEqual o, [ 'b.c', 'd.e' ])

    (assert ok)
    return

