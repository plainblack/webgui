#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use lib "../../lib";
use strict;
use FileHandle;
use File::Copy qw(cp);
use Getopt::Long;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Asset;
use WebGUI::Setting;
use WebGUI::User;

my $toVersion = "6.8.0";
my $configFile;
my $quiet;

start();
addTimeZonesToUserPreferences();
# MUST DO: any dates in WebGUI greater than epoch 2^32 must be reduced, because
# the new DateTime system uses Params::Validate, which will only validate integers
# up to 2^32 as SCALARs. :(
removeUnneededFiles();
updateCollaboration();
addPhotoField();
addAvatarField();
addEnableAvatarColumn();
addSpectre();
addWorkflow();
finish();

#-------------------------------------------------
sub updateCollaboration {
print "\tAdding collaboration/rss template\n" unless ($quiet);
WebGUI::SQL->write("ALTER TABLE Collaboration ADD COLUMN rssTemplateId varchar(22) binary NOT NULL default 'PBtmpl0000000000000142' after notificationTemplateId");
my $template = <<STOP;
<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
<channel>
<title><tmpl_var title></title>
<link><tmpl_var link></link>
<description><tmpl_var description></description>
<tmpl_loop item_loop>
<item>
<title><tmpl_var title></title>
<link><tmpl_var link></link>
<description><tmpl_var description></description>
<guid isPermaLink="true"><tmpl_var guid></guid>
<pubDate><tmpl_var pubDate></pubDate>
</item>
</tmpl_loop>
</channel>
</rss>
STOP
# Get Template folder
my $templateFolder = WebGUI::Asset->newByUrl('templates');
# Add Collaboration/RSS folder beneath
my $rssFolder = $templateFolder->addChild({
    title=>"Collaboration/RSS",
    menuTitle=>"Collaboration/RSS",
    url=>"templates/collaboration/rss",
    className=>"WebGUI::Asset::Wobject::Folder"
    });
$rssFolder->commit;
# Place the Collaboration/RSS folder beneath the 
# Collaboration/Thread folder
my $threadFolder = WebGUI::Asset->newByUrl('templates/collaboration/thread');
my $threadRank = $threadFolder->getRank;
$rssFolder->setRank($threadRank + 1);

$rssFolder->addChild({
	className=>"WebGUI::Asset::Template",
	template=>$template,
	namespace=>"Collaboration/RSS",
	title=>'Default Forum RSS',
        menuTitle=>'Default Forum RSS',
        ownerUserId=>'3',
        groupIdView=>'7',
        groupIdEdit=>'4',
        isHidden=>1
	}, 'PBtmpl0000000000000142'
);

}

#-------------------------------------------------
sub addTimeZonesToUserPreferences {
	print "\tDropping time offsets in favor of time zones.\n" unless ($quiet);
	WebGUI::SQL->write("delete from userProfileData where fieldName='timeOffset'");
	WebGUI::SQL->write("update userProfileField set dataValues='', fieldName='timeZone', dataType='timeZone', dataDefault=".quote("['America/Chicago']")." where fieldName='timeOffset'");
	WebGUI::SQL->write("insert into userProfileData values ('1','timeZone','America/Chicago')");
}

sub removeUnneededFiles {
	print "\tRemoving files that are no longer needed.\n" unless ($quiet);
	unlink("../../www/env.pl");
	unlink("../../www/index.fpl");
	unlink("../../www/index.pl");
}

#-------------------------------------------------
sub addPhotoField {
	print "\tAdding photo field to User Profiles\n" unless ($quiet);
	##Get profileCategoryId.
	my ($categoryId) = WebGUI::SQL->quickArray(q!select profileCategoryId from userProfileCategory where categoryName='WebGUI::International::get(439,"WebGUI");'!);
	##Get last sequence number
	my ($lastField) = WebGUI::SQL->buildArray(qq!select max(sequenceNumber) from userProfileField where profileCategoryId=$categoryId!);
	++ $lastField;
	##Insert Photo Field
	WebGUI::SQL->write(sprintf q!insert into userProfileField values ('photo','WebGUI::International::get("photo","WebGUI");', 1, 0, 'Image', '', '', %d, %d, 1, 1)!, $lastField, $categoryId);
}

