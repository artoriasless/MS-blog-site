var express = require('express'),
    app     = express(),
    server;

app.use(express.static('public'));
app.use(express.static('views'));

app.get('/index.html', function(request, response) {
    response.sendFile(__dirname + '/' + 'index.html');
})

server = app.listen(8181, function() {
	console.info('应用实例，访问地址为：http://127.0.0.1:8181/index.html');
})
