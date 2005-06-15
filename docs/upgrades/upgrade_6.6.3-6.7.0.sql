insert into webguiVersion values ('6.7.0','upgrade',unix_timestamp());
alter table SyndicatedContent add column displayMode varchar(20) not null default 'interleaved';
alter table SyndicatedContent add column hasTerms varchar(255) not null;

