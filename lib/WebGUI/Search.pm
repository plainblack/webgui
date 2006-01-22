package WebGUI::Search;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2006 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use warnings;
use WebGUI::Asset;
use WebGUI::SQL;

=head1 NAME

Package WebGUI::Search

=head1 DESCRIPTION

A package for creating queries with the WebGUI Search Engine.

=head1 SYNOPSIS

 use WebGUI::Search;

=head1 METHODS

These methods are available from this package:

=cut


#-------------------------------------------------------------------

=head2 getAssetIds ( )

Returns an array reference containing all the asset ids of the assets that matched.

=cut

sub getAssetIds {
	my $self = shift;
	my $query = "select assetId from assetIndex where ";
	$query .= "isPublic=1 and " if ($self->{_isPublic});
	$query .= "(".$self->{_query}.")";
	my $rs = $self->session->db->prepare($query);
	$rs->execute($self->{_params});
	my @ids = ();
	while (my ($id) = $rs->array) {
		push(@ids, $id);		
	}
	return \@ids;
}


#-------------------------------------------------------------------

=head2 getAsses ( )

Returns an array reference containing asset objects for those that matched.

=cut

sub getAssets {
	my $self = shift;
	my $query = "select assetId,className,revisionDate from assetIndex where ";
	$query .= "isPublic=1 and " if ($self->{_isPublic});
	$query .= "(".$self->{_query}.")";
	my $rs = $self->session->db->prepare($query);
	$rs->execute($self->{_params});
	my @assets;
	while (my ($id, $class, $version) = $rs->array) {
		push(@assets, WebGUI::Asset->new($id, $class, $version));		
	}
	return \@assets;
}


#-------------------------------------------------------------------

=head2 getResultSet ( ) 

Returns a WebGUI::SQL::ResultSet object containing the search results with columns labeled "assetId", "title", "url", "synopsis", "ownerUserId", "groupIdView", "groupIdEdit", "creationDate", "revisionDate", and "className".

=cut

sub getResultSet {
	my $self = shift;
	my $query = "select assetId, title, url, synopsis, ownerUserId, groupIdView, groupIdEdit, creationDate, revisionDate,  className from assetIndex where ";
	$query .= "isPublic=1 and " if ($self->{_isPublic});
	$query .= "(".$self->{_query}.")";
	my $rs = $self->session->db->prepare($query);
	$rs->execute($self->{_params});
	return $rs;
}



#-------------------------------------------------------------------

=head2 new ( session  [ , isPublic ] )

Constructor.

=head3 session

A reference to the current session.

=head3 isPublic

A boolean indicating whether this search should search all internal data (0), or just public data (1). Defaults to just public data (1).

=cut

sub new {
	my $class = shift;
	my $session = shift;
	my $isPublic = (shift eq "0") ? 0 : 1;
	bless {_session=>$session, _isPublic=>$isPublic}, $class;
}



#-------------------------------------------------------------------

=head2 rawClause ( sql [, placeholders ] ) 

Tells the search engine to use a custom sql where clause that you've designed for the assetIndex table instead of using the API to build it.

=head3 sql

The where clause to execute. It should not actually contain the "where" term itself. 

=head3 placeholders

A list of placeholder parameters to go along with the query. See WebGUI::SQL::ResultSet::execute() for details.

=cut

sub rawClause {
	my $self = shift;
	$self->{_query} = shift;
	$self->{_params} = shift;
}

#-------------------------------------------------------------------

=head2 search ( match, keywords ) 

A simple keyword search.

=head3 match

Should we match "any" or "all" of the keywords.

=head3 keywords

An array of the key words or phrases to match against.

=cut

sub search {
	my $self = shift;
	my $match = shift;
	my @keywords = @_;
	my $operator = ($match eq "any") ? " or " : " and ";
	my @phrases = ();
	foreach (1..scalar(@keywords)) {
		 push(@phrases, "match (keywords) against (?)");
	}
	$self->{_query} = join($operator, @phrases);
	$self->{_params} = \@keywords;
}


#-------------------------------------------------------------------

=head2 searchLimitLineage ( lineage, match, keywords ) 

A simple keyword search limiting the search to a particular lineage.

=head3 lineage

The lineage to limit the search to.

=head3 match

Should we match "any" or "all" of the keywords.

=head3 keywords

An array of the key words or phrases to match against.

=cut

sub searchLimitLineage {
	my $self = shift;
	my $lineage = shift;
	$self->search(@_);
	$self->{_query} = "lineage like ? and (".$self->{_query}.")";
	my @params = @{$self->{_params}};
	unshift(@params, $lineage.'%');
	$self->{_params} = \@params;
}

#-------------------------------------------------------------------

=head2 session ( ) 

=cut

sub session {
	my $self = shift;
	return $self->{_session};
}



1;