#-------------------------------------------------
sub addAvatarField {
	print "\tAdding avatar field to User Profiles\n" unless ($quiet);
	##Get profileCategoryId.
	my ($categoryId) = WebGUI::SQL->buildArray(q!select profileCategoryId from userProfileCategory where categoryName='WebGUI::International::get(449,"WebGUI");';!);
	##Get last sequence number
	my ($lastField) = WebGUI::SQL->buildArray(qq!select max(sequenceNumber) from userProfileField where profileCategoryId=$categoryId!);
	++ $lastField;
	##Insert Photo Field
	WebGUI::SQL->write( sprintf q!insert into userProfileField values('avatar','WebGUI::International::get("avatar","WebGUI");', 0, 0, 'Image', '', '', %d, %d, 1, 0)!, $lastField, $categoryId );
}

#-------------------------------------------------
sub addEnableAvatarColumn {
	print "\tAdding enableAvatar column to Collaborations\n" unless ($quiet);
	WebGUI::SQL->write('ALTER TABLE Collaboration ADD COLUMN avatarsEnabled int(11) NOT NULL DEFAULT 0');
}

#-------------------------------------------------
sub addSpectre {
	print "\tAdding Spectre\n" unless ($quiet);
	my $user = WebGUI::User->new("new","pbuser_________spectre");
	$user->username("Spectre");
	$user->addToGroups([3]);
	my $source = FileHandle->new("../../etc/spectre.conf.original","r");
        if (defined $source) {
        	binmode($source);
                my $dest = FileHandle->new(">../../etc/spectre.conf");
                if (defined $dest) {
                	binmode($dest);
                        cp($source,$dest);
                        $dest->close;
                }
                $source->close;
        }
}

#-------------------------------------------------
sub addWorkflow {
	print "\tAdding Workflow\n" unless ($quiet);
	WebGUI::SQL->write("create table WorkflowSchedule (
		taskId varchar(22) binary not null primary key,
		enabled int not null default 1,
		minuteOfHour varchar(25),
		hourOfDay varchar(25),
		dayOfMonth varchar(25),
		monthOfYear varchar(25),
		dayOfWeek varchar(25),
		workflowId varchar(22) binary not null
		)");
	WebGUI::SQL->write("create table WofklowInstance (
		instanceId varchar(22) binary not null primary key,
		workflowId varchar(22) binary not null,
		currentActivityId varchar(22) binary not null,
		priority int
		)");
	WebGUI::SQL->write("create table WorkflowInstanceData (
		instanceId varchar(22) binary not null primary key,
		dataName varchar(35),
		className varchar(255),
		methodName varchar(255),
		parameters text
		)");
	WebGUI::SQL->write("create table Wofklow (
		workflowId varchar(22) binary not null primary key,
		title varchar(255),
		description text
		)");
	WebGUI::SQL->write("create table WorkflowActivity (
		activityId varchar(22) binary not null primary key,
		workflowId varchar(22) binary not null,
		title varchar(255),
		description text,
		previousActivityId varchar(22) binary not null,
		dateCreated bigint,
		className varchar(255)
		)");
	WebGUI::SQL->write("create table WorkflowActivityProperty (
		propertyId varchar(22) binary not null primary key,
		activityId varchar(22) binary not null,
		name varchar(255),
		value text
		)");
}


#--- DO NOT EDIT BELOW THIS LINE

#-------------------------------------------------
sub start {
	$|=1; #disable output buffering
	GetOptions(
    		'configFile=s'=>\$configFile,
        	'quiet'=>\$quiet
	);
	WebGUI::Session::open("../..",$configFile);
	WebGUI::Session::refreshUserInfo(3);
	WebGUI::SQL->write("insert into webguiVersion values (".quote($toVersion).",'upgrade',".time().")");
}

#-------------------------------------------------
sub finish {
	WebGUI::Session::close();
}

