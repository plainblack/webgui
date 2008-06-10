CREATE TABLE `fluxRule` (
  `fluxRuleId` varchar(22) character set utf8 collate utf8_bin NOT NULL,
  `name` varchar(255) NOT NULL,
  `sequenceNumber` int(11) NOT NULL default '1',
  `sticky` tinyint(1) NOT NULL,
  `onRuleFirstTrueWorkflowId` varchar(22) character set utf8 collate utf8_bin default NULL,
  `onRuleFirstFalseWorkflowId` varchar(22) character set utf8 collate utf8_bin default NULL,
  `onAccessFirstTrueWorkflowId` varchar(22) character set utf8 collate utf8_bin default NULL,
  `onAccessFirstFalseWorkflowId` varchar(22) character set utf8 collate utf8_bin default NULL,
  `onAccessTrueWorkflowId` varchar(22) character set utf8 collate utf8_bin default NULL,
  `onAccessFalseWorkflowId` varchar(22) character set utf8 collate utf8_bin default NULL,
  `combinedExpression` mediumtext default NULL,
  PRIMARY KEY  (`fluxRuleId`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `fluxRuleUserData` (
  `fluxRuleUserDataId` varchar(22) character set utf8 collate utf8_bin NOT NULL,
  `fluxRuleId` varchar(22) character set utf8 collate utf8_bin NOT NULL,
  `userId` varchar(22) character set utf8 collate utf8_bin NOT NULL,
  `dateRuleFirstChecked` datetime default NULL,
  `dateRuleFirstTrue` datetime default NULL,
  `dateRuleFirstFalse` datetime default NULL,
  `dateAccessFirstAttempted` datetime default NULL,
  `dateAccessFirstTrue` datetime default NULL,
  `dateAccessFirstFalse` datetime default NULL,
  `dateAccessMostRecentlyTrue` datetime default NULL,
  `dateAccessMostRecentlyFalse` datetime default NULL,
  PRIMARY KEY  (`fluxRuleUserDataId`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE `fluxExpression` (
  `fluxExpressionId` varchar(22) character set utf8 collate utf8_bin NOT NULL,
  `fluxRuleId` varchar(22) character set utf8 collate utf8_bin NOT NULL,
  `name` varchar(255) NOT NULL default 'Undefined',
  `sequenceNumber` int(11) NOT NULL default '1',
  `operand1` varchar(255) NOT NULL,
  `operand1Args` mediumtext default NULL,
  `operand1AssetId` varchar(22) character set utf8 collate utf8_bin default NULL,
  `operand1Modifier` varchar(255) default NULL,
  `operand1ModifierArgs` mediumtext default NULL,
  `operand2` varchar(255) NOT NULL,
  `operand2Args` mediumtext default NULL,
  `operand2AssetId` varchar(22) character set utf8 collate utf8_bin default NULL,
  `operand2Modifier` varchar(255) default NULL,
  `operand2ModifierArgs` mediumtext default NULL,
  `operator` varchar(255) NOT NULL,
  PRIMARY KEY  (`fluxExpressionId`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;