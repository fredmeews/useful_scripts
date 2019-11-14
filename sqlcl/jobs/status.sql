select
  decode(
    lag(status) over (order by status, category, name),
    status, '|',
    '---- ' || status || ' ----') job_status,
--    '---- ' || (case when status = 'Running' then 'RUNNING' else 'QUEUED' end) || ' ----') job_status,
  job_no,
  name,
  to_char(start_date, 'MM/DD/YYYY HH24:MI') startd,
  job_template_id
from job_queue
order by 
    case
       when status like 'Error%' then 1
       when status = 'Running' then 2
       when status like '%Queued%' then 3
       when status like 'Suspend%' then 4
       else 5
    end
fetch first 50 rows only;
