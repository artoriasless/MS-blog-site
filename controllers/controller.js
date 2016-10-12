var controllCategory = {
    '/initTags.node'    : 'viewSqlInitTags',
    '/initLatest.node'  : 'viewSqlInitLatest',
    '/initTimeline.node': 'viewSqlInitTimeline',
    '/initCategory.node': 'viewSqlInitCategory',

    '/categoryByTagName.node' : 'viewSqlCategoryByTagName',
    '/categoryByTimeline.node': 'viewSqlCategoryByTimeline',

    '/paperById.node': 'viewSqlPaperById'
};

var controll = function(request, response) {
    var callbackFunc  = function(resultObj) { response.json(resultObj); },
        viewSqlModule = require('../models/' + controllCategory[request.path] +'.js');
    
    viewSqlModule.sqlQuery(request, callbackFunc);
}

module.exports.controll = controll;