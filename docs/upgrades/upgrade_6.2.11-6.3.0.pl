#!/usr/bin/perl

use lib "../../lib";
use FileHandle;
use File::Path;
use File::Copy;
use Getopt::Long;
use strict;
use WebGUI::Group;
use WebGUI::HTML;
use WebGUI::Id;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;


my $configFile;
my $quiet;

GetOptions(
    'configFile=s'=>\$configFile,
	'quiet'=>\$quiet
);

WebGUI::Session::open("../..",$configFile);

print "\tMerging Forum/Post and Forum/Thread templates.\n" unless ($quiet);
my %threadTemplates;
my $forums = WebGUI::SQL->read("select forumId, threadTemplateId, postTemplateId from forum where threadTemplateId<>'1' and postTemplateId<>'1'");
while (my ($forumId, $threadTemplateId, $postTemplateId) = $forums->array) {
	my $key = "Thread ".$threadTemplateId." | ".$postTemplateId;
	unless (exists $threadTemplates{$key}) {
		my ($threadTemplate) = WebGUI::SQL->quickArray("select template from template where namespace='Forum/Thread' and templateId=".quote($threadTemplateId));
		my ($postTemplate) = WebGUI::SQL->quickArray("select template from template where namespace='Forum/Post' and templateId=".quote($postTemplateId));
		$threadTemplate =~ s/\<tmpl_var\s+post\.full\s*\>/$postTemplate/ixsg;
		$threadTemplates{$key} = $threadTemplate;
	}
}
$forums->finish;
my ($defaultThreadTemplate) = WebGUI::SQL->quickArray("select template from template where namespace='Forum/Thread' and templateId='1'");
my ($defaultPostTemplate) = WebGUI::SQL->quickArray("select template from template where namespace='Forum/Post' and  templateId='1'");
$defaultThreadTemplate =~ s/\<tmpl_var\s+post\.full\s*\>/$defaultPostTemplate/ixsg;
$defaultThreadTemplate =~ '<p>^Navigation(crumbTrail);</p>'.$defaultThreadTemplate;
WebGUI::SQL->write("update template set template=".quote($defaultThreadTemplate)." where namespace='Forum/Thread' and templateId='1'");
WebGUI::SQL->write("delete from template where namespace='Forum/Post' or (namespace='Forum/Thread' and templateId<>'1')");
foreach my $key (%threadTemplates) {
	WebGUI::SQL->write("insert into template (templateId, namespace, template, name) values (".quote(WebGUI::Id::generate()).", 'Forum/Thread',
		".quote($threadTemplates{$key}).", ".quote($key).")");
}
WebGUI::SQL->write("update template set templateId='25' where templateId='1' and namespace in ('Forum','Forum/Thread','Forum/PostForm')");
WebGUI::SQL->write("update forum set forumTemplateId='25' where forumTemplateId='1'");
WebGUI::SQL->write("update forum set postFormTemplateId='25' where postFormTemplateId='1'");
WebGUI::SQL->write("update forum set threadTemplateId='25' where threadTemplateId='1'");
WebGUI::SQL->write("update template set templateId=concat('NNN',templateId) where templateId like '10%' and namespace in ('Forum','Forum/Thread','Forum/PostForm')");
WebGUI::SQL->write("update forum set forumTemplateId=concat('NNN',forumTemplateId) where forumTemplateId like '10%'");
WebGUI::SQL->write("update forum set postFormTemplateId=concat('NNN',postFormTemplateId) where postFormTemplateId like '10%'");
WebGUI::SQL->write("update forum set threadTemplateId=concat('NNN',threadTemplateId) where threadTemplateId like '10%'");



print "\tFixing navigation template variables.\n" unless ($quiet);
my $sth = WebGUI::SQL->read("select * from template where namespace in ('Navigation')");
while (my $data = $sth->hashRef) {
        $data->{template} =~ s/page.current/basepage/ig;
        $data->{template} =~ s/isMy/is/ig;
        $data->{template} =~ s/isCurrent/isBasepage/ig;
        $data->{template} =~ s/inCurrentRoot/inBranch/ig;
        WebGUI::SQL->write("update template set template=".quote($data->{template})." where namespace=".quote($data->{namespace})." and templateId=".quote($data->{templateId}));
}
$sth->finish;


print "\tMoving site icons into style templates.\n" unless ($quiet);
my $type = lc($session{setting}{siteicon});
$type =~ s/.*\.(.*?)$/$1/;
my $tags = '	
	<link rel="icon" href="'.$session{setting}{siteicon}.'" type="image/'.$type.'" />
	<link rel="SHORTCUT ICON" href="'.$session{setting}{favicon}.'" />
	<tmpl_var head.tags>
	';
$sth = WebGUI::SQL->read("select templateId,template from template where namespace='style'");
while (my ($id,$template) = $sth->array) {
	$template =~ s/\<tmpl_var head\.tags\>/$tags/ig;
	WebGUI::SQL->write("update template set template=".quote($template)." where templateId=".quote($id)." and namespace='style'");
}
$sth->finish;
WebGUI::SQL->write("delete from settings where name in ('siteicon','favicon')");


print "\tMigrating wobject templates to asset templates.\n" unless ($quiet);
my $sth = WebGUI::SQL->read("select templateId, template, namespace from template where namespace in ('Article', 
		'SyndicatedContent', 'MessageBoard', 'DataForm', 'EventsCalendar', 'HttpProxy', 'Poll', 'Product', 'WobjectProxy',
		'IndexedSearch', 'SQLReport', 'Survey', 'WSClient')");
while (my $t = $sth->hashRef) {
	$t->{template} = '<a name="<tmpl_var assetId>"></a>
<tmpl_if session.var.adminOn>
	<p><tmpl_var controls></p>
</tmpl_if>	
		'.$t->{template};
	WebGUI::SQL->write("update template set template=".quote($t->{template})." where templateId=".quote($t->{templateId})." and namespace=".quote($t->{namespace}));
}
$sth->finish;





print "\tConverting Pages, Wobjects, and Forums to Assets\n" unless ($quiet);
print "\t\tHold on cuz this is going to take a long time...\n" unless ($quiet);
print "\t\tMaking first round of table structure changes\n" unless ($quiet);
WebGUI::SQL->write("alter table wobject add column assetId varchar(22) not null");
WebGUI::SQL->write("alter table wobject add styleTemplateId varchar(22) not null");
WebGUI::SQL->write("alter table wobject add printableStyleTemplateId varchar(22) not null");
WebGUI::SQL->write("alter table wobject add cacheTimeout int not null default 60");
WebGUI::SQL->write("alter table wobject add cacheTimeoutVisitor int not null default 3600");
WebGUI::SQL->write("alter table metaData_values add assetId varchar(22) not null");
WebGUI::SQL->write("alter table wobject drop primary key");
WebGUI::SQL->write("alter table Poll_answer add column assetId varchar(22)");
WebGUI::SQL->write("alter table DataForm_entry add column assetId varchar(22)");
WebGUI::SQL->write("alter table DataForm_entryData add column assetId varchar(22)");
WebGUI::SQL->write("alter table DataForm_field add column assetId varchar(22)");
WebGUI::SQL->write("alter table DataForm_tab add column assetId varchar(22)");
WebGUI::SQL->write("alter table Product_feature add assetId varchar(22) not null");
WebGUI::SQL->write("alter table Product_benefit add assetId varchar(22) not null");
WebGUI::SQL->write("alter table Product_specification add assetId varchar(22) not null");
WebGUI::SQL->write("alter table Product_accessory drop primary key");
WebGUI::SQL->write("alter table Product_accessory add assetId varchar(22) not null");
WebGUI::SQL->write("alter table Product_accessory add accessoryAssetId varchar(22) not null");
WebGUI::SQL->write("alter table Product_accessory add primary key (assetId,accessoryAssetId)");
WebGUI::SQL->write("alter table Product_related drop primary key");
WebGUI::SQL->write("alter table Product_related add assetId varchar(22) not null");
WebGUI::SQL->write("alter table Product_related add relatedAssetId varchar(22) not null");
WebGUI::SQL->write("alter table Product_related add primary key (assetId,relatedAssetId)");
WebGUI::SQL->write("alter table WobjectProxy add column description mediumtext");
WebGUI::SQL->write("alter table EventsCalendar change column isMaster scope integer not null default 0");
WebGUI::SQL->write("alter table EventsCalendar_event add column eventLocation text");
WebGUI::SQL->write("alter table EventsCalendar_event change column startDate eventStartDate bigint(20)");
WebGUI::SQL->write("alter table EventsCalendar_event change column endDate eventEndDate bigint(20)");
WebGUI::SQL->write("alter table EventsCalendar_event add column templateId varchar(22)");
WebGUI::SQL->write("alter table EventsCalendar_event add column assetId varchar(22) not null");
WebGUI::SQL->write("alter table EventsCalendar_event drop primary key");


# next 2 lines are for sitemap to nav migration
WebGUI::SQL->write("alter table Navigation rename tempoldnav");
WebGUI::SQL->write("create table Navigation (assetId varchar(22) not null primary key, assetsToInclude text, startType varchar(35), startPoint varchar(255), endPoint varchar(35), showSystemPages int not null default 0, showHiddenPages int not null default 0, showUnprivilegedPages int not null default 0, templateId varchar(22) not null)");
my @wobjects = qw(SiteMap Article Poll Survey USS WSClient DataForm FileManager EventsCalendar HttpProxy IndexedSearch MessageBoard Product SQLReport SyndicatedContent WobjectProxy);
my @otherWobjects = ();
my @temp = WebGUI::SQL->buildArray("select distinct(namespace) from wobject where namespace not in (".quoteAndJoin(\@wobjects).")");
foreach my $other (@temp) {
	my $test = WebGUI::SQL->unconditionalRead("select * from $other");
	if ($test->errorCode < 1) {
		push(@otherWobjects,$other);
	} else {
		print "\t\t WARNING: A wobject instance of $other exists in your database without a namespace table.\n" unless ($quiet);
	}
	$test->finish;
}
my @allWobjects = (@wobjects,@otherWobjects);
foreach my $namespace (@allWobjects) {
	WebGUI::SQL->write("alter table ".$namespace." add column assetId varchar(22) not null");
	if (isIn($namespace, @otherWobjects)) {
		my $test = WebGUI::SQL->unconditionalRead("select templateId from $namespace");
		if ($test->errorCode > 0) { # only add this if they don't already have it
			WebGUI::SQL->write("alter table ".$namespace." add column templateId varchar(22) not null");
		}
	} else {
		WebGUI::SQL->write("alter table ".$namespace." add column templateId varchar(22) not null");
	}
	my $sth = WebGUI::SQL->read("select wobjectId, templateId from wobject where namespace=".quote($namespace));
	while (my ($wid, $tid) = $sth->array) {
		WebGUI::SQL->write("update ".$namespace." set templateId=".quote($tid)." where wobjectId=".quote($wid));
	}
	$sth->finish;
}

walkTree('0','PBasset000000000000001','000001','2');
mapProductCollateral();

print "\t\tMaking second round of table structure changes\n" unless ($quiet);
WebGUI::SQL->write("alter table WobjectProxy add column shortcutToAssetId varchar(22) not null");
my $sth = WebGUI::SQL->read("select proxiedWobjectId from WobjectProxy");
while (my ($wobjectId) = $sth->array) {
	my ($assetId) = WebGUI::SQL->quickArray("select assetId from wobject where wobjectId=".quote($wobjectId));
	WebGUI::SQL->write("update WobjectProxy set shortcutToAssetId=".quote($assetId)." where wobjectId=".quote($wobjectId));
}
$sth->finish;
foreach my $namespace (@allWobjects) {
	if (isIn($namespace, qw(SiteMap USS FileManager))) {
		# do nothing because these are going away
	} elsif (isIn($namespace, @wobjects)) {
		WebGUI::SQL->write("delete from ".$namespace." where assetId is null or assetId = ''"); # protect ourselves from crap
		WebGUI::SQL->write("alter table ".$namespace." drop column wobjectId");
		WebGUI::SQL->write("alter table ".$namespace." add primary key (assetId)");
	} elsif (isIn($namespace, qw(Navigation Layout Collaboration Folder))) {
		# do nothing because these are new
	} else {
		WebGUI::SQL->write("delete from ".$namespace." where assetId is null or assetId = ''"); # protect ourselves from crap
		WebGUI::SQL->write("alter table ".$namespace." drop primary key");
		WebGUI::SQL->write("alter table ".$namespace." add primary key (assetId)");
	}
}
WebGUI::SQL->write("alter table WobjectProxy drop proxiedWobjectId");
WebGUI::SQL->write("alter table WobjectProxy change proxiedTemplateId overrideTemplateId varchar(22) not null");
WebGUI::SQL->write("alter table WobjectProxy change proxyByCriteria shortcutByCriteria int not null");
WebGUI::SQL->write("alter table WobjectProxy change proxyCriteria shortcutCriteria text not null");
WebGUI::SQL->write("alter table WobjectProxy rename Shortcut");
WebGUI::SQL->write("update asset set className='WebGUI::Asset::Shortcut' where className='WebGUI::Asset::Wobject::WobjectProxy'");
WebGUI::SQL->write("delete from wobject where assetId is null or assetId = ''"); # protect ourselves from crap
WebGUI::SQL->write("alter table wobject drop column wobjectId");
WebGUI::SQL->write("alter table wobject add primary key (assetId)");
WebGUI::SQL->write("alter table wobject drop column templateId");
WebGUI::SQL->write("alter table wobject drop column namespace");
WebGUI::SQL->write("alter table wobject drop column pageId");
WebGUI::SQL->write("alter table wobject drop column sequenceNumber");
WebGUI::SQL->write("alter table wobject drop column title");
WebGUI::SQL->write("alter table wobject drop column ownerId");
WebGUI::SQL->write("alter table wobject drop column groupIdEdit");
WebGUI::SQL->write("alter table wobject drop column groupIdView");
WebGUI::SQL->write("alter table wobject drop column userDefined1");
WebGUI::SQL->write("alter table wobject drop column userDefined2");
WebGUI::SQL->write("alter table wobject drop column userDefined3");
WebGUI::SQL->write("alter table wobject drop column userDefined4");
WebGUI::SQL->write("alter table wobject drop column userDefined5");
WebGUI::SQL->write("alter table wobject drop column templatePosition");
WebGUI::SQL->write("alter table wobject drop column bufferUserId");
WebGUI::SQL->write("alter table wobject drop column bufferDate");
WebGUI::SQL->write("alter table wobject drop column bufferPrevId");
WebGUI::SQL->write("alter table wobject drop column forumId");
WebGUI::SQL->write("alter table wobject drop column startDate");
WebGUI::SQL->write("alter table wobject drop column endDate");
WebGUI::SQL->write("alter table wobject drop column addedBy");
WebGUI::SQL->write("alter table wobject drop column dateAdded");
WebGUI::SQL->write("alter table wobject drop column editedBy");
WebGUI::SQL->write("alter table wobject drop column lastEdited");
WebGUI::SQL->write("alter table wobject drop column allowDiscussion");
WebGUI::SQL->write("alter table metaData_values drop column wobjectId");
WebGUI::SQL->write("drop table page");
WebGUI::SQL->write("drop table FileManager");
WebGUI::SQL->write("drop table FileManager_file");
WebGUI::SQL->write("delete from template where namespace in ('FileManager')");
WebGUI::SQL->write("drop table SiteMap");
WebGUI::SQL->write("delete from template where namespace in ('SiteMap')");
WebGUI::SQL->write("alter table Article drop column image");
WebGUI::SQL->write("alter table Article drop column attachment");
WebGUI::SQL->write("alter table Poll_answer drop column wobjectId");
WebGUI::SQL->write("alter table DataForm_entry drop column wobjectId");
WebGUI::SQL->write("alter table DataForm_entryData drop column wobjectId");
WebGUI::SQL->write("alter table DataForm_field drop column wobjectId");
WebGUI::SQL->write("alter table DataForm_tab drop column wobjectId");
WebGUI::SQL->write("alter table Product_accessory drop column wobjectId");
WebGUI::SQL->write("alter table Product_benefit drop column wobjectId");
WebGUI::SQL->write("alter table Product_feature drop column wobjectId");
WebGUI::SQL->write("alter table Product_related drop column wobjectId");
WebGUI::SQL->write("alter table Product_specification drop column wobjectId");
WebGUI::SQL->write("alter table Product_related drop column RelatedWobjectId");
WebGUI::SQL->write("alter table Product_accessory drop column AccessoryWobjectId");
WebGUI::SQL->write("delete from EventsCalendar_event where assetId is null or assetId = ''"); # protect ourselves from crap
WebGUI::SQL->write("alter table EventsCalendar_event add primary key (assetId)");
WebGUI::SQL->write("alter table EventsCalendar_event drop column name");
WebGUI::SQL->write("alter table EventsCalendar_event drop column wobjectId");

