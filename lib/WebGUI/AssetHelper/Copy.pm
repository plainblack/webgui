package WebGUI::AssetHelper::Copy;

use strict;
use Class::C3;
use base qw/WebGUI::AssetHelper/;
use Scalar::Util qw( blessed );

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

=head2 process ( )

Fork the copy operation

=cut

sub process {
    my ($self) = @_;
    my $asset   = $self->asset;
    my $session = $self->session;

    # Should we autocommit?
    my $commit = $session->setting->get('versionTagMode') eq 'autoCommit';

    # Fork the copy. Forking makes sure it won't get interrupted
    my $fork    = WebGUI::Fork->start(
        $session, blessed( $self ), 'copy', { assetId => $asset->getId, commit => $commit },
    );

    return {
        forkId      => $fork->getId,
    };
}

#-------------------------------------------------------------------

=head2 copy ( $process, $args )

Perform the copy stuff in a forked process

=cut

sub copy {
    my ($process, $args) = @_;
    my $session = $process->session;
    my $asset = WebGUI::Asset->newById($session, $args->{assetId});
    my $tree  = WebGUI::ProgressTree->new($session, [ $asset->getId ] );
    $process->update(sub { $tree->json });
    my $newAsset = $asset->duplicate({ state => "clipboard" });

    # If we aren't committing, add to a tag
    if ( !$args->{commit} ) {
        $newAsset->update({
            status      => "pending",
            tagId       => WebGUI::VersionTag->getWorking( $session )->getId,
        });
    }
    $newAsset->update({ title => $newAsset->getTitle . ' (copy)'});

    $tree->success($asset->getId);
    $process->update(sub { $tree->json });
}

1;
