FBA = require 'firebase-admin'
FS  = require 'firebase-admin/firestore'

class FirebaseApp

  create: (name, config) ->
    fb_cfg =
      credential: FBA.credential.cert(config.service_account)
      databaseURL: "https://#{config.project_id}.firebaseio.com"

    fba = await FBA.initializeApp(fb_cfg, name)
    db  = FS.getFirestore(fba)
    return { fba, db, FV: FS.FieldValue }

module.exports = FirebaseApp
