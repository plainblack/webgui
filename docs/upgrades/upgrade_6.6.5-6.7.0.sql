insert into webguiVersion values ('6.7.0','upgrade',unix_timestamp());
alter table SyndicatedContent add column displayMode varchar(20) not null default 'interleaved';
alter table SyndicatedContent add column hasTerms varchar(255) not null;
alter table snippet add column mimeType varchar(50) not null default 'text/html';
drop table theme;
drop table themeComponent;
alter table Survey_question add column Survey_sectionId varchar(22) null;
create table Survey_section (Survey_id varchar(22) null, Survey_sectionId varchar(22) not null, sectionName text null, sequenceNumber int(11) not null default 1, primary key (Survey_sectionId));
