var dbm = global.dbm || require('db-migrate');
var type = dbm.dataType;

exports.up = function(db, callback) {
  db.addColumn('quotes', 'context', {
    type: 'string', notNull: true, defaultValue: 'engineering'
  }, function(err) {
    if (err != null) {
      callback(err);
    } else {
      db.addIndex('quotes', 'idx_quotes_on_context', ['context'], callback);
    }
  });
};

exports.down = function(db, callback) {
  db.removeColumn('quotes', 'context', callback);
};
