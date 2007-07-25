package WebGUI::Session::Env;

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

Package WebGUI::Session::Env

=head1 DESCRIPTION

This package allows you to reference environment variables.

=head1 SYNOPSIS

$env = WebGUI::Session::Env->new;

$value = $env->get('REMOTE_ADDR');

=head1 METHODS

These methods are available from this package:

=cut


#-------------------------------------------------------------------

=head2 DESTROY ( )

Deconstructor.

=cut

sub DESTROY {
        my $self = shift;
        undef $self;
}


#-------------------------------------------------------------------

=head2 get( varName ) 

Retrieves the current value of an environment variable.

=head3 varName

The name of the variable.

=cut

sub get {
	my $self = shift;
	my $var = shift;
	return $self->{_env}{$var};
}


#-------------------------------------------------------------------

=head2 getIp ( )

Returns the user's real IP address. Normally this is REMOTE_ADDR, but if they go through a proxy server it might be in HTTP_X_FORWARDED_FOR. This method attempts to figure out what the most likely IP is for the user. Note that it's possible to spoof this and therefore shouldn't be used as your only security mechanism for validating a user.

=cut

sub getIp {
	my $self = shift;
        if ($self->get("HTTP_X_FORWARDED_FOR") =~ m/(\d+\.\d+\.\d+\.\d+)/) {
                return $1;
        } 
	return $self->get("REMOTE_ADDR");
}


#-------------------------------------------------------------------

=head2 new ( )

Constructor. Returns an env object.

=cut

sub new {
	my $class = shift;
	bless {_env=>\%ENV}, $class;
}


1;
