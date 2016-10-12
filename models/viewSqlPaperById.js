var mysql      = require('mysql'),
    sqlOptions = require('./sqlOptions.js').options,

    viewSql = '',

    client;

var sqlQuery = function(request, callbackFunc) {
    viewSql = ' (SELECT id,title,LEFT(publish_date,10) AS date,tag,subtag,content' +
              ' FROM papers_table WHERE id < "' + request.body.paperId + '" order by id DESC limit 1) ' +
              'UNION' +
              ' (SELECT id,title,LEFT(publish_date,10) AS date,tag,subtag,content' +
              ' FROM papers_table WHERE id = "' + request.body.paperId + '") ' +
              'UNION' +
              ' (SELECT id,title,LEFT(publish_date,10) AS date,tag,subtag,content' +
              ' FROM papers_table WHERE id > "' + request.body.paperId + '" order by id asc limit 1)';

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