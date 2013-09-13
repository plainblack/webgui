package WebGUI::AssetHelper::Cut;

use strict;
use base qw/WebGUI::AssetHelper/;
use Scalar::Util qw( blessed );
use Monkey::Patch;
use JSON;
use Data::Dumper;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2012 Plain Black Corporation.
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

=head2 process ()

Cuts the asset to the clipboard.  If the user cannot edit the asset, or the asset is a
system asset, it returns an error message.

=cut

sub process {
    my ($self) = @_;
    my $asset   = $self->asset;
    my $session = $self->session;

    my $i18n = WebGUI::International->new($session, 'WebGUI');
    if (! $asset->canEdit) {
        return { error => $i18n->get('38'), };
    }
    elsif ( $asset->get('isSystem') ) {
        return { error => $i18n->get('41'), };
    }

    # Fork the cut. Forking makes sure it won't get interrupted
    my $fork    = WebGUI::Fork->start(
        $session, blessed( $self ), 'cut', { assetId => $asset->getId },
    );

    return {
        forkId      => $fork->getId,
    };
}

#----------------------------------------------------------------------------

=head2 cut ( process, args )

Handle the actual cutting in the forked process.
After this routine returns, C<Forks> marks this task as finished.

=cut

sub cut {
    my ( $process, $args ) = @_;
    my $asset = WebGUI::Asset->newById( $process->session, $args->{assetId} );

    # All the Assets we need to work on
    my $assetIds = $asset->getLineage( ['self','descendants'] );

    # Build a tree and update process status
    my $tree = WebGUI::ProgressTree->new( $process->session, $assetIds );

    # flat() return s a hash of all nodes to be done
    my $maxValue = keys %{ $tree->flat };

    my $update_progress = sub {
        # update the Fork's progress with how many are done
        my $flat = $tree->flat;
        my @done = grep { $_->{success} or $_->{failure} } values %$flat;
        my $current_value = scalar @done;
        my $info = {
            maxValue     => $maxValue,
            value        => $current_value,
            message      => 'Working...',
            reload       => 1,                # this won't take effect until Fork.pm returns finished => 1 and this status is propogated to WebGUI.Admin.prototype.openForkDialog's callback
            @_,
        };
        $info->{refresh} = 1 if $maxValue == $current_value;
        # $info->{debug_flat_keys} = join ',', keys %$flat;
        # $info->{debug_tree} = Dumper( $tree->tree );
        my $json = JSON::encode_json( $info );
        $process->update( $json );
    };

    $update_progress->( debug_initial => 1 );

    # Monkeypatch a sub to get a status update
    my $patch = Monkey::Patch::patch_class(
        'WebGUI::Asset', 'updateHistory', sub {
            my ( $orig, $self, @args ) = @_;

            $tree->success( $self->assetId );  # this should add it to the @done set / $current_value count as computed above

            $update_progress->();

            $self->$orig( @args );
        }
    );

    # Do the actual work
    $asset->cut;
}

1;
