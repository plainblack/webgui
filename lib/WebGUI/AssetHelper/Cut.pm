package WebGUI::AssetHelper::Cut;

use strict;
use Class::C3;
use base qw/WebGUI::AssetHelper/;

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

Package WebGUI::AssetHelper::Cut

=head1 DESCRIPTION

Cuts an Asset to the Clipboard.

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 process ( $class, $asset )

Cuts the asset to the clipboard.  If the user cannot edit the asset, or the asset is a
system asset, it returns an error message.

=cut

sub process {
    my ($class, $asset) = @_;
    my $session = $asset->session;

    my $i18n = WebGUI::International->new($session, 'WebGUI');
    if (! $asset->canEdit) {
        return { error => $i18n->get('38'), };
    }
    elsif ( $asset->get('isSystem') ) {
        return { error => $i18n->get('41'), };
    }

    return {
        openDialog      => '?op=assetHelper;className=' . $class . ';method=cut;assetId=' . $asset->getId,
    };
}

#----------------------------------------------------------------------------

=head2 www_cut ( $class, $asset )

Show the progress bar while cutting the asset.

=cut

sub www_cut {
    my ( $class, $asset ) = @_;
    my $session = $asset->session;
    my $i18n    = WebGUI::International->new($session, 'Asset');

    return $session->response->stream( sub {
        my ( $session ) = @_;
        my $pb = WebGUI::ProgressBar->new($session);
        my @stack;

        return $pb->run(
            admin => 1,
            title => $i18n->get('Copy Assets'),
            icon  => $session->url->extras('adminConsole/assets.gif'),
            code  => sub {
                my $bar = shift;
                $bar->update( "Preparing... (i18n)" );
                $bar->total( $asset->getDescendantCount + 2 );
                $bar->update( "Cutting... (i18n)" );
                my $success = $asset->cut();
                if (! $success) {
                    return { error => $i18n->get('41', 'WebGUI'), };
                }
                return { message => "Your asset is cut!" };
            },
            wrap  => {
                'WebGUI::Asset::getLineageIterator' => sub {
                    my ($bar, $orig, $asset, @args) = @_;
                    $bar->update("Updating descendants... (i18n)");
                    return $asset->$orig(@args);
                },
                'WebGUI::Asset::updateHistory' => sub {
                    my ( $bar, $orig, $asset, @args ) = @_;
                    $bar->update( "Updating " . $asset->getTitle );
                    return $asset->$orig(@args);
                },
            },
        );
    } );
}

1;
