package WebGUI::Macro::Execute;

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

Package WebGUI::Macro::Execute

=head1 DESCRIPTION

Allows a content manager or administrator to execute an external program.

=head2 process ( system_call )

=head3 system_call

The system call to execute.  STDOUT from the call will be captured and
returned.  Calls containing the words passwd, shadow or .conf will
be blocked and an error message returned instead.

=cut


#-------------------------------------------------------------------
sub process {
	my $session = shift;
        my @param = @_;
	if ($param[0] =~ /passwd/ || $param[0] =~ /shadow/ || $param[0] =~ /\.conf/) {
		my $i18n = WebGUI::International->new($session, 'Macro_Execute');
		return $i18n->get('execute error');
	} else {
       		return `$param[0]`;
	}
}

1;


