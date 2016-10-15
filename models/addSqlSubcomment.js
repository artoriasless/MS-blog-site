var sqlOptions = require('./sqlOptions.js').options,
    mysql      = require('mysql'),

    querySetting = {},

    colsCount = 0,

    addSql = '',

    client;

var sqlQuery = function(request, callbackFunc) {
    querySetting = {
        colsName: request.body['colsName[]'],
        valsArr : request.body['valsArr[]']
    };
    colsCount    = querySetting.colsName.length;
    querySetting.placeholders = '?';
    for (var i = 1; i < colsCount; i ++) {
        querySetting.placeholders += ',?';
    }

    addSql = 'INSERT INTO subcomment_table' +
             ' (' + querySetting.colsName.join(',') + ') ' + 
             'VALUES' + ' (' + querySetting.placeholders + ')';

    client = mysql.createConnection(sqlOptions.connection);

    client.connect(function(err) {
        if (err) { return err; }
    });

    client.query(addSql, querySetting.valsArr, function(err, result) {
        if (err) {
            callbackFunc({
                status: 'faild'
            });
            return err;
        }
        else {
            callbackFunc({
                status: 'success'
            });
        }

        client.end(function(err) {
            if (err) { return err; }
        })
    });
}

module.exports.sqlQuery = sqlQuery;