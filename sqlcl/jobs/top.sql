SELECT username,
       sql_id,
       sid||','||serial sid_serial,
--       serial#
       substr(sql_text, 1, 75) sqltext,
--       buffer_gets,
       osuser,
       module,
       elapsed_seconds,
--       disk_reads,
       executions
       buffer_get_per_exec
--       parse_calls,
--       sorts
--       rows_processed,
--       hit_ratio
       -- elapsed_time, cpu_time, user_io_wait_time, ,
  FROM (SELECT c.sql_id, sql_text,
	       c.sid,
	       c.serial# serial,
       	       elapsed_seconds,
               b.username,
               a.disk_reads,
               a.buffer_gets,
               trunc((a.buffer_gets + 1) / (a.executions + 1)) buffer_get_per_exec,
               a.parse_calls,
               a.sorts,
               a.executions,
               a.rows_processed,
               100 - ROUND (100 * a.disk_reads / a.buffer_gets , 2) hit_ratio,
               a.module,
               cpu_time, elapsed_time, user_io_wait_time
          FROM v$sqlarea a, dba_users b, v$session c, v$session_longops d
         WHERE a.parsing_user_id = b.user_id AND
	       a.sql_id = c.sql_id AND
	       c.status = 'ACTIVE' AND
	       c.sid = d.sid(+) AND
       	       c.serial# = d.serial# (+) and
	       c.sql_id = d.sql_id(+)
--           AND b.username NOT IN ('SYS', 'SYSTEM', 'RMAN','SYSMAN')
--           AND a.buffer_gets > 1000
--	 AND elapsed_seconds > 0 AND
	 and d.start_time = (select max(start_time) from v$session_longops d2 where d2.sql_id = c.sql_id)
         ORDER BY elapsed_seconds DESC
	 fetch first 40 rows only
	 );
-- WHERE ROWNUM <= 20;

--repeat 1000 10
