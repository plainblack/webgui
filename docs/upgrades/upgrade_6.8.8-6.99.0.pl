#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use lib "../../lib";
use strict;
use Getopt::Long;
use WebGUI::Session;
use WebGUI::VersionTag;
use File::Path;
use WebGUI::Workflow;
use WebGUI::Workflow::Cron;
use WebGUI::Group;
use WebGUI::Storage;

my $toVersion = "6.99.0"; # make this match what version you're going to
my $quiet; # this line required


my $session = start(); # this line required

changeDbCacheTimeoutName();
addWorkflow();
convertMessageLogToInbox();
updateCs();
changeCache();
templateParsers();
removeFiles();
addSearchEngine();
addEMS();
updateTemplates();
updateDatabaseLinksAndSQLReport();
ipsToCIDR();
addDisabletoRichEditor();
addNavigationMimeType();
addIndexes();
addDatabaseCache();
updateHelpTemplate();
fixImportNodePrivileges();
addAdManager();
updateMatrix();
updateFolder();
addRichEditUpload();
updateArticle();

finish($session); # this line required

#-------------------------------------------------
sub updateArticle {
	print "\tAllowing articles to have direct attachments.\n";
	$session->db->write("alter table Article add column storageId varchar(22) binary");
	my $rs = $session->db->read("select assetId from asset where className='WebGUI::Asset::Wobject::Article'");
	while (my ($id) = $rs->array) {
		my $asset = WebGUI::Asset->new($id, "WebGUI::Asset::Wobject::Article");
		if (defined $asset) {
			my $children = $asset->getLineage(["children"],{returnObjects=>1, includeOnlyClasses=>["WebGUI::Asset::File","WebGUI::Asset::File::Image"]});
			if (scalar(@{$children})) {
				my $storage = undef;
				if ($asset->get("storageId")) {
					$storage = WebGUI::Storage->get($session,$asset->get("storageId"));
				} else {
					$storage = WebGUI::Storage->create($session);
					$asset->update({storageId=>$storage->getId});
				}
				foreach my $child (@{$children}) {
					$child->getStorageLocation->copy($storage);
					$child->purge;
				}
			}
		}
	}
}

#-------------------------------------------------
sub addRichEditUpload {
	print "\tAdding the ability to upload from the rich editor.\n";
	my $root = WebGUI::Asset->getRoot($session);
	my $media = $root->addChild({
		url=>"media",
		title=>"Media",
		menuTitle=>"Media",
		className=>"WebGUI::Asset::Wobject::Folder",
		styleTemplateId=>"PBtmpl0000000000000060",
		printableStyleTemplateId=>'PBtmpl0000000000000111',
		templateId=>'PBtmpl0000000000000078',
		ownerUserId=>'3',
		groupIdEdit=>'12',
		groupIdView=>'7',
		},"PBasset000000000000003");
	$session->db->write("update asset set isSystem=1 where assetId=?",[$media->getId]);
	# somehow the import node isn't protected, doing that now
	$session->db->write("update asset set isSystem=1 where assetId=?",['PBasset000000000000002']);
	# the failsafe style should be visible
	$session->db->write("update template set showInForms=1 where assetId=?",['PBtmpl0000000000000060']);
}

#-------------------------------------------------
sub updateFolder {
	print "\tAdding sort option to folder.\n";
	$session->db->write("alter table Folder add column sortAlphabetically int not null default 0");
}

#-------------------------------------------------
sub updateMatrix {
	print "\tAdding new features to the matrix.\n";
	$session->db->write("alter table Matrix_listing add column storageId varchar(22) binary");
	$session->db->write("alter table Matrix_listing add column filename varchar(255)");
}

#-------------------------------------------------
sub changeCache {
	print "\tChanging page cache system.\n";
	$session->db->write("alter table MessageBoard add column visitorCacheTimeout int not null default 3600");
	$session->db->write("alter table Matrix add column visitorCacheTimeout int not null default 3600");
	$session->db->write("alter table Collaboration add column visitorCacheTimeout int not null default 3600");
	$session->db->write("alter table EventsCalendar add column visitorCacheTimeout int not null default 3600");
	$session->db->write("alter table Folder add column visitorCacheTimeout int not null default 3600");
	$session->db->write("alter table HttpProxy add column cacheTimeout int not null default 0");
	$session->db->write("alter table SQLReport add column cacheTimeout int not null default 0");
	$session->db->write("alter table snippet add column cacheTimeout int not null default 3600");
	$session->db->write("alter table FileAsset add column cacheTimeout int not null default 3600");
	$session->db->write("alter table Product add column cacheTimeout int not null default 3600");
	$session->db->write("alter table SyndicatedContent add column cacheTimeout int not null default 3600");
	$session->db->write("alter table MultiSearch add column cacheTimeout int not null default 3600");
	$session->db->write("alter table Article add column cacheTimeout int not null default 3600");
	$session->db->write("alter table wobject drop column cacheTimeout");
	$session->db->write("alter table wobject drop column cacheTimeoutVisitor");
}

