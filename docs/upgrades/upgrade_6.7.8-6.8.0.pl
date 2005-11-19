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
use Parse::PlainConfig;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Asset;
use WebGUI::Setting;
use WebGUI::User;
use WebGUI::Utility;

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
#addSpectre();
#addWorkflow();
addMatrix();
updateConfigFile();
addInOuutBoard();
addZipArchive();
finish();

#-------------------------------------------------
sub addZipArchive {
        print "\nAdding Zip Archive Asset\n" unless ($quiet);
	WebGUI::SQL->write("create table ZipArchiveAsset (
   assetId varchar(22) binary not null,
   templateId varchar(22) binary not null default '',
   showPage varchar(255) not null default 'index.html',
   revisionDate bigint not null,
   primary key (assetId,revisionDate)
)");
 	my $import = WebGUI::Asset->getImportNode;
        my $folder = $import->addChild({
                title=>"Zip Archive Templates",
                menuTitle=>"Zip Archive Templates",
                className=>"WebGUI::Asset::Wobject::Folder",
                url=>"ziparchive-templates",
                });
        my $template = <<STOP;
#assetId=ZipArchiveTMPL00000001
#title=Default Zip Archive Template
#namespace=ZipArchiveAsset

<tmpl_if session.var.adminOn>
   <tmpl_if controls>
      <p><tmpl_var controls></p>
   </tmpl_if>
</tmpl_if>

<tmpl_if error>
<ul>
  <li><tmpl_var error></li>
</ul>
</tmpl_if>

<tmpl_if fileUrl>
   <a href="<tmpl_var fileUrl>"><tmpl_var title></a>
<tmpl_else>
  <tmpl_if pageError>
      Error:  No initial page specified
  <tmpl_else>
      Error:  No file specified
  </tmpl_if>
</tmpl_if>	
	STOP
        my $newAsset = $folder->addChild({
                title=>"Default Zip Archive Template",
                menuTitle=>"Default Zip Archive Template",
                namespace=>"ZipArchiveAsset",
                url=>"zip-archive-template",
                className=>"WebGUI::Asset::Template",
                template=>$template
                }, "ZipArchiveTMPL00000001");
        $newAsset->commit;
}

#-------------------------------------------------
sub updateConfigFile {
        print "\tUpdating config file.\n" unless ($quiet);
        my $pathToConfig = '../../etc/'.$configFile;
        my $conf = Parse::PlainConfig->new('DELIM' => '=', 'FILE' => $pathToConfig, 'PURGE'=>1);
        my %newConfig;
        foreach my $key ($conf->directives) { # delete unwanted stuff
                unless (isIn($key,qw(enableDateCache scripturl))) {
                        $newConfig{$key} = $conf->get($key);
                }
        }
	push(@{$newConfig{assets}}, "WebGUI::Asset::Wobject::Matrix");	
	push(@{$newConfig{assets}}, "WebGUI::Asset::Wobject::InOutBoard");	
        $conf->purge;
        $conf->set(%newConfig);
        $conf->write;
}

