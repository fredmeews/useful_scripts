/*  execute a sql and get the first column of the first row as a return*/
var dbUser = util.executeReturnOneCol('select sys_context( \'userenv\', \'current_schema\' ) from dual');
var dbServer = util.executeReturnOneCol('select instance_name from v$instance');


/*  based on the connect user change my SQL prompt*/
//if ( dbServer.trim().startsWith("PROD") ) {
//    sqlcl.setStmt('set sqlprompt "@|yellow  _USER|@@@|green ' + dbServer + '|@@|blue >|@"');
//} else {
    sqlcl.setStmt('set sqlprompt "@|green  _USER|@@@|green ' + dbServer + '|@@|blue >|@"');
//}

sqlcl.run();