WebGUI::SQL->write("drop table forum");
WebGUI::SQL->write("drop table forumRead");
WebGUI::SQL->write("drop table forumPost");
WebGUI::SQL->write("drop table forumPostRating");
WebGUI::SQL->write("drop table forumPostAttachment");
WebGUI::SQL->write("drop table forumSubscription");
WebGUI::SQL->write("drop table forumThread");
WebGUI::SQL->write("drop table forumThreadSubscription");
WebGUI::SQL->write("drop table MessageBoard_forums");
WebGUI::SQL->write("drop table USS");
WebGUI::SQL->write("drop table USS_submission");

# start migrating non-wobject stuff into assets
my %migration;
WebGUI::SQL->write("insert into wobject (assetId, styleTemplateId, printableStyleTemplateId) values ('PBasset000000000000002','1','3')");
WebGUI::SQL->write("insert into Folder (assetId, templateId) values ('PBasset000000000000002','PBtmpl0000000000000078')");



print "\tConverting navigation system to asset tree\n" unless ($quiet);
my $navRootLineage = getNextLineage('PBasset000000000000002');
my $navRootId = WebGUI::SQL->setRow("asset","assetId",{
	assetId=>"new",
	isHidden=>1,
	title=>"Navigation Configurations",
	menuTitle=>"Navigation Configurations",
	url=>fixUrl('doesntexistyet',"Navigation Configurations"),
	ownerUserId=>"3",
	groupIdView=>"4",
	groupIdEdit=>"4",
	parentId=>"PBasset000000000000002",
	lineage=>$navRootLineage,
	lastUpdated=>time(),
	className=>"WebGUI::Asset::Wobject::Folder",
	state=>"published"
	});
WebGUI::SQL->setRow("wobject","assetId",{
	assetId=>$navRootId,
	styleTemplateId=>"1",
	printableStyleTemplateId=>"3"
	},undef,$navRootId);
WebGUI::SQL->setRow("Folder","assetId",{
	assetId=>$navRootId,
	templateId=>"PBtmpl0000000000000078"
	},undef,$navRootId);
my %macroCache;
my $navRankCounter = 1;
my $sth = WebGUI::SQL->read("select * from tempoldnav");
while (my $data = $sth->hashRef) {
	print "\t\tConverting ".$data->{identifier}."\n" unless ($quiet);
	my (%newNav,%newAsset,%newWobject);
	$newNav{assetId} = $newWobject{assetId} = $newAsset{assetId} = getNewId("nav",$data->{navigationId}); 
	$newAsset{url} = fixUrl($newAsset{assetId},$data->{identifier});
	$macroCache{$data->{identifier}} = $newAsset{url};
	$newAsset{isHidden} = 1;
	$newAsset{title} = $newAsset{menuTitle} = $data->{identifier};
	$newAsset{ownerUserId} = "3";
	$newAsset{groupIdView} = "7";
	$newAsset{groupIdEdit} = "4";
	$newAsset{className} = 'WebGUI::Asset::Wobject::Navigation';
	$newAsset{state} = 'published';
	$newAsset{lastUpdated} = time();
	$newAsset{parentId} = $navRootId;
	$newAsset{lineage} = $navRootLineage.sprintf("%06d",$navRankCounter);
	$newNav{templateId} = $data->{templateId};
	$newWobject{styleTemplateId}="1";
	$newWobject{printableStyleTemplateId}="3";
	$newWobject{displayTitle} = "0";
	$newNav{showSystemPages} = $data->{showSystemPages};
	$newNav{showHiddenPages} = $data->{showHiddenPages};
	$newNav{showUnprivilegedPages} = $data->{showUnprivilegedPages};
	if ($data->{startAt} eq "root") {
		$newNav{startType} = "relativeToRoot";
		$newNav{startPoint} = "0";
	} elsif ($data->{startAt} eq "WebGUIroot") {
		$newNav{startType} = "relativeToRoot";
		$newNav{startPoint} = "1";
	} elsif ($data->{startAt} eq "top") {
		$newNav{startType} = "relativeToRoot";
		$newNav{startPoint} = "2";
	} elsif ($data->{startAt} eq "grandmother") {
		$newNav{startType} = "relativeToCurrentUrl";
		$newNav{startPoint} = "-2";
	} elsif ($data->{startAt} eq "mother") {
		$newNav{startType} = "relativeToCurrentUrl";
		$newNav{startPoint} = "-1";
	} elsif ($data->{startAt} eq "current") {
		$newNav{startType} = "relativeToCurrentUrl";
		$newNav{startPoint} = "0";
	} elsif ($data->{startAt} eq "daughter") {
		$newNav{startType} = "relativeToCurrentUrl";
		$newNav{startPoint} = "1";
	} else {
		$newNav{startType} = "specificUrl";
		$newNav{startPoint} = $data->{startAt};
	}
	$newNav{endPoint} = (($data->{depth} == 99)?55:$data->{depth});
	if ($data->{method} eq "daughters") {
		$newNav{endPoint} = "1";
		$newNav{assetsToInclude} = "descendants";
	} elsif ($data->{method} eq "sisters") {
		$newNav{assetsToInclude} = "siblings";
	} elsif ($data->{method} eq "self_and_sisters") {
		$newNav{assetsToInclude} = "self\nsiblings";
	} elsif ($data->{method} eq "descendants") {
		$newNav{assetsToInclude} = "descendants";
	} elsif ($data->{method} eq "self_and_descendants") {
		$newNav{assetsToInclude} = "self\ndescendants";
	} elsif ($data->{method} eq "leaves_under") {
		$newNav{endPoint} = "1";
		$newNav{assetsToInclude} = "descendants";
	} elsif ($data->{method} eq "generation") {
		$newNav{assetsToInclude} = "self\nsisters";
	} elsif ($data->{method} eq "ancestors") {
		$newNav{endPoint} += $newNav{startPoint} unless ($newNav{startType} eq "specificUrl");
		$newNav{startType} = "relativeToRoot";
		$newNav{startPoint} = $data->{stopAtLevel}+1;
		$newNav{assetsToInclude} = "descendants";
	} elsif ($data->{method} eq "self_and_ancestors") {
		$newNav{endPoint} += $newNav{startPoint} unless ($newNav{startType} eq "specificUrl");
		$newNav{startType} = "relativeToRoot";
		$newNav{startPoint} = $data->{stopAtLevel}+1;
		$newNav{assetsToInclude} = "self\ndescendants";
	} elsif ($data->{method} eq "pedigree") {
		$newNav{endPoint} = 55;
		$newNav{startType} = "relativeToRoot";
		$newNav{startPoint} = 1;
		$newNav{assetsToInclude} = "pedigree";
	}
	WebGUI::SQL->setRow("asset","assetId",\%newAsset,undef,$newNav{assetId});
	WebGUI::SQL->setRow("wobject","assetId",\%newWobject,undef,$newNav{assetId});
	WebGUI::SQL->setRow("Navigation","assetId",\%newNav,undef,$newNav{assetId});
	$navRankCounter++;
}
$sth->finish;
WebGUI::SQL->write("update Navigation set startPoint='root' where startPoint='nameless_root'");
WebGUI::SQL->write("drop table tempoldnav");



print "\tConverting navigation templates\n" unless ($quiet);
my $sth = WebGUI::SQL->read("select templateId, template from template where namespace='Navigation'");
while (my ($id, $template) = $sth->array) {
	$template =~ s/isBasePage/isCurrent/isg;
	$template =~ s/basePage/currentPage/isg;
	$template =~ s/isRoot/isBranchRoot/isg;
	$template =~ s/inRoot/inBranchRoot/isg;
	$template =~ s/urlizedTitle/url/isg;
	$template =~ s/ownerId/ownerUserId/isg;
	$template =~ s/isTop/isTopOfBranch/isg;
	$template =~ s/isDaughter/isChild/isg;
	$template =~ s/isMother/isParent/isg;
	$template =~ s/isSister/isSibling/isg;
	$template =~ s/isLeftMost/isRankedFirst/isg;
	$template =~ s/isRightMost/isRankedLast/isg;
	$template =~ s/hasDaughter/hasChild/isg;
	$template =~ s/mother/parent/isg;
	$template =~ s/config\.button/controls/isg;
	$template =~ s/pageId/assetId/isg;
	$template = '
		<tmpl_if displayTitle>
		<h1><tmpl_var title></h1>
		</tmpl_if>
		<tmpl_if description>
			<p><tmpl_var description></p>
		</tmpl_if>
		'.$template;
	WebGUI::SQL->write("update template set template=".quote($template)." where templateId=".quote($id)." and namespace='Navigation'");
}
$sth->finish;




print "\tConverting collateral manager items into assets\n" unless ($quiet);
my $collateralRootLineage = getNextLineage('PBasset000000000000002');
my $collateralRootId = WebGUI::SQL->setRow("asset","assetId",{
	assetId=>"new",
	isHidden=>1,
	title=>"Files, Snippets, and Images",
	menuTitle=>"Files, Snippets, and Images",
	url=>fixUrl('doesntexistyet',"Collateral"),
	ownerUserId=>"3",
	groupIdView=>"4",
	groupIdEdit=>"4",
	parentId=>"PBasset000000000000002",
	lineage=>$collateralRootLineage,
	lastUpdated=>time(),
	className=>"WebGUI::Asset::Wobject::Folder",
	state=>"published"
	});
WebGUI::SQL->setRow("wobject","assetId",{
	assetId=>$collateralRootId,
	styleTemplateId=>"1",
	printableStyleTemplateId=>"3"
	},undef,$collateralRootId);
WebGUI::SQL->setRow("Navigation","assetId",{
	assetId=>$collateralRootId,
	templateId=>"PBtmpl0000000000000078"
	},undef,$collateralRootId);
my %folderCache = ('0'=>{id=>$collateralRootId,lineage=>$collateralRootLineage});
my %folderNameCache;
my $collateralRankCounter = 1;
my $sth = WebGUI::SQL->read("select * from collateralFolder where collateralFolderId <> '0'");
while (my $data = $sth->hashRef) {
	print "\t\tConverting folder ".$data->{collateralFolderId}."\n" unless ($quiet);
	my $url = fixUrl('doesntexist',$data->{name});
	$folderNameCache{$data->{name}} = $url;
	my $folderId = WebGUI::SQL->setRow("asset","assetId",{
		assetId=>"new",
		className=>'WebGUI::Asset::Layout',
		lineage=>$collateralRootLineage.sprintf("%06d",$collateralRankCounter),
		parentId=>$collateralRootId,
		ownerUserId=>'3',
		groupIdView=>'4',
		groupIdEdit=>'4',
		lastUpdated=>time(),
		title=>$data->{name},
		menuTitle=>$data->{name},
		url=>$url,
		state=>'published'
		});
	WebGUI::SQL->setRow("wobject","assetId",{
		assetId=>quote($folderId),
		styleTemplateId=>"1",
		printableStyleTemplateId=>"3",
		description=>$data->{description}
		},undef,$folderId);
	WebGUI::SQL->setRow("Layout","assetId",{
		templateId=>'15',
		assetId=>$folderId
		},undef,$folderId);
	$folderCache{$data->{collateralFolderId}} = {
		id=>$folderId,
		lineage=>$collateralRootLineage.sprintf("%06d",$collateralRankCounter)
		};
	$collateralRankCounter++;
}
$sth->finish;
my $lastCollateralFolderId = 'nolastid';
my ($parentId, $baseLineage);
my $sth = WebGUI::SQL->read("select * from collateral order by collateralFolderId");
while (my $data = $sth->hashRef) {
	print "\t\tConverting collateral item ".$data->{collateralId}." for folder ".$data->{collateralFolderId}."\n" unless ($quiet);
	unless ($lastCollateralFolderId eq $data->{collateralFolderId}) {
		my $id = $data->{collateralFolderId};
		$id = "0" unless (defined $id);
		$baseLineage = $folderCache{$id}{lineage};
		$parentId = $folderCache{$id}{id};
		$lastCollateralFolderId = $id;
	}
	my $class;
	my $collateralId = WebGUI::Id::generate();
	my $fileSize;
	if ($data->{collateralType} eq "file" || $data->{collateralType} eq "image") {
		my $storageId = copyFile($data->{filename},'images/'.$data->{collateralId});
		if (isIn(getFileExtension($data->{filename}), qw(jpg jpeg gif png))) {
			copyFile('thumb-'.$data->{filename},'images/'.$data->{collateralId},$storageId);
			WebGUI::SQL->write("insert into ImageAsset (assetId, parameters, thumbnailSize) values (".quote($collateralId).",
				".quote($data->{parameters}).", ".quote($data->{thumbnailSize}).")");
			$class = 'WebGUI::Asset::File::Image';
		} else {
			$class = 'WebGUI::Asset::File';
		}
		WebGUI::SQL->write("insert into FileAsset (assetId, filename, storageId) values (
			".quote($collateralId).", ".quote($data->{filename}).", ".quote($storageId).")");
		$fileSize = getFileSize($storageId,$data->{filename});
	} else {
		WebGUI::SQL->setRow("snippet","assetId",{
			assetId=>$collateralId,
			snippet=>$data->{parameters}
			},undef,$collateralId);
		$fileSize = length($data->{parameters});
	}
	my $url = fixUrl($collateralId,$data->{name});
	$macroCache{$data->{name}} = $macroCache{$data->{collateralId}} = $url;
	WebGUI::SQL->write("insert into asset (assetId, parentId, lineage, className, state, title, menuTitle, 
		url, ownerUserId, groupIdView, groupIdEdit, assetSize, lastUpdated) values (".
		quote($collateralId).", ".quote($parentId).", ".quote($baseLineage.sprintf("%06d",$collateralRankCounter)).", 
		'".$class."','published',".quote($data->{name}).", ".
		quote($data->{name}).", ".quote($url).", ".quote($data->{userId}).", 
		'7', '4', ".quote($fileSize).",".quote($data->{dateUploaded}).")");
	$collateralRankCounter++;
}
WebGUI::SQL->write("drop table collateralFolder");
WebGUI::SQL->write("drop table collateral");




