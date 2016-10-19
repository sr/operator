var dbm = global.dbm || require('db-migrate');
var type = dbm.dataType;

exports.up = function(db, callback) {
  db.createTable('deploys', {
    id: {type: 'int', primaryKey: true, autoIncrement: true},
    build_number: {type: 'int', notNull: true},
    sync_master: {type: 'string', notNull: true},
    started_at: {type: 'datetime', notNull: true}
  }, callback);
};

exports.down = function(db, callback) {
  db.dropTable('deploys', callback);
};
