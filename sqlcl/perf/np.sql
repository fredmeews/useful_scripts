define start='&1';
define end='&2';
define member='&3';

set feedback off
alter session set current_schema = UPMCHS1;
--alter session set current_schema = CHI_CORP;
--alter session set current_schema = CCF;
--alter session set current_schema = TRINITY3;


set sqlformat csv
spool /tmp/np.csv

SELECT
--    job_stream_id id,
    job_stream_history_id hid,
--    run_date,
    job_stream_name facility,
    substr(category,1,25) category,
--    job_no,
    start_date,
    end_date,
    round(job_duration, 2) job_duration,
    round(total_duration,2) total_duration,
        CASE WHEN
            total_duration = 0
        THEN
            0
        ELSE
            round( (job_duration * 100) / total_duration,2)
        END
    AS percentage
FROM
    (
        SELECT
            job_stream_id,
            job_stream_history_id,
            job_stream_name,
            category,
            MIN(job_no) job_no,
            TO_CHAR(run_date,'MM/DD/YYYY hh24:mi:ss') run_date,
            TO_CHAR(MIN(jh_start_date),'MM/DD/YYYY hh24:mi:ss') start_date,
            TO_CHAR(MAX(jh_end_date),'MM/DD/YYYY hh24:mi:ss') end_date,--round((max(jh_end_date) - min(jh_start_date))*24,2) duration,
            ( SUM( (MAX(jh_end_date) - MIN(jh_start_date) ) * 24) OVER(
                PARTITION BY job_stream_history_id,category
            ) ) AS job_duration,
            ( SUM( (MAX(jh_end_date) - MIN(jh_start_date) ) * 24) OVER(
                PARTITION BY job_stream_history_id
            ) ) AS total_duration
        FROM
            (
                SELECT
                    jsjh.job_stream_id,
                    job_stream_history_id,
                    jsjh.job_no,
                    jt.id,
                    jseqh.jh_start_date,
                    jseqh.jh_end_date,/*to_char(jseqh.jh_start_date,'MM/DD/YYYY hh24:mi:ss') start_date,to_char(jseqh.jh_end_date,'MM/DD/YYYY hh24:mi:ss') end_date,*/
                    jt.name,
                    js.name job_stream_name,
                    jsh.job_stream_date run_date,
                        CASE WHEN
                            jh.name LIKE '835 Data Load%'
                        THEN
                            '835 Load'
                        WHEN
                            jh.name LIKE 'Data Load 9.0%'
                        THEN
                            'PAS Load'
                        WHEN
                            jh.name LIKE 'Nightly Calc%'
                        THEN
                            'Nightly Calc'
                        WHEN
                            jh.name LIKE '837 Data Load%'
                        THEN
                            '837 Load'
                        WHEN
                            jh.name LIKE '%PIC Pro ETL%'
                        THEN
                            'PIC Pro ETL'
                        WHEN
                            jh.name LIKE 'Auto Rule%'
                        THEN
                            'Assignment Rules'
                        WHEN
                            jh.name LIKE 'Create CA%'
                        THEN
                            'CA'
                        WHEN
                            jh.name LIKE 'PIC Pro Assignment Rules'
                        THEN
                            'Pro AR'
                        WHEN
                            jh.name LIKE '%Dashboard%'
                        THEN
                            'Report'
                        WHEN
                            jh.name LIKE '%mail%'
                        THEN
                            'Email'			    
                        ELSE
                            jh.name--'Others'
                        END
                    category
                FROM
                    job_stream_history jsh,
                    job_stream js,
                    job_stream_job_history jsjh,
                    job_template jt,
                    job_history jh,
                    (
                        SELECT
                            job_history_id,
                            MIN(start_date) jh_start_date,
                            MAX(end_date) jh_end_date
                        FROM
                            job_sequence_history
                        WHERE
--                            start_date >= SYSDATE - 30
      start_date between to_date('&start', 'MM/DD/YYYY HH24:MI:SS') and to_date('&end', 'MM/DD/YYYY HH24:MI:SS')
                        GROUP BY
                            job_history_id
                    ) jseqh
                WHERE
--                    jsh.job_stream_date >= SYSDATE - 23
      jsh.job_stream_date between to_date('&start', 'MM/DD/YYYY HH24:MI:SS') and to_date('&end', 'MM/DD/YYYY HH24:MI:SS')
                AND
                    jsh.job_stream_id = js.id
                AND
                    jsh.id = jsjh.job_stream_history_id
                AND
                    jsjh.job_template_id = jt.id
                AND
                    jsjh.job_no = jh.job_no
                AND
                    jh.id = jseqh.job_history_id
--		AND
--		    jh.name NOT LIKE '%DLI %'
                AND
		    js.name NOT LIKE '%DLI%'
            ) jobs_by_stream
        GROUP BY
            job_stream_id,
            job_stream_history_id,
            job_stream_name,
            run_date,
            category
        ORDER BY
            job_stream_history_id,
            MIN(jh_start_date)
    )
    order by hid, start_date;

spool off
set sqlformat ansiconsole
set feedback on
exit

