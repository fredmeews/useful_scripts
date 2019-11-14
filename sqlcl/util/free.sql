-- History of tablespace storage
select snap_id, rtime,
round ((tablespace_maxsize * 8192 / (1024*1024*1024)), 2) max_gb,
round ((tablespace_usedsize * 8192 / (1024*1024*1024)), 2) used_gb
from dba_hist_tbspc_space_usage
where tablespace_id = (select ts# from v$tablespace where name = '&1')
order by rtime desc
fetch first 20 rows only;

-- Largest tables
select segment_name,segment_type,bytes/1024/1024 MB
 from dba_segments
 where owner = '&1' and segment_type IN ('TABLE', 'TABLE PARTITION')
 order by mb desc
 fetch first 10 rows only;

-- Partition
select segment_name, segment_type,  sum(bytes / 1024 / 1024) "MB", count(*) as ctr
from   dba_segments
where tablespace_name='&1' 
    and segment_name like 'EDI_FILE%'
group by segment_name, segment_type
order by 3 desc nulls last
fetch first 10 rows only;
