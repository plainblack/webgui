#!/usr/bin/perl

use lib "../../lib";
use FileHandle;
use File::Path;
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


print "\tMigrating wobject templates to asset templates.\n" unless ($quiet);
my $sth = WebGUI::SQL->read("select templateId, template, namespace from template where namespace in ('Article', 
		'USS', 'SyndicatedContent', 'MessageBoard', 'DataForm', 'EventsCalendar', 'HttpProxy', 'Poll', 'WobjectProxy',
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


# <this is here because we don't want to actually migrate stuff yet
#WebGUI::Session::close();
#exit;
# >this is here because we don't want to actually migrate stuff yet



print "\tConverting Pages, Wobjects, and Forums to Assets\n" unless ($quiet);
print "\t\tHold on cuz this is going to take a long time...\n" unless ($quiet);
print "\t\tMaking first round of table structure changes\n" unless ($quiet);
WebGUI::SQL->write("alter table wobject add column assetId varchar(22) not null");
WebGUI::SQL->write("alter table wobject add styleTemplateId varchar(22) not null");
WebGUI::SQL->write("alter table wobject add printableStyleTemplateId varchar(22) not null");
WebGUI::SQL->write("alter table wobject add cacheTimeout int not null default 60");
WebGUI::SQL->write("alter table wobject add cacheTimeoutVisitor int not null default 3600");
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



print "\tUpdating navigation to work with asset tree\n" unless ($quiet);
WebGUI::SQL->write("alter table Navigation add column assetsToInclude text");
WebGUI::SQL->write("alter table Navigation add column startType varchar(35)");
WebGUI::SQL->write("alter table Navigation add column startPoint varchar(35)");
WebGUI::SQL->write("alter table Navigation add column baseType varchar(35)");
WebGUI::SQL->write("alter table Navigation add column basePage varchar(255)");
WebGUI::SQL->write("alter table Navigation add column endType varchar(35)");
WebGUI::SQL->write("alter table Navigation add column endPoint varchar(35)");
my $sth = WebGUI::SQL->read("select * from Navigation");
while (my $data = $sth->hashRef) {
	my %newNav;
	$newNav{navigationId} = $data->{navigationId};
	$newNav{identifier} = $data->{identifier};
	$newNav{showSystemPages} = $data->{showSystemPages};
	$newNav{showHiddenPages} = $data->{showHiddenPages};
	$newNav{showUnprivilegedPages} = $data->{showUnprivilegedPages};
	$newNav{startType} = "relativeToRoot";
	$newNav{startPoint} = $data->{stopAtLevel}+1;
	if ($data->{startAt} eq "root") {
		$newNav{baseType} = "relativeToRoot";
		$newNav{basePage} = "0";
	} elsif ($data->{startAt} eq "WebGUIroot") {
		$newNav{baseType} = "relativeToRoot";
		$newNav{basePage} = "1";
	} elsif ($data->{startAt} eq "top") {
		$newNav{baseType} = "relativeToRoot";
		$newNav{basePage} = "2";
	} elsif ($data->{startAt} eq "grandmother") {
		$newNav{baseType} = "relativeToCurrentPage";
		$newNav{basePage} = "-2";
	} elsif ($data->{startAt} eq "mother") {
		$newNav{baseType} = "relativeToCurrentPage";
		$newNav{basePage} = "-1";
	} elsif ($data->{startAt} eq "current") {
		$newNav{baseType} = "relativeToCurrentPage";
		$newNav{basePage} = "0";
	} elsif ($data->{startAt} eq "daughter") {
		$newNav{baseType} = "relativeToCurrentPage";
		$newNav{basePage} = "1";
	} else {
		$newNav{baseType} = "specificUrl";
		$newNav{basePage} = $data->{startAt};
	}
	$newNav{endType} = "relativeToBasePage";
	$newNav{endPoint} = ($data->{depth} == 99)?55:$data->{stopAtLevel});
	if ($data->{method} eq "daughters") {
		$newNav{assetsToInclude} = "descendants";
	} elsif ($data->{method} eq "sisters") {
		$newNav{assetsToInclude} = "siblings";
	} elsif ($data->{method} eq "self_and_sisters") {
		$newNav{assetsToInclude} = "self,siblings";
	} elsif ($data->{method} eq "descendants") {
		$newNav{assetsToInclude} = "descendants";
	} elsif ($data->{method} eq "self_and_descendants") {
		$newNav{assetsToInclude} = "self,descendants";
	} elsif ($data->{method} eq "leaves_under") {
		$newNav{assetsToInclude} = "descendants";
	} elsif ($data->{method} eq "generation") {
		$newNav{assetsToInclude} = "self,sisters";
	} elsif ($data->{method} eq "ancestors") {
		$newNav{assetsToInclude} = "ancestors";
	} elsif ($data->{method} eq "self_and_ancestors") {
		$newNav{assetsToInclude} = "self,ancestors";
	} elsif ($data->{method} eq "pedigree") {
		$newNav{assetsToInclude} = "pedigree";
	}
	WebGUI::SQL->setRow("Navigation","navigationId",\%newNav);
}
$sth->finish;
WebGUI::SQL->write("alter table Navigation drop column depth");
WebGUI::SQL->write("alter table Navigation drop column startAt");
WebGUI::SQL->write("alter table Navigation drop column stopAtLevel");
WebGUI::SQL->write("alter table Navigation drop column method");
WebGUI::SQL->write("alter table Navigation drop column reverse");


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
			endDate, synopsis, newWindow, isHidden, ownerUserId, groupIdView, groupIdEdit, encryptPage, assetSize ) values (".quote($pageId).",
			".quote($newParentId).", ".quote($pageLineage).", ".quote($className).",'published',".quote($page->{title}).",
			".quote($page->{menuTitle}).", ".quote($pageUrl).", ".quote($page->{startDate}).", ".quote($page->{endDate}).",
			".quote($page->{synopsis}).", ".quote($page->{newWindow}).", ".quote($page->{hideFromNavigation}).", ".quote($page->{ownerId}).",
			".quote($page->{groupIdView}).", ".quote($page->{groupIdEdit}).", ".quote($page->{encryptPage}).",
			".length($page->{title}.$page->{menuTitle}.$page->{synopsis}.$page->{urlizedTitle}).")");
		if ($page->{redirectURL} ne "") {
			WebGUI::SQL->write("insert into redirect (assetId, redirectUrl) values (".quote($pageId).",".quote($page->{redirectURL}).")");
		} else {
			WebGUI::SQL->write("insert into wobject (assetId, styleTemplateId, templateId, printableStyleTemplateId, 
				cacheTimeout, cacheTimeoutVisitor, displayTitle) values (
				".quote($pageId).", ".quote($page->{styleId}).", ".quote($page->{templateId}).", 
				".quote($page->{printableStyleId}).", ".quote($page->{cacheTimeout}).",".quote($page->{cacheTimeoutVisitor}).",
				0)");
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
				endDate, isHidden, ownerUserId, groupIdView, groupIdEdit, encryptPage, assetSize) values (".quote($wobjectId).",
				".quote($pageId).", ".quote($wobjectLineage).", ".quote($className).",'published',".quote($wobject->{title}).",
				".quote($wobject->{title}).", ".quote($wobjectUrl).", ".quote($wobject->{startDate}).", ".quote($wobject->{endDate}).",
				1, ".quote($ownerId).", ".quote($groupIdView).", ".quote($groupIdEdit).", ".quote($page->{encryptPage}).",
				".length($wobject->{title}.$wobject->{description}).")");
			WebGUI::SQL->write("update wobject set assetId=".quote($wobjectId).", styleTemplateId=".quote($page->{styleId}).",
				printableStyleTemplateId=".quote($page->{printableStyleId}).", cacheTimeout=".quote($page->{cacheTimeout})
				.", cacheTimeoutVisitor=".quote($page->{cacheTimeoutVisitor})." where wobjectId=".quote($wobject->{wobjectId}));
			WebGUI::SQL->write("update ".$wobject->{namespace}." set assetId=".quote($wobjectId)." where wobjectId="
				.quote($wobject->{wobjectId}));
			if ($wobject->{namespace} eq "Article") {
				print "\t\t\tMigrating attachments for Article ".$wobject->{wobjectId}."\n" unless ($quiet);
				if ($namespace->{attachment}) {
					my $attachmentId = WebGUI::Id::generate();
					WebGUI::SQL->write("insert into asset (assetId, parentId, lineage, className, state, title, menuTitle, 
						url, startDate, endDate, isHidden, ownerUserId, groupIdView, groupIdEdit) values (".
						quote($attachmentId).", ".quote($wobjectId).", ".quote($wobjectLineage.sprintf("%06d",1)).", 
						'WebGUI::Asset::File','published',".quote($namespace->{attachment}).", ".
						quote($namespace->{attachment}).", ".quote(fixUrl($attachmentId,$wobjectUrl.'/'.$namespace->{attachment})).", 
						".quote($wobject->{startDate}).", ".quote($wobject->{endDate}).", 1, ".quote($ownerId).", 
						".quote($groupIdView).", ".quote($groupIdEdit).")");
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
						url, startDate, endDate, isHidden, ownerUserId, groupIdView, groupIdEdit) values (".
						quote($imageId).", ".quote($wobjectId).", ".quote($wobjectLineage.sprintf("%06d",$rank)).", 
						'WebGUI::Asset::File::Image','published',".quote($namespace->{image}).", ".
						quote($namespace->{image}).", ".quote(fixUrl($imageId,$wobjectUrl.'/'.$namespace->{image})).", 
						".quote($wobject->{startDate}).", ".quote($wobject->{endDate}).", 1, ".quote($ownerId).", 
						".quote($groupIdView).", ".quote($groupIdEdit).")");
					my $storageId = copyFile($namespace->{image},$wobject->{wobjectId});
					copyFile('thumb-'.$namespace->{image},$wobject->{wobjectId},$storageId);
					WebGUI::SQL->write("insert into FileAsset (assetId, filename, storageId, fileSize) values (
						".quote($imageId).", ".quote($namespace->{image}).", ".quote($storageId).",
						".quote(getFileSize($storageId,$namespace->{image})).")");
					WebGUI::SQL->write("insert into ImageAsset (assetId, thumbnailSize) values (".quote($imageId).",
						".quote($session{setting}{thumbnailSize}).")");
				}
				# migrate forums
				rmtree($session{config}{uploadsPath}.'/'.$wobject->{wobjectId});
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
				print "\t\t\tConverting File Manager ".$wobject->{wobjectId}." into File Folder Layout\n" unless ($quiet);
				WebGUI::SQL->write("update asset set className='WebGUI::Asset::Layout' where assetId=".quote($wobjectId));
				WebGUI::SQL->write("insert into layout (assetId) values (".quote($wobjectId).")");
				WebGUI::SQL->write("update wobject set templateId='15' where wobjectId=".quote($wobjectId));
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
							WebGUI::SQL->write("insert into ImageAsset (assetId, thumbnailSize) values (".quote($newId).",
								".quote($session{setting}{thumbnailSize}).")");
							$class = 'WebGUI::Asset::File::Image';
						} else {
							$class = 'WebGUI::Asset::File';
						}
						WebGUI::SQL->write("insert into FileAsset (assetId, filename, storageId, fileSize) values (
							".quote($newId).", ".quote($data->{$field}).", ".quote($storageId).",
							".quote(getFileSize($storageId,$data->{$field})).")");
						WebGUI::SQL->write("insert into asset (assetId, parentId, lineage, className, state, title, menuTitle, 
							url, startDate, endDate, isHidden, ownerUserId, groupIdView, groupIdEdit, synopsis) values (".
							quote($newId).", ".quote($wobjectId).", ".quote($wobjectLineage.sprintf("%06d",1)).", 
							'".$class."','published',".quote($data->{fileTitle}).", ".
							quote($data->{fileTitle}).", ".quote(fixUrl($newId,$wobjectUrl.'/'.$data->{$field})).", 
							".quote($wobject->{startDate}).", ".quote($wobject->{endDate}).", 1, ".quote($ownerId).", 
							".quote($data->{groupToView}).", ".quote($groupIdEdit).", ".quote($data->{briefSynopsis}).")");
						$rank++;
					}
				}
				$sth->finish;
				rmtree($session{config}{uploadsPath}.'/'.$wobject->{wobjectId});
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
			WebGUI::SQL->write("update layout set contentPositions=".quote($contentPositions)." where assetId=".quote($pageId));
		}
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


