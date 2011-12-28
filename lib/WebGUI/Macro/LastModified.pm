package WebGUI::Macro::LastModified;

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
use WebGUI::Asset;
use WebGUI::International;

=head1 NAME

Package WebGUI::Macro::LastModified

=head1 DESCRIPTION

Macro for displaying the date that the most recent revision of the Asset was last modified.

=head2 process ( [label, format] )

=head3 label

Text to prepend to the date.  This can be the empty string.

=head3 format string

A string specifying how to format the date using codes similar to those used by
sprintf.  See L<WebGUI::Session::datetime/"epochToHuman"> for a list of codes.  Uses
"%z" if empty.

=cut


#-------------------------------------------------------------------
sub process {
	my $session = shift;
	return '' unless $session->asset;
	my ($label, $format, $time);
	($label, $format) = @_;
	$format = '%z' if ($format eq "");
	($time) = $session->dbSlave->quickArray("SELECT max(revisionDate) FROM assetData where assetId=?",[$session->asset->getId]);
	if ($time) {
		return $label.$session->datetime->epochToHuman($time,$format);
	}
	my $i18n = WebGUI::International->new($session,'Macro_LastModified');
	return $i18n->get('never');
}

1;
