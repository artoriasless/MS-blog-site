var routeCategory = {
    '/index.html': '/views/index.html',
    '/home.html' : '/views/home.html'
};

var route = function(dirname, request, response) {
    if (routeCategory[request.path]) {
        response.sendFile(dirname + routeCategory[request.path]);
    }
    else {
        response.sendFile(dirname + '/views/404.html');
    }
};

module.exports.route = route;