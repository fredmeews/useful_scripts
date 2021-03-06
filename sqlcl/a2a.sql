-- ACCOUNT LEVEL COUNT
(select 'ETL' as source, mon_acct_id, count(*) from claim_etl_bkp group by mon_acct_id
minus 
select 'ETL' as source, mon_acct_id, count(*) from claim_plsql_bkp group by mon_acct_id)
union all
(select 'PL/SQL' as source, mon_acct_id, count(*) from claim_plsql_bkp group by mon_acct_id
minus 
select 'PL/SQL' as source, mon_acct_id, count(*) from claim_etl_bkp group by mon_acct_id) order by mon_acct_id, source;

-- CLAIM TYPE COUNT
(select 'ETL' as source, claim_type, count(*) from claim_etl_bkp group by claim_type
minus 
select 'ETL' as source, claim_type, count(*) from claim_plsql_bkp group by claim_type)
union all
(select 'PL/SQL' as source, claim_type, count(*) from claim_plsql_bkp group by claim_type
minus 
select 'PL/SQL' as source, claim_type, count(*) from claim_etl_bkp group by claim_type) order by claim_type, source;

-- ACCOUNT LEVEL COUNT - INST CLAIMS ONLY
(select 'ETL' as source, mon_acct_id, count(*) from claim_etl_bkp where claim_type = 2666347 group by mon_acct_id
minus 
select 'ETL' as source, mon_acct_id, count(*) from claim_plsql_bkp where claim_type = 2666347 group by mon_acct_id)
union all
(select 'PL/SQL' as source, mon_acct_id, count(*) from claim_plsql_bkp where claim_type = 2666347 group by mon_acct_id
minus 
select 'PL/SQL' as source, mon_acct_id, count(*) from claim_etl_bkp where claim_type = 2666347 group by mon_acct_id) order by mon_acct_id, source;

-- ACCOUNT or UCRN
select a.job_no, a.claim_number, a.account_no, a.admit_date_and_hour, a.DISCHARGE_HOUR, a.STATEMENT_DATES, 
a.ORIG_UCRN_ON_FILE, a.error_message
from CLAIM_UPLOAD_plsql_bkp a 
where a.account_no = '0127045036032';

select a.job_no, a.claim_number, a.account_no, a.admit_date_and_hour, a.DISCHARGE_HOUR, a.STATEMENT_DATES, 
a.ORIG_UCRN_ON_FILE, a.error_message
from CLAIM_UPLOAD_etl_bkp a 
where a.account_no in ('0127045036032');

select * from claim_detail_upload where job_no = 28535616	and claim_number = 287;

-- Loaded in PL/SQL but rejected in ETL
with orig as (select claim_number, account_no, ORIG_UCRN_ON_FILE from CLAIM_UPLOAD_plsql_bkp where error_message = 'Loaded')
select b.job_no, b.claim_number, b.account_no, b.ORIG_UCRN_ON_FILE, b.error_message
from CLAIM_UPLOAD_etl_bkp b, orig a
where b.claim_number = a.claim_number and 
  nvl(b.ORIG_UCRN_ON_FILE, b.account_no) = nvl(a.ORIG_UCRN_ON_FILE, a.account_no)
  and b.error_message not in ('Loaded', 'Professional Service From Date is greater than Service To Date')
  and not (b.account_no = '02206966');
  
-- Loaded in ETL but rejected in PL/SQL
with orig as (select claim_number, account_no, ORIG_UCRN_ON_FILE from CLAIM_UPLOAD where error_message = 'Loaded')
select b.job_no, b.claim_number, b.account_no, b.ORIG_UCRN_ON_FILE, b.error_message
from CLAIM_UPLOAD_plsql_bkp b, orig a
where b.claim_number = a.claim_number and 
  nvl(b.ORIG_UCRN_ON_FILE, b.account_no) = nvl(a.ORIG_UCRN_ON_FILE, a.account_no)
  and b.error_message != 'Loaded';
  
-- DATA MATCH CARR LOC CODE
select * from claim_detail_upload where job_no = 28526194	and claim_number = 2;
select PROVIDER_STATE, PROVIDER_ZIP_CODE, SERVICE_FACILITY_STATE, SERVICE_FACILITY_ZIP 
from claim_upload_etl_bkp where job_no = 28526194	and claim_number = 2;
select * from carrier_locality_master where state='MI' and zip_code='48118';

