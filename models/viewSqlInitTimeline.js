var mysql      = require('mysql'),
    sqlOptions = require('./sqlOptions.js').options,

    viewSql = 'SELECT timeline,(papers_count + 0) AS papersCount' +
              ' FROM timeline_index ' +
              'ORDER BY timeline DESC',
              
    client;

var sqlQuery = function(request, callbackFunc) {
    client = mysql.createConnection(sqlOptions.connection);

    client.connect(function(err) {
        if (err) { return err; }
    });

    client.query(viewSql, function(err, results, fields) {
        if (err) { return err; }
        else {
            callbackFunc(results);
        }

        client.end(function(err) {
            if (err) { return err; }
        })
    });
}

module.exports.sqlQuery = sqlQuery;