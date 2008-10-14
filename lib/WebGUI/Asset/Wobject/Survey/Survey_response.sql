CREATE TABLE `Survey_response` (
  `assetId` varchar(22) character set utf8 collate utf8_bin NOT NULL,
  `Survey_responseId` varchar(22) character set utf8 collate utf8_bin NOT NULL default '',
  `userId` varchar(22) default NULL,
  `username` varchar(255) default NULL,
  `ipAddress` varchar(15) default NULL,
  `startDate` bigint(20) NOT NULL default '0',
  `endDate` bigint(20) NOT NULL default '0',
  `isComplete` int(11) NOT NULL default '0',
  `anonId` varchar(255) default NULL,
  `responseJSON` longblob,
  PRIMARY KEY  (`Survey_responseId`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8
