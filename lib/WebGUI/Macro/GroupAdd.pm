package WebGUI::Macro::GroupAdd;

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
use WebGUI::Group;
use WebGUI::Grouping;
use WebGUI::Macro;
use WebGUI::Session;
use WebGUI::Template;
use WebGUI::URL;

#-------------------------------------------------------------------
sub process {
	my @param = WebGUI::Macro::getParams($_[0]);
	return "" if ($param[0] eq "");
	return "" if ($param[1] eq "");
	return "" if ($session{user}{userId} eq '1');
	my $g = WebGUI::Group->find($param[0]);
	return "" if ($g->groupId eq "");
	return "" unless ($g->autoAdd);
	return "" if (WebGUI::Grouping::isInGroup($g->groupId));
       my %var = ();
       $var{'group.url'} = WebGUI::URL::page("op=autoAddToGroup&groupId=".$g->groupId);
       $var{'group.text'} = $param[1];
       return WebGUI::Template::process(WebGUI::Template::getIdByName($param[2],"Macro/GroupAdd"), "Macro/GroupAdd", \%var);
}


1;

