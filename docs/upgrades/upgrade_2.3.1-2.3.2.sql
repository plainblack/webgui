alter table LinkList_link change name name varchar(128);
alter table UserSubmission_submission change title title varchar(128);
insert into settings values ('VERSION','2.3.2');

