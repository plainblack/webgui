# add this stuff to previousVersion.sql just before 6.0 release

delete from style where styleId < 0;
