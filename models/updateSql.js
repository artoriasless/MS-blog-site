var sqlOptions = require('./sqlOptions.js'),
    mysql      = require('mysql'),

    resultColCount = 0,
    resultQuery = '',

    conditionsColCount = 0,
    conditionsQuery = '',

    updateSql = '',

    client;

var sqlQuery = function(sqlSetting, querySetting) {
    sqlOptions.database   = sqlSetting.database;
    sqlOptions.table      = sqlSetting.table;
    sqlOptions.connection = sqlSetting.connection;

    resultColCount = querySetting.colsName.length;
    resultQuery    = querySetting.colsName[0] + '=?';
    for (var i = 1; i < resultColCount; i ++) {
        resultQuery += (',' + querySetting.colsName[i] + '=?');
    }

    conditionsColCount = querySetting.conditionsObj.colsName.length;
    conditionsQuery    = querySetting.conditionsObj.colsName[0] + '=?';
    for (var i = 1; i < conditionsColCount; i ++) {
        conditionsQuery += (' AND ' + querySetting.conditionsObj.colsName[i] + '=?');
    }

    updateSql = 'UPDATE ' + sqlOptions.table +
                ' SET ' + resultQuery +
                ' WHERE ' + conditionsQuery;
    
    client = mysql.createConnection(sqlOptions.connection);

    client.connect(function(err) {
        if (err) { return; }
    });

    client.query(updateSql, querySetting.valsArr.concat(querySetting.conditionsObj.valsArr), function(err, result) {
        if (err) { return; }
        
        client.end(function(err) {
            if (err) { return err; }
        })
    })
}

module.exports.sqlQuery = sqlQuery;