-- CLAIM LEVEL COLUMN DATA
(Select 'ETL' as source,
MON_ACCT_ID,PATIENT_CONTROL_NO,ADMIT_SOURCE,ADMIT_TYPE,DRG,BILL_TYPE,PT_LAST_NAME,PT_FIRST_NAME,PT_MIDDLE_NAME,PT_NAME_SUFFIX,PT_ADDRESS1,PT_ADDRESS2,PT_CITY,PT_STATE,PT_ZIP,PT_COUNTRY,PT_GENDER,PT_MARITAL_STATUS,PT_STATUS,REMARK_1,REMARK_2,REMARK_3,REMARK_4,TOTAL_ACTUAL_PAYMENTS,TOTAL_CHARGES,PAYER_NAME_BILLED_TO,MEDICAL_RECORD_NUMBER,FIELD_11,BILLED_TO_PAYER_ADDRESS1,BILLED_TO_PAYER_ADDRESS2,BILLED_TO_PAYER_CITY,BILLED_TO_PAYER_STATE,BILLED_TO_PAYER_ZIP,CLAIM_TYPE,RANK,PROVIDER_NO,ISANSI837,DRG_TYPE,DRG_VERSION,ACCIDENT_CODE,ACCIDENT_LOC_STATE,ACCIDENT_DATE,CODE_CODE_VAL1,CODE_CODE_VAL2,CODE_CODE_VAL3,CODE_CODE_VAL4,CODE_CODE_VAL5,CODE_CODE_VAL6,CODE_CODE_VAL7,CODE_CODE_VAL8,CODE_CODE_VAL9,ICD_DCN_1,ICD_DCN_2,ICD_DCN_3,ICD_DX_VER_QUAL,PT_NAME_ID,PAY_TO_PROV_NAME,PAY_TO_PROV_ADDRESS,PAY_TO_PROV_CSZ,PAY_TO_PROV_ID_CODE,NPI,PROVIDER_ID_OTHER1,PROVIDER_ID_OTHER2,PROVIDER_ID_OTHER3,PAY_TO_PROV_CITY,PAY_TO_PROV_STATE,PAY_TO_PROV_ZIP,SERVICE_FACILITY_NPI_QUAL,SERVICE_FACILITY_NPI,SERVICE_FACILITY_REND_ID_QUAL,SERVICE_FACILITY_RENDERING_ID,SERVICE_FACILITY_NAME,SERVICE_FACILITY_ADDRESS1,SERVICE_FACILITY_ADDRESS2,SERVICE_FACILITY_CITY,SERVICE_FACILITY_STATE,SERVICE_FACILITY_ZIP,TAXONOMY_CODE,COVERED_CHARGES,INSUR_ID_BILLED_TO,ORIG_PATIENT_CONTROL_NO,DRG_SEVERITY_LEVEL,LOAD_TYPE,CE_PATIENT_TYPE_ID,IP_OP_IND,CE_CLAIM_BILL_TYPE_PROFILE_ID,FACILITY_TYPE,CLAIM_FREQUENCY_CODE,CE_PATIENT_POPULATION_ID,
--ADMIT_DATE,DATE_BILLED,DISCHARGE_DATE,PT_BIRTHDATE,STATEMENT_FROM,STATEMENT_TO,
PX_CODING_METHOD,DELETED_YN,MON_PRACTITIONER_ID
--DAYS_COVERED,DAYS_NON_COVERED,DAYS_COINSURANCE,DAYS_LIFETIME_RESERVE,IS_DERIVE_3X,DEACTIVATION_OVERRIDE,INDUSTRY_IDENTIFIER_CODE
FROM CLAIM_etl_bkp 
MINUS
Select 'ETL' as source,
MON_ACCT_ID,PATIENT_CONTROL_NO,ADMIT_SOURCE,ADMIT_TYPE,DRG,BILL_TYPE,PT_LAST_NAME,PT_FIRST_NAME,PT_MIDDLE_NAME,PT_NAME_SUFFIX,PT_ADDRESS1,PT_ADDRESS2,PT_CITY,PT_STATE,PT_ZIP,PT_COUNTRY,PT_GENDER,PT_MARITAL_STATUS,PT_STATUS,REMARK_1,REMARK_2,REMARK_3,REMARK_4,TOTAL_ACTUAL_PAYMENTS,TOTAL_CHARGES,PAYER_NAME_BILLED_TO,MEDICAL_RECORD_NUMBER,FIELD_11,BILLED_TO_PAYER_ADDRESS1,BILLED_TO_PAYER_ADDRESS2,BILLED_TO_PAYER_CITY,BILLED_TO_PAYER_STATE,BILLED_TO_PAYER_ZIP,CLAIM_TYPE,RANK,PROVIDER_NO,ISANSI837,DRG_TYPE,DRG_VERSION,ACCIDENT_CODE,ACCIDENT_LOC_STATE,ACCIDENT_DATE,CODE_CODE_VAL1,CODE_CODE_VAL2,CODE_CODE_VAL3,CODE_CODE_VAL4,CODE_CODE_VAL5,CODE_CODE_VAL6,CODE_CODE_VAL7,CODE_CODE_VAL8,CODE_CODE_VAL9,ICD_DCN_1,ICD_DCN_2,ICD_DCN_3,ICD_DX_VER_QUAL,PT_NAME_ID,PAY_TO_PROV_NAME,PAY_TO_PROV_ADDRESS,PAY_TO_PROV_CSZ,PAY_TO_PROV_ID_CODE,NPI,PROVIDER_ID_OTHER1,PROVIDER_ID_OTHER2,PROVIDER_ID_OTHER3,PAY_TO_PROV_CITY,PAY_TO_PROV_STATE,PAY_TO_PROV_ZIP,SERVICE_FACILITY_NPI_QUAL,SERVICE_FACILITY_NPI,SERVICE_FACILITY_REND_ID_QUAL,SERVICE_FACILITY_RENDERING_ID,SERVICE_FACILITY_NAME,SERVICE_FACILITY_ADDRESS1,SERVICE_FACILITY_ADDRESS2,SERVICE_FACILITY_CITY,SERVICE_FACILITY_STATE,SERVICE_FACILITY_ZIP,TAXONOMY_CODE,COVERED_CHARGES,INSUR_ID_BILLED_TO,ORIG_PATIENT_CONTROL_NO,DRG_SEVERITY_LEVEL,LOAD_TYPE,CE_PATIENT_TYPE_ID,IP_OP_IND,CE_CLAIM_BILL_TYPE_PROFILE_ID,FACILITY_TYPE,CLAIM_FREQUENCY_CODE,CE_PATIENT_POPULATION_ID,
--ADMIT_DATE,DATE_BILLED,DISCHARGE_DATE,PT_BIRTHDATE,STATEMENT_FROM,STATEMENT_TO,
PX_CODING_METHOD,DELETED_YN,MON_PRACTITIONER_ID
--DAYS_COVERED,DAYS_NON_COVERED,DAYS_COINSURANCE,DAYS_LIFETIME_RESERVE,IS_DERIVE_3X,DEACTIVATION_OVERRIDE,INDUSTRY_IDENTIFIER_CODE
FROM CLAIM_plsql_bkp )
union all
(Select 'PL/SQL' as source,
MON_ACCT_ID,PATIENT_CONTROL_NO,ADMIT_SOURCE,ADMIT_TYPE,DRG,BILL_TYPE,PT_LAST_NAME,PT_FIRST_NAME,PT_MIDDLE_NAME,PT_NAME_SUFFIX,PT_ADDRESS1,PT_ADDRESS2,PT_CITY,PT_STATE,PT_ZIP,PT_COUNTRY,PT_GENDER,PT_MARITAL_STATUS,PT_STATUS,REMARK_1,REMARK_2,REMARK_3,REMARK_4,TOTAL_ACTUAL_PAYMENTS,TOTAL_CHARGES,PAYER_NAME_BILLED_TO,MEDICAL_RECORD_NUMBER,FIELD_11,BILLED_TO_PAYER_ADDRESS1,BILLED_TO_PAYER_ADDRESS2,BILLED_TO_PAYER_CITY,BILLED_TO_PAYER_STATE,BILLED_TO_PAYER_ZIP,CLAIM_TYPE,RANK,PROVIDER_NO,ISANSI837,DRG_TYPE,DRG_VERSION,ACCIDENT_CODE,ACCIDENT_LOC_STATE,ACCIDENT_DATE,CODE_CODE_VAL1,CODE_CODE_VAL2,CODE_CODE_VAL3,CODE_CODE_VAL4,CODE_CODE_VAL5,CODE_CODE_VAL6,CODE_CODE_VAL7,CODE_CODE_VAL8,CODE_CODE_VAL9,ICD_DCN_1,ICD_DCN_2,ICD_DCN_3,ICD_DX_VER_QUAL,PT_NAME_ID,PAY_TO_PROV_NAME,PAY_TO_PROV_ADDRESS,PAY_TO_PROV_CSZ,PAY_TO_PROV_ID_CODE,NPI,PROVIDER_ID_OTHER1,PROVIDER_ID_OTHER2,PROVIDER_ID_OTHER3,PAY_TO_PROV_CITY,PAY_TO_PROV_STATE,PAY_TO_PROV_ZIP,SERVICE_FACILITY_NPI_QUAL,SERVICE_FACILITY_NPI,SERVICE_FACILITY_REND_ID_QUAL,SERVICE_FACILITY_RENDERING_ID,SERVICE_FACILITY_NAME,SERVICE_FACILITY_ADDRESS1,SERVICE_FACILITY_ADDRESS2,SERVICE_FACILITY_CITY,SERVICE_FACILITY_STATE,SERVICE_FACILITY_ZIP,TAXONOMY_CODE,COVERED_CHARGES,INSUR_ID_BILLED_TO,ORIG_PATIENT_CONTROL_NO,DRG_SEVERITY_LEVEL,LOAD_TYPE,CE_PATIENT_TYPE_ID,IP_OP_IND,CE_CLAIM_BILL_TYPE_PROFILE_ID,FACILITY_TYPE,CLAIM_FREQUENCY_CODE,CE_PATIENT_POPULATION_ID,
--ADMIT_DATE,DATE_BILLED,DISCHARGE_DATE,PT_BIRTHDATE,STATEMENT_FROM,STATEMENT_TO,
PX_CODING_METHOD,DELETED_YN,MON_PRACTITIONER_ID
--DAYS_COVERED,DAYS_NON_COVERED,DAYS_COINSURANCE,DAYS_LIFETIME_RESERVE,IS_DERIVE_3X,DEACTIVATION_OVERRIDE,INDUSTRY_IDENTIFIER_CODE
FROM CLAIM_plsql_bkp 
MINUS
Select 'PL/SQL' as source,
MON_ACCT_ID,PATIENT_CONTROL_NO,ADMIT_SOURCE,ADMIT_TYPE,DRG,BILL_TYPE,PT_LAST_NAME,PT_FIRST_NAME,PT_MIDDLE_NAME,PT_NAME_SUFFIX,PT_ADDRESS1,PT_ADDRESS2,PT_CITY,PT_STATE,PT_ZIP,PT_COUNTRY,PT_GENDER,PT_MARITAL_STATUS,PT_STATUS,REMARK_1,REMARK_2,REMARK_3,REMARK_4,TOTAL_ACTUAL_PAYMENTS,TOTAL_CHARGES,PAYER_NAME_BILLED_TO,MEDICAL_RECORD_NUMBER,FIELD_11,BILLED_TO_PAYER_ADDRESS1,BILLED_TO_PAYER_ADDRESS2,BILLED_TO_PAYER_CITY,BILLED_TO_PAYER_STATE,BILLED_TO_PAYER_ZIP,CLAIM_TYPE,RANK,PROVIDER_NO,ISANSI837,DRG_TYPE,DRG_VERSION,ACCIDENT_CODE,ACCIDENT_LOC_STATE,ACCIDENT_DATE,CODE_CODE_VAL1,CODE_CODE_VAL2,CODE_CODE_VAL3,CODE_CODE_VAL4,CODE_CODE_VAL5,CODE_CODE_VAL6,CODE_CODE_VAL7,CODE_CODE_VAL8,CODE_CODE_VAL9,ICD_DCN_1,ICD_DCN_2,ICD_DCN_3,ICD_DX_VER_QUAL,PT_NAME_ID,PAY_TO_PROV_NAME,PAY_TO_PROV_ADDRESS,PAY_TO_PROV_CSZ,PAY_TO_PROV_ID_CODE,NPI,PROVIDER_ID_OTHER1,PROVIDER_ID_OTHER2,PROVIDER_ID_OTHER3,PAY_TO_PROV_CITY,PAY_TO_PROV_STATE,PAY_TO_PROV_ZIP,SERVICE_FACILITY_NPI_QUAL,SERVICE_FACILITY_NPI,SERVICE_FACILITY_REND_ID_QUAL,SERVICE_FACILITY_RENDERING_ID,SERVICE_FACILITY_NAME,SERVICE_FACILITY_ADDRESS1,SERVICE_FACILITY_ADDRESS2,SERVICE_FACILITY_CITY,SERVICE_FACILITY_STATE,SERVICE_FACILITY_ZIP,TAXONOMY_CODE,COVERED_CHARGES,INSUR_ID_BILLED_TO,ORIG_PATIENT_CONTROL_NO,DRG_SEVERITY_LEVEL,LOAD_TYPE,CE_PATIENT_TYPE_ID,IP_OP_IND,CE_CLAIM_BILL_TYPE_PROFILE_ID,FACILITY_TYPE,CLAIM_FREQUENCY_CODE,CE_PATIENT_POPULATION_ID,
--ADMIT_DATE,DATE_BILLED,DISCHARGE_DATE,PT_BIRTHDATE,STATEMENT_FROM,STATEMENT_TO,
PX_CODING_METHOD,DELETED_YN,MON_PRACTITIONER_ID
--DAYS_COVERED,DAYS_NON_COVERED,DAYS_COINSURANCE,DAYS_LIFETIME_RESERVE,IS_DERIVE_3X,DEACTIVATION_OVERRIDE,INDUSTRY_IDENTIFIER_CODE
FROM CLAIM_etl_bkp ) order by PATIENT_CONTROL_NO, source;

