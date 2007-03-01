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
use WebGUI::Workflow;
use WebGUI::International;

my $toVersion = "7.3.0"; # make this match what version you're going to
my $quiet; # this line required


my $session = start(); # this line required
addWikiAssets($session);
deleteOldFiles($session);
addFileFieldsToDataForm($session);
makeRSSFromParentAlwaysHidden($session);
addProfileFieldsOnPasswordRecovery($session);
addEmailValidationExpiry($session);
addNewCalendar($session);
migrateCalendars($session);
removeOldCalendar($session);
fixCommerceTemplateSettings($session);
finish($session); # this line required

#-------------------------------------------------
sub addFileFieldsToDataForm {
	my $session = shift;
	print "\tAdding File Field Types to the Data Form Wobject\n" unless $quiet;
	$session->db->write("alter table DataForm add column (mailAttachments int(11) default 0)");
}

#-------------------------------------------------
sub deleteOldFiles {
	my $session = shift;
	print "\tDeleting old unneeded files.\n" unless $quiet;
	unlink "../../www/extras/assets/wiki.gif";
	unlink "../../www/extras/assets/wikiPost.gif";
	unlink "../../www/extras/assets/small/wiki.gif";
	unlink "../../www/extras/assets/small/wikiPost.gif";
}

#-------------------------------------------------
sub addWikiAssets {
	my $session = shift;
	print "\tAdding wiki assets.\n" unless $quiet;

	$session->db->write($_) for(<<'EOT',
  CREATE TABLE `WikiMaster` (
    `assetId` varchar(22) character set utf8 collate utf8_bin NOT NULL,
    `revisionDate` bigint(20) NOT NULL,
    `groupToEditPages` varchar(22) character set utf8 collate utf8_bin NOT NULL default '2',
    `groupToAdminister` varchar(22) character set utf8 collate utf8_bin NOT NULL default '3',
    `richEditor` varchar(22) character set utf8 collate utf8_bin NOT NULL
                 default 'PBrichedit000000000002',
    `frontPageTemplateId` varchar(22) character set utf8 collate utf8_bin NOT NULL
                          default 'WikiFrontTmpl000000001',
    `pageTemplateId` varchar(22) character set utf8 collate utf8_bin NOT NULL
                     default 'WikiPageTmpl0000000001',
    `pageEditTemplateId` varchar(22) character set utf8 collate utf8_bin NOT NULL
                         default 'WikiPageEditTmpl000001',
    `recentChangesTemplateId` varchar(22) character set utf8 collate utf8_bin NOT NULL default 'WikiRCTmpl000000000001',
    `mostPopularTemplateId` varchar(22) character set utf8 collate utf8_bin NOT NULL default 'WikiMPTmpl000000000001',
    `pageHistoryTemplateId` varchar(22) character set utf8 collate utf8_bin NOT NULL
                            default 'WikiPHTmpl000000000001',
    `searchTemplateId` varchar(22) character set utf8 collate utf8_bin NOT NULL
                       default 'WikiSearchTmpl00000001',
    `recentChangesCount` int(11) NOT NULL default 50,
    `recentChangesCountFront` int(11) NOT NULL default 10,
    `mostPopularCount` int(11) NOT NULL default 50,
    `mostPopularCountFront` int(11) NOT NULL default 10,
    `thumbnailSize` int(11) NOT NULL default 0,
    `maxImageSize` int(11) NOT NULL default 0,
	`approvalWorkflow` varchar(22) binary not null default 'pbworkflow000000000003',
    PRIMARY KEY (`assetId`, `revisionDate`)
  ) ENGINE=MyISAM DEFAULT CHARSET=utf8;
EOT
				    <<'EOT',
  CREATE TABLE `WikiPage` (
    `assetId` varchar(22) character set utf8 collate utf8_bin NOT NULL,
    `revisionDate` bigint(20) NOT NULL,
    `content` mediumtext,
    `storageId` varchar(22) character set utf8 collate utf8_bin NULL,
    `views` bigint(20) NOT NULL default 0,
	isProtected int not null default 0,
	actionTaken varchar(35) not null,
	actionTakenBy varchar(22) binary not null,
    PRIMARY KEY (`assetId`, `revisionDate`)
  ) ENGINE=MyISAM DEFAULT CHARSET=utf8;
EOT
				   );

	$session->config->addToArray('assets', 'WebGUI::Asset::Wobject::WikiMaster');
}

