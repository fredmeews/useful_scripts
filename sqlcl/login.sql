set sqlformat ansiconsole;
set termout on
set feedback on
set verify off
cd /Users/hughese/src/useful_scripts/sqlcl

-- Custom commands
script custom.js

-- Customize prompt
script sqlprompt.js


-- alias jobs=@jobs/jobs.sql;
alias jobhist=script jobs/status.js history 0 1;
alias top=@jobs/top2;

alias clientinfo=script jobs/clientinfo.js;
alias whoami=select sys_context( 'userenv', 'current_schema' ) current_schema from dual;