#-------------------------------------------------
sub addAdManager {
	print "\tAdding advertising management.\n";
	$session->db->write("create table adSpace (
		adSpaceId varchar(22) binary not null primary key,
		name varchar(35) not null unique key,
		title varchar(255) not null,
		description text,
		costPerImpression decimal(11,2) not null default 0,
		minimumImpressions int not null default 1000,
		costPerClick decimal(11,2) not null default 0,
		minimumClicks int not null default 1000,
		width int not null default 468,
		height int not null default 60,
		groupToPurchase varchar(22) binary not null default '3'
		)");
	$session->db->write("create table advertisement (
		adId varchar(22) binary not null primary key,
		adSpaceId varchar(22) binary not null,
		ownerUserId varchar(22) binary not null,
		isActive int not null default 0,
		title varchar(255) not null,
		type varchar(15) not null default 'text',
		storageId varchar(22) binary,
		adText varchar(255),
		url text,
		richMedia text,
		borderColor varchar(7) not null default '#000000',
		textColor varchar(7) not null default '#000000',
		backgroundColor varchar(7) not null default '#ffffff',
		clicks int not null default 0,
		clicksBought int not null default 0,
		impressions int not null default 0,
		impressionsBought int not null default 0,
		priority int not null default 0,
		nextInPriority bigint not null default 0,
		renderedAd text
		)");
	$session->db->write("alter table advertisement add index adSpaceId_isActive (adSpaceId, isActive)");
	my $macros = $session->config->addToHash("macros","AdSpace","AdSpace");
	my $group = WebGUI::Group->new($session, "new", "pbgroup000000000000017");
	$group->name("Ad Manager");
	$group->description("These users will be able to manage advertisements.");
}

#-------------------------------------------------
sub fixImportNodePrivileges {
	print "\tFixing the privileges of all the content in the import node.\n";
	my $importNode = WebGUI::Asset->getImportNode($session);
	$importNode->update({groupIdView=>'7', groupIdEdit=>'12'});
	my $prepared = $session->db->prepare("update assetData set groupIdView='7', groupIdEdit='12' where assetId=?");
	my $rs = $session->db->read("select assetId from asset where lineage like ?",[$importNode->get("lineage").'%']);
	while (my ($id) = $rs->array) {
		$prepared->execute([$id]);	
	}
	my $root = WebGUI::Asset->getRoot($session);
	$root->update({groupIdView=>'7'});
}

