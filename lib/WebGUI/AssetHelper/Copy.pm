package WebGUI::AssetHelper::Copy;

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

Package WebGUI::AssetHelper::Copy

=head1 DESCRIPTION

Copy an Asset to the Clipboard, with no children.

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 process ( $asset )

Open a progress dialog for the copy operation

=cut

sub process {
    my ($self, $asset) = @_;

    return {
        openDialog => '?op=assetHelper;helperId=' . $self->id . ';method=copy;assetId=' . $asset->getId,
    };
}

#----------------------------------------------------------------------------

=head2 www_copy ( $asset )

Perform the copy operation, showing the progress.

=cut

sub www_copy {
    my ( $self, $asset ) = @_;
    my $session = $asset->session;
    my $i18n    = WebGUI::International->new($session, 'Asset');

    return $session->response->stream( sub {
        my ( $session ) = @_;
        my $pb = WebGUI::ProgressBar->new($session);
        my @stack;

        return $pb->run(
            admin   => 1,
            total   => 2,
            title => $i18n->get('Copy Assets'),
            icon  => $session->url->extras('adminConsole/assets.gif'),
            code  => sub {
                my $bar = shift;
                my $newAsset = $asset->duplicate;
                $bar->update($i18n->get('cut'));
                my $title   = sprintf("%s (%s)", $asset->getTitle, $i18n->get('copy'));
                $newAsset->update({ title => $title });
                $newAsset->cut;
                my $result = WebGUI::VersionTag->autoCommitWorkingIfEnabled(
                    $session, {
                        allowComments => 1,
                        returnUrl     => $asset->getUrl,
                    }
                );
                if ( $result eq 'redirect' ) {
                    return $asset->getUrl;
                }
                return { message => 'Your asset is now copied!' };
            },
            wrap  => {
                'WebGUI::Asset::duplicate' => sub {
                    my ($bar, $original, $asset, @args) = @_;
                    my $name = join '/', @stack, $asset->getTitle;
                    $bar->update($name);
                    return $asset->$original(@args);
                },
            }
        );
    } );
}

1;
