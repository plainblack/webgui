package WebGUI::AssetHelper::Duplicate;

use strict;
use Class::C3;
use base qw/WebGUI::AssetHelper/;
use Scalar::Util qw( blessed );

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Duplicateright 2001-2009 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=head1 NAME

Package WebGUI::AssetHelper::Duplicate

=head1 DESCRIPTION

Duplicate an Asset, with no children.

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 process ()

Fork the duplicate operation

=cut

sub process {
    my ($self) = @_;
    my $asset = $self->asset;
    my $session = $self->session;

    # Should we autocommit?
    my $commit = $session->setting->get('versionTagMode') eq 'autoCommit';

    # Fork the Duplicate. Forking makes sure it won't get interrupted
    my $fork    = WebGUI::Fork->start(
        $session, blessed( $self ), 'duplicate', { assetId => $asset->getId, commit => $commit },
    );

    return {
        forkId      => $fork->getId,
    };
}

#-------------------------------------------------------------------

=head2 duplicate ( $process, $args )

Perform the duplicate stuff in a forked process

=cut

sub duplicate {
    my ($process, $args) = @_;
    my $session = $process->session;
    my $asset = WebGUI::Asset->newById($session, $args->{assetId});
    my $tree  = WebGUI::ProgressTree->new($session, [ $asset->getId ] );
    $process->update(sub { $tree->json });
    my $newAsset = $asset->duplicate;

    # If we aren't committing, add to a tag
    if ( !$args->{commit} ) {
        $newAsset->update({
            status      => "pending",
            tagId       => WebGUI::VersionTag->getWorking( $session )->getId,
        });
    }
    $newAsset->update({ title => $newAsset->getTitle . ' (Duplicate)'});

    $tree->success($asset->getId);
    $process->update(sub { $tree->json });
}

1;
