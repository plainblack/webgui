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
	my $a = WebGUI::SQL->read("select * from page where subroutinePackage='WebGUI::Page' and parentId=".quote($oldParentId));
	while (my $page = $a->hashRef) {
		my $pageId = WebGUI::Id::generate();
		my $pageLineage = $parentLineage.sprintf("%06d",$myRank);
		my $pageUrl = $page->{urlizedTitle};
		my $className = 'WebGUI::Asset::Layout';
		if ($page->{redirectURL} ne "") {
			$className = 'WebGUI::Asset::Redirect';
		}
		WebGUI::SQL->write("insert into asset (assetId, parentId, lineage, className, state, title, menuTitle, url, startDate, 
			endDate, synopsis, newWindow, isHidden, ownerUserId, groupIdView, groupIdEdit) values (".quote($pageId).",
			".quote($newParentId).", ".quote($pageLineage).", ".quote($className).",'published',".quote($page->{title}).",
			".quote($page->{menuTitle}).", ".quote($pageUrl).", ".quote($page->startDate).", ".quote($page->{endDate}).",
			".quote($page->{synopsis}).", ".quote($page->{newWindow}).", ".quote($page->{hideFromNavigation}).", ".quote($page->{ownerId}).",
			".quote($page->{groupIdView}).", ".quote($page->{groupIdEdit}).")");
		if ($page->{redirectURL} ne "") {
			WebGUI::SQL->write("insert into redirect (assetId, redirectUrl) values (".quote($pageId).",".quote($page->{redirectURL}).")");
		} else {
			WebGUI::SQL->write("insert into layout (assetId, styleTemplateId, layoutTemplateId, printableStyleTemplateId) values (
				".quote($pageId).", ".quote($page->{styleId}).", ".quote($page->{templateId}).", 
				".quote($page->{printableStyleTemplateId}).")");
		}
		my $rank = 0;
		my $b = WebGUI::SQL->read("select * from wobject where pageId=".quote($page->{pageId}));
		while (my $wobject = $b->hashRef) {
			$rank++;
			my $wobjectId = WebGUI::Id::generate();
			my $wobjectLineage = $pageLineage.sprintf("%06d",$rank);
			my $wobjectUrl = $pageUrl."/".$wobject->{title};
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
				endDate, synopsis, isHidden, ownerUserId, groupIdView, groupIdEdit) values (".quote($wobjectId).",
				".quote($pageId).", ".quote($wobjectLineage).", ".quote($className).",'published',".quote($page->{title}).",
				".quote($page->{title}).", ".quote($wobjectUrl).", ".quote($wobject->startDate).", ".quote($wobject->{endDate}).",
				".quote($page->{synopsis}).", 1, ".quote($ownerId).", ".quote($groupIdView).", ".quote($groupIdEdit).")");
			WebGUI::SQL->write("update wobject set assetId=".quote($wobjectId));
			my $c = WebGUI::SQL->read("select * from ".$wobject->{namespace}." where wobjectId=".quote($wobject->{wobjectId}));
			while (my $namespace = $c->hashRef) {
			}
			$c->finish;
		}
		$b->finish;
		walkTree($page->{pageId},$pageId,$pageLineage,$rank+1);
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
	WebGUI::SQL->write("alter table wobject drop column title");
	WebGUI::SQL->write("alter table wobject drop column ownerId");
	WebGUI::SQL->write("alter table wobject drop column groupIdEdit");
	WebGUI::SQL->write("alter table wobject drop column groupIdView");
	WebGUI::SQL->write("drop table page");
}





