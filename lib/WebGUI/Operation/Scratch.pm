package WebGUI::Operation::Scratch;

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

=head1 NAME

Package WebGUI::Operation::Scratch

=head1 DESCRIPTION

Operations that provide access to the scratch area of the session variable.

=cut

#-------------------------------------------------------------------

=head2 www_deleteScratch ( )

Delete a variable from the session scratch area by setting a form
variable, scratchName.

=cut

sub www_deleteScratch {
	my $session = shift;
	$session->scratch->delete("www_".$session->form->process("scratchName"));
	return "";
}

#-------------------------------------------------------------------

=head2 www_setScratch ( )


Set a variable in the session scratch area by setting forms
variables, scratchName, the name of the variable to set, and scratchValue,
the value the variable should take.

=cut

sub www_setScratch {
	my $session = shift;
	$session->scratch->set("www_".$session->form->process("scratchName"),$session->form->process("scratchValue"));
	return "";
}


1;
