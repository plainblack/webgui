package WebGUI::Wobject::ExtraColumn;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Tie::CPHash;
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Wobject;

our @ISA = qw(WebGUI::Wobject);
our $namespace = "ExtraColumn";
our $name = WebGUI::International::get(1,$namespace);


#-------------------------------------------------------------------
sub duplicate {
        my ($w);
	$w = $_[0]->SUPER::duplicate($_[1]);
        $w = WebGUI::Wobject::ExtraColumn->new({wobjectId=>$w,namespace=>$namespace});
        $w->set({
		spacer=>$_[0]->get("spacer"),
		width=>$_[0]->get("width"),
		class=>$_[0]->get("class")
		});
}

#-------------------------------------------------------------------
sub new {
        my ($self, $class, $property);
        $class = shift;
        $property = shift;
        $self = WebGUI::Wobject->new($property);
        bless $self, $class;
}

#-------------------------------------------------------------------
sub set {
        $_[0]->SUPER::set($_[1],[qw(spacer width class)]);
}

#-------------------------------------------------------------------
sub www_copy {
        if (WebGUI::Privilege::canEditPage()) {
		$_[0]->duplicate;
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_edit {
        my ($output, $f, $endDate, $width, $class, $spacer);
        if (WebGUI::Privilege::canEditPage()) {
                $output = helpIcon(1,$namespace);
		$output .= '<h1>'.WebGUI::International::get(6,$namespace).'</h1>';
        	if ($_[0]->get("wobjectId") eq "new") {
                	$width = 200;
                	$spacer = 10;
        	} else {
                	$width = $_[0]->get("width");
                	$spacer = $_[0]->get("spacer");
        	}
		$class = $_[0]->get("class") || "content";
        	$endDate = $_[0]->get("endDate") || (time()+315360000);
        	$f = WebGUI::HTMLForm->new;
        	$f->hidden("wid",$_[0]->get("wobjectId"));
        	$f->hidden("namespace",$_[0]->get("namespace")) if ($_[0]->get("wobjectId") eq "new");
        	$f->hidden("func","editSave");
        	$f->readOnly($_[0]->get("wobjectId"),WebGUI::International::get(499));
        	$f->hidden("title",$namespace);
        	$f->hidden("displayTitle",0);
        	$f->hidden("processMacros",0);
        	$f->hidden("templatePosition",'A');
        	$f->date("startDate",WebGUI::International::get(497),$_[0]->get("startDate"));
        	$f->date("endDate",WebGUI::International::get(498),$endDate);
		$f->integer("spacer",WebGUI::International::get(3,$namespace),$spacer);
		$f->integer("width",WebGUI::International::get(4,$namespace),$width);
		$f->text("class",WebGUI::International::get(5,$namespace),$class);
        	$f->submit;
        	$output .= $f->print;
		return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editSave {
        if (WebGUI::Privilege::canEditPage()) {
		$_[0]->SUPER::www_editSave();
                $_[0]->set({
			spacer=>$session{form}{spacer},
			width=>$session{form}{width},
			class=>$session{form}{class}
			});
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_view {
	return	'</td><td width="'.$_[0]->get("spacer").'"></td><td width="'.$_[0]->get("width").'" class="'.$_[0]->get("class").'" valign="top">';
}


1;

