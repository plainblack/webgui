package WebGUI::Persistent::Query;

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
use WebGUI::SQL ();
use WebGUI::ErrorHandler;

=head1 NAME

Package WebGUI::Persistent::Query

=head1 DESCRIPTION

An abstract base class for objects that build queries, providing funtionality
for building the where clause. See WebGUI::Persistent::Query::Select for more 
details.

=head1 SYNOPSIS

 use WebGUI::Persistent::Query;
 our @ISA = qw(WebGUI::Persistent::Query);

 sub buildQuery {
      # build the query...
      .
      .
      .
 }

=head1 METHODS

#-------------------------------------------------------------------

=head2 buildQuery

Build the query from the properties. This method must be overridden by
subclasses

=cut

sub buildQuery {
     WebGUI::ErrorHandler::fatalError("buildQuery() must be overridden");
}
;

#-------------------------------------------------------------------

=head2 buildWhere

Build the where clause for this query.

=cut

sub buildWhere {
     my ($self) = @_;
     my @clauses;

     if (my $where = $self->parseWhereArgs(@{$self->{_where}})) {
          return "WHERE $where";
     }

     return undef;
}

#-------------------------------------------------------------------

=head2 buildWhereElement( $name, @values )

Builds an element of a where clause.

=cut

sub buildWhereElement {
     my ($self,$name,@vals) = @_;
     @vals = @{$vals[0]} if ref($vals[0]);
     return undef unless @vals;
     return "$name = ".$self->quote($name,@vals) if (@vals == 1);
     return "$name IN (".join(',',map {$self->quote($name,$_)} @vals).")";
}

#-------------------------------------------------------------------

=head2 new( %p )

=over

=item properties

A hashref of field name to a hash reference of property settings. 

Currently used settings are:

=over

=item * quote

If true values for this field are automatically quoted.

=back

=item table

The name of the table to query.

=item where

A hash reference or array reference of arguments to build a where clause from.
See parseWhereArgs for details.

=back

=cut

sub new {
     my ($class,%p) = @_;
     $p{where} ||= [];
     $p{where} = [$p{where}] unless ref($p{where}) eq 'ARRAY';
     my $self = bless {
          _where      => $p{where},
          _properties => $p{properties},
          _table      => $p{table},
     }, $class;
     return $self;
}

#-------------------------------------------------------------------

sub _parsePart {
     my ($self,$part,$or,$no_bracket) = @_;

     return $part unless ref($part);
     if (ref($part) eq 'ARRAY') {
          my @parts;
          foreach my $sub_part (@$part) {
               $sub_part = $self->_parsePart($sub_part,!$or);
               push @parts,$sub_part if $sub_part;
          }
          if (@parts) {
               my $ret_val = join(($or ? ' OR ' : ' AND '),@parts);
               return ($no_bracket ? $ret_val : "($ret_val)");
          }
     } elsif (ref($part) eq 'HASH') {
          my @parts;
          foreach my $key (keys %$part) {
               my $clause = $self->buildWhereElement($key,$part->{$key});
               push @parts,$clause if $clause; 
          }
          return $self->_parsePart(\@parts,!$or,1);
     }
     return '';
}

#-------------------------------------------------------------------

=head2 parseWhereArgs( @argumentList)

Recursivley parses a list of where arguments joining them with "AND" or "OR". Arguments 
may take a number of forms:

=over

=item * scalar

("A = 1") is left unchanged.

=item * array reference

An array reference causes the joining argument to switch from 'AND' to 'OR' 
(or visa-versa) for its contents:

([ "A = 1","C = 2" ])

becomes:

"(A = 1 OR C = 2)"

=item * hash reference

These are a convienent way of being able to dynamically build up complex 
queries gradually.

({ A => 1 , C => 2 })

becomes:

"A = 1 AND C = 2"

=back

This routine is flexiable enough to be able to parse arguments of the form:

({A => [1,2]},[{B => 3,C => 4}],{D => 5})

becomes:

"A in (1,2) AND (B = 3 OR C = 4) AND D = 5"

=cut

sub parseWhereArgs {
     my ($self,@where_arg_list) = @_;
     my @where_parts;
     foreach my $where_part (@where_arg_list) {
          my $part = $self->_parsePart($where_part,1,0);
          push @where_parts,$part if $part;
     }
     return $self->_parsePart(\@where_parts,0,1);
}

#-------------------------------------------------------------------

=head2 quote( $propertyName, $propertyVaule )

Returns a quoted value for inclusion in a query, by refering to the properties
supplied to new().

=cut

sub quote {
     my ($self,$propertyName,$propertyValue) = @_;
  
     return 'NULL' unless defined($propertyValue);

     if ($self->{_properties}{$propertyName}{quote}) {
          return WebGUI::SQL::quote($propertyValue);
     }

     return $propertyValue;
}

1;
