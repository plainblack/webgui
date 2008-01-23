#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
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

addIsExportable($session);
updateTemplates($session);
addUrlAndContentHandlers($session);
addFriendsNetwork($session);
addSearchWithContainers($session);
addGroupToEditPost($session);
installGalleryAsset($session);
installGalleryAlbumAsset($session);
installPhotoAsset($session);

createEvent_relatedlinkTable($session);
updateRelatedLinkData($session);
alterEventTableForSequence($session);
populateSequenceNumbers($session);

finish($session); # this line required


#-------------------------------------------------
sub addUrlAndContentHandlers {
    my $session = shift;
    print "\tAdding pluggable URL and content handlers." unless $quiet;
    my $config = $session->config;
    my @urlHandlers = (
    { "^/extras" => "WebGUI::URL::PassThru" },
    { "^/uploads/dictionaries" => "WebGUI::URL::Unauthorized" },
    { "^/uploads" => "WebGUI::URL::Uploads" },
    { '^/\*give-credit-where-credit-is-due\*$' => "WebGUI::URL::Credits" },
    { '^/abcdefghijklmnopqrstuvwxyz$' => "WebGUI::URL::Snoop" },
    { ".*" => "WebGUI::URL::Content" }
        );
    my $passthrus = $config->get("passthruUrls");
    if (defined $passthrus) {
        foreach my $url (@{$passthrus}) {
            unshift @urlHandlers, { "^".$url => "WebGUI::URL::PassThru" };
        }
    }
    $config->set("urlHandlers", \@urlHandlers);
    $config->set("contentHandlers" , [
    "WebGUI::Content::Prefetch",
    "WebGUI::Content::Maintenance",
    "WebGUI::Content::Operation",
    "WebGUI::Content::Setup",
    "WebGUI::Content::Asset",
    "WebGUI::Content::NotFound"
    ]);
    $config->delete("passthruUrls");
    unlink "../../lib/WebGUI/Setup.pm";
    print "DONE!\n" unless $quiet;
}

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

