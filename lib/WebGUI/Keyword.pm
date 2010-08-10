package WebGUI::Keyword;

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
use Class::InsideOut qw(public register id);
use HTML::TagCloud;
use WebGUI::Paginator;

=head1 NAME

Package WebGUI::Keyword

=head1 DESCRIPTION

This package provides an API to create and modify keywords used by the asset sysetm.

Assets can use the C<keywords> property to set keywords automatically. See 
WebGUI::Asset::update() for more details.

=head1 SYNOPSIS

 use WebGUI::Keyword;

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 session ( ) 

Returns a reference to the current session.

=cut

public session => my %session;


#-------------------------------------------------------------------

=head2 deleteKeywordsForAsset ( $asset )

Removes all keywords from an asset.

=head3 asset

The asset to delete the keywords from.

=cut

sub deleteKeywordsForAsset {
    my $self = shift;
    my $asset = shift;
    $self->session->db->write("delete from assetKeyword where assetId=?", [$asset->getId]);
}

#-------------------------------------------------------------------

=head2 deleteKeyword ( { keyword => $keyword } )

Removes a particular keyword from the system entirely.

=head3 keyword

The keyword to remove.

=cut

sub deleteKeyword {
    my $self = shift;
    my $options = shift;
    $self->session->db->write("delete from assetKeyword where keyword=?", [$options->{keyword}]);
}

#-------------------------------------------------------------------

=head2 findKeywords ( $options )

Find keywords.

=head3 $options

A hashref of options to change the behavior of the method.

=head4 asset

Find all keywords for all assets below an asset, providing a WebGUI::Asset object.

=head4 assetId

Find all keywords for all assets below an asset, providing an assetId.

=head4 search

Find all keywords using the SQL clause LIKE.  This can be used in tandem with asset or assetId.

=head4 limit

Limit the number of keywords that are returned.

=cut

sub findKeywords {
    my $self = shift;
    my $options = shift;

    my $sql = 'SELECT keyword FROM assetKeyword';
    my @where;
    my @placeholders;
    my $parentAsset;
    if ($options->{asset}) {
        $parentAsset = $options->{asset};
    }
    if ($options->{assetId}) {
        $parentAsset = WebGUI::Asset->new($self->session, $options->{assetId});
    }
    if ($parentAsset) {
        $sql .= ' INNER JOIN asset USING (assetId)';
        push @where, 'lineage LIKE ?';
        push @placeholders, $parentAsset->get('lineage') . '%';
    }
    if ($options->{search}) {
        push @where, 'keyword LIKE ?';
        push @placeholders, '%' . $options->{search} . '%';
    }
    if (@where) {
        $sql .= ' WHERE ' . join(' AND ', @where);
    }
    $sql .= ' GROUP BY keyword';
    if ($options->{limit}) {
        $sql .= ' LIMIT ' . $options->{limit};
    }
    my $keywords = $self->session->db->buildArrayRef($sql, \@placeholders);
    return $keywords;
}

#-------------------------------------------------------------------

=head2 generateCloud ( { startAsset => $asset, displayFunc => "viewKeyword" } )

Generates a block of HTML that represents the prevelence of one keyword compared to another.

=head3 displayAsset

The asset that contains the function to display a list of assets related to a given keyword. If not specified the
startAsset will be used.

=head3 displayFunc

The www func that will be called on the displayAsset to display the list of assets associated to a given keyword.

=head3 cloudLevels

How many levels of keyword sizes should there be displayed in the cloud. Defaults to 24. Range between 2 and 24.

=head3 startAsset

The starting point in the asset tree to search for keywords, so you can show a cloud for just a subsection of the
site.

=head3 maxKeywords

The maximum number of keywords to display in the cloud. Defaults to 50. Valid range between 1 and 100, inclusive.

=head3 urlCallback

This is the name of a method that will be called on the displayAsset, or the startAsset to get the URL
that elements in the tag cloud will link to.  The method will be passed the keyword as its first, and only argument.

=head3 includeOnlyKeywords

This is an arrayref of keywords.  The generated cloud will only contain these keywords.

=cut

sub generateCloud {
    my $self = shift;
    my $options = shift;
    my $display = $options->{displayAsset} || $options->{startAsset};
    my $includeKeywords = $options->{includeOnlyKeywords};
    my $maxKeywords = $options->{maxKeywords} || 50;
    if ($maxKeywords > 100) {
        $maxKeywords = 100;
    }
    my $urlCallback = $options->{urlCallback};
    my $extraWhere = '';
    my @extraPlaceholders;
    if ($includeKeywords) {
        $extraWhere .= ' AND keyword IN (' . join(',', ('?') x @{$includeKeywords}) . ')';
        push @extraPlaceholders, @{$includeKeywords};
    }
    my $sth = $self->session->db->read("SELECT COUNT(*) as keywordTotal, keyword FROM assetKeyword
        LEFT JOIN asset USING (assetId) WHERE lineage LIKE ? $extraWhere
        GROUP BY keyword ORDER BY keywordTotal DESC LIMIT ?",
        [ $options->{startAsset}->get("lineage").'%', @extraPlaceholders, $maxKeywords ]);
    my $cloud = HTML::TagCloud->new(levels=>$options->{cloudLevels} || 24);
    while (my ($count, $keyword) = $sth->array) {
        my $url
            = $urlCallback ? $display->$urlCallback($keyword)
            : $options->{displayFunc} ? $display->getUrl("func=".$options->{displayFunc}.";keyword=".$keyword)
            : $display->getUrl("keyword=".$keyword)
            ;
        $cloud->add($keyword, $url, $count);
    }
    return $cloud->html_and_css($maxKeywords);
}

