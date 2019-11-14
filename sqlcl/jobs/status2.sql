select
  decode(
      lag(status) over (order by status, category, name),
      status, '|',
      '|'||(case when upper(status) like 'ERROR%' then 'ERROR' when upper(status) like '%QUEUED%' then 'QUEUED' else upper(status) end)||'|',
  ) job_status,
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
