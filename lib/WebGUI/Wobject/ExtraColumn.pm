package WebGUI::Wobject::ExtraColumn;

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
use Tie::IxHash;
use WebGUI::DateTime;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Page;
use WebGUI::TabForm;
use WebGUI::Template;
use WebGUI::Wobject;

our @ISA = qw(WebGUI::Wobject);


#-------------------------------------------------------------------
sub duplicate {
        my ($w);
	$w = $_[0]->SUPER::duplicate($_[1]);
        $w = WebGUI::Wobject::ExtraColumn->new({wobjectId=>$w,namespace=>$_[0]->get("namespace")});
        $w->set({
		spacer=>$_[0]->get("spacer"),
		width=>$_[0]->get("width"),
		class=>$_[0]->get("class")
		});
}

#-------------------------------------------------------------------
sub name {
        return WebGUI::International::get(1,$_[0]->get("namespace"));
}

#-------------------------------------------------------------------
sub new {
        my $class = shift;
        my $property = shift;
        my $self = WebGUI::Wobject->new(
                $property,
                [qw(spacer width class)]
                );
        bless $self, $class;
}

#-------------------------------------------------------------------
sub uiLevel {
        return 1;
}

#-------------------------------------------------------------------
sub www_edit {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
        my ($output, $f, $endDate, $width, $class, $spacer,$startDate, $templatePosition);
        $output = helpIcon(1,$_[0]->get("namespace"));
	$output .= '<h1>'.WebGUI::International::get(6,$_[0]->get("namespace")).'</h1>';
        $width = $_[0]->get("width") || 200;
        $spacer = $_[0]->get("spacer") || 10;
	$templatePosition = $_[0]->get("templatePosition") || 1;
	$class = $_[0]->get("class") || "content";
       	$startDate = $_[0]->get("startDate") || $session{page}{startDate};
       	$endDate = $_[0]->get("endDate") || $session{page}{endDate};
	my %tabs;
        tie %tabs, 'Tie::IxHash';
        %tabs = (
                properties=>{
                        label=>WebGUI::International::get(893)
                        },
                layout=>{
                        label=>WebGUI::International::get(105),
                        uiLevel=>5
                        },
                privileges=>{
                        label=>WebGUI::International::get(107),
                        uiLevel=>9
                        }
                );
       	$f = WebGUI::TabForm->new(\%tabs);
       	$f->hidden({name=>"wid",value=>$_[0]->get("wobjectId")});
       	$f->hidden({name=>"namespace",value=>$_[0]->get("namespace")}) if ($_[0]->get("wobjectId") eq "new");
       	$f->hidden({name=>"func",value=>"editSave"});
       	$f->getTab("properties")->readOnly($_[0]->get("wobjectId"),WebGUI::International::get(499));
       	$f->hidden({name=>"title",value=>$_[0]->name});
       	$f->hidden({name=>"displayTitle",value=>0});
	$f->getTab("layout")->select(
                -name=>"templatePosition",
                -label=>WebGUI::International::get(363),
                -value=>[$templatePosition],
                -uiLevel=>5,
                -options=>WebGUI::Page::getTemplatePositions($session{page}{templateId}),
                -subtext=>WebGUI::Page::drawTemplate($session{page}{templateId})
                );
       	$f->getTab("privileges")->date("startDate",WebGUI::International::get(497),$startDate);
       	$f->getTab("privileges")->date("endDate",WebGUI::International::get(498),$endDate);
	$f->getTab("properties")->integer("spacer",WebGUI::International::get(3,$_[0]->get("namespace")),$spacer);
	$f->getTab("properties")->integer("width",WebGUI::International::get(4,$_[0]->get("namespace")),$width);
	$f->getTab("properties")->text("class",WebGUI::International::get(5,$_[0]->get("namespace")),$class);
       	$output .= $f->print;
	return $output;
}

#-------------------------------------------------------------------
sub www_editSave {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
	$_[0]->SUPER::www_editSave({
		spacer=>$session{form}{spacer},
		width=>$session{form}{width},
		class=>$session{form}{class}
		});
        return "";
}

#-------------------------------------------------------------------
sub www_view {
	return	'</td><td width="'.$_[0]->get("spacer").'"></td><td width="'.$_[0]->get("width").'" class="'.$_[0]->get("class").'" valign="top">';
}


1;

