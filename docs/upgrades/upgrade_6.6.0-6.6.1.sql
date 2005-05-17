insert into webguiVersion values ('6.6.1','upgrade',unix_timestamp());
insert into settings values ('commerceSendDailyReportTo', '');
ALTER TABLE navigation CHANGE COLUMN anscestorEndPoint ancestorEndPoint INTEGER NOT NULL DEFAULT 55;