print "\tMigrating forum templates to collaboration templates\n" unless ($quiet);
my $sth = WebGUI::SQL->read("select templateId,template,namespace from template where namespace in ('Forum','Forum/Thread','Forum/Notification', 'Forum/Search', 'Forum/PostForm')");
while (my ($id, $template, $namespace) = $sth->array) {
	my $newNamespace;
	if ($namespace eq "Forum") {
		$newNamespace = "Collaboration";
	} elsif ($namespace eq "Forum/PostForm") {
		$newNamespace = "Collaboration/PostForm";
	} elsif ($namespace eq "Forum/Search") {
		$newNamespace = "Collaboration/Search";
	} elsif ($namespace eq "Forum/Notification") {
		$newNamespace = "Collaboration/Notification";
	} elsif ($namespace eq "Forum/Thread") {
		$newNamespace = "Collaboration/Thread";
	}
	$template =~ s/\<tmpl_var\s+callback\.url\>//ixsg;
	$template =~ s/\<tmpl_var\s+callback\.label\>//ixsg;
	$template =~ s/\<tmpl_var\s+forum\.description\>//ixsg;
	$template =~ s/\<tmpl_var\s+forum\.title\>//ixsg;
	$template =~ s/forum\.title/collaboration.title/ixsg;
	$template =~ s/forum\.description/collaboration.description/ixsg;
	$template =~ s/forum\.//ixsg;
	$template =~ s/thread\.list\.url/collaboration.url/ixsg;
	$template =~ s/thread\.new\.url/add.url/ixsg;
	$template =~ s/thread\.new\.label/add.label/ixsg;
	$template =~ s/thread\.root\.subject/title/ixsg;
	$template =~ s/thread\.root\.epoch/dateSubmitted/ixsg;
	$template =~ s/thread\.root\.url/url/ixsg;
	$template =~ s/thread\.root\.date/dateSubmitted.human/ixsg;
	$template =~ s/thread\.root\.time/timeSubmitted.human/ixsg;
	$template =~ s/thread\.root\.user\.profile/userProfile.url/ixsg;
	$template =~ s/thread\.root\.user\.alias/username/ixsg;
	$template =~ s/thread\.root\.user\.name/username/ixsg;
	$template =~ s/thread\.root\.user\.id/ownerUserId/ixsg;
	$template =~ s/thread\.root\.user\.isVisitor/user.isVisitor/ixsg;
	$template =~ s/thread\.root\.status/status/ixsg;
	$template =~ s/thread\.last\.subject/lastReply.title/ixsg;
	$template =~ s/thread\.last\.epoch/lastReply.dateSubmitted/ixsg;
	$template =~ s/thread\.last\.date/lastReply.dateSubmitted.human/ixsg;
	$template =~ s/thread\.last\.time/lastReply.timeSubmitted.human/ixsg;
	$template =~ s/thread\.last\.user.profile/lastReply.userProfile.url/ixsg;
	$template =~ s/thread\.last\.user.name/lastReply.username/ixsg;
	$template =~ s/thread\.last\.user.id/lastReply.ownerUserId/ixsg;
	$template =~ s/thread\.last\./lastReply./ixsg;
	$template =~ s/thread\.//ixsg;
	$template =~ s/post\.subject/title/ixsg;
	$template =~ s/post\.message/content/ixsg;
	$template =~ s/post\.time\.value/timeSubmitted.human/ixsg;
	$template =~ s/post\.date\.value/dateSubmitted.human/ixsg;
	$template =~ s/post\.date\.epoch/dateSubmitted/ixsg;
	$template =~ s/post\.canEdit/user.canEdit/ixsg;
	$template =~ s/post\.user\.name/username/ixsg;
	$template =~ s/post\.user\.alias/username/ixsg;
	$template =~ s/post\.id/assetId/ixsg;
	$template =~ s/post\.user\.id/ownerUserId/ixsg;
	$template =~ s/post\.user\.profile/userProfile.url/ixsg;
	$template =~ s/post\.//ixsg;
	$template =~ s/form\.begin/form.header/ixsg;
	$template =~ s/form\.end/form.footer/ixsg;
	$template =~ s/message\.form/content.form/ixsg;
	$template =~ s/subject\.form/title.form/ixsg;
	$template =~ s/newpost\.isNewMessage/isNewPost/ixsg;
	$template =~ s/newpost\.header/newpost.header.label/ixsg;
	$template =~ s/newpost\.//ixsg;
	$template =~ s/firstPage/pagination.firstPage/ixsg;
	$template =~ s/lastPage/pagination.lastPage/ixsg;
	$template =~ s/nextPage/pagination.nextPage/ixsg;
	$template =~ s/previousPage/pagination.previousPage/ixsg;
	$template =~ s/pageList/pagination.pageList.upTo10/ixsg;
	$template =~ s/multiplePages/pagination.pageCount.isMultiple/ixsg;
	$template =~ s/numberOfPages/pagination.pageCount/ixsg;
	$template =~ s/pageNumber/pagination.pageNumber/ixsg;
	$template =~ s/thread_loop/post_loop/ixsg;
	$template =~ s/depth_loop/indent_loop/ixsg;
	$template =~ s/back\.url/collaboration.url/ixsg;
	$template =~ s/list\.label/back.label/ixsg;
	$template =~ s/-=:\s+:=-//ixsg;
	$template =~ s/previous\.more/previous.url/ixsg;
	$template =~ s/next\.more/next.url/ixsg;
	$template = '<a name="<tmpl_var assetId>"></a> <tmpl_if session.var.adminOn> <p><tmpl_var controls></p> </tmpl_if>'.$template;
	WebGUI::SQL->write("update template set template=".quote($template).", namespace=".quote($newNamespace)." where templateId=".quote($id)." and namespace=".quote($namespace)); 
}
$sth->finish;
my $defaultThread = '
<a name="<tmpl_var assetId>"></a> 
<tmpl_if session.var.adminOn> 
	<p><tmpl_var controls></p>
</tmpl_if>


<style>
	.postBorder {
		border: 1px solid #cccccc;
		width: 100%;
		margin-bottom: 10px;
	}
 	.postBorderCurrent {
		border: 3px dotted black;
		width: 100%;
		margin-bottom: 10px;
	}
	.postSubject {
		border-bottom: 1px solid #cccccc;
		font-weight: bold;
		padding: 3px;
	}
	.postData {
		border-bottom: 1px solid #cccccc;
		font-size: 11px;
		background-color: #eeeeee;
		color: black;
		padding: 3px;
	}
	.postControls {
		border-top: 1px solid #cccccc;
		background-color: #eeeeee;
		color: black;
		padding: 3px;
	}
	.postMessage {
		padding: 3px;
	}
	.currentThread {
		background-color: #eeeeee;
	}
	.threadHead {
		font-weight: bold;
		border-bottom: 1px solid #cccccc;
		font-size: 11px;
		background-color: #eeeeee;
		color: black;
		padding: 3px;
	}
	.threadData {
		font-size: 11px;
		padding: 3px;
	}
</style>
	


<div style="float: left; width: 70%">
	<h1><a href="<tmpl_var collaboration.url>"><tmpl_var collaboration.title></a></h1>
</div>
<div style="width: 30%; float: left; text-align: right;">
	<script language="JavaScript" type="text/javascript">	<!--
	function goLayout(){
		location = document.layout.layoutSelect.options[document.layout.layoutSelect.selectedIndex].value
	}
	//-->	
	</script>
	<form name="layout">
		<select name="layoutSelect" size="1" onChange="goLayout()">
			<option value="<tmpl_var layout.flat.url>" <tmpl_if layout.isFlat>selected="1"</tmpl_if>><tmpl_var layout.flat.label></option>
			<option value="<tmpl_var layout.nested.url>" <tmpl_if layout.isNested>selected="1"</tmpl_if>><tmpl_var layout.nested.label></option>
			<option value="<tmpl_var layout.threaded.url>" <tmpl_if layout.isThreaded>selected="1"</tmpl_if>><tmpl_var layout.threaded.label></option>
		</select> 
	</form> 
</div>
<div style="clear: both;"></div>

	








<tmpl_if layout.isThreaded>
<!-- begin threaded layout -->
	<tmpl_loop post_loop>
		<tmpl_if isCurrent>
			<div class="postBorder">
				<a name="<tmpl_var assetId>"></a>
				<div class="postSubject">
					<tmpl_var title>
				</div>
				<div class="postData">
					<div style="float: left; width: 50%;">
						<b><tmpl_var user.label>:</b> 
							<tmpl_if user.isVisitor>
								<tmpl_var username>
							<tmpl_else>
								<a href="<tmpl_var userProfile.url>"><tmpl_var username></a>
							</tmpl_if>
							<br />
						<b><tmpl_var date.label>:</b> <tmpl_var dateSubmitted.human><br />
					</div>	
					<div>
						<b><tmpl_var views.label>:</b> <tmpl_var views><br />
						<b><tmpl_var rating.label>:</b> <tmpl_var rating>
							<tmpl_unless hasRated>
								 &nbsp; &nbsp;<tmpl_var rate.label> [ <a href="<tmpl_var rate.url.1>">1</a>, <a href="<tmpl_var rate.url.2>">2</a>, <a href="<tmpl_var rate.url.3>">3</a>, <a href="<tmpl_var rate.url.4>">4</a>, <a href="<tmpl_var rate.url.5>">5</a> ]
							</tmpl_unless>
							<br />
						<tmpl_if user.isModerator>
							<b><tmpl_var status.label>:</b> <tmpl_var status>  &nbsp; &nbsp; [ <a href="<tmpl_var approve.url>"><tmpl_var approve.label></a> | <a href="<tmpl_var deny.url>"><tmpl_var deny.label></a> ]<br />
						<tmpl_else>	
							<tmpl_if user.isPoster>
								<b><tmpl_var status.label>:</b> <tmpl_var status><br />
							</tmpl_if>	
						</tmpl_if>	
					</div>	
				</div>
				<div class="postMessage">
					<tmpl_var content>
				</div>
				<tmpl_unless isLocked>
					<div class="postControls">
						<tmpl_if user.canReply>
							<a href="<tmpl_var reply.url>">[<tmpl_var reply.label>]</a>
						</tmpl_if>
						<tmpl_if user.canEdit>
							<a href="<tmpl_var edit.url>">[<tmpl_var edit.label>]</a>
							<a href="<tmpl_var delete.url>">[<tmpl_var delete.label>]</a>
						</tmpl_if>
					</div>
				</tmpl_unless>
			</div>	
		</tmpl_if>
	</tmpl_loop>
	<table style="width: 100%">
		<thead>
			<tr>
				<td class="threadHead"><tmpl_var subject.label></td>
				<td class="threadHead"><tmpl_var user.label></td>
				<td class="threadHead"><tmpl_var date.label></td>
			</tr>
		</thead>
		<tbody>
			<tmpl_loop post_loop>
				<tr <tmpl_if isCurrent>class="currentThread"</tmpl_if>>
					<td class="threadData"><tmpl_loop indent_loop>&nbsp; &nbsp;</tmpl_loop><a href="<tmpl_var url>"><tmpl_var title.short></a></td>
					<td class="threadData"><tmpl_var username></td>
					<td class="threadData"><tmpl_var dateSubmitted.human></td>
				</tr>
			</tmpl_loop>
		</tbody>
	</table>	
<!-- end threaded layout -->
</tmpl_if>



<tmpl_if layout.isFlat>
<!-- begin flat layout -->
	<tmpl_loop post_loop>
		<div class="postBorder<tmpl_if isCurrent>Current</tmpl_if>">
			<a name="<tmpl_var assetId>"></a>
			<div class="postSubject">
				<tmpl_var title>
			</div>
			<div class="postData">
				<div style="float: left; width: 50%">
					<b><tmpl_var user.label>:</b> 
						<tmpl_if user.isVisitor>
							<tmpl_var username>
						<tmpl_else>
							<a href="<tmpl_var userProfile.url>"><tmpl_var username></a>
						</tmpl_if>
						<br />
					<b><tmpl_var date.label>:</b> <tmpl_var dateSubmitted.human><br />
				</div>	
				<div>
					<b><tmpl_var views.label>:</b> <tmpl_var views><br />
					<b><tmpl_var rating.label>:</b> <tmpl_var rating>
						<tmpl_unless hasRated>
							 &nbsp; &nbsp;<tmpl_var rate.label> [ <a href="<tmpl_var rate.url.1>">1</a>, <a href="<tmpl_var rate.url.2>">2</a>, <a href="<tmpl_var rate.url.3>">3</a>, <a href="<tmpl_var rate.url.4>">4</a>, <a href="<tmpl_var rate.url.5>">5</a> ]
						</tmpl_unless>
						<br />
					<tmpl_if user.isModerator>
						<b><tmpl_var status.label>:</b> <tmpl_var status>  &nbsp; &nbsp; [ <a href="<tmpl_var approve.url>"><tmpl_var approve.label></a> | <a href="<tmpl_var deny.url>"><tmpl_var deny.label></a> ]<br />
					<tmpl_else>	
						<tmpl_if user.isPoster>
							<b><tmpl_var status.label>:</b> <tmpl_var status><br />
						</tmpl_if>	
					</tmpl_if>	
				</div>	
			</div>
			<div class="postMessage">
				<tmpl_var content>
			</div>
			<tmpl_unless isLocked>
				<div class="postControls">
					<tmpl_if user.canReply>
						<a href="<tmpl_var reply.url>">[<tmpl_var reply.label>]</a>
					</tmpl_if>
					<tmpl_if user.canEdit>
						<a href="<tmpl_var edit.url>">[<tmpl_var edit.label>]</a>
						<a href="<tmpl_var delete.url>">[<tmpl_var delete.label>]</a>
					</tmpl_if>
				</div>
			</tmpl_unless>
		</div>
	</tmpl_loop>
<!-- end flat layout -->
</tmpl_if>



<tmpl_if layout.isNested>
<!-- begin nested layout -->
    <tmpl_loop post_loop>
		<div style="margin-left: <tmpl_var depthX10>px;">
			<div class="postBorder<tmpl_if isCurrent>Current</tmpl_if>">
				<a name="<tmpl_var assetId>"></a>
				<div class="postSubject">
					<tmpl_var title>
				</div>
				<div class="postData">
					<div style="float: left; width: 50%">
						<b><tmpl_var user.label>:</b> 
							<tmpl_if user.isVisitor>
								<tmpl_var username>
							<tmpl_else>
								<a href="<tmpl_var userProfile.url>"><tmpl_var username></a>
							</tmpl_if>
							<br />
						<b><tmpl_var date.label>:</b> <tmpl_var dateSubmitted.human><br />
					</div>	
					<div>
						<b><tmpl_var views.label>:</b> <tmpl_var views><br />
						<b><tmpl_var rating.label>:</b> <tmpl_var rating>
							<tmpl_unless hasRated>
								 &nbsp; &nbsp;<tmpl_var rate.label> [ <a href="<tmpl_var rate.url.1>">1</a>, <a href="<tmpl_var rate.url.2>">2</a>, <a href="<tmpl_var rate.url.3>">3</a>, <a href="<tmpl_var rate.url.4>">4</a>, <a href="<tmpl_var rate.url.5>">5</a> ]
							</tmpl_unless>
							<br />
						<tmpl_if user.isModerator>
							<b><tmpl_var status.label>:</b> <tmpl_var status>  &nbsp; &nbsp; [ <a href="<tmpl_var approve.url>"><tmpl_var approve.label></a> | <a href="<tmpl_var deny.url>"><tmpl_var deny.label></a> ]<br />
						<tmpl_else>	
							<tmpl_if user.isPoster>
								<b><tmpl_var status.label>:</b> <tmpl_var status><br />
							</tmpl_if>	
						</tmpl_if>	
					</div>	
				</div>
				<div class="postMessage">
					<tmpl_var content>
				</div>
				<tmpl_unless isLocked>
					<div class="postControls">
						<tmpl_if user.canReply>
							<a href="<tmpl_var reply.url>">[<tmpl_var reply.label>]</a>
						</tmpl_if>
						<tmpl_if user.canEdit>
							<a href="<tmpl_var edit.url>">[<tmpl_var edit.label>]</a>
							<a href="<tmpl_var delete.url>">[<tmpl_var delete.label>]</a>
						</tmpl_if>
					</div>
				</tmpl_unless>
			</div>
		</div>
	</tmpl_loop>
<!-- end nested layout -->
</tmpl_if>



<tmpl_if pagination.pageCount.isMultiple>
	<div class="pagination" style="margin-top: 20px;">
		[ <tmpl_var pagination.previousPage>  | <tmpl_var pagination.pageList.upTo10> | <tmpl_var pagination.nextPage> ]
	</div>
</tmpl_if>


