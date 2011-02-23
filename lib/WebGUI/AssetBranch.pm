package WebGUI::Asset;

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

=cut

use strict;

=head1 NAME

Package WebGUI::Asset (AssetBranch)

=head1 DESCRIPTION

This is a mixin package for WebGUI::Asset that contains all branch manipulation related functions.

=head1 SYNOPSIS

 use WebGUI::Asset;

=head1 METHODS

These methods are available from this class:

=cut



#-------------------------------------------------------------------

=head2 duplicateBranch ( [ $childrenOnly ] )

Duplicates this asset and the entire subtree below it.  Returns the root of the new subtree.

=head3 $childrenOnly

If true, then only children, and not descendants, will be duplicated.

=head3 $state

Set this to "clipboard" if you want the resulting asset to be on the clipboard
(rather than published) when we're done.

=cut

sub duplicateBranch {
    my ($self, $childrenOnly, $state) = @_;
    my $session   = $self->session;
    my $log       = $session->log;
    my $clipboard = $state && $state =~ /^clipboard/;

    my $newAsset = $self->duplicate(
        {   skipAutoCommitWorkflows => 1,
            skipNotification        => 1,
            state                   => $state,
        }
    );

    # Correctly handle positions for Layout assets
    my $contentPositions = $self->get("contentPositions");
    my $assetsToHide     = $self->get("assetsToHide");

    my $childIter = $self->getLineageIterator(["children"]);
    while ( 1 ) {
        my $child;
        eval { $child = $childIter->() };
        if ( my $x = WebGUI::Error->caught('WebGUI::Error::ObjectNotFound') ) {
            $self->session->log->error($x->full_message);
            next;
        }
        last unless $child;
        my $newChild;
        if ($childrenOnly) {
            $newChild = $child->duplicate(
                {   skipAutoCommitWorkflows => 1,
                    skipNotification        => 1,
                    state                   => $clipboard && 'clipboard-limbo',
                }
            );
        }
        elsif($clipboard) {
            $newChild = $child->duplicateBranch(0, 'clipboard-limbo');
        }
        else {
            $newChild = $child->duplicateBranch;
        }
        $newChild->setParent($newAsset);
        my ($oldChildId, $newChildId) = ($child->getId, $newChild->getId);
        $contentPositions =~ s/\Q${oldChildId}\E/${newChildId}/g if ($contentPositions);
        $assetsToHide     =~ s/\Q${oldChildId}\E/${newChildId}/g if ($assetsToHide);
    }

    $newAsset->update({contentPositions=>$contentPositions}) if $contentPositions;
    $newAsset->update({assetsToHide=>$assetsToHide})         if $assetsToHide;
    return $newAsset;
}

1;
