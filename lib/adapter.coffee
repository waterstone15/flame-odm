FBA_APP       = require 'firebase-admin/app'
FBA_FIRESTORE = require 'firebase-admin/firestore'

first         = require 'lodash/first'
get           = require 'lodash/get'
isEmpty       = require 'lodash/isEmpty'
isEqual       = require 'lodash/isEqual'
isFunction    = require 'lodash/isFunction'
isInteger     = require 'lodash/isInteger'
isPlainObject = require 'lodash/isPlainObject'
isString      = require 'lodash/isString'
last          = require 'lodash/last'
map           = require 'lodash/map'
max           = require 'lodash/max'
min           = require 'lodash/min'
pick          = require 'lodash/pick'
reverse       = require 'lodash/reverse'
{ all }       = require 'rsvp'


class Adapter


  type: 'Adapter'


  constructor: (sa) ->
    @.cfg = if (isString sa) then {} else { sa }

    @.cloud = switch
      when (isPlainObject sa)          then 'other'
      when (sa == 'firebase-function') then 'firebase-function'
      when (sa == 'google-cloud')      then 'google-cloud'
      when (sa == 'process-env')       then 'process-env'
      else
        'firebase-function'

    return


  connect: ->
    if @.fba && @.db
      return

    if @.cloud == 'firebase-function'
      try
        FBA_APP.initializeApp()
        @.fba = FBA_APP.getApp()
        @.db  = FBA_FIRESTORE.getFirestore(@.fba)
      catch e
        throw (new FlameError "There was an error connecting to Firebase. Ref: 'firebase-function'")
        console.log e
      return


    if @.cloud == 'google-cloud'
      try
        (FBA_APP.initializeApp {
          credential: FBA_APP.applicationDefault()
        })
        @.fba = FBA_APP.getApp()
        @.db  = (FBA_FIRESTORE.getFirestore @.fba)
      catch e
        throw (new FlameError "There was an error connecting to Firebase. Ref: 'google-cloud'")
        console.log e
      return


    if @.cloud == 'other' || @.cloud == 'process-env'
      if !@.cfg.sa
        sa = (JSON.parse process.env.FB_SERVICE_ACCOUNT)
      else if (isFunction @.cfg.sa)
        sa = await @.cfg.sa()
      else
        throw (new FlameError 'When not running in a Firebase Function or on Google Cloud, an adapter needs a service account in order to connect to Firestore. Please supply a valid service account.')
        return

      try
        (FBA_APP.initializeApp {
          credential: (FBA_APP.cert sa)
          databaseURL: "https://#{sa.project_id}.firebaseio.com"
        }, 'flame-odm')
        @.fba = (FBA_APP.getApp 'flame-odm')
        @.db  = (FBA_FIRESTORE.getFirestore @.fba)
      catch e
        throw (new FlameError "There was an error connecting to Firebase. Ref: 'other'")
        console.log e
      return



  count: (model, query) ->
    await @.connect()
    col_ref = (@.db.collection "#{model.collection}")
    fbq = (query.prepare col_ref, model.serializer)
    try
      count = await fbq.count().get()
      if (isInteger count?.data?().count)
        return count.data().count
    catch err
      console.log err
      (do ->)
    return null


  del: (model, id, transaction) ->
    await @.connect()


  destroy: (record, transaction = null) ->
    await @.connect()
    dr = (@.db.doc "#{record.collection}/#{record.id}")
    if transaction
      await (transaction.delete dr)
    else
      try
        await dr.delete()
      catch err
        console.log err
        return false
    return true


  find: (model, query, fields = null, transaction = null) ->
    await @.connect()
    ls = await (@.findAll model, query, fields, transaction)
    return (first ls) ? null


  get: (model, id, fields = null, transaction = null) ->
    await @.connect()
    dr = (@.db.doc "#{model.collection}/#{id}")
    if transaction
      ds = await (transaction.get dr)
      if ds.exists
        obj = (model.serializer.fromDB ds.data())
        return if fields then (pick obj, fields) else obj
      return null
    else
      try
        ds = await dr.get()
        if ds.exists
          obj = (model.serializer.fromDB ds.data())
          return if fields then (pick obj, fields) else obj
      catch err
        console.log err
        (do ->)
    return null


  getAll: (model, ids, fields = null) ->
    await @.connect()
    drs = (map ids, ((id) => (@.db.doc "#{model.collection}/#{id}")))
    dss = await (@.db.getAll drs...)
    if !(isEmpty dss)
      return (map dss, ((ds) ->
        obj = (model.serializer.fromDB ds.data())
        return if fields then (pick obj, fields) else obj
    ))
    return null


  findAll: (model, query, fields = null, transaction = null) ->
    await @.connect()
    col_ref  = (@.db.collection "#{model.collection}")
    fbq = (query.prepare col_ref, model.serializer)
    if fields
      s = model.serializer
      fs = (map fields, (f) -> (s.fmt[s.fmts.field.db] f))
      fbq = (fbq.select fs...)
    if transaction
      qs = await (transaction.get fbq)
      if !qs.empty
        return (map qs.docs, ((ds) -> (model.serializer.fromDB ds.data())))
      return null
    else
      try
        qs = await fbq.get()
        if !qs.empty
          return (map qs.docs, ((ds) -> (model.serializer.fromDB ds.data())))
      catch err
        console.log err
        (do ->)
      return null


  page: (model, pager = null, cursor = null, fields = null, transaction = null) ->
    CPEND = (get cursor, 'position') == 'page-end'

    await @.connect()
    queries = (pager.queries cursor)
    [ coll_first, coll_last, itemz, priorz, total, tail_count ] = await (all [
      (@.find    model, queries.collection, fields, transaction)
      (@.find    model, queries.reversed,   fields, transaction)
      (@.findAll model, queries.itemz,      fields, transaction)
      (@.findAll model, queries.priorz,     fields, transaction)
      (@.count model, queries.collection)
      (@.count model, queries.tail)
    ])

    pg_count = (min [ pager.size, itemz.length ])
    items    = itemz[0...pg_count]

    if CPEND
      items = (reverse items)
      [ coll_first, coll_last ] = [ coll_last, coll_first ]

    at_start = (isEqual coll_first, (first items))
    at_end   = (isEqual coll_last, (last items))

    previous = ({ obj: priorz[1], position: 'page-end' } if !at_start) ? null
    next     = ({ obj: itemz[pg_count], position: 'page-start' } if !at_end) ? null

    after  = tail_count - pg_count
    before = (total - tail_count)

    if CPEND
      [ after, before ] = [ before, after ]
      previous = ({ obj: itemz[pg_count], position: 'page-end' } if !at_start) ? null
      next     = ({ obj: priorz[1], position: 'page-start' } if !at_end) ? null

    return {
      counts:
        total:    total
        before:   before
        page:     pg_count
        after:    after
      collection:
        first:    coll_first
        last:     coll_last
      page:
        first:    (first items)
        items:    items
        last:     (last items)
      cursors:
        previous: previous
        current:  cursor
        next:     next
    }


  save: (record, transaction = null) ->
    await @.connect()
    dr = (@.db.doc "#{record.collection}/#{record.id}")
    if transaction
      await (transaction.create dr, (record.serializer.toDB record.data))
    else
      try
        await (dr.create (record.serializer.toDB record.data))
      catch err
        console.log err
        return false
    return true


  transact: (fn) ->
    await @.connect()
    try
      return await (@.db.runTransaction ((t) -> await (fn t)))
    catch err
      console.log err
      return null


  traverse: (model, query, opts, fn) ->
    await @.connect()


  update: (record, fields = [], transaction = null) ->
    await @.connect()
    dr = (@.db.doc "#{record.collection}/#{record.id}")
    if transaction
      await (transaction.update dr, (record.serializer.toDB (pick record.data, fields)))
    else
      try
        await (dr.update (record.serializer.toDB (pick record.data, fields)))
      catch err
        console.log err
        return false
    return true




module.exports = Adapter
