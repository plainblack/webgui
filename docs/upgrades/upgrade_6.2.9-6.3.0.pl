#!/usr/bin/perl

use lib "../../lib";
use FileHandle;
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



# <this is here because we don't want to actually migrate stuff yet
WebGUI::Session::close();
exit;
# >this is here because we don't want to actually migrate stuff yet



print "\tConverting Pages, Wobjects, and Forums to Assets\n" unless ($quiet);
print "\t\tHold on cuz this is going to take a long time...\n" unless ($quiet);
print "\t\tMaking first round of table structure changes\n" unless ($quiet);
WebGUI::SQL->write("alter table wobject add column assetId varchar(22) not null");
WebGUI::SQL->write("alter table wobject add styleTemplateId varchar(22) not null");
WebGUI::SQL->write("alter table wobject add printableStyleTemplateId varchar(22) not null");
WebGUI::SQL->write("alter table wobject drop primary key");
my $sth = WebGUI::SQL->read("select distinct(namespace) from wobject");
while (my ($namespace) = $sth->array) {
	WebGUI::SQL->write("alter table ".$namespace." add column assetId varchar(22) not null");
}
$sth->finish;
walkTree('0','theroot','000001','1');
print "\t\tMaking second round of table structure changes\n" unless ($quiet);
WebGUI::SQL->write("drop table SiteMap");
WebGUI::SQL->write("delete from template where namespace in ('SiteMap')");
my $sth = WebGUI::SQL->read("select distinct(namespace) from wobject where namespace is not null");
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