#-------------------------------------------------
sub addInOutBoard {
	print "\tAdding In/Out Board Asset\n" unless ($quiet);
	WebGUI::SQL->write("create table InOutBoard ( 
        assetId varchar(22) binary not null primary key,
	revisionDate bigint,
        statusList text,
        reportViewerGroup varchar(22) binary not null default '3',
        inOutGroup varchar(22) binary not null default '2',
        inOutTemplateId varchar(22) binary not null default 'IOB0000000000000000001',
        reportTemplateId varchar(22) binary not null default 'IOB0000000000000000002',
        paginateAfter int not null default 50,
        reportPaginateAfter int not null default 50
	)");
	WebGUI::SQL->write("create table InOutBoard_status (
        assetId varchar(22) binary  not null,
        userId varchar(22) binary not null,
        status varchar(255),
        dateStamp int not null,
        message text
	)");
	WebGUI::SQL->write("create table InOutBoard_statusLog (
        assetId varchar(22) binary not null,
        userId varchar(22) binary not null,
        status varchar(255),
        dateStamp int not null,
        message text
	)");
	WebGUI::SQl->write("insert into userProfileField (fieldName,fieldLabel,visible,dataType,dataValues,dataDefault,sequenceNumber,profileCategoryId,editable) values ('department',".quote("'Department'").",1,'selectList',".quote("{'IT'=>'IT','HR'=>'HR','Regular Staff'=>'Regular Staff'}").",".quote("['Regular Staff']").",8,'6',1)");
	my $import = WebGUI::Asset->getImportNode;
	my $folder = $import->addChild({
		title=>"In/Out Board Templates",
		menuTitle=>"In/Out Board Templates",
		className=>"WebGUI::Asset::Wobject::Folder",
		url=>"iob-templates",
		});
	my $template = <<STOP;
<h1>In/Out Board Report</h1>
   <tmpl_var form><br />
   <tmpl_if showReport>
   <table width=100% cellpadding=3 cellspacing=0 border=1>
   <tr>
   <th><tmpl_var username.label></th>
   <th><tmpl_var status.label></th>
   <th><tmpl_var date.label></th>
   <th><tmpl_var message.label></th>
   <th><tmpl_var updatedBy.label></th>
   </tr>
   <tmpl_loop rows_loop>
   <tmpl_if deptHasChanged>
   <tr><td colspan=5><b><tmpl_var department></b></td></tr>
   </tmpl_if>
   <tr>
   <td><tmpl_var username></td>
   <td><tmpl_var status></td>
   <td><tmpl_var dateStamp></td>
   <td><tmpl_var message></td>
   <td><tmpl_var createdBy></td>
   </tr>
   </tmpl_loop>
   <tr><td colspan=5><tmpl_var paginateBar></td></tr>
   </table>
   </tmpl_if>
STOP
	my $newAsset = $folder->addChild({
		title=>"Default InOutBoard Report Template",
		menuTitle=>"Default InOutBoard Report Template",
		namespace=>"InOutBoard/Report",
		url=>"iob-report-template",
		className=>"WebGUI::Asset::Template",
		template=>$template
		}, "IOB0000000000000000002");
	$newAsset->commit;
	my $template = <<STOP;
<a name="<tmpl_var id>"></a>
<tmpl_if session.var.adminOn>
   <p><tmpl_var controls></p>
</tmpl_if>

<tmpl_if displayTitle> 
   <h1><tmpl_var title></h1> 
</tmpl_if> 

<tmpl_var description>

<tmpl_if selectDelegatesURL>
   <a href="<tmpl_var selectDelegatesURL>">Select delegates</a>
</tmpl_if>
<tmpl_if canViewReport>
   <tmpl_if selectDelegatesURL>
      &nbsp;&middot;&nbsp;
   </tmpl_if>
   <a href="<tmpl_var viewReportURL>">View Report</a>
</tmpl_if>
<tmpl_if displayForm>
   <tmpl_var form><br />
</tmpl_if>
   
   <table width=100% cellpadding=3 cellspacing=0 border=1>
   <tmpl_loop rows_loop>
   <tmpl_if deptHasChanged>
   <tr><td colspan=4><b><tmpl_var department></b></td></tr>
   </tmpl_if>
   <tr>
   <td><tmpl_var username></td>
   <td><tmpl_var status></td>
   <td><tmpl_var dateStamp></td>
   <td><tmpl_var message></td>
   </tr>
   </tmpl_loop>
   <tr><td colspan=4><tmpl_var paginateBar></td></tr>
   </table>
STOP
	my $newAsset = $folder->addChild({
		title=>"Default InOutBoard Template",
		menuTitle=>"Default InOutBoard Template",
		namespace=>"InOutBoard",
		url=>"iob-template",
		className=>"WebGUI::Asset::Template",
		template=>$template
		}, "IOB0000000000000000001");
	$newAsset->commit;
}

