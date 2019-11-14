--set sqlformat ansiconsole;
set sqlformat csv;
-- set sqlformat json;
-- set sqlformat insert;
-- set sqlformat html;

SELECT
     sys_context( 'userenv', 'current_schema' ) member,
     org_id,
     name facility,
     round(AVG(f30cnt)) file_30,
     round(AVG(f835cnt)) file_835,
     round(AVG(f837cnt)) file_837,
     round(AVG(calccnt)) calc_cnt
FROM
    (
        SELECT
            o.org_id,
            o.name,
            TO_CHAR(h.start_date,'mmddyyyy') AS startdate,
            SUM(
                CASE WHEN
                    ir.program_name = 'MON_ACCOUNTS.load'
                THEN
                    nvl(inserts1,0) + nvl(updates1,0)
                ELSE
                    0
                END
            ) AS f30cnt,
            SUM(
                CASE WHEN
                    ir.program_name = 'RA_CLAIM_PAYMENTS.load'
                THEN
                    nvl(inserts1,0) + nvl(updates1,0)
                ELSE
                    0
                END
            ) AS f835cnt,
            SUM(
                CASE WHEN
                    ir.program_name = 'CLAIMS.LOAD'
                THEN
                    nvl(inserts1,0) + nvl(updates1,0)
                ELSE
                    0
                END
            ) AS f837cnt,
            SUM(
                CASE WHEN
                    ir.program_name = 'CE_PROCESS_ACCOUNT_PAYERS.populate_for_data_load'
                THEN
                    nvl(inserts1,0) + nvl(updates1,0)
                ELSE
                    0
                END
            ) AS calccnt
        FROM
            interface_run ir,
            job_history h,
            org o
        WHERE
            ir.job_no = h.job_no
        AND
            h.status = 'Completed'
        AND
--            h.start_date > SYSDATE - 30
            h.start_date between to_date('08-27-2017', 'MM-DD-YYYY') and to_date('08-29-2017', 'MM-DD-YYYY')
        AND
            ir.org_id = o.org_id
--
        AND (
                lower(h.name) LIKE 'data load%'
            OR
                lower(h.name) LIKE '%nightly calc%'
            OR
                h.name LIKE '835%'
            OR
                h.name LIKE '837%'
        ) GROUP BY
            o.org_id,
            o.name,
            TO_CHAR(h.start_date,'mmddyyyy')
    )
GROUP BY
    org_id,
    name
ORDER BY member, file_30 desc;

set sqlformat ansiconsole;
