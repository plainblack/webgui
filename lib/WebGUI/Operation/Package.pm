package WebGUI::Operation::Package;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2004 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com			info@plainblack.com
#-------------------------------------------------------------------

use Exporter;
use strict qw(vars subs);
use WebGUI::Icon;
use WebGUI::Page;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_deployPackage );

#-------------------------------------------------------------------
sub _duplicateWobjects {
	my (%properties);
	tie %properties, 'Tie::CPHash';
	my $sth = WebGUI::SQL->read("select * from wobject where pageId=$_[0] order by sequenceNumber");
	while (my $wobject = $sth->hashRef) {
		my $cmd = "WebGUI::Wobject::".${$wobject}{namespace};
		my $load = "use ".$cmd;
		eval($load);
		WebGUI::ErrorHandler::warn("Wobject failed to compile: $cmd.".$@) if($@);
		my $w = $cmd->new($wobject);
		$w->duplicate($_[1]);
	}
	$sth->finish;
}

#-------------------------------------------------------------------
sub _recursePageTree {
	my ($a, %package, %newParent, $newPageId, $sequenceNumber, $urlizedTitle);
	tie %newParent, 'Tie::CPHash';
	tie %package, 'Tie::CPHash';
	%newParent = WebGUI::SQL->quickHash("select * from page where pageId=$_[1]");
	_duplicateWobjects($_[0],$_[1]);
	($sequenceNumber) = WebGUI::SQL->quickArray("select max(sequenceNumber) from page where parentId=$_[1]");
	$a = WebGUI::SQL->read("select * from page where parentId=$_[0] order by sequenceNumber");
	while (%package = $a->hash) {
		$newPageId = getNextId("pageId");
		$sequenceNumber++;
		$urlizedTitle = WebGUI::Page::makeUnique($package{urlizedTitle});
                WebGUI::SQL->write("insert into page (
			pageId,
			parentId,
			title,
			styleId,
			ownerId,
			groupIdView,
			groupIdEdit,
			sequenceNumber,
			metaTags,
			urlizedTitle,
			defaultMetaTags,
			menuTitle,
			synopsis,
			templateId,
			startDate,
			endDate,
			redirectURL,
			userDefined1,
			userDefined2,
			userDefined3,
			userDefined4,
			userDefined5,
			hideFromNavigation,
			newWindow,
			cacheTimeout,
			cacheTimeoutVisitor,
			printableStyleId,
			wobjectPrivileges
			) values (
			$newPageId,
			$_[1],
			".quote($package{title}).",
			$newParent{styleId},
			$session{user}{userId},
			$newParent{groupIdView},
			$newParent{groupIdEdit},
			$sequenceNumber,
			".quote($package{metaTags}).",
			".quote($urlizedTitle).",
			".$package{defaultMetaTags}.",
			".quote($package{menuTitle}).",
			".quote($package{synopsis}).",
			".quote($package{templateId}).",
			$newParent{startDate},
			$newParent{endDate},
			".quote($newParent{redirectURL}).",
			".quote($newParent{userDefined1}).",
			".quote($newParent{userDefined2}).",
			".quote($newParent{userDefined3}).",
			".quote($newParent{userDefined4}).",
			".quote($newParent{userDefined5}).",
			$package{hideFromNavigation},
			$package{newWindow},
			$package{cacheTimeout},
			$package{cacheTimeoutVisitor},
			$package{printableStyleId},
			$package{wobjectPrivileges}
			)");
		_recursePageTree($package{pageId},$newPageId);
	}
	$a->finish;
}

#-------------------------------------------------------------------
sub www_deployPackage {
	if (WebGUI::Privilege::canEditPage()) {
		_recursePageTree($session{form}{pid},$session{page}{pageId});
		return "";
	} else {
		return WebGUI::Privilege::insufficient();
	}
}

1;

