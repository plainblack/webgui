package WebGUI::ProgressTree;

use warnings;
use strict;

=head1 NAME

WebGUI::ProgressTree

=head1 DESCRIPTION

Helper functions for maintaining a JSON represtentation of the progress of an
operation that modifies a tree of assets. See WebGUI::Fork::ProgressTree for a
status page that renders this.

=head1 SYNOPSIS

    my $tree = WebGUI::ProgressTree->new($session, \@assetIds);
    $tree->success($assetId);
    $tree->failure($assetId, $reason);
    $tree->note($assetId, 'something about this one...');

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

=head1 METHODS

=cut

#-------------------------------------------------------------------

=head2 new ($session, $assetIds)

Constructs new tree object for tracking the progress of $assetIds.

=cut

sub new {
    my ( $class, $session, $assetIds ) = @_;
    my ( %flat, @roots );
    if (@$assetIds) {
        my $db  = $session->db;
        my $dbh = $db->dbh;
        my $set = join( ',', map { $dbh->quote($_) } @$assetIds );
        my $sql = qq{
            SELECT   a.assetId, a.parentId, d.url
            FROM     asset a INNER JOIN assetData d ON a.assetId = d.assetId
            WHERE    a.assetId IN ($set)
            ORDER BY a.lineage ASC, d.revisionDate DESC
        };
        my $sth = $db->read($sql);

        while ( my $asset = $sth->hashRef ) {
            my ( $id, $parentId ) = delete @{$asset}{ 'assetId', 'parentId' };

            # We'll get back multiple rows for each asset, but the first one
            # is the latest.  Skip the others.
            next if $flat{$id};
            $flat{$id} = $asset;
            if ( my $parent = $flat{$parentId} ) {
                push( @{ $parent->{children} }, $asset );
            }
            else {
                push( @roots, $asset );
            }
        }
    }
    my $self = {
        session => $session,
        tree    => \@roots,
        flat    => \%flat,
    };
    bless $self, $class;
} ## end sub new

#-------------------------------------------------------------------

=head2 success ($assetId)

Whatever we were doing to $assetId succeeded.  Woohoo!

=cut

sub success {
    my ( $self, $assetId ) = @_;
    $self->{flat}->{$assetId}->{success} = 1;
}

#-------------------------------------------------------------------

=head2 failure ($assetId, $reason)

Whatever we were doing to $assetId didn't work for $reason.  Aww.

=cut

sub failure {
    my ( $self, $assetId, $reason ) = @_;
    $self->{flat}->{$assetId}->{failure} = $reason;
}

#-------------------------------------------------------------------

=head2 note ($assetId, $note)

Add some extra text.  WebGUI::Fork::ProgressTree displays these as paragraphs
under the node for this asset.

=cut

sub note {
    my ( $self, $assetId, $note ) = @_;
    push( @{ $self->{flat}->{$assetId}->{notes} }, $note );
}

#-------------------------------------------------------------------

=head2 focus ($assetId)

Make a note that this is the asset that we are currently doing something with.

=cut

sub focus {
    my ( $self, $assetId ) = @_;
    if ( my $last = delete $self->{last} ) {
        delete $last->{focus};
    }
    if ($assetId) {
        my $focus = $self->{last} = $self->{flat}->{$assetId};
        $focus->{focus} = 1;
    }
}

#-------------------------------------------------------------------

=head2 tree

A hashy representation of the status of this tree of assets.

=cut

sub tree { $_[0]->{tree} }

#-------------------------------------------------------------------

=head2 json

$self->tree encoded as json.

=cut

sub json { JSON::encode_json( $_[0]->tree ) }

#-------------------------------------------------------------------

=head2 session

The WebGUI::Session this progress tree is associated with.

=cut

sub session { $_[0]->{session} }

1;
