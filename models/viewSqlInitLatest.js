var mysql      = require('mysql'),
    sqlOptions = require('./sqlOptions.js').options,

    viewSql = 'SELECT id,title,LEFT(publish_date,10) AS date,timeline' +
              ' FROM papers_table ' +
              'ORDER BY publish_date DESC',
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