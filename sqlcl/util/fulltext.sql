select * from ( select address, hash_value, count(*) 
cnt, max(decode(piece,0,sql_text))|| 
max(decode(piece,1,sql_text))|| 
max(decode(piece,2,sql_text))|| 
max(decode(piece,3,sql_text))|| 
max(decode(piece,4,sql_text))|| 
max(decode(piece,5,sql_text))|| 
max(decode(piece,6,sql_text))|| 
max(decode(piece,7,sql_text))|| 
max(decode(piece,8,sql_text))|| 
max(decode(piece,9,sql_text)) sql_text
from 
v$sqltext group by address, hash_value order by 3 
desc)
where rownum = 1 ;

