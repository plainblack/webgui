package WebGUI::Macro::PrevNext;

use strict;

=head1 NAME

Package WebGUI::Macro::PrevNext

=head1 DESCRIPTION

Provides YUI-powered previous/next buttons for inline page navigation, doing a depth-first
search one level deep. Handy if you want people to be able to click "next, next, next" to 
navigate through your content. You probably want to use this in your Page Layout template.
Generates attractive YUI button markup which gracefully degrades to a standard link tag when 
javascript is disabled.

=head2 process( $session, $topPage, $depth, $templateId )

The main macro class, Macro.pm, will call this subroutine and pass it options.

=over 4

=item $session

A session variable

=item $topPage

The assetId of the top page.  The Macro will not look above this page.

=item $depth

From the $topPage, how many levels of hierarchy down to "block".  For example, if
there is a page structure that looks like:
    
    topPage
        page1
            subPage1_1
            subPage2_1
        page2
            subPage1_2
            subPage2_2

and $depth is 0, then navigation links would show up on page1 and its subpages, and page2
and its subpages.  The links would allow you to start at page1 and go from page to page, down
into its subpages, up to page2, then down into its subpages.

If $depth is 1, then page1 would only have a next link, down into its subpages.  Its last
subpage, subPage2_1, would only have a previous link.

=item $templateId

The assetId of a template to use to make the macro's output.

=back

=cut


#-------------------------------------------------------------------
sub process {
	my ($session, $topPageUrl, $depth, $templateId) = @_;
    $templateId = defined $templateId ? $templateId : 'PrevNextMacro_YUILink0';

    ##Determine the top page
    my $topPage;
    if ($topPageUrl) {
        $topPage = WebGUI::Asset->newByUrl($session, $topPageUrl);
    }
    if (! defined $topPage) {
        $topPage = WebGUI::Asset->getDefault($session);
    }

    ##Use the depth to alter the top page
    my $thisPage = $session->asset;
    my $startingPage = getStartPage($topPage, $thisPage, $depth);

    my $nextPage = getNext(    $thisPage, $startingPage);
    my $prevPage = getPrevious($thisPage, $startingPage);
    my $vars;
    $vars->{startingPageTitle} = $startingPage->getTitle;
    if (defined $nextPage) {
        $vars->{hasNext} = 1;
        $vars->{nextUrl} = $nextPage->getUrl;
        $vars->{nextMenuTitle} = $nextPage->getMenuTitle;
        $vars->{nextTitle} = $nextPage->getTitle;
    }
    else {
        $vars->{hasNext} = 0;
    }
    if (defined $prevPage) {
        $vars->{hasPrevious} = 1;
        $vars->{previousUrl} = $prevPage->getUrl;
        $vars->{previousMenuTitle} = $prevPage->getMenuTitle;
        $vars->{previousTitle} = $prevPage->getTitle;
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
    ##Special case for page above starting page
    if ($startingAsset->get('lineage') lt $topPage->get('lineage') ) {
        return undef;
    }
    my $session = $startingAsset->session;
    my $childrenIterator = $topPage->getLineageIterator(
        ['descendants'],
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
        ['self', 'descendants'],
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
    return $firstChild;
}

=head2 getStartPage ($topPage, $thisPage, $depth)

Find the previous asset using a 1-level, depth first approach.  This means
it prefers children over siblings.  If no previous asset exists, it
returns undef.  If it does exist, it returns an WebGUI::Asset object of
the appropriate type.

=head3 $topPage

The asset requested to be the top asset by the user.

=head3 $thisPage

The current page, from the session variable.

=head3 $depth

The number of levels, from the topPage, to ignore.

=cut

sub getStartPage {
    my ($topPage, $thisPage, $depth) = @_;
    if ($depth == 0) {
        return $topPage;
    }
    my $topLineage  = $topPage->get('lineage');
    my $thisLineage = $thisPage->get('lineage');
    my $topLineageLength = length($topLineage);
    my $startPageLineage = $topLineage . substr($thisLineage, $topLineageLength, 6 * $depth);
    my $startPage = WebGUI::Asset->newByLineage($topPage->session, $startPageLineage);
    if (!defined $startPage) {
        $startPage = $topPage;
    }
    return $startPage;
}

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2008 SDH Consulting Group. All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. See L<perlartistic>.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=head1 AUTHORS

Colin Kuskie, perlDreamer Consulting, LLC
Patrick Donelan, SDH Consulting Group

=cut

1;

#vim:ft=perl
