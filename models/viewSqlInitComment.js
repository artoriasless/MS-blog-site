var mysql      = require('mysql'),
    sqlOptions = require('./sqlOptions.js').options,

    viewSql = '',

    client;

var sqlQuery = function(request, callbackFunc) {
    viewSql = '(SELECT id AS commentId,user_name AS userName,content,DATE_FORMAT(comment_date,"%Y-%m-%d %h:%i:%s") AS commentDate,type' +
              ' FROM comment_table ' +
              'WHERE paper_id = "' + request.body.paperId + '")' +
              ' UNION ' +
              '(SELECT comment_id AS commentId,user_name AS userName,content,DATE_FORMAT(comment_date,"%Y-%m-%d %h:%i:%s") AS commentDate,type' +
              ' FROM subcomment_table ' +
              'WHERE paper_id = "' + request.body.paperId + '")' +
              ' ORDER BY commentId,type ASC';

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