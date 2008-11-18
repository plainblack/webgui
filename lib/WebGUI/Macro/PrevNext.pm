package WebGUI::Macro::PrevNext;

use strict;

=head1 NAME

Package WebGUI::Macro::PrevNext

=head1 DESCRIPTION

Provide a JS based previous and next button for each page, doing a depth-first
search one level deep.

=head2 process( $session, $topPage )

The main macro class, Macro.pm, will call this subroutine and pass it options.

=over 4

=item $session

A session variable

=item $topPage

The assetId of the top page.  The Macro will not look above this page.

=back

=cut


#-------------------------------------------------------------------
sub process {
	my ($session, $topPageId) = @_;
    my $topPage;
    if ($topPageId) {
        $topPage = WebGUI::Asset->newByDynamicClass($session, $topPageId);
    }
    if (! defined $topPage) {
        $topPage = WebGUI::Asset->getDefault($session);
    }
	my $output = ""; # do some stuff
	return $output;
}

sub getNext {
    my ($startingAsset, $topPage) = @_;
    my $session = $startingAsset->session;
    my $childrenIterator = $startingAsset->getLineageIterator(
        ['children'],
        {
            includeOnlyClasses => ['WebGUI::Asset::Wobject::Layout'],
            returnObjects      => 1,
        }
    );
    my $firstChild = $childrenIterator->();
    if (defined $firstChild) {
        return $firstChild;
    }
    ##No children, try the first sibling after me
    my $firstAsset = $startingAsset;
    while ($firstAsset->getId ne $topPage->getId) {
        my $siblingLineage = $firstAsset->getParent->get('lineage').$firstAsset->formatRank($firstAsset->getRank()+1);
        my $firstSib = WebGUI::Asset->newByLineage($session, $siblingLineage);
        if (defined $firstSib) {
            return $firstSib;
        }
        $firstAsset = $firstAsset->getParent;
    }
    ##No valid siblings after me, try my parent's siblings.
    return undef;
}

1;

#vim:ft=perl