#-------------------------------------------------
sub convertMessageLogToInbox {
	print "\tConverting message log to inbox.\n";
	$session->db->write("create table inbox (
		messageId varchar(22) binary not null primary key,
		status varchar(15) not null default 'pending',
		dateStamp bigint not null,
		completedOn bigint,
		completedBy varchar(22) binary,
		userId varchar(22) binary,
		groupId varchar(22) binary,
		subject varchar(255) not null default 'No Subject',
		message mediumtext
		)");	
	$session->db->write("alter table Matrix_listing add column approvalMessageId varchar(22) binary");
	my $prepared = $session->db->prepare("insert into inbox (messageId, status, dateStamp, completedOn, completedBy, userId, subject, message) 
		values ( ?,?,?,?,?,?,?,? )");
	my $rs = $session->db->read("select * from messageLog");
	while (my $data = $rs->hashRef) {
		$prepared->execute([
			$session->id->generate,
			'completed',
			$data->{dateOfEntry},
			time(),
			'3',
			$data->{userId},
			$data->{subject},
			$data->{message}
			]);	
	}
	$session->db->write("delete from userProfileField where fieldname='INBOXNotifications'");
	$session->db->write("delete from userProfileData where fieldname='INBOXNotifications'");
	$session->db->write("drop table if exists messageLog");
	$rs = $session->db->read("select distinct assetId from template where namespace='Operation/MessageLog/View' or namespace='Operation/MessageLog/Message'");
	while (my ($id) = $rs->array) {
		my $asset = WebGUI::Asset->new($session, $id, "WebGUI::Asset::Template");
		if (defined $asset) {
			$asset->purge;
		}
	}
}

#-------------------------------------------------
sub updateCs {
	print "\tUpdating the Collaboration System.\n";
	print "\t\tAdding collaboration system popularity system based upon karma.\n";
	$session->db->write("alter table Collaboration add column defaultKarmaScale integer not null default 1");
	$session->db->write("alter table Thread add column karma integer not null default 0");
	$session->db->write("alter table Thread add column karmaScale integer not null default 1");
	$session->db->write("alter table Thread add column karmaRank decimal(6,6) not null default 0");
	print "\t\tIncreasing CS performance.\n";
	$session->db->write("alter table Post_rating add index assetId_userId (assetId,userId);");
	$session->db->write("alter table Post_rating add index assetId_ipAddress (assetId,ipAddress);");
	$session->db->write("delete from Post_read where postId<>threadId");
	$session->db->write("alter table Post_read drop column postId");
	$session->db->write("alter table Post_read drop column readDate");
	$session->db->write("alter table Post_read rename Thread_read");
	print "\t\tAdding email to discussion support.\n";
	$session->db->write("alter table Collaboration add column mailServer varchar(255)");
	$session->db->write("alter table Collaboration add column mailAccount varchar(255)");
	$session->db->write("alter table Collaboration add column mailPassword varchar(255)");
	$session->db->write("alter table Collaboration add column mailAddress varchar(255)");
	$session->db->write("alter table Collaboration add column mailPrefix varchar(255)");
	$session->db->write("alter table Collaboration add column getMail int not null default 0");
	$session->db->write("alter table Collaboration add column getMailInterval int not null default 300");
	$session->db->write("alter table Collaboration add column getMailCronId varchar(22) binary");
	my $workflow = WebGUI::Workflow->create($session, {
			isSerial=>1,
			type=>"WebGUI::Asset::Wobject::Collaboration",	
			enabled=>1,
			description=>"Retrieves mail from a POP3 account for the given Collaboration System.",
			title=>"Get CS Mail"	
			}, "csworkflow000000000001");
	my $activity = $workflow->addActivity("WebGUI::Workflow::Activity::GetCsMail","csactivity000000000001");
	$activity->set("title","Get the mail");	
	print "\t\tDeleting old ratings due to new rating system.\n";
	$session->db->write("delete from Post_rating");
	$session->db->write("update Post set rating=0");
}

#-------------------------------------------------
sub addDatabaseCache {
	print "\tAdding database cache.\n";
	$session->db->write("create table cache ( namespace varchar(128) not null, cachekey varchar(128) not null, expires bigint not null, size int not null, content mediumtext, primary key (namespace, cachekey))");
	$session->db->write("alter table cache add index namespace_cachekey_size (namespace,cachekey,expires)");
	if ($session->config->get("memcached_servers")) {
		$session->config->set("cacheType","WebGUI::Cache::Memcached");
	} else {
		$session->config->set("cacheType","WebGUI::Cache::FileCache");
	}
}

#-------------------------------------------------
sub addIndexes {
	print "\tAdding indexes to increase performance.\n";
	$session->db->write("alter table assetData add index url (url)");
}

#-------------------------------------------------
sub addWorkflow {
	print "\tAdding workflow.\n";
	print "\t\tMaking database changes.\n";
	$session->db->write("alter table assetData drop column startDate");
	$session->db->write("alter table assetData drop column endDate");
	$session->db->write("alter table assetVersionTag add column isLocked int not null default 0");
	$session->db->write("alter table assetVersionTag add column lockedBy varchar(22) binary not null");
	$session->db->write("alter table assetVersionTag add column groupToUse varchar(22) binary not null");
	$session->db->write("alter table assetVersionTag add column workflowId varchar(22) binary not null");
	$session->db->write("alter table assetVersionTag add column workflowInstanceId varchar(22) binary");
	$session->db->write("alter table assetVersionTag add column comments text");
	$session->db->write("create table WorkflowSchedule (
		taskId varchar(22) binary not null primary key,
		title varchar(255) not null default 'Untitled',
		enabled int not null default 0,
		runOnce int not null default 0,
		minuteOfHour varchar(25) not null default '0',
		hourOfDay varchar(25) not null default '*',
		dayOfMonth varchar(25) not null default '*',
		monthOfYear varchar(25) not null default '*',
		dayOfWeek varchar(25) not null default '*',
		workflowId varchar(22) binary not null,
		className varchar(255),
		methodName varchar(255),
		priority int not null default 2,
		parameters text
		)");
	$session->db->write("create table WorkflowInstance (
		instanceId varchar(22) binary not null primary key,
		workflowId varchar(22) binary not null,
		currentActivityId varchar(22) binary not null,
		priority int not null default 2,
		className varchar(255),
		methodName varchar(255),
		parameters text,
		runningSince bigint,
		lastUpdate bigint
		)");
	$session->db->write("create table WorkflowInstanceScratch (
		instanceId varchar(22) binary not null,
		name varchar(255) not null,
		value text,
		primary key (instanceId, name)
		)");
	$session->db->write("create table Workflow (
		workflowId varchar(22) binary not null primary key,
		title varchar(255) not null default 'Untitled',
		description text,
		enabled int not null default 0,
		isSerial int not null default 0,
		type varchar(255) not null default 'None'
		)");
	$session->db->write("create table WorkflowActivity (
		activityId varchar(22) binary not null primary key,
		workflowId varchar(22) binary not null,
		title varchar(255) not null default 'Untitled',
		description text,
		sequenceNumber int not null default 1,
		className varchar(255)
		)");
	$session->db->write("create table WorkflowActivityData (
		activityId varchar(22) binary not null,
		name varchar(255) not null,
		value text,
		primary key (activityId, name)
		)");
	$session->db->write("create table mailQueue (
		messageId varchar(22) binary not null primary key,
		message mediumtext,
		toGroup varchar(22) binary
		)");
	$session->db->write("alter table Collaboration drop column moderatePosts");
	$session->db->write("alter table Collaboration drop column moderateGroupId");
	$session->db->write("alter table Collaboration add column approvalWorkflow varchar(22) binary not null default 'pbworkflow000000000003'");
	print "\t\tPurging old workflow info.\n";
	my $versionTag = WebGUI::VersionTag->getWorking($session);
	$versionTag->set({name=>"Upgrade to ".$toVersion});
	my $rs = $session->db->read("select assetId from assetData where status='denied'");
	while (my ($id) = $rs->array) {
		my $asset = WebGUI::Asset->newByDynamicClass($session, $id);
		if ($asset->get("status") eq "denied") {
			$asset->purge;
		}
	}
	$session->db->write("update assetData set status='approved' where status='denied'");
	print "\t\tUpdating groups.\n";
	$session->db->write("update groups set showInForms=1 where groupId='12'");
	my $group = WebGUI::Group->new($session,"new","pbgroup000000000000015");
	$group->set("groupName", "Workflow Managers");
	$group->set("description", "People who can create, edit, and delete workflows.");
	$group = WebGUI::Group->new($session,"new","pbgroup000000000000016");
	$group->set("groupName", "Version Tag Managers");
	$group->set("description", "People who can create, edit, and delete special version tags.");
	print "\t\tUpdating the config file.\n";
	$session->config->set("spectreIp","127.0.0.1");
	$session->config->set("spectrePort",32133);
	$session->config->set("spectreSubnets",["127.0.0.1/32"]);
	$session->config->set("workflowActivities", {
		None=>["WebGUI::Workflow::Activity::DecayKarma", "WebGUI::Workflow::Activity::TrashClipboard", "WebGUI::Workflow::Activity::CleanTempStorage", 
			"WebGUI::Workflow::Activity::CleanFileCache", "WebGUI::Workflow::Activity::CleanLoginHistory", "WebGUI::Workflow::Activity::ArchiveOldThreads",
			"WebGUI::Workflow::Activity::TrashExpiredEvents", "WebGUI::Workflow::Activity::CreateCronJob", "WebGUI::Workflow::Activity::DeleteExpiredSessions",
			"WebGUI::Workflow::Activity::ExpireGroupings", "WebGUI::Workflow::Activity::PurgeOldAssetRevisions",
			"WebGUI::Workflow::Activity::ExpireSubscriptionCodes", "WebGUI::Workflow::Activity::PurgeOldTrash", 
			"WebGUI::Workflow::Activity::GetSyndicatedContent", "WebGUI::Workflow::Activity::ProcessRecurringPayments",
			"WebGUI::Workflow::Activity::SendQueuedMailMessages",
			"WebGUI::Workflow::Activity::SyncProfilesToLdap", "WebGUI::Workflow::Activity::SummarizePassiveProfileLog"],
		"WebGUI::User"=>["WebGUI::Workflow::Activity::CreateCronJob", "WebGUI::Workflow::Activity::NotifyAboutUser"],
		"WebGUI::VersionTag"=>["WebGUI::Workflow::Activity::CommitVersionTag", "WebGUI::Workflow::Activity::RollbackVersionTag", 
			"WebGUI::Workflow::Activity::TrashVersionTag", "WebGUI::Workflow::Activity::CreateCronJob", "WebGUI::Workflow::Activity::UnlockVersionTag",
			"WebGUI::Workflow::Activity::RequestApprovalForVersionTag", "WebGUI::Workflow::Activity::NotifyAboutVersionTag",
			"WebGUI::Workflow::Activity::ExportVersionTagAsHtml"]
		});
	$session->config->delete("SyncProfilesToLDAP_hour");
	$session->config->delete("fileCacheSizeLimit");
	$session->config->delete("passiveProfileInterval");
	$session->config->delete("CleanLoginHistory_ageToDelete");
	$session->config->delete("DecayKarma_minimumKarma");
	$session->config->delete("DecayKarma_decayFactor");
	$session->config->delete("DeleteExpiredClipboard_offset");
	$session->config->delete("DeleteExpiredEvents_offset");
	$session->config->delete("TrashExpiredContent_offset");
	$session->config->delete("DeleteExpiredTrash_offset");
	$session->config->delete("DeleteExpiredRevisions_offset");
	print "\t\tAdding default workflows and cron jobs.\n";
	my $workflow = WebGUI::Workflow->create($session, {
		title=>"Daily Maintenance Tasks",
		description=>"This workflow runs daily maintenance tasks such as cleaning up old temporary files and cache.",
		enabled=>1,
		type=>"None"
		}, "pbworkflow000000000001");
	my $activity = $workflow->addActivity("WebGUI::Workflow::Activity::CleanTempStorage", "pbwfactivity0000000001");
	$activity->set("title","Delete temp files older than 24 hours");
	$activity->set("storageTimeout",60*60*24);
	$activity = $workflow->addActivity("WebGUI::Workflow::Activity::ProcessRecurringPayments", "pbwfactivity0000000013");
	$activity->set("title", "Process Recurring Payments");
	$activity = $workflow->addActivity("WebGUI::Workflow::Activity::CleanFileCache", "pbwfactivity0000000002");
	$activity->set("title","Prune cache larger than 100MB");
	$activity->set("sizeLimit", 1000000000);
	$activity = $workflow->addActivity("WebGUI::Workflow::Activity::ArchiveOldThreads", "pbwfactivity0000000005");
	$activity->set("title", "Archive old CS threads");
	$activity = $workflow->addActivity("WebGUI::Workflow::Activity::TrashExpiredEvents", "pbwfactivity0000000006");
	$activity->set("title", "Trash old Events Calendar Events");
	$activity->set("trashAfter", 60*60*24*30);
	$activity = $workflow->addActivity("WebGUI::Workflow::Activity::ExpireGroupings", "pbwfactivity0000000007");
	$activity->set("title", "deal with user groupings that have expired");
	$activity = $workflow->addActivity("WebGUI::Workflow::Activity::ExpireSubscriptionCodes", "pbwfactivity0000000011");
	$activity->set("title", "Expire old subscription codes");
	$activity = $workflow->addActivity("WebGUI::Workflow::Activity::SummarizePassiveProfileLog", "pbwfactivity0000000014");
	$activity->set("title", "Summarize Passive Profiling Data");
	$activity = $workflow->addActivity("WebGUI::Workflow::Activity::SyncProfilesToLdap", "pbwfactivity0000000015");
	$activity->set("title", "Sync User Profiles With LDAP");
	WebGUI::Workflow::Cron->create($session, {
		title=>'Daily Maintenance',
		enabled=>1,
		runOnce=>0,
		minuteOfHour=>"30",
		hourOfDay=>"23",
		priority=>3,
		workflowId=>$workflow->getId
		}, "pbcron0000000000000001");
	$workflow = WebGUI::Workflow->create($session, {
		title=>"Weekly Maintenance Tasks",
		description=>"This workflow runs once per week to perform maintenance tasks like cleaning up log files.",
		enabled=>1,
		type=>"None"
		}, "pbworkflow000000000002");
	$activity = $workflow->addActivity("WebGUI::Workflow::Activity::CleanLoginHistory", "pbwfactivity0000000003");
	$activity->set("title", "Delete login entries older than 90 days");
	$activity->set("ageToDelete", 60*60*24*90);
	$activity = $workflow->addActivity("WebGUI::Workflow::Activity::TrashClipboard", "pbwfactivity0000000004");
	$activity->set("title", "Move clipboard items older than 30 days to trash");
	$activity->set("trashAfter", 60*60*24*30);
	$activity = $workflow->addActivity("WebGUI::Workflow::Activity::PurgeOldAssetRevisions", "pbwfactivity0000000008");
	$activity->set("title", "delete asset revisions older than a year from the database");
	$activity->set("purgeAfter", 60*60*24*365);
	$activity = $workflow->addActivity("WebGUI::Workflow::Activity::PurgeOldTrash", "pbwfactivity0000000010");
	$activity->set("title", "delete assets from trash that have been sitting around for 30 days");
	$activity->set("purgeAfter", 60*60*24*30);
	WebGUI::Workflow::Cron->create($session, {
                title=>'Weekly Maintenance',
                enabled=>1,
                runOnce=>0,
                minuteOfHour=>"30",
                hourOfDay=>"1",
		dayOfWeek=>"0",
                priority=>3,
                workflowId=>$workflow->getId
                }, "pbcron0000000000000002");
	$workflow = WebGUI::Workflow->create($session, {
		title=>"Hourly Maintenance Tasks",
		description=>"This workflow runs once per hour to perform maintenance tasks like deleting expired user sessions.",
		enabled=>1,
		type=>"None"
		}, "pbworkflow000000000004");
	$activity = $workflow->addActivity("WebGUI::Workflow::Activity::DeleteExpiredSessions", "pbwfactivity0000000009");
	$activity->set("title", "delete expired sessions");
	$activity = $workflow->addActivity("WebGUI::Workflow::Activity::GetSyndicatedContent", "pbwfactivity0000000012");
	$activity->set("title", "Get syndicated content");
	WebGUI::Workflow::Cron->create($session, {
                title=>'Hourly Maintenance',
                enabled=>1,
                runOnce=>0,
                minuteOfHour=>"15",
                priority=>3,
                workflowId=>$workflow->getId
                }, "pbcron0000000000000003");
	$workflow = WebGUI::Workflow->create($session, {
		title=>"Commit Without Approval",
		description=>"This workflow commits all the assets in this version tag without asking for any approval.",
		enabled=>1,
		type=>"WebGUI::VersionTag"
		}, "pbworkflow000000000003");
	$activity = $workflow->addActivity("WebGUI::Workflow::Activity::CommitVersionTag", "pbwfactivity0000000006");
	$activity->set("title", "Commit Assets");
	$workflow = WebGUI::Workflow->create($session, {
		title=>"Commit With Approval",
		description=>"This workflow commits all the assets in this version tag after getting approval from content managers.",
		enabled=>1,
		type=>"WebGUI::VersionTag"
		}, "pbworkflow000000000005");
	$activity = $workflow->addActivity("WebGUI::Workflow::Activity::RequestApprovalForVersionTag", "pbwfactivity0000000017");
	$activity->set("title", "Get Approval from Content Managers");
	$activity->set("groupToApprove", "4");
	$activity->set("message", "A new version tag awaits your approval.");
	$activity->set("doOnDeny", "pbworkflow000000000006");
	$activity = $workflow->addActivity("WebGUI::Workflow::Activity::CommitVersionTag", "pbwfactivity0000000016");
	$activity->set("title", "Commit Assets");
	$activity = $workflow->addActivity("WebGUI::Workflow::Activity::NotifyAboutVersionTag", "pbwfactivity0000000018");
	$activity->set("title", "Notify Committer of Approval");
	$activity->set("message", "Your version tag was approved.");
	$activity->set("who", "committer");
	$workflow = WebGUI::Workflow->create($session, {
		title=>"Unlock Version Tag and Notify Owner",
		description=>"This workflow is used when a version tag approval is denied. It unlocks the version tag, making it available for editing, and notifies the tag owner.",
		enabled=>1,
		type=>"WebGUI::VersionTag"
		}, "pbworkflow000000000006");
	$activity = $workflow->addActivity("WebGUI::Workflow::Activity::UnlockVersionTag", "pbwfactivity0000000019");
	$activity->set("title", "Unlock Version Tag");
	$activity = $workflow->addActivity("WebGUI::Workflow::Activity::NotifyAboutVersionTag", "pbwfactivity0000000020");
	$activity->set("title", "Notify Committer of Denial");
	$activity->set("message", "Your version tag was denied. Please take corrective actions and recommit your changes.");
	$activity->set("who", "committer");
	$workflow = WebGUI::Workflow->create($session, {
		title=>"Send Queued Email Messages",
		description => "Sends all the messages in the mail queue.",
		enabled=>1,
		isSerial=>1,
		type=>"None"
		}, "pbworkflow000000000007");
	$activity = $workflow->addActivity("WebGUI::Workflow::Activity::SendQueuedMailMessages", "pbwfactivity0000000021");
	$activity->set("title", "Send Queued Messages");
	WebGUI::Workflow::Cron->create($session, {
                title=>'Send Queued Email Messages Every 5 Minutes',
                enabled=>1,
                runOnce=>0,
                minuteOfHour=>"*/5",
                priority=>3,
                workflowId=>$workflow->getId
                }, "pbcron0000000000000004");
	print "\t\tUpdating settings.\n";
	$session->setting->remove("autoCommit");
	$session->setting->remove("alertOnNewUser");
	$session->setting->remove("onNewUserAlertGroup");
	$session->setting->set("runOnRegistration","");
	$session->setting->add("defaultVersionTagWorkflow","pbworkflow000000000003");
	$session->setting->add("mailReturnPath",undef);
}

#-------------------------------------------------
sub updateDatabaseLinksAndSQLReport {
	print "\tUpdating the Database link and SQLReport Tables.\n";
	$session->db->write('alter table databaseLink add column allowedKeywords text');
	$session->db->write('update databaseLink set allowedKeywords="select\ndecsribe\nshow"');
	$session->db->write('alter table SQLReport add column prequeryStatements1 text');
	$session->db->write('alter table SQLReport add column prequeryStatements2 text');
	$session->db->write('alter table SQLReport add column prequeryStatements3 text');
	$session->db->write('alter table SQLReport add column prequeryStatements4 text');
	$session->db->write('alter table SQLReport add column prequeryStatements5 text');
}

#-------------------------------------------------
sub updateTemplates {
        print "\tUpdating base templates for XHTML compliance, and a cleaner look.\n" unless ($quiet);
	$session->db->write("alter table template add column headBlock text");
	my $template = WebGUI::Asset->new($session, "PBtmpl0000000000000003", "WebGUI::Asset::Template");
	if (defined $template) {
		$template->purge;
	}
	opendir(DIR,"templates-6.99.0");
	my @files = readdir(DIR);
	closedir(DIR);
	my $importNode = WebGUI::Asset->getImportNode($session);
	my $folder = $importNode->addChild({
		className=>"WebGUI::Asset::Wobject::Folder",
		title => "7.0.0 New Templates",
		menuTitle => "7.0.0 New Templates",
		url=> "7_0_0_new_templates",
		groupIdView=>"12"
		});
	foreach my $file (@files) {
		next unless ($file =~ /\.tmpl$/);
		open(FILE,"<templates-6.99.0/".$file);
		my $first = 1;
		my $create = 0;
		my $head = 0;
		my %properties = (className=>"WebGUI::Asset::Template");
		while (my $line = <FILE>) {
			if ($first) {
				$line =~ m/^\#(.*)$/;
				$properties{id} = $1;
				$first = 0;
			} elsif ($line =~ m/^\#create$/) {
				$create = 1;
			} elsif ($line =~ m/^\#(.*):(.*)$/) {
				$properties{$1} = $2;
			} elsif ($line =~ m/^~~~$/) {
				$head = 1;
			} elsif ($head) {
				$properties{headBlock} .= $line;
			} else {
				$properties{template} .= $line;	
			}
		}
		close(FILE);
		if ($create) {
			#sleep(1);
			my $template = $folder->addChild(\%properties, $properties{id});
		} else {
			#sleep(1);
			my $template = WebGUI::Asset->new($session,$properties{id}, "WebGUI::Asset::Template");
			if (defined $template) {
				my $newRevision = $template->addRevision(\%properties);
			}
		}
	}
}

#-------------------------------------------------
sub addEMS {

my $sql1 = <<SQL1;

create table EventManagementSystem (
 assetId varchar(22) binary not null,
 revisionDate bigint(20) not null,
 displayTemplateId varchar(22) binary,
 checkoutTemplateId varchar(22) binary,
 managePurchasesTemplateId varchar(22) binary,
 paginateAfter int(11) default 10,
 groupToAddEvents varchar(22) binary,
 groupToApproveEvents varchar(22) binary,
 globalPrerequisites tinyint default 1,
 globalMetadata tinyint default 1,
primary key(assetId,revisionDate)
)
SQL1

my $sql2 = <<SQL2;

create table EventManagementSystem_products (
 productId varchar(22) binary not null,
 assetId varchar(22) binary,
 startDate bigint(20),
 endDate bigint(20),
 maximumAttendees int(11),
 approved tinyint,
 sequenceNumber int(11),
primary key(productId)
)
SQL2

my $sql3 = <<SQL3;
create table EventManagementSystem_registrations (
 registrationId varchar(22) binary not null,
 productId varchar(22) binary,
 purchaseId varchar(22) binary,
 badgeId varchar(22) binary,
 returned tinyint default 0,
 primary key(registrationId))
SQL3

my $sql4 = <<SQL4;

create table EventManagementSystem_purchases (
 purchaseId varchar(22) binary not null,
 transactionId varchar(22) binary,
primary key(purchaseId)
)
SQL4

my $sql5 = <<SQL5;

create table EventManagementSystem_prerequisites (
 prerequisiteId varchar(22) binary not null,
 productId varchar(22) binary,
 operator varchar(100),
primary key(prerequisiteId)
)
SQL5

my $sql6 = <<SQL6;

create table EventManagementSystem_prerequisiteEvents (
 prerequisiteEventId varchar(22) binary not null,
 prerequisiteId varchar(22) binary,
 requiredProductId varchar(22) binary,
primary key(prerequisiteEventId)
)
SQL6

my $sql7 = <<SQL7;

create table EventManagementSystem_metaField (
 fieldId varchar(22) binary not null,
 assetId varchar(22) binary,
 name varchar(50),
 label varchar(100),
 dataType varchar(20),
 visible tinyint default 0,
 required tinyint default 0,
 possibleValues text,
 defaultValues text,
 sequenceNumber int(5),
 autoSearch tinyint default 0,
primary key(fieldId)
)
SQL7

my $sql8 = <<SQL8;

create table EventManagementSystem_metaData (
 fieldId varchar(22) binary not null,
 productId varchar(22) binary not null,
 fieldData text,
primary key(fieldId,productId)
)
SQL8


my $sql9 = <<SQL9;
create table EventManagementSystem_badges (
 badgeId varchar(22) binary not null,
 userId varchar(22) binary,
 firstName varchar(100),
 lastName varchar(100),
 address varchar(100),
 city varchar(100),
 state varchar(50),
 zipCode varchar(15),
 country varchar(255),
 phone varchar(50),
 email varchar(255),
primary key(badgeId)
)
SQL9

	$session->db->write($sql1);
	$session->db->write($sql2);
	$session->db->write($sql3);
	$session->db->write($sql4);
	$session->db->write($sql5);
	$session->db->write($sql6);
	$session->db->write($sql7);
	$session->db->write($sql8);
	$session->db->write($sql9);
}

#-------------------------------------------------
sub addSearchEngine {
	print "\tUpgrading search engine.\n" unless ($quiet);
	$session->config->set("searchIndexerPlugins", {
        	"txt" => "/bin/cat",
        	"readme"=> "/bin/cat",
        	"html" => "/bin/cat",
        	"htm" => "/bin/cat"
        	});
	$session->db->write("create table search ( 
		assetId varchar(22) binary not null,
		revisionDate bigint not null default 0,
		classLimiter text,
		searchRoot varchar(22) binary not null default 'PBasset000000000000001',
		templateId varchar(22) binary not null default 'PBtmpl0000000000000200',
		primary key (assetId,revisionDate)
		)");
	$session->db->write("create table assetIndex (
		assetId varchar(22) binary not null primary key,
		title varchar(255),
		synopsis text,
		url varchar(255),
		creationDate bigint,
		revisionDate bigint,
		ownerUserId varchar(22) binary,
		groupIdView varchar(22) binary,
		groupIdEdit varchar(22) binary,
		lineage varchar(255),
		className varchar(255),
		isPublic int not null default 1,
		keywords mediumtext,
		fulltext (keywords)
		)");
	my @searchParents = $session->db->buildArray("select parentId from asset where className='WebGUI::Asset::Wobject::IndexedSearch'");
	my @searchIds = $session->db->buildArray("select assetId from asset where className='WebGUI::Asset::Wobject::IndexedSearch'");
	$session->db->write("delete from asset where className='WebGUI::Asset::Wobject::IndexedSearch'");
	my $deleteWobject = $session->db->prepare("delete from wobject where assetId=?");
	my $deleteAssetData = $session->db->prepare("delete from assetData where assetId=?");
	foreach my $id (@searchIds) {
		$deleteWobject->execute($id);
		$deleteAssetData->execute($id);
	}
	$deleteWobject->finish;
	$deleteAssetData->finish;
	$session->db->write("drop table if exists IndexedSearch");
	$session->db->write("drop table if exists IndexedSearch_default");
	$session->db->write("drop table if exists IndexedSearch_default_data");
	$session->db->write("drop table if exists IndexedSearch_default_words");
	$session->db->write("drop table if exists IndexedSearch_docInfo");
}

#-------------------------------------------------
sub templateParsers {
	print "\tAdding support for multiple template parsers.\n" unless ($quiet);
	$session->config->set("templateParsers",["WebGUI::Asset::Template::HTMLTemplate"]);
	$session->config->set("defaultTemplateParser","WebGUI::Asset::Template::HTMLTemplate");
	$session->db->write("alter table template add column parser varchar(255) not null default 'WebGUI::Asset::Template::HTMLTemplate'");
}

#-------------------------------------------------
sub removeFiles {
	print "\tRemoving old unneeded files.\n" unless ($quiet);
	unlink '../../lib/WebGUI/MessageLog.pm';
	unlink '../../lib/WebGUI/Operation/MessageLog.pm';
	unlink '../../lib/WebGUI/ErrorHandler.pm';
	unlink '../../lib/WebGUI/HTTP.pm';
	unlink '../../lib/WebGUI/Privilege.pm';
	unlink '../../lib/WebGUI/DateTime.pm';
	unlink '../../lib/WebGUI/FormProcessor.pm';
	unlink '../../lib/WebGUI/URL.pm';
	unlink '../../lib/WebGUI/Id.pm';
	unlink '../../lib/WebGUI/Icon.pm';
	unlink '../../lib/WebGUI/Mail.pm';
	unlink '../../lib/WebGUI/Style.pm';
	unlink '../../lib/WebGUI/Setting.pm';
	unlink '../../lib/WebGUI/Grouping.pm';
	unlink '../../lib/WebGUI/Asset/Wobject/IndexedSearch.pm';
	unlink '../../lib/WebGUI/Help/Asset_IndexedSearch.pm';
	unlink '../../lib/WebGUI/i18n/Asset_IndexedSearch.pm';
	unlink '../../sbin/Hourly/IndexedSearch_buildIndex.pm';
	rmtree('../../lib/WebGUI/Asset/Wobject/IndexedSearch');
	rmtree('../../sbin/Hourly');
	unlink('../../sbin/runHourly.pl');
}

#-------------------------------------------------
sub addDisabletoRichEditor {
	print "\tUpdating Rich Editor to add master disable.\n" unless ($quiet);
	my $sth = $session->db->read('show columns from RichEdit');
	my $numColumns = $sth->rows;
	$sth->finish;
	# only add the column if it doesn't already exist.
	$session->db->write("alter table RichEdit add column disableRichEditor int(11) default 0") if ($numColumns < 21);
}

#-------------------------------------------------
sub changeDbCacheTimeoutName {
	print "\tChanging dbCacheTimeout to groupCacheTimeout.\n" unless ($quiet);
	$session->db->write("alter table groups change dbCacheTimeout groupCacheTimeout int not null default 3600");
}

#-------------------------------------------------
sub addNavigationMimeType {
	print "\tAdding Mime Type to Navigations.\n" unless ($quiet);
	$session->db->write("alter table Navigation add column mimeType varchar(50) default 'text/html'");
}

#-------------------------------------------------
sub ipsToCIDR {
	print "\tTranslating IP addresses to CIDR format.\n" unless ($quiet);
	print "\t\tStarting with Group ipFilters.\n" unless ($quiet);
	my $sth = $session->db->read('select groupId, ipFilter from groups');
	while (my $hash = $sth->hashRef) {
		next unless $hash->{ipFilter};
		$hash->{ipFilter} =~ s/\s//g;
		my @ips = split /;/, $hash->{ipFilter};
		@ips = map { ip2cidr($_) } @ips;
		$session->db->write('update groups set ipFilter=? where groupId=?',
				[join(',', @ips), $hash->{groupId}]);
	}
	print "\t\tUpdating debug Ip.\n" unless ($quiet);
	$sth = $session->db->read("select * from settings where name='debugIp'");
	while (my $hash = $sth->hashRef) {
		next unless $hash->{value};
		my @ips = split /\s+/, $hash->{value};
		@ips = map { ip2cidr($_) } @ips;
		$session->db->write('update settings set value=? where name=?',
				[join(',', @ips), $hash->{name}]);
	}
}

sub ip2cidr {
	my ($ip) = @_;
	$ip =~ s/\.$//;
	my $bytes = $ip =~ tr/././;
	my $new_bytes = 3-$bytes;
	my $prefixLength = 32 - 8*$new_bytes;
	$ip .= ('.0' x $new_bytes) . "/$prefixLength";
	return $ip;
}


#-------------------------------------------------
sub updateHelpTemplate {
	print "\tUpdating Help template.\n" unless ($quiet);
	my $template = <<EOT;
<p><tmpl_var body></p>

<tmpl_if fields>
<dl>
<tmpl_loop fields>

   <dt><tmpl_var title></dt>
         <dd><tmpl_var description>
<tmpl_if uiLevel>
	<br /><i><tmpl_var uiLevelLabel>:</i><tmpl_var uiLevel>
</tmpl_if>
</dd>
	 </tmpl_loop>
	 </dl>
	 </tmpl_if>
EOT
	my $asset = WebGUI::Asset->new($session,"PBtmplHelp000000000001","WebGUI::Asset::Template");
	$asset->addRevision({template=>$template});
}

# ---- DO NOT EDIT BELOW THIS LINE ----

#-------------------------------------------------
sub start {
	my $configFile;
	$|=1; #disable output buffering
	GetOptions(
    		'configFile=s'=>\$configFile,
        	'quiet'=>\$quiet
	);
	my $session = WebGUI::Session->open("../..",$configFile);
	$session->user({userId=>3});
	$session->db->write("insert into webguiVersion values (".$session->db->quote($toVersion).",'upgrade',".$session->datetime->time().")");
	return $session;
}

#-------------------------------------------------
sub finish {
	my $session = shift;
	my $versionTag = WebGUI::VersionTag->getWorking($session);
	$versionTag->commit;
	$session->close();
}

