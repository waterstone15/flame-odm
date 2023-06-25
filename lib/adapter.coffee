FBA_APP       = require 'firebase-admin/app'
FBA_FIRESTORE = require 'firebase-admin/firestore'

isFunction    = require 'lodash/isFunction'
isInteger     = require 'lodash/isInteger'
isEmpty       = require 'lodash/isEmpty'
map           = require 'lodash/map'
pick          = require 'lodash/pick'

class Adapter


  type: 'Adapter'


  constructor: (sa) ->
    @.connection = (=>
      try
        @.fba = (FBA_APP.getApp 'flame-odm')
        @.db  = (FBA_FIRESTORE.getFirestore @.fba)
        return
      catch e
        (do ->)

      if !sa
        sa = (JSON.parse process.env.SERVICE_ACCOUNT)

      if (isFunction sa)
        sa = await sa()

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
    )()
    return


  count: (model, query) ->
    await @.connection
    cr  = (@.db.collection "#{model.collection}")
    fbq = (query.prepare cr)
    try
      count = await fbq.count().get()
      if (isInteger count?.data?().count)
        return count.data().count
    catch err
      console.log err
      (do ->)
    return null


  del: (model, id, transaction) ->
    await @.connection


  find: (model, query, fields = null, transaction) ->
    await @.connection


  get: (model, id, fields = null, transaction = null) ->
    await @.connection
    dr = (@.db.doc "#{model.collection}/#{id}")
    if transaction
      ds = await transaction.get()
      if ds.exists
        return (model.serializer.fromDB ds.data())
      return null
    else
      try
        ds = await dr.get()
        if ds.exists
          return (model.serializer.fromDB ds.data())
      catch err
        console.log err
        (do ->)
    return null


  getAll: (model, ids, fields = null) ->
    await @.connection
    drs = (map ids, ((id) => (@.db.doc "#{model.collection}/#{id}")))
    dss = await (@.db.getAll drs...)
    if !(isEmpty dss)
      return (map dss, ((ds) -> (model.serializer.fromDB ds.data())))
    return null


  list: (model, query, fields = null, transaction = null) ->
    await @.connection
    cr  = (@.db.collection "#{model.collection}")
    fbq = (query.prepare cr)
    (fbq.select ...fields) if fields
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


  page: (model, query, fields = null, transaction) ->
    await @.connection


  save: (record, transaction = null) ->
    await @.connection
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
    await @.connection
    try
      return await (@.db.runTransaction ((t) -> await (fn t)))
    catch err
      console.log err
      return null


  update: (record, fields = [], transaction = null) ->
    await @.connection
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


  walk: (model, query, opts, fn) ->
    await @.connection


module.exports = Adapter
