## sqlOptions.js ##
options = {
    database  : '',
    table     : '',
    connection: {
        host    : '127.0.0.1',
        user    : 'root',
        password: '12345',
        port    : '3306',
        database: ''
    }
};


## common sqlSetting ##
//本项目对于数据，力求通用，讲语句缩减到增、删、改、查四块
//每一个都尽量做到封装，只考虑传入参数，不关心内部实现
//考虑到本项目不是特别复杂，所以对于数据删除和数据修改，只考虑AND，不考虑OR以及BETWEEN等特定条件
sqlSetting = {
    database  : '',
    table     : '',
    connection: {
        host    : '127.0.0.1',
        user    : 'root',
        password: '12345',
        port    : '3306',
        database: ''
    }
};


## addSql.js ##
querySetting = {
    colsName: [ 'col1', 'col2', 'col3' ],
    valsArr : [ 'val1', 'val2', 'val3' ],
    //placeholders: '?,?,?'  // calculate in model level
};


## deleteSql.js ##
querySetting = {
    colsName: [ 'col1', 'col2', 'col3' ],
    valsArr : [ 'val1', 'val2', 'val3' ],
    //conditions: 'col1=? AND col2=? AND col3=?'  // calculate in model level
};


## updateSql.js ##
querySetting = {
    colsName: [ 'col1', 'col2', 'col3' ],
    valsArr : [ 'val1', 'val2', 'val3' ],
    conditionsObj: {
        colsName: [ 'col-1', 'col-2' ],
        valsArr : [ 'val-1', 'val-2' ],
    }
    //resultQuery: 'col1=?,col2=?            // calculate in model level
    //conditionsQuery: 'col-1=? AND col-2=?  // calculate in model level
};


## viewSql.js ##
//查询的需求太多，暂时做不到写一个后全部通用，暂时将每一个页面所需要的数据查询写在一个js文件