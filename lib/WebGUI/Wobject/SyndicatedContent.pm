package WebGUI::Wobject::SyndicatedContent;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2003 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Tie::CPHash;
use WebGUI::DateTime;
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Wobject;

our @ISA = qw(WebGUI::Wobject);
our $namespace = "SyndicatedContent";
our $name = WebGUI::International::get(2,$namespace);

#-------------------------------------------------------------------
sub duplicate {
	my ($w);
	$w = $_[0]->SUPER::duplicate($_[1]);
        $w = WebGUI::Wobject::SyndicatedContent->new({wobjectId=>$w,namespace=>$namespace});
	$w->set({
		rssUrl=>$_[0]->get("rssUrl"),
		content=>$_[0]->get("content"),
		lastFetched=>$_[0]->get("lastFetched")
		});
}

#-------------------------------------------------------------------
sub set {
        $_[0]->SUPER::set($_[1], [qw(rssUrl content lastFetched)]);
}

#-------------------------------------------------------------------
sub uiLevel {
        return 6;
}

#-------------------------------------------------------------------
sub www_edit {
        return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
        my ($output, $f);
        $output = helpIcon(1,$namespace);
	$output .= '<h1>'.WebGUI::International::get(4,$namespace).'</h1>';
	$f = WebGUI::HTMLForm->new;
	$f->url("rssUrl",WebGUI::International::get(1,$namespace),$_[0]->get("rssUrl"));
	if ($_[0]->get("wobjectId") ne "new") {
               	$f->readOnly(WebGUI::DateTime::epochToHuman($_[0]->get("lastFetched"),"%z %Z"),WebGUI::International::get(5,$namespace));
               	$f->readOnly($_[0]->get("content"),WebGUI::International::get(6,$namespace));
	} else {
		$f->hidden("content","Not yet fetched!");
		$f->hidden("lastFetched",time());
	}
	$output .= $_[0]->SUPER::www_edit($f->printRowsOnly);
        return $output;
}

#-------------------------------------------------------------------
sub www_editSave {
        return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
	my ($property);
	$property->{rssUrl} = $session{form}{rssUrl};
	$property->{content} = $session{form}{content} if ($session{form}{content} ne "");
	$property->{lastFetched} = $session{form}{lastFetched} if ($session{form}{lastFetched} ne "");
	$_[0]->SUPER::www_editSave($property);
        return "";
}

#-------------------------------------------------------------------
sub www_view {
	my ($output);
	$output = $_[0]->displayTitle;
	$output .= $_[0]->description;
	$output = $_[0]->processMacros($output);
	$output .= $_[0]->get("content");
	return $output;
}


1;

