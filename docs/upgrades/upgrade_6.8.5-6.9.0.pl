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
addEMSTemplates();
addEMSTables();
updateTemplates();
updateDatabaseLinksAndSQLReport();

finish($session); # this line required

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
	opendir(DIR,"templates-6.9.0");
	my @files = readdir(DIR);
	closedir(DIR);
	my $importNode = WebGUI::Asset->getImportNode($session);
	my $folder = $importNode->addChild({
		className=>"WebGUI::Asset::Wobject::Folder",
		title => "6.9.0 New Templates",
		menuTitle => "6.9.0 New Templates",
		url=> "6_9_0_new_templates",
		groupIdView=>"12"
		});
	$folder->commit;
	foreach my $file (@files) {
		next unless ($file =~ /\.tmpl$/);
		open(FILE,"<templates-6.9.0/".$file);
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
			sleep(1);
			my $template = $folder->addChild(\%properties, $properties{id});
			$template->commit;
		} else {
			sleep(1);
			my $template = WebGUI::Asset->new($session,$properties{id}, "WebGUI::Asset::Template");
			if (defined $template) {
				my $newRevision = $template->addRevision(\%properties);
				$newRevision->commit;
			}
		}
	}
}

#-------------------------------------------------
sub addEMSTemplates {
        print "\tAdding Event Management System Templates.\n" unless ($quiet);
my $template = <<EOT1;
<a name="id<tmpl_var assetId>" id="id<tmpl_var assetId>"></a>

<tmpl_if session.var.adminOn>
        <p><tmpl_var controls></p>
</tmpl_if>

EOT1
        my $in = WebGUI::Asset->getImportNode($session);
        $in->addChild({
                 className=>'WebGUI::Asset::Template',
                 template=>$template,
                 namespace=>'EventManagementSystem',
                 }, "EventManagerTmpl000001"
        );
}

#-------------------------------------------------
sub addEMSTables {

        print "\t Creating Event Management System tables.\n" unless ($quiet);

my $sql1 = <<SQL1;

create table EventManagementSystem (
 assetId varchar(22) not null,
 revisionDate bigint(20) not null,
 displayTemplateId varchar(22),
 paginateAfter int(11) default 10,
 groupToAddEvents varchar(22),
 groupToApproveEvents varchar(22),
 globalPrerequisites tinyint default 1,
primary key(assetId,revisionDate)
)
SQL1

my $sql2 = <<SQL2;

create table EventManagementSystem_products (
 productId varchar(22) not null,
 assetId varchar(22),
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
 registrationId varchar(22) not null,
 productId varchar(22),
 purchaseId varchar(22),
 firstName varchar(100),
 lastName varchar(100),
 address varchar(100),
 city varchar(100),
 state varchar(50),
 zipCode varchar(15),
 country varchar(255),
 phone varchar(50),
 email varchar(255),
primary key(registrationId)
)
SQL3

my $sql4 = <<SQL4;

create table EventManagementSystem_purchases (
 purchaseId varchar(22) not null,
 userId varchar(22),
primary key(purchaseId)
)
SQL4

my $sql5 = <<SQL5;

create table EventManagementSystem_prerequisites (
 prerequisiteId varchar(22) not null,
 productId varchar(22),
 operator varchar(100),
primary key(prerequisiteId)
)
SQL5

my $sql6 = <<SQL6;

create table EventManagementSystem_prerequisiteEvents (
 prerequisiteEventId varchar(22) not null,
 prerequisiteId varchar(22),
 requiredProductId varchar(22),
primary key(prerequisiteEventId)
)
SQL6

        $session->db->write($sql1);
        $session->db->write($sql2);
        $session->db->write($sql3);
        $session->db->write($sql4);
        $session->db->write($sql5);
        $session->db->write($sql6);

}

#-------------------------------------------------
sub addSearchEngine {
	print "\tUpgrading search engine.\n" unless ($quiet);
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
	unlink '../../lib/WebGUI/Mail.pm';
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

