package WebGUI::AssetHelper::CopyBranch;

use strict;
use base qw/WebGUI::AssetHelper/;
use Scalar::Util qw{ blessed };
use WebGUI::VersionTag;

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

Package WebGUI::AssetHelper::CopyBranch

=head1 DESCRIPTION

Copy an Asset to the Clipboard, with children or descendants

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 process ()

Open a progress dialog for the copy operation

=cut

sub process {
    my ($self) = @_;

    return {
        openDialog => $self->getUrl( 'getWith' ),
    };
}

#----------------------------------------------------------------------------

=head2 www_getWith ()

Get the "with" configuration. "Descendants" or "Children".

=cut

sub www_getWith {
    my ( $self ) = @_;
    my $asset   = $self->asset;
    my $session = $self->session;
    my $i18n    = WebGUI::International->new($session, 'Asset');

    my $f   = $self->getForm( 'copy' );
    $f->addField( 'submit', name => 'with', value => 'Children' );
    $f->addField( 'submit', name => 'with', value => 'Descendants' );
    return $f->toHtml;
}


#----------------------------------------------------------------------------

=head2 www_copy ()

Perform the copy operation in a fork

=cut

sub www_copy {
    my ($self) = @_;
    my $asset   = $self->asset;
    my $session = $self->session;

    my $childrenOnly = 1 if lc $session->form->get('with') eq 'children';

    # Should we autocommit?
    my $commit = $session->setting->get('versionTagMode') eq 'autoCommit';

    # Fork the copy. Forking makes sure it won't get interrupted
    my $fork    = WebGUI::Fork->start(
        $session, blessed( $self ), 'copyBranch', { childrenOnly => $childrenOnly, assetId => $asset->getId, commit => $commit },
    );

    return {
        forkId      => $fork->getId,
    };
}

#-------------------------------------------------------------------

=head2 copyBranch ( $process, $args )

Perform the copy stuff in a forked process

=cut

sub copyBranch {
    my ($process, $args) = @_;
    my $session = $process->session;
    my $asset = WebGUI::Asset->newById($session, $args->{assetId});

    # Get the assets we need to duplicate
    my $assetIds = [];
    if ( $args->{childrenOnly} ) {
        $assetIds = $asset->getLineage(['children']);
    }
    else {
        $assetIds = $asset->getLineage(['descendants']);
    }

    my $tree  = WebGUI::ProgressTree->new($session, $assetIds );
    my $maxValue = keys %{ $tree->flat };
    $process->update(sub { $tree->json });
    my $update_progress = sub {
        # update the Fork's progress with how many are done
        my $flat = $tree->flat;
        my @done = grep { $_->{success} or $_->{failure} } values %$flat;
        my $current_value = scalar @done;
        my $info = {
            maxValue     => $maxValue,
            value        => $current_value,
            message      => 'Copying...',
            reload       => 1,                # this won't take effect until Fork.pm returns finished => 1 and this status is propogated to WebGUI.Admin.prototype.openForkDialog's callback
            @_,
        };
        $info->{refresh} = 1 if $maxValue == $current_value;
        my $json = JSON::encode_json( $info );
        $process->update( $json );
    };

    # Patch a sub to get a status update
    my $patch = Monkey::Patch::patch_class(
        'WebGUI::Asset',
        'duplicate',
        sub {
            my ( $duplicate, $self, @args ) = @_;
            my $id = $self->getId;
            $tree->focus($id);
            my $ret = $self->$duplicate(@args);
            $tree->success($id);
            $update_progress->();
            return $ret;
        }
    );

    my $newAsset = $asset->duplicateBranch( $args->{childrenOnly} ? 1 : 0, 'clipboard' );

    $newAsset->update({ title => $newAsset->getTitle . ' (copy)'});

    $tree->success($asset->getId);
    $update_progress->();

    my $tag = WebGUI::VersionTag->getWorking($session);
    if ($tag->canAutoCommit) {
        $tag->commit;
    }

}

1;
