insert into webguiVersion values ('4.5.0','upgrade',unix_timestamp());
insert into international values (72,'Poll',1,'Randomize answers?');
alter table Poll add column randomizeAnswers int not null default 0;
insert into userProfileField values ('firstDayOfWeek','WebGUI::International::get(699,"WebGUI");',1,0,'select','{0=>WebGUI::International::get(27,"WebGUI"),1=>WebGUI::International::get(28,"WebGUI")}','[0]',2,4,1);
update userProfileField set sequenceNumber=sequenceNumber+1 where profileCategoryId=4 and sequenceNumber>=2;
insert into international values (699,"WebGUI",1,"First Day Of Week");
update international set message='Calendar Month' where internationalId=18 and namespace='EventsCalendar';
insert into international values (74,'EventsCalendar',1,'Calendar Month (Small)');
update EventsCalendar set calendarLayout='calendarMonth' where calendarLayout='calendar';
insert into international values (75,'EventsCalendar',1,'Month');
insert into international values (76,'EventsCalendar',1,'Year');
update international set internationalId=700, namespace='WebGUI' where internationalId='5' and namespace='EventsCalendar';
update international set internationalId=701, namespace='WebGUI' where internationalId='6' and namespace='EventsCalendar';
update international set internationalId=702, namespace='WebGUI' where internationalId='75' and namespace='EventsCalendar';
update international set internationalId=703, namespace='WebGUI' where internationalId='76' and namespace='EventsCalendar';
update international set message='Day(s)' where internationalId=700 and languageId=1;
update international set message='Week(s)' where internationalId=701 and languageId=1;
update international set message='Month(s)' where internationalId=702 and languageId=1;
update international set message='Year(s)' where internationalId=703 and languageId=1;
insert into international values (704,'WebGUI',1,'Second(s)');
insert into international values (705,'WebGUI',1,'Minute(s)');
insert into international values (706,'WebGUI',1,'Hour(s)');
delete from international where namespace='EventsCalendar' and internationalId=10;
delete from international where namespace='EventsCalendar' and internationalId=11;
insert into international values (75,'EventsCalendar',1,'Which do you wish to do?');
insert into international values (76,'EventsCalendar',1,'Delete only this event.');
insert into international values (77,'EventsCalendar',1,'Delete this event <b>and</b> all of its recurrences.');
insert into international values (78,'EventsCalendar',1,'Don\'t delete anything, I made a mistake.');
update wobject set editTimeout=editTimeout*3600;
insert into international values (707,"WebGUI",1,"Show debugging?");
insert into settings values ('showDebug',0);
update settings set name='imageManagersGroup' where name='groupToManageImages';
insert into settings values ('styleManagersGroup',5);
insert into settings values ('templateManagersGroup',8);
delete from international where internationalId=414 and namespace='WebGUI';
delete from international where internationalId=415 and namespace='WebGUI';
delete from international where internationalId=413 and namespace='WebGUI';
insert into international values (710,'WebGUI',1,'Edit Privilege Settings');
insert into international values (711,'WebGUI',1,'Image Managers Group');
insert into international values (713,'WebGUI',1,'Style Managers Group');
insert into international values (714,'WebGUI',1,'Template Managers Group');
delete from settings where name='onCriticalError';
update international set message='Add a new image group.' where internationalId=543 and namespace='WebGUI' and languageId=1;









