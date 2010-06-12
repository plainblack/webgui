package WebGUI::Session::Stow;

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
use Scalar::Util qw(weaken);

=head1 NAME

Package WebGUI::Session::Stow

=head1 DESCRIPTION

This package allows you to "stow" a scalar or a reference to any other perl structure for the duration of the request. It's sort of like a mini in memory cache that only exists until $session->close is called. It is great to stow stuff that might otherwise have to be requested many times during a single page view, but that you would't want to store in the regular cache. Note that this is NOT supposed to be used as a global variable system. It's simply an in memory cache.

=head1 SYNOPSIS

$stow = WebGUI::Session::Stow->new($session);

$stow->delete('temp');
$stow->set('temp',$value);
$value = $stow->get('temp');

$stow->deleteAll;


=head1 METHODS

These methods are available from this package:

=cut



#-------------------------------------------------------------------

=head2 delete ( name )

Deletes a stow variable.

=head3 name

The name of the stow variable.

=cut

sub delete {
	my $self = shift;
	my $name = shift;
	return undef unless ($name);
	delete $self->{_data}{$name};
}


#-------------------------------------------------------------------

=head2 deleteAll ( )

Deletes all stow variables for this session.

=cut

sub deleteAll {
	my $self = shift;
	delete $self->{_data};
}


#-------------------------------------------------------------------

=head2 get( varName ) 

Retrieves the current value of a stow variable. By default, will try
to create a safe copy.

WARNING: Not all structures can be made completely safe. Objects will
not be cloned.

=head3 varName

The name of the variable.

=head3 options

A hashref of options with the following keys:

 noclone        - If true, will not create a safe copy. This can be much much
                    faster than creating a safe copy. Defaults to false.

=cut

sub get {
	my $self    = shift;
	my $var     = shift;
    my $opt     = shift || {};
    my $value   = $self->{_data}{$var};
    return undef unless defined $value;
    my $ref     = ref $value;
    return $value if ( !$ref || $opt->{noclone} );

    # Try to clone
    # NOTE: Clone and Storable::dclone do not currently work here, but
    # would be safer if they did
    if ($ref eq 'ARRAY') {
        my @safeArray = @{ $value };
        return \@safeArray;
    }
    elsif ($ref eq 'HASH') {
        my %safeHash = %{ $value };
        return \%safeHash;
    }
    
    # Can't figure out how to clone
    return $value;
}


#-------------------------------------------------------------------

=head2 new ( session )

Constructor. Returns a stow object.

=head3 session

A reference to the session.

=cut

sub new {
	my $class = shift;
	my $session = shift;
    my $self = bless { _session => $session }, $class;
    weaken $self->{_session};
    return $self;
}


#-------------------------------------------------------------------

=head2 session ( )

Returns a reference to the current session.

=cut

sub session {
    $_[0]->{_session};
}

#-------------------------------------------------------------------

=head2 set ( name, value )

Stows some data.

=head3 name

The name of the stow variable.

=head3 value

The value of the stow variable.  Any scalar or reference.

=cut

sub set {
	my $self = shift;
	my $name = shift;
	my $value = shift;
	return undef unless ($name);
	$self->{_data}{$name} = $value;
}


1;