/*
CLAIM_plsql_bkp
CLAIM_CHARGE_1500_plsql_bkp
CLAIM_CHARGE_UB_plsql_bkp
CLAIM_CODE_plsql_bkp
CLAIM_NONCLINICAL_CODE_plsql_bkp
CLAIM_PAYER_plsql_bkp
CLAIM_PHYSICIAN_plsql_bkp
CLAIM_PROVIDER_plsql_bkp
CLAIM_UPLOAD_plsql_bkp
mon_account_payer_plsql_bkp
mon_account_plsql_bkp
claim_account_level_plsql_bkp
*/

with orig as (select claim_number, account_no, ORIG_UCRN_ON_FILE from CLAIM_UPLOAD_plsql_bkp where error_message = 'Loaded')
select b.job_no, b.claim_number, b.account_no, b.ORIG_UCRN_ON_FILE, b.error_message
from CLAIM_UPLOAD_etl_bkp b, orig a
where b.claim_number = a.claim_number and 
  nvl(b.ORIG_UCRN_ON_FILE, b.account_no) = nvl(a.ORIG_UCRN_ON_FILE, a.account_no)
  and b.error_message in ('Professional Service From Date is greater than Service To Date');
-- 28535556
-- 28535616



select count(*) from claim_detail_upload cdu, claim_upload_plsql_bkp cu
where cu.job_no in (10298964, 10299014) and cdu.job_no in (28535556, 28535616)
and cu.claim_number = cdu.claim_number and cu.error_message = 'Loaded'
and case when cu.job_no = 10298964 and cdu.job_no = 28535556 then 1
when cu.job_no = 10299014 and cdu.job_no = 28535616 then 1
else 0 end = 1
;
-- 2109 - count of prof lines as per CDU for successfully loaded claims - pl/sql
-- 1544 - actually loaded
-- 565 - not loaded by pl/sql

