var sqlOptions = require('./sqlOptions.js'),
    mysql      = require('mysql'),

    colsCount = 0,

    deleteSql = '',

    client;

var sqlQuery = function(sqlSetting, querySetting) {
    sqlOptions.database   = sqlSetting.database;
    sqlOptions.table      = sqlSetting.table;
    sqlOptions.connection = sqlSetting.connection;

    colsCount = querySetting.colsName.length;
    querySetting.conditions = querySetting.colsName[0] + '=?';
    for (var i = 1; i < colsCount; i ++) {
        querySetting.conditions += (' AND ' + querySetting.colsName[i] + '=?'); 
    }

    deleteSql = 'DELETE FROM ' + sqlOptions.table + 
                ' WHERE ' + querySetting.conditions;

    client = mysql.createConnection(sqlOptions.connection);

    client.connect(function(err) {
        if (err) { return; }
    });

    client.query(deleteSql, querySetting.valsArr, function(err, result) {
        if (err) { return; }

        client.end(function(err) {
            if (err) { return err; }
        })
    })
}

module.exports.sqlQuery = sqlQuery;