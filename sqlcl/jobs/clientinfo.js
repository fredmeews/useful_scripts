function getJobSessions( jobSession ) {
    var sql = "select sid, serial# serial, client_info from v$session where client_info is not null";
    var ret = util.executeReturnList(sql, {});;

    var prevStatus = "";
    var count = 0;
    for (var i = 0; i < ret.length; i++) {
	var clientInfo = ret[i].CLIENT_INFO;
	if (clientInfo.indexOf("JobNo") == -1) continue;
	
//	ctx.write( ret[i].CLIENT_INFO +  "\t" + ret[i].SID + "\t" + ret[i].SERIAL + "\n" );

	var field = clientInfo.split(".")[0];
	var jobNo = field.split("=")[1];
//	ctx.write( "fields: " + field + "\t" + "jobno: " + jobNo + "\n");

	jobSession[jobNo] = ret[i].SID + "," + ret[i].SERIAL;
    }

    // for(jobNo in jobSession){
    // 	var sid = jobSession[jobNo];
    // 	ctx.write( "jobno " + jobNo + " sid: " + sid + "\n");
    // }
}


var jobSession = {};
getJobSessions(jobSession);