#----------------------------------------------------------------------------
# Install the GalleryAlbum asset
sub installGalleryAlbumAsset {
    my $session     = shift;
    print "\tInstalling GalleryAlbum asset..." unless $quiet;
    
    $session->db->write(<<'ENDSQL');
CREATE TABLE IF NOT EXISTS GalleryAlbum (
    assetId VARCHAR(22) BINARY NOT NULL,
    revisionDate BIGINT NOT NULL,
    allowComments INT,
    assetIdThumbnail VARCHAR(22) BINARY,
    userDefined1 TEXT,
    userDefined2 TEXT,
    userDefined3 TEXT,
    userDefined4 TEXT,
    userDefined5 TEXT,
    othersCanAdd INT,
    PRIMARY KEY (assetId, revisionDate)
)
ENDSQL

    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Install the Gallery asset
sub installGalleryAsset {
    my $session     = shift;
    print "\tInstalling Gallery asset..." unless $quiet;

    $session->db->write(<<'ENDSQL');
CREATE TABLE IF NOT EXISTS Gallery (
    assetId VARCHAR(22) BINARY NOT NULL,
    revisionDate BIGINT NOT NULL,
    groupIdAddComment VARCHAR(22) BINARY,
    groupIdAddFile VARCHAR(22) BINARY,
    groupIdModerator VARCHAR(22) BINARY,
    imageResolutions TEXT,
    imageViewSize INT,
    imageThumbnailSize INT,
    maxSpacePerUser VARCHAR(20),
    richEditIdComment VARCHAR(22) BINARY,
    templateIdAddArchive VARCHAR(22) BINARY,
    templateIdDeleteAlbum VARCHAR(22) BINARY,
    templateIdDeleteFile VARCHAR(22) BINARY,
    templateIdEditAlbum VARCHAR(22) BINARY,
    templateIdEditFile VARCHAR(22) BINARY,
    templateIdListAlbums VARCHAR(22) BINARY,
    templateIdListAlbumsRss VARCHAR(22) BINARY,
    templateIdListFilesForUser VARCHAR(22) BINARY,
    templateIdListFilesForUserRss VARCHAR(22) BINARY,
    templateIdMakeShortcut VARCHAR(22) BINARY,
    templateIdSearch VARCHAR(22) BINARY,
    templateIdViewSlideshow VARCHAR(22) BINARY,
    templateIdViewThumbnails VARCHAR(22) BINARY,
    templateIdViewAlbum VARCHAR(22) BINARY,
    templateIdViewAlbumRss VARCHAR(22) BINARY,
    templateIdViewFile VARCHAR(22) BINARY,
    viewAlbumAssetId VARCHAR(22),
    viewDefault ENUM('album','list'),
    viewListOrderBy VARCHAR(40),
    viewListOrderDirection ENUM('ASC','DESC'),
    workflowIdCommit VARCHAR(22) BINARY,
    PRIMARY KEY (assetId, revisionDate)
)
ENDSQL
    
    $session->config->addToArray("assets","WebGUI::Asset::Wobject::Gallery");

    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Install the photo asset
sub installPhotoAsset {
    my $session     = shift;
    print "\tInstalling Photo asset..." unless $quiet;

    # Photo Asset
    $session->db->write(<<'ENDSQL');
CREATE TABLE IF NOT EXISTS Photo (
    assetId VARCHAR(22) BINARY NOT NULL,
    revisionDate BIGINT NOT NULL,
    exifData LONGTEXT,
    friendsOnly INT,
    location VARCHAR(255),
    rating INT,
    userDefined1 TEXT,
    userDefined2 TEXT,
    userDefined3 TEXT,
    userDefined4 TEXT,
    userDefined5 TEXT,
    PRIMARY KEY (assetId, revisionDate)
)
ENDSQL
    
    $session->db->write(<<'ENDSQL');
CREATE TABLE IF NOT EXISTS Photo_comment (
    assetId VARCHAR(22) BINARY NOT NULL,
    commentId VARCHAR(22) BINARY NOT NULL,
    userId VARCHAR(22) BINARY,
    visitorIp VARCHAR(255),
    creationDate DATETIME,
    bodyText LONGTEXT,
    INDEX (commentId),
    PRIMARY KEY (assetId, commentId)
)
ENDSQL
   
    $session->db->write(<<'ENDSQL');
CREATE TABLE IF NOT EXISTS Photo_rating (
    assetId VARCHAR(22) BINARY NOT NULL,
    userId VARCHAR(22) BINARY,
    visitorIp VARCHAR(255),
    rating INT,
    INDEX (assetId)
)
ENDSQL
    
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Add the isExportable property for all assets
sub addIsExportable {
    my $session = shift;
    print "\tAdding isExportable flag for all assets (fine-grained export control)..." unless $quiet;
    $session->db->write('alter table assetData add column isExportable int(11) not null default 1');
    print "DONE!\n" unless $quiet;
}

#--------------------------------------------------------------------------
# Populate the initial sequence numbers
sub populateSequenceNumbers {
    my $session = shift;

    my $dbh = $session->db->dbh;

    my $seed = 16384;
    my $curr_seed = 32768;

    my $sql =<<SQL_END;
SELECT DISTINCT Event.assetId 
 FROM Event
 ORDER BY Event.startDate, Event.startTime, Event.endDate, Event.endTime, Event.assetId
SQL_END
    my $ar_assetIds = $dbh->selectcol_arrayref($sql);

    for my $assetId (@$ar_assetIds) {
	my ($event) = $dbh->selectrow_hashref("SELECT revisionDate FROM Event WHERE assetId = ? ORDER BY revisionDate DESC LIMIT 1",undef,$assetId);

	$dbh->do("UPDATE Event SET sequenceNumber = ? WHERE assetId = ? AND revisionDate = ?",{},$curr_seed,$assetId,$event->{revisionDate});

	$curr_seed += $seed;
    }
    $dbh->do("UPDATE Calendar SET sortEventsBy = 'sequenceNumber'");
}

#--------------------------------------------------------------------------
# Create event relatedlink table
sub createEvent_relatedlinkTable {
    my $session = shift;
    print "\tCreate Event_relatedlink table.\n" unless $quiet;

    my $sql =<<SQL_END;
CREATE TABLE Event_relatedlink (
  eventlinkId VARCHAR(22) NOT NULL,
  assetId VARCHAR(22) NOT NULL,
  linkURL TINYTEXT,
  linktext VARCHAR(80),
  groupIdView VARCHAR(22) NOT NULL,
  sequenceNumber BIGINT(20) DEFAULT NULL
)
SQL_END

    $session->db->write($sql) or die "Failed to create Event_relatedlink table\n";
}

#-----------------------------------------------------------------------------
# Update the related links from the Event table to Event_relatedlink
sub updateRelatedLinkData {
    my $session = shift;
    use HTML::Parser;

    my $p = HTML::Parser->new(api_version =>3);

    print "\tConverting Related Links from Event table to Event_relatedlink table\n" unless $quiet;

    my $sth = $session->db->read("SELECT Event.assetId,relatedLinks,groupIdView FROM Event,assetData WHERE Event.assetId = assetData.assetId order by Event.revisionDate desc");
    $sth->execute;
    my (%asset_used, %event_asset_of, %snippet_asset_of);

    while (my ($assetId, $relatedLinks, $groupIdView) = $sth->array) {

        if (defined $asset_used{$assetId}) {
#	    print "\tAlready defined\n";
#	    print "$assetId, $relatedLinks\n";
	    next;
        }
#	print "\n\tUsing\n";
#	print "$assetId, $relatedLinks\n";

	$asset_used{$assetId} = $groupIdView;

	$event_asset_of{$assetId} = parse_html_to_link($p, $relatedLinks);
#	print Dumper ( $event_asset_of{ $assetId } )."\n";
	$p->eof;
    }

    # Scan all records for active AssetProxy macros and convert them to a
    #   Real url / display text pair.
    #
    for my $assetId (keys %event_asset_of) {
	for my $hr (@{$event_asset_of{$assetId}}) {
	    next unless ($hr->{url} =~ /AssetProxy/);

	    $hr->{text} =~ s/^\///;
#	    print "*** NEW ***\n".$hr->{text}."\n";
	    my ($assetId_snippet, $groupIdView) = $session->db->quickArray("SELECT assetId, groupIdView FROM assetData WHERE url = ? ORDER BY revisionDate DESC LIMIT 1",[$hr->{text}]);
	    
	    unless ($assetId_snippet) {
		delete $event_asset_of{$assetId};
		next;
	    }
	    $asset_used{$assetId_snippet} = $groupIdView;

	    my ($snippet) = $session->db->quickArray("SELECT snippet FROM snippet WHERE assetId = ? ORDER BY revisionDate DESC LIMIT 1",[$assetId_snippet]);
#	    print "\tsnippetId: ($assetId_snippet), assetId($assetId):\n$snippet\n";
	    my $links = parse_html_to_link($p, $snippet);
#	    print $assetId.":\n".Dumper ($links)."\n";
	    for (@$links) {
		push @{$snippet_asset_of{$assetId}{$assetId_snippet}}, $_;
	    }
	    $hr = undef;
	}
    }

    # Extracted data now stored as Event_relatedlink rows
    my $sql =<<SQL_END;
INSERT INTO Event_relatedlink 
(assetId,groupIdView,linkurl,linktext,sequenceNumber,eventlinkId)
VALUES (?,?,?,?,?,?)
SQL_END
    for my $assetId (keys %event_asset_of) {
	for my $a_idx (0..@{$event_asset_of{$assetId}}) {
	    my $eventlinkId = $session->id->generate();
	    next unless (defined (my $hr_link = $event_asset_of{$assetId}[$a_idx]));
	    my $groupToView = $asset_used{$assetId};

#	  printf "'%s', '%s', '%s',  '%s', '%s', '%s'\n",$assetId,$groupToView,$hr_link->{url},$hr_link->{text},$a_idx+1,$eventlinkId; 
	    $session->db->write($sql,[$assetId,$groupToView,$hr_link->{url},$hr_link->{text},$a_idx+1,$eventlinkId]);
        }
    }
#    print "Snippets\n";
    for my $assetId (keys %snippet_asset_of) {
	my $hrs_asset_of = \%{$snippet_asset_of{$assetId}};
#	print "\tEvent: $assetId\n";
#	print Dumper ($hrs_asset_of)."\n";
	for my $s_assetId (keys %$hrs_asset_of) {
#	    print "\t\tSnippet: $s_assetId\n";
	    for my $a_idx (0..@{$hrs_asset_of->{$s_assetId}}) {
#	      print "\t\t\tIDX: $a_idx\n";
		my $eventlinkId = $session->id->generate();
		next unless (defined (my $hr_link = $hrs_asset_of->{$s_assetId}[$a_idx]));
		my $groupToView = $asset_used{$s_assetId};
		
#	    printf "'%s', '%s', '%s',  '%s', '%s', '%s'\n",$assetId,$groupToView,$hr_link->{url},$hr_link->{text},$a_idx+1,$eventlinkId; 
		$session->db->write($sql,[$assetId,$groupToView,$hr_link->{url},$hr_link->{text},$a_idx+1,$eventlinkId]);
	    }
	}
    }
    return;
}

#-----------------------------------------------------------------------------
# Alter the Event table to add the Sequence Number field
sub alterEventTableForSequence {
    my $session = shift;

    print "\tAdding sequenceNumber to Event table.\n" unless $quiet;
    my $sql =<<SQL_END;
ALTER TABLE Event ADD sequenceNumber BIGINT(20) DEFAULT NULL
SQL_END

    $session->db->write($sql) or die "Failed to modify Event table\n";

    $sql =<<SQL_END;
ALTER TABLE Calendar ADD sortEventsBy ENUM('time','sequencenumber') DEFAULT 'time'
SQL_END
    $session->db->write($sql) or die "Failed to modify Calendar table\n";
}

########
# Convert HTML::Parser output to something useful
#  Results in a array of hashrefs with keys 'url' and 'text'
# 
sub parse_html_to_link {
    my ($p, $rl, $verbose) = @_;

    $rl =~ s/<\/a\>\s*<a\s/<\/a\><br \/><a/gm;

    my @result;
    $p->handler( start => \@result, 'attr' );
    $p->handler( text => \@result, 'text' );
    $p->parse($rl."<br />");
    if ($verbose) { 
        print "=========================================\n";
        print Dumper (@result)."\n";
        print "------\n";
    }

    my (@text, @links, $key);
    for (@result) {
	if (ref ($_->[0]) ne "HASH") {
	    if ($_->[0] =~ /^\^AssetProxy/) {
		push @text, $_->[0];
		push @links, link_to_hashref('', \@text);
	    }
	    elsif ($_->[0] =~ /\w/) {
		push @text, $_->[0]; 
	    }
	}
	else {
	    if ($_->[0]->{href}) {
		$key = $_->[0]->{href};
	    }
	    else {
		push @links, link_to_hashref($key, \@text);
	    }
	}
    }
    return \@links;
}

########
# Given a key (URL) and an array_ref containing strings
#   build a hash value according to certain rules
# 
sub link_to_hashref {
    my ($key, $ar_text) = @_;

    return unless $ar_text->[0];
    my %h;
    if ($key) {
        # Both hash key and values provided
	$h{url} = $key;
	$h{text} = (join "&nbsp;",@$ar_text) || $key;
	$key = '';
    }
    elsif ($ar_text->[0] =~ /^\//) {
        # Only a file reference is provided
	$h{url} = join "&nbsp;",@$ar_text;
	$h{text} = join "&nbsp;",@$ar_text;
    }
    elsif ($ar_text->[0] =~ /^\^AssetProxy\(([^\)]+)\)/) {
        # Snippet macro provided
	$h{text} = $1;
	$h{url} = 'AssetProxy';
    }
    
    # prevent surprise array expansion
    @$ar_text = ();

    return \%h;
}




# --------------- DO NOT EDIT BELOW THIS LINE --------------------------------

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
}

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
    return undef unless (-d "packages-".$toVersion);
    print "\tUpdating packages.\n" unless ($quiet);
    opendir(DIR,"packages-".$toVersion);
    my @files = readdir(DIR);
    closedir(DIR);
    my $newFolder = undef;
    foreach my $file (@files) {
        next unless ($file =~ /\.wgpkg$/);
        $file       = "packages-" . $toVersion . "/" . $file;
        addPackage( $session, $file );
    }
}

