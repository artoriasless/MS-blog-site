var sqlOptions = require('./sqlOptions.js'),
    mysql      = require('mysql'),

    viewSql = '',

    client;

var sqlQuery = function(sqlSetting, querySetting) {
    sqlOptions.database   = sqlSetting.database;
    sqlOptions.table      = sqlSetting.table;
    sqlOptions.connection = sqlSetting.connection;

    client = mysql.createConnection(sqlOptions.connection);

    client.connect(function(err) {
        if (err) {
            console.info('[query error] - ' + err);
            return ;
        }
    });
}

module.exports.sqlQuery = sqlQuery;