select count(*) from claim_detail_upload where job_no in (28535556, 28535616) and claim_type='H';
select count(*) from claim_charge_1500_plsql_bkp a, claim_plsql_bkp b 
where a.claim_id = b.id and b.job_no in (10298964, 10299014);

(Select 'ETL' as source, 
AMOUNT,COB_IND,EMERGENCY_IND,EPSDT_IND,HCFA_LINE24K,HCPCS_CODE,HCPCS_MODIFIER_1,HCPCS_MODIFIER_2,HCPCS_MODIFIER_3,HCPCS_MODIFIER_4,QUANTITY,SERVICE_DATE_END,SERVICE_DATE_START,PLACE_OF_SERVICE,DIAGNOSIS_CODE_POINTER,LINE_NO,mp.org_id, mp.npi, mp.ssn, mp.ein, CARRIER_CODE,LOC_CODE,RENDERING_PROVIDER_ID_QUAL,RENDERING_PROVIDER_ID,RENDERING_NPI_QUAL,RENDERING_NPI,IS_DELETED
FROM CLAIM_CHARGE_1500_etl_bkp c
, mon_practitioner mp where mp.id = c.mon_practitioner_id
MINUS
Select 'ETL' as source,
AMOUNT,COB_IND,EMERGENCY_IND,EPSDT_IND,HCFA_LINE24K,HCPCS_CODE,HCPCS_MODIFIER_1,HCPCS_MODIFIER_2,HCPCS_MODIFIER_3,HCPCS_MODIFIER_4,QUANTITY,SERVICE_DATE_END,SERVICE_DATE_START,PLACE_OF_SERVICE,DIAGNOSIS_CODE_POINTER,LINE_NO,mp.org_id, mp.npi, mp.ssn, mp.ein, CARRIER_CODE,LOC_CODE,RENDERING_PROVIDER_ID_QUAL,RENDERING_PROVIDER_ID,RENDERING_NPI_QUAL,RENDERING_NPI,IS_DELETED
FROM CLAIM_CHARGE_1500_plsql_bkp c 
, mon_practitioner mp where mp.id = c.mon_practitioner_id
)union all
(Select 'PL/SQL' as source,
AMOUNT,COB_IND,EMERGENCY_IND,EPSDT_IND,HCFA_LINE24K,HCPCS_CODE,HCPCS_MODIFIER_1,HCPCS_MODIFIER_2,HCPCS_MODIFIER_3,HCPCS_MODIFIER_4,QUANTITY,SERVICE_DATE_END,SERVICE_DATE_START,PLACE_OF_SERVICE,DIAGNOSIS_CODE_POINTER,LINE_NO,mp.org_id, mp.npi, mp.ssn, mp.ein, CARRIER_CODE,LOC_CODE,RENDERING_PROVIDER_ID_QUAL,RENDERING_PROVIDER_ID,RENDERING_NPI_QUAL,RENDERING_NPI,IS_DELETED
FROM CLAIM_CHARGE_1500_plsql_bkp c
, mon_practitioner mp where mp.id = c.mon_practitioner_id
MINUS
Select 'PL/SQL' as source,
AMOUNT,COB_IND,EMERGENCY_IND,EPSDT_IND,HCFA_LINE24K,HCPCS_CODE,HCPCS_MODIFIER_1,HCPCS_MODIFIER_2,HCPCS_MODIFIER_3,HCPCS_MODIFIER_4,QUANTITY,SERVICE_DATE_END,SERVICE_DATE_START,PLACE_OF_SERVICE,DIAGNOSIS_CODE_POINTER,LINE_NO,mp.org_id, mp.npi, mp.ssn, mp.ein, CARRIER_CODE,LOC_CODE,RENDERING_PROVIDER_ID_QUAL,RENDERING_PROVIDER_ID,RENDERING_NPI_QUAL,RENDERING_NPI,IS_DELETED
FROM CLAIM_CHARGE_1500_etl_bkp c
, mon_practitioner mp where mp.id = c.mon_practitioner_id
) order by hcpcs_code, service_date_start, npi, source;


