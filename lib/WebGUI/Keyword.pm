package WebGUI::Keyword;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2008 Plain Black Corporation.
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

The maximum number of keywords to display in the cloud. Defaults to 50. Valid range between 1 and 50, inclusive.

=cut

sub generateCloud {
    my $self = shift;
    my $options = shift;
    my $display = $options->{displayAsset} || $options->{startAsset};
    my $sth = $self->session->db->read("select count(*) as keywordTotal, keyword from assetKeyword 
        left join asset using (assetId) where lineage like ? group by keyword order by keywordTotal desc limit 50", 
        [ $options->{startAsset}->get("lineage").'%' ]);
    my $cloud = HTML::TagCloud->new(levels=>$options->{cloudLevels} || 24);
    while (my ($count, $keyword) = $sth->array) {
        $cloud->add($keyword, $display->getUrl("func=".$options->{displayFunc}.";keyword=".$keyword), $count);
    }
    return $cloud->html_and_css($options->{maxKeywords});
}

#-------------------------------------------------------------------

=head2 getKeywordsForAsset ( { asset => $asset } )

Returns a string of keywords separated by spaces.

=head3 asset

An asset that you want to get the keywords for.

=head3 asArrayRef

A boolean, that if set to 1 will return the keywords as an array reference rather than a string.

=cut

sub getKeywordsForAsset {
    my ($self, $options) = @_;
    my @keywords = $self->session->db->buildArray("select keyword from assetKeyword where assetId=?",
        [$options->{asset}->getId]);
    if ($options->{asArrayRef}) {
        return \@keywords;
    }
    else {
        return join(" ", map({ m/\s/ ? '"' . $_ . '"' : $_ } @keywords));
    }
}


#-------------------------------------------------------------------

=head2 getMatchingAssets ( { startAsset => $asset, keyword => $keyword } )

Returns an array reference of asset ids matching the params.

=head3 startAsset

An asset object where you'd like to start searching for matching keywords. Doesn't search any particular branch if one isn't specified.

=head3 keyword

The keyword to match.

=head3 keywords

An array reference of keywords to match.

=head3 matchAssetKeywords

A reference to an asset that has a list of keywords to match. This can help locate assets that are similar to another asset.

=head3 isa

A classname pattern to match. For example, if you provide 'WebGUI::Asset::Sku' then everything that has a class name that starts with that including 'WebGUI::Asset::Sku::Product' will be included.

=head3 usePaginator

Instead of returning an array reference of assetId's, return a paginator object.

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

    # looking for a list of keywords
    if (exists $options->{keywords}) {
        my @placeholders = ();
        foreach my $word (@{$options->{keywords}}){
            push @placeholders, '?';
            push @params, $word;
        }
        next unless scalar @placeholders;
        push @clauses, 'keyword in ('.join(',', @placeholders).')';
    }

    # write the query
    my $query = 'select distinct assetKeyword.assetId from assetKeyword left join asset using (assetId)
        where '.join(' and ', @clauses).' order by creationDate desc';
        
    # perform the search
    if ($options->{usePaginator}) {
        my $p = WebGUI::Paginator->new($self->session);
        $p->setDataByQuery($query, undef, undef, \@params);
        return $p;
    }
    else {
        return $self->session->db->buildArrayRef($query, \@params);
    }
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
    my $keywords = [];
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
            $sth->execute([$assetId, lc($keyword)]);
        }
    }
}

#------------------------------------------------------------------------------

=head2 string2list ( string )

Returns an array reference of phrases.

=head3 string

A scalar containing space separated phrases.

=cut

sub string2list {
    my $text = shift;
    return if (ref $text);
    my @words = ();
    my $word = '';
    my $errorFlag = 0;
    while ( defined $text and length $text and not $errorFlag) {
        if ($text =~ s/\A(?: ([^\"\s\\]+) | \\(.) )//mx) {
            $word .= $1;
        } 
        elsif ($text =~ s/\A"((?:[^\"\\]|\\.)*)"//mx) {
            $word .= $1;
        } 
        elsif ($text =~ s/\A\s+//m){
            push(@words, $word);
            $word = '';
        } 
        elsif ($text =~ s/\A"//) {
            $errorFlag = 1;
        } 
        else {
            $errorFlag = 1;
        }
    }
    push(@words, $word);
    return \@words;
}


1;

