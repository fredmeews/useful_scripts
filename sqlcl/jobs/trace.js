// declare the java classes  needed
var DriverManager = Java.type("java.sql.DriverManager");
var DBUtil  = Java.type("oracle.dbtools.db.DBUtil");
var Thread  = Java.type("java.lang.Thread");
var System  = Java.type("java.lang.System");

// Create a new connection to use for monitoring
// Grab the connect URL from the base connection in sqlcl

if ( typeof conn !== 'undefined' ) {
    var LongOpsBinds = {};

    if (args.length == 1) {
	var sql = "SELECT sid FROM v$session_longops  WHERE sofar/totalwork < 1 and sofar > 0 and sofar <> totalwork";	
	var ret = util.executeReturnList(sql, {});;

	for (var i = 0; i < ret.length; i++) {
	    ctx.write("Longops SID: " + ret[i].SID + "\n");
	}
    }
    else {
	// long ops sql
	var sql = " SELECT sid, to_char(start_time,'hh24:mi:ss') stime, " +
	    " message,( sofar/totalwork)* 100 percent  " +
	    " FROM v$session_longops " +
	    " WHERE sofar/totalwork < 1" +
	    " and   sid = :SID " +
	    " and sofar > 0 and sofar <> totalwork ";
	
	if ( !conn  ) {
	    System.out.println(" Not Monitoring , not connected ");
	}else {
	    LongOpsBinds.SID = args[1];	
	}
	
	// start it up
	runme();
    }
} else {
    System.out.println("Not Connected, longops could not run ");
}

function main(arg){
    function inner(){
        System.out.println("\nStarting Monitoring sid= " + LongOpsBinds.SID )
	System.out.println("\nStarting Monitoring sid= " + sql)
      //connect
        try {
            var conn2  = ctx.cloneCLIConnection();
             var util2  = DBUtil.getInstance(conn2);
            var last = 0;
	    var curr = 0;
             // run always !
             while(true) {
                ret = util2.executeReturnList(sql,LongOpsBinds);
                 // only print if the percent changed
		 curr = Math.round( ret[0].PERCENT );
                 if ( ret.length > 0 && last != curr ){
                     last = curr;
//		     System.out.println(last);
                     System.out.println( ret[0].STIME + "> " + curr + '% Completed \t' + ret[0].MESSAGE);
                 }
		 else {
		     System.out.println("No change");
		 }
                 // sleepy time
                 Thread.sleep(5000);
              }
            System.out.println("\nDone Monitoring")
            conn2.close();
         } catch (e) {
              System.out.println("\nDone: " + e.getLocalizedMessage());
         }
        }
        return inner;
};


function runme(){
        // import and alias Java Thread and Runnable classes
        var Thread = Java.type("java.lang.Thread");
        var Runnable = Java.type("java.lang.Runnable");

        // declare our thread
        this.thread = new Thread(new Runnable(){
         run: main()
        });

        // start our thread
        this.thread.start();
        return;
}
