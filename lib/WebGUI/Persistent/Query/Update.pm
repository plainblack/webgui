package WebGUI::Persistent::Query::Update;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2004 Plain Black LLC.
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

Package WebGUI::Persistent::Query::Update

=head1 DESCRIPTION

This class allows reliable dynamic building of Sql update queries.

=head1 SYNOPSIS

 my $query = WebGUI::Persistent::Query::Update->new(
   table => 'myTable',
   where => [A => [1,2],[{C => 'hello',B => 1}]],
   data => {
     A => 1,
     B => 2,
     C => 'hello',
     D => 'world'
   },
   properties => {
     A => { },
     B => { },
     C => { quote => 1 },
     D => { quote => 1 },
   }
 );

 $query->buildQuery();

Returns:

  UPDATE myTable SET A = 1, B = 2, C = 'hello' C = 'world'
  WHERE A IN (1,2) AND (C = 'hello' OR B = 1)

=cut

=head2 buildQuery

=cut

sub buildQuery {
     my ($self) = @_;

     my @clauses = ('UPDATE',$self->{_table},$self->buildSet());
     if (my $where = $self->buildWhere()) {
          push @clauses,$where;
     }

     return join(' ',@clauses);
}

sub buildSet {
     my ($self) = @_;
     'SET '.join(', ',map {
          "$_ = ". $self->quote($_,$self->{_data}{$_})
     } keys %{$self->{_data}});
}

=head2 new( %p )

=over

=item data

A hash reference of field name to value.

=item properties

=over

=item * quote

If true values for this field are automatically quoted.

=back

=item table

=item where

A hash reference or array reference of arguments to build a where clause from.
See WebGUI::Persistent::Query::parseWhereArgs for details.

=back

=cut

sub new {
     my ($class,%p) = @_;
     my $self = $class->SUPER::new(%p);
     $self->{_data} = $p{data} || {};
     return $self;
}

1;
