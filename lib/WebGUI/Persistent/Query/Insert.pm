package WebGUI::Persistent::Query::Insert;

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
use WebGUI::Persistent::Query::Insert;

our @ISA = qw(WebGUI::Persistent::Query);

=head1 NAME

Package WebGUI::Persistent::Query::Insert

=head1 DESCRIPTION

This class allows reliable dynamic building of Sql insert queries.

=head1 SYNOPSIS

 my $query = WebGUI::Persistent::Query::Insert->new(
   table => 'myTable',
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

  INSERT INTO myTable (A,B,C,D) VALUES (1,2,'hello','world');

=cut

#-------------------------------------------------------------------

sub buildFieldValues {
     my ($self) = @_;

     my @fields = keys %{$self->{_data}};
     my @values = map { $self->quote($_,$self->{_data}{$_})} @fields;

     return "(".join(', ',@fields).") VALUES (".join(', ',@values).")";
}

#-------------------------------------------------------------------

=head2 buildQuery

=cut

sub buildQuery {
     my ($self) = @_;
     return join(' ','INSERT INTO',$self->{_table},$self->buildFieldValues());
}

#-------------------------------------------------------------------

=head2 new( %p )

=head3 data

A hash reference of field name to value.

=head3 properties

=head3 * quote

If true values for this field are automatically quoted.

=head3 table

The name of the table to query.

=cut

sub new {
     my ($class,%p) = @_;
     my $self = $class->SUPER::new(%p);
     $self->{_data} = $p{data} || {};
     return $self;
}

1;
