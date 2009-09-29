

CREATE TABLE `AdSku` (
  `assetId` varchar(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL,
  `purchaseTemplate` varchar(22) character set utf8 collate utf8_bin NOT NULL,
  `manageTemplate` varchar(22) character set utf8 collate utf8_bin NOT NULL,
  `adSpace` varchar(22) character set utf8 collate utf8_bin NOT NULL,
  `priority` int(11) default '1',
  `pricePerClick` float default '0',
  `pricePerImpression` float default '0',
  `clickDiscounts` varchar(1024) character set utf8 default NULL,
  `impressionDiscounts` varchar(1024) character set utf8 default NULL,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Article` (
  `linkTitle` char(255) default NULL,
  `linkURL` text,
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `templateId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL default '0',
  `cacheTimeout` int(11) NOT NULL default '3600',
  `storageId` char(22) character set utf8 collate utf8_bin default NULL,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Calendar` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) unsigned NOT NULL default '0',
  `defaultDate` enum('current','first','last') default 'current',
  `defaultView` enum('month','week','day','list') default 'month',
  `visitorCacheTimeout` int(11) unsigned default NULL,
  `templateIdMonth` char(22) character set utf8 collate utf8_bin default 'CalendarMonth000000001',
  `templateIdWeek` char(22) character set utf8 collate utf8_bin default 'CalendarWeek0000000001',
  `templateIdDay` char(22) character set utf8 collate utf8_bin default 'CalendarDay00000000001',
  `templateIdEvent` char(22) character set utf8 collate utf8_bin default 'CalendarEvent000000001',
  `templateIdEventEdit` char(22) character set utf8 collate utf8_bin default 'CalendarEventEdit00001',
  `templateIdSearch` char(22) character set utf8 collate utf8_bin default 'CalendarSearch00000001',
  `templateIdPrintMonth` char(22) character set utf8 collate utf8_bin default 'CalendarPrintMonth0001',
  `templateIdPrintWeek` char(22) character set utf8 collate utf8_bin default 'CalendarPrintWeek00001',
  `templateIdPrintDay` char(22) character set utf8 collate utf8_bin default 'CalendarPrintDay000001',
  `templateIdPrintEvent` char(22) character set utf8 collate utf8_bin default 'CalendarPrintEvent0001',
  `groupIdEventEdit` char(22) character set utf8 collate utf8_bin default '3',
  `groupIdSubscribed` char(22) character set utf8 collate utf8_bin default NULL,
  `subscriberNotifyOffset` int(11) default NULL,
  `sortEventsBy` enum('time','sequencenumber') default 'time',
  `listViewPageInterval` bigint(20) default NULL,
  `templateIdList` char(22) character set utf8 collate utf8_bin default NULL,
  `templateIdPrintList` char(22) character set utf8 collate utf8_bin default NULL,
  `icalInterval` bigint(20) default NULL,
  `workflowIdCommit` char(22) character set utf8 collate utf8_bin default NULL,
  `icalFeeds` longtext,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Carousel` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL,
  `items` mediumtext character set utf8,
  `templateId` char(22) character set utf8 collate utf8_bin default NULL,
  `slideWidth` int(11) default NULL,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Collaboration` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `postGroupId` char(22) character set utf8 collate utf8_bin NOT NULL default '2',
  `canStartThreadGroupId` char(22) character set utf8 collate utf8_bin NOT NULL default '2',
  `karmaPerPost` int(11) NOT NULL default '0',
  `collaborationTemplateId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `threadTemplateId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `postFormTemplateId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `searchTemplateId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `notificationTemplateId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `sortBy` char(35) NOT NULL default 'assetData.revisionDate',
  `sortOrder` char(4) NOT NULL default 'desc',
  `usePreview` int(11) NOT NULL default '1',
  `addEditStampToPosts` int(11) NOT NULL default '0',
  `editTimeout` int(11) NOT NULL default '3600',
  `attachmentsPerPost` int(11) NOT NULL default '0',
  `filterCode` char(30) NOT NULL default 'javascript',
  `useContentFilter` int(11) NOT NULL default '1',
  `threads` int(11) NOT NULL default '0',
  `views` int(11) NOT NULL default '0',
  `replies` int(11) NOT NULL default '0',
  `rating` int(11) NOT NULL default '0',
  `lastPostId` char(22) character set utf8 collate utf8_bin default NULL,
  `lastPostDate` bigint(20) default NULL,
  `archiveAfter` int(11) NOT NULL default '31536000',
  `postsPerPage` int(11) NOT NULL default '10',
  `threadsPerPage` int(11) NOT NULL default '30',
  `subscriptionGroupId` char(22) character set utf8 collate utf8_bin default NULL,
  `allowReplies` int(11) NOT NULL default '0',
  `displayLastReply` int(11) NOT NULL default '0',
  `richEditor` char(22) character set utf8 collate utf8_bin NOT NULL default 'PBrichedit000000000002',
  `karmaRatingMultiplier` int(11) NOT NULL default '0',
  `karmaSpentToRate` int(11) NOT NULL default '0',
  `revisionDate` bigint(20) NOT NULL default '0',
  `avatarsEnabled` int(11) NOT NULL default '0',
  `approvalWorkflow` char(22) character set utf8 collate utf8_bin NOT NULL default 'pbworkflow000000000003',
  `threadApprovalWorkflow` char(22) character set utf8 collate utf8_bin NOT NULL default 'pbworkflow000000000003',
  `defaultKarmaScale` int(11) NOT NULL default '1',
  `mailServer` char(255) default NULL,
  `mailAccount` char(255) default NULL,
  `mailPassword` char(255) default NULL,
  `mailAddress` char(255) default NULL,
  `mailPrefix` char(255) default NULL,
  `getMail` int(11) NOT NULL default '0',
  `getMailInterval` int(11) NOT NULL default '300',
  `getMailCronId` char(22) character set utf8 collate utf8_bin default NULL,
  `visitorCacheTimeout` int(11) NOT NULL default '3600',
  `autoSubscribeToThread` int(11) NOT NULL default '1',
  `requireSubscriptionForEmailPosting` int(11) NOT NULL default '1',
  `thumbnailSize` int(11) NOT NULL default '0',
  `maxImageSize` int(11) NOT NULL default '0',
  `enablePostMetaData` int(11) NOT NULL default '0',
  `useCaptcha` int(11) NOT NULL default '0',
  `groupToEditPost` char(22) character set utf8 collate utf8_bin NOT NULL,
  `archiveEnabled` int(1) default '1',
  `postReceivedTemplateId` char(22) character set utf8 collate utf8_bin default 'default_post_received1',
  `replyRichEditor` varchar(22) character set utf8 collate utf8_bin default 'PBrichedit000000000002',
  `replyFilterCode` varchar(30) default 'javascript',
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Dashboard` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` char(22) character set utf8 collate utf8_bin NOT NULL,
  `adminsGroupId` char(22) character set utf8 collate utf8_bin NOT NULL default '4',
  `usersGroupId` char(22) character set utf8 collate utf8_bin NOT NULL default '2',
  `templateId` char(22) character set utf8 collate utf8_bin NOT NULL default 'DashboardViewTmpl00001',
  `isInitialized` tinyint(3) unsigned NOT NULL default '0',
  `assetsToHide` text,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `DataForm` (
  `acknowledgement` text,
  `mailData` int(11) NOT NULL default '1',
  `emailTemplateId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `acknowlegementTemplateId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `listTemplateId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `templateId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `defaultView` int(11) NOT NULL default '0',
  `revisionDate` bigint(20) NOT NULL default '0',
  `groupToViewEntries` char(22) character set utf8 collate utf8_bin NOT NULL default '7',
  `mailAttachments` int(11) default '0',
  `useCaptcha` int(1) default '0',
  `storeData` int(1) default '1',
  `fieldConfiguration` longtext,
  `tabConfiguration` longtext,
  `workflowIdAddEntry` char(22) character set utf8 collate utf8_bin default NULL,
  `htmlAreaRichEditor` varchar(22) character set utf8 collate utf8_bin default '**Use_Default_Editor**',
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `DataForm_entry` (
  `DataForm_entryId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `userId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `username` char(255) default NULL,
  `ipAddress` char(255) default NULL,
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `entryData` longtext,
  `submissionDate` datetime default NULL,
  PRIMARY KEY  (`DataForm_entryId`),
  KEY `assetId` (`assetId`),
  KEY `assetId_submissionDate` (`assetId`,`submissionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `DataTable` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL,
  `data` longtext character set utf8,
  `templateId` char(22) character set utf8 collate utf8_bin default NULL,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `EMSBadge` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL,
  `price` float NOT NULL default '0',
  `seatsAvailable` int(11) NOT NULL default '100',
  `relatedBadgeGroups` mediumtext,
  `templateId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `earlyBirdPrice` float NOT NULL default '0',
  `earlyBirdPriceEndDate` bigint(20) default NULL,
  `preRegistrationPrice` float NOT NULL default '0',
  `preRegistrationPriceEndDate` bigint(20) default NULL,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `EMSBadgeGroup` (
  `badgeGroupId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `emsAssetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `name` char(100) default NULL,
  PRIMARY KEY  (`badgeGroupId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `EMSEventMetaField` (
  `fieldId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `assetId` char(22) character set utf8 collate utf8_bin default NULL,
  `label` char(100) default NULL,
  `dataType` char(20) default NULL,
  `visible` tinyint(4) default '0',
  `required` tinyint(4) default '0',
  `possibleValues` text,
  `defaultValues` text,
  `sequenceNumber` int(5) default NULL,
  PRIMARY KEY  (`fieldId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `EMSRegistrant` (
  `badgeId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `userId` char(22) character set utf8 collate utf8_bin default NULL,
  `badgeNumber` int(11) NOT NULL auto_increment,
  `badgeAssetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `emsAssetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `name` char(35) NOT NULL,
  `address1` char(35) default NULL,
  `address2` char(35) default NULL,
  `address3` char(35) default NULL,
  `city` char(35) default NULL,
  `state` char(35) default NULL,
  `zipcode` char(35) default NULL,
  `country` char(35) default NULL,
  `phoneNumber` char(35) default NULL,
  `organization` char(35) default NULL,
  `email` char(255) default NULL,
  `notes` mediumtext,
  `purchaseComplete` tinyint(1) default NULL,
  `hasCheckedIn` tinyint(1) default NULL,
  `transactionItemId` char(22) character set utf8 collate utf8_bin default NULL,
  PRIMARY KEY  (`badgeId`),
  UNIQUE KEY `badgeNumber` (`badgeNumber`),
  KEY `badgeAssetId_purchaseComplete` (`badgeAssetId`,`purchaseComplete`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `EMSRegistrantRibbon` (
  `badgeId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `ribbonAssetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `transactionItemId` char(22) character set utf8 collate utf8_bin default NULL,
  PRIMARY KEY  (`badgeId`,`ribbonAssetId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `EMSRegistrantTicket` (
  `badgeId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `ticketAssetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `purchaseComplete` tinyint(1) default NULL,
  `transactionItemId` char(22) character set utf8 collate utf8_bin default NULL,
  PRIMARY KEY  (`badgeId`,`ticketAssetId`),
  KEY `ticketAssetId_purchaseComplete` (`ticketAssetId`,`purchaseComplete`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `EMSRegistrantToken` (
  `badgeId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `tokenAssetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `quantity` int(11) default NULL,
  `transactionItemIds` text,
  PRIMARY KEY  (`badgeId`,`tokenAssetId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `EMSRibbon` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL,
  `percentageDiscount` float NOT NULL default '10',
  `price` float NOT NULL default '0',
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `EMSTicket` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL,
  `price` float NOT NULL default '0',
  `seatsAvailable` int(11) NOT NULL default '100',
  `startDate` datetime default NULL,
  `duration` float NOT NULL default '1',
  `eventNumber` int(11) default NULL,
  `location` char(100) default NULL,
  `relatedBadgeGroups` mediumtext,
  `relatedRibbons` mediumtext,
  `eventMetaData` mediumtext,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `EMSToken` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL,
  `price` float NOT NULL default '0',
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Event` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) unsigned NOT NULL,
  `feedId` char(22) character set utf8 collate utf8_bin default NULL,
  `feedUid` char(255) default NULL,
  `startDate` date default NULL,
  `endDate` date default NULL,
  `userDefined1` text,
  `userDefined2` text,
  `userDefined3` text,
  `userDefined4` text,
  `userDefined5` text,
  `recurId` char(22) character set utf8 collate utf8_bin default NULL,
  `description` longtext,
  `startTime` time default NULL,
  `endTime` time default NULL,
  `relatedLinks` longtext,
  `location` char(255) default NULL,
  `storageId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `timeZone` char(255) default 'America/Chicago',
  `sequenceNumber` bigint(20) default NULL,
  `iCalSequenceNumber` int(11) default NULL,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `EventManagementSystem` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL,
  `groupToApproveEvents` char(22) character set utf8 collate utf8_bin default NULL,
  `timezone` char(30) NOT NULL default 'America/Chicago',
  `templateId` char(22) character set utf8 collate utf8_bin NOT NULL default '2rC4ErZ3c77OJzJm7O5s3w',
  `badgeBuilderTemplateId` char(22) character set utf8 collate utf8_bin NOT NULL default 'BMybD3cEnmXVk2wQ_qEsRQ',
  `lookupRegistrantTemplateId` char(22) character set utf8 collate utf8_bin NOT NULL default 'OOyMH33plAy6oCj_QWrxtg',
  `printBadgeTemplateId` char(22) character set utf8 collate utf8_bin NOT NULL default 'PsFn7dJt4wMwBa8hiE3hOA',
  `printTicketTemplateId` char(22) character set utf8 collate utf8_bin NOT NULL default 'yBwydfooiLvhEFawJb0VTQ',
  `badgeInstructions` mediumtext,
  `ribbonInstructions` mediumtext,
  `ticketInstructions` mediumtext,
  `tokenInstructions` mediumtext,
  `registrationStaffGroupId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `scheduleTemplateId` char(22) character set utf8 collate utf8_bin default NULL,
  `scheduleColumnsPerPage` int(11) default NULL,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Event_recur` (
  `recurId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `recurType` char(16) default NULL,
  `pattern` char(255) default NULL,
  `startDate` date default NULL,
  `endDate` char(10) default NULL,
  PRIMARY KEY  (`recurId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Event_relatedlink` (
  `eventlinkId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `linkURL` tinytext,
  `linktext` char(80) default NULL,
  `groupIdView` char(22) character set utf8 collate utf8_bin NOT NULL,
  `sequenceNumber` bigint(20) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `FileAsset` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `storageId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `filename` char(255) NOT NULL,
  `templateId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL default '0',
  `cacheTimeout` int(11) NOT NULL default '3600',
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `FlatDiscount` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL default '0',
  `templateId` char(22) character set utf8 collate utf8_bin NOT NULL default '63ix2-hU0FchXGIWkG3tow',
  `mustSpend` float NOT NULL default '0',
  `percentageDiscount` int(3) NOT NULL default '0',
  `priceDiscount` float NOT NULL default '0',
  `thankYouMessage` mediumtext,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Folder` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `templateId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL default '0',
  `visitorCacheTimeout` int(11) NOT NULL default '3600',
  `sortAlphabetically` int(11) NOT NULL default '0',
  `sortOrder` enum('ASC','DESC') default 'ASC',
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Gallery` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL,
  `groupIdAddComment` char(22) character set utf8 collate utf8_bin default NULL,
  `groupIdAddFile` char(22) character set utf8 collate utf8_bin default NULL,
  `imageResolutions` text,
  `imageViewSize` int(11) default NULL,
  `imageThumbnailSize` int(11) default NULL,
  `maxSpacePerUser` char(20) default NULL,
  `richEditIdComment` char(22) character set utf8 collate utf8_bin default NULL,
  `templateIdAddArchive` char(22) character set utf8 collate utf8_bin default NULL,
  `templateIdDeleteAlbum` char(22) character set utf8 collate utf8_bin default NULL,
  `templateIdDeleteFile` char(22) character set utf8 collate utf8_bin default NULL,
  `templateIdEditAlbum` char(22) character set utf8 collate utf8_bin default NULL,
  `templateIdEditFile` char(22) character set utf8 collate utf8_bin default NULL,
  `templateIdListAlbums` char(22) character set utf8 collate utf8_bin default NULL,
  `templateIdListAlbumsRss` char(22) character set utf8 collate utf8_bin default NULL,
  `templateIdListFilesForUser` char(22) character set utf8 collate utf8_bin default NULL,
  `templateIdListFilesForUserRss` char(22) character set utf8 collate utf8_bin default NULL,
  `templateIdMakeShortcut` char(22) character set utf8 collate utf8_bin default NULL,
  `templateIdSearch` char(22) character set utf8 collate utf8_bin default NULL,
  `templateIdViewSlideshow` char(22) character set utf8 collate utf8_bin default NULL,
  `templateIdViewThumbnails` char(22) character set utf8 collate utf8_bin default NULL,
  `templateIdViewAlbum` char(22) character set utf8 collate utf8_bin default NULL,
  `templateIdViewAlbumRss` char(22) character set utf8 collate utf8_bin default NULL,
  `templateIdViewFile` char(22) character set utf8 collate utf8_bin default NULL,
  `viewAlbumAssetId` char(22) character set utf8 collate utf8_bin default NULL,
  `viewDefault` enum('album','list') default NULL,
  `viewListOrderBy` char(40) default NULL,
  `viewListOrderDirection` enum('ASC','DESC') default NULL,
  `workflowIdCommit` char(22) character set utf8 collate utf8_bin default NULL,
  `templateIdEditComment` char(22) character set utf8 collate utf8_bin default NULL,
  `richEditIdAlbum` char(22) character set utf8 collate utf8_bin default NULL,
  `richEditIdFile` char(22) character set utf8 collate utf8_bin default NULL,
  `defaultFilesPerPage` int(11) default NULL,
  `imageDensity` int(11) default NULL,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `GalleryAlbum` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL,
  `allowComments` int(11) default NULL,
  `assetIdThumbnail` char(22) character set utf8 collate utf8_bin default NULL,
  `userDefined1` text,
  `userDefined2` text,
  `userDefined3` text,
  `userDefined4` text,
  `userDefined5` text,
  `othersCanAdd` int(11) default NULL,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `GalleryFile` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL,
  `userDefined1` longtext,
  `userDefined2` longtext,
  `userDefined3` longtext,
  `userDefined4` longtext,
  `userDefined5` longtext,
  `views` bigint(20) default '0',
  `friendsOnly` int(1) default '0',
  `rating` int(1) default '0',
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `GalleryFile_comment` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `commentId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `userId` char(22) character set utf8 collate utf8_bin default NULL,
  `visitorIp` char(255) default NULL,
  `creationDate` datetime default NULL,
  `bodyText` longtext,
  PRIMARY KEY  (`assetId`,`commentId`),
  KEY `commentId` (`commentId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `HttpProxy` (
  `proxiedUrl` text,
  `timeout` int(11) default NULL,
  `removeStyle` int(11) default NULL,
  `filterHtml` char(30) default NULL,
  `followExternal` int(11) default NULL,
  `followRedirect` int(11) default NULL,
  `cacheHttp` int(11) default '0',
  `useCache` int(11) default '0',
  `debug` int(11) default '0',
  `rewriteUrls` int(11) default NULL,
  `searchFor` char(255) default NULL,
  `stopAt` char(255) default NULL,
  `cookieJarStorageId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `templateId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL default '0',
  `cacheTimeout` int(11) NOT NULL default '0',
  `useAmpersand` int(11) NOT NULL default '0',
  `urlPatternFilter` mediumtext,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `ITransact_recurringStatus` (
  `gatewayId` char(128) NOT NULL,
  `initDate` bigint(20) NOT NULL default '0',
  `lastTransaction` bigint(20) NOT NULL default '0',
  `status` char(10) NOT NULL,
  `errorMessage` char(128) default NULL,
  `recipe` char(15) NOT NULL,
  PRIMARY KEY  (`gatewayId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `ImageAsset` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `thumbnailSize` int(11) NOT NULL default '50',
  `parameters` text,
  `revisionDate` bigint(20) NOT NULL default '0',
  `annotations` mediumtext,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `InOutBoard` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL default '0',
  `statusList` text,
  `reportViewerGroup` char(22) character set utf8 collate utf8_bin NOT NULL default '3',
  `inOutGroup` char(22) character set utf8 collate utf8_bin NOT NULL default '2',
  `inOutTemplateId` char(22) character set utf8 collate utf8_bin NOT NULL default 'IOB0000000000000000001',
  `reportTemplateId` char(22) character set utf8 collate utf8_bin NOT NULL default 'IOB0000000000000000002',
  `paginateAfter` int(11) NOT NULL default '50',
  `reportPaginateAfter` int(11) NOT NULL default '50',
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `InOutBoard_delegates` (
  `userId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `delegateUserId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `InOutBoard_status` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `userId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `status` char(255) default NULL,
  `dateStamp` int(11) NOT NULL,
  `message` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `InOutBoard_statusLog` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `userId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `status` char(255) default NULL,
  `dateStamp` int(11) NOT NULL,
  `message` text,
  `createdBy` char(22) character set utf8 collate utf8_bin default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Layout` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `templateId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `contentPositions` text,
  `assetsToHide` text,
  `revisionDate` bigint(20) NOT NULL default '0',
  `assetOrder` char(20) default 'asc',
  `mobileTemplateId` char(22) character set utf8 collate utf8_bin default 'PBtmpl0000000000000054',
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Map` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL,
  `groupIdAddPoint` char(22) character set utf8 collate utf8_bin default NULL,
  `mapApiKey` text character set utf8,
  `mapHeight` char(12) character set utf8 default NULL,
  `mapWidth` char(12) character set utf8 default NULL,
  `startLatitude` float default NULL,
  `startLongitude` float default NULL,
  `startZoom` tinyint(3) unsigned default NULL,
  `templateIdEditPoint` char(22) character set utf8 collate utf8_bin default NULL,
  `templateIdView` char(22) character set utf8 collate utf8_bin default NULL,
  `templateIdViewPoint` char(22) character set utf8 collate utf8_bin default NULL,
  `workflowIdPoint` char(22) character set utf8 collate utf8_bin default NULL,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `MapPoint` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL,
  `latitude` float default NULL,
  `longitude` float default NULL,
  `website` varchar(255) character set utf8 default NULL,
  `address1` varchar(255) character set utf8 default NULL,
  `address2` varchar(255) character set utf8 default NULL,
  `city` varchar(255) character set utf8 default NULL,
  `state` varchar(255) character set utf8 default NULL,
  `zipCode` varchar(255) character set utf8 default NULL,
  `country` varchar(255) character set utf8 default NULL,
  `phone` varchar(255) character set utf8 default NULL,
  `fax` varchar(255) character set utf8 default NULL,
  `email` varchar(255) character set utf8 default NULL,
  `storageIdPhoto` char(22) character set utf8 collate utf8_bin default NULL,
  `userDefined1` text character set utf8,
  `userDefined2` text character set utf8,
  `userDefined3` text character set utf8,
  `userDefined4` text character set utf8,
  `userDefined5` text character set utf8,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Matrix` (
  `detailTemplateId` char(22) character set utf8 collate utf8_bin default NULL,
  `compareTemplateId` char(22) character set utf8 collate utf8_bin default NULL,
  `searchTemplateId` char(22) character set utf8 collate utf8_bin default NULL,
  `categories` text,
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `templateId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL default '0',
  `maxComparisons` int(11) NOT NULL default '10',
  `maxComparisonsPrivileged` int(11) NOT NULL default '10',
  `defaultSort` char(22) character set utf8 collate utf8_bin NOT NULL default 'score',
  `compareColorNo` char(22) character set utf8 collate utf8_bin default '#ffaaaa',
  `compareColorLimited` char(22) character set utf8 collate utf8_bin NOT NULL default '#ffffaa',
  `compareColorCostsExtra` char(22) character set utf8 collate utf8_bin NOT NULL default '#ffffaa',
  `compareColorFreeAddOn` char(22) character set utf8 collate utf8_bin NOT NULL default '#ffffaa',
  `compareColorYes` char(22) character set utf8 collate utf8_bin NOT NULL default '#aaffaa',
  `submissionApprovalWorkflowId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `ratingsDuration` int(11) NOT NULL default '7776000',
  `editListingTemplateId` char(22) character set utf8 collate utf8_bin default NULL,
  `groupToAdd` char(22) character set utf8 collate utf8_bin default '2',
  `screenshotsConfigTemplateId` char(22) character set utf8 collate utf8_bin default NULL,
  `screenshotsTemplateId` char(22) character set utf8 collate utf8_bin default NULL,
  `statisticsCacheTimeout` int(11) NOT NULL default '3600',
  `maxScreenshotWidth` int(11) default NULL,
  `maxScreenshotHeight` int(11) default NULL,
  `listingsCacheTimeout` int(11) NOT NULL default '3600',
  `maxComparisonsGroup` char(22) character set utf8 collate utf8_bin default NULL,
  `maxComparisonsGroupInt` int(11) default NULL,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `MatrixListing` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL,
  `screenshots` char(22) character set utf8 collate utf8_bin default NULL,
  `description` text character set utf8,
  `version` char(255) character set utf8 default NULL,
  `views` int(11) default NULL,
  `compares` int(11) default NULL,
  `clicks` int(11) default NULL,
  `viewsLastIp` char(255) character set utf8 default NULL,
  `comparesLastIp` char(255) character set utf8 default NULL,
  `clicksLastIp` char(255) character set utf8 default NULL,
  `lastUpdated` int(11) default NULL,
  `maintainer` char(22) character set utf8 collate utf8_bin default NULL,
  `manufacturerName` char(255) character set utf8 default NULL,
  `manufacturerURL` char(255) character set utf8 default NULL,
  `productURL` char(255) character set utf8 default NULL,
  `score` int(11) default NULL,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `MatrixListing_attribute` (
  `matrixId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `matrixListingId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `attributeId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `value` char(255) character set utf8 default NULL,
  PRIMARY KEY  (`attributeId`,`matrixListingId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `MatrixListing_rating` (
  `timeStamp` int(11) NOT NULL default '0',
  `category` char(255) default NULL,
  `rating` int(11) NOT NULL default '1',
  `listingId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `ipAddress` char(15) default NULL,
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `userId` char(22) character set utf8 collate utf8_bin default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `MatrixListing_ratingSummary` (
  `listingId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `category` char(255) NOT NULL,
  `meanValue` decimal(3,2) default NULL,
  `medianValue` int(11) default NULL,
  `countValue` int(11) default NULL,
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  PRIMARY KEY  (`listingId`,`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Matrix_attribute` (
  `attributeId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `category` char(255) NOT NULL,
  `name` char(255) default NULL,
  `description` text,
  `fieldType` char(255) NOT NULL default 'MatrixCompare',
  `defaultValue` char(255) default NULL,
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `options` text,
  PRIMARY KEY  (`attributeId`),
  KEY `categoryIndex` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `MessageBoard` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `templateId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL default '0',
  `visitorCacheTimeout` int(11) NOT NULL default '3600',
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `MultiSearch` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) unsigned NOT NULL default '0',
  `templateId` char(22) character set utf8 collate utf8_bin NOT NULL default 'MultiSearchTmpl0000001',
  `predefinedSearches` text,
  `cacheTimeout` int(11) NOT NULL default '3600',
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Navigation` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `assetsToInclude` text,
  `startType` char(35) default NULL,
  `startPoint` char(255) default NULL,
  `descendantEndPoint` int(11) NOT NULL default '55',
  `showSystemPages` int(11) NOT NULL default '0',
  `showHiddenPages` int(11) NOT NULL default '0',
  `showUnprivilegedPages` int(11) NOT NULL default '0',
  `templateId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `ancestorEndPoint` int(11) NOT NULL default '55',
  `revisionDate` bigint(20) NOT NULL default '0',
  `mimeType` char(50) default 'text/html',
  `reversePageLoop` tinyint(1) default '0',
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Newsletter` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL,
  `newsletterTemplateId` char(22) character set utf8 collate utf8_bin NOT NULL default 'newsletter000000000001',
  `mySubscriptionsTemplateId` char(22) character set utf8 collate utf8_bin NOT NULL default 'newslettersubscrip0001',
  `newsletterHeader` mediumtext,
  `newsletterFooter` mediumtext,
  `newsletterCategories` text,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Newsletter_subscriptions` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `userId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `subscriptions` text,
  `lastTimeSent` bigint(20) NOT NULL default '0',
  PRIMARY KEY  (`assetId`,`userId`),
  KEY `lastTimeSent_assetId_userId` (`lastTimeSent`,`assetId`,`userId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `PM_project` (
  `projectId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `assetId` char(22) character set utf8 collate utf8_bin default NULL,
  `name` char(255) NOT NULL,
  `description` text,
  `startDate` bigint(20) default NULL,
  `endDate` bigint(20) default NULL,
  `projectManager` char(22) character set utf8 collate utf8_bin default NULL,
  `durationUnits` enum('hours','days') default 'hours',
  `hoursPerDay` float default NULL,
  `targetBudget` float(15,2) default '0.00',
  `percentComplete` float NOT NULL default '0',
  `parentId` char(22) character set utf8 collate utf8_bin default NULL,
  `creationDate` bigint(20) NOT NULL,
  `createdBy` char(22) character set utf8 collate utf8_bin NOT NULL,
  `lastUpdatedBy` char(22) character set utf8 collate utf8_bin NOT NULL,
  `lastUpdateDate` bigint(20) NOT NULL,
  `projectObserver` char(22) character set utf8 collate utf8_bin default '7',
  PRIMARY KEY  (`projectId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `PM_task` (
  `taskId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `projectId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `taskName` char(255) NOT NULL,
  `duration` float default NULL,
  `startDate` bigint(20) default NULL,
  `endDate` bigint(20) default NULL,
  `dependants` char(50) default NULL,
  `parentId` char(22) character set utf8 collate utf8_bin default NULL,
  `percentComplete` float default NULL,
  `sequenceNumber` int(11) NOT NULL default '1',
  `creationDate` bigint(20) NOT NULL,
  `createdBy` char(22) character set utf8 collate utf8_bin NOT NULL,
  `lastUpdatedBy` char(22) character set utf8 collate utf8_bin NOT NULL,
  `lastUpdateDate` bigint(20) NOT NULL,
  `lagTime` bigint(20) default '0',
  `taskType` enum('timed','progressive','milestone') NOT NULL default 'timed',
  PRIMARY KEY  (`taskId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `PM_taskResource` (
  `taskResourceId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `taskId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `sequenceNumber` int(11) NOT NULL,
  `resourceKind` enum('user','group') NOT NULL,
  `resourceId` char(22) character set utf8 collate utf8_bin NOT NULL,
  PRIMARY KEY  (`taskResourceId`),
  UNIQUE KEY `taskId` (`taskId`,`resourceKind`,`resourceId`),
  UNIQUE KEY `taskId_2` (`taskId`,`sequenceNumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `PM_wobject` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `projectDashboardTemplateId` char(22) character set utf8 collate utf8_bin NOT NULL default 'ProjectManagerTMPL0001',
  `projectDisplayTemplateId` char(22) character set utf8 collate utf8_bin NOT NULL default 'ProjectManagerTMPL0002',
  `ganttChartTemplateId` char(22) character set utf8 collate utf8_bin NOT NULL default 'ProjectManagerTMPL0003',
  `editTaskTemplateId` char(22) character set utf8 collate utf8_bin NOT NULL default 'ProjectManagerTMPL0004',
  `groupToAdd` char(22) character set utf8 collate utf8_bin NOT NULL default '3',
  `revisionDate` bigint(20) NOT NULL,
  `resourcePopupTemplateId` char(22) character set utf8 collate utf8_bin NOT NULL default 'ProjectManagerTMPL0005',
  `resourceListTemplateId` char(22) character set utf8 collate utf8_bin NOT NULL default 'ProjectManagerTMPL0006',
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Photo` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL,
  `exifData` longtext,
  `location` char(255) default NULL,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Photo_rating` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `userId` char(22) character set utf8 collate utf8_bin default NULL,
  `visitorIp` char(255) default NULL,
  `rating` int(11) default NULL,
  KEY `assetId` (`assetId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Poll` (
  `active` int(11) NOT NULL default '1',
  `graphWidth` int(11) NOT NULL default '150',
  `voteGroup` char(22) character set utf8 collate utf8_bin default NULL,
  `question` char(255) default NULL,
  `a1` char(255) default NULL,
  `a2` char(255) default NULL,
  `a3` char(255) default NULL,
  `a4` char(255) default NULL,
  `a5` char(255) default NULL,
  `a6` char(255) default NULL,
  `a7` char(255) default NULL,
  `a8` char(255) default NULL,
  `a9` char(255) default NULL,
  `a10` char(255) default NULL,
  `a11` char(255) default NULL,
  `a12` char(255) default NULL,
  `a13` char(255) default NULL,
  `a14` char(255) default NULL,
  `a15` char(255) default NULL,
  `a16` char(255) default NULL,
  `a17` char(255) default NULL,
  `a18` char(255) default NULL,
  `a19` char(255) default NULL,
  `a20` char(255) default NULL,
  `karmaPerVote` int(11) NOT NULL default '0',
  `randomizeAnswers` int(11) NOT NULL default '0',
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `templateId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL default '0',
  `graphConfiguration` blob,
  `generateGraph` tinyint(1) default NULL,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Poll_answer` (
  `answer` char(3) default NULL,
  `userId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `ipAddress` char(50) default NULL,
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Post` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `threadId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `username` char(30) default NULL,
  `content` mediumtext,
  `views` int(11) NOT NULL default '0',
  `contentType` char(35) NOT NULL default 'mixed',
  `userDefined1` text,
  `userDefined2` text,
  `userDefined3` text,
  `userDefined4` text,
  `userDefined5` text,
  `storageId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `rating` int(11) NOT NULL default '0',
  `revisionDate` bigint(20) NOT NULL default '0',
  `originalEmail` mediumtext,
  PRIMARY KEY  (`assetId`,`revisionDate`),
  KEY `threadId_rating` (`threadId`,`rating`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Post_rating` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `userId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `ipAddress` char(15) NOT NULL,
  `dateOfRating` bigint(20) default NULL,
  `rating` int(11) NOT NULL default '0',
  KEY `assetId_userId` (`assetId`,`userId`),
  KEY `assetId_ipAddress` (`assetId`,`ipAddress`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Product` (
  `image1` char(255) default NULL,
  `image2` char(255) default NULL,
  `image3` char(255) default NULL,
  `brochure` char(255) default NULL,
  `manual` char(255) default NULL,
  `warranty` char(255) default NULL,
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `templateId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL default '0',
  `cacheTimeout` int(11) NOT NULL default '3600',
  `thankYouMessage` mediumtext,
  `accessoryJSON` longtext,
  `benefitJSON` longtext,
  `featureJSON` longtext,
  `relatedJSON` longtext,
  `specificationJSON` longtext,
  `variantsJSON` longtext,
  `isShippingRequired` int(11) default NULL,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `RichEdit` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `askAboutRichEdit` int(11) NOT NULL default '0',
  `preformatted` int(11) NOT NULL default '0',
  `editorWidth` int(11) NOT NULL default '0',
  `editorHeight` int(11) NOT NULL default '0',
  `sourceEditorWidth` int(11) NOT NULL default '0',
  `sourceEditorHeight` int(11) NOT NULL default '0',
  `useBr` int(11) NOT NULL default '0',
  `nowrap` int(11) NOT NULL default '0',
  `removeLineBreaks` int(11) NOT NULL default '0',
  `npwrap` int(11) NOT NULL default '0',
  `directionality` char(3) NOT NULL default 'ltr',
  `toolbarLocation` char(6) NOT NULL default 'bottom',
  `cssFile` char(255) default NULL,
  `validElements` mediumtext,
  `toolbarRow1` text,
  `toolbarRow2` text,
  `toolbarRow3` text,
  `enableContextMenu` int(11) NOT NULL default '0',
  `revisionDate` bigint(20) NOT NULL default '0',
  `disableRichEditor` int(11) default '0',
  `inlinePopups` int(11) NOT NULL default '0',
  `allowMedia` int(11) default NULL,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `SQLForm_fieldOrder` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `fieldId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `rank` int(11) NOT NULL default '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `SQLReport` (
  `dbQuery1` text,
  `paginateAfter` int(11) NOT NULL default '50',
  `preprocessMacros1` int(11) default '0',
  `debugMode` int(11) NOT NULL default '0',
  `databaseLinkId1` char(22) character set utf8 collate utf8_bin NOT NULL,
  `placeholderParams1` text,
  `preprocessMacros2` int(11) default '0',
  `dbQuery2` text,
  `placeholderParams2` text,
  `databaseLinkId2` char(22) character set utf8 collate utf8_bin NOT NULL,
  `preprocessMacros3` int(11) default '0',
  `dbQuery3` text,
  `placeholderParams3` text,
  `databaseLinkId3` char(22) character set utf8 collate utf8_bin NOT NULL,
  `preprocessMacros4` int(11) default '0',
  `dbQuery4` text,
  `placeholderParams4` text,
  `databaseLinkId4` char(22) character set utf8 collate utf8_bin NOT NULL,
  `preprocessMacros5` int(11) default '0',
  `dbQuery5` text,
  `placeholderParams5` text,
  `databaseLinkId5` char(22) character set utf8 collate utf8_bin NOT NULL,
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `templateId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL default '0',
  `cacheTimeout` int(11) NOT NULL default '0',
  `prequeryStatements1` text,
  `prequeryStatements2` text,
  `prequeryStatements3` text,
  `prequeryStatements4` text,
  `prequeryStatements5` text,
  `downloadType` char(255) default NULL,
  `downloadFilename` char(255) default NULL,
  `downloadTemplateId` char(22) character set utf8 collate utf8_bin default NULL,
  `downloadMimeType` char(255) default NULL,
  `downloadUserGroup` char(22) character set utf8 collate utf8_bin default NULL,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Shelf` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL default '0',
  `templateId` char(22) character set utf8 collate utf8_bin NOT NULL default 'nFen0xjkZn8WkpM93C9ceQ',
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Shortcut` (
  `overrideTitle` int(11) NOT NULL default '0',
  `overrideDescription` int(11) NOT NULL default '0',
  `overrideTemplate` int(11) NOT NULL default '0',
  `overrideDisplayTitle` int(11) NOT NULL default '0',
  `overrideTemplateId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `shortcutByCriteria` int(11) NOT NULL default '0',
  `resolveMultiples` char(30) default 'mostRecent',
  `shortcutCriteria` text NOT NULL,
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `templateId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `shortcutToAssetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `disableContentLock` int(11) NOT NULL default '0',
  `revisionDate` bigint(20) NOT NULL default '0',
  `prefFieldsToShow` text,
  `prefFieldsToImport` text,
  `showReloadIcon` tinyint(3) unsigned NOT NULL default '0',
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Shortcut_overrides` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `fieldName` char(255) NOT NULL,
  `newValue` text,
  PRIMARY KEY  (`assetId`,`fieldName`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `StockData` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `templateId` char(22) character set utf8 collate utf8_bin NOT NULL default 'StockListTMPL000000001',
  `displayTemplateId` char(22) character set utf8 collate utf8_bin NOT NULL default 'StockListTMPL000000002',
  `defaultStocks` text,
  `source` char(50) default 'usa',
  `failover` int(11) default '1',
  `revisionDate` int(11) NOT NULL,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Story` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL,
  `headline` char(255) character set utf8 default NULL,
  `subtitle` char(255) character set utf8 default NULL,
  `byline` char(255) character set utf8 default NULL,
  `location` char(255) character set utf8 default NULL,
  `highlights` text character set utf8,
  `story` mediumtext character set utf8,
  `photo` longtext character set utf8,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `StoryArchive` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL,
  `storiesPerPage` int(11) default NULL,
  `groupToPost` char(22) character set utf8 collate utf8_bin default NULL,
  `templateId` char(22) character set utf8 collate utf8_bin default NULL,
  `storyTemplateId` char(22) character set utf8 collate utf8_bin default NULL,
  `editStoryTemplateId` char(22) character set utf8 collate utf8_bin default NULL,
  `keywordListTemplateId` char(22) character set utf8 collate utf8_bin default NULL,
  `archiveAfter` int(11) default NULL,
  `richEditorId` char(22) character set utf8 collate utf8_bin default NULL,
  `approvalWorkflowId` char(22) character set utf8 collate utf8_bin default 'pbworkflow000000000003',
  `photoWidth` int(11) default NULL,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `StoryTopic` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL,
  `storiesPer` int(11) default NULL,
  `storiesShort` int(11) default NULL,
  `templateId` char(22) character set utf8 collate utf8_bin default NULL,
  `storyTemplateId` char(22) character set utf8 collate utf8_bin default NULL,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Subscription` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL,
  `templateId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `thankYouMessage` mediumtext,
  `price` float NOT NULL default '0',
  `subscriptionGroup` char(22) character set utf8 collate utf8_bin NOT NULL default '2',
  `duration` char(12) NOT NULL default 'Monthly',
  `executeOnSubscription` char(255) default NULL,
  `karma` int(6) default '0',
  `recurringSubscription` tinyint(1) NOT NULL default '1',
  `redeemSubscriptionCodeTemplateId` char(22) character set utf8 collate utf8_bin NOT NULL,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Subscription_code` (
  `code` char(64) NOT NULL,
  `batchId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `status` char(10) NOT NULL default 'Unused',
  `dateUsed` bigint(20) default NULL,
  `usedBy` char(22) character set utf8 collate utf8_bin default NULL,
  PRIMARY KEY  (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Subscription_codeBatch` (
  `batchId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `name` char(255) default NULL,
  `description` mediumtext,
  `subscriptionId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `expirationDate` bigint(20) NOT NULL,
  `dateCreated` bigint(20) NOT NULL,
  PRIMARY KEY  (`batchId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Survey` (
  `groupToTakeSurvey` char(22) character set utf8 collate utf8_bin NOT NULL default '2',
  `groupToEditSurvey` char(22) character set utf8 collate utf8_bin NOT NULL default '3',
  `groupToViewReports` char(22) character set utf8 collate utf8_bin NOT NULL default '3',
  `overviewTemplateId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `maxResponsesPerUser` int(11) NOT NULL default '1',
  `gradebookTemplateId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `templateId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL default '0',
  `surveyEditTemplateId` char(22) character set utf8 collate utf8_bin default NULL,
  `answerEditTemplateId` char(22) character set utf8 collate utf8_bin default NULL,
  `questionEditTemplateId` char(22) character set utf8 collate utf8_bin default NULL,
  `sectionEditTemplateId` char(22) character set utf8 collate utf8_bin default NULL,
  `surveyTakeTemplateId` char(22) character set utf8 collate utf8_bin default NULL,
  `surveyQuestionsId` char(22) character set utf8 collate utf8_bin default NULL,
  `exitURL` text,
  `surveyJSON` longtext,
  `timeLimit` mediumint(8) unsigned NOT NULL,
  `showProgress` tinyint(3) unsigned NOT NULL default '0',
  `showTimeLimit` tinyint(3) unsigned NOT NULL default '0',
  `doAfterTimeLimit` char(22) character set utf8 collate utf8_bin default NULL,
  `onSurveyEndWorkflowId` varchar(22) character set utf8 collate utf8_bin default NULL,
  `quizModeSummary` tinyint(3) default NULL,
  `surveySummaryTemplateId` char(22) character set utf8 collate utf8_bin default NULL,
  `allowBackBtn` tinyint(3) default NULL,
  `feedbackTemplateId` char(22) character set utf8 collate utf8_bin default NULL,
  `testResultsTemplateId` char(22) character set utf8 collate utf8_bin default NULL,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Survey_questionTypes` (
  `questionType` varchar(56) character set utf8 NOT NULL,
  `answers` text character set utf8 NOT NULL,
  PRIMARY KEY  (`questionType`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Survey_response` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `Survey_responseId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `userId` char(22) character set utf8 collate utf8_bin default NULL,
  `username` char(255) default NULL,
  `ipAddress` char(15) default NULL,
  `startDate` bigint(20) NOT NULL default '0',
  `endDate` bigint(20) NOT NULL default '0',
  `isComplete` int(11) NOT NULL default '0',
  `anonId` char(255) default NULL,
  `responseJSON` longtext,
  `revisionDate` bigint(20) NOT NULL default '0',
  PRIMARY KEY  (`Survey_responseId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Survey_tempReport` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `Survey_responseId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `order` smallint(5) unsigned NOT NULL,
  `sectionNumber` smallint(5) unsigned NOT NULL,
  `sectionName` text,
  `questionNumber` smallint(5) unsigned NOT NULL,
  `questionName` text,
  `questionComment` mediumtext,
  `answerNumber` smallint(5) unsigned default NULL,
  `answerValue` mediumtext,
  `answerComment` mediumtext,
  `entryDate` bigint(20) unsigned NOT NULL COMMENT 'UTC Unix Time',
  `isCorrect` tinyint(3) unsigned default NULL,
  `value` int(11) default NULL,
  `fileStoreageId` char(22) character set utf8 collate utf8_bin default NULL,
  PRIMARY KEY  (`assetId`,`Survey_responseId`,`order`),
  KEY `assetId` (`assetId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Survey_test` (
  `testId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `sequenceNumber` int(11) NOT NULL default '1',
  `dateCreated` datetime default NULL,
  `lastUpdated` datetime default NULL,
  `assetId` char(255) character set utf8 default NULL,
  `name` char(255) character set utf8 default NULL,
  `test` mediumtext character set utf8 NOT NULL,
  PRIMARY KEY  (`testId`),
  KEY `assetId` (`assetId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `SyndicatedContent` (
  `rssUrl` text,
  `maxHeadlines` int(11) NOT NULL default '0',
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `templateId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL default '0',
  `hasTerms` char(255) NOT NULL,
  `cacheTimeout` int(11) NOT NULL default '3600',
  `processMacroInRssUrl` int(11) default '0',
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `TT_projectList` (
  `projectId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `assetId` char(22) character set utf8 collate utf8_bin default NULL,
  `projectName` char(255) NOT NULL,
  `creationDate` bigint(20) NOT NULL,
  `createdBy` char(22) character set utf8 collate utf8_bin NOT NULL,
  `lastUpdatedBy` char(22) character set utf8 collate utf8_bin NOT NULL,
  `lastUpdateDate` bigint(20) NOT NULL,
  PRIMARY KEY  (`projectId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `TT_projectResourceList` (
  `projectId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `resourceId` char(22) character set utf8 collate utf8_bin NOT NULL,
  PRIMARY KEY  (`projectId`,`resourceId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `TT_projectTasks` (
  `taskId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `projectId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `taskName` char(255) NOT NULL,
  PRIMARY KEY  (`taskId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `TT_report` (
  `reportId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `startDate` char(10) NOT NULL,
  `endDate` char(10) NOT NULL,
  `reportComplete` int(11) NOT NULL default '0',
  `resourceId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `creationDate` bigint(20) NOT NULL,
  `createdBy` char(22) character set utf8 collate utf8_bin NOT NULL,
  `lastUpdatedBy` char(22) character set utf8 collate utf8_bin NOT NULL,
  `lastUpdateDate` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `TT_timeEntry` (
  `entryId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `projectId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `taskId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `taskDate` char(10) NOT NULL,
  `hours` float default '0',
  `comments` text,
  `reportId` char(22) character set utf8 collate utf8_bin NOT NULL,
  PRIMARY KEY  (`entryId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `TT_wobject` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `userViewTemplateId` char(22) character set utf8 collate utf8_bin NOT NULL default 'TimeTrackingTMPL000001',
  `managerViewTemplateId` char(22) character set utf8 collate utf8_bin NOT NULL default 'TimeTrackingTMPL000002',
  `timeRowTemplateId` char(22) character set utf8 collate utf8_bin NOT NULL default 'TimeTrackingTMPL000003',
  `pmAssetId` char(22) character set utf8 collate utf8_bin default NULL,
  `groupToManage` char(22) character set utf8 collate utf8_bin NOT NULL default '3',
  `revisionDate` bigint(20) NOT NULL,
  `pmIntegration` int(11) NOT NULL default '0',
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Thingy` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL,
  `templateId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `defaultThingId` char(22) character set utf8 collate utf8_bin default NULL,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `ThingyRecord` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL,
  `templateIdView` char(22) character set utf8 collate utf8_bin default NULL,
  `thingId` char(22) character set utf8 collate utf8_bin default NULL,
  `thingFields` longtext character set utf8,
  `thankYouText` longtext character set utf8,
  `price` float default NULL,
  `duration` bigint(20) default NULL,
  `fieldPrice` longtext,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `ThingyRecord_record` (
  `recordId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `sequenceNumber` int(11) NOT NULL default '1',
  `dateCreated` datetime default NULL,
  `lastUpdated` datetime default NULL,
  `transactionId` char(255) character set utf8 default NULL,
  `assetId` char(255) character set utf8 default NULL,
  `expires` bigint(20) NOT NULL default '0',
  `userId` char(255) character set utf8 default NULL,
  `fields` longtext character set utf8,
  `isHidden` tinyint(1) NOT NULL default '0',
  `sentExpiresNotice` tinyint(1) NOT NULL default '0',
  PRIMARY KEY  (`recordId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Thingy_fields` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `thingId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `fieldId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `sequenceNumber` int(11) NOT NULL,
  `dateCreated` bigint(20) NOT NULL,
  `createdBy` char(22) character set utf8 collate utf8_bin NOT NULL,
  `dateUpdated` bigint(20) NOT NULL,
  `updatedBy` char(22) character set utf8 collate utf8_bin NOT NULL,
  `label` char(255) NOT NULL,
  `fieldType` char(255) NOT NULL,
  `defaultValue` longtext,
  `possibleValues` text,
  `subtext` char(255) default NULL,
  `status` char(255) NOT NULL,
  `width` int(11) default NULL,
  `height` int(11) default NULL,
  `vertical` smallint(1) default NULL,
  `extras` char(255) default NULL,
  `display` int(11) default NULL,
  `viewScreenTitle` int(11) default NULL,
  `displayInSearch` int(11) default NULL,
  `searchIn` int(11) default NULL,
  `fieldInOtherThingId` char(22) character set utf8 collate utf8_bin default NULL,
  `size` int(11) default NULL,
  `pretext` char(255) default NULL,
  PRIMARY KEY  (`fieldId`,`thingId`,`assetId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Thingy_things` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `thingId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `label` char(255) NOT NULL,
  `editScreenTitle` char(255) NOT NULL,
  `editInstructions` text,
  `groupIdAdd` char(22) character set utf8 collate utf8_bin NOT NULL,
  `groupIdEdit` char(22) character set utf8 collate utf8_bin NOT NULL,
  `saveButtonLabel` char(255) NOT NULL,
  `afterSave` char(255) NOT NULL,
  `editTemplateId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `onAddWorkflowId` char(22) character set utf8 collate utf8_bin default NULL,
  `onEditWorkflowId` char(22) character set utf8 collate utf8_bin default NULL,
  `onDeleteWorkflowId` char(22) character set utf8 collate utf8_bin default NULL,
  `groupIdView` char(22) character set utf8 collate utf8_bin NOT NULL,
  `viewTemplateId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `defaultView` char(255) NOT NULL,
  `searchScreenTitle` char(255) NOT NULL,
  `searchDescription` text,
  `groupIdSearch` char(22) character set utf8 collate utf8_bin NOT NULL,
  `groupIdImport` char(22) character set utf8 collate utf8_bin NOT NULL,
  `groupIdExport` char(22) character set utf8 collate utf8_bin NOT NULL,
  `searchTemplateId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `thingsPerPage` int(11) NOT NULL default '25',
  `sortBy` char(22) character set utf8 collate utf8_bin default NULL,
  `display` int(11) default NULL,
  `exportMetaData` int(11) default NULL,
  `maxEntriesPerUser` int(11) default NULL,
  PRIMARY KEY  (`thingId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Thread` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `replies` int(11) NOT NULL default '0',
  `lastPostId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `lastPostDate` bigint(20) default NULL,
  `isLocked` int(11) NOT NULL default '0',
  `isSticky` int(11) NOT NULL default '0',
  `subscriptionGroupId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL default '0',
  `karma` int(11) NOT NULL default '0',
  `karmaScale` int(11) NOT NULL default '1',
  `karmaRank` float(11,6) default NULL,
  `threadRating` int(11) default '0',
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Thread_read` (
  `threadId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `userId` char(22) character set utf8 collate utf8_bin NOT NULL,
  KEY `threadId_userId` (`threadId`,`userId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `UserList` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL default '0',
  `templateId` char(22) character set utf8 collate utf8_bin default NULL,
  `showGroupId` char(22) character set utf8 collate utf8_bin default NULL,
  `hideGroupId` char(22) character set utf8 collate utf8_bin default NULL,
  `usersPerPage` int(11) default NULL,
  `alphabet` text,
  `alphabetSearchField` char(128) default NULL,
  `showOnlyVisibleAsNamed` int(11) default NULL,
  `sortBy` char(128) default NULL,
  `sortOrder` char(4) default NULL,
  `overridePublicEmail` int(11) default NULL,
  `overridePublicProfile` int(11) default NULL,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `WeatherData` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) unsigned NOT NULL default '0',
  `templateId` char(22) character set utf8 collate utf8_bin NOT NULL default 'WeatherDataTmpl0000001',
  `locations` text,
  `partnerId` char(100) default NULL,
  `licenseKey` char(100) default NULL,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `WikiMaster` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL,
  `groupToEditPages` char(22) character set utf8 collate utf8_bin NOT NULL default '2',
  `groupToAdminister` char(22) character set utf8 collate utf8_bin NOT NULL default '3',
  `richEditor` char(22) character set utf8 collate utf8_bin NOT NULL default 'PBrichedit000000000002',
  `frontPageTemplateId` char(22) character set utf8 collate utf8_bin NOT NULL default 'WikiFrontTmpl000000001',
  `pageTemplateId` char(22) character set utf8 collate utf8_bin NOT NULL default 'WikiPageTmpl0000000001',
  `pageEditTemplateId` char(22) character set utf8 collate utf8_bin NOT NULL default 'WikiPageEditTmpl000001',
  `recentChangesTemplateId` char(22) character set utf8 collate utf8_bin NOT NULL default 'WikiRCTmpl000000000001',
  `mostPopularTemplateId` char(22) character set utf8 collate utf8_bin NOT NULL default 'WikiMPTmpl000000000001',
  `pageHistoryTemplateId` char(22) character set utf8 collate utf8_bin NOT NULL default 'WikiPHTmpl000000000001',
  `searchTemplateId` char(22) character set utf8 collate utf8_bin NOT NULL default 'WikiSearchTmpl00000001',
  `recentChangesCount` int(11) NOT NULL default '50',
  `recentChangesCountFront` int(11) NOT NULL default '10',
  `mostPopularCount` int(11) NOT NULL default '50',
  `mostPopularCountFront` int(11) NOT NULL default '10',
  `thumbnailSize` int(11) NOT NULL default '0',
  `maxImageSize` int(11) NOT NULL default '0',
  `approvalWorkflow` char(22) character set utf8 collate utf8_bin NOT NULL default 'pbworkflow000000000003',
  `useContentFilter` int(11) default '0',
  `filterCode` char(30) default 'javascript',
  `byKeywordTemplateId` char(22) character set utf8 collate utf8_bin NOT NULL default 'WikiKeyword00000000001',
  `allowAttachments` int(11) NOT NULL default '0',
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `WikiPage` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL,
  `content` mediumtext,
  `views` bigint(20) NOT NULL default '0',
  `isProtected` int(11) NOT NULL default '0',
  `actionTaken` char(35) NOT NULL,
  `actionTakenBy` char(22) character set utf8 collate utf8_bin NOT NULL,
  `isFeatured` int(1) default NULL,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Workflow` (
  `workflowId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `title` char(255) NOT NULL default 'Untitled',
  `description` text,
  `enabled` int(11) NOT NULL default '0',
  `type` char(255) NOT NULL default 'None',
  `mode` char(20) NOT NULL default 'parallel',
  PRIMARY KEY  (`workflowId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `WorkflowActivity` (
  `activityId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `workflowId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `title` char(255) NOT NULL default 'Untitled',
  `description` text,
  `sequenceNumber` int(11) NOT NULL default '1',
  `className` char(255) default NULL,
  PRIMARY KEY  (`activityId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `WorkflowActivityData` (
  `activityId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `name` char(255) NOT NULL,
  `value` text,
  PRIMARY KEY  (`activityId`,`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `WorkflowInstance` (
  `instanceId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `workflowId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `currentActivityId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `priority` int(11) NOT NULL default '2',
  `className` char(255) default NULL,
  `methodName` char(255) default NULL,
  `parameters` longtext,
  `runningSince` bigint(20) default NULL,
  `lastUpdate` bigint(20) default NULL,
  `lastStatus` char(15) default NULL,
  `noSession` tinyint(1) NOT NULL default '0',
  PRIMARY KEY  (`instanceId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `WorkflowInstanceScratch` (
  `instanceId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `name` char(255) NOT NULL,
  `value` text,
  PRIMARY KEY  (`instanceId`,`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `WorkflowSchedule` (
  `taskId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `title` char(255) NOT NULL default 'Untitled',
  `enabled` int(11) NOT NULL default '0',
  `runOnce` int(11) NOT NULL default '0',
  `minuteOfHour` char(255) NOT NULL default '0',
  `hourOfDay` char(255) NOT NULL default '*',
  `dayOfMonth` char(255) NOT NULL default '*',
  `monthOfYear` char(255) NOT NULL default '*',
  `dayOfWeek` char(255) NOT NULL default '*',
  `workflowId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `className` char(255) default NULL,
  `methodName` char(255) default NULL,
  `priority` int(11) NOT NULL default '2',
  `parameters` longtext,
  PRIMARY KEY  (`taskId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `ZipArchiveAsset` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `templateId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `showPage` char(255) NOT NULL default 'index.html',
  `revisionDate` bigint(20) NOT NULL,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `adSkuPurchase` (
  `adSkuPurchaseId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `sequenceNumber` int(11) NOT NULL default '1',
  `dateCreated` datetime default NULL,
  `lastUpdated` datetime default NULL,
  `isDeleted` tinyint(1) NOT NULL default '0',
  `clicksPurchased` bigint(20) default NULL,
  `dateOfPurchase` bigint(20) default NULL,
  `impressionsPurchased` bigint(20) default NULL,
  `transactionItemId` char(22) character set utf8 collate utf8_bin default NULL,
  `userId` char(22) character set utf8 collate utf8_bin default NULL,
  `adId` char(22) character set utf8 collate utf8_bin default NULL,
  `storedImage` char(22) character set utf8 collate utf8_bin default NULL,
  PRIMARY KEY  (`adSkuPurchaseId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `adSpace` (
  `adSpaceId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `name` char(35) NOT NULL,
  `title` char(255) NOT NULL,
  `description` text,
  `minimumImpressions` int(11) NOT NULL default '1000',
  `minimumClicks` int(11) NOT NULL default '1000',
  `width` int(11) NOT NULL default '468',
  `height` int(11) NOT NULL default '60',
  PRIMARY KEY  (`adSpaceId`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `address` (
  `addressId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `addressBookId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `label` char(35) default NULL,
  `firstName` char(35) default NULL,
  `lastName` char(35) default NULL,
  `address1` char(35) default NULL,
  `address2` char(35) default NULL,
  `address3` char(35) default NULL,
  `city` char(35) default NULL,
  `state` char(35) default NULL,
  `country` char(35) default NULL,
  `code` char(35) default NULL,
  `phoneNumber` char(35) default NULL,
  `organization` char(255) default NULL,
  `email` char(255) default NULL,
  PRIMARY KEY  (`addressId`),
  KEY `addressBookId_addressId` (`addressBookId`,`addressId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `addressBook` (
  `addressBookId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `sessionId` char(22) character set utf8 collate utf8_bin default NULL,
  `userId` char(22) character set utf8 collate utf8_bin default NULL,
  `defaultAddressId` char(22) character set utf8 collate utf8_bin default NULL,
  PRIMARY KEY  (`addressBookId`),
  KEY `userId` (`sessionId`),
  KEY `sessionId` (`sessionId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `advertisement` (
  `adId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `adSpaceId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `ownerUserId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `isActive` int(11) NOT NULL default '0',
  `title` char(255) NOT NULL,
  `type` char(15) NOT NULL default 'text',
  `storageId` char(22) character set utf8 collate utf8_bin default NULL,
  `adText` char(255) default NULL,
  `url` text,
  `richMedia` text,
  `borderColor` char(7) NOT NULL default '#000000',
  `textColor` char(7) NOT NULL default '#000000',
  `backgroundColor` char(7) NOT NULL default '#ffffff',
  `clicks` int(11) NOT NULL default '0',
  `clicksBought` int(11) NOT NULL default '0',
  `impressions` int(11) NOT NULL default '0',
  `impressionsBought` int(11) NOT NULL default '0',
  `priority` int(11) NOT NULL default '0',
  `nextInPriority` bigint(20) NOT NULL default '0',
  `renderedAd` text,
  PRIMARY KEY  (`adId`),
  KEY `adSpaceId_isActive` (`adSpaceId`,`isActive`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `analyticRule` (
  `ruleId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `sequenceNumber` int(11) NOT NULL default '1',
  `dateCreated` datetime default NULL,
  `lastUpdated` datetime default NULL,
  `bucketName` char(255) default NULL,
  `regexp` char(255) NOT NULL default '.+',
  PRIMARY KEY  (`ruleId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `asset` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `parentId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `lineage` char(255) NOT NULL,
  `state` char(35) NOT NULL,
  `className` char(255) NOT NULL,
  `creationDate` bigint(20) NOT NULL default '997995720',
  `createdBy` char(22) character set utf8 collate utf8_bin NOT NULL default '3',
  `stateChanged` char(22) character set utf8 collate utf8_bin NOT NULL default '997995720',
  `stateChangedBy` char(22) character set utf8 collate utf8_bin NOT NULL default '3',
  `isLockedBy` char(22) character set utf8 collate utf8_bin default NULL,
  `isSystem` int(11) NOT NULL default '0',
  `lastExportedAs` char(255) default NULL,
  PRIMARY KEY  (`assetId`),
  UNIQUE KEY `lineage` (`lineage`),
  KEY `parentId` (`parentId`),
  KEY `state_parentId_lineage` (`state`,`parentId`,`lineage`),
  KEY `isPrototype_className_assetId` (`className`,`assetId`),
  KEY `className_assetId_state` (`className`,`assetId`,`state`),
  KEY `state_lineage` (`state`,`lineage`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `assetAspectComments` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL,
  `comments` longtext,
  `averageCommentRating` int(11) default NULL,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `assetAspectRssFeed` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL,
  `itemsPerFeed` int(11) default '25',
  `feedCopyright` text character set utf8,
  `feedTitle` text character set utf8,
  `feedDescription` mediumtext character set utf8,
  `feedImage` char(22) character set utf8 collate utf8_bin default NULL,
  `feedImageLink` text character set utf8,
  `feedImageDescription` mediumtext character set utf8,
  `feedHeaderLinks` char(32) character set utf8 default 'rss\natom',
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `assetAspect_Subscribable` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL,
  `subscriptionGroupId` char(22) character set utf8 collate utf8_bin default NULL,
  `subscriptionTemplateId` char(22) character set utf8 collate utf8_bin default NULL,
  `skipNotification` int(11) default NULL,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `assetData` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL default '0',
  `revisedBy` char(22) character set utf8 collate utf8_bin NOT NULL,
  `tagId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `status` char(35) NOT NULL default 'pending',
  `title` char(255) NOT NULL default 'untitled',
  `menuTitle` char(255) NOT NULL default 'untitled',
  `url` char(255) NOT NULL,
  `ownerUserId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `groupIdView` char(22) character set utf8 collate utf8_bin NOT NULL,
  `groupIdEdit` char(22) character set utf8 collate utf8_bin NOT NULL,
  `synopsis` text,
  `newWindow` int(11) NOT NULL default '0',
  `isHidden` int(11) NOT NULL default '0',
  `isPackage` int(11) NOT NULL default '0',
  `isPrototype` int(11) NOT NULL default '0',
  `encryptPage` int(11) NOT NULL default '0',
  `assetSize` int(11) NOT NULL default '0',
  `extraHeadTags` text,
  `skipNotification` int(11) NOT NULL default '0',
  `isExportable` int(11) NOT NULL default '1',
  `inheritUrlFromParent` int(11) NOT NULL default '0',
  `lastModified` bigint(20) default NULL,
  `extraHeadTagsPacked` longtext,
  `usePackedHeadTags` int(1) default NULL,
  PRIMARY KEY  (`assetId`,`revisionDate`),
  KEY `assetId_url` (`assetId`,`url`),
  KEY `assetId_revisionDate_status_tagId` (`assetId`,`revisionDate`,`status`,`tagId`),
  KEY `url` (`url`),
  KEY `assetId_status_tagId_revisionDate` (`assetId`,`status`,`tagId`,`revisionDate`),
  KEY `assetId_status` (`assetId`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `assetHistory` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `userId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `dateStamp` bigint(20) NOT NULL default '0',
  `actionTaken` char(255) NOT NULL,
  `url` char(255) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `assetIndex` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `title` char(255) default NULL,
  `synopsis` text,
  `url` char(255) default NULL,
  `creationDate` bigint(20) default NULL,
  `revisionDate` bigint(20) default NULL,
  `ownerUserId` char(22) character set utf8 collate utf8_bin default NULL,
  `groupIdView` char(22) character set utf8 collate utf8_bin default NULL,
  `groupIdEdit` char(22) character set utf8 collate utf8_bin default NULL,
  `className` char(255) default NULL,
  `isPublic` int(11) NOT NULL default '1',
  `keywords` mediumtext,
  `lineage` char(255) default NULL,
  PRIMARY KEY  (`assetId`),
  FULLTEXT KEY `keywords` (`keywords`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `assetKeyword` (
  `keyword` char(64) NOT NULL,
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  PRIMARY KEY  (`keyword`,`assetId`),
  KEY `keyword` (`keyword`),
  KEY `assetId` (`assetId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `assetVersionTag` (
  `tagId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `name` char(255) NOT NULL,
  `isCommitted` int(11) NOT NULL default '0',
  `creationDate` bigint(20) NOT NULL default '0',
  `createdBy` char(22) character set utf8 collate utf8_bin NOT NULL,
  `commitDate` bigint(20) NOT NULL default '0',
  `committedBy` char(22) character set utf8 collate utf8_bin NOT NULL,
  `isLocked` int(11) NOT NULL default '0',
  `lockedBy` char(22) character set utf8 collate utf8_bin NOT NULL,
  `groupToUse` char(22) character set utf8 collate utf8_bin NOT NULL,
  `workflowId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `workflowInstanceId` char(22) character set utf8 collate utf8_bin default NULL,
  `comments` text,
  `startTime` datetime default NULL,
  `endTime` datetime default NULL,
  `isSiteWide` tinyint(1) NOT NULL default '0',
  PRIMARY KEY  (`tagId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `authentication` (
  `userId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `authMethod` char(30) NOT NULL,
  `fieldName` char(128) NOT NULL,
  `fieldData` text,
  PRIMARY KEY  (`userId`,`authMethod`,`fieldName`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `bucketLog` (
  `userId` varchar(22) character set utf8 collate utf8_bin NOT NULL,
  `Bucket` varchar(22) character set utf8 collate utf8_bin NOT NULL,
  `duration` int(11) default NULL,
  `timeStamp` datetime default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `cache` (
  `namespace` char(128) NOT NULL,
  `cachekey` char(128) NOT NULL,
  `expires` bigint(20) NOT NULL,
  `size` int(11) NOT NULL,
  `content` mediumblob,
  PRIMARY KEY  (`namespace`,`cachekey`),
  KEY `namespace_cachekey_size` (`namespace`,`cachekey`,`expires`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `cart` (
  `cartId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `sessionId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `shippingAddressId` char(22) character set utf8 collate utf8_bin default NULL,
  `shipperId` char(22) character set utf8 collate utf8_bin default NULL,
  `posUserId` char(22) character set utf8 collate utf8_bin default NULL,
  `creationDate` int(20) default NULL,
  PRIMARY KEY  (`cartId`),
  KEY `sessionId` (`sessionId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `cartItem` (
  `itemId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `cartId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `dateAdded` datetime NOT NULL,
  `options` longtext,
  `configuredTitle` char(255) default NULL,
  `shippingAddressId` char(22) character set utf8 collate utf8_bin default NULL,
  `quantity` int(11) NOT NULL default '1',
  PRIMARY KEY  (`itemId`),
  KEY `cartId_assetId_dateAdded` (`cartId`,`assetId`,`dateAdded`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `databaseLink` (
  `databaseLinkId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `title` char(255) default NULL,
  `DSN` char(255) default NULL,
  `username` char(255) default NULL,
  `identifier` char(255) default NULL,
  `allowedKeywords` text,
  `allowMacroAccess` int(11) NOT NULL default '0',
  `additionalParameters` char(255) NOT NULL,
  PRIMARY KEY  (`databaseLinkId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `deltaLog` (
  `userId` varchar(22) character set utf8 collate utf8_bin NOT NULL,
  `assetId` varchar(22) character set utf8 collate utf8_bin NOT NULL,
  `delta` int(11) default NULL,
  `timeStamp` bigint(20) default NULL,
  `url` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `donation` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL,
  `defaultPrice` float NOT NULL default '100',
  `thankYouMessage` mediumtext,
  `templateId` char(22) character set utf8 collate utf8_bin NOT NULL,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `filePumpBundle` (
  `bundleId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `sequenceNumber` int(11) NOT NULL default '1',
  `dateCreated` datetime default NULL,
  `lastUpdated` datetime default NULL,
  `bundleName` char(255) character set utf8 NOT NULL default 'New bundle',
  `lastModified` bigint(20) NOT NULL default '0',
  `lastBuild` bigint(20) NOT NULL default '0',
  `jsFiles` longtext character set utf8 NOT NULL,
  `cssFiles` longtext character set utf8 NOT NULL,
  `otherFiles` longtext character set utf8 NOT NULL,
  PRIMARY KEY  (`bundleId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `friendInvitations` (
  `inviteId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `inviterId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `friendId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `dateSent` datetime NOT NULL,
  `comments` char(255) NOT NULL,
  `messageId` char(22) character set utf8 collate utf8_bin NOT NULL,
  PRIMARY KEY  (`inviteId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `groupGroupings` (
  `groupId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `inGroup` char(22) character set utf8 collate utf8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `groupings` (
  `groupId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `userId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `expireDate` bigint(20) NOT NULL default '2114402400',
  `groupAdmin` int(11) NOT NULL default '0',
  PRIMARY KEY  (`groupId`,`userId`),
  KEY `userId` (`userId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `groups` (
  `groupId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `groupName` char(100) default NULL,
  `description` char(255) default NULL,
  `expireOffset` int(11) NOT NULL default '314496000',
  `karmaThreshold` int(11) NOT NULL default '1000000000',
  `ipFilter` text,
  `dateCreated` int(11) NOT NULL default '997938000',
  `lastUpdated` int(11) NOT NULL default '997938000',
  `deleteOffset` int(11) NOT NULL default '14',
  `expireNotifyOffset` int(11) NOT NULL default '-14',
  `expireNotifyMessage` text,
  `expireNotify` int(11) NOT NULL default '0',
  `scratchFilter` text,
  `autoAdd` int(11) NOT NULL default '0',
  `autoDelete` int(11) NOT NULL default '0',
  `databaseLinkId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `groupCacheTimeout` int(11) NOT NULL default '3600',
  `dbQuery` text,
  `isEditable` int(11) NOT NULL default '1',
  `showInForms` int(11) NOT NULL default '1',
  `ldapGroup` char(255) default NULL,
  `ldapGroupProperty` char(255) default NULL,
  `ldapRecursiveProperty` char(255) default NULL,
  `ldapLinkId` char(22) character set utf8 collate utf8_bin default NULL,
  `ldapRecursiveFilter` mediumtext,
  `isAdHocMailGroup` tinyint(4) NOT NULL default '0',
  PRIMARY KEY  (`groupId`),
  KEY `groupName` (`groupName`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `imageColor` (
  `colorId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `name` char(255) NOT NULL default 'untitled',
  `fillTriplet` char(7) NOT NULL default '#000000',
  `fillAlpha` char(2) NOT NULL default '00',
  `strokeTriplet` char(7) NOT NULL default '#000000',
  `strokeAlpha` char(2) NOT NULL default '00',
  PRIMARY KEY  (`colorId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `imageFont` (
  `fontId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `name` char(255) default NULL,
  `storageId` char(22) character set utf8 collate utf8_bin default NULL,
  `filename` char(255) default NULL,
  PRIMARY KEY  (`fontId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `imagePalette` (
  `paletteId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `name` char(255) NOT NULL default 'untitled',
  PRIMARY KEY  (`paletteId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `imagePaletteColors` (
  `paletteId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `colorId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `paletteOrder` int(11) NOT NULL,
  PRIMARY KEY  (`paletteId`,`paletteOrder`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `inbox` (
  `messageId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `status` char(15) NOT NULL default 'pending',
  `dateStamp` bigint(20) NOT NULL,
  `completedOn` bigint(20) default NULL,
  `completedBy` char(22) character set utf8 collate utf8_bin default NULL,
  `userId` char(22) character set utf8 collate utf8_bin default NULL,
  `groupId` char(22) character set utf8 collate utf8_bin default NULL,
  `subject` char(255) NOT NULL default 'No Subject',
  `message` mediumtext,
  `sentBy` char(22) character set utf8 collate utf8_bin NOT NULL default '3',
  PRIMARY KEY  (`messageId`),
  KEY `completedOn_dateStamp` (`completedOn`,`dateStamp`),
  KEY `pb_userId` (`userId`),
  KEY `pb_groupId` (`groupId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `inbox_messageState` (
  `messageId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `userId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `isRead` tinyint(4) NOT NULL default '0',
  `repliedTo` tinyint(4) NOT NULL default '0',
  `deleted` tinyint(4) NOT NULL default '0',
  PRIMARY KEY  (`messageId`,`userId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `incrementer` (
  `incrementerId` char(50) NOT NULL,
  `nextValue` int(11) NOT NULL default '1',
  PRIMARY KEY  (`incrementerId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `karmaLog` (
  `userId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `amount` int(11) NOT NULL default '1',
  `source` char(255) default NULL,
  `description` text,
  `dateModified` bigint(20) NOT NULL default '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `ldapLink` (
  `ldapLinkId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `ldapLinkName` char(255) NOT NULL,
  `ldapUrl` char(255) NOT NULL,
  `connectDn` char(255) NOT NULL,
  `identifier` char(255) NOT NULL,
  `ldapUserRDN` char(255) default NULL,
  `ldapIdentity` char(255) default NULL,
  `ldapIdentityName` char(255) default NULL,
  `ldapPasswordName` char(255) default NULL,
  `ldapSendWelcomeMessage` char(2) default NULL,
  `ldapWelcomeMessage` text,
  `ldapAccountTemplate` char(22) character set utf8 collate utf8_bin NOT NULL,
  `ldapCreateAccountTemplate` char(22) character set utf8 collate utf8_bin NOT NULL,
  `ldapLoginTemplate` char(22) character set utf8 collate utf8_bin NOT NULL,
  `ldapGlobalRecursiveFilter` mediumtext,
  PRIMARY KEY  (`ldapLinkId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `mailQueue` (
  `messageId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `message` mediumtext,
  `toGroup` char(22) character set utf8 collate utf8_bin default NULL,
  `isInbox` tinyint(4) default '0',
  PRIMARY KEY  (`messageId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `metaData_properties` (
  `fieldId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `fieldName` char(100) NOT NULL,
  `description` mediumtext NOT NULL,
  `fieldType` char(30) default NULL,
  `possibleValues` text,
  `defaultValue` char(255) default NULL,
  PRIMARY KEY  (`fieldId`),
  UNIQUE KEY `field_unique` (`fieldName`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `metaData_values` (
  `fieldId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `value` char(255) default NULL,
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  PRIMARY KEY  (`fieldId`,`assetId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `passiveAnalyticsStatus` (
  `startDate` datetime default NULL,
  `endDate` datetime default NULL,
  `running` int(2) default '0',
  `userId` varchar(22) character set utf8 collate utf8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `passiveLog` (
  `userId` varchar(22) character set utf8 collate utf8_bin NOT NULL,
  `assetId` varchar(22) character set utf8 collate utf8_bin NOT NULL,
  `sessionId` varchar(22) character set utf8 collate utf8_bin NOT NULL,
  `timeStamp` bigint(20) default NULL,
  `url` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `passiveProfileAOI` (
  `userId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `fieldId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `value` char(100) NOT NULL,
  `count` int(11) default NULL,
  PRIMARY KEY  (`userId`,`fieldId`,`value`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `passiveProfileLog` (
  `passiveProfileLogId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `userId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `sessionId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `dateOfEntry` bigint(20) NOT NULL default '0',
  PRIMARY KEY  (`passiveProfileLogId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `paymentGateway` (
  `paymentGatewayId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `className` char(255) default NULL,
  `options` longtext,
  PRIMARY KEY  (`paymentGatewayId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `redirect` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `redirectUrl` text,
  `revisionDate` bigint(20) NOT NULL default '0',
  `redirectType` int(11) NOT NULL default '302',
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `replacements` (
  `replacementId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `searchFor` char(255) default NULL,
  `replaceWith` text,
  PRIMARY KEY  (`replacementId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `search` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL default '0',
  `classLimiter` text,
  `searchRoot` char(22) character set utf8 collate utf8_bin NOT NULL default 'PBasset000000000000001',
  `templateId` char(22) character set utf8 collate utf8_bin NOT NULL default 'PBtmpl0000000000000200',
  `useContainers` int(11) NOT NULL default '0',
  `paginateAfter` int(11) NOT NULL default '25',
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `settings` (
  `name` char(255) NOT NULL,
  `value` text,
  PRIMARY KEY  (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `shipper` (
  `shipperId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `className` char(255) default NULL,
  `options` longtext,
  PRIMARY KEY  (`shipperId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `shopCredit` (
  `creditId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `userId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `amount` float NOT NULL default '0',
  `comment` text,
  `dateOfAdjustment` datetime default NULL,
  PRIMARY KEY  (`creditId`),
  KEY `userId` (`userId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `sku` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL,
  `description` mediumtext,
  `sku` char(35) NOT NULL,
  `vendorId` char(22) character set utf8 collate utf8_bin NOT NULL default 'defaultvendor000000000',
  `displayTitle` tinyint(1) NOT NULL default '1',
  `overrideTaxRate` tinyint(1) NOT NULL default '0',
  `taxRateOverride` float NOT NULL default '0',
  `taxConfiguration` longtext,
  `shipsSeparately` tinyint(1) NOT NULL,
  PRIMARY KEY  (`assetId`,`revisionDate`),
  KEY `sku` (`sku`),
  KEY `vendorId` (`vendorId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `snippet` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `snippet` mediumtext,
  `processAsTemplate` int(11) NOT NULL default '0',
  `mimeType` char(50) NOT NULL default 'text/html',
  `revisionDate` bigint(20) NOT NULL default '0',
  `cacheTimeout` int(11) NOT NULL default '3600',
  `snippetPacked` longtext,
  `usePacked` int(1) default NULL,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `subscriptionCode` (
  `batchId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `code` char(64) NOT NULL,
  `status` char(10) NOT NULL default 'Unused',
  `dateCreated` int(11) NOT NULL default '0',
  `dateUsed` int(11) NOT NULL default '0',
  `expires` int(11) NOT NULL default '0',
  `usedBy` char(22) character set utf8 collate utf8_bin NOT NULL,
  PRIMARY KEY  (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `subscriptionCodeBatch` (
  `batchId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `name` char(128) default NULL,
  `description` mediumtext NOT NULL,
  `subscriptionId` char(22) character set utf8 collate utf8_bin NOT NULL,
  PRIMARY KEY  (`batchId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `subscriptionCodeSubscriptions` (
  `code` char(64) NOT NULL,
  `subscriptionId` char(22) character set utf8 collate utf8_bin NOT NULL,
  UNIQUE KEY `code` (`code`,`subscriptionId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `taxDriver` (
  `className` char(255) character set utf8 NOT NULL,
  `options` longtext,
  PRIMARY KEY  (`className`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `tax_eu_vatNumbers` (
  `userId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `countryCode` char(3) character set utf8 NOT NULL,
  `vatNumber` char(20) character set utf8 NOT NULL,
  `viesValidated` tinyint(1) default NULL,
  `viesErrorCode` int(3) default NULL,
  `approved` tinyint(1) default NULL,
  PRIMARY KEY  (`userId`,`vatNumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `tax_generic_rates` (
  `taxId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `country` char(100) NOT NULL,
  `state` char(100) default NULL,
  `city` char(100) default NULL,
  `code` char(100) default NULL,
  `taxRate` float NOT NULL default '0',
  PRIMARY KEY  (`taxId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `template` (
  `template` mediumtext,
  `namespace` char(35) NOT NULL default 'Page',
  `isEditable` int(11) NOT NULL default '1',
  `showInForms` int(11) NOT NULL default '1',
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL default '0',
  `parser` char(255) NOT NULL default 'WebGUI::Asset::Template::HTMLTemplate',
  `isDefault` int(1) default '0',
  `templatePacked` longtext,
  `usePacked` int(1) default NULL,
  PRIMARY KEY  (`assetId`,`revisionDate`),
  KEY `namespace_showInForms` (`namespace`,`showInForms`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `template_attachments` (
  `templateId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL default '0',
  `url` varchar(256) character set utf8 NOT NULL,
  `type` varchar(20) character set utf8 default NULL,
  `sequence` int(11) default NULL,
  PRIMARY KEY  (`templateId`,`revisionDate`,`url`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `transaction` (
  `transactionId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `originatingTransactionId` char(22) character set utf8 collate utf8_bin default NULL,
  `isSuccessful` tinyint(1) NOT NULL default '0',
  `orderNumber` int(11) NOT NULL auto_increment,
  `transactionCode` char(100) default NULL,
  `statusCode` char(35) default NULL,
  `statusMessage` char(255) default NULL,
  `userId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `username` char(35) NOT NULL,
  `amount` float default NULL,
  `shopCreditDeduction` float default NULL,
  `shippingAddressId` char(22) character set utf8 collate utf8_bin default NULL,
  `shippingAddressName` char(35) default NULL,
  `shippingAddress1` char(35) default NULL,
  `shippingAddress2` char(35) default NULL,
  `shippingAddress3` char(35) default NULL,
  `shippingCity` char(35) default NULL,
  `shippingState` char(35) default NULL,
  `shippingCountry` char(35) default NULL,
  `shippingCode` char(35) default NULL,
  `shippingPhoneNumber` char(35) default NULL,
  `shippingDriverId` char(22) character set utf8 collate utf8_bin default NULL,
  `shippingDriverLabel` char(35) default NULL,
  `shippingPrice` float default NULL,
  `paymentAddressId` char(22) character set utf8 collate utf8_bin default NULL,
  `paymentAddressName` char(35) default NULL,
  `paymentAddress1` char(35) default NULL,
  `paymentAddress2` char(35) default NULL,
  `paymentAddress3` char(35) default NULL,
  `paymentCity` char(35) default NULL,
  `paymentState` char(35) default NULL,
  `paymentCountry` char(35) default NULL,
  `paymentCode` char(35) default NULL,
  `paymentPhoneNumber` char(35) default NULL,
  `paymentDriverId` char(22) character set utf8 collate utf8_bin default NULL,
  `paymentDriverLabel` char(35) default NULL,
  `taxes` float default NULL,
  `dateOfPurchase` datetime default NULL,
  `isRecurring` tinyint(1) default NULL,
  `notes` mediumtext,
  `cashierUserId` char(22) character set utf8 collate utf8_bin default NULL,
  PRIMARY KEY  (`transactionId`),
  UNIQUE KEY `orderNumber` (`orderNumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `transactionItem` (
  `itemId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `transactionId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `assetId` char(22) character set utf8 collate utf8_bin default NULL,
  `configuredTitle` char(255) default NULL,
  `options` longtext,
  `shippingAddressId` char(22) character set utf8 collate utf8_bin default NULL,
  `shippingName` char(35) default NULL,
  `shippingAddress1` char(35) default NULL,
  `shippingAddress2` char(35) default NULL,
  `shippingAddress3` char(35) default NULL,
  `shippingCity` char(35) default NULL,
  `shippingState` char(35) default NULL,
  `shippingCountry` char(35) default NULL,
  `shippingCode` char(35) default NULL,
  `shippingPhoneNumber` char(35) default NULL,
  `shippingTrackingNumber` char(255) default NULL,
  `orderStatus` char(35) NOT NULL default 'NotShipped',
  `lastUpdated` datetime default NULL,
  `quantity` int(11) NOT NULL default '1',
  `price` float default NULL,
  `vendorId` char(22) character set utf8 collate utf8_bin NOT NULL default 'defaultvendor000000000',
  `vendorPayoutStatus` char(10) default 'NotPaid',
  `vendorPayoutAmount` decimal(8,2) default '0.00',
  `taxRate` decimal(6,3) default NULL,
  `taxConfiguration` longtext,
  PRIMARY KEY  (`itemId`),
  KEY `transactionId` (`transactionId`),
  KEY `vendorId` (`vendorId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `userInvitations` (
  `inviteId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `userId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `dateSent` date default NULL,
  `email` char(255) NOT NULL,
  `newUserId` char(22) character set utf8 collate utf8_bin default NULL,
  `dateCreated` date default NULL,
  PRIMARY KEY  (`inviteId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `userLoginLog` (
  `userId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `status` char(30) default NULL,
  `timeStamp` int(11) default NULL,
  `ipAddress` char(128) default NULL,
  `userAgent` text,
  `sessionId` char(22) character set utf8 collate utf8_bin default NULL,
  `lastPageViewed` int(11) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `userProfileCategory` (
  `profileCategoryId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `label` char(255) NOT NULL default 'Undefined',
  `shortLabel` char(255) default NULL,
  `sequenceNumber` int(11) NOT NULL default '1',
  `visible` int(11) NOT NULL default '1',
  `editable` int(11) NOT NULL default '1',
  `protected` int(11) NOT NULL default '0',
  PRIMARY KEY  (`profileCategoryId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `userProfileData` (
  `userId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `email` char(255) default NULL,
  `firstName` char(255) default NULL,
  `middleName` char(255) default NULL,
  `lastName` char(255) default NULL,
  `icq` char(255) default NULL,
  `aim` char(255) default NULL,
  `msnIM` char(255) default NULL,
  `yahooIM` char(255) default NULL,
  `cellPhone` char(255) default NULL,
  `pager` char(255) default NULL,
  `emailToPager` char(255) default NULL,
  `language` char(255) default NULL,
  `homeAddress` char(255) default NULL,
  `homeCity` char(255) default NULL,
  `homeState` char(255) default NULL,
  `homeZip` char(255) default NULL,
  `homeCountry` char(255) default NULL,
  `homePhone` char(255) default NULL,
  `workAddress` char(255) default NULL,
  `workCity` char(255) default NULL,
  `workState` char(255) default NULL,
  `workZip` char(255) default NULL,
  `workCountry` char(255) default NULL,
  `workPhone` char(255) default NULL,
  `gender` char(255) default NULL,
  `birthdate` bigint(20) default NULL,
  `homeURL` char(255) default NULL,
  `workURL` char(255) default NULL,
  `workName` char(255) default NULL,
  `timeZone` char(255) default NULL,
  `dateFormat` char(255) default NULL,
  `timeFormat` char(255) default NULL,
  `discussionLayout` char(255) default NULL,
  `firstDayOfWeek` char(255) default NULL,
  `uiLevel` char(255) default NULL,
  `alias` char(255) default NULL,
  `signature` longtext,
  `publicProfile` longtext,
  `toolbar` char(255) default NULL,
  `photo` char(22) character set utf8 collate utf8_bin default NULL,
  `avatar` char(22) character set utf8 collate utf8_bin default NULL,
  `department` char(255) default NULL,
  `allowPrivateMessages` longtext,
  `ableToBeFriend` tinyint(4) default NULL,
  `showMessageOnLoginSeen` bigint(20) default NULL,
  `showOnline` tinyint(1) default NULL,
  `versionTagMode` char(255) default NULL,
  `wg_privacySettings` longtext,
  `receiveInboxEmailNotifications` tinyint(1) default NULL,
  `receiveInboxSmsNotifications` tinyint(1) default NULL,
  PRIMARY KEY  (`userId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `userProfileField` (
  `fieldName` char(128) NOT NULL,
  `label` char(255) NOT NULL default 'Undefined',
  `visible` int(11) NOT NULL default '0',
  `required` int(11) NOT NULL default '0',
  `fieldType` char(128) NOT NULL default 'text',
  `possibleValues` text,
  `dataDefault` text,
  `sequenceNumber` int(11) NOT NULL default '1',
  `profileCategoryId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `protected` int(11) NOT NULL default '0',
  `editable` int(11) NOT NULL default '1',
  `forceImageOnly` int(11) default '1',
  `showAtRegistration` int(11) NOT NULL default '0',
  `requiredForPasswordRecovery` int(11) NOT NULL default '0',
  `extras` text,
  `defaultPrivacySetting` char(128) default NULL,
  PRIMARY KEY  (`fieldName`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `userSession` (
  `sessionId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `expires` int(11) default NULL,
  `lastPageView` int(11) default NULL,
  `adminOn` int(11) NOT NULL default '0',
  `lastIP` char(50) default NULL,
  `userId` char(22) character set utf8 collate utf8_bin NOT NULL,
  PRIMARY KEY  (`sessionId`),
  KEY `expires` (`expires`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `userSessionScratch` (
  `sessionId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `name` char(255) NOT NULL,
  `value` text,
  PRIMARY KEY  (`sessionId`,`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `users` (
  `userId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `username` char(100) default NULL,
  `authMethod` char(30) NOT NULL default 'WebGUI',
  `dateCreated` int(11) NOT NULL default '1019867418',
  `lastUpdated` int(11) NOT NULL default '1019867418',
  `karma` int(11) NOT NULL default '0',
  `status` char(35) NOT NULL default 'Active',
  `referringAffiliate` char(22) character set utf8 collate utf8_bin NOT NULL,
  `friendsGroup` char(22) character set utf8 collate utf8_bin NOT NULL,
  PRIMARY KEY  (`userId`),
  UNIQUE KEY `username_unique` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `vendor` (
  `vendorId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `dateCreated` datetime default NULL,
  `name` char(255) default NULL,
  `userId` char(22) character set utf8 collate utf8_bin NOT NULL default '3',
  `preferredPaymentType` char(255) default NULL,
  `paymentInformation` text,
  `paymentAddressId` char(22) character set utf8 collate utf8_bin default NULL,
  `url` text,
  PRIMARY KEY  (`vendorId`),
  KEY `userId` (`userId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `webguiVersion` (
  `webguiVersion` char(10) default NULL,
  `versionType` char(30) default NULL,
  `dateApplied` int(11) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `wobject` (
  `displayTitle` int(11) NOT NULL default '1',
  `description` mediumtext,
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `styleTemplateId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `printableStyleTemplateId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL default '0',
  `mobileStyleTemplateId` char(22) character set utf8 collate utf8_bin default 'PBtmpl0000000000000060',
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

