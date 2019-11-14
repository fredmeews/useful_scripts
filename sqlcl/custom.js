// From: https://github.com/oracle/oracle-db-tools/blob/b0d0badbb24b20ec90b1dd8caf82d923559a6185/sqlcl/examples/customCommand.js


// SQLCL's Command Registry
var CommandRegistry = Java.type("oracle.dbtools.raptor.newscriptrunner.CommandRegistry");

// CommandListener for creating any new command
var CommandListener =  Java.type("oracle.dbtools.raptor.newscriptrunner.CommandListener")

// Broke the .js out from the Java.extend to be easier to read
var cmd = {};

// Called to attempt to handle any command
cmd.handle = function (conn,ctx,cmd) {
    ///////////////////////
    // su - switch session
    ///////////////////////    
    if ( cmd.getSql().trim().startsWith("su ") ) {
	args = cmd.getSql().trim().split(/(\s+)/);

	var dbUser = args[2].toUpperCase();
	sqlcl.setStmt("alter session set current_schema = " + dbUser);
	sqlcl.run();
	
	var dbServer = util.executeReturnOneCol('select instance_name from v$instance');
	sqlcl.setStmt( 'set sqlprompt "@|green  ' + dbUser + '|@@@|green ' + dbServer + '|@@|blue >|@"' );
	sqlcl.run();

       // return TRUE to indicate the command was handled
       return true;
    }

    ///////////////////////
    // trace - monitor longops
    ///////////////////////        
    if ( cmd.getSql().trim().startsWith("trace") ) {
	args = cmd.getSql().trim().split(/(\s+)/);

	var sid = args[2];
	if (sid) {
	    sqlcl.setStmt("script jobs/trace.js " + sid);
	}
	else {
	    sqlcl.setStmt("script jobs/trace.js");
	}
	sqlcl.run();

	return true;
    }

    ///////////////////////
    // top - worst sessions
    ///////////////////////            
    if ( cmd.getSql().trim().startsWith("top") ) {
	sqlcl.setStmt("@jobs/top2.sql");
	sqlcl.run();

	sqlcl.setStmt("repeat 1000 10");
	sqlcl.run();

	return true;
    }	    

    ///////////////////////
    // tabs - find tables
    ///////////////////////            
    if ( cmd.getSql().trim().startsWith("tabs") ) {
	args = cmd.getSql().trim().split(/(\s+)/);

	var tableName = args[2].toUpperCase();
	sqlcl.setStmt("select object_name name, object_type type from all_objects where owner = " + 
		      "(select sys_context('userenv','current_schema') x from dual) and " +
		      "object_name like '%" + tableName + "%' and " +
		      "object_type not like '%PARTITION' and " +
		      "object_type not in ('INDEX', 'SEQUENCE') " +		      
		      "order by object_type, object_name"
		     );
	sqlcl.run();
	
       return true;
    }
    
   // return FALSE to indicate the command was not handled
   // and other commandListeners will be asked to handle it
   return false;
}

// fired before ANY command

cmd.begin = function (conn,ctx,cmd) {
   var start = new Date();
   ctx.putProperty("cmd.start",start);
}

// fired after ANY Command
cmd.end = function (conn,ctx,cmd) {
   var end = new Date().getTime();
   var start = ctx.getProperty("cmd.start");
   if ( start ) {
      start = start.getTime();
      // print out elapsed time of all commands
//      ctx.write("Elapsed Time:" + (end - start) + "\n");
   }
}

// Actual Extend of the Java CommandListener

var MyCmd2 = Java.extend(CommandListener, {
		handleEvent: cmd.handle ,
        beginEvent:  cmd.begin  , 
        endEvent:    cmd.end    
});

// Registering the new Command
CommandRegistry.addForAllStmtsListener(MyCmd2.class);

