#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

our ($webguiRoot);

BEGIN {
    $webguiRoot = "../..";
    unshift (@INC, $webguiRoot."/lib");
}

use strict;
use Getopt::Long;
use WebGUI::Session;
use WebGUI::Storage;
use WebGUI::Asset;
use WebGUI::Utility;
use Tie::IxHash;


my $toVersion = '7.6.2';
my $quiet; # this line required


my $session = start(); # this line required

# upgrade functions go here
repairManageWorkflows($session); 
addPreTextToThingyFields($session);
updateAddressBook($session);
changeDefaultPaginationInSearch($session);
upgradeToYui26($session);
addUsersOnlineMacro($session);
addProfileExtrasField($session);
addWorkflowToDataform( $session );
installDataTableAsset( $session );
installAjaxI18N( $session );
fixFriendsGroups( $session );
upgradeAccount( $session );
finish($session); # this line required

#----------------------------------------------------------------------------
sub fixFriendsGroups {
    my $session = shift;
    my $users = $session->db->buildArrayRef("select userId from users where friendsGroup is not null && friendsGroup != ''");
    foreach my $userId (@{$users}) {
        #purge the admin group
        WebGUI::User->new($session,$userId)->friends->deleteGroups([3]);
    }
}

#----------------------------------------------------------------------------
sub upgradeAccount {
    my $session = shift;
    my $config  = $session->config;
    my $setting = $session->setting;

    print "\tUpgrading WebGUI Account System... " unless $quiet;
    #Add account properties to config file
    $session->config->delete("account"); #Delete account if it exists
    $session->config->set("account",[
        {
            identifier    => "profile",
            title         => "^International(title,Account_Profile);",
            className     => "WebGUI::Account::Profile"
        },
        {
            identifier    => "inbox",
            title         => "^International(title,Account_Inbox);",
			className     => "WebGUI::Account::Inbox"
        },
        {
            identifier    => "friends",
            title         => "^International(title,Account_Friends);",
			className     => "WebGUI::Account::Friends"
        },
        {
            identifier    => "shop",
            title         => "^International(title,Account_Shop);",
			className     => "WebGUI::Account::Shop"
        },
        {
            identifier    => "user",
            title         => "^International(title,Account_User);",
			className     => "WebGUI::Account::User"
        },
    ]);
    $session->config->set("profileModuleIdentifier","profile");
    #Add the content handler to the config file if it's not there
    my $oldHandlers = $session->config->get( "contentHandlers" );
    unless (isIn("WebGUI::Content::Account",@{$oldHandlers})) {
        my @newHandlers;
        for my $handler ( @{ $oldHandlers } ) {
            if ( $handler eq "WebGUI::Content::Operation" ) {
                push @newHandlers, "WebGUI::Content::Account";
            }
            push @newHandlers, $handler;
        }
        $session->config->set( "contentHandlers", \@newHandlers );
    }
    
    #Add the settings for the profile module
    $setting->add("profileStyleTemplateId",""); #Use the userStyle by default
    $setting->add("profileLayoutTemplateId","N716tpSna0iIQTKxS4gTWA");
    $setting->add("profileEditLayoutTemplateId","FJbUTvZ2nUTn65LpW6gjsA"); 
    $setting->add("profileEditTemplateId","75CmQgpcCSkdsL-oawdn3Q");
    $setting->add("profileViewTempalteId","2CS-BErrjMmESOtGT90qOg");
    $setting->add("profileErrorTempalteId","MBmWlA_YEA2I6D29OMGtRg");

    #Add the settings for the inbox module
    $setting->add("inboxStyleTemplateId",""); #Use the userStyle by default
    $setting->add("inboxLayoutTempalteId","N716tpSna0iIQTKxS4gTWA");
    $setting->add("inboxViewTemplateId","c8xrwVuu5QE0XtF9DiVzLw");
    $setting->add("inboxViewMessageTemplateId","0n4HtbXaWa_XJHkFjetnLQ");
    $setting->add("inboxSendMessageTemplateId","6uQEULvXFgCYlRWnYzZsuA");
    $setting->add("inboxErrorTemplateId","ErEzulFiEKDkaCDVmxUavw");
    $setting->add("inboxMessageConfirmationTemplateId","DUoxlTBXhVS-Zl3CFDpt9g");
    #Invitations
    $setting->add("inboxManageInvitationsTemplateId","1Q4Je3hKCJzeo0ZBB5YB8g");
    $setting->add("inboxViewInvitationTemplateId","VBkY05f-E3WJS50WpdKd1Q");
    $setting->add("inboxInvitationConfirmTemplateId","5A8Hd9zXvByTDy4x-H28qw");

    #Add the settings for the friends module
    $setting->add("friendsStyleTemplateId",""); #Use the userStyle by default
    $setting->add("friendsLayoutTempalteId","N716tpSna0iIQTKxS4gTWA");
    $setting->add("friendsViewTemplateId","1Yn_zE_dSiNuaBGNLPbxtw");
    $setting->add("friendsEditTemplateId","AZFU33p0jpPJ-E6qLSWZng");
    $setting->add("friendsSendRequestTemplateId","AGJBGviWGAwjnwziiPjvDg");
    $setting->add("friendsErrorTemplateId","7Ijdd8SW32lVgg2H8R-Aqw");
    $setting->add("friendsConfirmTemplateId","K8F0j_cq_jgo8dvWY_26Ag");
    $setting->add("friendsRemoveConfirmTemplateId","G5V6neXIDiFXN05oL-U3AQ");

    #Add the settings for the user module
    $setting->add("userAccountStyleTemplateId",""); #Use the userStyle by default
    $setting->add("userAccountLayoutTemplateId","9ThW278DWLV0-Svf68ljFQ");

    #Add the settings for the shop module
    $setting->add("shopStyleTemplateId",""); #Use the userStyle by default
    $setting->add("shopLayoutTemplateId","aUDsJ-vB9RgP-AYvPOy8FQ");

    #Add inbox changes
    $session->db->write(q{
        create table inbox_messageState (
            messageId char(22) binary not null,
            userId char(22) binary not null,
            isRead tinyint(4) not null default 0,
            repliedTo tinyint(4) not null default 0,
            deleted tinyint(4) not null default 0,
            primary key (messageId, userId)
        )
    });

    #Update the inbox
    my $sth = $session->db->read("select messageId, groupId, userId, status from inbox");
    while(my ($messageId,$groupId,$userId,$status) = $sth->array) {
        my $repliedTo = $status eq "replied";
        my $isRead    = ($status ne "unread" && $status ne "pending")?1:0;
        my $deleted   = 0;

        if($status eq "deleted") {
            #Purge deleted messages
            $session->db->write("delete from inbox where messageId=?",[$messageId]);
            next;
        }

        if($groupId) {
            my $g     = WebGUI::Group->new($session,$groupId);
            my $users = $g->getAllUsers;
            foreach my $userId (@{$users}) {
                $session->db->write(
                    q{ REPLACE INTO inbox_messageState (messageId,userId,isRead,repliedTo,deleted) VALUES (?,?,?,?,?) },
                    [$messageId,$userId,$isRead,$repliedTo,$deleted]
                );
            }
        }

        if($userId) {
            $session->db->write(
                q{ REPLACE INTO inbox_messageState (messageId,userId,isRead,repliedTo,deleted) VALUES (?,?,?,?,?) },
                [$messageId,$userId,$isRead,$repliedTo,$deleted]
            );
        }

        if($status ne "completed" && $status ne "pending") {
            $session->db->write(
                q{ UPDATE inbox SET status='active' WHERE messageId=? },
                [$messageId]
            );
        }
    }

    #Add the profile field changes
    $session->db->write(q{alter table userProfileCategory add column shortLabel char(255) default NULL after label});
    $session->db->write(q{update userProfileCategory set shortLabel='WebGUI::International::get("misc info short","WebGUI");' where profileCategoryId='1'});
    $session->db->write(q{update userProfileCategory set shortLabel='WebGUI::International::get("contact info short","WebGUI");' where profileCategoryId='2'});
    $session->db->write(q{update userProfileCategory set shortLabel='WebGUI::International::get("personal info short","WebGUI");' where profileCategoryId='3'});
    $session->db->write(q{update userProfileCategory set shortLabel='WebGUI::International::get("preferences short","WebGUI");' where profileCategoryId='4'});
    $session->db->write(q{update userProfileCategory set shortLabel='WebGUI::International::get("home info short","WebGUI");' where profileCategoryId='5'});
    $session->db->write(q{update userProfileCategory set shortLabel='WebGUI::International::get("work info short","WebGUI");' where profileCategoryId='6'});
    $session->db->write(q{update userProfileCategory set shortLabel='WebGUI::International::get("demographic info short","WebGUI");' where profileCategoryId='7'});

    $session->db->write(q{alter table userProfileData modify publicProfile char(10) default 'none'});
    $session->db->write(q{update userProfileData set publicProfile='none' where publicProfile='0' || publicProfile is NULL || publicProfile=''});
    $session->db->write(q{update userProfileData set publicProfile='all' where publicProfile='1'});
    $session->db->write(q{REPLACE INTO `userProfileField` VALUES ('publicProfile','WebGUI::International::get(861)',1,0,'RadioList','{ all=>WebGUI::International::get(\'public label\',\'Account_Profile\'), friends=>WebGUI::International::get(\'friends only label\',\'Account_Profile\'), none=>WebGUI::International::get(\'private label\',\'Account_Profile\')}','[\"none\"]',8,'4',1,1,0,0,0,'')})
    

    #Clean up old templates and settings
    my $oldtemplates = {
        editUserProfileTemplate      => 'Operation/Profile/Edit',
        viewUserProfileTemplate      => 'Operation/Profile/View',
        manageFriendsTemplateId      => 'friends/manage',
        sendPrivateMessageTemplateId => 'Inbox/SendPrivateMessage',
        viewInboxTemplateId          => 'Inbox',
        viewInboxMessageTemplateId   => 'Inbox/Message',
    };

    foreach my $setting (keys %{$oldtemplates}) {
        #Remove the setting
        $session->db->write("delete from settings where name=?",[$setting]);
        #Remove all the templates with the related namespace
        my $assets = $session->db->buildArrayRef("select distinct assetId from template where namespace=?",[$oldtemplates->{$setting}]);
        #Purge the template
        foreach my $assetId (@{$assets}) {
            WebGUI::Asset->newByDynamicClass($session,$assetId)->purge;
        }
    }
    
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# installDataTableAsset
# Install the asset by creating the DB table and adding it to the config file
sub installDataTableAsset {
    my $session     = shift;
    print "\tInstalling the DataTable asset... " unless $quiet;

    $session->db->write( <<'ENDSQL' );
        CREATE TABLE DataTable ( 
            assetId VARCHAR(22) BINARY NOT NULL, 
            revisionDate BIGINT NOT NULL, 
            data LONGTEXT, 
            templateId VARCHAR(22) BINARY,
            PRIMARY KEY ( assetId, revisionDate ) 
        )
ENDSQL

    my $assets  = $session->config->get( "assets" );
    $assets->{ "WebGUI::Asset::Wobject::DataTable" } = { category => "basic" };
    $session->config->set( "assets", $assets );

    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# installDataTableAsset
# Install the content handler by adding it to the config file
sub installAjaxI18N {
    my $session     = shift;
    print "\tInstalling the AjaxI18N content handler... " unless $quiet;

    my $oldHandlers = $session->config->get( "contentHandlers" );
    my @newHandlers;
    for my $handler ( @{ $oldHandlers } ) {
        if ( $handler eq "WebGUI::Content::Operation" ) {
            push @newHandlers, "WebGUI::Content::AjaxI18N";
        }
        push @newHandlers, $handler;
    }
    $session->config->set( "contentHandlers", \@newHandlers );

    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub upgradeToYui26 {
    my $session = shift;
    print "\tUpgrading to YUI 2.6... " unless $quiet;
    $session->db->write("update template set template=replace(template, 'resize-beta.js', 'resize-min.js'), headBlock=replace(headBlock, 'resize-beta.js', 'resize-min.js')");
    $session->db->write("update template set template=replace(template, 'resize-beta-min.js', 'resize-min.js'), headBlock=replace(headBlock, 'resize-beta-min.js', 'resize-min.js')");
    $session->db->write("update template set template=replace(template, 'datasource-beta.js', 'datasource-min.js'), headBlock=replace(headBlock, 'datasource-beta.js', 'datasource-min.js')");
    $session->db->write("update template set template=replace(template, 'datasource-beta-min.js', 'datasource-min.js'), headBlock=replace(headBlock, 'datasource-beta-min.js', 'datasource-min.js')");
    $session->db->write("update template set template=replace(template, 'datatable-beta.js', 'datatable-min.js'), headBlock=replace(headBlock, 'datatable-beta.js', 'datatable-min.js')");
    $session->db->write("update template set template=replace(template, 'datatable-beta-min.js', 'datatable-min.js'), headBlock=replace(headBlock, 'datatable-beta-min.js', 'datatable-min.js')");
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub changeDefaultPaginationInSearch {
    my $session = shift;
    print "\tAllow content managers to change the default pagination in the search asset... " unless $quiet;
    $session->db->write("ALTER TABLE `search` ADD COLUMN `paginateAfter` INTEGER  NOT NULL DEFAULT 25");
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addUsersOnlineMacro {
    my $session = shift;
    print "\tMaking the UsersOnline macro available... " unless $quiet;
    $session->config->addToHash("macros","UsersOnline","UsersOnline");
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub updateAddressBook {
    my $session = shift;
    print "\tAdding organization and email to address book... " unless $quiet;
    my $db = $session->db;
    $db->write("alter table address add column organization char(255)");
    $db->write("alter table address add column email char(255)");
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub repairManageWorkflows {
    my $session = shift;
    print "\tCorrecting the Manage Workflow link in configuration file... " unless $quiet;
    # and here's our code
    my $ac = $session->config->get('adminConsole');
    if (exists $ac->{'workflow'}) {
        $ac->{'workflow'}->{'url'} = "^PageUrl(\"\",op=manageWorkflows);";
        $session->config->set('adminConsole', $ac);
    }
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addPreTextToThingyFields {
    my $session = shift;
    print "\tAdding a pre-text property to Thingy fields... " unless $quiet;
    $session->db->write('ALTER TABLE `Thingy_fields` ADD pretext varchar(255)');
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addProfileExtrasField {
    my $session = shift;
    print "\tAdding the Extras field for profile fields... " unless $quiet;
    my $db = $session->db;
    $db->write('alter table userProfileField add extras text default NULL');
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Add the workflow property to DataForm
sub addWorkflowToDataform {
    my $session     = shift;
    print "\tAdding Workflow to DataForm... " unless $quiet;

    my $sth = $session->db->read('DESCRIBE `DataForm`');
    while (my ($col) = $sth->array) {
        if ( $col eq 'workflowIdAddEntry' ) {
            print "Already done, skipping.\n" unless $quiet;
            return;
        }
    }
     
    $session->db->write( "ALTER TABLE DataForm ADD COLUMN workflowIdAddEntry CHAR(22) BINARY" );
    print "DONE!\n" unless $quiet;
}

# -------------- DO NOT EDIT BELOW THIS LINE --------------------------------

#----------------------------------------------------------------------------
# Add a package to the import node
sub addPackage {
    my $session     = shift;
    my $file        = shift;

    # Make a storage location for the package
    my $storage     = WebGUI::Storage->createTemp( $session );
    $storage->addFileFromFilesystem( $file );

    # Import the package into the import node
    my $package = WebGUI::Asset->getImportNode($session)->importPackage( $storage );

    # Make the package not a package anymore
    $package->update({ isPackage => 0 });
    
    # Set the default flag for templates added
    my $assetIds
        = $package->getLineage( ['self','descendants'], {
            includeOnlyClasses  => [ 'WebGUI::Asset::Template' ],
        } );
    for my $assetId ( @{ $assetIds } ) {
        my $asset   = WebGUI::Asset->newByDynamicClass( $session, $assetId );
        if ( !$asset ) {
            print "Couldn't instantiate asset with ID '$assetId'. Please check package '$file' for corruption.\n";
            next;
        }
        $asset->update( { isDefault => 1 } );
    }

    return;
}

#-------------------------------------------------
sub start {
    my $configFile;
    $|=1; #disable output buffering
    GetOptions(
        'configFile=s'=>\$configFile,
        'quiet'=>\$quiet
    );
    my $session = WebGUI::Session->open($webguiRoot,$configFile);
    $session->user({userId=>3});
    my $versionTag = WebGUI::VersionTag->getWorking($session);
    $versionTag->set({name=>"Upgrade to ".$toVersion});
    return $session;
}

#-------------------------------------------------
sub finish {
    my $session = shift;
    updateTemplates($session);
    my $versionTag = WebGUI::VersionTag->getWorking($session);
    $versionTag->commit;
    $session->db->write("insert into webguiVersion values (".$session->db->quote($toVersion).",'upgrade',".$session->datetime->time().")");
    $session->close();
}

#-------------------------------------------------
sub updateTemplates {
    my $session = shift;
    return undef unless (-d "packages-".$toVersion);
    print "\tUpdating packages.\n" unless ($quiet);
    opendir(DIR,"packages-".$toVersion);
    my @files = readdir(DIR);
    closedir(DIR);
    my $newFolder = undef;
    $session->db->write( "UPDATE asset SET parentId='infinityandbeyond' WHERE assetId='pbversion0000000000001'" );
    foreach my $file (@files) {
        next unless ($file =~ /\.wgpkg$/);
        # Fix the filename to include a path
        $file       = "packages-" . $toVersion . "/" . $file;
        addPackage( $session, $file );
    }
}

#vim:ft=perl
