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
use File::Path;

my $toVersion = "6.9.0"; # make this match what version you're going to
my $quiet; # this line required


my $session = start(); # this line required

templateParsers();
removeFiles();
addSearchEngine();

finish($session); # this line required


#-------------------------------------------------
sub addSearchEngine {
	print "\tUpgrading search engine.\n" unless ($quiet);
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
	$session->db->write("alter table template add column parser varchar(255) not null default 'WebGUI::Asset::Template::HTMLTemplate'");
}

#-------------------------------------------------
sub removeFiles {
	print "\tRemoving old unneeded files.\n" unless ($quiet);
	unlink '../../lib/WebGUI/ErrorHandler.pm';
	unlink '../../lib/WebGUI/HTTP.pm';
	unlink '../../lib/WebGUI/Privilege.pm';
	unlink '../../lib/WebGUI/DateTime.pm';
	unlink '../../lib/WebGUI/FormProcessor.pm';
	unlink '../../lib/WebGUI/URL.pm';
	unlink '../../lib/WebGUI/Id.pm';
	unlink '../../lib/WebGUI/Icon.pm';
	unlink '../../lib/WebGUI/Style.pm';
	unlink '../../lib/WebGUI/Setting.pm';
	unlink '../../lib/WebGUI/Grouping.pm';
	unlink '../../lib/WebGUI/Asset/Wobject/IndexedSearch.pm';
	unlink '../../lib/WebGUI/Help/Asset_IndexedSearch.pm';
	unlink '../../lib/WebGUI/i18n/Asset_IndexedSearch.pm';
	unlink '../../sbin/Hourly/IndexedSearch_buildIndex.pm';
	rmtree('../../lib/WebGUI/Asset/Wobject/IndexedSearch');
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
	$session->close();
}

