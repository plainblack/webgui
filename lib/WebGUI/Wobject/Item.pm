package WebGUI::Wobject::Item;

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
use WebGUI::Attachment;
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::Utility;
use WebGUI::Wobject;

our @ISA = qw(WebGUI::Wobject);

#-------------------------------------------------------------------
sub duplicate {
        my ($w, $f);
        $w = $_[0]->SUPER::duplicate($_[1]);
	$f = WebGUI::Attachment->new($_[0]->get("attachment"),$_[0]->get("wobjectId"));
	$f->copy($w);
}

#-------------------------------------------------------------------
sub name {
        return WebGUI::International::get(4,$_[0]->get("namespace"));
}

#-------------------------------------------------------------------
sub new {
        my $class = shift;
        my $property = shift;
        my $self = WebGUI::Wobject->new(
                -properties=>$property,
                -extendedProperties=>{
			linkURL=>{}, 
			attachment=>{}
			},
		-useTemplate=>1
                );
        bless $self, $class;
}

#-------------------------------------------------------------------
sub www_edit {
	my $properties = WebGUI::HTMLForm->new;
	$properties->url(
		-name=>"linkURL",
		-label=>WebGUI::International::get(1,$_[0]->get("namespace")),
		-value=>$_[0]->getValue("linkURL"));
	$properties->raw($_[0]->fileProperty("attachment",2));
	return $_[0]->SUPER::www_edit(
		-properties=>$properties->printRowsOnly,
		-headingId=>6,
		-helpId=>1
		);
}

#-------------------------------------------------------------------
sub www_editSave {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
        my ($attachment, $property);
	$_[0]->SUPER::www_editSave() if ($_[0]->get("wobjectId") eq "new");
        $attachment = WebGUI::Attachment->new("",$_[0]->get("wobjectId"));
	$attachment->save("attachment");
	$property->{attachment} = $attachment->getFilename if ($attachment->getFilename ne "");
	$_[0]->SUPER::www_editSave($property);
        return "";
}

#-------------------------------------------------------------------
sub www_view {
	my ($file, %var);
	if ($_[0]->get("attachment") ne "") {
		$file = WebGUI::Attachment->new($_[0]->get("attachment"),$_[0]->get("wobjectId"));
		$var{"attachment.name"} = $file->getFilename;
		$var{"attachment.URL"} = $file->getURL;
		$var{"attachment.Icon"} = $file->getIcon;
	}
        return $_[0]->processTemplate($_[0]->get("templateId"),\%var);
}	


1;

