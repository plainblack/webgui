package WebGUI::Persistent::Query::Delete;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2004 Plain Black Corporation.
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
use WebGUI::Persistent::Query;

our @ISA = qw(WebGUI::Persistent::Query);

=head1 NAME

Package WebGUI::Persistent::Query::Delete

=head1 DESCRIPTION

This class allows reliable dynamic building of Sql delete queries.

=head1 SYNOPSIS

 my $query = WebGUI::Persistent::Query::Delete->new(
   table => 'myTable',
   where => [A => [1,2],[{C => 'hello',B => 1}]]
 );

 $query->buildQuery();

Returns:

  DELETE FROM myTable 
  WHERE A IN (1,2) AND (C = 'hello' OR B = 1)

=cut

#-------------------------------------------------------------------

=head2 buildQuery

=cut

sub buildQuery {
     my ($self,%p) = @_;
  
     my $query = 'DELETE FROM '.$self->{_table};
     if (my $where = $self->buildWhere()) {
          $query .= " $where";
     }
  
     return $query;
}

=head2 new( %p )

=head3 properties

A hashref of field name to a hash reference of property settings. 

Currently used settings are:

=head3 * quote

If true values for this field are automatically quoted.

=head3 table

The name of the table to query.

=head3 where

A hash reference or array reference of arguments to build a where clause from.
See parseWhereArgs for details.

=cut

1;
