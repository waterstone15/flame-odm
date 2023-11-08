FBA_APP       = require 'firebase-admin/app'
FBA_FIRESTORE = require 'firebase-admin/firestore'

first         = require 'lodash/first'
isEmpty       = require 'lodash/isEmpty'
isFunction    = require 'lodash/isFunction'
isInteger     = require 'lodash/isInteger'
map           = require 'lodash/map'
pick          = require 'lodash/pick'

class Adapter


  type: 'Adapter'


  constructor: (sa) ->
    @.cfg = { sa }
    return


  connect: ->
    if @.fba && @.db
      return

    if !@.cfg.sa
      sa = (JSON.parse process.env.SERVICE_ACCOUNT)
    else if (isFunction @.cfg.sa)
      sa = await @.cfg.sa()
    else
      throw (new FlameError 'An adapter needs a service account in order to connect to Firestore.')
      return

    try
      (FBA_APP.initializeApp {
        credential: (FBA_APP.cert sa)
        databaseURL: "https://#{sa.project_id}.firebaseio.com"
      }, 'flame-odm')
    catch e
      (do ->)

    @.fba = (FBA_APP.getApp 'flame-odm')
    @.db  = (FBA_FIRESTORE.getFirestore @.fba)
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


  page: (model, pager, cursor) ->
    # direction = 'high-to-low' || 'low-to-high'
    position = 'page-start' || 'page-end'
    values = [[ 'field', 'value' ], [ 'field', 'value' ]]
    await @.connect()


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
