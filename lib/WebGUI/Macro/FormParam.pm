package WebGUI::Macro::FormParam;

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

Package WebGUI::Macro::FormParam

=head1 DESCRIPTION

Macro for pulling the value of any form field by specifying the name of the form field.  This
macro is mainly used for making SQL Reports with dynamic queries.

=head2 process ( fieldName )

=head3 fieldName

The name of the field to pull from the session object.

=cut


#-------------------------------------------------------------------
sub process {
	my $session = shift;
	return $session->form->process(shift);
}


1;

