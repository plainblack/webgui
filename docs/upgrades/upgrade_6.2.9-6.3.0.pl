#!/usr/bin/perl

use lib "../../lib";
use Getopt::Long;
use strict;
use WebGUI::Id;
use WebGUI::Page;
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


#print "\tConverting Pages, Wobjects, and Forums to Assets\n" unless ($quiet);
#walkTree('0','theroot','000001','0');

WebGUI::Session::close();


sub walkTree {
	my $oldParentId = shift;
	my $newParentId = shift;
	my $parentLineage = shift;
	my $myRank = shift;
	WebGUI::SQL->write("alter table wobject add column assetId varchar(22) not null");
	my $sth = WebGUI::SQL->read("select distinct(namespace) from wobject");
	while (my ($namespace) = $sth->array) {
		WebGUI::SQL->write("alter table ".$namespace." add column assetId varchar(22) not null");
	}
	$sth->finish;
	my $a = WebGUI::SQL->read("select * from page where subroutinePackage='WebGUI::Page' and parentId=".quote($oldParentId)." order by nestedSetLeft");
	while (my $page = $a->hashRef) {
		my $pageId = WebGUI::Id::generate();
		my $pageLineage = $parentLineage.sprintf("%06d",$myRank);
		my $pageUrl = fixUrl($page->{urlizedTitle});
		my $className = 'WebGUI::Asset::Layout';
		if ($page->{redirectURL} ne "") {
			$className = 'WebGUI::Asset::Redirect';
		}
		WebGUI::SQL->write("insert into asset (assetId, parentId, lineage, className, state, title, menuTitle, url, startDate, 
			endDate, synopsis, newWindow, isHidden, ownerUserId, groupIdView, groupIdEdit, encryptPage ) values (".quote($pageId).",
			".quote($newParentId).", ".quote($pageLineage).", ".quote($className).",'published',".quote($page->{title}).",
			".quote($page->{menuTitle}).", ".quote($pageUrl).", ".quote($page->startDate).", ".quote($page->{endDate}).",
			".quote($page->{synopsis}).", ".quote($page->{newWindow}).", ".quote($page->{hideFromNavigation}).", ".quote($page->{ownerId}).",
			".quote($page->{groupIdView}).", ".quote($page->{groupIdEdit}).", ".quote($page->{encryptPage}).")");
		if ($page->{redirectURL} ne "") {
			WebGUI::SQL->write("insert into redirect (assetId, redirectUrl) values (".quote($pageId).",".quote($page->{redirectURL}).")");
		} else {
			WebGUI::SQL->write("insert into layout (assetId, styleTemplateId, layoutTemplateId, printableStyleTemplateId) values (
				".quote($pageId).", ".quote($page->{styleId}).", ".quote($page->{templateId}).", 
				".quote($page->{printableStyleTemplateId}).")");
		}
		my $rank = 0;
		my $b = WebGUI::SQL->read("select * from wobject where pageId=".quote($page->{pageId})." order by sequenceNumber");
		while (my $wobject = $b->hashRef) {
			$rank++;
			my ($namespace) = WebGUI::SQL->quickHashRef("select * from ".$wobject->{namespace}." where wobjectId=".quote($wobject->{wobjectId}));
			my $wobjectId = WebGUI::Id::generate();
			my $wobjectLineage = $pageLineage.sprintf("%06d",$rank);
			my $wobjectUrl = fixUrl($pageUrl."/".$wobject->{title});
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
				endDate, isHidden, ownerUserId, groupIdView, groupIdEdit, encryptPage) values (".quote($wobjectId).",
				".quote($pageId).", ".quote($wobjectLineage).", ".quote($className).",'published',".quote($page->{title}).",
				".quote($page->{title}).", ".quote($wobjectUrl).", ".quote($wobject->startDate).", ".quote($wobject->{endDate}).",
				1, ".quote($ownerId).", ".quote($groupIdView).", ".quote($groupIdEdit).", ".quote($page->{encryptPage}).")");
			WebGUI::SQL->write("update wobject set assetId=".quote($wobjectId));
			WebGUI::SQL->write("update ".$wobject->{namespace}." set assetId=".quote($wobjectId));
			if ($namespace eq "Article") {
				# migrate attachment to file asset
				# migrate image to image asset
				# migrate forums
			} elsif ($namespace eq "SiteMap") {
				my $navident = 'SiteMap_'.$namespace->{wobjectId};
				my ($starturl) = WebGUI::SQL->quickArray("select urlizedTitle from page 
					where pageId=".quote($namespace->{startAtThisLevel}));
				WebGUI::SQL->write("insert into Navigation (navigationId, identifier, depth, startAt, 
					templateId) values (".quote(WebGUI::Id::generate()).", ".quote($navident).", 
					".quote($namespace->{depth}).", ".quote($starturl).", '1')"); 
				my $navmacro = $wobject->{description}.'<p>^Navigation('.$navident.');</p>';
				WebGUI::SQL->write("update wobject set className='WebGUI::Asset::Wobject::Article', description=".quote($navmacro)."
					where assetId=".quote($wobjectId));
				WebGUI::SQL->write("insert into Article (assetId) values (".quote($wobjectId).")");
			} elsif ($namespace eq "FileManager") {
				# we're dumping file manager's so do that here
			} elsif ($namespace eq "Product") {
				# migrate attachments to file assets
				# migrate images to image assets
			} elsif ($namespace eq "USS") {
				# migrate master forum
				# migrate submissions
				# migrate submission forums
				# migrate submission attachments
				# migrate submission images
			} elsif ($namespace eq "MessageBoard") {
				# migrate forums
			}
		}
		$b->finish;
		walkTree($page->{pageId},$pageId,$pageLineage,$rank+1);
		$myRank++;
	}
	$a->finish;
	my $sth = WebGUI::SQL->read("select distinct(namespace) from wobject");
	while (my ($namespace) = $sth->array) {
		if (isIn($namespace, qw(Article DataForm EventsCalendar HttpProxy IndexedSearch MessageBoard Poll Product SQLReport Survey SyndicatedContent USS WobjectProxy WSClient))) {
			WebGUI::SQL->write("alter table ".$namespace." drop column wobjectId");
		} else {
			WebGUI::SQL->write("alter table ".$namespace." drop primary key");
		}
		WebGUI::SQL->write("alter table ".$namespace." add primary key (assetId)");
	}
	$sth->finish;
	WebGUI::SQL->write("alter table wobject drop column wobjectId");
	WebGUI::SQL->write("alter table wobject add primary key (assetId)");
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
	WebGUI::SQL->write("alter table wobject drop column allowDiscussion");
	WebGUI::SQL->write("drop table page");
	WebGUI::SQL->write("alter table Article drop column image");
	WebGUI::SQL->write("alter table Article drop column attachment");
	WebGUI::SQL->write("delete from template where namespace in ('SiteMap')");
}




sub fixUrl {
	my $id = shift;
        my $url = WebGUI::URL::urlize(shift);
        my ($test) = WebGUI::SQL->quickArray("select url from asset where assetId<>".quote($id)." and url=".quote($url));
        if ($test) {
                my @parts = split(/\./,$url);
                if ($parts[0] =~ /(.*)(\d+$)/) {
                        $parts[0] = $1.($2+1);
                } elsif ($test ne "") {
                        $parts[0] .= "2";
                }
                $url = join(".",@parts);
                $url = fixUrl($url);
        }
        return $url;
}
