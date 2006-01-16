package WebGUI::Session::Stow;

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

=head1 NAME

Package WebGUI::Session::Stow

=head1 DESCRIPTION

This package allows you to "stow" a scalar or a reference to any other perl structure for the duration of the request. It's sort of like a mini in memory cache that only exists unless $session->close is called.

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

=head DESTROY ( )

Deconstructor.

=cut

sub DESTROY {
        my $self = shift;
        undef $self;
}


#-------------------------------------------------------------------

=head2 get( varName ) 

Retrieves the current value of a stow variable.

=head3 varName

The name of the variable.

=cut

sub get {
	my $self = shift;
	my $var = shift;
	return undef if $self->session->config->get("disableCache");
	return $self->{_data}{$var};
}


#-------------------------------------------------------------------

=head2 new ( session )

Constructor. Returns a stow object.

=head3 session

A reference to the session.

=cut

sub new {
	my $class = shift;
	my $session = shift; use WebGUI; WebGUI::dumpSession($session);
	bless {_session=>$session}, $class;
}


#-------------------------------------------------------------------

=head2 session ( )

Returns a reference to the current session.

=cut

sub session {
	my $self = shift;
	return $self->{_session};
}

#-------------------------------------------------------------------

=head2 set ( name, value )

Stows some data.

=head3 name

The name of the stow variable.

=head3 value

The value of the  stow variable.  Any scalar or reference.

=cut

sub set {
	my $self = shift;
	my $name = shift;
	my $value = shift;
	return undef unless ($name);
	$self->{_data}{$name} = $value;
}


1;
