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


my $toVersion = "photogallery"; # make this match what version you're going to
my $quiet; # this line required


my $session = start(); # this line required

# upgrade functions go here
installGalleryAsset($session);
installGalleryAlbumAsset($session);
installPhotoAsset($session);

finish($session); # this line required


##-------------------------------------------------
#sub exampleFunction {
#	my $session = shift;
#	print "\tWe're doing some stuff here that you should know about.\n" unless ($quiet);
#	# and here's our code
#}

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
    imageViewCompression INT,
    imageThumbnailSize INT,
    maxSpacePerUser VARCHAR(20),
    richEditIdFileComment VARCHAR(22) BINARY,
    templateIdAddArchive VARCHAR(22) BINARY,
    templateIdDeleteAlbum VARCHAR(22) BINARY,
    templateIdDeleteFile VARCHAR(22) BINARY,
    templateIdEditFile VARCHAR(22) BINARY,
    templateIdListAlbums VARCHAR(22) BINARY,
    templateIdListAlbumsRss VARCHAR(22) BINARY,
    templateIdListUserFiles VARCHAR(22) BINARY,
    templateIdListUserFilesRss VARCHAR(22) BINARY,
    templateIdMakeShortcut VARCHAR(22) BINARY,
    templateIdSearch VARCHAR(22) BINARY,
    templateIdSlideshow VARCHAR(22) BINARY,
    templateIdThumbnails VARCHAR(22) BINARY,
    templateIdViewAlbum VARCHAR(22) BINARY,
    templateIdViewAlbumRss VARCHAR(22) BINARY,
    templateIdViewFile VARCHAR(22) BINARY,
    workflowIdCommit VARCHAR(22) BINARY,
    PRIMARY KEY (assetId, revisionDate)
)
ENDSQL
    
    

    print "DONE!\n" unless $quiet;
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
    othersCanAdd INT,
    allowComments INT,
    PRIMARY KEY (assetId, revisionDate)
)
ENDSQL

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
    friendsOnly INT,
    rating INT,
    storageIdPhoto VARCHAR(22) BINARY,
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



