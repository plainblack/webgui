insert into webguiVersion values ('4.2.0','upgrade',unix_timestamp());
insert into international values (6,'Item','English','Edit Item');
insert into settings values ('runOnRegistration','');
insert into international values (559,'WebGUI','English','Run On Registration');
alter table discussion add column locked int not null default 0;
alter table discussion add column status varchar(30) not null default 'Approved';
update international set internationalId=560, namespace='WebGUI' where internationalId=7 and namespace='UserSubmission';
update international set internationalId=561, namespace='WebGUI' where internationalId=8 and namespace='UserSubmission';
update international set internationalId=562, namespace='WebGUI' where internationalId=9 and namespace='UserSubmission';
update international set internationalId=563, namespace='WebGUI' where internationalId=10 and namespace='UserSubmission';
update international set internationalId=564, namespace='WebGUI' where internationalId=3 and namespace='MessageBoard';
update international set internationalId=565, namespace='WebGUI' where internationalId=21 and namespace='MessageBoard';
update international set internationalId=566, namespace='WebGUI' where internationalId=5 and namespace='MessageBoard';
delete from international where internationalId=19 and namespace='Article';
delete from international where internationalId=20 and namespace='Article';
delete from international where internationalId=21 and namespace='Article';
delete from international where namespace='UserSubmission' and internationalId=30;
delete from international where namespace='UserSubmission' and internationalId=49;
delete from international where namespace='UserSubmission' and internationalId=50;
delete from international where namespace='UserSubmission' and internationalId=44;
insert into international values (567,'WebGUI','English','Pre-emptive');
insert into international values (568,'WebGUI','English','After-the-fact');
insert into international values (569,'WebGUI','English','Moderation Type');
alter table wobject add column groupToPost int not null default 2;
alter table wobject add column editTimeout int not null default 1;
alter table wobject add column groupToModerate int not null default 4;
alter table wobject add column karmaPerPost int not null default 0;
alter table wobject add column moderationType varchar(30) not null default 'after';
alter table MessageBoard drop column editTimeout;
alter table MessageBoard drop column groupToModerate;
alter table MessageBoard drop column groupToPost;
alter table MessageBoard drop column karmaPerPost;
alter table UserSubmission drop column groupToPost;
alter table UserSubmission drop column groupToModerate;
alter table UserSubmission drop column editTimeout;
alter table UserSubmission drop column karmaPerPost;
alter table Article drop column karmaPerPost;
alter table Article drop column editTimeout;
alter table Article drop column groupToModerate;
alter table Article drop column groupToPost;
insert into international values (570,'WebGUI','English','Lock Thread');
insert into international values (571,'WebGUI','English','Unlock Thread');
update international set internationalId=572, namespace='WebGUI' where namespace='UserSubmission' and internationalId=24;
update international set internationalId=573, namespace='WebGUI' where namespace='UserSubmission' and internationalId=25;
update international set internationalId=574, namespace='WebGUI' where namespace='UserSubmission' and internationalId=26;
insert into international values (575,'WebGUI','English','Edit');
insert into international values (576,'WebGUI','English','Delete');
update international set internationalId=577, namespace='WebGUI' where namespace='MessageBoard' and internationalId=13;
delete from international where namespace='UserSubmission' and internationalId=42;
delete from international where namespace='UserSubmission' and internationalId=43;
delete from international where namespace='Article' and internationalId=25;
delete from international where namespace='Article' and internationalId=26;
insert into international values (578,'WebGUI','English','You have a pending message to approve.');
insert into international values (579,'WebGUI','English','Your message has been approved.');
insert into international values (580,'WebGUI','English','Your message has been denied.');












