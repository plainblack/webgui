package WebGUI::Wobject::Item;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black LLC.
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
our $namespace = "Item";
our $name = WebGUI::International::get(4,$namespace);

#-------------------------------------------------------------------
sub duplicate {
        my ($w, $f);
        $w = $_[0]->SUPER::duplicate($_[1]);
	$w = WebGUI::Wobject::Item->new({wobjectId=>$w,namespace=>$namespace});
	$w->set({
		linkURL=>$_[0]->get("linkURL"),
		attachment=>$_[0]->get("attachment")
		});
	$f = WebGUI::Attachment->new($_[0]->get("attachment"),$_[0]->get("wobjectId"));
	$f->copy($w->get("wobjectId"));
}

#-------------------------------------------------------------------
sub set {
	$_[0]->SUPER::set($_[1],[qw(linkURL attachment)]);
}

#-------------------------------------------------------------------
sub www_edit {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
        my ($output, $f);
	$output = helpIcon(1,$_[0]->get("namespace"));
	$output .= '<h1>'.WebGUI::International::get(6,$namespace).'</h1>';
	$f = WebGUI::HTMLForm->new;
	$f->url("linkURL",WebGUI::International::get(1,$_[0]->get("namespace")),$_[0]->get("linkURL"));
	$f->raw($_[0]->fileProperty("attachment",2));
	$output .= $_[0]->SUPER::www_edit($f->printRowsOnly);
        return $output;
}

#-------------------------------------------------------------------
sub www_editSave {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
        my ($attachment, $property);
	$_[0]->SUPER::www_editSave();
        $attachment = WebGUI::Attachment->new("",$_[0]->get("wobjectId"));
	$attachment->save("attachment");
	$property->{linkURL} = $session{form}{linkURL};
	$property->{attachment} = $attachment->getFilename if ($attachment->getFilename ne "");
	$_[0]->set($property);
        return "";
}

#-------------------------------------------------------------------
sub www_view {
	my (@test, $output, $file);
	if ($_[0]->get("displayTitle")) {
		$output = '<span class="itemTitle">'.$_[0]->get("title").'</span>';
        	if ($_[0]->get("linkURL")) {
        		$output = '<a href="'.$_[0]->get("linkURL").'">'.$output.'</span></a>';
        	}
	} 
	if ($_[0]->get("attachment") ne "") {
		$file = WebGUI::Attachment->new($_[0]->get("attachment"),$_[0]->get("wobjectId"));
		if ($_[0]->get("displayTitle")) {
			$output .= ' - ';
		}
		$output .= '<a href="'.$file->getURL.'"><img src="'.$file->getIcon.'" border=0 alt="'.
			$_[0]->get("attachment").'" width=16 height=16 border=0 align="middle"></a>';
	}
	if ($_[0]->get("description") ne "") {
		$output .= ' - '.$_[0]->get("description");
	}
        return $_[0]->processMacros($output);
}	


1;

