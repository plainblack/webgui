package WebGUI::AssetHelper::CopyBranch;

use strict;
use Class::C3;
use base qw/WebGUI::AssetHelper::Copy/;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=head1 NAME

Package WebGUI::AssetHelper::CopyBranch

=head1 DESCRIPTION

Copy an Asset to the Clipboard, with children or descendants

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 process ( $class, $asset )

Open a progress dialog for the copy operation

=cut

sub process {
    my ($class, $asset) = @_;

    return {
        openDialog => '?op=assetHelper;className=' . $class . ';method=getWith;assetId=' . $asset->getId
    };
}

#----------------------------------------------------------------------------

=head2 www_getWith ( $class, $asset )

Get the "with" configuration. "Descendants" or "Children".

=cut

sub www_getWith {
    my ( $class, $asset ) = @_;
    my $session = $asset->session;
    my $i18n    = WebGUI::International->new($session, 'Asset');

    return '<form style="text-align: center">'
        . '<input type="hidden" name="op" value="assetHelper" />'
        . '<input type="hidden" name="className" value="' . $class . '" />'
        . '<input type="hidden" name="assetId" value="' . $asset->getId . '" />'
        . '<input type="hidden" name="method" value="copy" />'
        . '<input type="submit" name="with" value="Children" />'
        . '<input type="submit" name="with" value="Descendants" />'
        . '</form>'
        ;
}


#----------------------------------------------------------------------------

=head2 www_copy ( $class, $asset )

Perform the copy operation, showing the progress.

=cut

sub www_copy {
    my ($class, $asset) = @_;
    my $session = $asset->session;

    $asset->forkWithStatusPage({
            plugin   => 'ProgressTree',
            title    => 'Copy Assets',
            method   => 'copyInFork',
            dialog   => 1,
            message  => 'Your assets are now copied!',
            args     => {
                childrenOnly => $session->form->get('with') eq 'children',
                assetId      => $asset->getId,
            }
        }
    );
}

1;
