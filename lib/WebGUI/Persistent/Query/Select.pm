package WebGUI::Persistent::Query::Select;

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

=head1 NAME

Package WebGUI::Persistent::Query::Select

=head1 DESCRIPTION

This class allows reliable dynamic building of Sql select queries.

=head1 SYNOPSIS

 my $query = WebGUI::Persistent::Query::Select->new(
   where => [A => [1,2],[{C => 'hello',B => 1}]],
   table => 'myTable',
   limit => 1,
   groupBy => 'D',
   properties => {
     A => { },
     B => { },
     C => { quote => 1 },
     D => { quote => 1 },
   }
 );

 $query->buildQuery();

Returns:

  SELECT A,B,C,D 
  FROM myTable 
  WHERE A IN (1,2) AND (C = 'hello' OR B = 1) LIMIT 1 GROUP BY D

=cut

our @ISA = qw(WebGUI::Persistent::Query);

#-------------------------------------------------------------------

sub buildFrom { "FROM ".$_[0]->{_table} }

#-------------------------------------------------------------------

sub buildGroupBy { 
     my ($self) = @_;
     return '' unless $self->{_groupBy} && @{$self->{_groupBy}};
     return 'GROUP BY '.join(',',@{$self->{_groupBy}});
}

#-------------------------------------------------------------------

sub buildLimit { $_[0]->{_limit} ? "LIMIT ".$_[0]->{_limit} : '' }

#-------------------------------------------------------------------

sub buildOrderBy { 
     my ($self) = @_;
     return '' unless $self->{_orderBy} && @{$self->{_orderBy}};
     return 'ORDER BY '.join(',',@{$self->{_orderBy}});
}

#-------------------------------------------------------------------

=head2 buildQuery

=cut

sub buildQuery {
     my ($self) = @_;

     my @clauses = ('SELECT',
                    $self->buildSelectFields(),
                    $self->buildFrom());

     if (my $where = $self->buildWhere()) {
          push @clauses,$where;
     }
     if (my $group_by = $self->buildGroupBy()) {
          push @clauses,$group_by;
     }
     if (my $order_by = $self->buildOrderBy()) {
          push @clauses,$order_by;
     }
     if (my $limit = $self->buildLimit()) {
          push @clauses,$limit;
     }
     return join(' ',@clauses);
}

#-------------------------------------------------------------------

sub buildSelectFields {
     my ($self) = @_;
     return join(', ',@{$self->{_fields}}) if @{$self->{_fields}};
     return join(', ',keys %{$self->{_properties}}) if %{$self->{_properties}};
     return '*';
}

#-------------------------------------------------------------------

=head2 new( %p )

=over

=item fields

An array reference of field names (optional).

=item groupBy

An array reference of fields to group results by

=item limit

A scalar limit.

=item orderBy

An array reference of fields to order results by

=item properties

=over

=item * quote

If true values for this field are automatically quoted.

=back

=item table

The name of the table to query.

=item where

A hash reference or array reference of arguments to build a where clause from.
See WebGUI::Persistent::Query::parseWhereArgs for details.

=cut

sub new {
     my ($class,%p) = @_;
     my $self = $class->SUPER::new(%p);
     $self->{_fields} = $p{fields} || [];
     $self->{_limit} = $p{limit};
     $self->{_group_by} = $p{groupBy};
     $self->{_order_by} = $p{orderBy};
     return $self;
}

1;
