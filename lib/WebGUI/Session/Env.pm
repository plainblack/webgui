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
        if ($var eq "REMOTE_ADDR" && $self->{_env}{HTTP_X_FORWARDED_FOR} ne "") {
                return $self->{_env}{HTTP_X_FORWARDED_FOR};
        }
	return $self->{_env}{$var};
}


#-------------------------------------------------------------------

=head2 new ( )

Constructor. Returns a stow object.

=cut

sub new {
	my $class = shift;
	bless {_env=>\%ENV}, $class;
}



1;