(Select 'ETL' as source, 
REVENUE_CODE,FORM_LOCATOR_49,HCPCS_CODE,NON_COVERED_CHARGES,RATE,SERVICE_DATE,TOTAL_CHARGES,UNITS,LINE_NO,HCPCS_MODIFIER_1,HCPCS_MODIFIER_2,HCPCS_MODIFIER_3,HCPCS_MODIFIER_4,SERVICE_DATE_TO,NDC_CODE
FROM CLAIM_CHARGE_UB_etl_bkp c
MINUS
Select 'ETL' as source,
REVENUE_CODE,FORM_LOCATOR_49,HCPCS_CODE,NON_COVERED_CHARGES,RATE,SERVICE_DATE,TOTAL_CHARGES,UNITS,LINE_NO,HCPCS_MODIFIER_1,HCPCS_MODIFIER_2,HCPCS_MODIFIER_3,HCPCS_MODIFIER_4,SERVICE_DATE_TO,NDC_CODE
FROM CLAIM_CHARGE_UB_plsql_bkp c 
)union all
(Select 'PL/SQL' as source,
REVENUE_CODE,FORM_LOCATOR_49,HCPCS_CODE,NON_COVERED_CHARGES,RATE,SERVICE_DATE,TOTAL_CHARGES,UNITS,LINE_NO,HCPCS_MODIFIER_1,HCPCS_MODIFIER_2,HCPCS_MODIFIER_3,HCPCS_MODIFIER_4,SERVICE_DATE_TO,NDC_CODE
FROM CLAIM_CHARGE_UB_plsql_bkp c
MINUS
Select 'PL/SQL' as source,
REVENUE_CODE,FORM_LOCATOR_49,HCPCS_CODE,NON_COVERED_CHARGES,RATE,SERVICE_DATE,TOTAL_CHARGES,UNITS,LINE_NO,HCPCS_MODIFIER_1,HCPCS_MODIFIER_2,HCPCS_MODIFIER_3,HCPCS_MODIFIER_4,SERVICE_DATE_TO,NDC_CODE
FROM CLAIM_CHARGE_UB_etl_bkp c
);