#-------------------------------------------------------------------

=head2 getKeywordsForAsset ( $options )

Looks up the keywords for an asset, identified by either an asset object
or an asset GUID in the options.  Returns a string of keywords separated
by spaces.  If the keyword has spaces in it, it will be quoted.

=head3 $options

A hash reference of options.

=head4 asset

An asset that you want to get the keywords for.

=head4 assetId

The GUID of an asset you want to get the keywords for.

=head4 asArrayRef

A boolean, that if set to 1 will return the keywords as an array reference rather than a string.

=cut

sub getKeywordsForAsset {
    my ($self, $options) = @_;
    my $assetId = $options->{asset} ? $options->{asset}->getId : $options->{assetId};
    my $keywords = $self->session->db->buildArrayRef("select keyword from assetKeyword where assetId=?",
        [$assetId]);
    if ($options->{asArrayRef}) {
        return $keywords;
    }
    else {
        return join(', ', @$keywords);
    }
}


#-------------------------------------------------------------------

=head2 getMatchingAssets ( $options )

Returns an array reference of asset ids matching the params.  Assets are returned in order of creationDate.
Only published assets are returned, unless the C<states> options is used.

=head3 $options

A hash reference of options.

=head4 startAsset

An asset object where you'd like to start searching for matching keywords. Doesn't search any particular branch if one isn't specified.

=head4 keyword

The keyword to match.

=head4 keywords

An array reference of keywords to match.

=head4 matchAssetKeywords

A reference to an asset that has a list of keywords to match. This can help locate assets that are similar to another asset.
If the referenced asset does not have any keywords, then an empty array reference is returned.

=head4 isa

A classname pattern to match. For example, if you provide 'WebGUI::Asset::Sku' then everything that has a class name that starts with that including 'WebGUI::Asset::Sku::Product' will be included.

=head4 usePaginator

Instead of returning an array reference of assetId's, return a paginator object.

=head4 rowsPerPage

If usePaginator is passed, then this variable will set the number of rows per page that the paginator uses.
If usePaginator is not passed, then this variable will limit the number of assetIds that are returned.

=head4 states

An array reference of asset states.  The ids of assets in those states will be returned.  If this option
is missing, only assets in the C<published> state will be returned.

=head4 sortOrder

Determines the order that assets are returned.  By default, it is in Chronological order, by creationDate.  If
you set sortOrder to Alphabetically, it will sort by title, and then lineage.

=cut

sub getMatchingAssets {
    my ($self, $options) = @_;

    # base query
    my @clauses = ();
    my @params = ();

    # what lineage are we looking for
    if (exists $options->{startAsset}) {
        push @clauses, 'lineage like ?';
        push @params, $options->{startAsset}->get("lineage").'%';
    }
    
    # matching keywords against another asset
    if (exists $options->{matchAssetKeywords}) {
        $options->{keywords} = $self->getKeywordsForAsset({
            asset       => $options->{matchAssetKeywords},
            asArrayRef  => 1,
            });
        return [] unless scalar @{ $options->{keywords} };
    }

    # looking for a class name match
    if (exists $options->{isa}) {
        push @clauses, 'className like ?';
        push @params, $options->{isa}.'%';
    }

    # looking for a single keyword
    if (exists $options->{keyword}) {
        push @clauses, 'keyword=?';
        push @params, $options->{keyword};
    }

    # looking for a single keyword
    my @states;
    if (exists $options->{states} && scalar(@{ $options->{states} } )) {
        @states = @{ $options->{states} };
    }
    else {
        @states = 'published';
    }
    {
        my @placeholders = ('?') x scalar @states;
        push @params, @states;
        push @clauses, 'state in ('.join(',', @placeholders).')';
    }

    # looking for a list of keywords
    if (exists $options->{keywords} && scalar(@{$options->{keywords}})) {
        my @placeholders = ();
        foreach my $word (@{$options->{keywords}}){
            push @placeholders, '?';
            push @params, $word;
        }
        push @clauses, 'keyword in ('.join(',', @placeholders).')';
    }

    my $sortOrder = $options->{sortOrder} || 'Chronologically';

    my $orderBy = $sortOrder eq 'Alphabetically' ? ' order by upper(title), lineage' : ' order by creationDate desc, lineage';

    # write the query
    my $query = q{
        select distinct assetKeyword.assetId 
        from   assetKeyword 
        left join asset using (assetId) 
        left join assetData using (assetId)
        where } . 
        join(' and ', @clauses) . $orderBy;

    # perform the search
    if ($options->{usePaginator}) {
        my $p = WebGUI::Paginator->new($self->session, undef, $options->{rowsPerPage});
        $p->setDataByQuery($query, undef, undef, \@params);
        return $p;
    }
    elsif ($options->{rowsPerPage}) {
        $query .= ' limit '. $options->{rowsPerPage};
    }
    return $self->session->db->buildArrayRef($query, \@params);
}

