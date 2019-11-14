// Usage:
//
// jobs - show jobs currently in queue
// jobs history 1 2 --- show jobs between 1 and 2 days ago
// 

var DEBUG = true;
var jobSession = {};

var sql = "select sid, serial# serial, client_info, to_char(logon_time,'MM/DD HH24:MI') start_time " +
    "from v$session where client_info is not null and username = SYS_CONTEXT ('USERENV', 'SESSION_USER')";