(Select 'ETL' as source, 
CODE,CODE_DATE,CODE_TYPE,VERSION_ID,RANK,MODIFIER_1,MODIFIER_2,POA_INDICATOR,DX_TYPE_INDICATOR
FROM CLAIM_CODE_etl_bkp c
MINUS
Select 'ETL' as source,
CODE,CODE_DATE,CODE_TYPE,VERSION_ID,RANK,MODIFIER_1,MODIFIER_2,POA_INDICATOR,DX_TYPE_INDICATOR
FROM CLAIM_CODE_plsql_bkp c 
)union all
(Select 'PL/SQL' as source,
CODE,CODE_DATE,CODE_TYPE,VERSION_ID,RANK,MODIFIER_1,MODIFIER_2,POA_INDICATOR,DX_TYPE_INDICATOR
FROM CLAIM_CODE_plsql_bkp c
MINUS
Select 'PL/SQL' as source,
CODE,CODE_DATE,CODE_TYPE,VERSION_ID,RANK,MODIFIER_1,MODIFIER_2,POA_INDICATOR,DX_TYPE_INDICATOR
FROM CLAIM_CODE_etl_bkp c
);

(Select 'ETL' as source, 
CODE_CATEGORY,RANK,CODE,nvl(AMOUNT,0),CODE_DATE,CODE_DATE_TO
FROM CLAIM_NONCLINICAL_CODE_etl_bkp c
MINUS
Select 'ETL' as source,
CODE_CATEGORY,RANK,CODE,nvl(AMOUNT,0),CODE_DATE,CODE_DATE_TO
FROM CLAIM_NONCLINICAL_CODE_plsql_bkp c 
)union all
(Select 'PL/SQL' as source,
CODE_CATEGORY,RANK,CODE,nvl(AMOUNT,0),CODE_DATE,CODE_DATE_TO
FROM CLAIM_NONCLINICAL_CODE_plsql_bkp c
MINUS
Select 'PL/SQL' as source,
CODE_CATEGORY,RANK,CODE,nvl(AMOUNT,0),CODE_DATE,CODE_DATE_TO
FROM CLAIM_NONCLINICAL_CODE_etl_bkp c
);

/*
CLAIM_plsql_bkp
CLAIM_CHARGE_1500_plsql_bkp
CLAIM_CHARGE_UB_plsql_bkp
CLAIM_CODE_plsql_bkp
CLAIM_NONCLINICAL_CODE_plsql_bkp
CLAIM_PAYER_plsql_bkp
CLAIM_PHYSICIAN_plsql_bkp
CLAIM_PROVIDER_plsql_bkp
CLAIM_UPLOAD_plsql_bkp
mon_account_payer_plsql_bkp
mon_account_plsql_bkp
claim_account_level_plsql_bkp
*/

