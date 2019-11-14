--@jobs/job_throughput.sql 08212017 08252017 08262017 08302017

define fromdate='&1';
define middate='&2';
define newbegin='&3';
define enddate='&4';

select user, 
       round(avg(DL_Before),1) as DL_Before,
       round(avg(DL_After),1) as DL_After,  
       round(avg(AR_Before),1) as AR_Before,
       round(avg(AR_After),1) as AR_After,
       round(avg(NC_Before),1) as NC_Before,
       round(avg(NC_After),1) as NC_After,
        round(avg(Rpt_Before),1) as Rpt_Before,
       round(avg(Rpt_After),1) as Rpt_After     
 from (
 select
case when jobStart between to_date('&fromdate','MMDDYYYY') and to_date('&middate','MMDDYYYY') then
         case when jobType='DataLoad' then round(processed/jobHours, 1) else null end
       end as DL_Before,
case when jobStart between to_date('&newbegin','MMDDYYYY') and to_date('&enddate','MMDDYYYY') then
         case when jobType='DataLoad' then round(processed/jobHours, 1) else null end
       end as DL_After,
case when jobStart between to_date('&fromdate','MMDDYYYY') and to_date('&middate','MMDDYYYY') then
         case when jobType='Nightly Calc' then round(processed/jobHours, 1) else null end
       end as NC_Before,
case when jobStart between to_date('&newbegin','MMDDYYYY') and to_date('&enddate','MMDDYYYY') then
         case when jobType='Nightly Calc' then round(processed/jobHours, 1) else null end
       end as NC_After,
case when jobStart between to_date('&fromdate','MMDDYYYY') and to_date('&middate','MMDDYYYY') then
         case when jobType='Auto Rule' then round(processed/jobHours, 1) else null end
       end as AR_Before,
case when jobStart between to_date('&newbegin','MMDDYYYY') and to_date('&enddate','MMDDYYYY') then
         case when jobType='Auto Rule' then round(processed/jobHours, 1) else null end
       end as AR_After,
case when jobStart between to_date('&fromdate','MMDDYYYY') and to_date('&middate','MMDDYYYY') then
         case when jobType='Report' then round(1/jobHours ,1) else null end
       end as Rpt_Before,
case when jobStart between to_date('&newbegin','MMDDYYYY') and to_date('&enddate','MMDDYYYY') then
         case when jobType='Report' then  round(1/jobHours ,1)  else null end
       end as Rpt_After       
    from (select j.*, ((jsh.end_date - jsh.start_date) * 24) + 0.00001 stepHours, sequence_no, jsh.start_date stepStart, jsh.end_date stepEnd
                 --,coalesce(substr(arguments, instr(arguments, ' ', 1, 2) + 1, instr(arguments, ' ', 1, 3) - instr(arguments, ' ', 1, 2)), 'startup') command
          from (select (jobDays * 24) + 0.00001 jobHours, j.*,  coalesce(RACount, claimCount, recordsReceived,accountPayerCount,ruleResultCount, 0) processed,
                coalesce(totalRACount, totalClaimCount, recordsReceived, 0) read,
                  case
                      when j.name like '835%'           then '835'
                      when j.name like 'Data Load 9.0%' then 'DataLoad'
                      when j.name like '%Nightly Calc%'  then 'Nightly Calc'
                      when j.name like '837%'           then '837'
                      when (j.name like 'Auto Rule%' OR j.name like 'Automatic Rules%')  then 'Auto Rule'
                      when (j.name like 'Work Queue Rule%' or j.name like 'Workqueue%')  then 'WQ Rule'
                     when j.category like '%eport%' then 'Report'
                      else 'Others'
                  end jobType
            from (select job_no, jh.id, jh.name, jh.category,
                     (select min(jsh.start_date) from job_sequence_history jsh where jsh.job_history_id = jh.id and jsh.status = 'Completed') jobStart,
                     (select max(jsh.end_date) from job_sequence_history jsh where jsh.job_history_id = jh.id and jsh.status = 'Completed') jobEnd,
                     (select sum(jsh.end_date - jsh.start_date) from job_sequence_history jsh where jsh.job_history_id = jh.id and jsh.status = 'Completed') jobDays,
                     (select max(file_path || filename) from edi_file f where f.req_file_id = jh.job_no) filename,
                     (select max(rec_cnt) from edi_file f where f.req_file_id = jh.job_no) rec_cnt,
                     (select sum(records_received_cnt) from dl_filename_summary fs where fs.job_no = jh.job_no) recordsReceived,
                     (select sum(db_inserts) from dl_filenumber_summary fs where fs.job_no = jh.job_no) db_inserts,
                     (select max(ra_count) from dl_835_summary ts where ts.job_no = jh.job_no and Message = 'Received') totalRACount,
                     (select max(ra_count) from dl_835_summary ts where ts.job_no = jh.job_no and Message = 'LOADED') RACount,
                     (select max(claim_count) from dl_837_summary ts where ts.job_no = jh.job_no and Message = 'Received') totalClaimCount,
                     (select max(claim_count) from dl_837_summary ts where ts.job_no = jh.job_no and Message = 'Loaded') claimCount,
                     (select sum(nvl(ir.inserts1,0)+nvl(ir.updates1,0)) from interface_run ir where ir.job_no = jh.job_no and ir.program_name = 'CE_PROCESS_ACCOUNT_PAYERS.populate_for_data_load') accountPayerCount,
                     (select sum(nvl(ir.inserts1,0)+nvl(ir.updates1,0)) from interface_run ir where ir.job_no = jh.job_no ) ruleResultCount,
                    (select count(*) from interface_run ir where ir.job_no = jh.job_no ) ruleCount,
                     (select sum(records_received_cnt) from dl_filename_summary fs where fs.job_no = jh.job_no and filename like '%_30_%' escape '\') accountCount
                 from job_history jh
                 where --category = 'Data Load' and
                 status = 'Completed'
                 and not exists (select null from job_history ijh, job_sequence_history ijsh where ijh.id = ijsh.job_history_id and ijsh.status = 'Error' and jh.id = ijh.id)
                 ) j
              ) j
            join job_sequence_history jsh on jsh.job_history_id = j.id
          where jsh.status = 'Completed') jsh
      where jobStart between to_date('&fromdate','MMDDYYYY') and to_date('&enddate','MMDDYYYY')
      and jobType in ('Nightly Calc','DataLoad','Auto Rule','Report') --'835','837'
      and sequence_no = 1
)  ;
