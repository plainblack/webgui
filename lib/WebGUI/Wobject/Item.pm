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
	$w = WebGUI::Wobject::Item->new({wobjectId=>$w,namespace=>$_[0]->get("namespace")});
	$w->set({
		linkURL=>$_[0]->get("linkURL"),
		attachment=>$_[0]->get("attachment"),
		templateId=>$_[0]->get("templateId")
		});
	$f = WebGUI::Attachment->new($_[0]->get("attachment"),$_[0]->get("wobjectId"));
	$f->copy($w->get("wobjectId"));
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
                $property,
                [qw(linkURL attachment templateId)]
                );
        bless $self, $class;
}

#-------------------------------------------------------------------
sub www_edit {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
        my ($output, $f, $template);
	$template = $_[0]->get("templateId") || 1;
	$output = helpIcon(1,$_[0]->get("namespace"));
	$output .= '<h1>'.WebGUI::International::get(6,$_[0]->get("namespace")).'</h1>';
	$f = WebGUI::HTMLForm->new;
	$f->url("linkURL",WebGUI::International::get(1,$_[0]->get("namespace")),$_[0]->get("linkURL"));
	$f->raw($_[0]->fileProperty("attachment",2));
	$f->template(
                -name=>"templateId",
                -value=>$template,
                -namespace=>$_[0]->get("namespace"),
                -label=>WebGUI::International::get(72,$_[0]->get("namespace")),
                -afterEdit=>'func=edit&wid='.$_[0]->get("wobjectId")
                );
	$output .= $_[0]->SUPER::www_edit($f->printRowsOnly);
        return $output;
}

#-------------------------------------------------------------------
sub www_editSave {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
        my ($attachment, $property);
	$_[0]->SUPER::www_editSave() if ($_[0]->get("wobjectId") eq "new");
        $attachment = WebGUI::Attachment->new("",$_[0]->get("wobjectId"));
	$attachment->save("attachment");
	$property->{linkURL} = $session{form}{linkURL};
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

