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
sub name {
        return WebGUI::International::get(1,$_[0]->get("namespace"));
}

#-------------------------------------------------------------------
sub new {
        my $class = shift;
        my $property = shift;
        my $self = WebGUI::Wobject->new(
                -properties=>$property,
                -extendedProperties=>{
			spacer=>{
				defaultValue=>10
				},
			width=>{
				defaultValue=>200
				}, 
			class=>{
				defaultValue=>"content"
				}
			}
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
        my ($output, $f);
        $output = helpIcon(1,$_[0]->get("namespace"));
	$output .= '<h1>'.WebGUI::International::get(6,$_[0]->get("namespace")).'</h1>';
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
       	$f->getTab("properties")->readOnly(
		-value=>$_[0]->get("wobjectId"),
		-label=>WebGUI::International::get(499)
		);
       	$f->hidden({name=>"title",value=>$_[0]->name});
       	$f->hidden({name=>"displayTitle",value=>$_[0]->getValue("displayTitle")});
	$f->getTab("layout")->select(
                -name=>"templatePosition",
                -label=>WebGUI::International::get(363),
                -value=>[$_[0]->getValue("templatePosition")],
                -uiLevel=>5,
                -options=>WebGUI::Page::getTemplatePositions($session{page}{templateId}),
                -subtext=>WebGUI::Page::drawTemplate($session{page}{templateId})
                );
       	$f->getTab("privileges")->date(
		-name=>"startDate",
		-label=>WebGUI::International::get(497),
		-value=>$_[0]->getValue("startDate")
		);
       	$f->getTab("privileges")->date(
		-name=>"endDate",
		-label=>WebGUI::International::get(498),
		-value=>$_[0]->getValue("endDate")
		);
	$f->getTab("properties")->integer(
		-name=>"spacer",
		-label=>WebGUI::International::get(3,$_[0]->get("namespace")),
		-value=>,$_[0]->getValue("spacer")
		);
	$f->getTab("properties")->integer(
		-name=>"width",
		-label=>WebGUI::International::get(4,$_[0]->get("namespace")),
		-value=>$_[0]->getValue("width")
		);
	$f->getTab("properties")->text(
		-name=>"class",
		-label=>WebGUI::International::get(5,$_[0]->get("namespace")),
		-value=>$_[0]->get("class")
		);
       	$output .= $f->print;
	return $output;
}

#-------------------------------------------------------------------
sub www_view {
	return	'</td><td width="'.$_[0]->get("spacer").'"></td><td width="'.$_[0]->get("width").'" class="'.$_[0]->get("class").'" valign="top">';
}


1;