<div style="margin-top: 20px;">
    <tmpl_if previous.url>
		<a href="<tmpl_var previous.url>">[<tmpl_var previous.label>]</a> 
	</tmpl_if>	
    <tmpl_if next.url>
		<a href="<tmpl_var next.url>">[<tmpl_var next.label>]</a> 
	</tmpl_if>	
	<tmpl_if user.canPost>
		<a href="<tmpl_var add.url>">[<tmpl_var add.label>]</a>
	</tmpl_if>
	<tmpl_if user.isModerator>
		<tmpl_if isSticky>
			<a href="<tmpl_var unstick.url>">[<tmpl_var unstick.label>]</a>
		<tmpl_else>
			<a href="<tmpl_var stick.url>">[<tmpl_var stick.label>]</a>
		</tmpl_if>
		<tmpl_if isLocked>
			<a href="<tmpl_var unlock.url>">[<tmpl_var unlock.label>]</a>
		<tmpl_else>
			<a href="<tmpl_var lock.url>">[<tmpl_var lock.label>]</a>
		</tmpl_if>
	</tmpl_if>
	<tmpl_unless user.isVisitor>
		<tmpl_if user.isSubscribed>
			<a href="<tmpl_var unsubscribe.url>">[<tmpl_var unsubscribe.label>]</a>
		<tmpl_else>
			<a href="<tmpl_var subscribe.url>">[<tmpl_var subscribe.label>]</a>
		</tmpl_if>
	</tmpl_unless>
</div>

';
WebGUI::SQL->write("update template set template=".quote($defaultThread)." where templateId='25' and namespace='Collaboration/Thread'");


print "\tMigrating USS templates to collaboration templates\n" unless ($quiet);
my $sth = WebGUI::SQL->read("select templateId,template,namespace from template where namespace in ('USS','USS/Submission','USS/SubmissionForm')");
while (my ($id, $template, $namespace) = $sth->array) {
	my $newNamespace;
	if ($namespace eq "USS") {
		$template =~ s/post\.url/add.url/ixsg;
		$newNamespace = "Collaboration";
	} elsif ($namespace eq "USS/SubmissionForm") {
		$newNamespace = "Collaboration/PostForm";
		if ($template =~ /image\.form/ixsg && $template =~ /attachment\.form/ixsg) {
			$template =~ s/\<tmpl_var\s+image\.form\>//ixsg;
			$template =~ s/\<tmpl_var\s+image\.label\>//ixsg;
		} elsif ($template =~ /image\.form/) {
			$template =~ s/image\.form/attachment.form/ixsg;
		}
	} elsif ($namespace eq "USS/Submission") {
		$newNamespace = "Collaboration/Thread";
		if ($template =~ /attachment\.box/ixsg) {
			my $box = '<div><a href="<tmpl_var attachment.url>"><img src="<tmpl_var attachment.icon>" border="0"> <tmpl_var attachment.name></a></div>';
			$template =~ s/\<tmpl_var\s+attachment\.box\>/$box/ixsg;
		}
	}
	$template =~ s/\<tmpl_var\s+search\.form\>//ixsg;
	$template =~ s/\<tmpl_var\s+leave\.url\>//ixsg;
	$template =~ s/\<tmpl_var\s+leave\.label\>//ixsg;
	$template =~ s/canPost/user.canPost/ixsg;
	$template =~ s/canModerate/user.isModerator/ixsg;
	$template =~ s/submission\.currentUser/user.isPoster/ixsg;
	$template =~ s/submission\.id/assetId/ixsg;
	$template =~ s/submission\.isNew/isNewPost/ixsg;
	$template =~ s/submission\.content\.full/content/ixsg;
	$template =~ s/submission\.content/synopsis/ixsg;
	$template =~ s/submission\.responses/replies/ixsg;
	$template =~ s/submission\.userId/ownerUserId/ixsg;
	$template =~ s/submission\.date.updated/dateUpdated.human/ixsg;
	$template =~ s/submission\.date/dateSubmitted.human/ixsg;
	$template =~ s/submission\.userProfile/userProfile.url/ixsg;
	$template =~ s/submission\.secondColumn/isSecond/ixsg;
	$template =~ s/submission\.thirdColumn/isThird/ixsg;
	$template =~ s/submission\.fourthColumn/isFourth/ixsg;
	$template =~ s/submission\.fifthColumn/isFifth/ixsg;
	$template =~ s/submission\.//ixsg;
	$template =~ s/user\.Profile/userProfile.url/ixsg;
	$template =~ s/user\.id/ownerUserId/ixsg;
	$template =~ s/user\.alias/username/ixsg;
	$template =~ s/user\.username/username/ixsg;
	$template =~ s/date\.epoch/dateSubmitted/ixsg;
	$template =~ s/date\.human/dateSubmitted.human/ixsg;
	$template =~ s/date\.updated\.epoch/dateUpdated/ixsg;
	$template =~ s/date\.updated\.human/dateUpdated.human/ixsg;
	$template =~ s/date\.updated\.label/date.label/ixsg;
	$template =~ s/status\.status/status/ixsg;
	$template =~ s/views\.count/views/ixsg;
	$template =~ s/post\.url/edit.url/ixsg;
	$template =~ s/previous\.more/previous.url/ixsg;
	$template =~ s/next\.more/next.url/ixsg;
	$template =~ s/canReply/user.canReply/ixsg;
	$template =~ s/title\.value/title/ixsg;
	$template =~ s/body\.form\.textarea/content.form/ixsg;
	$template =~ s/body\.form/content.form/ixsg;
	$template =~ s/body\.value/content/ixsg;
	$template =~ s/back\.url/collaboration.url/ixsg;
	$template =~ s/submissions_loop/post_loop/ixsg;
	$template = '<a name="<tmpl_var assetId>"></a> <tmpl_if session.var.adminOn> <p><tmpl_var controls></p> </tmpl_if>'.$template;
	WebGUI::SQL->write("update template set template=".quote($template).", namespace=".quote($newNamespace)." where templateId=".quote($id)." and namespace=".quote($namespace)); 
}
$sth->finish;



print "\tConverting template system to asset tree\n" unless ($quiet);
WebGUI::SQL->write("update template set namespace='Layout' where namespace='page'");
WebGUI::SQL->write("alter table template add column assetId varchar(22) not null");
my $tempRootLineage = getNextLineage('PBasset000000000000002');
my $tempRootId = WebGUI::SQL->setRow("asset","assetId",{
	assetId=>"new",
	isHidden=>1,
	title=>"Templates",
	menuTitle=>"Templates",
	url=>fixUrl('doesntexistyet',"Templates"),
	ownerUserId=>"3",
	groupIdView=>"4",
	groupIdEdit=>"4",
	parentId=>"PBasset000000000000002",
	lineage=>$tempRootLineage,
	lastUpdated=>time(),
	className=>"WebGUI::Asset::Wobject::Folder",
	state=>"published"
	});
WebGUI::SQL->setRow("wobject","assetId",{
	assetId=>$tempRootId,
	styleTemplateId=>"1",
	printableStyleTemplateId=>"3"
	},undef,$tempRootId);
WebGUI::SQL->setRow("Folder","assetId",{
	assetId=>$tempRootId,
	templateId=>"PBtmpl0000000000000078"
	},undef,$tempRootId);
