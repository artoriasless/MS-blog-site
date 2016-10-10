var route = function(dirname, request, response) {
    switch (request.path) {
        case '/index.html':
            indexPage(dirname, response);
            break;
        default :
            wrongPage(dirname, response);
            break;
    }
};

var indexPage = function(rootpath, res) {
    res.sendFile(rootpath + '/views/index.html');
}

var wrongPage = function(rootpath, res) {
    res.sendFile(rootpath + '/views/404.html');
}

module.exports.route = route;