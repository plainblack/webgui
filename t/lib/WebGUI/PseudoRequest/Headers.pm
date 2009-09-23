package WebGUI::PseudoRequest::Headers;

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

=head1 NAME

Package WebGUI::PseudoRequest::Headers

=head2 new

Construct a new PseudoRequest::Headers object.  This is just for holding headers.
It doesn't do any magic.

=cut

sub new {
	my $this = shift;
	my $class = ref($this) || $this;
	my $self = { headers => {} };
	bless $self, $class;
	return $self;
}

#----------------------------------------------------------------------------

=head2 set( $key, $value )

Set a key, value pair in the header object.

=cut

sub set {
	my $self = shift;
	my $key = shift;
	my $value = shift;
	$self->{headers}->{$key} = $value;
}

#----------------------------------------------------------------------------

=head2 fetch

Returns the entire internal hashref of headers.

=cut

sub fetch {
	my $self = shift;
	return $self->{headers};
}

1;

