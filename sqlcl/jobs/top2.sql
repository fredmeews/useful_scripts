-- history;

set feedback off;

SELECT username, osuser,
       sqlid,
       sid||','||serial sid_serial,
       substr(sql_text, 1, 75) sqltext,
--       buffer_gets,       
       substr(module,1,10) module,
--       elapsed_time,
       disk_reads,
--       executions,
       buffer_get_per_exec
--       parse_calls,
--       sorts
--       rows_processed,
--       hit_ratio
       -- elapsed_time, cpu_time, user_io_wait_time, ,
  FROM (SELECT sql_text, sid, serial# serial, s.sql_id sqlid, s.osuser,
               b.username,
               a.disk_reads,
               a.buffer_gets,
               trunc((a.buffer_gets + 1) / (a.executions + 1)) buffer_get_per_exec,
               a.parse_calls,
               a.sorts,
               a.executions,
               a.rows_processed,
               100 - ROUND (100 * a.disk_reads / a.buffer_gets , 2) hit_ratio,
               s.module,
               cpu_time, elapsed_time, user_io_wait_time
          FROM v$sqlarea a, dba_users b, v$session s
         WHERE a.parsing_user_id = b.user_id
--           AND b.username NOT IN ('SYS', 'SYSTEM', 'RMAN','SYSMAN')
--           AND a.buffer_gets > 1000
	   AND s.sql_id = a.sql_id
	   AND s.status = 'ACTIVE'
         ORDER BY buffer_get_per_exec DESC
	 fetch first 20 rows only
	 );
-- WHERE ROWNUM <= 20;


--repeat 1000 5;

set feedback on;
