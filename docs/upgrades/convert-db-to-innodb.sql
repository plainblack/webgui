SET SESSION sort_buffer_size=512*1024*1024; 
SET SESSION read_rnd_buffer_size=512*1024*1024;

CREATE TABLE `AdSku_inno` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL,
  `purchaseTemplate` char(22) character set utf8 collate utf8_bin NOT NULL,
  `manageTemplate` char(22) character set utf8 collate utf8_bin NOT NULL,
  `adSpace` char(22) character set utf8 collate utf8_bin NOT NULL,
  `priority` int(11) default '1',
  `pricePerClick` float default '0',
  `pricePerImpression` float default '0',
  `clickDiscounts` text character set utf8 default NULL,
  `impressionDiscounts` text character set utf8 default NULL,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Article_inno` (
  `linkTitle` char(255) default NULL,
  `linkURL` text,
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `templateId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL default '0',
  `cacheTimeout` int(11) NOT NULL default '3600',
  `storageId` char(22) character set utf8 collate utf8_bin default NULL,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Calendar_inno` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL default '0',
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



CREATE TABLE `Carousel_inno` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL,
  `items` mediumtext character set utf8,
  `templateId` char(22) character set utf8 collate utf8_bin default NULL,
  `slideWidth` int(11) default NULL,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Collaboration_inno` (
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
  `replyRichEditor` char(22) character set utf8 collate utf8_bin default 'PBrichedit000000000002',
  `replyFilterCode` char(30) default 'javascript',
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Dashboard_inno` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL,
  `adminsGroupId` char(22) character set utf8 collate utf8_bin NOT NULL default '4',
  `usersGroupId` char(22) character set utf8 collate utf8_bin NOT NULL default '2',
  `templateId` char(22) character set utf8 collate utf8_bin NOT NULL default 'DashboardViewTmpl00001',
  `isInitialized` tinyint(3) unsigned NOT NULL default '0',
  `assetsToHide` text,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `DataForm_inno` (
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
  `htmlAreaRichEditor` char(22) character set utf8 collate utf8_bin default NULL,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `DataForm_entry_inno` (
  `DataForm_entryId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `userId` char(22) character set utf8 collate utf8_bin,
  `username` char(255) default NULL,
  `ipAddress` char(255) default NULL,
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `entryData` longtext,
  `submissionDate` datetime default NULL,
  PRIMARY KEY  (`DataForm_entryId`),
  KEY `assetId` (`assetId`),
  KEY `assetId_submissionDate` (`assetId`,`submissionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `DataTable_inno` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL,
  `data` longtext character set utf8,
  `templateId` char(22) character set utf8 collate utf8_bin default NULL,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `EMSBadge_inno` (
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



CREATE TABLE `EMSBadgeGroup_inno` (
  `badgeGroupId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `emsAssetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `name` char(100) default NULL,
  PRIMARY KEY  (`badgeGroupId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `EMSEventMetaField_inno` (
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



CREATE TABLE `EMSRegistrant_inno` (
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



CREATE TABLE `EMSRegistrantRibbon_inno` (
  `badgeId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `ribbonAssetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `transactionItemId` char(22) character set utf8 collate utf8_bin default NULL,
  PRIMARY KEY  (`badgeId`,`ribbonAssetId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `EMSRegistrantTicket_inno` (
  `badgeId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `ticketAssetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `purchaseComplete` tinyint(1) default NULL,
  `transactionItemId` char(22) character set utf8 collate utf8_bin default NULL,
  PRIMARY KEY  (`badgeId`,`ticketAssetId`),
  KEY `ticketAssetId_purchaseComplete` (`ticketAssetId`,`purchaseComplete`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `EMSRegistrantToken_inno` (
  `badgeId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `tokenAssetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `quantity` int(11) default NULL,
  `transactionItemIds` text,
  PRIMARY KEY  (`badgeId`,`tokenAssetId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `EMSRibbon_inno` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL,
  `percentageDiscount` float NOT NULL default '10',
  `price` float NOT NULL default '0',
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `EMSTicket_inno` (
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



CREATE TABLE `EMSToken_inno` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL,
  `price` float NOT NULL default '0',
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Event_inno` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL,
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



CREATE TABLE `EventManagementSystem_inno` (
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



CREATE TABLE `Event_recur_inno` (
  `recurId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `recurType` char(16) default NULL,
  `pattern` char(255) default NULL,
  `startDate` date default NULL,
  `endDate` char(10) default NULL,
  PRIMARY KEY  (`recurId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Event_relatedlink_inno` (
  `eventlinkId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `linkURL` tinytext,
  `linktext` char(80) default NULL,
  `groupIdView` char(22) character set utf8 collate utf8_bin NOT NULL,
  `sequenceNumber` bigint(20) default NULL,
  PRIMARY KEY (`eventLinkId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `FileAsset_inno` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `storageId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `filename` char(255) NOT NULL,
  `templateId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL default '0',
  `cacheTimeout` int(11) NOT NULL default '3600',
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `FlatDiscount_inno` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL default '0',
  `templateId` char(22) character set utf8 collate utf8_bin NOT NULL default '63ix2-hU0FchXGIWkG3tow',
  `mustSpend` float NOT NULL default '0',
  `percentageDiscount` int(3) NOT NULL default '0',
  `priceDiscount` float NOT NULL default '0',
  `thankYouMessage` mediumtext,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Folder_inno` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `templateId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL default '0',
  `visitorCacheTimeout` int(11) NOT NULL default '3600',
  `sortAlphabetically` int(11) NOT NULL default '0',
  `sortOrder` enum('ASC','DESC') default 'ASC',
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Gallery_inno` (
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



CREATE TABLE `GalleryAlbum_inno` (
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



CREATE TABLE `GalleryFile_inno` (
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



CREATE TABLE `GalleryFile_comment_inno` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `commentId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `userId` char(22) character set utf8 collate utf8_bin default NULL,
  `visitorIp` char(255) default NULL,
  `creationDate` datetime default NULL,
  `bodyText` longtext,
  PRIMARY KEY  (`assetId`,`commentId`),
  KEY `commentId` (`commentId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `HttpProxy_inno` (
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



CREATE TABLE `ImageAsset_inno` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `thumbnailSize` int(11) NOT NULL default '50',
  `parameters` text,
  `revisionDate` bigint(20) NOT NULL default '0',
  `annotations` mediumtext,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `InOutBoard_inno` (
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



CREATE TABLE `InOutBoard_delegates_inno` (
  `userId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `delegateUserId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `InOutBoard_status_inno` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `userId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `status` char(255) default NULL,
  `dateStamp` int(11) NOT NULL,
  `message` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `InOutBoard_statusLog_inno` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `userId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `status` char(255) default NULL,
  `dateStamp` int(11) NOT NULL,
  `message` text,
  `createdBy` char(22) character set utf8 collate utf8_bin default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Layout_inno` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `templateId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `contentPositions` text,
  `assetsToHide` text,
  `revisionDate` bigint(20) NOT NULL default '0',
  `assetOrder` char(20) default 'asc',
  `mobileTemplateId` char(22) character set utf8 collate utf8_bin default 'PBtmpl0000000000000054',
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Map_inno` (
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



CREATE TABLE `MapPoint_inno` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL,
  `latitude` float default NULL,
  `longitude` float default NULL,
  `website` char(255) character set utf8 default NULL,
  `address1` char(255) character set utf8 default NULL,
  `address2` char(255) character set utf8 default NULL,
  `city` char(255) character set utf8 default NULL,
  `state` char(255) character set utf8 default NULL,
  `zipCode` char(255) character set utf8 default NULL,
  `country` char(255) character set utf8 default NULL,
  `phone` char(255) character set utf8 default NULL,
  `fax` char(255) character set utf8 default NULL,
  `email` char(255) character set utf8 default NULL,
  `storageIdPhoto` char(22) character set utf8 collate utf8_bin default NULL,
  `userDefined1` text character set utf8,
  `userDefined2` text character set utf8,
  `userDefined3` text character set utf8,
  `userDefined4` text character set utf8,
  `userDefined5` text character set utf8,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Matrix_inno` (
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



CREATE TABLE `MatrixListing_inno` (
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



CREATE TABLE `MatrixListing_attribute_inno` (
  `matrixId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `matrixListingId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `attributeId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `value` char(255) character set utf8 default NULL,
  PRIMARY KEY  (`attributeId`,`matrixListingId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `MatrixListing_rating_inno` (
  `timeStamp` int(11) NOT NULL default '0',
  `category` char(255) default NULL,
  `rating` int(11) NOT NULL default '1',
  `listingId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `ipAddress` char(15) default NULL,
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `userId` char(22) character set utf8 collate utf8_bin default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `MatrixListing_ratingSummary_inno` (
  `listingId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `category` char(255) NOT NULL,
  `meanValue` decimal(3,2) default NULL,
  `medianValue` int(11) default NULL,
  `countValue` int(11) default NULL,
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  PRIMARY KEY  (`listingId`,`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Matrix_attribute_inno` (
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



CREATE TABLE `MessageBoard_inno` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `templateId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL default '0',
  `visitorCacheTimeout` int(11) NOT NULL default '3600',
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `MultiSearch_inno` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL default '0',
  `templateId` char(22) character set utf8 collate utf8_bin NOT NULL default 'MultiSearchTmpl0000001',
  `predefinedSearches` text,
  `cacheTimeout` int(11) NOT NULL default '3600',
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Navigation_inno` (
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



CREATE TABLE `Newsletter_inno` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL,
  `newsletterTemplateId` char(22) character set utf8 collate utf8_bin NOT NULL default 'newsletter000000000001',
  `mySubscriptionsTemplateId` char(22) character set utf8 collate utf8_bin NOT NULL default 'newslettersubscrip0001',
  `newsletterHeader` mediumtext,
  `newsletterFooter` mediumtext,
  `newsletterCategories` text,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Newsletter_subscriptions_inno` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `userId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `subscriptions` text,
  `lastTimeSent` bigint(20) NOT NULL default '0',
  PRIMARY KEY  (`assetId`,`userId`),
  KEY `lastTimeSent_assetId_userId` (`lastTimeSent`,`assetId`,`userId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `PM_project_inno` (
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
  `createdBy` char(22) character set utf8 collate utf8_bin,
  `lastUpdatedBy` char(22) character set utf8 collate utf8_bin,
  `lastUpdateDate` bigint(20) NOT NULL,
  `projectObserver` char(22) character set utf8 collate utf8_bin default '7',
  PRIMARY KEY  (`projectId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `PM_task_inno` (
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
  `createdBy` char(22) character set utf8 collate utf8_bin,
  `lastUpdatedBy` char(22) character set utf8 collate utf8_bin,
  `lastUpdateDate` bigint(20) NOT NULL,
  `lagTime` bigint(20) default '0',
  `taskType` enum('timed','progressive','milestone') NOT NULL default 'timed',
  PRIMARY KEY  (`taskId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `PM_taskResource_inno` (
  `taskResourceId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `taskId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `sequenceNumber` int(11) NOT NULL,
  `resourceKind` enum('user','group') NOT NULL,
  `resourceId` char(22) character set utf8 collate utf8_bin NOT NULL,
  PRIMARY KEY  (`taskResourceId`),
  UNIQUE KEY `taskId` (`taskId`,`resourceKind`,`resourceId`),
  UNIQUE KEY `taskId_2` (`taskId`,`sequenceNumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `PM_wobject_inno` (
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



CREATE TABLE `Photo_inno` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL,
  `exifData` longtext,
  `location` char(255) default NULL,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Photo_rating_inno` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `userId` char(22) character set utf8 collate utf8_bin default NULL,
  `visitorIp` char(255) default NULL,
  `rating` int(11) default NULL,
  KEY `assetId` (`assetId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Poll_inno` (
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



CREATE TABLE `Poll_answer_inno` (
  `answer` char(3) default NULL,
  `userId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `ipAddress` char(50) default NULL,
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Post_inno` (
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



CREATE TABLE `Post_rating_inno` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `userId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `ipAddress` char(15) NOT NULL,
  `dateOfRating` bigint(20) default NULL,
  `rating` int(11) NOT NULL default '0',
  KEY `assetId_userId` (`assetId`,`userId`),
  KEY `assetId_ipAddress` (`assetId`,`ipAddress`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Product_inno` (
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



CREATE TABLE `RichEdit_inno` (
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



CREATE TABLE `SQLReport_inno` (
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



CREATE TABLE `Shelf_inno` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL default '0',
  `templateId` char(22) character set utf8 collate utf8_bin NOT NULL default 'nFen0xjkZn8WkpM93C9ceQ',
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Shortcut_inno` (
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



CREATE TABLE `Shortcut_overrides_inno` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `fieldName` char(255) NOT NULL,
  `newValue` text,
  PRIMARY KEY  (`assetId`,`fieldName`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `StockData_inno` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `templateId` char(22) character set utf8 collate utf8_bin NOT NULL default 'StockListTMPL000000001',
  `displayTemplateId` char(22) character set utf8 collate utf8_bin NOT NULL default 'StockListTMPL000000002',
  `defaultStocks` text,
  `source` char(50) default 'usa',
  `failover` int(11) default '1',
  `revisionDate` bigint(20) NOT NULL,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Story_inno` (
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



CREATE TABLE `StoryArchive_inno` (
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



CREATE TABLE `StoryTopic_inno` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL,
  `storiesPer` int(11) default NULL,
  `storiesShort` int(11) default NULL,
  `templateId` char(22) character set utf8 collate utf8_bin default NULL,
  `storyTemplateId` char(22) character set utf8 collate utf8_bin default NULL,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Subscription_inno` (
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



CREATE TABLE `Subscription_code_inno` (
  `code` char(64) NOT NULL,
  `batchId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `status` char(10) NOT NULL default 'Unused',
  `dateUsed` bigint(20) default NULL,
  `usedBy` char(22) character set utf8 collate utf8_bin default NULL,
  PRIMARY KEY  (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Subscription_codeBatch_inno` (
  `batchId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `name` char(255) default NULL,
  `description` mediumtext,
  `subscriptionId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `expirationDate` bigint(20) NOT NULL,
  `dateCreated` bigint(20) NOT NULL,
  PRIMARY KEY  (`batchId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Survey_inno` (
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
  `onSurveyEndWorkflowId` char(22) character set utf8 collate utf8_bin default NULL,
  `quizModeSummary` tinyint(3) default NULL,
  `surveySummaryTemplateId` char(22) character set utf8 collate utf8_bin default NULL,
  `allowBackBtn` tinyint(3) default NULL,
  `feedbackTemplateId` char(22) character set utf8 collate utf8_bin default NULL,
  `testResultsTemplateId` char(22) character set utf8 collate utf8_bin default NULL,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Survey_questionTypes_inno` (
  `questionType` char(56) character set utf8 NOT NULL,
  `answers` text character set utf8 NOT NULL,
  PRIMARY KEY  (`questionType`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Survey_response_inno` (
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



CREATE TABLE `Survey_tempReport_inno` (
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



CREATE TABLE `Survey_test_inno` (
  `testId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `sequenceNumber` int(11) NOT NULL default '1',
  `dateCreated` datetime default NULL,
  `lastUpdated` datetime default NULL,
  `assetId` char(22) character set utf8 collate utf8_bin default NULL,
  `name` char(255) character set utf8 default NULL,
  `test` mediumtext character set utf8 NOT NULL,
  PRIMARY KEY  (`testId`),
  KEY `assetId` (`assetId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `SyndicatedContent_inno` (
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



CREATE TABLE `TT_projectList_inno` (
  `projectId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `assetId` char(22) character set utf8 collate utf8_bin default NULL,
  `projectName` char(255) NOT NULL,
  `creationDate` bigint(20) NOT NULL,
  `createdBy` char(22) character set utf8 collate utf8_bin,
  `lastUpdatedBy` char(22) character set utf8 collate utf8_bin,
  `lastUpdateDate` bigint(20) NOT NULL,
  PRIMARY KEY  (`projectId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `TT_projectResourceList_inno` (
  `projectId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `resourceId` char(22) character set utf8 collate utf8_bin NOT NULL,
  PRIMARY KEY  (`projectId`,`resourceId`),
  KEY (`resourceId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `TT_projectTasks_inno` (
  `taskId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `projectId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `taskName` char(255) NOT NULL,
  PRIMARY KEY  (`taskId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `TT_report_inno` (
  `reportId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `startDate` char(10) NOT NULL,
  `endDate` char(10) NOT NULL,
  `reportComplete` int(11) NOT NULL default '0',
  `resourceId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `creationDate` bigint(20) NOT NULL,
  `createdBy` char(22) character set utf8 collate utf8_bin,
  `lastUpdatedBy` char(22) character set utf8 collate utf8_bin,
  `lastUpdateDate` bigint(20) NOT NULL,
  PRIMARY KEY (reportId)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `TT_timeEntry_inno` (
  `entryId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `projectId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `taskId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `taskDate` char(10) NOT NULL,
  `hours` float default '0',
  `comments` text,
  `reportId` char(22) character set utf8 collate utf8_bin NOT NULL,
  PRIMARY KEY  (`entryId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `TT_wobject_inno` (
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



CREATE TABLE `Thingy_inno` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL,
  `templateId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `defaultThingId` char(22) character set utf8 collate utf8_bin default NULL,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `ThingyRecord_inno` (
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



CREATE TABLE `ThingyRecord_record_inno` (
  `recordId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `sequenceNumber` int(11) NOT NULL default '1',
  `dateCreated` datetime default NULL,
  `lastUpdated` datetime default NULL,
  `transactionId` char(22) character set utf8 collate utf8_bin default NULL,
  `assetId` char(22) character set utf8 collate utf8_bin default NULL,
  `expires` bigint(20) NOT NULL default '0',
  `userId` char(22) character set utf8 collate utf8_bin default NULL,
  `fields` longtext character set utf8,
  `isHidden` tinyint(1) NOT NULL default '0',
  `sentExpiresNotice` tinyint(1) NOT NULL default '0',
  PRIMARY KEY  (`recordId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Thingy_fields_inno` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `thingId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `fieldId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `sequenceNumber` int(11) NOT NULL,
  `dateCreated` bigint(20) NOT NULL,
  `createdBy` char(22) character set utf8 collate utf8_bin,
  `dateUpdated` bigint(20) NOT NULL,
  `updatedBy` char(22) character set utf8 collate utf8_bin,
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



CREATE TABLE `Thingy_things_inno` (
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



CREATE TABLE `Thread_inno` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `replies` int(11) NOT NULL default '0',
  `lastPostId` char(22) character set utf8 collate utf8_bin,
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



CREATE TABLE `Thread_read_inno` (
  `threadId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `userId` char(22) character set utf8 collate utf8_bin NOT NULL,
  KEY `threadId_userId` (`threadId`,`userId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `UserList_inno` (
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



CREATE TABLE `WeatherData_inno` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL default '0',
  `templateId` char(22) character set utf8 collate utf8_bin NOT NULL default 'WeatherDataTmpl0000001',
  `locations` text,
  `partnerId` char(100) default NULL,
  `licenseKey` char(100) default NULL,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `WikiMaster_inno` (
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



CREATE TABLE `WikiPage_inno` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL,
  `content` mediumtext,
  `views` bigint(20) NOT NULL default '0',
  `isProtected` int(11) NOT NULL default '0',
  `actionTaken` char(35) NOT NULL,
  `actionTakenBy` char(22) character set utf8 collate utf8_bin,
  `isFeatured` int(1) default NULL,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `Workflow_inno` (
  `workflowId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `title` char(255) NOT NULL default 'Untitled',
  `description` text,
  `enabled` int(11) NOT NULL default '0',
  `type` char(255) NOT NULL default 'None',
  `mode` char(20) NOT NULL default 'parallel',
  PRIMARY KEY  (`workflowId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `WorkflowActivity_inno` (
  `activityId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `workflowId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `title` char(255) NOT NULL default 'Untitled',
  `description` text,
  `sequenceNumber` int(11) NOT NULL default '1',
  `className` char(255) default NULL,
  PRIMARY KEY  (`activityId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `WorkflowActivityData_inno` (
  `activityId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `name` char(255) NOT NULL,
  `value` text,
  PRIMARY KEY  (`activityId`,`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `WorkflowInstance_inno` (
  `instanceId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `workflowId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `currentActivityId` char(22) character set utf8 collate utf8_bin,
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



CREATE TABLE `WorkflowInstanceScratch_inno` (
  `instanceId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `name` char(255) NOT NULL,
  `value` text,
  PRIMARY KEY  (`instanceId`,`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `WorkflowSchedule_inno` (
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



CREATE TABLE `ZipArchiveAsset_inno` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `templateId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `showPage` char(255) NOT NULL default 'index.html',
  `revisionDate` bigint(20) NOT NULL,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `adSkuPurchase_inno` (
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



CREATE TABLE `adSpace_inno` (
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



CREATE TABLE `address_inno` (
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



CREATE TABLE `addressBook_inno` (
  `addressBookId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `sessionId` char(22) character set utf8 collate utf8_bin default NULL,
  `userId` char(22) character set utf8 collate utf8_bin default NULL,
  `defaultAddressId` char(22) character set utf8 collate utf8_bin default NULL,
  PRIMARY KEY  (`addressBookId`),
  KEY `userId` (`sessionId`),
  KEY `sessionId` (`sessionId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `advertisement_inno` (
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



CREATE TABLE `analyticRule_inno` (
  `ruleId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `sequenceNumber` int(11) NOT NULL default '1',
  `dateCreated` datetime default NULL,
  `lastUpdated` datetime default NULL,
  `bucketName` char(255) default NULL,
  `regexp` char(255) NOT NULL default '.+',
  PRIMARY KEY  (`ruleId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `asset_inno` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `parentId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `lineage` char(255) NOT NULL,
  `state` char(35) NOT NULL,
  `className` char(255) NOT NULL,
  `creationDate` bigint(20) NOT NULL default '997995720',
  `createdBy` char(22) character set utf8 collate utf8_bin default '3',
  `stateChanged` char(22) character set utf8 collate utf8_bin NOT NULL default '997995720',
  `stateChangedBy` char(22) character set utf8 collate utf8_bin default '3',
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



CREATE TABLE `assetAspectComments_inno` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL,
  `comments` longtext,
  `averageCommentRating` int(11) default NULL,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `assetAspectRssFeed_inno` (
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



CREATE TABLE `assetAspect_Subscribable_inno` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL,
  `subscriptionGroupId` char(22) character set utf8 collate utf8_bin default NULL,
  `subscriptionTemplateId` char(22) character set utf8 collate utf8_bin default NULL,
  `skipNotification` int(11) default NULL,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `assetData_inno` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL default '0',
  `revisedBy` char(22) character set utf8 collate utf8_bin,
  `tagId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `status` char(35) NOT NULL default 'pending',
  `title` char(255) NOT NULL default 'untitled',
  `menuTitle` char(255) NOT NULL default 'untitled',
  `url` char(255) NOT NULL,
  `ownerUserId` char(22) character set utf8 collate utf8_bin,
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



CREATE TABLE `assetHistory_inno` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `userId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `dateStamp` bigint(20) NOT NULL default '0',
  `actionTaken` char(255) NOT NULL,
  `url` char(255) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `assetIndex_inno` (
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
  PRIMARY KEY  (`assetId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `assetKeyword_inno` (
  `keyword` char(64) NOT NULL,
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  PRIMARY KEY  (`keyword`,`assetId`),
  KEY `keyword` (`keyword`),
  KEY `assetId` (`assetId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `assetVersionTag_inno` (
  `tagId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `name` char(255) NOT NULL,
  `isCommitted` int(11) NOT NULL default '0',
  `creationDate` bigint(20) NOT NULL default '0',
  `createdBy` char(22) character set utf8 collate utf8_bin,
  `commitDate` bigint(20) NOT NULL default '0',
  `committedBy` char(22) character set utf8 collate utf8_bin,
  `isLocked` int(11) NOT NULL default '0',
  `lockedBy` char(22) character set utf8 collate utf8_bin,
  `groupToUse` char(22) character set utf8 collate utf8_bin,
  `workflowId` char(22) character set utf8 collate utf8_bin,
  `workflowInstanceId` char(22) character set utf8 collate utf8_bin default NULL,
  `comments` text,
  `startTime` datetime default NULL,
  `endTime` datetime default NULL,
  `isSiteWide` tinyint(1) NOT NULL default '0',
  PRIMARY KEY  (`tagId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `authentication_inno` (
  `userId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `authMethod` char(30) NOT NULL,
  `fieldName` char(128) NOT NULL,
  `fieldData` text,
  PRIMARY KEY  (`userId`,`authMethod`,`fieldName`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `bucketLog_inno` (
  `userId` char(22) character set utf8 collate utf8_bin,
  `Bucket` char(22) character set utf8 collate utf8_bin NOT NULL,
  `duration` int(11) default NULL,
  `timeStamp` datetime default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `cart_inno` (
  `cartId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `sessionId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `shippingAddressId` char(22) character set utf8 collate utf8_bin default NULL,
  `shipperId` char(22) character set utf8 collate utf8_bin default NULL,
  `posUserId` char(22) character set utf8 collate utf8_bin default NULL,
  `creationDate` int(20) default NULL,
  PRIMARY KEY  (`cartId`),
  KEY `sessionId` (`sessionId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `cartItem_inno` (
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



CREATE TABLE `databaseLink_inno` (
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



CREATE TABLE `deltaLog_inno` (
  `userId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `delta` int(11) default NULL,
  `timeStamp` bigint(20) default NULL,
  `url` char(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `donation_inno` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL,
  `defaultPrice` float NOT NULL default '100',
  `thankYouMessage` mediumtext,
  `templateId` char(22) character set utf8 collate utf8_bin NOT NULL,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `filePumpBundle_inno` (
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



CREATE TABLE `friendInvitations_inno` (
  `inviteId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `inviterId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `friendId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `dateSent` datetime NOT NULL,
  `comments` char(255) NOT NULL,
  `messageId` char(22) character set utf8 collate utf8_bin NOT NULL,
  PRIMARY KEY  (`inviteId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `groupGroupings_inno` (
  `groupId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `inGroup` char(22) character set utf8 collate utf8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `groupings_inno` (
  `groupId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `userId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `expireDate` bigint(20) NOT NULL default '2114402400',
  `groupAdmin` int(11) NOT NULL default '0',
  PRIMARY KEY  (`groupId`,`userId`),
  KEY `userId` (`userId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `groups_inno` (
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
  `databaseLinkId` char(22) character set utf8 collate utf8_bin,
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



CREATE TABLE `imageColor_inno` (
  `colorId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `name` char(255) NOT NULL default 'untitled',
  `fillTriplet` char(7) NOT NULL default '#000000',
  `fillAlpha` char(2) NOT NULL default '00',
  `strokeTriplet` char(7) NOT NULL default '#000000',
  `strokeAlpha` char(2) NOT NULL default '00',
  PRIMARY KEY  (`colorId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `imageFont_inno` (
  `fontId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `name` char(255) default NULL,
  `storageId` char(22) character set utf8 collate utf8_bin default NULL,
  `filename` char(255) default NULL,
  PRIMARY KEY  (`fontId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `imagePalette_inno` (
  `paletteId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `name` char(255) NOT NULL default 'untitled',
  PRIMARY KEY  (`paletteId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `imagePaletteColors_inno` (
  `paletteId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `colorId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `paletteOrder` int(11) NOT NULL,
  PRIMARY KEY  (`paletteId`,`paletteOrder`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `inbox_inno` (
  `messageId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `status` char(15) NOT NULL default 'pending',
  `dateStamp` bigint(20) NOT NULL,
  `completedOn` bigint(20) default NULL,
  `completedBy` char(22) character set utf8 collate utf8_bin default NULL,
  `userId` char(22) character set utf8 collate utf8_bin default NULL,
  `groupId` char(22) character set utf8 collate utf8_bin default NULL,
  `subject` char(255) NOT NULL default 'No Subject',
  `message` mediumtext,
  `sentBy` char(22) character set utf8 collate utf8_bin default '3',
  PRIMARY KEY  (`messageId`),
  KEY `completedOn_dateStamp` (`completedOn`,`dateStamp`),
  KEY `pb_userId` (`userId`),
  KEY `pb_groupId` (`groupId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `inbox_messageState_inno` (
  `messageId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `userId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `isRead` tinyint(4) NOT NULL default '0',
  `repliedTo` tinyint(4) NOT NULL default '0',
  `deleted` tinyint(4) NOT NULL default '0',
  PRIMARY KEY  (`messageId`,`userId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `incrementer_inno` (
  `incrementerId` char(50) NOT NULL,
  `nextValue` int(11) NOT NULL default '1',
  PRIMARY KEY  (`incrementerId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `karmaLog_inno` (
  `userId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `amount` int(11) NOT NULL default '1',
  `source` char(255) default NULL,
  `description` text,
  `dateModified` bigint(20) NOT NULL default '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `ldapLink_inno` (
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



CREATE TABLE `mailQueue_inno` (
  `messageId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `message` mediumtext,
  `toGroup` char(22) character set utf8 collate utf8_bin default NULL,
  `isInbox` tinyint(4) default '0',
  PRIMARY KEY  (`messageId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `metaData_properties_inno` (
  `fieldId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `fieldName` char(100) NOT NULL,
  `description` mediumtext NOT NULL,
  `fieldType` char(30) default NULL,
  `possibleValues` text,
  `defaultValue` char(255) default NULL,
  PRIMARY KEY  (`fieldId`),
  UNIQUE KEY `field_unique` (`fieldName`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `metaData_values_inno` (
  `fieldId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `value` char(255) default NULL,
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  PRIMARY KEY  (`fieldId`,`assetId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `passiveAnalyticsStatus_inno` (
  `startDate` datetime default NULL,
  `endDate` datetime default NULL,
  `running` int(2) default '0',
  `userId` char(22) character set utf8 collate utf8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `passiveLog_inno` (
  `userId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `sessionId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `timeStamp` bigint(20) default NULL,
  `url` char(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `passiveProfileAOI_inno` (
  `userId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `fieldId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `value` char(100) NOT NULL,
  `count` int(11) default NULL,
  PRIMARY KEY  (`userId`,`fieldId`,`value`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `passiveProfileLog_inno` (
  `passiveProfileLogId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `userId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `sessionId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `dateOfEntry` bigint(20) NOT NULL default '0',
  PRIMARY KEY  (`passiveProfileLogId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `paymentGateway_inno` (
  `paymentGatewayId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `className` char(255) default NULL,
  `options` longtext,
  PRIMARY KEY  (`paymentGatewayId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `redirect_inno` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `redirectUrl` text,
  `revisionDate` bigint(20) NOT NULL default '0',
  `redirectType` int(11) NOT NULL default '302',
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `replacements_inno` (
  `replacementId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `searchFor` char(255) default NULL,
  `replaceWith` text,
  PRIMARY KEY  (`replacementId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `search_inno` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL default '0',
  `classLimiter` text,
  `searchRoot` char(22) character set utf8 collate utf8_bin NOT NULL default 'PBasset000000000000001',
  `templateId` char(22) character set utf8 collate utf8_bin NOT NULL default 'PBtmpl0000000000000200',
  `useContainers` int(11) NOT NULL default '0',
  `paginateAfter` int(11) NOT NULL default '25',
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `settings_inno` (
  `name` char(255) NOT NULL,
  `value` text,
  PRIMARY KEY  (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `shipper_inno` (
  `shipperId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `className` char(255) default NULL,
  `options` longtext,
  PRIMARY KEY  (`shipperId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `shopCredit_inno` (
  `creditId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `userId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `amount` float NOT NULL default '0',
  `comment` text,
  `dateOfAdjustment` datetime default NULL,
  PRIMARY KEY  (`creditId`),
  KEY `userId` (`userId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `sku_inno` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL,
  `description` mediumtext,
  `sku` char(35) NOT NULL,
  `vendorId` char(22) character set utf8 collate utf8_bin default 'defaultvendor000000000',
  `displayTitle` tinyint(1) NOT NULL default '1',
  `overrideTaxRate` tinyint(1) NOT NULL default '0',
  `taxRateOverride` float NOT NULL default '0',
  `taxConfiguration` longtext,
  `shipsSeparately` tinyint(1) NOT NULL,
  PRIMARY KEY  (`assetId`,`revisionDate`),
  KEY `sku` (`sku`),
  KEY `vendorId` (`vendorId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `snippet_inno` (
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



CREATE TABLE `taxDriver_inno` (
  `className` char(255) character set utf8 NOT NULL,
  `options` longtext,
  PRIMARY KEY  (`className`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `tax_eu_vatNumbers_inno` (
  `userId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `countryCode` char(3) character set utf8 NOT NULL,
  `vatNumber` char(20) character set utf8 NOT NULL,
  `viesValidated` tinyint(1) default NULL,
  `viesErrorCode` int(3) default NULL,
  `approved` tinyint(1) default NULL,
  PRIMARY KEY  (`userId`,`vatNumber`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `tax_generic_rates_inno` (
  `taxId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `country` char(100) NOT NULL,
  `state` char(100) default NULL,
  `city` char(100) default NULL,
  `code` char(100) default NULL,
  `taxRate` float NOT NULL default '0',
  PRIMARY KEY  (`taxId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `template_inno` (
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


-- Removed primary key due to bug
--  PRIMARY KEY  (`templateId`,`revisionDate`,`url`)
CREATE TABLE `template_attachments_inno` (
  `templateId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL default '0',
  `url` char(255) character set utf8 NOT NULL,
  `type` char(20) character set utf8 default NULL,
  `sequence` int(11) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `transaction_inno` (
  `transactionId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `originatingTransactionId` char(22) character set utf8 collate utf8_bin default NULL,
  `isSuccessful` tinyint(1) NOT NULL default '0',
  `orderNumber` int(11) NOT NULL auto_increment,
  `transactionCode` char(100) default NULL,
  `statusCode` char(35) default NULL,
  `statusMessage` char(255) default NULL,
  `userId` char(22) character set utf8 collate utf8_bin,
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



CREATE TABLE `transactionItem_inno` (
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
  `vendorId` char(22) character set utf8 collate utf8_bin default 'defaultvendor000000000',
  `vendorPayoutStatus` char(10) default 'NotPaid',
  `vendorPayoutAmount` decimal(8,2) default '0.00',
  `taxRate` decimal(6,3) default NULL,
  `taxConfiguration` longtext,
  PRIMARY KEY  (`itemId`),
  KEY `transactionId` (`transactionId`),
  KEY `vendorId` (`vendorId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `userInvitations_inno` (
  `inviteId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `userId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `dateSent` date default NULL,
  `email` char(255) NOT NULL,
  `newUserId` char(22) character set utf8 collate utf8_bin default NULL,
  `dateCreated` date default NULL,
  PRIMARY KEY  (`inviteId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `userLoginLog_inno` (
  `userId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `status` char(30) default NULL,
  `timeStamp` int(11) default NULL,
  `ipAddress` char(128) default NULL,
  `userAgent` text,
  `sessionId` char(22) character set utf8 collate utf8_bin default NULL,
  `lastPageViewed` int(11) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `userProfileCategory_inno` (
  `profileCategoryId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `label` char(255) NOT NULL default 'Undefined',
  `shortLabel` char(255) default NULL,
  `sequenceNumber` int(11) NOT NULL default '1',
  `visible` int(11) NOT NULL default '1',
  `editable` int(11) NOT NULL default '1',
  `protected` int(11) NOT NULL default '0',
  PRIMARY KEY  (`profileCategoryId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- changed all char 255 to char 55 to avoid erno 139
CREATE TABLE `userProfileData_inno` (
  `userId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `email` char(55) default NULL,
  `firstName` char(55) default NULL,
  `middleName` char(55) default NULL,
  `lastName` char(55) default NULL,
  `icq` char(55) default NULL,
  `aim` char(55) default NULL,
  `msnIM` char(55) default NULL,
  `yahooIM` char(55) default NULL,
  `cellPhone` char(55) default NULL,
  `pager` char(55) default NULL,
  `emailToPager` char(55) default NULL,
  `language` char(55) default NULL,
  `homeAddress` char(55) default NULL,
  `homeCity` char(55) default NULL,
  `homeState` char(55) default NULL,
  `homeZip` char(55) default NULL,
  `homeCountry` char(55) default NULL,
  `homePhone` char(55) default NULL,
  `workAddress` char(55) default NULL,
  `workCity` char(55) default NULL,
  `workState` char(55) default NULL,
  `workZip` char(55) default NULL,
  `workCountry` char(55) default NULL,
  `workPhone` char(55) default NULL,
  `gender` char(55) default NULL,
  `birthdate` bigint(20) default NULL,
  `homeURL` char(55) default NULL,
  `workURL` char(55) default NULL,
  `workName` char(55) default NULL,
  `timeZone` char(55) default NULL,
  `dateFormat` char(55) default NULL,
  `timeFormat` char(55) default NULL,
  `discussionLayout` char(55) default NULL,
  `firstDayOfWeek` char(55) default NULL,
  `uiLevel` char(55) default NULL,
  `alias` char(55) default NULL,
  `signature` longtext,
  `publicProfile` longtext,
  `toolbar` char(55) default NULL,
  `photo` char(22) character set utf8 collate utf8_bin default NULL,
  `avatar` char(22) character set utf8 collate utf8_bin default NULL,
  `department` char(55) default NULL,
  `allowPrivateMessages` longtext,
  `ableToBeFriend` tinyint(4) default NULL,
  `showMessageOnLoginSeen` bigint(20) default NULL,
  `showOnline` tinyint(1) default NULL,
  `versionTagMode` char(55) default NULL,
  `wg_privacySettings` longtext,
  `receiveInboxEmailNotifications` tinyint(1) default NULL,
  `receiveInboxSmsNotifications` tinyint(1) default NULL,
  PRIMARY KEY  (`userId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `userProfileField_inno` (
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



CREATE TABLE `userSession_inno` (
  `sessionId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `expires` int(11) default NULL,
  `lastPageView` int(11) default NULL,
  `adminOn` int(11) NOT NULL default '0',
  `lastIP` char(50) default NULL,
  `userId` char(22) character set utf8 collate utf8_bin NOT NULL,
  PRIMARY KEY  (`sessionId`),
  KEY `expires` (`expires`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `userSessionScratch_inno` (
  `sessionId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `name` char(255) NOT NULL,
  `value` text,
  PRIMARY KEY  (`sessionId`,`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `users_inno` (
  `userId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `username` char(100) default NULL,
  `authMethod` char(30) NOT NULL default 'WebGUI',
  `dateCreated` int(11) NOT NULL default '1019867418',
  `lastUpdated` int(11) NOT NULL default '1019867418',
  `karma` int(11) NOT NULL default '0',
  `status` char(35) NOT NULL default 'Active',
  `referringAffiliate` char(22) character set utf8 collate utf8_bin,
  `friendsGroup` char(22) character set utf8 collate utf8_bin,
  PRIMARY KEY  (`userId`),
  UNIQUE KEY `username_unique` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `vendor_inno` (
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



CREATE TABLE `webguiVersion_inno` (
  `webguiVersion` char(10) default NULL,
  `versionType` char(30) default NULL,
  `dateApplied` int(11) default NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



CREATE TABLE `wobject_inno` (
  `displayTitle` int(11) NOT NULL default '1',
  `description` mediumtext,
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `styleTemplateId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `printableStyleTemplateId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL default '0',
  `mobileStyleTemplateId` char(22) character set utf8 collate utf8_bin default 'PBtmpl0000000000000060',
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



INSERT INTO `AdSku_inno` SELECT * FROM `AdSku` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `Article_inno` SELECT * FROM `Article` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `Calendar_inno` SELECT * FROM `Calendar` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `Carousel_inno` SELECT * FROM `Carousel` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `Collaboration_inno` SELECT * FROM `Collaboration` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `Dashboard_inno` SELECT * FROM `Dashboard` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `DataForm_inno` SELECT * FROM `DataForm` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `DataForm_entry_inno` SELECT * FROM `DataForm_entry` ORDER BY `DataForm_entryId`; 
INSERT INTO `DataTable_inno` SELECT * FROM `DataTable` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `EMSBadge_inno` SELECT * FROM `EMSBadge` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `EMSBadgeGroup_inno` SELECT * FROM `EMSBadgeGroup` ORDER BY `badgeGroupId`; 
INSERT INTO `EMSEventMetaField_inno` SELECT * FROM `EMSEventMetaField` ORDER BY `fieldId`; 
INSERT INTO `EMSRegistrant_inno` SELECT * FROM `EMSRegistrant` ORDER BY `badgeId`; 
INSERT INTO `EMSRegistrantRibbon_inno` SELECT * FROM `EMSRegistrantRibbon` ORDER BY `badgeId`, `ribbonAssetId`; 
INSERT INTO `EMSRegistrantTicket_inno` SELECT * FROM `EMSRegistrantTicket` ORDER BY `badgeId`, `ticketAssetId`; 
INSERT INTO `EMSRegistrantToken_inno` SELECT * FROM `EMSRegistrantToken` ORDER BY `badgeId`, `tokenAssetId`; 
INSERT INTO `EMSRibbon_inno` SELECT * FROM `EMSRibbon` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `EMSTicket_inno` SELECT * FROM `EMSTicket` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `EMSToken_inno` SELECT * FROM `EMSToken` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `Event_inno` SELECT * FROM `Event` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `EventManagementSystem_inno` SELECT * FROM `EventManagementSystem` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `Event_recur_inno` SELECT * FROM `Event_recur` ORDER BY `recurId`; 
INSERT INTO `Event_relatedlink_inno` SELECT * FROM `Event_relatedlink` ORDER BY `eventlinkId`; 
INSERT INTO `FileAsset_inno` SELECT * FROM `FileAsset` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `FlatDiscount_inno` SELECT * FROM `FlatDiscount` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `Folder_inno` SELECT * FROM `Folder` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `Gallery_inno` SELECT * FROM `Gallery` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `GalleryAlbum_inno` SELECT * FROM `GalleryAlbum` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `GalleryFile_inno` SELECT * FROM `GalleryFile` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `GalleryFile_comment_inno` SELECT * FROM `GalleryFile_comment` ORDER BY `assetId`, `commentId`; 
INSERT INTO `HttpProxy_inno` SELECT * FROM `HttpProxy` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `ImageAsset_inno` SELECT * FROM `ImageAsset` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `InOutBoard_inno` SELECT * FROM `InOutBoard` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `InOutBoard_delegates_inno` SELECT * FROM `InOutBoard_delegates`; 
INSERT INTO `InOutBoard_status_inno` SELECT * FROM `InOutBoard_status`; 
INSERT INTO `InOutBoard_statusLog_inno` SELECT * FROM `InOutBoard_statusLog`; 
INSERT INTO `Layout_inno` SELECT * FROM `Layout` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `Map_inno` SELECT * FROM `Map` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `MapPoint_inno` SELECT * FROM `MapPoint` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `Matrix_inno` SELECT * FROM `Matrix` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `MatrixListing_inno` SELECT * FROM `MatrixListing` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `MatrixListing_attribute_inno` SELECT * FROM `MatrixListing_attribute` ORDER BY `matrixListingId`, `attributeId`; 
INSERT INTO `MatrixListing_rating_inno` SELECT * FROM `MatrixListing_rating`; 
INSERT INTO `MatrixListing_ratingSummary_inno` SELECT * FROM `MatrixListing_ratingSummary` ORDER BY `listingId`, `category`; 
INSERT INTO `Matrix_attribute_inno` SELECT * FROM `Matrix_attribute` ORDER BY `attributeId`; 
INSERT INTO `MessageBoard_inno` SELECT * FROM `MessageBoard` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `MultiSearch_inno` SELECT * FROM `MultiSearch` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `Navigation_inno` SELECT * FROM `Navigation` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `Newsletter_inno` SELECT * FROM `Newsletter` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `Newsletter_subscriptions_inno` SELECT * FROM `Newsletter_subscriptions` ORDER BY `assetId`, `userId`; 
INSERT INTO `PM_project_inno` SELECT * FROM `PM_project` ORDER BY `projectId`; 
INSERT INTO `PM_task_inno` SELECT * FROM `PM_task` ORDER BY `taskId`; 
INSERT INTO `PM_taskResource_inno` SELECT * FROM `PM_taskResource` ORDER BY `taskResourceId`; 
INSERT INTO `PM_wobject_inno` SELECT * FROM `PM_wobject` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `Photo_inno` SELECT * FROM `Photo` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `Photo_rating_inno` SELECT * FROM `Photo_rating` ORDER BY `assetId`; 
INSERT INTO `Poll_inno` SELECT * FROM `Poll` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `Poll_answer_inno` SELECT * FROM `Poll_answer`; 
INSERT INTO `Post_inno` SELECT * FROM `Post` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `Post_rating_inno` SELECT * FROM `Post_rating`; 
INSERT INTO `Product_inno` SELECT * FROM `Product` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `RichEdit_inno` SELECT * FROM `RichEdit` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `SQLReport_inno` SELECT * FROM `SQLReport` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `Shelf_inno` SELECT * FROM `Shelf` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `Shortcut_inno` SELECT * FROM `Shortcut` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `Shortcut_overrides_inno` SELECT * FROM `Shortcut_overrides` ORDER BY `assetId`, `fieldName`; 
INSERT INTO `StockData_inno` SELECT * FROM `StockData` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `Story_inno` SELECT * FROM `Story` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `StoryArchive_inno` SELECT * FROM `StoryArchive` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `StoryTopic_inno` SELECT * FROM `StoryTopic` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `Subscription_inno` SELECT * FROM `Subscription` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `Subscription_code_inno` SELECT * FROM `Subscription_code` ORDER BY `code`; 
INSERT INTO `Subscription_codeBatch_inno` SELECT * FROM `Subscription_codeBatch` ORDER BY `batchId`; 
INSERT INTO `Survey_inno` SELECT * FROM `Survey` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `Survey_questionTypes_inno` SELECT * FROM `Survey_questionTypes` ORDER BY `questionType`; 
INSERT INTO `Survey_response_inno` SELECT * FROM `Survey_response` ORDER BY `Survey_responseId`; 
INSERT INTO `Survey_tempReport_inno` SELECT * FROM `Survey_tempReport` ORDER BY `assetId`, `Survey_responseId`, `order`; 
INSERT INTO `Survey_test_inno` SELECT * FROM `Survey_test` ORDER BY `testId`; 
INSERT INTO `SyndicatedContent_inno` SELECT * FROM `SyndicatedContent` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `TT_projectList_inno` SELECT * FROM `TT_projectList` ORDER BY `projectId`; 
INSERT INTO `TT_projectResourceList_inno` SELECT * FROM `TT_projectResourceList` ORDER BY `projectId`, `resourceId`; 
INSERT INTO `TT_projectTasks_inno` SELECT * FROM `TT_projectTasks` ORDER BY `taskId`; 
INSERT INTO `TT_report_inno` SELECT * FROM `TT_report`; 
INSERT INTO `TT_timeEntry_inno` SELECT * FROM `TT_timeEntry` ORDER BY `entryId`; 
INSERT INTO `TT_wobject_inno` SELECT * FROM `TT_wobject` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `Thingy_inno` SELECT * FROM `Thingy` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `ThingyRecord_inno` SELECT * FROM `ThingyRecord` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `ThingyRecord_record_inno` SELECT * FROM `ThingyRecord_record` ORDER BY `recordId`; 
INSERT INTO `Thingy_fields_inno` SELECT * FROM `Thingy_fields` ORDER BY `assetId`, `thingId`, `fieldId`; 
INSERT INTO `Thingy_things_inno` SELECT * FROM `Thingy_things` ORDER BY `thingId`; 
INSERT INTO `Thread_inno` SELECT * FROM `Thread` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `Thread_read_inno` SELECT * FROM `Thread_read`; 
INSERT INTO `UserList_inno` SELECT * FROM `UserList` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `WeatherData_inno` SELECT * FROM `WeatherData` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `WikiMaster_inno` SELECT * FROM `WikiMaster` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `WikiPage_inno` SELECT * FROM `WikiPage` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `Workflow_inno` SELECT * FROM `Workflow` ORDER BY `workflowId`; 
INSERT INTO `WorkflowActivity_inno` SELECT * FROM `WorkflowActivity` ORDER BY `activityId`; 
INSERT INTO `WorkflowActivityData_inno` SELECT * FROM `WorkflowActivityData` ORDER BY `activityId`, `name`; 
INSERT INTO `WorkflowInstance_inno` SELECT * FROM `WorkflowInstance` ORDER BY `instanceId`; 
INSERT INTO `WorkflowInstanceScratch_inno` SELECT * FROM `WorkflowInstanceScratch` ORDER BY `instanceId`, `name`; 
INSERT INTO `WorkflowSchedule_inno` SELECT * FROM `WorkflowSchedule` ORDER BY `taskId`; 
INSERT INTO `ZipArchiveAsset_inno` SELECT * FROM `ZipArchiveAsset` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `adSkuPurchase_inno` SELECT * FROM `adSkuPurchase` ORDER BY `adSkuPurchaseId`; 
INSERT INTO `adSpace_inno` SELECT * FROM `adSpace` ORDER BY `adSpaceId`; 
INSERT INTO `address_inno` SELECT * FROM `address` ORDER BY `addressId`; 
INSERT INTO `addressBook_inno` SELECT * FROM `addressBook` ORDER BY `addressBookId`; 
INSERT INTO `advertisement_inno` SELECT * FROM `advertisement` ORDER BY `adId`; 
INSERT INTO `analyticRule_inno` SELECT * FROM `analyticRule` ORDER BY `ruleId`; 
INSERT INTO `asset_inno` SELECT * FROM `asset` ORDER BY `assetId`; 
INSERT INTO `assetAspectComments_inno` SELECT * FROM `assetAspectComments` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `assetAspectRssFeed_inno` SELECT * FROM `assetAspectRssFeed` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `assetAspect_Subscribable_inno` SELECT * FROM `assetAspect_Subscribable` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `assetData_inno` SELECT * FROM `assetData` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `assetHistory_inno` SELECT * FROM `assetHistory`; 
INSERT INTO `assetIndex_inno` SELECT * FROM `assetIndex` ORDER BY `assetId`; 
INSERT INTO `assetKeyword_inno` SELECT * FROM `assetKeyword` ORDER BY `keyword`, `assetId`; 
INSERT INTO `assetVersionTag_inno` SELECT * FROM `assetVersionTag` ORDER BY `tagId`; 
INSERT INTO `authentication_inno` SELECT * FROM `authentication` ORDER BY `userId`, `authMethod`, `fieldName`; 
INSERT INTO `bucketLog_inno` SELECT * FROM `bucketLog`; 
INSERT INTO `cart_inno` SELECT * FROM `cart` ORDER BY `cartId`; 
INSERT INTO `cartItem_inno` SELECT * FROM `cartItem` ORDER BY `itemId`; 
INSERT INTO `databaseLink_inno` SELECT * FROM `databaseLink` ORDER BY `databaseLinkId`; 
INSERT INTO `deltaLog_inno` SELECT * FROM `deltaLog`; 
INSERT INTO `donation_inno` SELECT * FROM `donation` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `filePumpBundle_inno` SELECT * FROM `filePumpBundle` ORDER BY `bundleId`; 
INSERT INTO `friendInvitations_inno` SELECT * FROM `friendInvitations` ORDER BY `inviteId`; 
INSERT INTO `groupGroupings_inno` SELECT * FROM `groupGroupings`; 
INSERT INTO `groupings_inno` SELECT * FROM `groupings` ORDER BY `groupId`, `userId`; 
INSERT INTO `groups_inno` SELECT * FROM `groups` ORDER BY `groupId`; 
INSERT INTO `imageColor_inno` SELECT * FROM `imageColor` ORDER BY `colorId`; 
INSERT INTO `imageFont_inno` SELECT * FROM `imageFont` ORDER BY `fontId`; 
INSERT INTO `imagePalette_inno` SELECT * FROM `imagePalette` ORDER BY `paletteId`; 
INSERT INTO `imagePaletteColors_inno` SELECT * FROM `imagePaletteColors` ORDER BY `paletteId`, `paletteOrder`; 
INSERT INTO `inbox_inno` SELECT * FROM `inbox` ORDER BY `messageId`; 
INSERT INTO `inbox_messageState_inno` SELECT * FROM `inbox_messageState` ORDER BY `messageId`, `userId`; 
INSERT INTO `incrementer_inno` SELECT * FROM `incrementer` ORDER BY `incrementerId`; 
INSERT INTO `karmaLog_inno` SELECT * FROM `karmaLog`; 
INSERT INTO `ldapLink_inno` SELECT * FROM `ldapLink` ORDER BY `ldapLinkId`; 
INSERT INTO `mailQueue_inno` SELECT * FROM `mailQueue` ORDER BY `messageId`; 
INSERT INTO `metaData_properties_inno` SELECT * FROM `metaData_properties` ORDER BY `fieldId`; 
INSERT INTO `metaData_values_inno` SELECT * FROM `metaData_values` ORDER BY `fieldId`, `assetId`; 
INSERT INTO `passiveAnalyticsStatus_inno` SELECT * FROM `passiveAnalyticsStatus`; 
INSERT INTO `passiveLog_inno` SELECT * FROM `passiveLog`; 
INSERT INTO `passiveProfileAOI_inno` SELECT * FROM `passiveProfileAOI` ORDER BY `userId`, `fieldId`, `value`; 
INSERT INTO `passiveProfileLog_inno` SELECT * FROM `passiveProfileLog` ORDER BY `passiveProfileLogId`; 
INSERT INTO `paymentGateway_inno` SELECT * FROM `paymentGateway` ORDER BY `paymentGatewayId`; 
INSERT INTO `redirect_inno` SELECT * FROM `redirect` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `replacements_inno` SELECT * FROM `replacements` ORDER BY `replacementId`; 
INSERT INTO `search_inno` SELECT * FROM `search` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `settings_inno` SELECT * FROM `settings` ORDER BY `name`; 
INSERT INTO `shipper_inno` SELECT * FROM `shipper` ORDER BY `shipperId`; 
INSERT INTO `shopCredit_inno` SELECT * FROM `shopCredit` ORDER BY `creditId`; 
INSERT INTO `sku_inno` SELECT * FROM `sku` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `snippet_inno` SELECT * FROM `snippet` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `taxDriver_inno` SELECT * FROM `taxDriver` ORDER BY `className`; 
INSERT INTO `tax_eu_vatNumbers_inno` SELECT * FROM `tax_eu_vatNumbers` ORDER BY `userId`, `vatNumber`; 
INSERT INTO `tax_generic_rates_inno` SELECT * FROM `tax_generic_rates` ORDER BY `taxId`; 
INSERT INTO `template_inno` SELECT * FROM `template` ORDER BY `assetId`, `revisionDate`; 
INSERT INTO `template_attachments_inno` SELECT * FROM `template_attachments` ORDER BY `templateId`, `revisionDate`, `url`; 
INSERT INTO `transaction_inno` SELECT * FROM `transaction` ORDER BY `transactionId`; 
INSERT INTO `transactionItem_inno` SELECT * FROM `transactionItem` ORDER BY `itemId`; 
INSERT INTO `userInvitations_inno` SELECT * FROM `userInvitations` ORDER BY `inviteId`; 
INSERT INTO `userLoginLog_inno` SELECT * FROM `userLoginLog`; 
INSERT INTO `userProfileCategory_inno` SELECT * FROM `userProfileCategory` ORDER BY `profileCategoryId`; 
INSERT INTO `userProfileData_inno` SELECT * FROM `userProfileData` ORDER BY `userId`; 
INSERT INTO `userProfileField_inno` SELECT * FROM `userProfileField` ORDER BY `fieldName`; 
INSERT INTO `userSession_inno` SELECT * FROM `userSession` ORDER BY `sessionId`; 
INSERT INTO `userSessionScratch_inno` SELECT * FROM `userSessionScratch` ORDER BY `sessionId`, `name`; 
INSERT INTO `users_inno` SELECT * FROM `users` ORDER BY `userId`; 
INSERT INTO `vendor_inno` SELECT * FROM `vendor` ORDER BY `vendorId`; 
INSERT INTO `webguiVersion_inno` SELECT * FROM `webguiVersion`; 
INSERT INTO `wobject_inno` SELECT * FROM `wobject` ORDER BY `assetId`, `revisionDate`;



DROP TABLE `AdSku`; 
DROP TABLE `Article`; 
DROP TABLE `Calendar`; 
DROP TABLE `Carousel`; 
DROP TABLE `Collaboration`; 
DROP TABLE `Dashboard`; 
DROP TABLE `DataForm`; 
DROP TABLE `DataForm_entry`; 
DROP TABLE `DataTable`; 
DROP TABLE `EMSBadge`; 
DROP TABLE `EMSBadgeGroup`; 
DROP TABLE `EMSEventMetaField`; 
DROP TABLE `EMSRegistrant`; 
DROP TABLE `EMSRegistrantRibbon`; 
DROP TABLE `EMSRegistrantTicket`; 
DROP TABLE `EMSRegistrantToken`; 
DROP TABLE `EMSRibbon`; 
DROP TABLE `EMSTicket`; 
DROP TABLE `EMSToken`; 
DROP TABLE `Event`; 
DROP TABLE `EventManagementSystem`; 
DROP TABLE `Event_recur`; 
DROP TABLE `Event_relatedlink`; 
DROP TABLE `FileAsset`; 
DROP TABLE `FlatDiscount`; 
DROP TABLE `Folder`; 
DROP TABLE `Gallery`; 
DROP TABLE `GalleryAlbum`; 
DROP TABLE `GalleryFile`; 
DROP TABLE `GalleryFile_comment`; 
DROP TABLE `HttpProxy`; 
DROP TABLE `ImageAsset`; 
DROP TABLE `InOutBoard`; 
DROP TABLE `InOutBoard_delegates`; 
DROP TABLE `InOutBoard_status`; 
DROP TABLE `InOutBoard_statusLog`; 
DROP TABLE `Layout`; 
DROP TABLE `Map`; 
DROP TABLE `MapPoint`; 
DROP TABLE `Matrix`; 
DROP TABLE `MatrixListing`; 
DROP TABLE `MatrixListing_attribute`; 
DROP TABLE `MatrixListing_rating`; 
DROP TABLE `MatrixListing_ratingSummary`; 
DROP TABLE `Matrix_attribute`; 
DROP TABLE `MessageBoard`; 
DROP TABLE `MultiSearch`; 
DROP TABLE `Navigation`; 
DROP TABLE `Newsletter`; 
DROP TABLE `Newsletter_subscriptions`; 
DROP TABLE `PM_project`; 
DROP TABLE `PM_task`; 
DROP TABLE `PM_taskResource`; 
DROP TABLE `PM_wobject`; 
DROP TABLE `Photo`; 
DROP TABLE `Photo_rating`; 
DROP TABLE `Poll`; 
DROP TABLE `Poll_answer`; 
DROP TABLE `Post`; 
DROP TABLE `Post_rating`; 
DROP TABLE `Product`; 
DROP TABLE `RichEdit`; 
DROP TABLE `SQLReport`; 
DROP TABLE `Shelf`; 
DROP TABLE `Shortcut`; 
DROP TABLE `Shortcut_overrides`; 
DROP TABLE `StockData`; 
DROP TABLE `Story`; 
DROP TABLE `StoryArchive`; 
DROP TABLE `StoryTopic`; 
DROP TABLE `Subscription`; 
DROP TABLE `Subscription_code`; 
DROP TABLE `Subscription_codeBatch`; 
DROP TABLE `Survey`; 
DROP TABLE `Survey_questionTypes`; 
DROP TABLE `Survey_response`; 
DROP TABLE `Survey_tempReport`; 
DROP TABLE `Survey_test`; 
DROP TABLE `SyndicatedContent`; 
DROP TABLE `TT_projectList`; 
DROP TABLE `TT_projectResourceList`; 
DROP TABLE `TT_projectTasks`; 
DROP TABLE `TT_report`; 
DROP TABLE `TT_timeEntry`; 
DROP TABLE `TT_wobject`; 
DROP TABLE `Thingy`; 
DROP TABLE `ThingyRecord`; 
DROP TABLE `ThingyRecord_record`; 
DROP TABLE `Thingy_fields`; 
DROP TABLE `Thingy_things`; 
DROP TABLE `Thread`; 
DROP TABLE `Thread_read`; 
DROP TABLE `UserList`; 
DROP TABLE `WeatherData`; 
DROP TABLE `WikiMaster`; 
DROP TABLE `WikiPage`; 
DROP TABLE `Workflow`; 
DROP TABLE `WorkflowActivity`; 
DROP TABLE `WorkflowActivityData`; 
DROP TABLE `WorkflowInstance`; 
DROP TABLE `WorkflowInstanceScratch`; 
DROP TABLE `WorkflowSchedule`; 
DROP TABLE `ZipArchiveAsset`; 
DROP TABLE `adSkuPurchase`; 
DROP TABLE `adSpace`; 
DROP TABLE `address`; 
DROP TABLE `addressBook`; 
DROP TABLE `advertisement`; 
DROP TABLE `analyticRule`; 
DROP TABLE `asset`; 
DROP TABLE `assetAspectComments`; 
DROP TABLE `assetAspectRssFeed`; 
DROP TABLE `assetAspect_Subscribable`; 
DROP TABLE `assetData`; 
DROP TABLE `assetHistory`; 
DROP TABLE `assetIndex`; 
DROP TABLE `assetKeyword`; 
DROP TABLE `assetVersionTag`; 
DROP TABLE `authentication`; 
DROP TABLE `bucketLog`; 
DROP TABLE `cart`; 
DROP TABLE `cartItem`; 
DROP TABLE `databaseLink`; 
DROP TABLE `deltaLog`; 
DROP TABLE `donation`; 
DROP TABLE `filePumpBundle`; 
DROP TABLE `friendInvitations`; 
DROP TABLE `groupGroupings`; 
DROP TABLE `groupings`; 
DROP TABLE `groups`; 
DROP TABLE `imageColor`; 
DROP TABLE `imageFont`; 
DROP TABLE `imagePalette`; 
DROP TABLE `imagePaletteColors`; 
DROP TABLE `inbox`; 
DROP TABLE `inbox_messageState`; 
DROP TABLE `incrementer`; 
DROP TABLE `karmaLog`; 
DROP TABLE `ldapLink`; 
DROP TABLE `mailQueue`; 
DROP TABLE `metaData_properties`; 
DROP TABLE `metaData_values`; 
DROP TABLE `passiveAnalyticsStatus`; 
DROP TABLE `passiveLog`; 
DROP TABLE `passiveProfileAOI`; 
DROP TABLE `passiveProfileLog`; 
DROP TABLE `paymentGateway`; 
DROP TABLE `redirect`; 
DROP TABLE `replacements`; 
DROP TABLE `search`; 
DROP TABLE `settings`; 
DROP TABLE `shipper`; 
DROP TABLE `shopCredit`; 
DROP TABLE `sku`; 
DROP TABLE `snippet`; 
DROP TABLE `taxDriver`; 
DROP TABLE `tax_eu_vatNumbers`; 
DROP TABLE `tax_generic_rates`; 
DROP TABLE `template`; 
DROP TABLE `template_attachments`; 
DROP TABLE `transaction`; 
DROP TABLE `transactionItem`; 
DROP TABLE `userInvitations`; 
DROP TABLE `userLoginLog`; 
DROP TABLE `userProfileCategory`; 
DROP TABLE `userProfileData`; 
DROP TABLE `userProfileField`; 
DROP TABLE `userSession`; 
DROP TABLE `userSessionScratch`; 
DROP TABLE `users`; 
DROP TABLE `vendor`; 
DROP TABLE `webguiVersion`; 
DROP TABLE `wobject`;




ALTER TABLE `AdSku_inno` RENAME `AdSku`; 
ALTER TABLE `Article_inno` RENAME `Article`; 
ALTER TABLE `Calendar_inno` RENAME `Calendar`; 
ALTER TABLE `Carousel_inno` RENAME `Carousel`; 
ALTER TABLE `Collaboration_inno` RENAME `Collaboration`; 
ALTER TABLE `Dashboard_inno` RENAME `Dashboard`; 
ALTER TABLE `DataForm_inno` RENAME `DataForm`; 
ALTER TABLE `DataForm_entry_inno` RENAME `DataForm_entry`; 
ALTER TABLE `DataTable_inno` RENAME `DataTable`; 
ALTER TABLE `EMSBadge_inno` RENAME `EMSBadge`; 
ALTER TABLE `EMSBadgeGroup_inno` RENAME `EMSBadgeGroup`; 
ALTER TABLE `EMSEventMetaField_inno` RENAME `EMSEventMetaField`; 
ALTER TABLE `EMSRegistrant_inno` RENAME `EMSRegistrant`; 
ALTER TABLE `EMSRegistrantRibbon_inno` RENAME `EMSRegistrantRibbon`; 
ALTER TABLE `EMSRegistrantTicket_inno` RENAME `EMSRegistrantTicket`; 
ALTER TABLE `EMSRegistrantToken_inno` RENAME `EMSRegistrantToken`; 
ALTER TABLE `EMSRibbon_inno` RENAME `EMSRibbon`; 
ALTER TABLE `EMSTicket_inno` RENAME `EMSTicket`; 
ALTER TABLE `EMSToken_inno` RENAME `EMSToken`; 
ALTER TABLE `Event_inno` RENAME `Event`; 
ALTER TABLE `EventManagementSystem_inno` RENAME `EventManagementSystem`; 
ALTER TABLE `Event_recur_inno` RENAME `Event_recur`; 
ALTER TABLE `Event_relatedlink_inno` RENAME `Event_relatedlink`; 
ALTER TABLE `FileAsset_inno` RENAME `FileAsset`; 
ALTER TABLE `FlatDiscount_inno` RENAME `FlatDiscount`; 
ALTER TABLE `Folder_inno` RENAME `Folder`; 
ALTER TABLE `Gallery_inno` RENAME `Gallery`; 
ALTER TABLE `GalleryAlbum_inno` RENAME `GalleryAlbum`; 
ALTER TABLE `GalleryFile_inno` RENAME `GalleryFile`; 
ALTER TABLE `GalleryFile_comment_inno` RENAME `GalleryFile_comment`; 
ALTER TABLE `HttpProxy_inno` RENAME `HttpProxy`; 
ALTER TABLE `ImageAsset_inno` RENAME `ImageAsset`; 
ALTER TABLE `InOutBoard_inno` RENAME `InOutBoard`; 
ALTER TABLE `InOutBoard_delegates_inno` RENAME `InOutBoard_delegates`; 
ALTER TABLE `InOutBoard_status_inno` RENAME `InOutBoard_status`; 
ALTER TABLE `InOutBoard_statusLog_inno` RENAME `InOutBoard_statusLog`; 
ALTER TABLE `Layout_inno` RENAME `Layout`; 
ALTER TABLE `Map_inno` RENAME `Map`; 
ALTER TABLE `MapPoint_inno` RENAME `MapPoint`; 
ALTER TABLE `Matrix_inno` RENAME `Matrix`; 
ALTER TABLE `MatrixListing_inno` RENAME `MatrixListing`; 
ALTER TABLE `MatrixListing_attribute_inno` RENAME `MatrixListing_attribute`; 
ALTER TABLE `MatrixListing_rating_inno` RENAME `MatrixListing_rating`; 
ALTER TABLE `MatrixListing_ratingSummary_inno` RENAME `MatrixListing_ratingSummary`; 
ALTER TABLE `Matrix_attribute_inno` RENAME `Matrix_attribute`; 
ALTER TABLE `MessageBoard_inno` RENAME `MessageBoard`; 
ALTER TABLE `MultiSearch_inno` RENAME `MultiSearch`; 
ALTER TABLE `Navigation_inno` RENAME `Navigation`; 
ALTER TABLE `Newsletter_inno` RENAME `Newsletter`; 
ALTER TABLE `Newsletter_subscriptions_inno` RENAME `Newsletter_subscriptions`; 
ALTER TABLE `PM_project_inno` RENAME `PM_project`; 
ALTER TABLE `PM_task_inno` RENAME `PM_task`; 
ALTER TABLE `PM_taskResource_inno` RENAME `PM_taskResource`; 
ALTER TABLE `PM_wobject_inno` RENAME `PM_wobject`; 
ALTER TABLE `Photo_inno` RENAME `Photo`; 
ALTER TABLE `Photo_rating_inno` RENAME `Photo_rating`; 
ALTER TABLE `Poll_inno` RENAME `Poll`; 
ALTER TABLE `Poll_answer_inno` RENAME `Poll_answer`; 
ALTER TABLE `Post_inno` RENAME `Post`; 
ALTER TABLE `Post_rating_inno` RENAME `Post_rating`; 
ALTER TABLE `Product_inno` RENAME `Product`; 
ALTER TABLE `RichEdit_inno` RENAME `RichEdit`; 
ALTER TABLE `SQLReport_inno` RENAME `SQLReport`; 
ALTER TABLE `Shelf_inno` RENAME `Shelf`; 
ALTER TABLE `Shortcut_inno` RENAME `Shortcut`; 
ALTER TABLE `Shortcut_overrides_inno` RENAME `Shortcut_overrides`; 
ALTER TABLE `StockData_inno` RENAME `StockData`; 
ALTER TABLE `Story_inno` RENAME `Story`; 
ALTER TABLE `StoryArchive_inno` RENAME `StoryArchive`; 
ALTER TABLE `StoryTopic_inno` RENAME `StoryTopic`; 
ALTER TABLE `Subscription_inno` RENAME `Subscription`; 
ALTER TABLE `Subscription_code_inno` RENAME `Subscription_code`; 
ALTER TABLE `Subscription_codeBatch_inno` RENAME `Subscription_codeBatch`; 
ALTER TABLE `Survey_inno` RENAME `Survey`; 
ALTER TABLE `Survey_questionTypes_inno` RENAME `Survey_questionTypes`; 
ALTER TABLE `Survey_response_inno` RENAME `Survey_response`; 
ALTER TABLE `Survey_tempReport_inno` RENAME `Survey_tempReport`; 
ALTER TABLE `Survey_test_inno` RENAME `Survey_test`; 
ALTER TABLE `SyndicatedContent_inno` RENAME `SyndicatedContent`; 
ALTER TABLE `TT_projectList_inno` RENAME `TT_projectList`; 
ALTER TABLE `TT_projectResourceList_inno` RENAME `TT_projectResourceList`; 
ALTER TABLE `TT_projectTasks_inno` RENAME `TT_projectTasks`; 
ALTER TABLE `TT_report_inno` RENAME `TT_report`; 
ALTER TABLE `TT_timeEntry_inno` RENAME `TT_timeEntry`; 
ALTER TABLE `TT_wobject_inno` RENAME `TT_wobject`; 
ALTER TABLE `Thingy_inno` RENAME `Thingy`; 
ALTER TABLE `ThingyRecord_inno` RENAME `ThingyRecord`; 
ALTER TABLE `ThingyRecord_record_inno` RENAME `ThingyRecord_record`; 
ALTER TABLE `Thingy_fields_inno` RENAME `Thingy_fields`; 
ALTER TABLE `Thingy_things_inno` RENAME `Thingy_things`; 
ALTER TABLE `Thread_inno` RENAME `Thread`; 
ALTER TABLE `Thread_read_inno` RENAME `Thread_read`; 
ALTER TABLE `UserList_inno` RENAME `UserList`; 
ALTER TABLE `WeatherData_inno` RENAME `WeatherData`; 
ALTER TABLE `WikiMaster_inno` RENAME `WikiMaster`; 
ALTER TABLE `WikiPage_inno` RENAME `WikiPage`; 
ALTER TABLE `Workflow_inno` RENAME `Workflow`; 
ALTER TABLE `WorkflowActivity_inno` RENAME `WorkflowActivity`; 
ALTER TABLE `WorkflowActivityData_inno` RENAME `WorkflowActivityData`; 
ALTER TABLE `WorkflowInstance_inno` RENAME `WorkflowInstance`; 
ALTER TABLE `WorkflowInstanceScratch_inno` RENAME `WorkflowInstanceScratch`; 
ALTER TABLE `WorkflowSchedule_inno` RENAME `WorkflowSchedule`; 
ALTER TABLE `ZipArchiveAsset_inno` RENAME `ZipArchiveAsset`; 
ALTER TABLE `adSkuPurchase_inno` RENAME `adSkuPurchase`; 
ALTER TABLE `adSpace_inno` RENAME `adSpace`; 
ALTER TABLE `address_inno` RENAME `address`; 
ALTER TABLE `addressBook_inno` RENAME `addressBook`; 
ALTER TABLE `advertisement_inno` RENAME `advertisement`; 
ALTER TABLE `analyticRule_inno` RENAME `analyticRule`; 
ALTER TABLE `asset_inno` RENAME `asset`; 
ALTER TABLE `assetAspectComments_inno` RENAME `assetAspectComments`; 
ALTER TABLE `assetAspectRssFeed_inno` RENAME `assetAspectRssFeed`; 
ALTER TABLE `assetAspect_Subscribable_inno` RENAME `assetAspect_Subscribable`; 
ALTER TABLE `assetData_inno` RENAME `assetData`; 
ALTER TABLE `assetHistory_inno` RENAME `assetHistory`; 
ALTER TABLE `assetIndex_inno` RENAME `assetIndex`; 
ALTER TABLE `assetKeyword_inno` RENAME `assetKeyword`; 
ALTER TABLE `assetVersionTag_inno` RENAME `assetVersionTag`; 
ALTER TABLE `authentication_inno` RENAME `authentication`; 
ALTER TABLE `bucketLog_inno` RENAME `bucketLog`; 
ALTER TABLE `cart_inno` RENAME `cart`; 
ALTER TABLE `cartItem_inno` RENAME `cartItem`; 
ALTER TABLE `databaseLink_inno` RENAME `databaseLink`; 
ALTER TABLE `deltaLog_inno` RENAME `deltaLog`; 
ALTER TABLE `donation_inno` RENAME `donation`; 
ALTER TABLE `filePumpBundle_inno` RENAME `filePumpBundle`; 
ALTER TABLE `friendInvitations_inno` RENAME `friendInvitations`; 
ALTER TABLE `groupGroupings_inno` RENAME `groupGroupings`; 
ALTER TABLE `groupings_inno` RENAME `groupings`; 
ALTER TABLE `groups_inno` RENAME `groups`; 
ALTER TABLE `imageColor_inno` RENAME `imageColor`; 
ALTER TABLE `imageFont_inno` RENAME `imageFont`; 
ALTER TABLE `imagePalette_inno` RENAME `imagePalette`; 
ALTER TABLE `imagePaletteColors_inno` RENAME `imagePaletteColors`; 
ALTER TABLE `inbox_inno` RENAME `inbox`; 
ALTER TABLE `inbox_messageState_inno` RENAME `inbox_messageState`; 
ALTER TABLE `incrementer_inno` RENAME `incrementer`; 
ALTER TABLE `karmaLog_inno` RENAME `karmaLog`; 
ALTER TABLE `ldapLink_inno` RENAME `ldapLink`; 
ALTER TABLE `mailQueue_inno` RENAME `mailQueue`; 
ALTER TABLE `metaData_properties_inno` RENAME `metaData_properties`; 
ALTER TABLE `metaData_values_inno` RENAME `metaData_values`; 
ALTER TABLE `passiveAnalyticsStatus_inno` RENAME `passiveAnalyticsStatus`; 
ALTER TABLE `passiveLog_inno` RENAME `passiveLog`; 
ALTER TABLE `passiveProfileAOI_inno` RENAME `passiveProfileAOI`; 
ALTER TABLE `passiveProfileLog_inno` RENAME `passiveProfileLog`; 
ALTER TABLE `paymentGateway_inno` RENAME `paymentGateway`; 
ALTER TABLE `redirect_inno` RENAME `redirect`; 
ALTER TABLE `replacements_inno` RENAME `replacements`; 
ALTER TABLE `search_inno` RENAME `search`; 
ALTER TABLE `settings_inno` RENAME `settings`; 
ALTER TABLE `shipper_inno` RENAME `shipper`; 
ALTER TABLE `shopCredit_inno` RENAME `shopCredit`; 
ALTER TABLE `sku_inno` RENAME `sku`; 
ALTER TABLE `snippet_inno` RENAME `snippet`; 
ALTER TABLE `taxDriver_inno` RENAME `taxDriver`; 
ALTER TABLE `tax_eu_vatNumbers_inno` RENAME `tax_eu_vatNumbers`; 
ALTER TABLE `tax_generic_rates_inno` RENAME `tax_generic_rates`; 
ALTER TABLE `template_inno` RENAME `template`; 
ALTER TABLE `template_attachments_inno` RENAME `template_attachments`; 
ALTER TABLE `transaction_inno` RENAME `transaction`; 
ALTER TABLE `transactionItem_inno` RENAME `transactionItem`; 
ALTER TABLE `userInvitations_inno` RENAME `userInvitations`; 
ALTER TABLE `userLoginLog_inno` RENAME `userLoginLog`; 
ALTER TABLE `userProfileCategory_inno` RENAME `userProfileCategory`; 
ALTER TABLE `userProfileData_inno` RENAME `userProfileData`; 
ALTER TABLE `userProfileField_inno` RENAME `userProfileField`; 
ALTER TABLE `userSession_inno` RENAME `userSession`; 
ALTER TABLE `userSessionScratch_inno` RENAME `userSessionScratch`; 
ALTER TABLE `users_inno` RENAME `users`; 
ALTER TABLE `vendor_inno` RENAME `vendor`; 
ALTER TABLE `webguiVersion_inno` RENAME `webguiVersion`; 
ALTER TABLE `wobject_inno` RENAME `wobject`;

-- can't use a parentid that doesn't exist
update asset set parentId='PBasset000000000000001' where assetId='PBasset000000000000001';
alter table asset add foreign key (parentId) references asset(assetId) on delete cascade on update cascade;
alter table asset add foreign key (createdBy) references users(userId) on delete set null on update cascade;
alter table asset add foreign key (stateChangedBy) references users(userId) on delete set null on update cascade;
alter table asset add foreign key (isLockedBy) references users(userId) on delete set null on update cascade;
alter table assetVersionTag add foreign key (createdBy) references users(userId) on delete set null on update cascade;
alter table assetVersionTag add foreign key (committedBy) references users(userId) on delete set null on update cascade;
-- have to fix broken data to add the key
update assetVersionTag set lockedBy=null where lockedBy='';
alter table assetVersionTag add foreign key (lockedBy) references users(userId) on delete set null on update cascade;
alter table assetVersionTag add foreign key (groupToUse) references groups(groupId) on delete set null on update cascade;
update assetVersionTag set workflowId=null where workflowId='';
alter table assetVersionTag add foreign key (workflowId) references Workflow(workflowId) on delete set null on update cascade;
update assetVersionTag set workflowInstanceId=null where workflowInstanceId='';
alter table assetVersionTag add foreign key (workflowInstanceId) references WorkflowInstance(instanceId) on delete set null on update cascade;
alter table assetData add foreign key (tagId) references assetVersionTag(tagId) on delete cascade on update cascade;
alter table assetData add foreign key (assetId) references asset(assetId) on delete cascade on update cascade;
alter table assetData add foreign key (revisedBy) references users(userId) on delete set null on update cascade;
alter table assetData add foreign key (ownerUserId) references users(userId) on delete set null on update cascade;
alter table assetData add foreign key (groupIdView) references groups(groupId) on delete restrict on update cascade;
alter table assetData add foreign key (groupIdEdit) references groups(groupId) on delete restrict on update cascade;
alter table passiveLog add foreign key (assetId) references asset(assetId) on delete cascade on update cascade;
alter table metaData_values add foreign key (assetId) references asset(assetId) on delete cascade on update cascade;
alter table assetIndex add foreign key (assetId) references asset(assetId) on delete cascade on update cascade;
alter table assetIndex add foreign key (ownerUserId) references users(userId) on delete set null on update cascade;
alter table assetIndex add foreign key (groupIdView) references groups(groupId) on delete set null on update cascade;
alter table assetIndex add foreign key (groupIdEdit) references groups(groupId) on delete set null on update cascade;
alter table assetIndex add foreign key (className) references asset(className) on delete cascade on update cascade;
alter table assetKeyword add foreign key (assetId) references asset(assetId) on delete cascade on update cascade;
alter table redirect add foreign key (assetId,revisionDate) references assetData(assetId,revisionDate) on delete cascade on update cascade;
alter table Event add foreign key (assetId,revisionDate) references assetData(assetId,revisionDate) on delete cascade on update cascade;
alter table Event add foreign key (recurId) references Event_recur(recurId) on delete set null on update cascade;
alter table Event_relatedlink add foreign key (assetId) references asset(assetId) on delete cascade on update cascade;
alter table Event_relatedlink add foreign key (groupIdView) references groups(groupId) on delete restrict on update cascade;
alter table snippet add foreign key (assetId,revisionDate) references assetData(assetId,revisionDate) on delete cascade on update cascade;
alter table template add foreign key (assetId,revisionDate) references assetData(assetId,revisionDate) on delete cascade on update cascade;
alter table MapPoint add foreign key (assetId,revisionDate) references assetData(assetId,revisionDate) on delete cascade on update cascade;
alter table MatrixListing add foreign key (assetId,revisionDate) references assetData(assetId,revisionDate) on delete cascade on update cascade;
alter table MatrixListing_attribute add foreign key (matrixId) references asset(assetId) on delete cascade on update cascade;
alter table MatrixListing_attribute add foreign key (matrixListingId) references asset(assetId) on delete cascade on update cascade;
alter table MatrixListing_attribute add foreign key (attributeId) references Matrix_attribute(attributeId) on delete cascade on update cascade;
alter table MatrixListing_rating add foreign key (listingId) references asset(assetId) on delete cascade on update cascade;
alter table MatrixListing_rating add foreign key (assetId) references asset(assetId) on delete cascade on update cascade;
alter table MatrixListing_rating add foreign key (userId) references users(userId) on delete cascade on update cascade;
alter table MatrixListing_ratingSummary add foreign key (listingId) references asset(assetId) on delete cascade on update cascade;
alter table MatrixListing_ratingSummary add foreign key (assetId) references asset(assetId) on delete cascade on update cascade;
alter table Matrix_attribute add foreign key (assetId) references asset(assetId) on delete cascade on update cascade;
alter table Shortcut add foreign key (assetId,revisionDate) references assetData(assetId,revisionDate) on delete cascade on update cascade;
alter table Shortcut add foreign key (overrideTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table Shortcut add foreign key (templateId) references asset(assetId) on delete restrict on update cascade;
alter table Shortcut add foreign key (shortcutToAssetId) references asset(assetId) on delete cascade on update cascade;
alter table Shortcut_overrides add foreign key (assetId) references asset(assetId) on delete cascade on update cascade;
alter table Story add foreign key (assetId,revisionDate) references assetData(assetId,revisionDate) on delete cascade on update cascade;
alter table WikiPage add foreign key (assetId,revisionDate) references assetData(assetId,revisionDate) on delete cascade on update cascade;
alter table WikiPage add foreign key (actionTakenBy) references users(userId) on delete set null on update cascade;
alter table Post add foreign key (assetId,revisionDate) references assetData(assetId,revisionDate) on delete cascade on update cascade;
alter table Post add foreign key (threadId) references asset(assetId) on delete cascade on update cascade;
alter table Post_rating add foreign key (assetId) references asset(assetId) on delete cascade on update cascade;
alter table Post_rating add foreign key (userId) references users(userId) on delete cascade on update cascade;
alter table Thread add foreign key (assetId,revisionDate) references Post(assetId,revisionDate) on delete cascade on update cascade;
alter table Thread add foreign key (lastPostId) references asset(assetId) on delete set null on update cascade;
alter table Thread add foreign key (subscriptionGroupId) references groups(groupId) on delete restrict on update cascade;
alter table Thread_read add foreign key (threadId) references asset(assetId) on delete cascade on update cascade;
alter table Thread_read add foreign key (userId) references users(userId) on delete cascade on update cascade;
alter table RichEdit add foreign key (assetId,revisionDate) references assetData(assetId,revisionDate) on delete cascade on update cascade;
alter table FileAsset add foreign key (assetId,revisionDate) references assetData(assetId,revisionDate) on delete cascade on update cascade;
alter table FileAsset add foreign key (templateId) references asset(assetId) on delete restrict on update cascade;
alter table ZipArchiveAsset add foreign key (assetId,revisionDate) references FileAsset(assetId,revisionDate) on delete cascade on update cascade;
alter table ZipArchiveAsset add foreign key (templateId) references asset(assetId) on delete cascade on update cascade;
alter table GalleryFile add foreign key (assetId,revisionDate) references FileAsset(assetId,revisionDate) on delete cascade on update cascade;
alter table Photo add foreign key (assetId,revisionDate) references GalleryFile(assetId,revisionDate) on delete cascade on update cascade;
alter table ImageAsset add foreign key (assetId,revisionDate) references FileAsset(assetId,revisionDate) on delete cascade on update cascade;
alter table sku add foreign key (assetId,revisionDate) references assetData(assetId,revisionDate) on delete cascade on update cascade;
alter table sku add foreign key (vendorId) references vendor(vendorId) on delete set null on update cascade;
alter table donation add foreign key (assetId,revisionDate) references sku(assetId,revisionDate) on delete cascade on update cascade;
alter table donation add foreign key (templateId) references asset(assetId) on delete restrict on update cascade;
alter table AdSku add foreign key (assetId,revisionDate) references sku(assetId,revisionDate) on delete cascade on update cascade;
alter table AdSku add foreign key (purchaseTemplate) references asset(assetId) on delete restrict on update cascade;
alter table AdSku add foreign key (manageTemplate) references asset(assetId) on delete restrict on update cascade;
alter table AdSku add foreign key (adSpace) references adSpace(adSpaceId) on delete cascade on update cascade;
alter table Subscription add foreign key (assetId,revisionDate) references sku(assetId,revisionDate) on delete cascade on update cascade;
alter table Subscription add foreign key (templateId) references asset(assetId) on delete restrict on update cascade;
alter table Subscription add foreign key (subscriptionGroup) references groups(groupId) on delete restrict on update cascade;
alter table Subscription add foreign key (redeemSubscriptionCodeTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table Subscription_code add foreign key (batchId) references Subscription_codeBatch(batchId) on delete cascade on update cascade;
alter table Subscription_code add foreign key (usedBy) references users(userId) on delete cascade on update cascade;
alter table Subscription_codeBatch add foreign key (subscriptionId) references asset(assetId) on delete cascade on update cascade;
alter table EMSBadge add foreign key (assetId,revisionDate) references sku(assetId,revisionDate) on delete cascade on update cascade;
alter table EMSBadge add foreign key (templateId) references asset(assetId) on delete restrict on update cascade;
alter table EMSRibbon add foreign key (assetId,revisionDate) references sku(assetId,revisionDate) on delete cascade on update cascade;
alter table EMSTicket add foreign key (assetId,revisionDate) references sku(assetId,revisionDate) on delete cascade on update cascade;
alter table EMSToken add foreign key (assetId,revisionDate) references sku(assetId,revisionDate) on delete cascade on update cascade;
alter table FlatDiscount add foreign key (assetId,revisionDate) references sku(assetId,revisionDate) on delete cascade on update cascade;
alter table FlatDiscount add foreign key (templateId) references asset(assetId) on delete restrict on update cascade;
alter table Product add foreign key (assetId,revisionDate) references sku(assetId,revisionDate) on delete cascade on update cascade;
alter table Product add foreign key (templateId) references asset(assetId) on delete restrict on update cascade;
alter table wobject add foreign key (assetId,revisionDate) references assetData(assetId,revisionDate) on delete cascade on update cascade;
alter table wobject add foreign key (styleTemplateId) references asset(assetId) on delete restrict on update cascade;
update wobject set printableStyleTemplateId='PBtmpl0000000000000060' where printableStyleTemplateId='';
alter table wobject add foreign key (printableStyleTemplateId) references asset(assetId) on delete restrict on update cascade;
update wobject set mobileStyleTemplateId='PBtmpl0000000000000060' where mobileStyleTemplateId='2p9ygcqH_Z11qOUvQ1uBvw';
alter table wobject add foreign key (mobileStyleTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table Article add foreign key (assetId,revisionDate) references wobject(assetId,revisionDate) on delete cascade on update cascade;
alter table Article add foreign key (templateId) references asset(assetId) on delete restrict on update cascade;
alter table Calendar add foreign key (assetId,revisionDate) references wobject(assetId,revisionDate) on delete cascade on update cascade;
alter table Calendar add foreign key (templateIdMonth) references asset(assetId) on delete restrict on update cascade;
alter table Calendar add foreign key (templateIdWeek) references asset(assetId) on delete restrict on update cascade;
alter table Calendar add foreign key (templateIdDay) references asset(assetId) on delete restrict on update cascade;
alter table Calendar add foreign key (templateIdEvent) references asset(assetId) on delete restrict on update cascade;
alter table Calendar add foreign key (templateIdEventEdit) references asset(assetId) on delete restrict on update cascade;
alter table Calendar add foreign key (templateIdSearch) references asset(assetId) on delete restrict on update cascade;
alter table Calendar add foreign key (templateIdPrintMonth) references asset(assetId) on delete restrict on update cascade;
alter table Calendar add foreign key (templateIdPrintWeek) references asset(assetId) on delete restrict on update cascade;
alter table Calendar add foreign key (templateIdPrintDay) references asset(assetId) on delete restrict on update cascade;
alter table Calendar add foreign key (templateIdPrintEvent) references asset(assetId) on delete restrict on update cascade;
alter table Calendar add foreign key (groupIdEventEdit) references groups(groupId) on delete restrict on update cascade;
alter table Calendar add foreign key (groupIdSubscribed) references groups(groupId) on delete restrict on update cascade;
alter table Calendar add foreign key (templateIdList) references asset(assetId) on delete restrict on update cascade;
alter table Calendar add foreign key (templateIdPrintList) references asset(assetId) on delete restrict on update cascade;
alter table Calendar add foreign key (workflowIdCommit) references Workflow(workflowId) on delete restrict on update cascade;
alter table Carousel add foreign key (assetId,revisionDate) references wobject(assetId,revisionDate) on delete cascade on update cascade;
alter table Carousel add foreign key (templateId) references asset(assetId) on delete restrict on update cascade;
alter table Collaboration add foreign key (assetId,revisionDate) references wobject(assetId,revisionDate) on delete cascade on update cascade;
alter table Newsletter add foreign key (assetId,revisionDate) references Collaboration(assetId,revisionDate) on delete cascade on update cascade;
alter table Newsletter add foreign key (newsletterTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table Newsletter add foreign key (mySubscriptionsTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table Newsletter_subscriptions add foreign key (userId) references users(userId) on delete cascade on update cascade;
alter table Dashboard add foreign key (assetId,revisionDate) references wobject(assetId,revisionDate) on delete cascade on update cascade;
alter table Dashboard add foreign key (adminsGroupId) references groups(groupId) on delete restrict on update cascade;
alter table Dashboard add foreign key (usersGroupId) references groups(groupId) on delete restrict on update cascade;
alter table Dashboard add foreign key (templateId) references asset(assetId) on delete restrict on update cascade;
update DataForm set htmlAreaRichEditor=null where htmlAreaRichEditor='**Use_Default_Editor**';
alter table DataForm add foreign key (assetId,revisionDate) references wobject(assetId,revisionDate) on delete cascade on update cascade;
alter table DataForm add foreign key (emailTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table DataForm add foreign key (acknowlegementTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table DataForm add foreign key (listTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table DataForm add foreign key (templateId) references asset(assetId) on delete restrict on update cascade;
alter table DataForm add foreign key (groupToViewEntries) references groups(groupId) on delete restrict on update cascade;
alter table DataForm add foreign key (workflowIdAddEntry) references Workflow(workflowId) on delete set null on update cascade;
alter table DataForm add foreign key (htmlAreaRichEditor) references asset(assetId) on delete set null on update cascade;
alter table DataForm_entry add foreign key (userId) references users(userId) on delete set null on update cascade;
alter table DataForm_entry add foreign key (assetId) references asset(assetId) on delete cascade on update cascade;
alter table DataTable add foreign key (assetId,revisionDate) references wobject(assetId,revisionDate) on delete cascade on update cascade;
alter table DataTable add foreign key (templateId) references asset(assetId) on delete restrict on update cascade;
alter table EventManagementSystem add foreign key (assetId,revisionDate) references wobject(assetId,revisionDate) on delete cascade on update cascade;
alter table EventManagementSystem add foreign key (templateId) references asset(assetId) on delete restrict on update cascade;
alter table EventManagementSystem add foreign key (badgeBuilderTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table EventManagementSystem add foreign key (lookupRegistrantTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table EventManagementSystem add foreign key (printBadgeTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table EventManagementSystem add foreign key (printTicketTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table EventManagementSystem add foreign key (scheduleTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table EventManagementSystem add foreign key (groupToApproveEvents) references groups(groupId) on delete restrict on update cascade;
alter table EventManagementSystem add foreign key (registrationStaffGroupId) references groups(groupId) on delete restrict on update cascade;
alter table EMSBadgeGroup add foreign key (emsAssetId) references asset(assetId) on delete cascade on update cascade;
alter table EMSEventMetaField add foreign key (assetId) references asset(assetId) on delete cascade on update cascade;
alter table EMSRegistrant add foreign key (userId) references users(userId) on delete set null on update cascade;
alter table EMSRegistrant add foreign key (badgeAssetId) references asset(assetId) on delete cascade on update cascade;
alter table EMSRegistrant add foreign key (emsAssetId) references asset(assetId) on delete cascade on update cascade;
alter table EMSRegistrant add foreign key (transactionItemId) references transactionItem(itemId) on delete cascade on update cascade;
alter table EMSRegistrantRibbon add foreign key (ribbonAssetId) references asset(assetId) on delete cascade on update cascade;
alter table EMSRegistrantRibbon add foreign key (transactionItemId) references transactionItem(itemId) on delete cascade on update cascade;
alter table EMSRegistrantTicket add foreign key (ticketAssetId) references asset(assetId) on delete cascade on update cascade;
alter table EMSRegistrantTicket add foreign key (transactionItemId) references transactionItem(itemId) on delete cascade on update cascade;
alter table EMSRegistrantToken add foreign key (tokenAssetId) references asset(assetId) on delete cascade on update cascade;
alter table search add foreign key (assetId,revisionDate) references wobject(assetId,revisionDate) on delete cascade on update cascade;
alter table search add foreign key (searchRoot) references asset(assetId) on delete restrict on update cascade;
alter table search add foreign key (templateId) references asset(assetId) on delete restrict on update cascade;
alter table Folder add foreign key (assetId,revisionDate) references wobject(assetId,revisionDate) on delete cascade on update cascade;
alter table Folder add foreign key (templateId) references asset(assetId) on delete restrict on update cascade;
alter table Gallery add foreign key (assetId,revisionDate) references wobject(assetId,revisionDate) on delete cascade on update cascade;
alter table Gallery add foreign key (groupIdAddComment) references groups(groupId) on delete restrict on update cascade;
alter table Gallery add foreign key (groupIdAddFile) references groups(groupId) on delete restrict on update cascade;
alter table Gallery add foreign key (richEditIdComment) references asset(assetId) on delete restrict on update cascade;
alter table Gallery add foreign key (templateIdAddArchive) references asset(assetId) on delete restrict on update cascade;
alter table Gallery add foreign key (templateIdDeleteAlbum) references asset(assetId) on delete restrict on update cascade;
alter table Gallery add foreign key (templateIdDeleteFile) references asset(assetId) on delete restrict on update cascade;
alter table Gallery add foreign key (templateIdEditAlbum) references asset(assetId) on delete restrict on update cascade;
alter table Gallery add foreign key (templateIdEditFile) references asset(assetId) on delete restrict on update cascade;
alter table Gallery add foreign key (templateIdListAlbums) references asset(assetId) on delete restrict on update cascade;
alter table Gallery add foreign key (templateIdListAlbumsRss) references asset(assetId) on delete restrict on update cascade;
alter table Gallery add foreign key (templateIdListFilesForUser) references asset(assetId) on delete restrict on update cascade;
alter table Gallery add foreign key (templateIdListFilesForUserRss) references asset(assetId) on delete restrict on update cascade;
alter table Gallery add foreign key (templateIdMakeShortcut) references asset(assetId) on delete restrict on update cascade;
alter table Gallery add foreign key (templateIdSearch) references asset(assetId) on delete restrict on update cascade;
alter table Gallery add foreign key (templateIdViewSlideshow) references asset(assetId) on delete restrict on update cascade;
alter table Gallery add foreign key (templateIdViewThumbnails) references asset(assetId) on delete restrict on update cascade;
alter table Gallery add foreign key (templateIdViewAlbum) references asset(assetId) on delete restrict on update cascade;
alter table Gallery add foreign key (templateIdViewAlbumRss) references asset(assetId) on delete restrict on update cascade;
alter table Gallery add foreign key (templateIdViewFile) references asset(assetId) on delete restrict on update cascade;
alter table Gallery add foreign key (viewAlbumAssetId) references asset(assetId) on delete restrict on update cascade;
alter table Gallery add foreign key (workflowIdCommit) references Workflow(workflowId) on delete restrict on update cascade;
alter table Gallery add foreign key (templateIdEditComment) references asset(assetId) on delete restrict on update cascade;
alter table Gallery add foreign key (richEditIdAlbum) references asset(assetId) on delete restrict on update cascade;
alter table Gallery add foreign key (richEditIdFile) references asset(assetId) on delete restrict on update cascade;
alter table GalleryAlbum add foreign key (assetId,revisionDate) references wobject(assetId,revisionDate) on delete cascade on update cascade;
alter table GalleryAlbum add foreign key (assetIdThumbnail) references asset(assetId) on delete restrict on update cascade;
alter table HttpProxy add foreign key (assetId,revisionDate) references wobject(assetId,revisionDate) on delete cascade on update cascade;
alter table HttpProxy add foreign key (templateId) references asset(assetId) on delete restrict on update cascade;
alter table InOutBoard add foreign key (assetId,revisionDate) references wobject(assetId,revisionDate) on delete cascade on update cascade;
alter table InOutBoard add foreign key (reportViewerGroup) references groups(groupId) on delete restrict on update cascade;
alter table InOutBoard add foreign key (inOutGroup) references groups(groupId) on delete restrict on update cascade;
alter table InOutBoard add foreign key (inOutTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table InOutBoard add foreign key (reportTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table InOutBoard_delegates add foreign key (userId) references users(userId) on delete cascade on update cascade;
alter table InOutBoard_delegates add foreign key (delegateUserId) references users(userId) on delete cascade on update cascade;
alter table InOutBoard_delegates add foreign key (assetId) references asset(assetId) on delete cascade on update cascade;
alter table InOutBoard_status add foreign key (userId) references users(userId) on delete cascade on update cascade;
alter table InOutBoard_status add foreign key (assetId) references asset(assetId) on delete cascade on update cascade;
alter table InOutBoard_statusLog add foreign key (userId) references users(userId) on delete cascade on update cascade;
alter table InOutBoard_statusLog add foreign key (assetId) references asset(assetId) on delete cascade on update cascade;
alter table InOutBoard_statusLog add foreign key (createdBy) references users(userId) on delete cascade on update cascade;
alter table Layout add foreign key (assetId,revisionDate) references wobject(assetId,revisionDate) on delete cascade on update cascade;
alter table Layout add foreign key (templateId) references asset(assetId) on delete restrict on update cascade;
alter table Layout add foreign key (mobileTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table Map add foreign key (assetId,revisionDate) references wobject(assetId,revisionDate) on delete cascade on update cascade;
alter table Map add foreign key (groupIdAddPoint) references groups(groupId) on delete restrict on update cascade;
alter table Map add foreign key (templateIdEditPoint) references asset(assetId) on delete restrict on update cascade;
alter table Map add foreign key (templateIdViewPoint) references asset(assetId) on delete restrict on update cascade;
alter table Map add foreign key (templateIdView) references asset(assetId) on delete restrict on update cascade;
alter table Map add foreign key (workflowIdPoint) references Workflow(workflowId) on delete restrict on update cascade;
alter table Matrix add foreign key (assetId,revisionDate) references wobject(assetId,revisionDate) on delete cascade on update cascade;
alter table Matrix add foreign key (detailTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table Matrix add foreign key (compareTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table Matrix add foreign key (searchTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table Matrix add foreign key (templateId) references asset(assetId) on delete restrict on update cascade;
alter table Matrix add foreign key (submissionApprovalWorkflowId) references Workflow(workflowId) on delete restrict on update cascade;
alter table Matrix add foreign key (editListingTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table Matrix add foreign key (groupToAdd) references groups(groupId) on delete restrict on update cascade;
alter table Matrix add foreign key (screenShotsConfigTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table Matrix add foreign key (screenShotsTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table Matrix add foreign key (maxComparisonsGroup) references groups(groupId) on delete restrict on update cascade;
alter table MessageBoard add foreign key (assetId,revisionDate) references wobject(assetId,revisionDate) on delete cascade on update cascade;
alter table MessageBoard add foreign key (templateId) references asset(assetId) on delete restrict on update cascade;
alter table MultiSearch add foreign key (assetId,revisionDate) references wobject(assetId,revisionDate) on delete cascade on update cascade;
alter table MultiSearch add foreign key (templateId) references asset(assetId) on delete restrict on update cascade;
alter table Survey add foreign key (assetId,revisionDate) references wobject(assetId,revisionDate) on delete cascade on update cascade;
alter table Survey add foreign key (gradebookTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table Survey add foreign key (overviewTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table Survey add foreign key (templateId) references asset(assetId) on delete restrict on update cascade;
alter table Survey add foreign key (surveyEditTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table Survey add foreign key (answerEditTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table Survey add foreign key (questionEditTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table Survey add foreign key (surveyQuestionsId) references asset(assetId) on delete restrict on update cascade;
alter table Survey add foreign key (sectionEditTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table Survey add foreign key (surveySummaryTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table Survey add foreign key (feedbackTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table Survey add foreign key (testResultsTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table Survey add foreign key (groupToTakeSurvey) references groups(groupId) on delete restrict on update cascade;
alter table Survey add foreign key (groupToEditSurvey) references groups(groupId) on delete restrict on update cascade;
alter table Survey add foreign key (onSurveyEndWorkflowId) references Workflow(workflowId) on delete restrict on update cascade;
alter table Survey_response add foreign key (userId) references users(userId) on delete cascade on update cascade;
alter table Survey_test add foreign key (assetId) references asset(assetId) on delete cascade on update cascade;
alter table Survey_tempReport add foreign key (assetId) references asset(assetId) on delete restrict on update cascade;
alter table Survey_tempReport add foreign key (Survey_responseId) references Survey_response(Survey_responseId) on delete restrict on update cascade;
alter table Thingy add foreign key (assetId,revisionDate) references wobject(assetId,revisionDate) on delete cascade on update cascade;
alter table Thingy add foreign key (templateId) references asset(assetId) on delete restrict on update cascade;
alter table Thingy add foreign key (defaultThingId) references Thingy_things(thingId) on delete set null on update cascade;
alter table Thingy_fields add foreign key (assetId) references asset(assetId) on delete cascade on update cascade;
alter table Thingy_fields add foreign key (thingId) references Thingy_things(thingId) on delete cascade on update cascade;
alter table Thingy_fields add foreign key (createdBy) references users(userId) on delete set null on update cascade;
alter table Thingy_fields add foreign key (updatedBy) references users(userId) on delete set null on update cascade;
alter table Thingy_fields add foreign key (fieldInOtherThingId) references Thingy_things(thingId) on delete set null on update cascade;
alter table Thingy_things add foreign key (assetId) references asset(assetId) on delete cascade on update cascade;
alter table Thingy_things add foreign key (groupIdAdd) references groups(groupId) on delete restrict on update cascade;
alter table Thingy_things add foreign key (groupIdEdit) references groups(groupId) on delete restrict on update cascade;
alter table Thingy_things add foreign key (viewTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table Thingy_things add foreign key (searchTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table Thingy_things add foreign key (editTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table Thingy_things add foreign key (onAddWorkflowId) references Workflow(workflowId) on delete restrict on update cascade;
alter table Thingy_things add foreign key (onEditWorkflowId) references Workflow(workflowId) on delete restrict on update cascade;
alter table Thingy_things add foreign key (onDeleteWorkflowId) references Workflow(workflowId) on delete restrict on update cascade;
alter table Thingy_things add foreign key (groupIdView) references groups(groupId) on delete restrict on update cascade;
alter table Thingy_things add foreign key (groupIdSearch) references groups(groupId) on delete restrict on update cascade;
alter table Thingy_things add foreign key (groupIdImport) references groups(groupId) on delete restrict on update cascade;
alter table Thingy_things add foreign key (groupIdExport) references groups(groupId) on delete restrict on update cascade;
alter table ThingyRecord add foreign key (assetId,revisionDate) references Sku(assetId,revisionDate) on delete cascade on update cascade;
alter table ThingyRecord add foreign key (templateIdView) references asset(assetId) on delete restrict on update cascade;
alter table ThingyRecord add foreign key (thingId) references Thingy_things(thingId) on delete set null on update cascade;
alter table ThingyRecord_record add foreign key (assetId) references asset(assetId) on delete cascade on update cascade;
alter table ThingyRecord_record add foreign key (userId) references users(userId) on delete cascade on update cascade;
alter table ThingyRecord_record add foreign key (transactionId) references transaction(transactionId) on delete cascade on update cascade;
alter table TT_wobject add foreign key (assetId,revisionDate) references wobject(assetId,revisionDate) on delete cascade on update cascade;
alter table TT_wobject add foreign key (userViewTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table TT_wobject add foreign key (managerViewTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table TT_wobject add foreign key (groupToManage) references groups(groupId) on delete restrict on update cascade;
alter table TT_wobject add foreign key (pmAssetId) references asset(assetId) on delete restrict on update cascade;
alter table TT_wobject add foreign key (timeRowTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table TT_report add foreign key (assetId) references asset(assetId) on delete cascade on update cascade;
alter table TT_report add foreign key (createdBy) references users(userId) on delete set null on update cascade;
alter table TT_report add foreign key (lastUpdatedBy) references users(userId) on delete set null on update cascade;
alter table TT_projectList add foreign key (assetId) references asset(assetId) on delete cascade on update cascade;
alter table TT_projectList add foreign key (createdBy) references users(userId) on delete set null on update cascade;
alter table TT_projectList add foreign key (lastUpdatedBy) references users(userId) on delete set null on update cascade;
alter table TT_timeEntry add foreign key (projectId) references TT_projectList(projectId) on delete cascade on update cascade;
alter table TT_timeEntry add foreign key (taskId) references TT_projectTasks(taskId) on delete cascade on update cascade;
alter table TT_timeEntry add foreign key (reportId) references TT_report(reportId) on delete cascade on update cascade;
alter table TT_report add foreign key (resourceId) references TT_projectResourceList(resourceId) on delete cascade on update cascade;
alter table TT_projectResourceList add foreign key (projectId) references TT_projectList(projectId) on delete cascade on update cascade;
alter table TT_projectTasks add foreign key (projectId) references TT_projectList(projectId) on delete cascade on update cascade;
alter table SyndicatedContent add foreign key (assetId,revisionDate) references wobject(assetId,revisionDate) on delete cascade on update cascade;
alter table SyndicatedContent add foreign key (templateId) references asset(assetId) on delete restrict on update cascade;
alter table Navigation add foreign key (assetId,revisionDate) references wobject(assetId,revisionDate) on delete cascade on update cascade;
alter table Navigation add foreign key (templateId) references asset(assetId) on delete restrict on update cascade;
alter table PM_wobject add foreign key (assetId,revisionDate) references wobject(assetId,revisionDate) on delete cascade on update cascade;
alter table PM_wobject add foreign key (projectDashboardTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table PM_wobject add foreign key (projectDisplayTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table PM_wobject add foreign key (ganttChartTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table PM_wobject add foreign key (editTaskTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table PM_wobject add foreign key (groupToAdd) references groups(groupId) on delete restrict on update cascade;
alter table PM_wobject add foreign key (resourcePopupTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table PM_wobject add foreign key (resourceListTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table PM_project add foreign key (assetId) references asset(assetId) on delete cascade on update cascade;
alter table PM_project add foreign key (projectManager) references users(userId) on delete set null on update cascade;
alter table PM_project add foreign key (parentId) references PM_project(projectId) on delete cascade on update cascade;
alter table PM_project add foreign key (createdBy) references users(userId) on delete set null on update cascade;
alter table PM_project add foreign key (lastUpdatedBy) references users(userId) on delete set null on update cascade;
alter table PM_project add foreign key (projectObserver) references users(userId) on delete set null on update cascade;
alter table PM_task add foreign key (projectId) references PM_project(projectId) on delete cascade on update cascade;
alter table PM_task add foreign key (parentId) references PM_task(taskId) on delete cascade on update cascade;
alter table PM_task add foreign key (createdBy) references users(userId) on delete set null on update cascade;
alter table PM_task add foreign key (lastUpdatedBy) references users(userId) on delete set null on update cascade;
alter table PM_taskResource add foreign key (taskId) references PM_task(taskId) on delete cascade on update cascade;
alter table Poll add foreign key (assetId,revisionDate) references wobject(assetId,revisionDate) on delete cascade on update cascade;
alter table UserList add foreign key (assetId,revisionDate) references wobject(assetId,revisionDate) on delete cascade on update cascade;
alter table UserList add foreign key (templateId) references asset(assetId) on delete restrict on update cascade;
alter table UserList add foreign key (showGroupId) references groups(groupId) on delete restrict on update cascade;
alter table UserList add foreign key (hideGroupId) references groups(groupId) on delete restrict on update cascade;
alter table WeatherData add foreign key (assetId,revisionDate) references wobject(assetId,revisionDate) on delete cascade on update cascade;
alter table WeatherData add foreign key (templateId) references asset(assetId) on delete restrict on update cascade;
alter table WikiMaster add foreign key (assetId,revisionDate) references wobject(assetId,revisionDate) on delete cascade on update cascade;
alter table WikiMaster add foreign key (groupToEditPages) references groups(groupId) on delete restrict on update cascade;
alter table WikiMaster add foreign key (groupToAdminister) references groups(groupId) on delete restrict on update cascade;
alter table WikiMaster add foreign key (richEditor) references asset(assetId) on delete restrict on update cascade;
alter table WikiMaster add foreign key (frontPageTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table WikiMaster add foreign key (pageTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table WikiMaster add foreign key (pageEditTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table WikiMaster add foreign key (recentChangesTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table WikiMaster add foreign key (mostPopularTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table WikiMaster add foreign key (pageHistoryTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table WikiMaster add foreign key (searchTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table WikiMaster add foreign key (byKeywordTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table WikiMaster add foreign key (approvalWorkflow) references Workflow(workflowId) on delete restrict on update cascade;
alter table SQLReport add foreign key (assetId,revisionDate) references wobject(assetId,revisionDate) on delete cascade on update cascade;
alter table SQLReport add foreign key (databaseLinkId1) references databaseLink(databaseLinkId) on delete restrict on update cascade;
alter table SQLReport add foreign key (databaseLinkId2) references databaseLink(databaseLinkId) on delete restrict on update cascade;
alter table SQLReport add foreign key (databaseLinkId3) references databaseLink(databaseLinkId) on delete restrict on update cascade;
alter table SQLReport add foreign key (databaseLinkId4) references databaseLink(databaseLinkId) on delete restrict on update cascade;
alter table SQLReport add foreign key (databaseLinkId5) references databaseLink(databaseLinkId) on delete restrict on update cascade;
alter table SQLReport add foreign key (templateId) references asset(assetId) on delete restrict on update cascade;
alter table SQLReport add foreign key (downloadTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table Shelf add foreign key (assetId,revisionDate) references wobject(assetId,revisionDate) on delete cascade on update cascade;
alter table Shelf add foreign key (templateId) references asset(assetId) on delete restrict on update cascade;
alter table StockData add foreign key (assetId,revisionDate) references wobject(assetId,revisionDate) on delete cascade on update cascade;
alter table StockData add foreign key (templateId) references asset(assetId) on delete restrict on update cascade;
alter table StockData add foreign key (displayTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table StoryArchive add foreign key (assetId,revisionDate) references wobject(assetId,revisionDate) on delete cascade on update cascade;
alter table StoryArchive add foreign key (groupToPost) references groups(groupId) on delete restrict on update cascade;
alter table StoryArchive add foreign key (templateId) references asset(assetId) on delete restrict on update cascade;
alter table StoryArchive add foreign key (storyTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table StoryArchive add foreign key (editStoryTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table StoryArchive add foreign key (keywordListTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table StoryArchive add foreign key (richEditorId) references asset(assetId) on delete restrict on update cascade;
alter table StoryArchive add foreign key (approvalWorkflowId) references Workflow(workflowId) on delete restrict on update cascade;
alter table StoryTopic add foreign key (assetId,revisionDate) references wobject(assetId,revisionDate) on delete cascade on update cascade;
alter table StoryTopic add foreign key (templateId) references asset(assetId) on delete restrict on update cascade;
alter table StoryTopic add foreign key (storyTemplateId) references asset(assetId) on delete restrict on update cascade;

alter table assetAspectComments add foreign key (assetId,revisionDate) references assetData(assetId,revisionDate) on delete cascade on update cascade;
alter table assetAspectRssFeed add foreign key (assetId,revisionDate) references assetData(assetId,revisionDate) on delete cascade on update cascade;
alter table assetAspect_Subscribable add foreign key (assetId,revisionDate) references assetData(assetId,revisionDate) on delete cascade on update cascade;
alter table assetAspect_Subscribable add foreign key (subscriptionTemplateId) references asset(assetId) on delete restrict on update cascade;
alter table assetAspect_Subscribable add foreign key (subscriptionGroupId) references groups(groupId) on delete restrict on update cascade;

alter table authentication add foreign key (userId) references users(userId) on delete cascade on update cascade;
alter table userProfileData add foreign key (userId) references users(userId) on delete cascade on update cascade;
alter table userSession add foreign key (userId) references users(userId) on delete cascade on update cascade;
alter table passiveLog add foreign key (userId) references users(userId) on delete cascade on update cascade;
alter table userLoginLog add foreign key (userId) references users(userId) on delete cascade on update cascade;

alter table userSessionScratch add foreign key (sessionId) references userSession(sessionId) on delete cascade on update cascade;
alter table cart add foreign key (sessionId) references userSession(sessionId) on delete cascade on update cascade;
alter table cart add foreign key (shippingAddressId) references address(addressId) on delete set null on update cascade;
alter table cart add foreign key (shipperId) references shipper(shipperId) on delete set null on update cascade;
alter table cart add foreign key (posUserId) references users(userId) on delete set null on update cascade;
alter table cartItem add foreign key (cartId) references cart(cartId) on delete cascade on update cascade;
alter table cartItem add foreign key (assetId) references asset(assetId) on delete cascade on update cascade;
alter table cartItem add foreign key (shippingAddressId) references address(addressId) on delete set null on update cascade;
alter table WorkflowActivityData add foreign key (activityId) references WorkflowActivity(activityId) on delete cascade on update cascade;
alter table WorkflowActivity add foreign key (workflowId) references Workflow(workflowId) on delete cascade on update cascade;
alter table WorkflowInstance add foreign key (workflowId) references Workflow(workflowId) on delete cascade on update cascade;
alter table WorkflowInstance add foreign key (currentActivityId) references WorkflowActivity(activityId) on delete set null on update cascade;
alter table WorkflowInstanceScratch add foreign key (instanceId) references WorkflowInstance(instanceId) on delete cascade on update cascade;
alter table WorkflowSchedule add foreign key (workflowId) references Workflow(workflowId) on delete cascade on update cascade;
alter table adSkuPurchase add foreign key (transactionItemId) references transactionItem(itemId) on delete cascade on update cascade;
alter table adSkuPurchase add foreign key (userId) references users(userId) on delete cascade on update cascade;
alter table adSkuPurchase add foreign key (adId) references users(userId) on delete set null on update cascade;
alter table address add foreign key (addressBookId) references addressBook(addressBookId) on delete cascade on update cascade;
alter table addressBook add foreign key (sessionId) references userSession(sessionId) on delete set null on update cascade;
alter table addressBook add foreign key (userId) references users(userId) on delete cascade on update cascade;
alter table addressBook add foreign key (defaultAddressId) references address(addressId) on delete set null on update cascade;
alter table advertisement add foreign key (adSpaceId) references adSpace(adSpaceId) on delete cascade on update cascade;
alter table advertisement add foreign key (ownerUserId) references users(userId) on delete cascade on update cascade;
alter table bucketLog add foreign key (userId) references users(userId) on delete set null on update cascade;
alter table deltaLog add foreign key (assetId) references asset(assetId) on delete cascade on update cascade;
alter table friendInvitations add foreign key (inviterId) references users(userId) on delete cascade on update cascade;
alter table friendInvitations add foreign key (friendId) references users(userId) on delete cascade on update cascade;
alter table friendInvitations add foreign key (messageId) references inbox(messageId) on delete cascade on update cascade;
alter table groupGroupings add foreign key (inGroup) references groups(groupId) on delete cascade on update cascade;
update groups set databaseLinkId=null where databaseLinkId='';
alter table groups add foreign key (databaseLinkId) references databaseLink(databaseLinkId) on delete set null on update cascade;
alter table groups add foreign key (ldapLinkId) references ldapLink(ldapLinkId) on delete set null on update cascade;
alter table groupings add foreign key (userId) references users(userId) on delete cascade on update cascade;
alter table imagePaletteColors add foreign key (colorId) references imageColor(colorId) on delete cascade on update cascade;
alter table inbox add foreign key (completedBy) references users(userId) on delete set null on update cascade;
alter table inbox add foreign key (userId) references users(userId) on delete set null on update cascade;
alter table inbox add foreign key (groupId) references groups(groupId) on delete set null on update cascade;
alter table inbox add foreign key (sentBy) references users(userId) on delete set null on update cascade;
alter table inbox_messageState add foreign key (messageId) references inbox(messageId) on delete cascade on update cascade;
alter table inbox_messageState add foreign key (userId) references users(userId) on delete cascade on update cascade;
alter table karmaLog add foreign key (userId) references users(userId) on delete cascade on update cascade;
alter table ldapLink add foreign key (ldapLoginTemplate) references asset(assetId) on delete restrict on update cascade;
alter table ldapLink add foreign key (ldapCreateAccountTemplate) references asset(assetId) on delete restrict on update cascade;
alter table ldapLink add foreign key (ldapAccountTemplate) references asset(assetId) on delete restrict on update cascade;
alter table mailQueue add foreign key (toGroup) references groups(groupId) on delete cascade on update cascade;
alter table metaData_values add foreign key (assetId) references asset(assetId) on delete cascade on update cascade;
alter table passiveAnalyticsStatus add foreign key (userId) references users(userId) on delete cascade on update cascade;
alter table passiveProfileAOI add foreign key (userId) references users(userId) on delete cascade on update cascade;
alter table shopCredit add foreign key (userId) references users(userId) on delete cascade on update cascade;
alter table tax_eu_vatNumbers add foreign key (userId) references users(userId) on delete cascade on update cascade;
alter table template_attachments add foreign key (templateId) references asset(assetId) on delete cascade on update cascade;
alter table transaction add foreign key (originatingTransactionId) references transaction(transactionId) on delete set null on update cascade;
alter table transaction add foreign key (userId) references users(userId) on delete set null on update cascade;
alter table transaction add foreign key (shippingAddressId) references address(addressId) on delete set null on update cascade;
alter table transaction add foreign key (shippingDriverId) references shipper(shipperId) on delete set null on update cascade;
alter table transaction add foreign key (paymentAddressId) references address(addressId) on delete set null on update cascade;
alter table transaction add foreign key (paymentDriverId) references paymentGateway(paymentGatewayId) on delete set null on update cascade;
alter table transaction add foreign key (cashierUserId) references users(userId) on delete set null on update cascade;
alter table transactionItem add foreign key (transactionId) references transaction(transactionId) on delete cascade on update cascade;
alter table transactionItem add foreign key (shippingAddressId) references address(addressId) on delete set null on update cascade;
alter table transactionItem add foreign key (vendorId) references vendor(vendorId) on delete set null on update cascade;
alter table userInvitations add foreign key (userId) references users(userId) on delete cascade on update cascade;
alter table userInvitations add foreign key (newUserId) references users(userId) on delete cascade on update cascade;
alter table userProfileData add foreign key (userId) references users(userId) on delete cascade on update cascade;
alter table userProfileField add foreign key (profileCategoryId) references userProfileCategory(profileCategoryId) on delete restrict on update cascade;
update users set friendsGroup=null where friendsGroup='';
alter table users add foreign key (friendsGroup) references groups(groupId) on delete set null on update cascade;
alter table vendor add foreign key (userId) references users(userId) on delete cascade on update cascade;
alter table vendor add foreign key (paymentAddressId) references paymentGateway(paymentGatewayId) on delete cascade on update cascade;




