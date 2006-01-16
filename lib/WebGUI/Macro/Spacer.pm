package WebGUI::Macro::Spacer;

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

#-------------------------------------------------------------------

=head1 NAME

Package WebGUI::Macro::Spacer

=head1 DESCRIPTION

Macro for outputting a spacer graphic.

=head2 process ( [width, height] )

process takes returns an IMG tag pointing to the spacer gif in the WebGUI
extras directory.

=head3 width

Set the width of the spacer.

=head3 height

Set the height of the spacer.

=cut

sub process {
	my $session = shift; use WebGUI; WebGUI::dumpSession($session);
        my ($output, @param, $width, $height);
        @param = @_;
        $width = $param[0] if defined $param[0];
        $height = $param[1] if defined $param[1];
        $output = '<img src="'.$session->config->get("extrasURL").'/spacer.gif"'.(defined $width?' width="'.$width.'"':'').(defined $height?' height="'.$height.'"':'').' border="0" alt="" />';
        return $output;
}

1;

