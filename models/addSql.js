var sqlOptions = require('./sqlOptions.js'),
    mysql      = require('mysql'),

    colsCount = 0,

    addSql = '',

    client;

var sqlQuery = function(sqlSetting, querySetting) {
    sqlOptions.database   = sqlSetting.database;
    sqlOptions.table      = sqlSetting.table;
    sqlOptions.connection = sqlSetting.connection;
    
    colsCount = querySetting.colsName.length;
    querySetting.placeholders = '?';
    for (var i = 1; i < colsCount; i ++) {
        querySetting.placeholders += ',?';
    }

    addSql = 'INSERT INTO ' + sqlOptions.table + 
             ' (' + querySetting.colsName.join(',') + ') ' + 
             'VALUES' + ' (' + querySetting.placeholders + ')';

    client = mysql.createConnection(sqlOptions.connection);

    client.connect(function(err) {
        if (err) { return err; }
    });

    client.query(addSql, querySetting.valsArr, function(err, result) {
        if (err) { return err; }

        client.end(function(err) {
            if (err) { return err; }
        })
    });
}

module.exports.sqlQuery = sqlQuery;