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
    my ( $class, $asset ) = @_;
    my $session = $asset->session;
    my $i18n    = WebGUI::International->new($session, 'Asset');

    my $childrenOnly = lc $session->form->get('with') eq 'children';

    return $session->response->stream( sub {
        my ( $session ) = @_;
        my @stack;

        my $pb = WebGUI::ProgressBar->new($session);
        return $pb->run(
            admin   => 1,
            title => $i18n->get('Copy Assets'),
            icon  => $session->url->extras('adminConsole/assets.gif'),
            code  => sub {
                my $bar = shift;
                # First calculate the total
                $bar->update("Preparing copy (i18n)");
                $bar->total( $asset->getDescendantCount + 1 );
                my $newAsset = $asset->duplicateBranch( $childrenOnly );
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
                return;
            },
            wrap  => {
                'WebGUI::Asset::duplicateBranch' => sub {
                    my ($bar, $original, $asset, @args) = @_;
                    push(@stack, $asset->getTitle);
                    my $ret = $asset->$original(@args);
                    pop(@stack);
                    return $ret;
                },
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
