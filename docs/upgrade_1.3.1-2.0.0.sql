alter table event add column recurringEventId int not null;
INSERT INTO incrementer VALUES ('recurringEventId',1);