#-------------------------------------------------------------------

=head2 getTopKeywords ( $options )

Returns a hashref of the the top N keywords as well as the total number returned sorted in alphabetical order

=head3 $options

A hashref of options to change the behavior of the method.

=head4 asset

Find all keywords for all assets below an asset, providing a WebGUI::Asset object.

=head4 assetId

Find all keywords for all assets below an asset, providing an assetId.

=head4 search

Find all keywords using the SQL clause LIKE.  This can be used in tandem with asset or assetId.

=head4 limit

Limit the number of top keywords that are returned.

=cut

sub getTopKeywords {
    my $self    = shift;
    my $options = shift;
    my $sql     = q|
        SELECT
            keyword,occurrance
        FROM (
            SELECT
                keyword, count(keyword) as occurrance
            FROM
                assetKeyword
    |;
    my @where;
    my @placeholders;
    my $parentAsset;
    if ($options->{asset}) {
        $parentAsset = $options->{asset};
    }
    if ($options->{assetId}) {
        $parentAsset = WebGUI::Asset->new($self->session, $options->{assetId});
    }
    if ($parentAsset) {
        $sql .= ' INNER JOIN asset USING (assetId)';
        push @where, 'lineage LIKE ?';
        push @placeholders, $parentAsset->get('lineage') . '%';
    }
    if ($options->{search}) {
        push @where, 'keyword LIKE ?';
        push @placeholders, '%' . $options->{search} . '%';
    }
    if (@where) {
        $sql .= ' WHERE ' . join(' AND ', @where);
    }
    $sql .= ' GROUP BY keyword';
    $sql .= ' ORDER BY occurrance desc';
    if ($options->{limit}) {
        $sql .= ' LIMIT ' . $options->{limit};
    }
    $sql .= q|
        ) as keywords
        order by keyword
    |;
    my $keywords = $self->session->db->buildHashRef($sql, \@placeholders);
    return $keywords;
}


#-------------------------------------------------------------------

=head2 new ( $session )

Constructor.

=head3 session

A reference to the current session.

=cut

sub new {
    my $class = shift;
    my $session = shift;
    my $self = bless \do {my $s}, $class;
    register($self);
    $session{id $self} = $session;
    return $self;
}

#-------------------------------------------------------------------

=head2 replaceKeyword ( { currentKeyword => $keyword1, newKeyword => $keyword2 } ) 

Changes a keyword from one thing to another thing throughout the system.

=head3 currentKeyword

Whatever the keyword is now. Example: "apples"

=head3 newKeyword

Whatever you want it to be. Example; "apple"

=cut

sub replaceKeyword {
    my ($self, $options) = @_;
    $self->session->db->write("update assetKeyword set keyword=? where keyword=?", 
        [$options->{newKeyword}, $options->{currentKeyword}]);
}


#-------------------------------------------------------------------

=head2 setKeywordsForAsset ( { asset => $asset, keywords => $keywords } )

Sets the keywords for an asset. 

=head3 asset

An asset that you want to set the keywords for.

=head3 keywords

Either a string of space-separated keywords, or an array reference of keywords to assign to the asset.

=cut

sub setKeywordsForAsset {
    my $self = shift;
    my $options = shift;
    my $keywords;
    if (ref $options->{keywords} eq "ARRAY") {
        $keywords = $options->{keywords};
    }
    else {
        $keywords = string2list($options->{keywords});
    }

    $self->deleteKeywordsForAsset($options->{asset});
    my $assetId = $options->{asset}->getId;
    if (scalar(@{$keywords})) {
        my $sth = $self->session->db->prepare("insert into assetKeyword (assetId, keyword) values (?,?)");
        my %found_keywords;
        foreach my $keyword (@{$keywords}) {
            next if ($keyword eq "");
            next
                if $found_keywords{$keyword};
            $found_keywords{$keyword}++;
            $sth->execute([$assetId, $keyword]);
        }
    }
}

#------------------------------------------------------------------------------

=head2 string2list ( string )

Returns an array reference of phrases.

=head3 string

A scalar containing comma separated phrases.

=cut

sub string2list {
    my $text = shift;
    return if (ref $text);
    my @words = split /,/, $text;
    for my $word (@words) {
        $word =~ s/^\s+//;
        $word =~ s/\s+$//;
    }
    return \@words;
}


1;

