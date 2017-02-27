var dbm = global.dbm || require('db-migrate');
var type = dbm.dataType;

exports.up = function(db, callback) {
  db.createTable('quotes', {
    id: {type: 'int', primaryKey: true, autoIncrement: true},
    quote: {type: 'text', notNull: true}
  }, callback);
};

exports.down = function(db, callback) {
  db.dropTable('quotes', callback);
};
