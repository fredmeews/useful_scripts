select distinct category2 from (
SELECT --jsj.ID,
--        jsj.JOB_STREAM_ID,
        jsj.SEQUENCE_NO,
--        substr(js.NAME, 1,50) as JOB_STREAM_NAME,
--        jsj.JOB_TEMPLATE_ID,
        jt.NAME                as TEMPLATE_NAME,
pv.display_text category2,
case
                      when (pv.display_text like 'Data Load%' and js.name like '%835%') then 'DataLoad-835'
                      when (pv.display_text like 'Data Load%' and js.name like '%837%') then 'DataLoad-835' 		      
                      when pv.display_text like 'Data Load%' then 'DataLoad'
                      when (pv.display_text like '%Nightly Calc%' or pv.display_text like '%Calc (Parallel)%') then 'NightlyCalc'
                      when pv.display_text like '837%'           then '837'
                      when (pv.display_text like 'Auto%' OR pv.display_text like 'AutoRule%')  then 'AutoRule'
                      when (pv.display_text like 'Work Queue%' or pv.display_text like 'WorkQueue%')  then 'WorkQueue'
                      when (pv.display_text like '%Notes%')  then 'Notes'
                      when pv.display_text like '%eport%' then 'Report'
		      else pv.display_text
		        end category,
--	 jt.parl_nc_chunk_no,
--	 jt.parl_nc_chunk_max,
        jsj.IDENTIFIER,
        jsj.SCHEDULED_TIME
 FROM   job_stream_job jsj,
        job_stream js,
        job_template jt,
        preset_value pv
 WHERE  jsj.JOB_TEMPLATE_ID = jt.ID(+)
 AND    jt.CATEGORY_ID = pv.id(+)
 AND    jsj.JOB_STREAM_ID = js.id
 AND js.is_deleted =0 and js.is_finalized =1 and js.is_enabled =1
 ORDER BY js.name, jsj.sequence_no
 )
 order by 1;