#-----------------------------------------------------
sub makeRSSFromParentAlwaysHidden {
	my $session = shift;
	print "\tHiding RSS From Parent assets.\n" unless $quiet;

	# Since it's internal anyway, might as well just do it directly to all the revisions.
	$session->db->write($_) for(<<'EOT',
  UPDATE assetData AS d INNER JOIN RSSFromParent AS r
                                ON d.assetId = r.assetId AND d.revisionDate = r.revisionDate
     SET d.isHidden = 1
EOT
				   );
}

#-------------------------------------------------
sub addNewCalendar {
	my $session = shift;
	my $i18n = WebGUI::International->new($session,'Asset_Calendar');
	print "\tCreating Calendar and Event tables.\n" unless $quiet;
	
	$session->db->write($_) for (<<'ENDSQL',
CREATE TABLE `Event` (
  `assetId` varchar(22) NOT NULL, 
  `revisionDate` bigint(20) unsigned NOT NULL,
  `feedId` varchar(22) default NULL,
  `feedUid` varchar(255) default NULL,
  `startDate` date default NULL,
  `endDate` date default NULL,
  `userDefined1` text,
  `userDefined2` text,
  `userDefined3` text,
  `userDefined4` text,
  `userDefined5` text,
  `recurId` varchar(22) default NULL,
  `description` longtext,
  `startTime` time default NULL,
  `endTime` time default NULL,
  `relatedLinks` longtext,
  `location` varchar(255) default NULL,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8
ENDSQL
		<<'ENDSQL',
CREATE TABLE `Calendar` (
  `assetId` varchar(22) NOT NULL,
  `revisionDate` bigint(20) unsigned NOT NULL default '0',
  `defaultDate` enum('current','first','last') default "current",
  `defaultView` enum('month','week','day') default "month",
  `visitorCacheTimeout` int(11) unsigned default NULL,
  `templateIdMonth` varchar(22) default "CalendarMonth000000001",
  `templateIdWeek` varchar(22) default "CalendarWeek0000000001",
  `templateIdDay` varchar(22) default "CalendarDay00000000001",
  `templateIdEvent` varchar(22) default "CalendarEvent000000001",
  `templateIdEventEdit` varchar(22) default "CalendarEventEdit00001",
  `templateIdSearch` varchar(22) default "CalendarSearch00000001",
  `templateIdPrintMonth` varchar(22) default "CalendarPrintMonth0001",
  `templateIdPrintWeek` varchar(22) default "CalendarPrintWeek00001",
  `templateIdPrintDay` varchar(22) default "CalendarPrintDay000001",
  `templateIdPrintEvent` varchar(22) default "CalendarPrintEvent0001",
  `groupIdEventEdit` varchar(22) default "3",
  `groupIdSubscribed` varchar(22) default NULL,
  `subscriberNotifyOffset` int(11) default NULL,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8
ENDSQL
		<<'ENDSQL',
CREATE TABLE `Event_recur` (
  `recurId` varchar(22) NOT NULL,
  `recurType` varchar(16) default NULL,
  `pattern` varchar(255) default NULL,
  `startDate` date default NULL,
  `endDate` varchar(10) default NULL,
  PRIMARY KEY  (`recurId`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8
ENDSQL
		<<'ENDSQL',
CREATE TABLE `Calendar_feeds` (
  `feedId` varchar(22) NOT NULL,
  `assetId` varchar(22) NOT NULL,
  `url` varchar(255) NOT NULL,
  `lastUpdated` int(16) default NULL,
  `lastResult` varchar(255) default NULL,
  `feedType` varchar(30) NOT NULL,
  PRIMARY KEY  (`feedId`,`assetId`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
ENDSQL
);
	
	$session->config->addToArray('assets', 'WebGUI::Asset::Wobject::Calendar');
	
	my $workflows = $session->config->get("workflowActivities");
	push @{$workflows->{None}},"WebGUI::Workflow::Activity::CalendarUpdateFeeds";
	$session->config->set("workflowActivities",$workflows);
	
	# Add the Calendar Update Feeds activity to Hourly Maintenance workflow
	my $workflow = WebGUI::Workflow->new($session,"pbworkflow000000000004");
	my $activity = $workflow->addActivity("WebGUI::Workflow::Activity::CalendarUpdateFeeds");
	$activity->set("title", $i18n->get("workflow updateFeeds"));
	$activity->set("description", $i18n->get("workflow updateFeeds description"));	
}

#-------------------------------------------------
sub migrateCalendars {
	my $session	= shift;
	
	print "\tMigrating EventsCalendar to Calendar wobjects.\n" unless $quiet;
	use WebGUI::DateTime;
	
	# For every EventsCalendar
	#EventsCalendar.defaultMonth = Calendar.defaultDate
	my $calendars	= WebGUI::Asset->getRoot($session)->getLineage(['descendents'],
		{
            statesToInclude     => ['published','trash','clipboard','clipboard-limbo','trash-limbo'],
            statusToInclude     => ['pending','approved','deleted','archived'],
			includeOnlyClasses	=> ['WebGUI::Asset::Wobject::EventsCalendar'],
			returnObjects		=> 1,
		});

	for my $asset (@{$calendars})
	{
		next unless defined $asset;
        
        # If the asset is in the trash, ignore the migration, we're just going
        # to purge it.
        if ($asset->get("state") =~ m/trash/) {
            next;
        }


		my $properties	= {%{$asset->get}};
		#warn "Found calendar ".$properties->{title};
		$properties->{defaultDate}	    = delete $properties->{defaultMonth};
		$properties->{className}	    = "WebGUI::Asset::Wobject::Calendar";
        $properties->{groupIdEventEdit} = $properties->{groupIdEdit};

		# Add the new asset
		my $newAsset = $asset->getParent->addChild($properties);
		#warn "Added Calendar ".$newAsset->get("title")." ".$newAsset->get("className");
	    
		# Get this calendar's events and change to new parent
		my $events	= $asset->getLineage(['descendants'],
			{
                statesToInclude     => ['published','trash','clipboard','clipboard-limbo','trash-limbo'],
                statusToInclude     => ['pending','approved','deleted','archived'],
				includeOnlyClasses	=> ['WebGUI::Asset::Event'],
			});
		#warn "Got lineage";
		
		
		for my $event (@{$events}) {
			#warn "Got event: $event";
			
			# Add a child to the new calendar using the properties 
			# from EventsCalendar_event
            my %eventProperties = $session->db->quickHash("
                    select
                            *
                    from
                            asset
                    left join
                            assetData on asset.assetId=assetData.assetId
                    left join
                            EventsCalendar_event on asset.assetId = EventsCalendar_event.assetId and assetData.revisionDate=EventsCalendar_event.revisionDate
                    where
                            asset.assetId = ? 
                            and assetData.revisionDate=(
                                    select
                                            max(revisionDate)
                                    from assetData
                                    where assetData.assetId=asset.assetId
                                    and (status='approved' or status='archived')
                            )
                    ",[$event]);
			delete $eventProperties{assetId};
			
			my ($startDate, $startTime) = split / /, WebGUI::DateTime->new(delete $eventProperties{eventStartDate})->toMysql;
			my ($endDate, $endTime) = split / /, WebGUI::DateTime->new(delete $eventProperties{eventEndDate})->toMysql;
			
			$eventProperties{startDate} 	= $startDate;
			$eventProperties{startTime} 	= $startTime;
			$eventProperties{endDate} 	= $endDate;
			$eventProperties{endTime} 	= $endTime;
			#use Data::Dumper;
			#warn Dumper \%eventProperties;
			
            $newAsset->addChild(\%eventProperties,undef,undef,{skipAutoCommitWorkflows=>1});

			# Remove this event from the old calendar
			$session->db->write("delete from EventsCalendar_event where assetId=?",[$event]);
			$session->db->write("delete from asset where assetId=?",[$event]);
			$session->db->write("delete from assetData where assetId=?",[$event]);
			$session->db->write("delete from assetIndex where assetId=?",[$event]);
			$session->db->write("delete from assetHistory where assetId=?",[$event]);
		}
		#warn "Set parents on events";
		
		
        # Save the old Calendar's URL so we can fix it
        my $fixUrl = $asset->get("url");
		
        # Remove the old asset
		$asset->purge;
		#warn "Purged old calendar";
        
        # Fix the new Calendar's URL
        $newAsset->update({ url => $fixUrl });
	}
}

#-------------------------------------------------
sub removeOldCalendar {
	my $session	= shift;
	print "\tRemoving old EventsCalendar tables, templates, .\n" unless $quiet;
	
	# Remove tables
	$session->db->write("drop table EventsCalendar");
	$session->db->write("drop table EventsCalendar_event");
	
	# Remove Plainblack's EventsCalendar / Events templates
	#PBtmpl0000000000000022
	WebGUI::Asset->newByDynamicClass($session,"PBtmpl0000000000000022")->purge;
	#PBtmpl0000000000000023
	WebGUI::Asset->newByDynamicClass($session,"PBtmpl0000000000000023")->purge;
	
	$session->config->deleteFromArray("assets","WebGUI::Asset::Wobject::EventsCalendar");
}

#-------------------------------------------------
sub addProfileFieldsOnPasswordRecovery {
	my $session = shift;
	print "\tAdding requiredForPasswordRecovery to userProfileField rows.\n" unless $quiet;
	$session->db->write($_) for(<<'EOT',
  ALTER TABLE userProfileField
   ADD COLUMN requiredForPasswordRecovery int(11) NOT NULL default '0'
EOT
				   );

	$session->setting->set('webguiPasswordRecovery', 0);
	$session->setting->add('webguiPasswordRecoveryRequireUsername', 1);
	$session->setting->set('webguiPasswordRecoveryTemplate', 'PBtmpl0000000000000014');
}

#-------------------------------------------------
sub addEmailValidationExpiry {
	my $session = shift;
	print "\tAdding email validation expiry.\n" unless $quiet;

	# Remove email activation keys for active users so that if they deactivate themselves
	# in the future the workflow activity doesn't treat them as deleted.
	$session->db->write($_) for (<<'EOT',
  DELETE FROM authentication
        WHERE fieldName = 'emailValidationKey' AND
              (SELECT status FROM users AS u WHERE u.userId = userId) = 'Active'
EOT
				    );

	my $activities = $session->config->get('workflowActivities');
	my $class = 'WebGUI::Workflow::Activity::ExpireUnvalidatedEmailUsers';
	@{$$activities{None}} = ((grep{$_ ne $class} @{$$activities{None}}), $class);
	$session->config->set('workflowActivities', $activities);
}

#-------------------------------------------------
sub fixCommerceTemplateSettings {
	my $session = shift;
	print "\tFixing up commerce template settings.\n" unless $quiet;
	foreach my $spec (['commerceConfirmCheckoutTemplateId', 'PBtmpl0000000000000016'],
			  ['commerceCheckoutCanceledTemplateId', 'PBtmpl0000000000000015'],
			  ['commercePurchaseHistoryTemplateId', 'PBtmpl0000000000000019'],
			  ['commerceSelectShippingMethodTemplateId', 'PBtmplCSSM000000000001'],
			  ['commerceSelectPaymentGatewayTemplateId', 'PBtmpl0000000000000017'],
			  ['commerceViewShoppingCartTemplateId', 'PBtmplVSC0000000000001'],
			  ['commerceTransactionErrorTemplateId', 'PBtmpl0000000000000018']) {
		my ($name, $value) = @$spec;
		if ($session->setting->get($name) eq '1') {
			$session->setting->set($name, $value);
		}
	}
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
	my $versionTag = WebGUI::VersionTag->getWorking($session);
	$versionTag->set({name=>"Upgrade to ".$toVersion});
	$session->db->write("insert into webguiVersion values (".$session->db->quote($toVersion).",'upgrade',".$session->datetime->time().")");
	updateTemplates($session);
	return $session;
}

#-------------------------------------------------
sub finish {
	my $session = shift;
	my $versionTag = WebGUI::VersionTag->getWorking($session);
	$versionTag->commit;
	$session->close();
}

#-------------------------------------------------
sub updateTemplates {
	my $session = shift;
	return undef unless (-d "templates-".$toVersion);
        print "\tUpdating templates.\n" unless ($quiet);
	opendir(DIR,"templates-".$toVersion);
	my @files = readdir(DIR);
	closedir(DIR);
	my $importNode = WebGUI::Asset->getImportNode($session);
	my $newFolder = undef;
	foreach my $file (@files) {
		next unless ($file =~ /\.tmpl$/);
		open(FILE,"<templates-".$toVersion."/".$file);
		my $first = 1;
		my $create = 0;
		my $head = 0;
		my %properties = (className=>"WebGUI::Asset::Template");
		while (my $line = <FILE>) {
			if ($first) {
				$line =~ m/^\#(.{0,22})$/;
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
		if ($create && !WebGUI::Asset->newByDynamicClass($session,$properties{id})) {
			$newFolder = createNewTemplatesFolder($importNode) unless (defined $newFolder);
			my $template = $newFolder->addChild(\%properties, $properties{id});
		} else {
			my $template = WebGUI::Asset->new($session,$properties{id}, "WebGUI::Asset::Template");
			if (defined $template) {
				my $newRevision = $template->addRevision(\%properties);
			}
		}
	}
}

#-------------------------------------------------
sub createNewTemplatesFolder {
	my $importNode = shift;
	my $newFolder = $importNode->addChild({
		className=>"WebGUI::Asset::Wobject::Folder",
		title => $toVersion." New Templates",
		menuTitle => $toVersion." New Templates",
		url=> $toVersion."_new_templates",
		groupIdView=>"12"
		});
	return $newFolder;
}



