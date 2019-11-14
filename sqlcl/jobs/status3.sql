SELECT jsh.SEQUENCE_NO,  jsh.STATUS , 
round((jsh.END_DATE - jsh.START_DATE)*24*60, 1) minutes,
  to_char(jsh.start_date,'MM/DD/YYYY hh24:mi:ss') as begin, to_char(jsh.end_date,'MM/DD/YYYY hh24:mi:ss') finish,
  plugin,
  substr(jsh.ARGUMENTS, 1, 50) args
FROM JOB_SEQUENCE_HISTORY jsh,
  JOB_HISTORY jh
WHERE jsh.JOB_HISTORY_ID = jh.id
AND jh.JOB_NO            = &1;

select
substr(program_name,1,75) name,
round(sum(end_date-start_date)*24*60*60,2) seconds,
sum(inserts1+inserts2) inserts, sum(updates1+updates2) updates,
to_char(min(start_date),'MM/DD/YYYY hh24:mi:ss') min,
to_char(max(end_date),'MM/DD/YYYY hh24:mi:ss') max
from interface_run
where job_no = &1
group by program_name
order by sum (end_date-start_date)*24  desc
;