(Select 'ETL' as source, 
claim.PATIENT_CONTROL_NO, C.RANK,c.ASSIGN_BENEFIT,c.AUTHORIZATION_CODE,c.EST_AMOUNT_DUE,c.GROUP_NAME,c.INSURANCE_GROUP_NO,rtrim(c.INSURED_NAME),c.PAYER_IDENTIFICATION_NO,c.PAYER_NAME,c.PRIOR_PAYMENTS,c.PROVIDER_NO,c.REL_TO_INSURED,c.RELEASE_INFO,c.IS_BILLED_TO,c.CLAIM_FILE_IND_CODE,c.HEALTH_PLAN_ID
FROM CLAIM_PAYER_etl_bkp c
, claim where claim.id = c.claim_id
MINUS
Select 'ETL' as source,
claim.PATIENT_CONTROL_NO, C.RANK,c.ASSIGN_BENEFIT,c.AUTHORIZATION_CODE,c.EST_AMOUNT_DUE,c.GROUP_NAME,c.INSURANCE_GROUP_NO,rtrim(c.INSURED_NAME),c.PAYER_IDENTIFICATION_NO,c.PAYER_NAME,c.PRIOR_PAYMENTS,c.PROVIDER_NO,c.REL_TO_INSURED,c.RELEASE_INFO,c.IS_BILLED_TO,c.CLAIM_FILE_IND_CODE,c.HEALTH_PLAN_ID
FROM CLAIM_PAYER_plsql_bkp c 
, claim_plsql_bkp claim where claim.id = c.claim_id
)union all
(Select 'PL/SQL' as source,
claim.PATIENT_CONTROL_NO, C.RANK,c.ASSIGN_BENEFIT,c.AUTHORIZATION_CODE,c.EST_AMOUNT_DUE,c.GROUP_NAME,c.INSURANCE_GROUP_NO,rtrim(c.INSURED_NAME),c.PAYER_IDENTIFICATION_NO,c.PAYER_NAME,c.PRIOR_PAYMENTS,c.PROVIDER_NO,c.REL_TO_INSURED,c.RELEASE_INFO,c.IS_BILLED_TO,c.CLAIM_FILE_IND_CODE,c.HEALTH_PLAN_ID
FROM CLAIM_PAYER_plsql_bkp c
, claim_plsql_bkp claim where claim.id = c.claim_id
MINUS
Select 'PL/SQL' as source,
claim.PATIENT_CONTROL_NO, C.RANK,c.ASSIGN_BENEFIT,c.AUTHORIZATION_CODE,c.EST_AMOUNT_DUE,c.GROUP_NAME,c.INSURANCE_GROUP_NO,rtrim(c.INSURED_NAME),c.PAYER_IDENTIFICATION_NO,c.PAYER_NAME,c.PRIOR_PAYMENTS,c.PROVIDER_NO,c.REL_TO_INSURED,c.RELEASE_INFO,c.IS_BILLED_TO,c.CLAIM_FILE_IND_CODE,c.HEALTH_PLAN_ID
FROM CLAIM_PAYER_etl_bkp c
, claim where claim.id = c.claim_id
) order by PATIENT_CONTROL_NO, rank, source;


(Select 'ETL' as source, 
claim.PATIENT_CONTROL_NO,c.PHYSICIAN_CATEGORY,c.FIRST_NAME,c.LAST_NAME,c.SUFFIX,c.NPI,c.OTHER_ID_QUALIFIER,c.OTHER_ID,c.OTHER_ID2_QUALIFIER,c.OTHER_ID2,c.OTHER_ID3_QUALIFIER,c.OTHER_ID3,c.OTHER_ID4_QUALIFIER,c.OTHER_ID4
FROM CLAIM_PHYSICIAN_etl_bkp c
, claim where claim.id = c.claim_id
MINUS
Select 'ETL' as source,
claim.PATIENT_CONTROL_NO,c.PHYSICIAN_CATEGORY,c.FIRST_NAME,c.LAST_NAME,c.SUFFIX,c.NPI,c.OTHER_ID_QUALIFIER,c.OTHER_ID,c.OTHER_ID2_QUALIFIER,c.OTHER_ID2,c.OTHER_ID3_QUALIFIER,c.OTHER_ID3,c.OTHER_ID4_QUALIFIER,c.OTHER_ID4
FROM CLAIM_PHYSICIAN_plsql_bkp c 
, claim_plsql_bkp claim where claim.id = c.claim_id
)union all
(Select 'PL/SQL' as source,
claim.PATIENT_CONTROL_NO,c.PHYSICIAN_CATEGORY,c.FIRST_NAME,c.LAST_NAME,c.SUFFIX,c.NPI,c.OTHER_ID_QUALIFIER,c.OTHER_ID,c.OTHER_ID2_QUALIFIER,c.OTHER_ID2,c.OTHER_ID3_QUALIFIER,c.OTHER_ID3,c.OTHER_ID4_QUALIFIER,c.OTHER_ID4
FROM CLAIM_PHYSICIAN_plsql_bkp c
, claim_plsql_bkp claim where claim.id = c.claim_id
MINUS
Select 'PL/SQL' as source,
claim.PATIENT_CONTROL_NO,c.PHYSICIAN_CATEGORY,c.FIRST_NAME,c.LAST_NAME,c.SUFFIX,c.NPI,c.OTHER_ID_QUALIFIER,c.OTHER_ID,c.OTHER_ID2_QUALIFIER,c.OTHER_ID2,c.OTHER_ID3_QUALIFIER,c.OTHER_ID3,c.OTHER_ID4_QUALIFIER,c.OTHER_ID4
FROM CLAIM_PHYSICIAN_etl_bkp c
, claim where claim.id = c.claim_id
) order by PATIENT_CONTROL_NO, source;

