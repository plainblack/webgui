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
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Wobject;

our @ISA = qw(WebGUI::Wobject);


#-------------------------------------------------------------------
sub name {
        return WebGUI::International::get(2,$_[0]->get("namespace"));
}

#-------------------------------------------------------------------
sub new {
        my $class = shift;
        my $property = shift;
        my $self = WebGUI::Wobject->new(
                -properties=>$property,
                -extendedProperties=>{
			rssUrl=>{},
			content=>{
				defaultValue=>'Not yet fetched!'
				},
			lastFetched=>{
				defaultValue=>time()
				}
			}
                );
        bless $self, $class;
}


#-------------------------------------------------------------------
sub uiLevel {
        return 6;
}

#-------------------------------------------------------------------
sub www_edit {
	my $f = WebGUI::HTMLForm->new;
	$f->url(
		-name=>"rssUrl",
		-label=>WebGUI::International::get(1,$_[0]->get("namespace")),
		-value=>$_[0]->getValue("rssUrl")
		);
	if ($_[0]->get("wobjectId") ne "new") {
               	$f->readOnly(
			-value=>WebGUI::DateTime::epochToHuman($_[0]->getValue("lastFetched"),"%z %Z"),
			-label=>WebGUI::International::get(5,$_[0]->get("namespace"))
			);
               	$f->readOnly(
			-value=>$_[0]->getValue("content"),
			-label=>WebGUI::International::get(6,$_[0]->get("namespace"))
			);
	} else {
		$f->hidden("content",$_[0]->getValue("content"));
		$f->hidden("lastFetched",$_[0]->getValue("lastFetched"));
	}
	return $_[0]->SUPER::www_edit(
		-properties=>$f->printRowsOnly,
		-headingId=>4,
		-helpId=>1
		);
}


#-------------------------------------------------------------------
sub www_view {
	my ($output);
	$output = $_[0]->displayTitle;
	$output .= $_[0]->description;
	$output .= $_[0]->get("content");
	return $output;
}


1;

