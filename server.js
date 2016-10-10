var express = require('express'),
    app     = express(),
    server,

    bodyParser = require('body-parser'),
    urlencodedParser = bodyParser.urlencoded({
        extended: false
    });

/* router level */
var router = require('./routes/router.js');

/* controller level */
var controller = require('./controllers/controller.js');

app.use(express.static('public'));

app.get('/*', function(request, response) {
    router.route(__dirname, request, response);
});

app.post('/*', urlencodedParser, function(request, response) {
    controller.controll(request, response);
})

server = app.listen(8181, function() {
	console.info('app sample,view address：http://127.0.0.1:8181/index.html');
})
