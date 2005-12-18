package WebGUI::Macro::GroupAdd;

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

=head1 NAME

Package WebGUI::Macro::GroupAdd

=head1 DESCRIPTION

Macro that allows users to add themselves to a group.

=head2 process ( groupName, text, [ template ] )

=head3 groupName

The name of a group.  The group must exist and be set up for auto adds for the link
to be shown.

=head3 text

The text that will be displayed to the user in the link for adding themselves
to the group.

=head3 template

An optional template for formatting the text and link.

=cut


#-------------------------------------------------------------------
sub process {
	my @param = @_;
	return "" if ($param[0] eq "");
	return "" if ($param[1] eq "");
	return "" if ($session{user}{userId} eq '1');
	my $g = WebGUI::Group->find($param[0]);
	return "" if ($g->groupId eq "");
	return "" unless ($g->autoAdd);
	return "" if (WebGUI::Grouping::isInGroup($g->groupId));
	my %var = ();
	$var{'group.url'} = WebGUI::URL::page("op=autoAddToGroup;groupId=".$g->groupId);
	$var{'group.text'} = $param[1];
	if ($param[2]) {
		return  WebGUI::Asset::Template->newByUrl($param[2])->process(\%var);
	} else {
		return  WebGUI::Asset::Template->new("PBtmpl0000000000000040")->process(\%var);
	}
}


1;

