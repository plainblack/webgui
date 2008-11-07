-- SQL statement take are needed for version tag mode support. Must be added to current upgrade script when merging to mainline branch

-- Add setting. Upgrade script must take the current value of autoRequestCommit and update version tag mode.

INSERT INTO `settings` ( `name` , `value` )
VALUES (
'versionTagMode', ''
);


-- Remove autoRequestCommit

DELETE FROM `settings` WHERE `name` = 'autoRequestCommit';

-- Add isSiteWide column

ALTER TABLE `assetVersionTag` ADD `isSiteWide` BOOL NOT NULL DEFAULT '0';

-- Add profile field for user

INSERT INTO `userProfileField` (`fieldName`, `label`, `visible`, `required`, `fieldType`, `possibleValues`, `dataDefault`, `sequenceNumber`, `profileCategoryId`, `protected`, `editable`, `forceImageOnly`, `showAtRegistration`, `requiredForPasswordRecovery`) VALUES ('versionTagMode', 'WebGUI::International::get("version tag mode","WebGUI");', 1, 1, 'selectBox', '{\r\n    inherited     => WebGUI::International::get("versionTagMode inherited"),\r\n    multiPerUser  => WebGUI::International::get("versionTagMode multiPerUser"),\r\n    singlePerUser => WebGUI::International::get("versionTagMode singlePerUser"),\r\n    siteWide      => WebGUI::International::get("versionTagMode siteWide"),\r\n    autoCommit    => WebGUI::International::get("versionTagMode autoCommit"),\r\n}', 'inherited', 12, 0x34, 0, 1, 1, 0, 0);
