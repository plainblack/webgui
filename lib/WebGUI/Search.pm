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

Tells the search engine to use a custom sql where clause that you've designed for the assetIndex table instead of using the API to build it. It also returns a reference to the object so you can join a result method with it like this:

 my $assetIds = WebGUI::Search->new($session)->rawQuery($sql, $params)->getAssetIds;

=head3 sql

The where clause to execute. It should not actually contain the "where" term itself. 

=head3 placeholders

A list of placeholder parameters to go along with the query. See WebGUI::SQL::ResultSet::execute() for details.

=cut

sub rawClause {
	my $self = shift;
	$self->{_query} = shift;
	$self->{_params} = shift;
	return $self;
}

#-------------------------------------------------------------------

=head2 search ( rules ) 

A rules engine for WebGUI's search system. It also returns a reference to the search object so that you can join a result method with it like:

 my $assetIds = WebGUI::Search->new($session)->search(\%rules)->getAssetIds;

=head3 rules

A hash reference containing rules for a search. The rules will will be hash references containing the values of a rule. Here's an example rule set:

 {
   { 
     terms => [ "something to search for", "something else to search for"],
     match => "all"
   }, {
     terms => [ "000001000005", "000001000074000003" ]
   }
 }

=head4 keywords

This rule limits the search results to assets that match keyword criteria. This rule has two properties: "terms" and "match". Terms is an array reference that contains key words and key phrases to be searched for. Match is an operator that determins whether "all" the terms must match or if "any" of the terms can match. Match defaults to "any" if not specified.

=head4 lineage

This rule limits the search to a specific set of descendants in the asset tree. This has just one parameter, "terms", which is an array reference of asset lineages to match against.

=cut

sub search {
	my $self = shift;
	my $rules = shift;
	my @params = ();
	my $query = "";
	my @clauses = ();
	if ($rules->{keywords}) {
		push(@params,@{$rules->{keywords}{terms}});
		my $operator = ($rules->{keywords}{match} eq "all") ? " and " : " or ";
		my @phrases = ();
		foreach (1..scalar(@{$rules->{keywords}{terms}})) {
			 push(@phrases, "match (keywords) against (?)");
		}
		push(@clauses, join($operator, @phrases));
	}
	if ($rules->{lineage}) {
		my @phrases = ();
		foreach my $lineage (@{$rules->{lineage}{terms}}) {
			push(@params, $lineage."%");
			push(@phrases, "lineage like ?");
		}
		push(@clauses, join(" or ", @phrases));
	}
	$self->{_params} = \@params;
	$self->{_query} = "(".join(") and (", @clauses).")";
	return $self;
}


#-------------------------------------------------------------------

=head2 session ( ) 

=cut

sub session {
	my $self = shift;
	return $self->{_session};
}



1;

