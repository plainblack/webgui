package WebGUI::Operation::Replacements;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2004 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::AdminConsole;
use WebGUI::Grouping;
use WebGUI::Icon;
use WebGUI::HTMLForm;
use WebGUI::International;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;

#-------------------------------------------------------------------
sub _submenu {
        my $workarea = shift;
        my $title = shift;
        $title = WebGUI::International::get($title) if ($title);
        my $help = shift;
        my $ac = WebGUI::AdminConsole->new("contentFilters");
        if ($help) {
                $ac->setHelp($help);
        }
        $ac->addSubmenuItem(WebGUI::URL::page("op=editReplacement&amp;replacementId=new"), WebGUI::International::get(1047));
        $ac->addSubmenuItem(WebGUI::URL::page("op=listReplacements"), WebGUI::International::get("content filters"));
        return $ac->render($workarea, $title);
}


#-------------------------------------------------------------------
sub www_deleteReplacement {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	WebGUI::SQL->write("delete from replacements where replacementId=".quote($session{form}{replacementId}));
	return www_listReplacements();
}

#-------------------------------------------------------------------
sub www_editReplacement {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	my $data = WebGUI::SQL->getRow("replacements","replacementId",$session{form}{replacementId});
	my $f = WebGUI::HTMLForm->new;
	$f->hidden(
		-name=>"op",
		-value=>"editReplacementSave"
		);
	$f->hidden(
		-name=>"replacementId",
		-value=>$session{form}{replacementId}
		);
	$f->readOnly(
		-label=>WebGUI::International::get(1049),
		-value=>$session{form}{replacementId}
		);
	$f->text(
		-name=>"searchFor",
		-label=>WebGUI::International::get(1050),
		-value=>$data->{searchFor}
		);
	$f->textarea(
		-label=>WebGUI::International::get(1051),
		-name=>"replaceWith",
		-value=>$data->{replaceWith}
		);
	$f->submit;
	return _submenu($f->print,"1052");
}

#-------------------------------------------------------------------
sub www_editReplacementSave {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	WebGUI::SQL->setRow("replacements","replacementId",{
		replacementId=>$session{form}{replacementId},
		searchFor=>$session{form}{searchFor},
		replaceWith=>$session{form}{replaceWith}
		});
	return www_listReplacements();
}

#-------------------------------------------------------------------
sub www_listReplacements {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	my $output = '<table>';
	my $sth = WebGUI::SQL->read("select replacementId,searchFor from replacements order by searchFor");
	while (my $data = $sth->hashRef) {
		$output .= '<tr><td>'.deleteIcon("op=deleteReplacement&amp;replacementId=".$data->{replacementId})
			.editIcon("op=editReplacement&amp;replacementId=".$data->{replacementId}).'</td>';
		$output .= '<td class="tableData">'.$data->{searchFor}.'</td></tr>';
	}
	$sth->finish;
	$output .= '</table>';
	return _submenu($output);
}



1;
