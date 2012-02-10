package WebGUI::Macro::GroupDelete;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Group;
use WebGUI::Asset::Template;

=head1 NAME

Package WebGUI::Macro::GroupDelete

=head1 DESCRIPTION

Macro that allows users to remove themselves to a group.

=head2 process ( groupName, text, [ template ] )

=head3 groupName

The name of a group.  The group must exist and be set up for auto deletes for the link
to be shown.

=head3 text

The text that will be displayed to the user in the link for removing themselves
to the group.

=head3 template

The URL of an optional template for formatting the text and link.

=cut


#-------------------------------------------------------------------
sub process {
	my ($session, $groupName, $text, $template) = @_;
	return "" if ($groupName eq "");
	return "" if ($text eq "");
        return "" if ($session->user->isVisitor);
	my $g = WebGUI::Group->find($session, $groupName);
	return "" unless defined $g->getId;
	return "" unless ($g->autoDelete);
	return "" unless ($session->user->isInGroup($g->getId));
	my %var = ();
	$var{'group.url'} = $session->url->page("op=autoDeleteFromGroup;groupId=".$g->getId);
	$var{'group.text'} = $text;
	if ($template) {
		return  WebGUI::Asset::Template->newByUrl($session,$template)->process(\%var);
	} else {
		return  WebGUI::Asset::Template->newById($session,"PBtmpl0000000000000041")->process(\%var);
	}
}


1;

