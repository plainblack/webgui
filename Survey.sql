-- MySQL dump 10.11
--
-- Host: localhost    Database: www_survey_com
-- ------------------------------------------------------
-- Server version	5.0.67

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `Survey`
--

DROP TABLE IF EXISTS `Survey`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `Survey` (
  `groupToTakeSurvey` varchar(22) character set utf8 collate utf8_bin NOT NULL default '2',
  `groupToViewReports` varchar(22) character set utf8 collate utf8_bin NOT NULL default '3',
  `responseTemplateId` varchar(22) character set utf8 collate utf8_bin NOT NULL default '',
  `overviewTemplateId` varchar(22) character set utf8 collate utf8_bin NOT NULL default '',
  `maxResponsesPerUser` int(11) NOT NULL default '1',
  `gradebookTemplateId` varchar(22) character set utf8 collate utf8_bin NOT NULL default '',
  `assetId` varchar(22) character set utf8 collate utf8_bin NOT NULL default '',
  `templateId` varchar(22) character set utf8 collate utf8_bin NOT NULL default '',
  `revisionDate` bigint(20) NOT NULL default '0',
  `surveyEditTemplateId` varchar(22) NOT NULL,
  `answerEditTemplateId` varchar(22) NOT NULL,
  `questionEditTemplateId` varchar(22) NOT NULL,
  `sectionEditTemplateId` varchar(22) NOT NULL,
  `surveyTakeTemplateId` varchar(22) NOT NULL,
  `surveyQuestionsId` varchar(22) NOT NULL,
  `exitURL` varchar(512) default NULL,
  `surveyJSON` longblob,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `Survey_response`
--

DROP TABLE IF EXISTS `Survey_response`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
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
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `Survey_tempReport`
--

DROP TABLE IF EXISTS `Survey_tempReport`;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
CREATE TABLE `Survey_tempReport` (
  `assetId` varchar(22) NOT NULL,
  `Survey_responseId` varchar(22) NOT NULL,
  `order` smallint(5) unsigned NOT NULL,
  `sectionNumber` smallint(5) unsigned NOT NULL,
  `sectionName` varchar(512) default NULL,
  `questionNumber` smallint(5) unsigned NOT NULL,
  `questionName` varchar(512) default NULL,
  `questionComment` mediumtext,
  `answerNumber` smallint(5) unsigned default NULL,
  `answerValue` mediumtext,
  `answerComment` mediumtext,
  `entryDate` bigint(20) unsigned NOT NULL COMMENT 'UTC Unix Time',
  `isCorrect` tinyint(3) unsigned default NULL,
  `value` int(11) default NULL,
  `fileStoreageId` varchar(22) default NULL COMMENT 'Not implemented yet',
  PRIMARY KEY  (`assetId`,`Survey_responseId`,`order`),
  KEY `assetId` (`assetId`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
SET character_set_client = @saved_cs_client;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2008-10-24 21:38:00