my $tempRankCounter = 1;
my %templateCache;
my $sth = WebGUI::SQL->read("select * from template");
while (my $data = $sth->hashRef) {
	print "\t\tConverting ".$data->{name}."\n" unless ($quiet);
	my ($templateId ,%newAsset);
	$templateId = $newAsset{assetId} = getNewId("tmpl",$data->{templateId},$data->{namespace}); 
	$newAsset{url} = fixUrl($newAsset{assetId},$data->{name});
	$newAsset{isHidden} = 1;
	$newAsset{title} = $newAsset{menuTitle} = $data->{name};
	$newAsset{ownerUserId} = "3";
	$newAsset{groupIdView} = "7";
	$newAsset{groupIdEdit} = "4";
	$newAsset{className} = 'WebGUI::Asset::Template';
	$newAsset{state} = 'published';
	$newAsset{lastUpdated} = time();
	$newAsset{parentId} = $tempRootId;
	$newAsset{lineage} = $tempRootLineage.sprintf("%06d",$tempRankCounter);
	WebGUI::SQL->setRow("asset","assetId",\%newAsset,undef,$templateId);
	WebGUI::SQL->write("update template set assetId=".quote($templateId)." where templateId=".quote($data->{templateId})."
		and namespace=".quote($data->{namespace}));
	$templateCache{$data->{namespace}}{$data->{templateId}} = $templateId;
	$tempRankCounter++;
}
$sth->finish;
WebGUI::SQL->write("alter table template drop primary key");
WebGUI::SQL->write("alter table template drop column templateId");
WebGUI::SQL->write("alter table template drop column name");
WebGUI::SQL->write("delete from template  where assetId is null or assetId = ''"); # protect ourselves from crap
WebGUI::SQL->write("alter table template add primary key (assetId)");
my @wobjectTypes = qw(Article Poll Survey WSClient DataForm Layout EventsCalendar Navigation HttpProxy IndexedSearch MessageBoard Product SQLReport SyndicatedContent Shortcut);
my @allWobjectTypes = (@wobjectTypes,@otherWobjects);
print "\t\tMigrating wobject templates to new IDs\n" unless ($quiet);
foreach my $type (@allWobjectTypes) {
	print "\t\t\t$type\n" unless ($quiet);
	my $sth = WebGUI::SQL->read("select assetId, templateId from $type");
	while (my ($assetId, $templateId) = $sth->array) {
		WebGUI::SQL->setRow($type,"assetId",{
			assetId=>$assetId,
			templateId=>$templateCache{$type}{$templateId}
			});
	}
	$sth->finish;
}
print "\t\tMigrating wobject style templates to new IDs\n" unless ($quiet);
my $sth = WebGUI::SQL->read("select assetId, styleTemplateId, printableStyleTemplateId from wobject");
while (my ($assetId, $styleId, $printId) = $sth->array) {
	WebGUI::SQL->setRow("wobject","assetId",{
		assetId=>$assetId,
		styleTemplateId=>$templateCache{style}{$styleId},
		printableStyleTemplateId=>$templateCache{style}{$printId}
		});
}
$sth->finish;
print "\t\tMigrating DataForm templates to new IDs\n" unless ($quiet);
my $sth = WebGUI::SQL->read("select assetId,emailTemplateId,acknowlegementTemplateId,listTemplateId from DataForm");
while (my ($assetId, $emailId, $ackId, $listId) = $sth->array) {
	WebGUI::SQL->setRow("DataForm","assetId",{
		assetId=>$assetId,
		emailTemplateId=>$templateCache{DataForm}{$emailId},
		acknowlegementTemplateId=>$templateCache{DataForm}{$ackId},
		listTemplateId=>$templateCache{"DataForm/List"}{$listId}
		});
}
$sth->finish;
print "\t\tMigrating Collaboration templates to new IDs\n" unless ($quiet);
my $sth = WebGUI::SQL->read("select assetId, collaborationTemplateId, postFormTemplateId, threadTemplateId, searchTemplateId, notificationTemplateId from Collaboration");
while (my ($assetId, $collabId, $formId, $threadId, $searchId, $notId) = $sth->array) {
	WebGUI::SQL->setRow("Collaboration","assetId",{
		assetId=>$assetId,
		collaborationTemplateId=>$templateCache{"Collaboration"}{$collabId},
		searchTemplateId=>$templateCache{"Collaboration/Search"}{$searchId},
		threadTemplateId=>$templateCache{"Collaboration/Thread"}{$threadId},
		notificationTemplateId=>$templateCache{"Collaboration/Notification"}{$notId},
		postFormTemplateId=>$templateCache{"Collaboration/PostForm"}{$formId}
		});
}
print "\t\tMigrating Shortcut templates to new IDs\n" unless ($quiet);
my $sth = WebGUI::SQL->read("select assetId, proxiedNamespace overrideTemplateId from Shortcut");
while (my ($assetId, $namespace, $tid) = $sth->array) {
	WebGUI::SQL->setRow("Shortcut","assetId",{
		assetId=>$assetId,
		overrideTemplateId=>$templateCache{$namespace}{$tid}
		});
}
$sth->finish;
WebGUI::SQL->write("alter table Shortcut drop column proxiedNamespace");
WebGUI::SQL->write("alter table Shortcut change templateId templateId varchar(22) not null");
WebGUI::SQL->write("update Shortcut set templateId='PBtmpl0000000000000140'");
use WebGUI::Asset;
my $import = WebGUI::Asset->getImportNode;
my $newTemplate = $import->addChild({
		className=>'WebGUI::Asset::Template',
		namespace=>'Shortcut',
		title=>'Default Shortcut',
		menuTitle=>'Default Shortcut',
		ownerUserId=>'3',
		groupIdView=>'7',
		groupIdEdit=>'4',
		isHidden=>1,
		template=>'
<a name="<tmpl_var assetId>"></a>
<tmpl_if session.var.adminOn>
	<p><tmpl_var controls></p>
	<div style="width: 100%; border: 1px groove black;">
		<div style="width: 100%; background-image: url(<tmpl_var session.config.extrasURL>/opaque.gif);">
			<div style="text-align: center; font-weight: bold;"><a href="<tmpl_var originalURL>"><tmpl_var shortcut.label></a></div>
		</div>
</tmpl_if>	
<tmpl_var shortcut.content>
<tmpl_if session.var.adminOn>
		<div style="width: 100%; background-image: url(<tmpl_var session.config.extrasURL>/opaque.gif);">
			<div style="text-align: center; font-weight: bold;"><a href="<tmpl_var originalURL>"><tmpl_var shortcut.label></a></div>
		</div>
	</div>
</tmpl_if>	
		'
		},'PBtmpl0000000000000140');





print "\tReplacing some old macros with new ones\n" unless ($quiet);
my $sth = WebGUI::SQL->read("select assetId, template from template");
while (my ($id, $template) = $sth->array) {
	WebGUI::SQL->write("update template set template=".quote(replaceMacros($template))." where assetId=".quote($id));
}
$sth->finish;
my $sth = WebGUI::SQL->read("select assetId, description from wobject");
while (my ($id, $desc) = $sth->array) {
	WebGUI::SQL->write("update wobject set description=".quote(replaceMacros($desc))." where assetId=".quote($id));
}
$sth->finish;

my $sth = WebGUI::SQL->read("select assetId, snippet from snippet");
while (my ($id, $snip) = $sth->array) {
	WebGUI::SQL->write("update snippet set snippet=".quote(replaceMacros($snip))." where assetId=".quote($id));
}
$sth->finish;




print "\tDeleting files which are no longer used.\n" unless ($quiet);
#unlink("../../lib/WebGUI/Export.pm");
#unlink("../../lib/WebGUI/MetaData.pm");
#unlink("../../lib/WebGUI/Operation/MetaData.pm");
#unlink("../../lib/WebGUI/i18n/English/MetaData.pm");
#unlink("../../lib/WebGUI/Help/MetaData.pm");
#unlink("../../sbin/fileManagerImport.pl");
#unlink("../../sbin/collateralImport.pl");
#unlink("../../lib/WebGUI/Page.pm");
#unlink("../../lib/WebGUI/Page.pm");
#unlink("../../lib/WebGUI/Operation/Page.pm");
#unlink("../../lib/WebGUI/Operation/Package.pm");
#unlink("../../lib/WebGUI/Template.pm");
#unlink("../../lib/WebGUI/Operation/Template.pm");
#unlink("../../lib/WebGUI/Operation/Root.pm");
#unlink("../../lib/WebGUI/Navigation.pm");
#unlink("../../lib/WebGUI/Operation/Navigation.pm");
#unlink("../../lib/WebGUI/Macro/Navigation.pm");
#unlink("../../lib/WebGUI/Macro/File.pm");
#unlink("../../lib/WebGUI/Macro/I_imageWithTags.pm");
#unlink("../../lib/WebGUI/Macro/i_imageNoTags.pm");
#unlink("../../lib/WebGUI/Macro/Snippet.pm");
#unlink("../../lib/WebGUI/Macro/Backslash_pageUrl.pm");
#unlink("../../lib/WebGUI/Macro/RandomSnippet.pm");
#unlink("../../lib/WebGUI/Macro/RandomImage.pm");
#unlink("../../lib/WebGUI/Attachment.pm");
#unlink("../../lib/WebGUI/Node.pm");
#unlink("../../lib/WebGUI/Wobject/Article.pm");
#unlink("../../lib/WebGUI/Help/SiteMap.pm");
#unlink("../../lib/WebGUI/i18n/English/SiteMap.pm");
#unlink("../../lib/WebGUI/Wobject/SiteMap.pm");
#unlink("../../lib/WebGUI/Wobject/EventsCalendar.pm");
#unlink("../../lib/WebGUI/Wobject/Poll.pm");
#unlink("../../lib/WebGUI/Wobject/DataForm.pm");
#unlink("../../lib/WebGUI/Wobject/USS.pm");
#unlink("../../lib/WebGUI/Wobject/WSClient.pm");
#unlink("../../lib/WebGUI/i18n/English/FileManager.pm");
#unlink("../../lib/WebGUI/Help/FileManager.pm");
#unlink("../../lib/WebGUI/Wobject/FileManager.pm");
#rmtree("../../lib/WebGUI/Wobject/HttpProxy");
#unlink("../../lib/WebGUI/Wobject/HttpProxy.pm");
#unlink("../../lib/WebGUI/Wobject/SQLReport.pm");
#unlink("../../lib/WebGUI/Operation/Clipboard.pm");
#unlink("../../lib/WebGUI/Operation/Trash.pm");
#unlink("../../lib/WebGUI/Operation/Collateral.pm");
#unlink("../../lib/WebGUI/Collateral.pm");
#unlink("../../lib/WebGUI/CollateralFolder.pm");
#unlink("../../lib/WebGUI/Persistent.pm");
#rmtree("../../lib/WebGUI/Persistent");
#rmtree("../../lib/Tree");
#rmtree("../../lib/DBIx/Tree");
#unlink("../../lib/WebGUI/Help/WobjectProxy.pm");
#unlink("../../lib/WebGUI/i18n/English/WobjectProxy.pm");
#unlink("../../lib/WebGUI/Wobject/MessageBoard.pm");
#unlink("../../lib/WebGUI/Wobject/WobjectProxy.pm");
#rmtree("../../www/extras/wobject/WobjectProxy");



#--------------------------------------------
print "\tUpdating config file.\n" unless ($quiet);
my $pathToConfig = '../../etc/'.$configFile;
my $conf = Parse::PlainConfig->new('DELIM' => '=', 'FILE' => $pathToConfig);
my $macros = $conf->get("macros");
delete $macros->{"\\"};
delete $macros->{"Backslash_pageUrl"};
delete $macros->{"I_imageWithTags"};
delete $macros->{"Snippet"};
delete $macros->{"Navigation"};
delete $macros->{"File"};
delete $macros->{"RandomSnippet"};
delete $macros->{"RandomImage"};
delete $macros->{"i_imageNoTags"};
$macros->{"AssetProxy"} = "AssetProxy";
$macros->{"RandomAssetProxy"} = "RandomAssetProxy";
$macros->{"FileUrl"} = "FileUrl";
$macros->{"PageUrl"} = "PageUrl";
$conf->set("paymentPlugins"=>"ITransact");
$conf->set("macros"=>$macros);
$conf->set("assets"=>[
		'WebGUI::Asset::Wobject::Navigation',
		'WebGUI::Asset::Wobject::Poll',
		'WebGUI::Asset::Wobject::Article',
		'WebGUI::Asset::Wobject::DataForm',
		'WebGUI::Asset::Wobject::SyndicatedContent',
		'WebGUI::Asset::Wobject::WSClient',
		'WebGUI::Asset::Wobject::HttpProxy',
		'WebGUI::Asset::Wobject::SQLReport',
		'WebGUI::Asset::Wobject::Survey',
		'WebGUI::Asset::Wobject::Product',
		'WebGUI::Asset::Wobject::Collaboration',
		'WebGUI::Asset::Wobject::MessageBoard',
		'WebGUI::Asset::Wobject::EventsCalendar',
		'WebGUI::Asset::Redirect',
		'WebGUI::Asset::Template',
		'WebGUI::Asset::FilePile',
		'WebGUI::Asset::File',
		'WebGUI::Asset::File::Image',
		'WebGUI::Asset::Snippet'
		]);
$conf->set("assetContainers"=>[
		'WebGUI::Asset::Wobject::Folder',
		'WebGUI::Asset::Wobject::Layout'
		]);
$conf->write;




print "\tSetting user function style\n" unless ($quiet);
my ($defaultPageId) = WebGUI::SQL->quickArray("select value from settings where name='defaultPage'");
my ($styleId) = WebGUI::SQL->quickArray("select styleTemplateId from wobject where assetId=".quote($defaultPageId));
WebGUI::SQL->write("insert into settings (name,value) values ('userFunctionStyleId',".quote($styleId).")");




WebGUI::Session::close();








sub replaceMacros {
   	my $content = shift;
my $parenthesis;
$parenthesis = qr /\(                      # Start with '(',
                     (?:                     # Followed by
                     (?>[^()]+)              # Non-parenthesis
                     |(??{ $parenthesis })   # Or a balanced parenthesis block
                     )*                      # zero or more times
                     \)/x;                  # Ending with ')'
my $nestedMacro;
$nestedMacro = qr /(\^                     # Start with carat
                     ([^\^;()]+)            # And one or more none-macro characters -tagged-
                     ((?:                   # Followed by
                     (??{ $parenthesis })   # a balanced parenthesis block
                     |(?>[^\^;])            # Or not a carat or semicolon
#                    |(??{ $nestedMacro }) # Or a balanced carat-semicolon block
                     )*)                    # zero or more times -tagged-
                     ;)/x;                   # End with  a semicolon.
   	while ($content =~ /$nestedMacro/gs) {
      		my ($macro, $searchString, $params) = ($1, $2, $3);
      		next if ($searchString =~ /^\d+$/); # don't process ^0; ^1; ^2; etc.
      		next if ($searchString =~ /^\-$/); # don't process ^-;
		if ($params ne "") {
      			$params =~ s/(^\(|\)$)//g; # remove parenthesis
		}
		my @parsed;
        	push(@parsed, $+) while $params =~ m {
                	"([^\"\\]*(?:\\.[^\"\\]*)*)",?
                	|       ([^,]+),?
                	|       ,
        		}gx;
        	push(@parsed, undef) if substr($params,-1,1) eq ',';
		my $result;
		if (isIn($searchString, qw(Navigation I Snippet File))) {
			my $url = (exists $macroCache{$parsed[0]}) ? $macroCache{$parsed[0]} : $parsed[0];
			$result = '^AssetProxy("'.$url.'");';
		} elsif (isIn($searchString, qw(RandomSnippet RandomImage))) {
			my $url = (exists $macroCache{$parsed[0]}) ? $folderCache{$parsed[0]} : $parsed[0];
			$result = '^RandomAssetProxy("'.$url.'");';
		} elsif (isIn($searchString, qw(AdminBar))) {
			my $newId =$templateCache{"Macro/AdminBar"}{$parsed[0]};
			my $id = (defined $newId) ? $newId : $parsed[0];
			$result = '^AdminBarXXX("'.$id.'");';
		} elsif (isIn($searchString, qw(L))) {
			my $newId =$templateCache{"Macro/L_loginBox"}{$parsed[2]};
			my $id = (defined $newId) ? $newId : $parsed[2];
			$result = '^LoginBoxXXX("'.$parsed[0].'","'.$parsed[1].'","'.$id.'");';
		} elsif (isIn($searchString, qw(i))) {
			my $url = (exists $macroCache{$parsed[0]}) ? $macroCache{$parsed[0]} : $parsed[0];
			$result = '^FileUrl("'.$url.'");';
		} elsif (isIn($searchString, qw(\\))) {
			$result = '^PageUrl;';
		} else {
			next;
		}
		$content =~ s/\Q$macro/$result/ges;
   	}
	# a nasty hack to stop an infinite loop
	$content =~ s/AdminBarXXX/AdminBar/xg;
	$content =~ s/LoginBoxXXX/L/xg;
   	return $content;
}



sub walkTree {
	my $oldParentId = shift;
	my $newParentId = shift;
	my $parentLineage = shift;
	my $myRank = shift;
	print "\t\tFinding children of page ".$oldParentId."\n" unless ($quiet);
	my $a = WebGUI::SQL->read("select * from page where subroutinePackage='WebGUI::Page' and parentId=".quote($oldParentId)." order by nestedSetLeft");
	while (my $page = $a->hashRef) {
		print "\t\tConverting page ".$page->{pageId}."\n" unless ($quiet);
		my $pageId = WebGUI::Id::generate();
		if ($page->{pageId} eq $session{setting}{defaultPage}) {
			WebGUI::SQL->write("update settings set value=".quote($pageId)." where name='defaultPage'");
		}
		if ($page->{pageId} eq $session{setting}{notFoundPage}) {
			WebGUI::SQL->write("update settings set value=".quote($pageId)." where name='notFoundPage'");
		}
		my $pageLineage = $parentLineage.sprintf("%06d",$myRank);
		my $pageUrl = fixUrl($pageId,$page->{urlizedTitle});
		my $className = 'WebGUI::Asset::Wobject::Layout';
		if ($page->{redirectURL} ne "") {
			$className = 'WebGUI::Asset::Redirect';
		}
		WebGUI::SQL->write("insert into asset (assetId, parentId, lineage, className, state, title, menuTitle, url, startDate, 
			endDate, synopsis, newWindow, isHidden, ownerUserId, groupIdView, groupIdEdit, encryptPage, assetSize,
			extraHeadTags ) values (".quote($pageId).",
			".quote($newParentId).", ".quote($pageLineage).", ".quote($className).",'published',".quote($page->{title}||"Untitled").",
			".quote($page->{menuTitle}||"Untitled").", ".quote($pageUrl).", ".quote($page->{startDate}).", ".quote($page->{endDate}).",
			".quote($page->{synopsis}).", ".quote($page->{newWindow}).", ".quote($page->{hideFromNavigation}).", ".quote($page->{ownerId}||'3').",
			".quote($page->{groupIdView}||'7').", ".quote($page->{groupIdEdit}.'3').", ".quote($page->{encryptPage}).",
			".length($page->{title}.$page->{menuTitle}.$page->{synopsis}.$page->{urlizedTitle}).", ".quote($page->{metaTags}).")");
		if ($page->{redirectURL} ne "") {
			WebGUI::SQL->write("insert into redirect (assetId, redirectUrl) values (".quote($pageId).",".quote($page->{redirectURL}).")");
		} else {
			WebGUI::SQL->write("insert into wobject (assetId, styleTemplateId, printableStyleTemplateId, 
				cacheTimeout, cacheTimeoutVisitor, displayTitle, namespace) values (
				".quote($pageId).", ".quote($page->{styleId}||'1').",  
				".quote($page->{printableStyleId}||'1').", ".quote($page->{cacheTimeout}).",".quote($page->{cacheTimeoutVisitor}).",
				0,'Layout')");
			WebGUI::SQL->write("insert into Layout (assetId,templateId) values (".quote($pageId).", ".quote($page->{templateId}||'1').")");
		}
		my $rank = 1;
		print "\t\tFinding wobjects on page ".$page->{pageId}."\n" unless ($quiet);
		my $b = WebGUI::SQL->read("select * from wobject where pageId=".quote($page->{pageId})." order by sequenceNumber");
		while (my $wobject = $b->hashRef) {
			print "\t\t\tConverting wobject ".$wobject->{wobjectId}."\n" unless ($quiet);
			my $namespace = WebGUI::SQL->quickHashRef("select * from ".$wobject->{namespace}." where wobjectId=".quote($wobject->{wobjectId}));
			my $wobjectId = WebGUI::Id::generate();
			my $wobjectLineage = $pageLineage.sprintf("%06d",$rank);
			my $wobjectUrl = fixUrl($wobjectId,$pageUrl."/".$wobject->{title});
			my $groupIdView = $page->{groupIdView};
			my $groupIdEdit = $page->{groupIdEdit};
			my $ownerId = $page->{ownerId};
			if ($page->{wobjectPrivileges}) {
				$groupIdView = $wobject->{groupIdView};
				$groupIdEdit = $wobject->{groupIdEdit};
				$ownerId = $wobject->{ownerId};
			}
			$className = 'WebGUI::Asset::Wobject::'.$wobject->{namespace};
			WebGUI::SQL->write("insert into asset (assetId, parentId, lineage, className, state, title, menuTitle, url, startDate, 
				endDate, isHidden, ownerUserId, groupIdView, groupIdEdit, encryptPage, assetSize) values (".quote($wobjectId).",
				".quote($pageId).", ".quote($wobjectLineage).", ".quote($className).",'published',".quote($wobject->{title}||'Untitled').",
				".quote($wobject->{title}||'Untitled').", ".quote($wobjectUrl).", ".quote($wobject->{startDate}).", ".quote($wobject->{endDate}).",
				1, ".quote($ownerId||'3').", ".quote($groupIdView||'7').", ".quote($groupIdEdit||'3').", ".quote($page->{encryptPage}).",
				".length($wobject->{title}.$wobject->{description}).")");
			WebGUI::SQL->write("update wobject set assetId=".quote($wobjectId).", styleTemplateId=".quote($page->{styleId}||'1').",
				printableStyleTemplateId=".quote($page->{printableStyleId}||'1').", cacheTimeout=".quote($page->{cacheTimeout})
				.", cacheTimeoutVisitor=".quote($page->{cacheTimeoutVisitor})." where wobjectId=".quote($wobject->{wobjectId}));
			WebGUI::SQL->write("update ".$wobject->{namespace}." set assetId=".quote($wobjectId)." where wobjectId="
				.quote($wobject->{wobjectId}));
			WebGUI::SQL->write("update metaData_values set assetId=".quote($wobjectId)." where wobjectId=".quote($wobject->{wobjectId}));
			if ($wobject->{namespace} eq "Article") {
				print "\t\t\tMigrating attachments for Article ".$wobject->{wobjectId}."\n" unless ($quiet);
				if ($namespace->{attachment}) {
					my $attachmentId = WebGUI::Id::generate();
					my $storageId = copyFile($namespace->{attachment},$wobject->{wobjectId});
					WebGUI::SQL->write("insert into asset (assetId, parentId, lineage, className, state, title, menuTitle, 
						url, startDate, endDate, isHidden, ownerUserId, groupIdView, groupIdEdit,assetSize) values (".
						quote($attachmentId).", ".quote($wobjectId).", ".quote($wobjectLineage.sprintf("%06d",1)).", 
						'WebGUI::Asset::File','published',".quote($namespace->{attachment}).", ".
						quote($namespace->{attachment}).", ".quote(fixUrl($attachmentId,$wobjectUrl.'/'.$namespace->{attachment})).", 
						".quote($wobject->{startDate}).", ".quote($wobject->{endDate}).", 1, ".quote($ownerId).", 
						".quote($groupIdView).", ".quote($groupIdEdit).","
						.quote(getFileSize($storageId,$namespace->{attachment})).")");
					WebGUI::SQL->write("insert into FileAsset (assetId, filename, storageId) values (
						".quote($attachmentId).", ".quote($namespace->{attachment}).", ".quote($storageId).")");
				}
				if ($namespace->{image}) {
					my $rank = 1;
					$rank ++ if ($namespace->{attachment});
					my $imageId = WebGUI::Id::generate();
					my $storageId = copyFile($namespace->{image},$wobject->{wobjectId});
					copyFile('thumb-'.$namespace->{image},$wobject->{wobjectId},$storageId);
					WebGUI::SQL->write("insert into asset (assetId, parentId, lineage, className, state, title, menuTitle, 
						url, startDate, endDate, isHidden, ownerUserId, groupIdView, groupIdEdit,assetSize) values (".
						quote($imageId).", ".quote($wobjectId).", ".quote($wobjectLineage.sprintf("%06d",$rank)).", 
						'WebGUI::Asset::File::Image','published',".quote($namespace->{image}).", ".
						quote($namespace->{image}).", ".quote(fixUrl($imageId,$wobjectUrl.'/'.$namespace->{image})).", 
						".quote($wobject->{startDate}).", ".quote($wobject->{endDate}).", 1, ".quote($ownerId).", 
						".quote($groupIdView).", ".quote($groupIdEdit).",".quote(getFileSize($storageId,$namespace->{image})).")");
					WebGUI::SQL->write("insert into FileAsset (assetId, filename, storageId) values (
						".quote($imageId).", ".quote($namespace->{image}).", ".quote($storageId).")");
					WebGUI::SQL->write("insert into ImageAsset (assetId, thumbnailSize) values (".quote($imageId).",
						".quote($session{setting}{thumbnailSize}).")");
				}
				if ($namespace->{allowDiscussion}) {
					print "\t\t\tMigrating forum for Article ".$wobject->{wobjectId}."\n" unless ($quiet);
					$rank++;
					migrateForum($wobject->{forumId},$pageId,$pageLineage,$rank, $wobject->{title},$wobject->{description},
						$wobject->{startDate}, $wobject->{endDate}, $wobject->{ownerId}, $wobject->{groupIdEdit},
						$page->{styleId}, $page->{printableStyleId});
				}
				rmtree($session{config}{uploadsPath}.$session{os}{slash}.$wobject->{wobjectId});
			} elsif ($wobject->{namespace} eq "SiteMap") {
				print "\t\t\tConverting SiteMap ".$wobject->{wobjectId}." into Navigation\n" unless ($quiet);
				my ($starturl) = WebGUI::SQL->quickArray("select urlizedTitle from page 
					where pageId=".quote($namespace->{startAtThisLevel}));
				WebGUI::SQL->setRow("Navigation","assetId",{
					assetId=>$wobjectId,
					endPoint=>$namespace->{depth}||55,
					startPoint=>$starturl,
					startType=>"specificUrl",
					templateId=>"1",
					assetsToInclude=>"descendants"
					},undef,$wobjectId);
				WebGUI::SQL->write("update asset set className='WebGUI::Asset::Wobject::Navigation' where assetId=".quote($wobjectId));
				WebGUI::SQL->write("update wobject set namespace='Navigation'  where assetId=".quote($wobjectId));
			} elsif ($wobject->{namespace} eq "FileManager") {
				print "\t\t\tConverting File Manager ".$wobject->{wobjectId}." into File Folder Layout\n" unless ($quiet);
				WebGUI::SQL->write("update asset set className='WebGUI::Asset::Folder' where assetId=".quote($wobjectId));
				WebGUI::SQL->write("insert into Folder (assetId,templateId) values (".quote($wobjectId).", '15')");
				WebGUI::SQL->write("update wobject set namespace='Folder' where wobjectId=".quote($wobject->{wobjectId}));
				print "\t\t\tMigrating attachments for File Manager ".$wobject->{wobjectId}."\n" unless ($quiet);
				my $sth = WebGUI::SQL->read("select * from FileManager_file where wobjectId=".quote($wobjectId)." order by sequenceNumber");
				my $rank = 1;
				while (my $data = $sth->hashRef) {
					foreach my $field ("downloadFile","alternateVersion1","alternateVersion2") {
						next if ($data->{$field} eq "");
						print "\t\t\t\tMigrating file ".$data->{$field}." (".$data->{FileManager_fileId}.")\n" unless ($quiet);
						my $newId = WebGUI::Id::generate();
						my $storageId = copyFile($data->{$field},$wobject->{wobjectId}.'/'.$data->{FileManager_fileId});
						my $class;
						if (isIn(getFileExtension($data->{$field}), qw(jpg jpeg gif png))) {
							copyFile('thumb-'.$data->{$field},$wobject->{wobjectId}.'/'.$data->{FileManager_fileId},$storageId);
							WebGUI::SQL->write("insert into ImageAsset (assetId, thumbnailSize, parameters) values 
								(".quote($newId).",
								".quote($session{setting}{thumbnailSize}).", ".quote('alt="'.$wobject->{title}.'"').")");
							$class = 'WebGUI::Asset::File::Image';
						} else {
							$class = 'WebGUI::Asset::File';
						}
						WebGUI::SQL->write("insert into FileAsset (assetId, filename, storageId) values (
							".quote($newId).", ".quote($data->{$field}).", ".quote($storageId).")");
						WebGUI::SQL->write("insert into asset (assetId, parentId, lineage, className, state, title, menuTitle, 
							url, startDate, endDate, isHidden, ownerUserId, groupIdView, groupIdEdit, synopsis, assetSize
							) values (".
							quote($newId).", ".quote($wobjectId).", ".quote($wobjectLineage.sprintf("%06d",1)).", 
							'".$class."','published',".quote($data->{fileTitle}).", ".
							quote($data->{fileTitle}).", ".quote(fixUrl($newId,$wobjectUrl.'/'.$data->{$field})).", 
							".quote($wobject->{startDate}).", ".quote($wobject->{endDate}).", 1, ".quote($ownerId).", 
							".quote($data->{groupToView}).", ".quote($groupIdEdit).", ".quote($data->{briefSynopsis}).",
							".quote(getFileSize($storageId,$data->{$field})).")");
						$rank++;
					}
				}
				$sth->finish;
				rmtree($session{config}{uploadsPath}.$session{os}{slash}.$wobject->{wobjectId});
			} elsif ($wobject->{namespace} eq "Product") {
				print "\t\t\tMigrating information for Product ".$wobject->{wobjectId}."\n" unless ($quiet);
			    my ($newProductStoreId);
				# do a check to see if they've installed Image::Magick
                my  $hasImageMagick = 1;
                eval " use Image::Magick; "; $hasImageMagick=0 if $@;
			    # migrate attachments to file storage
				if($namespace->{image1}){
				   $newProductStoreId = copyFile($namespace->{image1},$wobject->{wobjectId});
				   copyFile("thumb-$namespace->{image1}",$wobject->{wobjectId},$newProductStoreId);
				   WebGUI::SQL->write("update Product set image1=".quote($newProductStoreId)." where wobjectId=".quote($wobject->{wobjectId}));
				}
				if($namespace->{image2}){
				   $newProductStoreId = copyFile($namespace->{image2},$wobject->{wobjectId});
				   copyFile("thumb-$namespace->{image2}",$wobject->{wobjectId},$newProductStoreId);
				   WebGUI::SQL->write("update Product set image2=".quote($newProductStoreId)." where wobjectId=".quote($wobject->{wobjectId}));
				}
				if($namespace->{image3}){
				   $newProductStoreId = copyFile($namespace->{image3},$wobject->{wobjectId});
				   copyFile("thumb-$namespace->{image3}",$wobject->{wobjectId},$newProductStoreId);
				   WebGUI::SQL->write("update Product set image3=".quote($newProductStoreId)." where wobjectId=".quote($wobject->{wobjectId}));
				}
				if($namespace->{manual}){
				   $newProductStoreId = copyFile($namespace->{manual},$wobject->{wobjectId});
				   WebGUI::SQL->write("update Product set manual=".quote($newProductStoreId)." where wobjectId=".quote($wobject->{wobjectId}));
				}
				if($namespace->{brochure}){
				   $newProductStoreId = copyFile($namespace->{brochure},$wobject->{wobjectId});
				   WebGUI::SQL->write("update Product set brochure=".quote($newProductStoreId)." where wobjectId=".quote($wobject->{wobjectId}));
				}
				if($namespace->{warranty}){
				   $newProductStoreId = copyFile($namespace->{warranty},$wobject->{wobjectId});
				   WebGUI::SQL->write("update Product set warranty=".quote($newProductStoreId)." where wobjectId=".quote($wobject->{wobjectId}));
				}
				print "\t\t\tMigrating product collateral data\n" unless ($quiet);
				foreach my $table (qw(Product_accessory Product_benefit Product_feature Product_related Product_specification)) {
					WebGUI::SQL->write("update $table set assetId=".quote($wobjectId)." where wobjectId=".quote($wobject->{wobjectId}));
				}
			} elsif ($wobject->{namespace} eq "USS") {
				print "\t\t\tConverting USS to collaboration system ".$wobject->{wobjectId}."\n" unless ($quiet);
				WebGUI::SQL->write("update asset set className='WebGUI::Asset::Wobject::Collaboration' where assetId=".quote($wobjectId));
				my $moderate = ($namespace->{defaultStatus} eq 'Approved') ? 0 : 1;
				my $master = WebGUI::SQL->quickHashRef("select * from forum where forumId=".quote($wobject->{forumId}));
				my $sg = WebGUI::Group->new("new");
				$sg->description("The group to store subscriptions for the collaboration system $wobjectId");
				$sg->name($wobjectId);
				$sg->showInForms(0);
				$sg->isEditable(0);
				$sg->deleteGroups(['3']);
				WebGUI::SQL->write("insert into Collaboration (assetId,postGroupId,moderateGroupId,moderatePosts,karmaPerPost,
					collaborationTemplateId, threadTemplateId, postFormTemplateId, searchTemplateId, notificationTemplateId,
					sortBy, sortOrder, usePreview, addEditStampToPosts, editTimeout, attachmentsPerPost, allowRichEdit, filterCode,
					useContentFilter, rating, archiveAfter, postsPerPage, threadsPerPage, subscriptionGroupId,
					allowReplies) values (".quote($wobjectId).", ".quote($namespace->{groupToContribute}).", 
					".quote($namespace->{groupToApprove}).", $moderate, ".quote($namespace->{karmaPerSubmission}).", 
					".quote($wobject->{templateId}).", ".quote($namespace->{submissionTemplateId}).", 
					".quote($namespace->{submissionFormTemplateId}).", ".quote($master->{searchTemplateId}||1).", 
					".quote($master->{notificationTemplateId}||1)." , ".quote($namespace->{sortBy}).",
					".quote($namespace->{sortOrder}).", 0, 0, 931536000, 2, 1, ".quote($namespace->{filterContent}).",
					0, 0, ".quote($master->{archiveAfter}||31536000).", ".quote($master->{postsPerPage}||10).", 
					".quote($namespace->{submissionsPerPage}).", ".quote($sg->groupId).",
					".quote($wobject->{allowDiscussion}).")");
				WebGUI::SQL->write("update wobject set namespace='Collaboration' where wobjectId=".quote($wobject->{wobjectId}));
				print "\t\t\tMigrating submissions for USS ".$wobject->{wobjectId}."\n" unless ($quiet);
				my $ussId = $namespace->{USS_id};
				my $usssubrank = 1;
				my $collabReplyCounter;
				my $collabViewCounter;
				my $collabThreadCounter;
				my %oldestForumPost;
				my $sth = WebGUI::SQL->read("select * from USS_submission where USS_id=".quote($ussId));
				while (my $submission = $sth->hashRef) {
					$collabThreadCounter++;
					$collabViewCounter += $submission->{views};
					print "\t\t\t\tMigrating submission ".$submission->{USS_submissionId}."\n" unless ($quiet);
					my $body = $submission->{content};
                			$body =~ s/\n/\^\-\;/ unless ($body =~ m/\^\-\;/);
                			my @content = split(/\^\-\;/,$body);
					$content[0] = WebGUI::HTML::filter($content[0],"none");
					$body =~ s/\^\-\;/\n/;
					my $threadLineage = $wobjectLineage.sprintf("%06d",$usssubrank);
					my $id = WebGUI::SQL->setRow("asset","assetId",{
						assetId => "new",
						title => $submission->{title},
						menuTitle => $submission->{title},
						startDate => $submission->{startDate},
						endDate => $submission->{endDate},
						url => fixUrl('notknownyet',$submission->{title}),
						className=>'WebGUI::Asset::Post::Thread',
						state=>'published',
						ownerUserId=>$submission->{userId},
						groupIdView=>$page->{groupIdView},
						groupIdEdit=>$page->{groupIdEdit},
						synopsis=>$content[0],
						assetSize=>length($submission->{content}),
						parentId=>$wobjectId,
						lineage=>$threadLineage,
						isHidden => 1
						});	
					WebGUI::SQL->setRow("Post","assetId",{
						assetId=>$id,
						threadId=>$id,
						dateSubmitted=>$submission->{dateSubmitted},
						dateUpdated=>$submission->{dateUpdated},
						username=>$submission->{username},
						content=>$body,
						status=>lc($submission->{status}),
						views=>$submission->{views},
						contentType=>$submission->{contentType},
						userDefined1=>$submission->{userDefined1},
						userDefined2=>$submission->{userDefined2},
						userDefined3=>$submission->{userDefined3},
						userDefined4=>$submission->{userDefined4},
						userDefined5=>$submission->{userDefined5},
						rating=>0
						},undef,$id);
					my $threadSubscriptionGroup = WebGUI::Group->new("new");
					$threadSubscriptionGroup->description("The group to store subscriptions for the thread $id");
					$threadSubscriptionGroup->name($id);
					$threadSubscriptionGroup->showInForms(0);
					$threadSubscriptionGroup->isEditable(0);
					$threadSubscriptionGroup->deleteGroups(['3']);
					WebGUI::SQL->setRow("Thread","assetId",{
						assetId=>$id,
						isLocked=>0,
						isSticky=>0,
						subscriptionGroupId=>$threadSubscriptionGroup->groupId
						}, undef, $id);
					my %oldestThreadPost;
					my $postRank = 1;
					my $threadReplyCounter;
					my $posts = WebGUI::SQL->read("select forumPost.* from forumPost left join forumThread on forumPost.forumThreadId=forumThread.forumThreadId where forumId=".quote($submission->{forumId}));
					while (my $post = $posts->hashRef) {
						$collabViewCounter += $post->{views};
						$threadReplyCounter++;
						my $postId = WebGUI::SQL->setRow("asset","assetId",{
							assetId=>"new",
							parentId=>$id,
							lineage=>$threadLineage.sprintf("%06d",$postRank),
							state=>'published',
							className=>'WebGUI::Asset::Post',
							title=>$post->{subject},
							menuTitle=>$post->{subject},
							url=>fixUrl("noneyet",$wobject->{title}.'/'.$submission->{title}.'/'.$post->{subject}),
							startDate=>$submission->{startDate},
							endDate=>$submission->{endDate},
							ownerUserId=>$post->{userId},
							groupIdView=>$page->{groupIdView},
							groupIdEdit=>$page->{groupIdEdit},
							isHidden=>1,
							lastUpdated=>$post->{dateOfPost},
							lastUpdatedBy=>$post->{userId}
							});
						if ($oldestThreadPost{date} < $post->{dateOfPost}) {
							$oldestThreadPost{date} = $post->{dateOfPost};
							$oldestThreadPost{id} = $postId;
						}
						WebGUI::SQL->setRow("Post","assetId",{
							assetId=>$postId,
							threadId=>$id,
							dateSubmitted=>$post->{dateOfPost},
							dateUpdated=>$post->{dateOfPost},
							username=>$post->{username},
							content=>$post->{message},
							status=>$post->{status},
							views=>$post->{views},
							contentType=>$post->{contentType},
							rating=>$post->{rating}
							},undef,$postId);
						$postRank++;
						if ($submission->{image}) {
							my $storageId = copyFile($submission->{image},$wobject->{wobjectId}.$session{os}{slash}.$submission->{USS_submissionId});
							copyFile('thumb-'.$submission->{image},$wobject->{wobjectId}.$session{os}{slash}.$submission->{USS_submissionId},$storageId);
						}
						if ($submission->{attachment}) {
							my $storageId = copyFile($submission->{attachment},$wobject->{wobjectId}.$session{os}{slash}.$submission->{USS_submissionId});
						}
					}
					$posts->finish;
					WebGUI::SQL->setRow("Thread","assetId",{
						assetId=>$id,
						lastPostId=>$oldestThreadPost{id},
						lastPostDate=>$oldestThreadPost{date},
						replies=>$threadReplyCounter
						});
					$usssubrank++;
					$collabReplyCounter += $threadReplyCounter;
					if ($oldestForumPost{date} < $oldestThreadPost{date}) {
						$oldestForumPost{date} = $oldestThreadPost{date};
						$oldestForumPost{id} = $oldestThreadPost{id};
					}
				}
				rmtree($session{config}{uploadsPath}.$session{os}{slash}.$wobject->{wobjectId});
				WebGUI::SQL->setRow("Collaboration","assetId",{
					assetId=>$wobjectId,
					lastPostId=>$oldestForumPost{id},
					lastPostDate=>$oldestForumPost{date},
					replies=>$collabReplyCounter,	
					views=>$collabViewCounter,
					threads=>$collabThreadCounter
					});
			} elsif ($wobject->{namespace} eq "WobjectProxy") {
				WebGUI::SQL->write("update WobjectProxy set description=".quote($wobject->{description})." where
					assetId=".quote($wobjectId));
			} elsif ($wobject->{namespace} eq "MessageBoard") {
				print "\t\t\tMigrating Message Board forums\n" unless ($quiet);
				my $forums = WebGUI::SQL->read("select forumId, title, description from MessageBoard_forums where wobjectId=".quote($wobject->{wobjectId})." order by sequenceNumber");
				my $i = 1;
				while (my ($fid, $title, $desc) = $forums->array) {
					migrateForum($fid,$wobjectId,$wobjectLineage,$i, $title,$desc,
						$wobject->{startDate}, $wobject->{endDate}, $wobject->{ownerId}, $wobject->{groupIdEdit},
						$page->{styleId}, $page->{printableStyleId});
					$i++;
				}
				$forums->finish;
			} elsif (isIn($wobject->{namespace}, qw(DataForm Poll))) {
				print "\t\t\tMigrating wobject collateral data\n" unless ($quiet);
				foreach my $table (qw(DataForm_entry DataForm_entryData DataForm_field DataForm_tab Poll_answer)) {
					WebGUI::SQL->write("update $table set assetId=".quote($wobjectId)." where wobjectId=".quote($wobject->{wobjectId}));
				}
			} elsif ($wobject->{namespace} eq "EventsCalendar") {
				print "\t\t\tMigrating Events Calendar ".$wobject->{wobjectId}." and its Events\n" unless ($quiet);
				my $wobjectId = $namespace->{wobjectId};
				my $sth = WebGUI::SQL->read("select * from EventsCalendar_event where wobjectId=".quote($wobjectId));
				my $calendar = WebGUI::Asset->newByDynamicClass($wobjectId,"WebGUI::Asset::Wobject::EventsCalendar");
				# This is definitely not finished!!!!!!   nor even tested!!!!   yikes!!!
#				while (my $event = $sth->hashRef) {
#					#Migrate each event to an asset.
#					my $eventObject = $calendar->addChild({
#						className=>'WebGUI::Asset::Event',
#						title=>$event->{name},
#						menuTitle=>$event->{name},
#						isHidden=>1,
#						newWindow=>0,
#						startDate=>$calendar->getValue("startDate"),
#						endDate=>$calendar->getValue("endDate"),
#						ownerUserId=>$calendar->getValue("ownerUserId"),
#						groupIdEdit=>$calendar->getValue("groupIdEdit"),
#						groupIdView=>$calendar->getValue("groupIdView"),
#						url=>$event->fixUrl($calendar->getUrl().'/'.$namespace->{name}),
#						templateId=>$calendar->getValue("eventTemplateId")
#					});
#					WebGUI::SQL->write("update EventsCalendar_event set assetId=".quote($eventObject->getId)." where EventsCalendar_eventId=".quote($event->{EventsCalendar_eventId}));
					# I'm sure there's something else I'm forgetting...
			#	}
			}
			$rank++;
		}
		$b->finish;
		if ($className eq "WebGUI::Asset::Wobject::Layout") { # Let's position some content
			my $positions;
			my $last = 1;
			my @assets;
			my @positions;
			my $b = WebGUI::SQL->read("select assetId, templatePosition from wobject where pageId=".quote($page->{pageId})."
				order by templatePosition, sequenceNumber");
			while (my ($assetId, $position) = $b->array) {
				if ($position ne $last) {
					push(@positions,join(",",@assets));
					@assets = ();
				}
				$last = $position;
				push(@assets,$assetId);
			}
			$b->finish;
			my $contentPositions = join("\.",@positions);
			WebGUI::SQL->write("update Layout set contentPositions=".quote($contentPositions)." where assetId=".quote($pageId));
		}
		if ($page->{parentId} eq "5") {
			WebGUI::SQL->write("update asset set isPackage=1 where assetId=".quote($pageId));
		}
		walkTree($page->{pageId},$pageId,$pageLineage,$rank);
		$myRank++;
	}
	$a->finish;
}


sub migrateForum {
	my $originalId = shift;
	print "\t\t\t\t Migrating forum $originalId\n";
	my $newParentId = shift;
	my $newParentLineage = shift;
	my $rank = shift;
	my $title = shift;
	my $description = shift;
	my $startDate = shift;
	my $endDate = shift;
	my $userId = shift;
	my $editGroup = shift;
	my $styleId = shift;
	my $printId = shift;
	my $lineage = $newParentLineage.sprintf("%06d",$rank);
	my $data = WebGUI::SQL->quickHashRef("select * from forum where forumId=".quote($originalId));
	if ($data->{masterForumId}) {
		my $master = WebGUI::SQL->quickHashRef("select * from forum where forumId=".quote($data->{masterForumId}));
		$data->{forumTemplateId} = $master->{forumTemplateId};
                $data->{threadTemplateId} = $master->{threadTemplateId};
                $data->{postTemplateId} = $master->{postTemplateId};
                $data->{searchTemplateId} = $master->{searchTemplateId};
                $data->{notificationTemplateId} = $master->{notificationTemplateId};
                $data->{postFormTemplateId} = $master->{postFormTemplateId};
                $data->{postPreviewTemplateId} = $master->{postPreviewTemplateId};
                $data->{archiveAfter} = $master->{archiveAfter};
                $data->{allowRichEdit} = $master->{allowRichEdit};
                $data->{allowReplacements} = $master->{allowReplacements};
                $data->{filterPosts} = $master->{filterPosts};
                $data->{karmaPerPost} = $master->{karmaPerPost};
                $data->{groupToView} = $master->{groupToView};
                $data->{groupToPost} = $master->{groupToPost};
                $data->{groupToView} = $master->{groupToView};
                $data->{groupToModerate} = $master->{groupToModerate};
                $data->{moderatePosts} = $master->{moderatePosts};
                $data->{attachmentsPerPost} = $master->{attachmentsPerPost};
                $data->{addEditStampToPosts} = $master->{addEditStampsToPost};
                $data->{postsPerPage} = $master->{postsPerPage};
                $data->{usePreview} = $master->{usePreview};
	}
	my $viewGroup = $data->{groupToView};
	my $newId = WebGUI::SQL->setRow("asset","assetId",{
		assetId=>"new",
		parentId=>$newParentId,
		lineage=>$lineage,
		state=>'published',
		className=>'WebGUI::Asset::Wobject::Collaboration',
		title=>$title,
		menuTitle=>$title,
		url=>fixUrl("noneyet",$title),
		startDate=>$startDate,
		endDate=>$endDate,
		ownerUserId=>$userId,
		groupIdView=>$viewGroup,
		groupIdEdit=>$editGroup,
		isHidden=>1,
		lastUpdated=>time(),
		lastUpdatedBy=>'3'});
	WebGUI::SQL->setRow("wobject","assetId",{
		assetId=>$newId,
		description=>$description,
		styleTemplateId=>$styleId,
		printableStyleTemplateId=>$printId
		},undef,$newId);
	print "\t\t\t\t\t Migrating subscriptions for forum $originalId\n";
	my $subscriptionGroup = WebGUI::Group->new("new");
	$subscriptionGroup->description("The group to store subscriptions for the collaboration system $newId");
	$subscriptionGroup->name($newId);
	$subscriptionGroup->showInForms(0);
	$subscriptionGroup->isEditable(0);
	$subscriptionGroup->deleteGroups(['3']);
	my $sth = WebGUI::SQL->read("select userId from forumSubscription where forumId=".quote($originalId));
	my @users;
	while (my ($uid) = $sth->array) {
		push(@users,$uid);
	}
	$sth->finish;
	$subscriptionGroup->addUsers(\@users);
	WebGUI::SQL->setRow("Collaboration","assetId", {
		postGroupId=>$data->{groupToPost},
		moderateGroupId=>$data->{groupToModerate},
		moderatePosts=>$data->{moderatePosts},
		karmaPerPost=>$data->{karmaPerPost},
		collaborationTemplateId=>$data->{forumTemplateId},
		threadTemplateId=>$data->{threadTemplateId},
		postFormTemplateId=>$data->{postformTemplateId},
		searchTemplateId=>$data->{searchTemplateId},
		notificationTemplateId=>$data->{notificationTemplateId},
		sortBy=>$data->{sortBy},
		sortOrder=>$data->{sortOrder},
		usePreview=>$data->{usePreview},
		addEditStampToPosts=>$data->{addEditStampToPosts},
		editTimeout=>$data->{editTimeout},
		attachmentsPerPost=>$data->{attachmentsPerPost},
		allowRichEdit=>$data->{allowRichEdit},
		filterCode=>$data->{filterPosts},
		useContentFilter=>$data->{allowReplacements},
		threads=>$data->{threads},
		views=>$data->{views},
		replies=>$data->{replies},
		rating=>$data->{rating},
		archiveAfter=>$data->{archiveAfter},
		postsPerPage=>$data->{postsPerPage},
		threadsPerPage=>$data->{threadsPerPage},
		subscriptionGroupId=>$subscriptionGroup->groupId,
		allowReplies=>1
		},undef,$newId);
	my %oldestForumPost;
	my $ratingprep = WebGUI::SQL->prepare("insert into Post_rating (assetId, userId, ipAddress, dateOfRating, rating) values (?,?,?,?,?)");
	print "\t\t\t\t\t Migrating threads for forum $originalId\n";
	my $threads = WebGUI::SQL->read("select * from forumThread left join forumPost on forumThread.rootPostId=forumPost.forumPostId where
		forumThread.forumId=".quote($originalId)." and forumPost.status<>'deleted'");
	my $threadRank = 1;
	if ($threads->errorCode>0) {
		print "\t\t\t\tWARNING: There was a problem migrating the threads for $originalId\n";
		return;
	}
	while (($threads->errorCode < 1) && (my ($thread) = $threads->hashRef)) {
		next if ($thread->{forumThreadId} eq "");
		print "\t\t\t\t\t\t Migrating thread ".$thread->{forumThreadId}."\n";
		my $threadLineage = $lineage.sprintf("%06d",$threadRank);
		my $threadId = WebGUI::SQL->setRow("asset","assetId",{
			assetId=>"new",
			parentId=>$newId,
			lineage=>$threadLineage,
			state=>'published',
			className=>'WebGUI::Asset::Post::Thread',
			title=>$thread->{subject},
			menuTitle=>$thread->{subject},
			url=>fixUrl("noneyet",$title.'/'.$thread->{subject}),
			startDate=>$startDate,
			endDate=>$endDate,
			ownerUserId=>$thread->{userId},
			groupIdView=>$viewGroup,
			groupIdEdit=>$editGroup,
			isHidden=>1,
			lastUpdated=>$thread->{dateOfPost},
			lastUpdatedBy=>$thread->{userId}
			});
		WebGUI::SQL->setRow("Post","assetId",{
			assetId=>$threadId,
			threadId=>$threadId,
			dateSubmitted=>$thread->{dateOfPost},
			dateUpdated=>$thread->{dateOfPost},
			username=>$thread->{username},
			content=>$thread->{message},
			status=>$thread->{status},
			views=>$thread->{views},
			contentType=>$thread->{contentType},
			rating=>$thread->{rating}
			},undef,$threadId);
		my $threadSubscriptionGroup = WebGUI::Group->new("new");
		$threadSubscriptionGroup->description("The group to store subscriptions for the thread $threadId");
		$threadSubscriptionGroup->name($threadId);
		$threadSubscriptionGroup->showInForms(0);
		$threadSubscriptionGroup->isEditable(0);
		$threadSubscriptionGroup->deleteGroups(['3']);
		my $sth = WebGUI::SQL->read("select userId from forumThreadSubscription where forumThreadId=".quote($thread->{forumThreadId}));
		my @users;
		while (my ($uid) = $sth->array) {
			push(@users,$uid);
		}
		$sth->finish;
		$threadSubscriptionGroup->addUsers(\@users);
		WebGUI::SQL->setRow("Thread","assetId",{
			assetId=>$threadId,
			replies=>$thread->{replies},
			isLocked=>$thread->{isLocked},
			isSticky=>$thread->{isSticky},
			subscriptionGroupId=>$threadSubscriptionGroup->groupId
			}, undef, $threadId);
		# we're going to give up hierarchy during the upgrade for the sake of simplicity
		print "\t\t\t\t\t\t Migrating posts for thread ".$thread->{forumThreadId}."\n";
		my %oldestThreadPost;
		my $posts = WebGUI::SQL->read("select * from forumPost where forumThreadId=".quote($thread->{forumThreadId})." and parentId<>'' and forumPost.status<>'deleted'");
		my $postRank = 1;
		if ($posts->errorCode>0) {
			print "\t\t\t\tWARNING: There was a problem migrating the posts for ".$thread->{forumThreadId}."\n";
			next;
		}
		while (my $post = $posts->hashRef) {
			next if ($thread->{forumPostId} eq "");
			print "\t\t\t\t\t\t\t Migrating post ".$post->{forumPostId}."\n";
			my $postId = WebGUI::SQL->setRow("asset","assetId",{
				assetId=>"new",
				parentId=>$threadId,
				lineage=>$threadLineage.sprintf("%06d",$postRank),
				state=>'published',
				className=>'WebGUI::Asset::Post',
				title=>$post->{subject},
				menuTitle=>$post->{subject},
				url=>fixUrl("noneyet",$title.'/'.$thread->{subject}.'/'.$post->{subject}),
				startDate=>$startDate,
				endDate=>$endDate,
				ownerUserId=>$post->{userId},
				groupIdView=>$viewGroup,
				groupIdEdit=>$editGroup,
				isHidden=>1,
				lastUpdated=>$post->{dateOfPost},
				lastUpdatedBy=>$post->{userId}
				});
			if ($oldestThreadPost{date} < $post->{dateOfPost}) {
				$oldestThreadPost{date} = $post->{dateOfPost};
				$oldestThreadPost{id} = $postId;
			}
			WebGUI::SQL->setRow("Post","assetId",{
				assetId=>$postId,
				threadId=>$threadId,
				dateSubmitted=>$post->{dateOfPost},
				dateUpdated=>$post->{dateOfPost},
				username=>$post->{username},
				content=>$post->{message},
				status=>$post->{status},
				views=>$post->{views},
				contentType=>$post->{contentType},
				rating=>$post->{rating}
				},undef,$postId);
			print "\t\t\t\t\t\t\t\t Migrating ratings for post ".$post->{forumPostId}."\n";
			my $ratings = WebGUI::SQL->read("select userId,ipAddress,dateOfRating,rating from forumPostRating where forumPostId=".quote($post->{forumPostId}));
			while (my ($uid,$ip,$date,$rating) = $ratings->array) {
				$ratingprep->execute([$postId,$uid,$ip,$date,$rating]);
			}
			$ratings->finish;
			$postRank++;
		}
		$posts->finish;
		print "\t\t\t\t\t\t\t Setting oldest post for thread ".$thread->{forumThreadId}."\n";
		WebGUI::SQL->setRow("Thread","assetId",{
			assetId=>$threadId,
			lastPostId=>$oldestThreadPost{id},
			lastPostDate=>$oldestThreadPost{date}
			});
		if ($oldestForumPost{date} < $oldestThreadPost{date}) {
			$oldestForumPost{date} = $oldestThreadPost{date};
			$oldestForumPost{id} = $oldestThreadPost{id};
		}
		$threadRank++;
	}
	print "\t\t\t\t WARNING: Couldn't finish processing threads for $originalId because something nasty occured in the database." if ($threads->errorCode > 0);
	$threads->finish;
	$ratingprep->finish;
	print "\t\t\t\t\t\t Setting oldest post for forum ".$originalId."\n";
	WebGUI::SQL->setRow("Collaboration","assetId",{
		assetId=>$newId,
		lastPostId=>$oldestForumPost{id},
		lastPostDate=>$oldestForumPost{date}
		});
}

sub fixUrl {
	my $id = shift;
        my $url = shift;
	if (length($url) > 250) {
		$url = substr($url,220);
	}
        $url = WebGUI::URL::urlize($url);
	$url = WebGUI::Id::generate() unless (defined $url && $url ne "");
        my ($test) = WebGUI::SQL->quickArray("select url from asset where assetId<>".quote($id)." and url=".quote($url));
        if ($test) {
                my @parts = split(/\./,$url);
                if ($parts[0] =~ /(.*)(\d+$)/) {
                        $parts[0] = $1.($2+1);
                } elsif ($test ne "") {
                        $parts[0] .= "2";
                }
                $url = join(".",@parts);
                $url = fixUrl($id,$url);
        }
	$url = WebGUI::Id::generate() unless (defined $url && $url ne ""); #check one last time to make sure we don't have an empty url
        return $url;
}

sub copyFile {
	my $filename = shift;
	my $oldPath = shift;
	my $id = shift || WebGUI::Id::generate();
	$id =~ m/^(.{2})(.{2})/;
	my $node = $session{config}{uploadsPath}.$session{os}{slash}.$1;
	mkdir($node);
	$node .= $session{os}{slash}.$2;
	mkdir($node);
	$node .= $session{os}{slash}.$id;
	mkdir($node);
	my $a = FileHandle->new($session{config}{uploadsPath}.$session{os}{slash}.$oldPath.$session{os}{slash}.$filename,"r");
	if (defined $a) {
   	    	binmode($a);
        	my $b = FileHandle->new(">".$node.$session{os}{slash}.$filename);
		if (defined $b) {
			print "Moving File".$session{config}{uploadsPath}.$session{os}{slash}.$oldPath.$session{os}{slash}.$filename."\n";
        		binmode($b);
        		copy($a,$b);
		}
	}
	return $id;
}

sub getNextLineage {
	my $assetId = shift;
	my ($startLineage) = WebGUI::SQL->quickArray("select lineage from asset where parentId='".$assetId."' order by lineage desc limit 1");
	$startLineage = '000001000001000000' unless ($startLineage);
	my $rank = substr($startLineage,12,6);
	my $parentLineage = substr($startLineage,0,12);
	return $parentLineage.sprintf("%06d",($rank+1));
}

sub getFileSize {
	my $id = shift;
	my $filename = shift;
	$id =~ m/^(.{2})(.{2})/;
	my $path = $session{config}{uploadsPath}.$session{os}{slash}.$1.$session{os}{slash}.$2.$session{os}{slash}.$id.$session{os}{slash}.$filename;
	my (@attributes) = stat($path);
	return $attributes[7] || 0;
}

sub getFileExtension {
	my $filename = shift;
        my $extension = lc($filename);
        $extension =~ s/.*\.(.*?)$/$1/;
        return $extension;
}

sub isIn {
        my $key = shift;
        $_ eq $key and return 1 for @_;
        return 0;
}


sub getNewId {
	my $type = shift;
	my $oldId = shift;
	my $namespace = shift;
	my $migration = {'tmpl' => {
                      'Operation/MessageLog/View' => {
                                                       '1' => 'PBtmpl0000000000000050'
                                                     },
                      'Collaboration/Search' => {
                                          '1' => 'PBtmpl0000000000000031'
                                        },
                      'Auth/WebGUI/Account' => {
                                                 '1' => 'PBtmpl0000000000000010'
                                               },
                      'MessageBoard' => {
                                          '1' => 'PBtmpl0000000000000047'
                                        },
                      'Operation/Profile/View' => {
                                                    '1' => 'PBtmpl0000000000000052'
                                                  },
                      'Operation/RedeemSubscription' => {
                                                          '1' => 'PBtmpl0000000000000053'
                                                        },
                      'Navigation' => {
                                        '8' => 'PBtmpl0000000000000136',
                                        '6' => 'PBtmpl0000000000000130',
                                        '1001' => 'PBtmpl0000000000000075',
                                        '4' => 'PBtmpl0000000000000117',
                                        '1' => 'PBtmpl0000000000000048',
                                        '3' => 'PBtmpl0000000000000108',
                                        '7' => 'PBtmpl0000000000000134',
                                        '1000' => 'PBtmpl0000000000000071',
                                        '2' => 'PBtmpl0000000000000093',
                                        '5' => 'PBtmpl0000000000000124'
                                      },
                      'Macro/L_loginBox' => {
                                              '1' => 'PBtmpl0000000000000044',
                                              '2' => 'PBtmpl0000000000000092'
                                            },
                      'Commerce/ConfirmCheckout' => {
                                                      '1' => 'PBtmpl0000000000000016'
                                                    },
                      'prompt' => {
                                    '1' => 'PBtmpl0000000000000057'
                                  },
                      'Auth/SMB/Login' => {
                                            '1' => 'PBtmpl0000000000000009'
                                          },
                      'ImageAsset' => {
                                        '2' => 'PBtmpl0000000000000088'
                                      },
                      'AttachmentBox' => {
                                           '1' => 'PBtmpl0000000000000003'
                                         },
                      'Poll' => {
                                  '1' => 'PBtmpl0000000000000055'
                                },
                      'FileAsset' => {
                                       '1' => 'PBtmpl0000000000000024'
                                     },
                      'HttpProxy' => {
                                       '1' => 'PBtmpl0000000000000033'
                                     },
                      'Auth/SMB/Create' => {
                                             '1' => 'PBtmpl0000000000000008'
                                           },
                      'Commerce/ViewPurchaseHistory' => {
                                                          '1' => 'PBtmpl0000000000000019'
                                                        },
                      'Article' => {
                                     '6' => 'PBtmpl0000000000000129',
                                     '4' => 'PBtmpl0000000000000115',
                                     '1' => 'PBtmpl0000000000000002',
                                     '3' => 'PBtmpl0000000000000103',
                                     '2' => 'PBtmpl0000000000000084',
                                     '5' => 'PBtmpl0000000000000123'
                                   },
                      'style' => {
                                   '6' => 'PBtmpl0000000000000132',
                                   'adminConsole' => 'PBtmpl0000000000000137',
                                   '3' => 'PBtmpl0000000000000111',
                                   '1' => 'PBtmpl0000000000000060',
                                   '10' => 'PBtmpl0000000000000070'
                                 },
                      'Macro/SubscriptionItem' => {
                                                    '1' => 'PBtmpl0000000000000046'
                                                  },
                      'WSClient' => {
                                      '1' => 'PBtmpl0000000000000069',
                                      '2' => 'PBtmpl0000000000000100'
                                    },
                      'Operation/MessageLog/Message' => {
                                                          '1' => 'PBtmpl0000000000000049'
                                                        },
                      'Auth/SMB/Account' => {
                                              '1' => 'PBtmpl0000000000000007'
                                            },
                      'Survey' => {
                                    '1' => 'PBtmpl0000000000000061'
                                  },
                      'EventsCalendar' => {
                                            '1' => 'PBtmpl0000000000000022',
                                            '3' => 'PBtmpl0000000000000105',
                                            '2' => 'PBtmpl0000000000000086'
                                          },
                      'Macro/AdminToggle' => {
                                               '1' => 'PBtmpl0000000000000036'
                                             },
                      'Auth/LDAP/Create' => {
                                              '1' => 'PBtmpl0000000000000005'
                                            },
                      'Auth/WebGUI/Create' => {
                                                '1' => 'PBtmpl0000000000000011'
                                              },
			'Folder' => {
                                  '15' => 'PBtmpl0000000000000078'
			},
                      'Layout' => {
                                  '6' => 'PBtmpl0000000000000131',
                                  '3' => 'PBtmpl0000000000000109',
                                  '7' => 'PBtmpl0000000000000135',
                                  '2' => 'PBtmpl0000000000000094',
                                  '1' => 'PBtmpl0000000000000054',
                                  '4' => 'PBtmpl0000000000000118',
                                  '5' => 'PBtmpl0000000000000125'
                                },
                      'Macro/H_homeLink' => {
                                              '1' => 'PBtmpl0000000000000042'
                                            },
                      'Collaboration' => {
                                   '25' => 'PBtmpl0000000000000026',
                                 '6' => 'PBtmpl0000000000000133',
                                 '21' => 'PBtmpl0000000000000102',
                                 '3' => 'PBtmpl0000000000000112',
                                 '2' => 'PBtmpl0000000000000097',
                                 '17' => 'PBtmpl0000000000000081',
                                 '20' => 'PBtmpl0000000000000101',
                                 '15' => 'PBtmpl0000000000000079',
                                 '14' => 'PBtmpl0000000000000077',
                                 '4' => 'PBtmpl0000000000000121',
                                 '1' => 'PBtmpl0000000000000066',
                                 '18' => 'PBtmpl0000000000000082',
                                 '16' => 'PBtmpl0000000000000080',
                                 '19' => 'PBtmpl0000000000000083',
                                 '5' => 'PBtmpl0000000000000128'
                               },
                      'AdminConsole' => {
                                          '1' => 'PBtmpl0000000000000001'
                                        },
                      'SQLReport' => {
                                       '1' => 'PBtmpl0000000000000059'
                                     },
                      'Macro/AdminBar' => {
                                            '1' => 'PBtmpl0000000000000035',
                                            '2' => 'PBtmpl0000000000000090'
                                          },
                      'Survey/Gradebook' => {
                                              '1' => 'PBtmpl0000000000000062'
                                            },
                      'DataForm/List' => {
                                           '1' => 'PBtmpl0000000000000021'
                                         },
                      'Macro/GroupDelete' => {
                                               '1' => 'PBtmpl0000000000000041'
                                             },
                      'Product' => {
                                     '4' => 'PBtmpl0000000000000119',
                                     '1' => 'PBtmpl0000000000000056',
                                     '3' => 'PBtmpl0000000000000110',
                                     '2' => 'PBtmpl0000000000000095'
                                   },
                      'Commerce/TransactionError' => {
                                                       '1' => 'PBtmpl0000000000000018'
                                                     },
                      'IndexedSearch' => {
                                           '1' => 'PBtmpl0000000000000034',
                                           '3' => 'PBtmpl0000000000000106',
                                           '2' => 'PBtmpl0000000000000089'
                                         },
                      'Auth/WebGUI/Expired' => {
                                                 '1' => 'PBtmpl0000000000000012'
                                               },
                      'Commerce/SelectPaymentGateway' => {
                                                           '1' => 'PBtmpl0000000000000017'
                                                         },
                      'Macro/File' => {
                                        '1' => 'PBtmpl0000000000000039',
                                        '3' => 'PBtmpl0000000000000107',
                                        '2' => 'PBtmpl0000000000000091'
                                      },
                      'Survey/Overview' => {
                                             '1' => 'PBtmpl0000000000000063'
                                           },
                      'Macro/a_account' => {
                                             '1' => 'PBtmpl0000000000000037'
                                           },
                      'Macro/LoginToggle' => {
                                               '1' => 'PBtmpl0000000000000043'
                                             },
                      'Auth/LDAP/Account' => {
                                               '1' => 'PBtmpl0000000000000004'
                                             },
                      'Survey/Response' => {
                                             '1' => 'PBtmpl0000000000000064'
                                           },
                      'Commerce/CheckoutCanceled' => {
                                                       '1' => 'PBtmpl0000000000000015'
                                                     },
                      'Collaboration/Thread' => {
                                          '25' => 'PBtmpl0000000000000032',
                                            '1' => 'PBtmpl0000000000000067',
                                            '3' => 'PBtmpl0000000000000113',
                                            '2' => 'PBtmpl0000000000000098'
                                          },
                      'Auth/WebGUI/Recovery' => {
                                                  '1' => 'PBtmpl0000000000000014'
                                                },
                      'Macro/r_printable' => {
                                               '1' => 'PBtmpl0000000000000045'
                                             },
                      'Operation/Profile/Edit' => {
                                                    '1' => 'PBtmpl0000000000000051'
                                                  },
                      'SyndicatedContent' => {
                                               '1' => 'PBtmpl0000000000000065'
                                             },
                      'Collaboration/PostForm' => {
                                            '25' => 'PBtmpl0000000000000029',
                                                '4' => 'PBtmpl0000000000000122',
                                                '1' => 'PBtmpl0000000000000068',
                                                '3' => 'PBtmpl0000000000000114',
                                                '2' => 'PBtmpl0000000000000099'
                                              },
                      'EventsCalendar/Event' => {
                                                  '1' => 'PBtmpl0000000000000023'
                                                },
                      'Macro/GroupAdd' => {
                                            '1' => 'PBtmpl0000000000000040'
                                          },
                      'Collaboration/Notification' => {
                                                '1' => 'PBtmpl0000000000000027'
                                              },
                      'Auth/LDAP/Login' => {
                                             '1' => 'PBtmpl0000000000000006'
                                           },
                      'DataForm' => {
                                      '4' => 'PBtmpl0000000000000116',
                                      '1' => 'PBtmpl0000000000000020',
                                      '3' => 'PBtmpl0000000000000104',
                                      '2' => 'PBtmpl0000000000000085'
                                    },
                      'Auth/WebGUI/Login' => {
                                               '1' => 'PBtmpl0000000000000013'
                                             },
                      'richEditor' => {
                                        'tinymce' => 'PBtmpl0000000000000138',
                                        '5' => 'PBtmpl0000000000000126'
                                      },
                      'Macro/EditableToggle' => {
                                                  '1' => 'PBtmpl0000000000000038'
                                                },
                      'richEditor/pagetree' => {
                                                 '1' => 'PBtmpl0000000000000058'
                                               }
                    },
          'nav' => {
                     '11' => 'PBnav00000000000000006',
                     '7' => 'PBnav00000000000000019',
                     '2' => 'PBnav00000000000000014',
                     '17' => 'PBnav00000000000000012',
                     '1' => 'PBnav00000000000000001',
                     '18' => 'PBnav00000000000000013',
                     '16' => 'PBnav00000000000000011',
                     '13' => 'PBnav00000000000000008',
                     '6' => 'PBnav00000000000000018',
                     '3' => 'PBnav00000000000000015',
                     '9' => 'PBnav00000000000000021',
                     '12' => 'PBnav00000000000000007',
                     '14' => 'PBnav00000000000000009',
                     '15' => 'PBnav00000000000000010',
                     '8' => 'PBnav00000000000000020',
                     '4' => 'PBnav00000000000000016',
                     '10' => 'PBnav00000000000000002',
                     '5' => 'PBnav00000000000000017'
                   }
        };
	my $newId;
	if ($type eq "nav") {
		$newId = $migration->{nav}{$oldId};
	} elsif ($type eq "tmpl") {
		$newId = $migration->{tmpl}{$namespace}{$oldId};
	}
	$newId = WebGUI::Id::generate() unless ($newId);
	return $newId;
}

# Frank Dillon 20050201 --
# Converting Product Wobjects to Assets. --
sub mapProductCollateral {
   my $sth = WebGUI::SQL->read("select * from Product_accessory");
   while (my $hash = $sth->hashRef){
      my ($newAssetId) = WebGUI::SQL->quickArray("select assetId from Product where wobjectId=".quote($hash->{AccessoryWobjectId}));
      WebGUI::SQL->write("update Product_accessory set accessoryAssetId=".quote($newAssetId)." where wobjectId=".quote($hash->{wobjectId})." and AccessoryWobjectId=".quote($hash->{AccessoryWobjectId}));
   }
   $sth->finish;
   
   $sth = WebGUI::SQL->read("select * from Product_related");
   while (my $hash = $sth->hashRef){
      my ($newAssetId) = WebGUI::SQL->quickArray("select assetId from Product where wobjectId=".quote($hash->{RelatedWobjectId}));
      WebGUI::SQL->write("update Product_related set relatedAssetId=".quote($newAssetId)." where wobjectId=".quote($hash->{wobjectId})." and RelatedWobjectId=".quote($hash->{RelatedWobjectId}));
   }
   $sth->finish;
}
