alter table Poll add column graphWidth_temp int after active;
update Poll set graphWidth_temp=graphWidth;
alter table Poll drop graphWidth;
alter table Poll change graphWidth_temp graphWidth int;

