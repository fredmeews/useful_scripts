select 
  sql_fulltext sqltext,
 ses.sid, ses.serial#, ses.osuser,
 lng.message,
 to_char(lng.start_time,'hh24:mi:ss') stime
-- (lng.sofar/lng.totalwork) * 100 percent
-- substr(sql.sql_text, 1, 10000) sql
 from v$session ses, v$session_longops lng, v$sqlarea sql
 where
  ses.sql_hash_value = sql.hash_value and
  ses.sid = lng.sid(+) and
  lng.time_remaining(+) > 0 and
  ses.serial# = lng.serial#(+) and
  ses.username='&1' and ses.osuser <> 'hughese' -- and
  order by ses.sql_exec_start desc;