(Select 'ETL' as source, 
NAME,ADDRESS1,ADDRESS2,CITY,STATE,ZIP,TIN,TIN_QUAL,PROVIDER_ID_QUAL,PROVIDER_ID,PROVIDER_PHONE
FROM CLAIM_PROVIDER_etl_bkp c
MINUS
Select 'ETL' as source,
NAME,ADDRESS1,ADDRESS2,CITY,STATE,ZIP,TIN,TIN_QUAL,PROVIDER_ID_QUAL,PROVIDER_ID,PROVIDER_PHONE
FROM CLAIM_PROVIDER_plsql_bkp c 
)union all
(Select 'PL/SQL' as source,
NAME,ADDRESS1,ADDRESS2,CITY,STATE,ZIP,TIN,TIN_QUAL,PROVIDER_ID_QUAL,PROVIDER_ID,PROVIDER_PHONE
FROM CLAIM_PROVIDER_plsql_bkp c
MINUS
Select 'PL/SQL' as source,
NAME,ADDRESS1,ADDRESS2,CITY,STATE,ZIP,TIN,TIN_QUAL,PROVIDER_ID_QUAL,PROVIDER_ID,PROVIDER_PHONE
FROM CLAIM_PROVIDER_etl_bkp c
);

--select distinct source, c.IS_837_CHANGE_TRIGGER,c.CALC_BASE,c.IS_MANUAL_TRIGGER,c.ACCOUNT_CALC_SITUATION, DATE_ACCOUNT_COMPONENT_UPDATED from(
(Select 'ETL' as source, 
claim.PATIENT_CONTROL_NO,c.id,c.IS_837_CHANGE_TRIGGER,c.CALC_BASE,c.IS_MANUAL_TRIGGER,c.ACCOUNT_CALC_SITUATION,
case when c.DATE_ACCOUNT_COMPONENT_UPDATED is null then 'null' else 'not null' end as DATE_ACCOUNT_COMPONENT_UPDATED
FROM mon_account_payer_etl_bkp c
, claim where claim.mon_account_payer_id = c.id and nvl(c.IS_MANUAL_TRIGGER,0) = 0
MINUS
Select 'ETL' as source,
claim.PATIENT_CONTROL_NO,c.id,c.IS_837_CHANGE_TRIGGER,c.CALC_BASE,c.IS_MANUAL_TRIGGER,c.ACCOUNT_CALC_SITUATION,
case when c.DATE_ACCOUNT_COMPONENT_UPDATED is null then 'null' else 'not null' end as DATE_ACCOUNT_COMPONENT_UPDATED
FROM mon_account_payer_plsql_bkp c 
, claim where claim.mon_account_payer_id = c.id and nvl(c.IS_MANUAL_TRIGGER,0) = 0
)union all
(Select 'PL/SQL' as source,
claim.PATIENT_CONTROL_NO,c.id,c.IS_837_CHANGE_TRIGGER,c.CALC_BASE,c.IS_MANUAL_TRIGGER,c.ACCOUNT_CALC_SITUATION,
case when c.DATE_ACCOUNT_COMPONENT_UPDATED is null then 'null' else 'not null' end as DATE_ACCOUNT_COMPONENT_UPDATED
FROM mon_account_payer_plsql_bkp c
, claim where claim.mon_account_payer_id = c.id and nvl(c.IS_MANUAL_TRIGGER,0) = 0
MINUS
Select 'PL/SQL' as source,
claim.PATIENT_CONTROL_NO,c.id,c.IS_837_CHANGE_TRIGGER,c.CALC_BASE,c.IS_MANUAL_TRIGGER,c.ACCOUNT_CALC_SITUATION,
case when c.DATE_ACCOUNT_COMPONENT_UPDATED is null then 'null' else 'not null' end as DATE_ACCOUNT_COMPONENT_UPDATED
FROM mon_account_payer_etl_bkp c
, claim where claim.mon_account_payer_id = c.id and nvl(c.IS_MANUAL_TRIGGER,0) = 0
);

-- PROF REPLACEMENT
(Select 'ETL' as source,
MON_ACCOUNT_PAYER_ID,PATIENT_CONTROL_NO,BILL_TYPE,DATE_BILLED,DELETED_YN,orig_patient_control_no
FROM CLAIM_etl_bkp where claim_type = 2666346
MINUS
Select 'ETL' as source,
MON_ACCOUNT_PAYER_ID,PATIENT_CONTROL_NO,BILL_TYPE,DATE_BILLED,DELETED_YN,orig_patient_control_no
FROM CLAIM_plsql_bkp where claim_type = 2666346)
union all
(Select 'PL/SQL' as source,
MON_ACCOUNT_PAYER_ID,PATIENT_CONTROL_NO,BILL_TYPE,DATE_BILLED,DELETED_YN,orig_patient_control_no
FROM CLAIM_plsql_bkp where claim_type = 2666346
MINUS
Select 'PL/SQL' as source,
MON_ACCOUNT_PAYER_ID,PATIENT_CONTROL_NO,BILL_TYPE,DATE_BILLED,DELETED_YN,orig_patient_control_no
FROM CLAIM_etl_bkp where claim_type = 2666346) order by MON_ACCOUNT_PAYER_ID, orig_patient_control_no, bill_type, source;

