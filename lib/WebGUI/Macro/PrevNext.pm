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
	my ($session, $topPageUrl, $templateId) = @_;
    $templateId = defined $templateId ? $templateId : 'PrevNextMacro_YUILink0';
    my $topPage;
    if ($topPageUrl) {
        $topPage = WebGUI::Asset->newByUrl($session, $topPageUrl);
    }
    if (! defined $topPage) {
        $topPage = WebGUI::Asset->getDefault($session);
    }
    my $nextPage = getNext($session->asset, $topPage);
    my $prevPage = getPrevious($session->asset, $topPage);
    my $vars;
    if (defined $nextPage) {
        $vars->{hasNext} = 1;
        $vars->{nextUrl} = $nextPage->getUrl;
    }
    else {
        $vars->{hasNext} = 0;
    }
    if (defined $prevPage) {
        $vars->{hasPrevious} = 1;
        $vars->{previousUrl} = $prevPage->getUrl;
    }
    else {
        $vars->{hasPrevious} = 0;
    }
    my $template = WebGUI::Asset->newByDynamicClass($session, $templateId);
	return $template->process($vars);
}

=head2 getNext ($startingAsset, $topPage)

Find the next asset using a 1-level, depth first approach.  This means it
prefers children over siblings.  If no next asset exists, it returns undef.
If it does exist, it returns an WebGUI::Asset object of the appropriate type.

=head3 $startingAsset

The next asset will be the next logical asset after $startingAsset.

=head3 $topPage

When no valid next sibling is found, the subroutine will attempt to
see if the parent has valid siblings with children.  It uses $topPage
to make sure it doesn't recurse out of a particular area, such as
all the way back to the WebGUI root node.

=cut

sub getNext {
    my ($startingAsset, $topPage) = @_;
    my $session = $startingAsset->session;
    my $childrenIterator = $topPage->getLineageIterator(
        ['descendants', 'siblings'],
        {
            includeOnlyClasses => ['WebGUI::Asset::Wobject::Layout'],
            returnObjects      => 1,
            whereClause        => 'asset.lineage > '.$session->db->quote($startingAsset->get('lineage')),
        }
    );
    my $firstChild;
    CHILD: while ($firstChild = $childrenIterator->()) {
       last CHILD if $firstChild->canView(); 
    }
    ##Fall through condition for undef
    return $firstChild;
}

=head2 getPrevious

Find the previous asset using a 1-level, depth first approach.  This means
it prefers children over siblings.  If no previous asset exists, it
returns undef.  If it does exist, it returns an WebGUI::Asset object of
the appropriate type.

=head3 $startingAsset

The next asset will be the next logical asset before $startingAsset.

=head3 $topPage

When no valid previous sibling is found, the subroutine will attempt to
see if the parent has valid siblings with children.  It uses $topPage
to make sure it doesn't recurse out of a particular area, such as
all the way back to the WebGUI root node.

=cut

sub getPrevious {
    my ($startingAsset, $topPage) = @_;
    my $session = $startingAsset->session;

    ##This includes self, for a corner condition when you look for a the previous
    ##Asset on the very first asset.  If you do not include self, then it will find
    ##the first asset whose lineage is above the topPage.
    my $childrenIterator = $topPage->getLineageIterator(
        ['self', 'descendants', 'siblings'],
        {
            includeOnlyClasses => ['WebGUI::Asset::Wobject::Layout'],
            whereClause        => 'asset.lineage < '.$session->db->quote($startingAsset->get('lineage')),
            returnObjects      => 1,
            invertTree         => 1,
        }
    );
    my $firstChild;
    CHILD: while ($firstChild = $childrenIterator->()) {
       last CHILD if $firstChild->canView(); 
    }
    if ($firstChild->getId ne $topPage->getId) {
        return $firstChild;
    }
    else {
        return undef;
    }
}

1;

#vim:ft=perl
