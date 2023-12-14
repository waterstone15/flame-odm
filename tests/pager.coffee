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



describe 'Pager ––', ->


  it 'A pager works with: { cursor, page-end, sort-backward, collection-end }', ->
    #  a b bb bb bb bb bb bb c d e f g h i j k l m n o p q r s t u v w x y z
    # [↑ • •  •]
    ok = false

    pager = (new Pager [
      [ 'order-by', 'letter', 'desc' ]
      [ 'order-by', 'id', 'desc' ]
    ], { size: 4 })
    pageF = [ 'id', 'letter' ]

    cursor =
      obj:
        id: 'MKDH6H3F6Hgoy0XDEcaqyHyoGpLByFyscaau'
        letter: 'a'
      position: 'page-end'

    page = await (m.page pager, cursor, pageF)

    ok = (_.isEqual page, {
      counts: { total: 32, before: 28, page: 4, after: 0 },
      collection: {
        first: { letter: 'z', id: 'o0YoqRCCdLthRDJKeDAWeh4sj73wARrPJI1e' },
        last: { letter: 'a', id: 'MKDH6H3F6Hgoy0XDEcaqyHyoGpLByFyscaau' }
      },
      page: {
        first: { letter: 'bb', id: 'MWIHYugi4831wfopB8sFYAqN4bRtQKkwKtbi' },
        items: [
          { letter: 'bb', id: 'MWIHYugi4831wfopB8sFYAqN4bRtQKkwKtbi' },
          { letter: 'bb', id: 'KKGzo1w6jOEZD7gJnSM7bf67YZNgjZswI7kC' },
          { letter: 'b', id: 'wDkfSyhjsfHOioEAwKFJuHpCgaoJuNGveVUw' },
          { letter: 'a', id: 'MKDH6H3F6Hgoy0XDEcaqyHyoGpLByFyscaau' }
        ],
        last: { letter: 'a', id: 'MKDH6H3F6Hgoy0XDEcaqyHyoGpLByFyscaau' }
      },
      cursors: {
        previous: {
          obj: { letter: 'bb', id: 'NWcCrV7NVAynl4llq0B2jmO5xyOXPFhpcM43' },
          position: 'page-end'
        },
        current: {
          obj: { id: 'MKDH6H3F6Hgoy0XDEcaqyHyoGpLByFyscaau', letter: 'a' },
          position: 'page-end'
        },
        next: null
      }
    })
    (assert ok)
    return


  it 'A pager works with: { cursor, page-end, sort-forward, collection-end }', ->
    #  a b bb bb bb bb bb bb c d e f g h i j k l m n o p q r s t u v w x y z
    #                                                               [• • • ↑]
    ok = false

    pager = (new Pager [
      [ 'order-by', 'letter', 'asc' ]
      [ 'order-by', 'id', 'asc' ]
    ], { size: 4 })
    pageF = [ 'id', 'letter' ]

    cursor =
      obj:
        id: 'o0YoqRCCdLthRDJKeDAWeh4sj73wARrPJI1e'
        letter: 'z'
      position: 'page-end'

    page = await (m.page pager, cursor, pageF)

    ok = (_.isEqual page, {
      counts: { total: 32, before: 28, page: 4, after: 0 },
      collection: {
        first: { letter: 'a', id: 'MKDH6H3F6Hgoy0XDEcaqyHyoGpLByFyscaau' },
        last: { letter: 'z', id: 'o0YoqRCCdLthRDJKeDAWeh4sj73wARrPJI1e' }
      },
      page: {
        first: { letter: 'w', id: 'OTky4UD4lDRVveitndnAGdJ2fMZZLoaeBcvm' },
        items: [
          { letter: 'w', id: 'OTky4UD4lDRVveitndnAGdJ2fMZZLoaeBcvm' },
          { letter: 'x', id: 'KSoTvpfy4b4RiSkZR6HHCbIpEh2694CWVj88' },
          { letter: 'y', id: 'ByMADK8aTXV6p0Tb7P7yeP75Ytfw6Ee13F42' },
          { letter: 'z', id: 'o0YoqRCCdLthRDJKeDAWeh4sj73wARrPJI1e' }
        ],
        last: { letter: 'z', id: 'o0YoqRCCdLthRDJKeDAWeh4sj73wARrPJI1e' }
      },
      cursors: {
        previous: {
          obj: { letter: 'v', id: 'NjtJLQkzhWvxL0X1ZK30L7boAkPT8JfbgS9V' },
          position: 'page-end'
        },
        current: {
          obj: { id: 'o0YoqRCCdLthRDJKeDAWeh4sj73wARrPJI1e', letter: 'z' },
          position: 'page-end'
        },
        next: null
      }
    })
    (assert ok)
    return


  it 'A pager works with: { cursor, page-end, sort-backward, collection-middle }', ->
    #  a b bb bb bb bb bb bb c d e f g h i j k l m n o p q r s t u v w x y z
    #                         [↑ • • •]
    ok = false

    pager = (new Pager [
      [ 'order-by', 'letter', 'desc' ]
      [ 'order-by', 'id', 'desc' ]
    ], { size: 4 })
    pageF = [ 'id', 'letter' ]

    cursor =
      obj:
        id: 'UmUtFhxtEqOO84QQ3v1whwpVMzXVIykHILYT'
        letter: 'd'
      position: 'page-end'

    page = await (m.page pager, cursor, pageF)

    ok = (_.isEqual page, {
      counts: { total: 32, before: 19, page: 4, after: 9 },
      collection: {
        first: { letter: 'z', id: 'o0YoqRCCdLthRDJKeDAWeh4sj73wARrPJI1e' },
        last: { letter: 'a', id: 'MKDH6H3F6Hgoy0XDEcaqyHyoGpLByFyscaau' }
      },
      page: {
        first: { letter: 'g', id: 'kanbCB4IkwpQeQEarsNMPetyzOX1BLNCBw3N' },
        items: [
          { letter: 'g', id: 'kanbCB4IkwpQeQEarsNMPetyzOX1BLNCBw3N' },
          { letter: 'f', id: '1VdSKkb3hkOgoprlOj6szfgexvw6uUu8vQ1J' },
          { letter: 'e', id: 'GGIueJeC8l3WKNGUv3RTtj6ouq6eQRvk0Y9q' },
          { letter: 'd', id: 'UmUtFhxtEqOO84QQ3v1whwpVMzXVIykHILYT' }
        ],
        last: { letter: 'd', id: 'UmUtFhxtEqOO84QQ3v1whwpVMzXVIykHILYT' }
      },
      cursors: {
        previous: {
          obj: { letter: 'h', id: 'bPGgxSvwu3sy1GyXNO9emCHA6q18MJKkyQnf' },
          position: 'page-end'
        },
        current: {
          obj: { id: 'UmUtFhxtEqOO84QQ3v1whwpVMzXVIykHILYT', letter: 'd' },
          position: 'page-end'
        },
        next: {
          obj: { letter: 'c', id: 'jz767qpjrQfp3P0woshpvYIQnX4yXIGhuTn7' },
          position: 'page-start'
        }
      }
    })
    (assert ok)
    return


  it 'A pager works with: { cursor, page-end, sort-forward, collection-middle }', ->
    #  a b bb bb bb bb bb bb c d e f g h i j k l m n o p q r s t u v w x y z
    #                 [•  •  • ↑]
    ok = false

    pager = (new Pager [
      [ 'order-by', 'letter', 'asc' ]
      [ 'order-by', 'id', 'asc' ]
    ], { size: 4 })
    pageF = [ 'id', 'letter' ]

    cursor =
      obj:
        id: 'UmUtFhxtEqOO84QQ3v1whwpVMzXVIykHILYT'
        letter: 'd'
      position: 'page-end'

    page = await (m.page pager, cursor, pageF)

    ok = (_.isEqual page, {
      counts: { total: 32, before: 6, page: 4, after: 22 },
      collection: {
        first: { letter: 'a', id: 'MKDH6H3F6Hgoy0XDEcaqyHyoGpLByFyscaau' },
        last: { letter: 'z', id: 'o0YoqRCCdLthRDJKeDAWeh4sj73wARrPJI1e' }
      },
      page: {
        first: { letter: 'bb', id: 'r5rbl9qSRK5iqjE19UOuNkCtDqvhOo5tYQe8' },
        items: [
          { letter: 'bb', id: 'r5rbl9qSRK5iqjE19UOuNkCtDqvhOo5tYQe8' },
          { letter: 'bb', id: 'z82lZRa9a0vPjD9CNllvdE24AMzicOOvp2r9' },
          { letter: 'c', id: 'jz767qpjrQfp3P0woshpvYIQnX4yXIGhuTn7' },
          { letter: 'd', id: 'UmUtFhxtEqOO84QQ3v1whwpVMzXVIykHILYT' }
        ],
        last: { letter: 'd', id: 'UmUtFhxtEqOO84QQ3v1whwpVMzXVIykHILYT' }
      },
      cursors: {
        previous: {
          obj: { letter: 'bb', id: 'dizEnbMrIiTm3oxZq3Lu9mFTZVFLAPVaZJva' },
          position: 'page-end'
        },
        current: {
          obj: { id: 'UmUtFhxtEqOO84QQ3v1whwpVMzXVIykHILYT', letter: 'd' },
          position: 'page-end'
        },
        next: {
          obj: { letter: 'e', id: 'GGIueJeC8l3WKNGUv3RTtj6ouq6eQRvk0Y9q' },
          position: 'page-start'
        }
      }
    })
    (assert ok)
    return


  it 'A pager works with: { cursor, page-end, sort-backward, collection-start }', ->
    #  a b bb bb bb bb bb bb c d e f g h i j k l m n o p q r s t u v w x y z
    #                                                                 [↑ • •]
    ok = false

    pager = (new Pager [
      [ 'order-by', 'letter', 'desc' ]
      [ 'order-by', 'id', 'desc' ]
    ], { size: 4 })
    pageF = [ 'id', 'letter' ]

    cursor =
      obj:
        id: 'KSoTvpfy4b4RiSkZR6HHCbIpEh2694CWVj88'
        letter: 'x'
      position: 'page-end'

    page = await (m.page pager, cursor, pageF)

    ok = (_.isEqual page, {
      counts: { total: 32, before: 0, page: 3, after: 29 },
      collection: {
        first: { letter: 'z', id: 'o0YoqRCCdLthRDJKeDAWeh4sj73wARrPJI1e' },
        last: { letter: 'a', id: 'MKDH6H3F6Hgoy0XDEcaqyHyoGpLByFyscaau' }
      },
      page: {
        first: { letter: 'z', id: 'o0YoqRCCdLthRDJKeDAWeh4sj73wARrPJI1e' },
        items: [
          { letter: 'z', id: 'o0YoqRCCdLthRDJKeDAWeh4sj73wARrPJI1e' },
          { letter: 'y', id: 'ByMADK8aTXV6p0Tb7P7yeP75Ytfw6Ee13F42' },
          { letter: 'x', id: 'KSoTvpfy4b4RiSkZR6HHCbIpEh2694CWVj88' }
        ],
        last: { letter: 'x', id: 'KSoTvpfy4b4RiSkZR6HHCbIpEh2694CWVj88' }
      },
      cursors: {
        previous: null,
        current: {
          obj: { id: 'KSoTvpfy4b4RiSkZR6HHCbIpEh2694CWVj88', letter: 'x' },
          position: 'page-end'
        },
        next: {
          obj: { letter: 'w', id: 'OTky4UD4lDRVveitndnAGdJ2fMZZLoaeBcvm' },
          position: 'page-start'
        }
      }
    })
    (assert ok)
    return


  it 'A pager works with: { cursor, page-end, sort-forward, collection-start }', ->
    #  a b bb bb bb bb bb bb c d e f g h i j k l m n o p q r s t u v w x y z
    # [• • ↑]
    ok = false

    pager = (new Pager [
      [ 'order-by', 'letter', 'asc' ]
      [ 'order-by', 'id', 'asc' ]
    ], { size: 4 })
    pageF = [ 'id', 'letter' ]

    cursor =
      obj:
        id: 'KKGzo1w6jOEZD7gJnSM7bf67YZNgjZswI7kC'
        letter: 'bb'
      position: 'page-end'

    page = await (m.page pager, cursor, pageF)

    ok = (_.isEqual page, {
      counts: { total: 32, before: 0, page: 3, after: 29 },
      collection: {
        first: { letter: 'a', id: 'MKDH6H3F6Hgoy0XDEcaqyHyoGpLByFyscaau' },
        last: { letter: 'z', id: 'o0YoqRCCdLthRDJKeDAWeh4sj73wARrPJI1e' }
      },
      page: {
        first: { letter: 'a', id: 'MKDH6H3F6Hgoy0XDEcaqyHyoGpLByFyscaau' },
        items: [
          { letter: 'a', id: 'MKDH6H3F6Hgoy0XDEcaqyHyoGpLByFyscaau' },
          { letter: 'b', id: 'wDkfSyhjsfHOioEAwKFJuHpCgaoJuNGveVUw' },
          { letter: 'bb', id: 'KKGzo1w6jOEZD7gJnSM7bf67YZNgjZswI7kC' }
        ],
        last: { letter: 'bb', id: 'KKGzo1w6jOEZD7gJnSM7bf67YZNgjZswI7kC' }
      },
      cursors: {
        previous: null,
        current: {
          obj: { id: 'KKGzo1w6jOEZD7gJnSM7bf67YZNgjZswI7kC', letter: 'bb' },
          position: 'page-end'
        },
        next: {
          obj: { letter: 'bb', id: 'MWIHYugi4831wfopB8sFYAqN4bRtQKkwKtbi' },
          position: 'page-start'
        }
      }
    })
    (assert ok)
    return


  it 'A pager works with: { cursor, page-start, sort-backward, collection-end }', ->
    #  a b bb bb bb bb bb bb c d e f g h i j k l m n o p q r s t u v w x y z
    # [• • ↑]
    ok = false

    pager = (new Pager [
      [ 'order-by', 'letter', 'desc' ]
      [ 'order-by', 'id', 'desc' ]
    ], { size: 4 })
    pageF = [ 'id', 'letter' ]

    cursor =
      obj:
        id: 'KKGzo1w6jOEZD7gJnSM7bf67YZNgjZswI7kC'
        letter: 'bb'
      position: 'page-start'

    page = await (m.page pager, cursor, pageF)

    ok = (_.isEqual page, {
      counts: { total: 32, before: 29, page: 3, after: 0 },
      collection: {
        first: { letter: 'z', id: 'o0YoqRCCdLthRDJKeDAWeh4sj73wARrPJI1e' },
        last: { letter: 'a', id: 'MKDH6H3F6Hgoy0XDEcaqyHyoGpLByFyscaau' }
      },
      page: {
        first: { letter: 'bb', id: 'KKGzo1w6jOEZD7gJnSM7bf67YZNgjZswI7kC' },
        items: [
          { letter: 'bb', id: 'KKGzo1w6jOEZD7gJnSM7bf67YZNgjZswI7kC' },
          { letter: 'b', id: 'wDkfSyhjsfHOioEAwKFJuHpCgaoJuNGveVUw' },
          { letter: 'a', id: 'MKDH6H3F6Hgoy0XDEcaqyHyoGpLByFyscaau' }
        ],
        last: { letter: 'a', id: 'MKDH6H3F6Hgoy0XDEcaqyHyoGpLByFyscaau' }
      },
      cursors: {
        previous: {
          obj: { letter: 'bb', id: 'MWIHYugi4831wfopB8sFYAqN4bRtQKkwKtbi' },
          position: 'page-end'
        },
        current: {
          obj: { id: 'KKGzo1w6jOEZD7gJnSM7bf67YZNgjZswI7kC', letter: 'bb' },
          position: 'page-start'
        },
        next: null
      }
    })
    (assert ok)
    return


  it 'A pager works with: { cursor, page-start, sort-forward, collection-end }', ->
    #  a b bb bb bb bb bb bb c d e f g h i j k l m n o p q r s t u v w x y z
    #                                                                 [↑ • •]
    ok = false

    pager = (new Pager [
      [ 'order-by', 'letter', 'asc' ]
      [ 'order-by', 'id', 'asc' ]
    ], { size: 4 })
    pageF = [ 'id', 'letter' ]

    cursor =
      obj:
        id: 'KSoTvpfy4b4RiSkZR6HHCbIpEh2694CWVj88'
        letter: 'x'
      position: 'page-start'

    page = await (m.page pager, cursor, pageF)

    ok = (_.isEqual page, {
      counts: { total: 32, before: 29, page: 3, after: 0 },
      collection: {
        first: { letter: 'a', id: 'MKDH6H3F6Hgoy0XDEcaqyHyoGpLByFyscaau' },
        last: { letter: 'z', id: 'o0YoqRCCdLthRDJKeDAWeh4sj73wARrPJI1e' }
      },
      page: {
        first: { letter: 'x', id: 'KSoTvpfy4b4RiSkZR6HHCbIpEh2694CWVj88' },
        items: [
          { letter: 'x', id: 'KSoTvpfy4b4RiSkZR6HHCbIpEh2694CWVj88' },
          { letter: 'y', id: 'ByMADK8aTXV6p0Tb7P7yeP75Ytfw6Ee13F42' },
          { letter: 'z', id: 'o0YoqRCCdLthRDJKeDAWeh4sj73wARrPJI1e' }
        ],
        last: { letter: 'z', id: 'o0YoqRCCdLthRDJKeDAWeh4sj73wARrPJI1e' }
      },
      cursors: {
        previous: {
          obj: { letter: 'w', id: 'OTky4UD4lDRVveitndnAGdJ2fMZZLoaeBcvm' },
          position: 'page-end'
        },
        current: {
          obj: { id: 'KSoTvpfy4b4RiSkZR6HHCbIpEh2694CWVj88', letter: 'x' },
          position: 'page-start'
        },
        next: null
      }
    })
    (assert ok)
    return


  it 'A pager works with: { cursor, page-start, sort-backward, collection-middle }', ->
    #  a b bb bb bb bb bb bb c d e f g h i j k l m n o p q r s t u v w x y z
    #                 [•  •  • ↑]
    ok = false

    pager = (new Pager [
      [ 'order-by', 'letter', 'desc' ]
      [ 'order-by', 'id', 'desc' ]
    ], { size: 4 })
    pageF = [ 'id', 'letter' ]

    cursor =
      obj:
        id: 'UmUtFhxtEqOO84QQ3v1whwpVMzXVIykHILYT'
        letter: 'd'
      position: 'page-start'

    page = await (m.page pager, cursor, pageF)

    ok = (_.isEqual page, {
      counts: { total: 32, before: 22, page: 4, after: 6 },
      collection: {
        first: { letter: 'z', id: 'o0YoqRCCdLthRDJKeDAWeh4sj73wARrPJI1e' },
        last: { letter: 'a', id: 'MKDH6H3F6Hgoy0XDEcaqyHyoGpLByFyscaau' }
      },
      page: {
        first: { letter: 'd', id: 'UmUtFhxtEqOO84QQ3v1whwpVMzXVIykHILYT' },
        items: [
          { letter: 'd', id: 'UmUtFhxtEqOO84QQ3v1whwpVMzXVIykHILYT' },
          { letter: 'c', id: 'jz767qpjrQfp3P0woshpvYIQnX4yXIGhuTn7' },
          { letter: 'bb', id: 'z82lZRa9a0vPjD9CNllvdE24AMzicOOvp2r9' },
          { letter: 'bb', id: 'r5rbl9qSRK5iqjE19UOuNkCtDqvhOo5tYQe8' }
        ],
        last: { letter: 'bb', id: 'r5rbl9qSRK5iqjE19UOuNkCtDqvhOo5tYQe8' }
      },
      cursors: {
        previous: {
          obj: { letter: 'e', id: 'GGIueJeC8l3WKNGUv3RTtj6ouq6eQRvk0Y9q' },
          position: 'page-end'
        },
        current: {
          obj: { id: 'UmUtFhxtEqOO84QQ3v1whwpVMzXVIykHILYT', letter: 'd' },
          position: 'page-start'
        },
        next: {
          obj: { letter: 'bb', id: 'dizEnbMrIiTm3oxZq3Lu9mFTZVFLAPVaZJva' },
          position: 'page-start'
        }
      }
    })
    (assert ok)
    return


  it 'A pager works with: { cursor, page-start, sort-forward, collection-middle }', ->
    #  a b bb bb bb bb bb bb c d e f g h i j k l m n o p q r s t u v w x y z
    #                 [↑  •  • •]
    ok = false

    pager = (new Pager [
      [ 'order-by', 'letter', 'asc' ]
      [ 'order-by', 'id', 'asc' ]
    ], { size: 4 })
    pageF = [ 'id', 'letter' ]

    cursor =
      obj:
        id: 'r5rbl9qSRK5iqjE19UOuNkCtDqvhOo5tYQe8'
        letter: 'bb'
      position: 'page-start'

    page = await (m.page pager, cursor, pageF)

    ok = (_.isEqual page, {
      counts: { total: 32, before: 6, page: 4, after: 22 },
      collection: {
        first: { letter: 'a', id: 'MKDH6H3F6Hgoy0XDEcaqyHyoGpLByFyscaau' },
        last: { letter: 'z', id: 'o0YoqRCCdLthRDJKeDAWeh4sj73wARrPJI1e' }
      },
      page: {
        first: { letter: 'bb', id: 'r5rbl9qSRK5iqjE19UOuNkCtDqvhOo5tYQe8' },
        items: [
          { letter: 'bb', id: 'r5rbl9qSRK5iqjE19UOuNkCtDqvhOo5tYQe8' },
          { letter: 'bb', id: 'z82lZRa9a0vPjD9CNllvdE24AMzicOOvp2r9' },
          { letter: 'c', id: 'jz767qpjrQfp3P0woshpvYIQnX4yXIGhuTn7' },
          { letter: 'd', id: 'UmUtFhxtEqOO84QQ3v1whwpVMzXVIykHILYT' }
        ],
        last: { letter: 'd', id: 'UmUtFhxtEqOO84QQ3v1whwpVMzXVIykHILYT' }
      },
      cursors: {
        previous: {
          obj: { letter: 'bb', id: 'dizEnbMrIiTm3oxZq3Lu9mFTZVFLAPVaZJva' },
          position: 'page-end'
        },
        current: {
          obj: { id: 'r5rbl9qSRK5iqjE19UOuNkCtDqvhOo5tYQe8', letter: 'bb' },
          position: 'page-start'
        },
        next: {
          obj: { letter: 'e', id: 'GGIueJeC8l3WKNGUv3RTtj6ouq6eQRvk0Y9q' },
          position: 'page-start'
        }
      }
    })
    (assert ok)
    return


  it 'A pager works with: { cursor, page-start, sort-backward, collection-start }', ->
    #  a b bb bb bb bb bb bb c d e f g h i j k l m n o p q r s t u v w x y z
    #                                                               [• • • ↑]
    ok = false

    pager = (new Pager [
      [ 'order-by', 'letter', 'desc' ]
      [ 'order-by', 'id', 'desc' ]
    ], { size: 4 })
    pageF = [ 'id', 'letter' ]

    cursor =
      obj:
        id: 'o0YoqRCCdLthRDJKeDAWeh4sj73wARrPJI1e'
        letter: 'z'
      position: 'page-start'

    page = await (m.page pager, cursor, pageF)

    ok = (_.isEqual page, {
      counts: { total: 32, before: 0, page: 4, after: 28 },
      collection: {
        first: { letter: 'z', id: 'o0YoqRCCdLthRDJKeDAWeh4sj73wARrPJI1e' },
        last: { letter: 'a', id: 'MKDH6H3F6Hgoy0XDEcaqyHyoGpLByFyscaau' }
      },
      page: {
        first: { letter: 'z', id: 'o0YoqRCCdLthRDJKeDAWeh4sj73wARrPJI1e' },
        items: [
          { letter: 'z', id: 'o0YoqRCCdLthRDJKeDAWeh4sj73wARrPJI1e' },
          { letter: 'y', id: 'ByMADK8aTXV6p0Tb7P7yeP75Ytfw6Ee13F42' },
          { letter: 'x', id: 'KSoTvpfy4b4RiSkZR6HHCbIpEh2694CWVj88' },
          { letter: 'w', id: 'OTky4UD4lDRVveitndnAGdJ2fMZZLoaeBcvm' }
        ],
        last: { letter: 'w', id: 'OTky4UD4lDRVveitndnAGdJ2fMZZLoaeBcvm' }
      },
      cursors: {
        previous: null,
        current: {
          obj: { id: 'o0YoqRCCdLthRDJKeDAWeh4sj73wARrPJI1e', letter: 'z' },
          position: 'page-start'
        },
        next: {
          obj: { letter: 'v', id: 'NjtJLQkzhWvxL0X1ZK30L7boAkPT8JfbgS9V' },
          position: 'page-start'
        }
      }
    })
    (assert ok)
    return


  it 'A pager works with: { cursor, page-start, sort-forward, collection-start }', ->
    #  a b bb bb bb bb bb bb c d e f g h i j k l m n o p q r s t u v w x y z
    # [↑ • •  •]
    ok = false

    pager = (new Pager [
      [ 'order-by', 'letter', 'asc' ]
      [ 'order-by', 'id', 'asc' ]
    ], { size: 4 })
    pageF = [ 'id', 'letter' ]

    cursor =
      obj:
        id: 'MKDH6H3F6Hgoy0XDEcaqyHyoGpLByFyscaau'
        letter: 'a'
      position: 'page-start'

    page = await (m.page pager, cursor, pageF)

    ok = (_.isEqual page, {
      counts: { total: 32, before: 0, page: 4, after: 28 },
      collection: {
        first: { letter: 'a', id: 'MKDH6H3F6Hgoy0XDEcaqyHyoGpLByFyscaau' },
        last: { letter: 'z', id: 'o0YoqRCCdLthRDJKeDAWeh4sj73wARrPJI1e' }
      },
      page: {
        first: { letter: 'a', id: 'MKDH6H3F6Hgoy0XDEcaqyHyoGpLByFyscaau' },
        items: [
          { letter: 'a', id: 'MKDH6H3F6Hgoy0XDEcaqyHyoGpLByFyscaau' },
          { letter: 'b', id: 'wDkfSyhjsfHOioEAwKFJuHpCgaoJuNGveVUw' },
          { letter: 'bb', id: 'KKGzo1w6jOEZD7gJnSM7bf67YZNgjZswI7kC' },
          { letter: 'bb', id: 'MWIHYugi4831wfopB8sFYAqN4bRtQKkwKtbi' }
        ],
        last: { letter: 'bb', id: 'MWIHYugi4831wfopB8sFYAqN4bRtQKkwKtbi' }
      },
      cursors: {
        previous: null,
        current: {
          obj: { id: 'MKDH6H3F6Hgoy0XDEcaqyHyoGpLByFyscaau', letter: 'a' },
          position: 'page-start'
        },
        next: {
          obj: { letter: 'bb', id: 'NWcCrV7NVAynl4llq0B2jmO5xyOXPFhpcM43' },
          position: 'page-start'
        }
      }
    })
    (assert ok)
    return


  it 'A pager works with: { no-cursor, backward }', ->
    #  a b bb bb bb bb bb bb c d e f g h i j k l m n o p q r s t u v w x y z
    #                                                               [• • • ↑]
    ok = false

    pager = (new Pager [
      [ 'order-by', 'letter', 'desc' ]
      [ 'order-by', 'id', 'desc' ]
    ], { size: 4 })
    pageF = [ 'id', 'letter' ]

    page = await (m.page pager, null, pageF)

    ok = (_.isEqual page, {
      counts: { total: 32, before: 0, page: 4, after: 28 },
      collection: {
        first: { letter: 'z', id: 'o0YoqRCCdLthRDJKeDAWeh4sj73wARrPJI1e' },
        last: { letter: 'a', id: 'MKDH6H3F6Hgoy0XDEcaqyHyoGpLByFyscaau' }
      },
      page: {
        first: { letter: 'z', id: 'o0YoqRCCdLthRDJKeDAWeh4sj73wARrPJI1e' },
        items: [
          { letter: 'z', id: 'o0YoqRCCdLthRDJKeDAWeh4sj73wARrPJI1e' },
          { letter: 'y', id: 'ByMADK8aTXV6p0Tb7P7yeP75Ytfw6Ee13F42' },
          { letter: 'x', id: 'KSoTvpfy4b4RiSkZR6HHCbIpEh2694CWVj88' },
          { letter: 'w', id: 'OTky4UD4lDRVveitndnAGdJ2fMZZLoaeBcvm' }
        ],
        last: { letter: 'w', id: 'OTky4UD4lDRVveitndnAGdJ2fMZZLoaeBcvm' }
      },
      cursors: {
        previous: null,
        current: null,
        next: {
          obj: { letter: 'v', id: 'NjtJLQkzhWvxL0X1ZK30L7boAkPT8JfbgS9V' },
          position: 'page-start'
        }
      }
    })
    (assert ok)
    return


  it 'A pager works with: { no-cursor, forward }', ->
    #  a b bb bb bb bb bb bb c d e f g h i j k l m n o p q r s t u v w x y z
    # [↑ • •  •]
    ok = false

    pager = (new Pager [
      [ 'order-by', 'letter', 'asc' ]
      [ 'order-by', 'id', 'asc' ]
    ], { size: 4 })
    pageF = [ 'id', 'letter' ]

    page = await (m.page pager, null, pageF)

    ok = (_.isEqual page, {
      counts: { total: 32, before: 0, page: 4, after: 28 },
      collection: {
        first: { letter: 'a', id: 'MKDH6H3F6Hgoy0XDEcaqyHyoGpLByFyscaau' },
        last: { letter: 'z', id: 'o0YoqRCCdLthRDJKeDAWeh4sj73wARrPJI1e' }
      },
      page: {
        first: { letter: 'a', id: 'MKDH6H3F6Hgoy0XDEcaqyHyoGpLByFyscaau' },
        items: [
          { letter: 'a', id: 'MKDH6H3F6Hgoy0XDEcaqyHyoGpLByFyscaau' },
          { letter: 'b', id: 'wDkfSyhjsfHOioEAwKFJuHpCgaoJuNGveVUw' },
          { letter: 'bb', id: 'KKGzo1w6jOEZD7gJnSM7bf67YZNgjZswI7kC' },
          { letter: 'bb', id: 'MWIHYugi4831wfopB8sFYAqN4bRtQKkwKtbi' }
        ],
        last: { letter: 'bb', id: 'MWIHYugi4831wfopB8sFYAqN4bRtQKkwKtbi' }
      },
      cursors: {
        previous: null,
        current: null,
        next: {
          obj: { letter: 'bb', id: 'NWcCrV7NVAynl4llq0B2jmO5xyOXPFhpcM43' },
          position: 'page-start'
        }
      }
    })
    (assert ok)
    return