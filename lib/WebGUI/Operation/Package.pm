package WebGUI::Operation::Package;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2004 Plain Black Corporation.
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
use WebGUI::Id;
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
	my $sth = WebGUI::SQL->read("select * from wobject where pageId=".quote($_[0])." order by sequenceNumber");
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
	my ($a, %package, %newParent,$currentPage,$page);
	tie %newParent, 'Tie::CPHash';
	tie %package, 'Tie::CPHash';
	%newParent = WebGUI::SQL->quickHash("select * from page where pageId=$_[1]");
	_duplicateWobjects($_[0],$_[1]);
	$a = WebGUI::SQL->read("select * from page where parentId=$_[0] order by sequenceNumber");
	while (%package = $a->hash) {
		$currentPage = WebGUI::Page->getPage($_[1]);
		$page = $currentPage->add;
		$page->set({
			title => $package{title},
			styleId => $newParent{styleId},
			printableStyleId => $package{printableStyleId},
			ownerId => $session{user}{userId},
			groupIdView => $newParent{groupIdView},
			groupIdEdit => $newParent{groupIdEdit},
			newWindow => $package{newWindow},
			wobjectPrivileges => $package{wobjectPrivileges},
			hideFromNavigation => $package{hideFromNavigation},
			startDate => $newParent{startDate},
			endDate => $newParent{endDate},
			cacheTimeout => $package{cacheTimeout},
			cacheTimeoutVisitor => $package{cacheTimeoutVisitor},
			metaTags => $package{metaTags},
			urlizedTitle => WebGUI::Page::makeUnique($package{urlizedTitle}),
			redirectURL => $newParent{redirectURL},
			defaultMetaTags => $package{defaultMetaTags},
			templateId => $package{templateId},
			menuTitle => $package{menuTitle},
			synopsis => $package{synopsis}
		});
		_recursePageTree($package{pageId},$page->get('pageId'));
	}
	$a->finish;
}


#-------------------------------------------------------------------
sub www_deployPackage {
	if (WebGUI::Page::canEdit()) {
		_recursePageTree($session{form}{pid},$session{page}{pageId});
		return "";
	} else {
		return WebGUI::Privilege::insufficient();
	}
}

1;

