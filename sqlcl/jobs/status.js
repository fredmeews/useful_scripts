// Usage:
//
// jobs - show jobs currently in queue
// jobs history 1 2 --- show jobs between 1 and 2 days ago
//
var DEBUG = false;
var jobSession = {};


getJobDetails(jobSession);
printCurrentTime();
printJobs(jobSession);

///////////////////////////////////////////////////////
function printCurrentTime() {
    var sql = "select to_char(sysdate,'MM/DD HH24:MI') time from dual";
    var ret = util.executeReturnList(sql, {});
    ctx.write( "DB TIME: " + ret[0].TIME + "\n" );
}

function printJobs() {

    var historyMode = false;
    var table = "job_queue";
    var start, end;

    var binds = {};
    binds.limit = 30;
    if (args.length >  1) {
	if (args[1] == "history") {
	    historyMode = true;
	    start = args[2];
	    end = args[3];
	    binds.limit = 100000; //no limit
	    table = "job_history";
	}
	else {
	    binds.limit = args[1];
	}
    }

    var sql = "select " +
	"  upper(status) status, " +
	"  job_no, " +
	"  name, " +
	"  to_char(start_date, 'MM/DD/YYYY_HH24:MI') startd, " +
	"  job_template_id " +
	"from " + table + " " +
	(historyMode ? "where start_date > sysdate - " + end + " and start_date < sysdate - " + start + " " : " ") + 
	"order by  " +
	"   case " +
	"       when status = 'RUNNING' then 1 " +
	"       when status like 'ERROR%' then 2 " +
	"       when status like '%QUEUED%' then 3 " +
	"       when status like 'SUSPEND%' then 4 " +
	"       else 5 " +
	"    end " +
	"fetch first :limit rows only ";
    
    if (DEBUG) ctx.write(sql + '\n\n\n'); 
    var ret = util.executeReturnList(sql, binds);

    // Group jobs by status, monbot style formatting
    var prevStatus = "";
    var count = 0;
    for (var i = 0; i < ret.length; i++) {
	if (ret[i].NAME.indexOf("Task Scheduler") !== -1) continue;
	
	if (ret[i].STATUS != prevStatus) {
	    if (count > 0) ctx.write("TOTAL: " + count + "\n");
	    ctx.write( "\n\n======= " + ret[i].STATUS +  " =======\n");
	    count = 0;
	}

	var s = "\t";

	// Add session info to output if available
	var session = jobSession[ret[i].JOB_NO];
	if (!session) {
	    sessionInfo = "";
	}
	else {
	    sessionInfo = "\n\t\tSID,SERIAL=" + session.sid + "," + session.serial + "\tSTARTED: "+ session.startTime;
	    if (session.reportDetails != "") sessionInfo += "\t" + session.reportDetails;
	}
	var jobNo = ret[i].JOB_NO;


	ctx.write( jobNo + "\t" + ret[i].STARTD +  "\t" + ret[i].NAME + "\t" + sessionInfo + "\n");

	count++;
	prevStatus = ret[i].STATUS;
    }

    ctx.write("TOTAL: " + count + "\n\n");
}


function getJobDetails( jobSession ) {
    
    var sql = "select sid, serial# serial, client_info, to_char(logon_time,'MM/DD HH24:MI') start_time " +
   	      "from v$session where client_info is not null and username = SYS_CONTEXT ('USERENV', 'CURRENT_SCHEMA')";

    if (DEBUG) ctx.write(sql + '\n\n\n');
    
    var ret = util.executeReturnList(sql, {});;

    var prevStatus = "";
    var count = 0;
    for (var i = 0; i < ret.length; i++) {
	
	var clientInfo = ret[i].CLIENT_INFO;
	if (clientInfo.indexOf("JobNo") == -1) continue;
	
	if (DEBUG) ctx.write( ret[i].CLIENT_INFO +  "\t" + ret[i].SID + "\t" + ret[i].SERIAL + "\n" );

	var field = clientInfo.split(".")[0];
	var jobNo = field.split("=")[1];

	field = clientInfo.split(".")[1];
	
	var reportId = field;
	var reportDetails = "";
	if (field.split("=")[0] == "ReportId") {
	    reportId = field.split("=")[1];
	    reportDetails = getReportInfo( reportId );
	}
	
	if (DEBUG) ctx.write( "jobno: " + jobNo + "\t" + "reportId: " + reportId + "\n");

	var session = {
	    sid: ret[i].SID,
	    serial: ret[i].SERIAL,
	    reportDetails: reportDetails,
	    startTime: ret[i].START_TIME
	};
	
	jobSession[jobNo] = session;
    }

}


function getReportInfo( reportId ) {
    var sql = "select 'REPORT:' || heading || ', USER:' || lower(login_id)  RPT from report r, users u " +
 	"where r.id = " + reportId + " and r.user_id_generator = u.user_id";

    if (DEBUG) ctx.write(sql + '\n\n\n');     

    var ret = util.executeReturnList(sql, {});
    return ret[0].RPT;
}
    


