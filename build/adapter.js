(function() {
  var Adapter, FBA_APP, FBA_FIRESTORE, first, isEmpty, isFunction, isInteger, map, pick;

  FBA_APP = require('firebase-admin/app');

  FBA_FIRESTORE = require('firebase-admin/firestore');

  first = require('lodash/first');

  isEmpty = require('lodash/isEmpty');

  isFunction = require('lodash/isFunction');

  isInteger = require('lodash/isInteger');

  map = require('lodash/map');

  pick = require('lodash/pick');

  Adapter = (function() {
    class Adapter {
      constructor(sa) {
        this.cfg = {sa};
        return;
      }

      async connect() {
        var e, sa;
        if (this.fba && this.db) {
          return;
        }
        if (!this.cfg.sa) {
          sa = JSON.parse(process.env.SERVICE_ACCOUNT);
        } else if (isFunction(this.cfg.sa)) {
          sa = (await this.cfg.sa());
        } else {
          throw new FlameError('An adapter needs a service account in order to connect to Firestore.');
          return;
        }
        try {
          FBA_APP.initializeApp({
            credential: FBA_APP.cert(sa),
            databaseURL: `https://${sa.project_id}.firebaseio.com`
          }, 'flame-odm');
        } catch (error) {
          e = error;
          ((function() {})());
        }
        this.fba = FBA_APP.getApp('flame-odm');
        this.db = FBA_FIRESTORE.getFirestore(this.fba);
      }

      async count(model, query) {
        var col_ref, count, err, fbq;
        await this.connect();
        col_ref = this.db.collection(`${model.collection}`);
        fbq = query.prepare(col_ref, model.serializer);
        try {
          count = (await fbq.count().get());
          if (isInteger(count != null ? typeof count.data === "function" ? count.data().count : void 0 : void 0)) {
            return count.data().count;
          }
        } catch (error) {
          err = error;
          console.log(err);
          ((function() {})());
        }
        return null;
      }

      async del(model, id, transaction) {
        return (await this.connect());
      }

      async find(model, query, fields = null, transaction = null) {
        var ls, ref;
        await this.connect();
        ls = (await (this.findAll(model, query, fields, transaction)));
        return (ref = first(ls)) != null ? ref : null;
      }

      async get(model, id, fields = null, transaction = null) {
        var dr, ds, err, obj;
        await this.connect();
        dr = this.db.doc(`${model.collection}/${id}`);
        if (transaction) {
          ds = (await transaction.get());
          if (ds.exists) {
            obj = model.serializer.fromDB(ds.data());
            if (fields) {
              return pick(obj, fields);
            } else {
              return obj;
            }
          }
          return null;
        } else {
          try {
            ds = (await dr.get());
            if (ds.exists) {
              obj = model.serializer.fromDB(ds.data());
              if (fields) {
                return pick(obj, fields);
              } else {
                return obj;
              }
            }
          } catch (error) {
            err = error;
            console.log(err);
            ((function() {})());
          }
        }
        return null;
      }

      async getAll(model, ids, fields = null) {
        var drs, dss;
        await this.connect();
        drs = map(ids, ((id) => {
          return this.db.doc(`${model.collection}/${id}`);
        }));
        dss = (await (this.db.getAll(...drs)));
        if (!(isEmpty(dss))) {
          return map(dss, (function(ds) {
            var obj;
            obj = model.serializer.fromDB(ds.data());
            if (fields) {
              return pick(obj, fields);
            } else {
              return obj;
            }
          }));
        }
        return null;
      }

      async findAll(model, query, fields = null, transaction = null) {
        var col_ref, err, fbq, fs, qs, s;
        await this.connect();
        col_ref = this.db.collection(`${model.collection}`);
        fbq = query.prepare(col_ref, model.serializer);
        if (fields) {
          s = model.serializer;
          fs = map(fields, function(f) {
            return s.fmt[s.fmts.field.db](f);
          });
          fbq = fbq.select(...fs);
        }
        if (transaction) {
          qs = (await (transaction.get(fbq)));
          if (!qs.empty) {
            return map(qs.docs, (function(ds) {
              return model.serializer.fromDB(ds.data());
            }));
          }
          return null;
        } else {
          try {
            qs = (await fbq.get());
            if (!qs.empty) {
              return map(qs.docs, (function(ds) {
                return model.serializer.fromDB(ds.data());
              }));
            }
          } catch (error) {
            err = error;
            console.log(err);
            ((function() {})());
          }
          return null;
        }
      }

      async page(model, pager, cursor) {
        var position, values;
        // direction = 'high-to-low' || 'low-to-high'
        position = 'page-start' || 'page-end';
        values = [['field', 'value'], ['field', 'value']];
        return (await this.connect());
      }

      async save(record, transaction = null) {
        var dr, err;
        await this.connect();
        dr = this.db.doc(`${record.collection}/${record.id}`);
        if (transaction) {
          await (transaction.create(dr, record.serializer.toDB(record.data)));
        } else {
          try {
            await (dr.create(record.serializer.toDB(record.data)));
          } catch (error) {
            err = error;
            console.log(err);
            return false;
          }
        }
        return true;
      }

      async transact(fn) {
        var err;
        await this.connect();
        try {
          return (await (this.db.runTransaction((async function(t) {
            return (await (fn(t)));
          }))));
        } catch (error) {
          err = error;
          console.log(err);
          return null;
        }
      }

      async update(record, fields = [], transaction = null) {
        var dr, err;
        await this.connect();
        dr = this.db.doc(`${record.collection}/${record.id}`);
        if (transaction) {
          await (transaction.update(dr, record.serializer.toDB(pick(record.data, fields))));
        } else {
          try {
            await (dr.update(record.serializer.toDB(pick(record.data, fields))));
          } catch (error) {
            err = error;
            console.log(err);
            return false;
          }
        }
        return true;
      }

      async traverse(model, query, opts, fn) {
        return (await this.connect());
      }

    };

    Adapter.prototype.type = 'Adapter';

    return Adapter;

  }).call(this);

  module.exports = Adapter;

}).call(this);