WebGUI::Session::close();


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
		my $pageLineage = $parentLineage.sprintf("%06d",$myRank);
		my $pageUrl = fixUrl($pageId,$page->{urlizedTitle});
		my $className = 'WebGUI::Asset::Layout';
		if ($page->{redirectURL} ne "") {
			$className = 'WebGUI::Asset::Redirect';
		}
		WebGUI::SQL->write("insert into asset (assetId, parentId, lineage, className, state, title, menuTitle, url, startDate, 
			endDate, synopsis, newWindow, isHidden, ownerUserId, groupIdView, groupIdEdit, encryptPage ) values (".quote($pageId).",
			".quote($newParentId).", ".quote($pageLineage).", ".quote($className).",'published',".quote($page->{title}).",
			".quote($page->{menuTitle}).", ".quote($pageUrl).", ".quote($page->{startDate}).", ".quote($page->{endDate}).",
			".quote($page->{synopsis}).", ".quote($page->{newWindow}).", ".quote($page->{hideFromNavigation}).", ".quote($page->{ownerId}).",
			".quote($page->{groupIdView}).", ".quote($page->{groupIdEdit}).", ".quote($page->{encryptPage}).")");
		if ($page->{redirectURL} ne "") {
			WebGUI::SQL->write("insert into redirect (assetId, redirectUrl) values (".quote($pageId).",".quote($page->{redirectURL}).")");
		} else {
			WebGUI::SQL->write("insert into wobject (assetId, styleTemplateId, templateId, printableStyleTemplateId) values (
				".quote($pageId).", ".quote($page->{styleId}).", ".quote($page->{templateId}).", 
				".quote($page->{printableStyleId}).")");
			WebGUI::SQL->write("insert into layout (assetId) values (".quote($pageId).")");
		}
		my $rank = 1;
		print "\t\tFinding wobjects on page ".$page->{pageId}."\n" unless ($quiet);
		my $b = WebGUI::SQL->read("select * from wobject where pageId=".quote($page->{pageId})." order by sequenceNumber");
		while (my $wobject = $b->hashRef) {
			print "\t\t\tConverting wobject ".$wobject->{wobjectId}."\n" unless ($quiet);
			my ($namespace) = WebGUI::SQL->quickHashRef("select * from ".$wobject->{namespace}." where wobjectId=".quote($wobject->{wobjectId}));
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
				endDate, isHidden, ownerUserId, groupIdView, groupIdEdit, encryptPage) values (".quote($wobjectId).",
				".quote($pageId).", ".quote($wobjectLineage).", ".quote($className).",'published',".quote($page->{title}).",
				".quote($page->{title}).", ".quote($wobjectUrl).", ".quote($wobject->{startDate}).", ".quote($wobject->{endDate}).",
				1, ".quote($ownerId).", ".quote($groupIdView).", ".quote($groupIdEdit).", ".quote($page->{encryptPage}).")");
			WebGUI::SQL->write("update wobject set assetId=".quote($wobjectId).", styleTemplateId=".quote($page->{styleId}).",
				printableStyleTemplateId=".quote($page->{printableStyleId})." where wobjectId=".quote($wobject->{wobjectId}));
			WebGUI::SQL->write("update ".$wobject->{namespace}." set assetId=".quote($wobjectId)." where wobjectId="
				.quote($wobject->{wobjectId}));
			if ($wobject->{namespace} eq "Article") {
				print "\t\t\tMigrating attachments for Article ".$wobject->{wobjectId}."\n" unless ($quiet);
				if ($namespace->{attachment}) {
					my $attachmentId = WebGUI::Id::generate();
					WebGUI::SQL->write("insert into asset (assetId, parentId, lineage, className, state, title, menuTitle, 
						url, startDate, endDate, isHidden, ownerUserId, groupIdView, groupIdEdit, boundToId) values (".
						quote($attachmentId).", ".quote($wobjectId).", ".quote($wobjectLineage.sprintf("%06d",1)).", 
						'WebGUI::Asset::File','published',".quote($namespace->{attachment}).", ".
						quote($namespace->{attachment}).", ".quote(fixUrl($attachmentId,$wobjectUrl.$namespace->{attachment})).", 
						".quote($wobject->{startDate}).", ".quote($wobject->{endDate}).", 1, ".quote($ownerId).", 
						".quote($groupIdView).", ".quote($groupIdEdit).", ".quote($wobjectId).")");
					my $storageId = copyFile($namespace->{attachment},$wobject->{wobjectId});
					WebGUI::SQL->write("insert into FileAsset (assetId, filename, storageId, fileSize) values (
						".quote($attachmentId).", ".quote($namespace->{attachment}).", ".quote($storageId).",
						".quote(getFileSize($storageId,$namespace->{attachment})).")");
				}
				if ($namespace->{image}) {
					my $rank = 1;
					$rank ++ if ($namespace->{attachment});
					my $imageId = WebGUI::Id::generate();
					WebGUI::SQL->write("insert into asset (assetId, parentId, lineage, className, state, title, menuTitle, 
						url, startDate, endDate, isHidden, ownerUserId, groupIdView, groupIdEdit, boundToId) values (".
						quote($imageId).", ".quote($wobjectId).", ".quote($wobjectLineage.sprintf("%06d",$rank)).", 
						'WebGUI::Asset::File::Image','published',".quote($namespace->{attachment}).", ".
						quote($namespace->{image}).", ".quote(fixUrl($imageId,$wobjectUrl.$namespace->{image})).", 
						".quote($wobject->{startDate}).", ".quote($wobject->{endDate}).", 1, ".quote($ownerId).", 
						".quote($groupIdView).", ".quote($groupIdEdit).", ".quote($wobjectId).")");
					my $storageId = copyFile($namespace->{image},$wobject->{wobjectId});
					copyFile('thumb-'.$namespace->{image},$wobject->{wobjectId},$storageId);
					WebGUI::SQL->write("insert into FileAsset (assetId, filename, storageId, fileSize) values (
						".quote($imageId).", ".quote($namespace->{image}).", ".quote($storageId).",
						".quote(getFileSize($storageId,$namespace->{image})).")");
					WebGUI::SQL->write("insert into ImageAsset (assetId, thumbnailSize) values (".quote($imageId).",
						".quote($session{setting}{thumbnailSize}).")");
				}
				# migrate forums
			} elsif ($wobject->{namespace} eq "SiteMap") {
				print "\t\t\tConverting SiteMap ".$wobject->{wobjectId}." into Navigation\n" unless ($quiet);
				my $navident = 'SiteMap_'.$namespace->{wobjectId};
				my ($starturl) = WebGUI::SQL->quickArray("select urlizedTitle from page 
					where pageId=".quote($namespace->{startAtThisLevel}));
				WebGUI::SQL->write("insert into Navigation (navigationId, identifier, depth, startAt, 
					templateId) values (".quote(WebGUI::Id::generate()).", ".quote($navident).", 
					".quote($namespace->{depth}).", ".quote($starturl).", '1')"); 
				my $navmacro = $wobject->{description}.'<p>^Navigation('.$navident.');</p>';
				WebGUI::SQL->write("update asset set className='WebGUI::Asset::Wobject::Article' where assetId=".quote($wobjectId));
				WebGUI::SQL->write("update wobject set namespace='Article', description=".quote($navmacro)." 
					where assetId=".quote($wobjectId));
				WebGUI::SQL->write("insert into Article (assetId,wobjectId) values (".quote($wobjectId).",
					".quote($wobject->{wobjectId}).")");
			} elsif ($wobject->{namespace} eq "FileManager") {
				# we're dumping file manager's so do that here
			} elsif ($wobject->{namespace} eq "Product") {
				# migrate attachments to file assets
				# migrate images to image assets
			} elsif ($wobject->{namespace} eq "USS") {
				# migrate master forum
				# migrate submissions
				# migrate submission forums
				# migrate submission attachments
				# migrate submission images
			} elsif ($wobject->{namespace} eq "MessageBoard") {
				# migrate forums
			}
			$rank++;
		}
		$b->finish;
		walkTree($page->{pageId},$pageId,$pageLineage,$rank);
		$myRank++;
	}
	$a->finish;
}




sub fixUrl {
	my $id = shift;
        my $url = shift;
        $url = WebGUI::URL::urlize($url);
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
	my $a = FileHandle->new($session{config}{uploadPath}.$session{os}{slash}.$oldPath.$session{os}{slash}.$filename,"r");
        binmode($a);
        my $b = FileHandle->new(">".$node.$session{os}{slash}.$filename);
        binmode($b);
        cp($a,$b);
	return $id;
}

sub getFileSize {
	my $id = shift;
	my $filename = shift;
	$id =~ m/^(.{2})(.{2})/;
	my $path = $session{config}{uploadsPath}.$session{os}{slash}.$1.$session{os}{slash}.$2.$session{os}{slash}.$id.$session{os}{slash}.$filename;
	my (@attributes) = stat($path);
	return $attributes[7];
}

sub isIn {
        my $key = shift;
        $_ eq $key and return 1 for @_;
        return 0;
}


