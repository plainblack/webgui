package WebGUI::Macro::GroupDelete;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
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
use WebGUI::Session;
use WebGUI::Asset::Template;
use WebGUI::URL;

#-------------------------------------------------------------------
sub process {
	my @param = @_;
	return "" if ($param[0] eq "");
	return "" if ($param[1] eq "");
        return "" if ($session{user}{userId} eq '1');
	my $g = WebGUI::Group->find($param[0]);
	return "" if ($g->groupId eq "");
	return "" unless ($g->autoDelete);
	return "" unless (WebGUI::Grouping::isInGroup($g->groupId));
	my %var = ();
       $var{'group.url'} = WebGUI::URL::page("op=autoDeleteFromGroup;groupId=".$g->groupId);
       $var{'group.text'} = $param[1];
	if ($param[2]) {
		return  WebGUI::Asset::Template->newByUrl($param[2])->process(\%var);
	} else {
		return  WebGUI::Asset::Template->new("PBtmpl0000000000000041")->process(\%var);
	}
}


1;

