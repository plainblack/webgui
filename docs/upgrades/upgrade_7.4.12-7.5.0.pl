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
use WebGUI::ProfileField;


my $toVersion = "7.5.0"; # make this match what version you're going to
my $quiet; # this line required


my $session = start(); # this line required

addFriendsNetwork($session);
addSearchWithContainers($session);

finish($session); # this line required


#-------------------------------------------------
sub addSearchWithContainers {
    my $session = shift;
    print "\tMaking search capable of displaying containers in search results instead of individaul assets." unless $quiet;
    $session->db->write("alter table search add column useContainers int not null default 0");
    print "DONE!\n" unless $quiet;
}

#-------------------------------------------------
sub addGroupToEditPost {
    my $session = shift;
    print "\tAdding the Group to Edit Post field to the Collaboration system." unless $quiet;
    $session->db->write("alter table Collaboration add column groupToEditPost varchar(22) not null");
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addFriendsNetwork {
    my $session = shift;
 	print "\tInstall the Friend's Network.\n" unless ($quiet);
 	print "\t\tInstall new Network User Profile Field for not wanting to be friendly.\n" unless ($quiet);
    my $field = WebGUI::ProfileField->create(
        $session,
        'ableToBeFriend',
        {
            'label'       => WebGUI::International->new($session)->get('user profile field friend availability', 'WebGUI'),
            'visible'     => 0,
            'required'    => 0,
            'protected'   => 1,
            'editable'    => 1,
            'fieldType'   => 'yesNo',
            'dataDefault' => 1,
        },
    );
    
 	print "\t\tUpdating Private Messaging Profile Field.\n" unless ($quiet);
    my $pmField = WebGUI::ProfileField->new($session,"allowPrivateMessages");
    my %data = (
		label              => 'WebGUI::International::get("allow private messages label","WebGUI")',
        visible            => 1,
        possibleValues     =>'{ all=>WebGUI::International::get("user profile field private message allow label","WebGUI"), friends=>WebGUI::International::get("user profile field private message friends only label","WebGUI"), none=>WebGUI::International::get("user profile field private message allow none label","WebGUI"),}',
		dataDefault        =>'["all"]',
		fieldType          =>'RadioList',
		required           => 0,
        protected          => 1,
        editable           => 1,
        );
    $pmField->set(\%data);
	$session->db->write("update userProfileData set allowPrivateMessages='all' where allowPrivateMessages='1'");
    $session->db->write("update userProfileData set allowPrivateMessages='none' where allowPrivateMessages='0'");
    
    
    print "\t\tInstall the table to keep track of friend network invitations.\n" unless ($quiet);
    my $db          = $session->db;
    $session->db->write(<<EOSQL);

CREATE TABLE friendInvitations (
    inviteId    VARCHAR(22) BINARY NOT NULL,
    inviterId   VARCHAR(22) BINARY NOT NULL,
    friendId    VARCHAR(22) BINARY NOT NULL,
    dateSent    datetime not null,
    comments    VARCHAR(255) NOT NULL,
    messageId varchar(22) binary not null,
    PRIMARY KEY (inviteId)
)
EOSQL

 	print "\t\tAdding friend cleanup workflow activity.\n" unless ($quiet);
    my $workflow = WebGUI::Workflow->new($session, "pbworkflow000000000001");
    my $activity = $workflow->addActivity("WebGUI::Workflow::Activity::DenyUnansweredFriends", "unansweredfriends_____");
    $activity->set("timeout", 60 * 60 * 24 * 30);
    $activity->set("title", "Deny Friend Requests Older Than A Month");

 	print "\t\tAdding friends related settings.\n" unless ($quiet);
    $session->setting->add("manageFriendsTemplateId", "managefriends_________");

 	print "\t\tAdd a new column to the users table to keep track of the groupId for friends." unless ($quiet);
    $db->write("alter table users add column friendsGroup varchar(22) binary not null default ''");
    print "OK\n" unless $quiet;
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



