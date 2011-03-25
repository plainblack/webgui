package WebGUI::AssetHelper::Delete;

use strict;
use Class::C3;
use base qw/WebGUI::AssetHelper/;
use Scalar::Util qw( blessed );

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Deleteright 2001-2009 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=head1 NAME

Package WebGUI::AssetHelper::Delete

=head1 DESCRIPTION

Delete an Asset, and all descendants

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 process ()

Fork the Delete operation

=cut

sub process {
    my ($self) = @_;
    my $asset = $self->asset;
    my $session = $self->session;

    my $i18n = WebGUI::International->new($session, 'WebGUI');
    if (! $asset->canEdit) {
        return { error => $i18n->get('38'), };
    }
    elsif ( $asset->get('isSystem') ) {
        return { error => $i18n->get('41'), };
    }

    # Fork the Delete. Forking makes sure it won't get interrupted
    my $fork    = WebGUI::Fork->start(
        $session, blessed( $self ), 'delete', { assetId => $asset->getId, },
    );

    return {
        forkId      => $fork->getId,
    };
}

#-------------------------------------------------------------------

=head2 delete ( $process, $args )

Perform the delete stuff in a forked process

=cut

sub delete {
    my ($process, $args) = @_;
    my $session = $process->session;
    my $asset = WebGUI::Asset->newById($session, $args->{assetId});

    # Prepare a tree with all the ids
    my $ids =
        $asset->getLineage(
            [ 'self', 'descendants' ], {
                statesToInclude => [qw(published clipboard clipboard-limbo trash trash-limbo)],
                statusToInclude => [qw(approved archived pending)],
            }
        );
    my $tree = WebGUI::ProgressTree->new( $session, $ids );
    $process->update(sub { $tree->json });

    # Patch a sub to get a status update
    my $patch = Monkey::Patch::patch_class(
        'WebGUI::Asset',
        'setState',
        sub {
            my ( $setState, $self, $state ) = @_;
            my $id = $self->getId;
            $tree->focus($id);
            my $ret = $self->$setState($state);
            $tree->success($id);
            $process->update(sub { $tree->json });
            return $ret;
        }
    );

    # Do the dirty deed, cheap
    $asset->trash;
}

1;