#-------------------------------------------------
sub addMatrix {
	print "\tAdding Matrix Asset\n" unless ($quiet);
	WebGUI::SQL->write("CREATE TABLE `Matrix_rating` (
  `timeStamp` int(11) NOT NULL default '0',
  `category` varchar(255) default NULL,
  `rating` int(11) NOT NULL default '1',
  `listingId` varchar(22) binary NOT NULL default '',
  `ipAddress` varchar(15) default NULL,
  `assetId` varchar(22) binary NOT NULL default '',
  `userId` varchar(22) binary default NULL
) ");
	WebGUI::SQL->write("CREATE TABLE `Matrix_listingData` (
  `listingId` varchar(22) binary NOT NULL default '',
  `fieldId` varchar(22) binary NOT NULL default '',
  `value` varchar(255) default NULL,
  `assetId` varchar(22) binary NOT NULL default '',
  PRIMARY KEY  (`listingId`,`fieldId`)
) ");
	WebGUI::SQL->write("CREATE TABLE `Matrix_field` (
  `fieldId` varchar(22) binary NOT NULL default '',
  `category` varchar(255) NOT NULL default '',
  `name` varchar(255) default NULL,
  `label` varchar(255) default NULL,
  `description` text,
  `fieldType` varchar(35) default NULL,
  `defaultValue` varchar(255) default NULL,
  `assetId` varchar(22) binary NOT NULL default '',
  PRIMARY KEY  (`fieldId`),
  KEY `categoryIndex` (`category`)
) ");
	WebGUI::SQL->write("CREATE TABLE `Matrix_ratingSummary` (
  `listingId` varchar(22) binary NOT NULL default '',
  `category` varchar(255) NOT NULL default '',
  `meanValue` decimal(3,2) default NULL,
  `medianValue` int(11) default NULL,
  `countValue` int(11) default NULL,
  `assetId` varchar(22) binary NOT NULL default '',
  PRIMARY KEY  (`listingId`,`category`)
)");
	WebGUI::SQL->write("CREATE TABLE `Matrix` (
  `detailTemplateId` varchar(22) binary default NULL,
  `compareTemplateId` varchar(22) binary default NULL,
  `searchTemplateId` varchar(22) binary default NULL,
  `ratingDetailTemplateId` varchar(22) binary default NULL,
  `categories` text,
  `assetId` varchar(22) binary NOT NULL default '',
  `templateId` varchar(22) binary NOT NULL default '',
  `revisionDate` bigint(20) NOT NULL default '0',
  `maxComparisons` int(11) NOT NULL default '10',
  `maxComparisonsPrivileged` int(11) NOT NULL default '10',
  `privilegedGroup` varchar(22) binary NOT NULL default '2',
  `groupToRate` varchar(22) binary NOT NULL default '2',
  `ratingTimeout` int(11) NOT NULL default '31536000',
  `ratingTimeoutPrivileged` int(11) NOT NULL default '31536000',
  `groupToAdd` varchar(22) binary NOT NULL default '2',
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ");
	WebGUI::SQL->write("CREATE TABLE `Matrix_listing` (
  `listingId` varchar(22) binary NOT NULL default '',
  `maintainerId` varchar(22) binary default NULL,
  `forumId` varchar(22) binary default NULL,
  `productName` varchar(255) default NULL,
  `productUrl` text,
  `manufacturerName` varchar(255) default NULL,
  `manufacturerUrl` text,
  `description` text,
  `lastUpdated` int(11) default NULL,
  `versionNumber` varchar(30) default NULL,
  `views` int(11) NOT NULL default '0',
  `compares` int(11) NOT NULL default '0',
  `clicks` int(11) NOT NULL default '0',
  `status` varchar(30) NOT NULL default 'pending',
  `clicksLastIp` varchar(16) default NULL,
  `viewsLastIp` varchar(16) default NULL,
  `comparesLastIp` varchar(16) default NULL,
  `assetId` varchar(22) binary NOT NULL default '',
  PRIMARY KEY  (`listingId`)
) ");
	my $import = WebGUI::Asset->getImportNode;
	my $folder = $import->addChild({
		title=>"Matrix Templates",
		menuTitle=>"Matrix Templates",
		className=>"WebGUI::Asset::Wobject::Folder",
		url=>"matrix-templates",
		});
	my $template = <<STOP;
<h1>Comparison</h1>
<table cellpadding="0" cellspacing="0" border="0" style="font-size: 11px; font-family: helvetica, arial, sans-serif;">

<tr>
<td valign="top"><tmpl_var compare.form></td>

<td valign="top">

<tmpl_if isTooMany>
You tried to compare too many listings. Please choose <tmpl_var maxCompares> or less at a time.
</tmpl_if>

<tmpl_if isTooFew>
You must choose at least two products to compare. Less than two isn't much of a comparison.
</tmpl_if>


<tmpl_unless isTooFew><tmpl_unless isTooMany>


<table style="font-size: 11px; font-family: helvetica, arial, sans-serif;" align="center" cellpadding="1" cellspacing="1" border="0">
<tr>
  <td>Product</td>
  <tmpl_loop product_loop>
    <td><a href="<tmpl_var url>"><tmpl_var name> <tmpl_var version></a></td>
  </tmpl_loop>
</tr>
<tr>
  <td>Last Updated</td>
  <tmpl_loop lastupdated_loop>
    <td><tmpl_var lastupdated></a></td>
  </tmpl_loop>
</tr>

<tmpl_loop category_loop>
 <tr><td class="category"><tmpl_var category></td>
  <tmpl_loop product_loop>
    <td align="center"><b><tmpl_var name></b></td>
  </tmpl_loop>


</tr>
  <tmpl_loop row_loop>
  <tr
   <tmpl_if __ODD__>
      class="odd"
   <tmpl_else>
      class="even"
   </tmpl_if>
   >
    <tmpl_loop column_loop>
      <td class="<tmpl_var class>" <tmpl_if description>onmouseover="return escape('<tmpl_var description>')"</tmpl_if>>
        <tmpl_var value>
      </td>
     </tmpl_loop>
    </tr>
   </tmpl_loop>
  </tmpl_loop>
</table>


</tmpl_unless></tmpl_unless>

</td></tr></table>
STOP
	my $newAsset = $folder->addChild({
		title=>"Matrix Default Compare",
		menuTitle=>"Matrix Default Compare",
		namespace=>"Matrix/Compare",
		url=>"matrix-default-compare-template",
		className=>"WebGUI::Asset::Template",
		template=>$template
		}, "matrixtmpl000000000002");
	$newAsset->commit;
	$template = <<STOP;
<tmpl_if session.var.adminOn>
<p><tmpl_var toolbar></p>
</tmpl_if>
<h1><tmpl_var title></h1>

<tmpl_if description>
  <tmpl_var description><br /><br />
</tmpl_if>

<table class="content" width="100%">
<tr><td valign="top" width="50%">
<p>Use the form below to select up to <tmpl_var maxCompares> listings to compare at once.
</p>
<tmpl_var compare.form>

</td><td valign="top">


<p>
<b>Narrow The Matrix</b><br>
You can narrow the scope of the matrix by <a href="<tmpl_var search.url>">searching</a> for exactly the criteria you're looking for in a listing.
</p>


<p>
<br><b>Expand The Matrix</b><br>
<tmpl_if isLoggedIn>
   <a href="<tmpl_var listing.add.url>">Click here to add a new listing.</a> Please note that you will be the official maintainer of the listing, and will be responsible for keeping it up to date.
<tmpl_else>
If you are the maker of a product, or are an expert user and are willing to maintain the listing, <a href="^a(linkonly);">create an account</a> so you can register your listing.
</tmpl_if>

</p>



<br><b>Listing Statistics</b><br>
<table class="content">
<tr>
  <td>Most clicks:</td>
  <td><tmpl_var best.clicks.count></td>
  <td><a href="<tmpl_var best.clicks.url>"><tmpl_var best.clicks.name></a></td>
</tr>
<tr>
  <td>Most views:</td>
  <td><tmpl_var best.views.count></td>
  <td><a href="<tmpl_var best.views.url>"><tmpl_var best.views.name></a></td>
</tr>
<tr>
  <td>Most compares:</td>
  <td><tmpl_var best.compares.count></td>
  <td><a href="<tmpl_var best.compares.url>"><tmpl_var best.compares.name></a></td>
</tr>
<tr>
  <td>Most recently updated:</td>
  <td><tmpl_var best.updated.date></td>
  <td><a href="<tmpl_var best.updated.url>"><tmpl_var best.updated.name></a></td>
</tr>
<tr>
  <td colspan="3"><hr size="1"></td>
</tr>
<tr>
  <td align="center" colspan="3">Best Rated By Users</td>
</tr>
<tmpl_loop best_rating_loop>
<tr>
  <td><tmpl_var category></td>
  <td><tmpl_var mean>/10</td>
  <td><a href="<tmpl_var url>"><tmpl_var name></a></td>
</tr>
</tmpl_loop>


<tr>
  <td colspan="3"><hr size="1"></td>
</tr>
<tr>
  <td colspan="3" align="center"><a href="<tmpl_var ratings.details.url>">View Ratings Details</a></td>
</tr>
<tr>
  <td colspan="3"><hr size="1"></td>
</tr>


<tr>
  <td align="center" colspan="3">Worst Rated By Users</td>
</tr>
<tmpl_loop worst_rating_loop>
<tr>
  <td><tmpl_var category></td>
  <td><tmpl_var mean>/10</td>
  <td><a href="<tmpl_var url>"><tmpl_var name></a></td>
</tr>
</tmpl_loop>

<tr>
  <td colspan="3"><hr size="1"></td>
</tr>

</table>

<br>
<br><b>Site Statistics</b><br>
<table class="content">
<tr>
  <td>Listing Count:</td>
  <td><tmpl_var listing.count></td>
</tr>
<tr>
  <td>Current Visitors:</td>
  <td><tmpl_var current.user.count></td>
</tr>
<tr>
  <td>Registered Users:</td>
  <td><tmpl_var user.count></td>
</tr>
</table>




<tmpl_if session.var.adminOn>
<p>   <a href="<tmpl_var field.list.url>">List Fields</a> 
</p>
<tmpl_if pending_list>
<b>PENDING LISTINGS:</b>
</tmpl_if>
<ul>
<tmpl_loop pending_list>
<li><a href="<tmpl_var url>"><tmpl_var productName></a></li>
</tmpl_loop>
</ul>
</tmpl_if>

</td></tr></table>
STOP
	$newAsset = $folder->addChild({
		title=>"Matrix Default View",
		menuTitle=>"Matrix Default View",
		namespace=>"Matrix",
		url=>"matrix-default-view-template",
		className=>"WebGUI::Asset::Template",
		template=>$template
		}, "matrixtmpl000000000001");
	$newAsset->commit;
	$template = <<STOP;
<style>
.ratingForm {
 font-size: 9px;
}
</style>

<h1><tmpl_var productName></h1>


<table class="content">
<tr><td valign="top">

<table class="content">
<tr><td><b>Web Site</b></td><td><a target="_blank" href="<tmpl_var productUrl.click>"><tmpl_var productUrl></a></td></tr>
<tr><td><b>Version Number</b></td><td><tmpl_var versionNumber></td></tr>
<tr><td><b>Manufacturer</b></td><td><a target="_blank" href="<tmpl_var manufacturerUrl.click>"><tmpl_var manufacturerName></a></td></tr>
<tr><td><b>Last Updated</b></td><td><tmpl_var lastUpdated.date></td></tr>
<tr><td><b>Clicks</b></td><td><tmpl_var clicks></td></tr>
<tr><td><b>Views</b></td><td><tmpl_var views></td></tr>
<tr><td><b>Compares</b></td><td><tmpl_var compares></td></tr>
</table>

</td>

  <td valign="top">&nbsp;</td>
  <td valign="top">
<tmpl_if description>
  <b>Description</b><br /><tmpl_var description><br /><br />
</tmpl_if>

<b>Contact Maintainer</b><br />
<tmpl_if email.wasSent>
  <div style="color: green;">Message sent.<br /></div>
</tmpl_if>
<tmpl_var email.form>
</td>


  <td valign="top">&nbsp;</td>
  <td valign="top">
<tmpl_var ratings>
</td>
</tr>


</table>
<p />


<table width="100%"  class="content">
<tr>
<td valign="top" width="50%">
<span class="category">Features</span>
<table class="content" width="180">

<tmpl_loop features_loop>
<tr
<tmpl_if __ODD__>
 class="odd"
<tmpl_else>
 class="even"
</tmpl_if>
>
  <td onmouseover="return escape('<tmpl_var description>')"><tmpl_var label></td><td><tmpl_var value></td>
</tr>
</tmpl_loop>
</table>
<p />


</td>
<td valign="top" width="50%">

<span class="category">Benefits</span>
<table class="content" width="180">
<tmpl_loop benefits_loop>
<tr
<tmpl_if __ODD__>
 class="odd"
<tmpl_else>
 class="even"
</tmpl_if>
>
  <td onmouseover="return escape('<tmpl_var description>')"><tmpl_var label></td><td class="<tmpl_var class>"><tmpl_var value></td>
</tr>
</tmpl_loop>
</table>


</td>
</tr>
</table>





<p />

<tmpl_var discussion>


<tmpl_if user.canEdit>
  <br /> <hr /><a href="<tmpl_var edit.url>">Edit this listing.</a> <br>
</tmpl_if>
<tmpl_if user.canApprove>
 <tmpl_if isPending>
   <a href="<tmpl_var approve.url>">Approve this listing.</a><br>
 </tmpl_if>
   <a href="<tmpl_var delete.url>">Delete this listing.</a><br>
  
</tmpl_if>
STOP
	$newAsset = $folder->addChild({
		title=>"Matrix Default Detailed Listing",
		menuTitle=>"Matrix Default Detailed Listing",
		namespace=>"Matrix/Detail",
		url=>"matrix-default-detailed-listing",
		className=>"WebGUI::Asset::Template",
		template=>$template
		}, "matrixtmpl000000000003");
	$newAsset->commit;
	$template = <<STOP;
<h1>Rating Detail</h1>

<table class="content" cellpadding="5" width="60%">
<tbody>
<tmpl_loop rating_loop>
<tmpl_if __ODD__>
<tr>
</tmpl_if>

<td width="50%" valign="top">
<h2><tmpl_var category></h2>

<table class="content">
<tbody>
<tr><th>Listing</th><th>Mean</th><th>Median</th><th>Count</th></tr>
<tmpl_loop detail_loop>

<tr>
<td><a href="<tmpl_var url>"><tmpl_var name></a></td>
<td><tmpl_var mean></td>
<td><tmpl_var median></td>
<td><tmpl_var count></td>
</tr>

</tmpl_loop>
</tbody>
</table>
</td>

<tmpl_if __EVEN__>
</tr>
</tmpl_if>

</tmpl_loop>
</tr>
</tbody>
</table>
STOP
	$newAsset = $folder->addChild({
		title=>"Matrix Default Rating Detail",
		menuTitle=>"Matrix Default Rating Detail",
		namespace=>"Matrix/RatingDetail",
		url=>"matrix-rating-detail-template",
		className=>"WebGUI::Asset::Template",
		template=>$template
		}, "matrixtmpl000000000004");
	$newAsset->commit;
	$template = <<STOP;
<h1>Search The Matrix</h1>


<tmpl_if isTooFew>
<p>Your search returned no results. Try specifying a few less criteria.</p>
</tmpl_if>

<tmpl_if isTooMany>
<p>
Your search returned too many results. Either select up to <tmpl_var maxCompares> products from the list below, or specify more critera.
</p>
</tmpl_if>


<table width="100%" class="content">
<tr><td valign="top">
<tmpl_var compare.form>
</td><td valign="top">



<tmpl_var form.header>
<tmpl_var form.submit>


<table width="100%"  class="content">
<tr>
<td valign="top" width="50%">


<span class="category">Features</span>
<table class="content" width="180">
<tmpl_loop features_loop>
<tr
<tmpl_if __ODD__>
 class="odd"
<tmpl_else>
 class="even"
</tmpl_if>
>
  <td onmouseover="return escape('<tmpl_var description>')"><tmpl_var label></td><td><tmpl_var form></td>
</tr>
</tmpl_loop>
</table>

</td>
<td valign="top" width="50%">

<span class="category">Benefits</span>
<table class="content">
<tmpl_loop benefits_loop>
<tr
<tmpl_if __ODD__>
 class="odd"
<tmpl_else>
 class="even"
</tmpl_if>
>
  <td onmouseover="return escape('<tmpl_var description>')"><tmpl_var label></td><td><tmpl_var form></td>
</tr>
</tmpl_loop>
</table>


</td>
</tr>
</table>

<tmpl_var form.submit>
<tmpl_var form.footer>


</td></tr></table>
STOP
	$newAsset = $folder->addChild({
		title=>"Matrix Default Search",
		menuTitle=>"Matrix Default Search",
		namespace=>"Matrix/Search",
		url=>"matrix-search-template",
		className=>"WebGUI::Asset::Template",
		template=>$template
		}, "matrixtmpl000000000005");
	$newAsset->commit;
}

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
	WebGUI::SQL->write("create table WorkflowInstance (
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
	WebGUI::SQL->write("create table Workflow (
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

