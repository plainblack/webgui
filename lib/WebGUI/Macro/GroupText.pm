package WebGUI::Macro::GroupText;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;

=head1 NAME

Package WebGUI::Macro::GroupText

=head1 DESCRIPTION

Macro for displaying a text message to user's in a certain group.

=head2 process ( groupName, member, nonMember )

Either the member or nonMember texts can be blank.

=head3 groupName

The name of the group whose members will be shown the message.

=head3 member

The text to be displayed to someone in the group.

=head3 nonMember

Text to be shown to someone not in the group.

=cut


#-------------------------------------------------------------------
sub process {
	my $session = shift; use WebGUI; WebGUI::dumpSession($session);
	my @param = @_;
	my ($groupId) = $session->dbSlave->quickArray("select groupId from groups where groupName=".$session->db->quote($param[0]));
	$groupId = 3 if ($groupId eq "");
	if ($session->user->isInGroup($groupId)) { 
		return $param[1];
	} else {
		return $param[2];
	}
}


1;

