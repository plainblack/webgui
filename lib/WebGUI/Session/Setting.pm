package WebGUI::Session::Setting;

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

Package WebGUI::Session::Setting

=head1 DESCRIPTION

This package stores and retrieves settings. It is generally only used internally by WebGUI and not by external scripts.

=head1 SYNOPSIS

 use WebGUI::Session::Setting;

 $settings = WebGUI::Session::Setting->new;

 $settings->set($name, $value);
 $value = $settings->get($name);

 $settings->add($name, $value);
 $settings->remove($name);

 $session = $settings->session;

=head1 FUNCTIONS

These subroutines are available from this package:

=cut



#-------------------------------------------------------------------

=head2 add ( name, value )

Creates a new setting.

=head3 name

The name of the setting to add.

=head3 value

The initial value of the setting.

=cut

sub add {
	my $self = shift;
	my $name = shift;
	my $value = shift;
	$self->{_settings}{$name} = $value;
	$self->session->db->write("insert into settings (name,value) values (".$self->session->db->quote($name).",".$self->session->db->quote($value).")");
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

=head2 get ( )

Returns a hash reference containing all the settings.

=cut

sub get {
	my $self = shift;
	my $param = shift;
	return $self->{_settings}{$param};
}


#-------------------------------------------------------------------

=head2 new ( session ) 

Constructor.

=head3 session

A reference to the current WebGUI::Session.

=cut

sub new {
	my $class = shift;
	my $session = shift;
	my $settings = $session->db->buildHashRef("select * from settings");
	bless {_settings=>$settings, _session=>$session}, $class;
}


#-------------------------------------------------------------------

=head2 remove ( name )

Removes a setting permanently.

=head3 name

The name of the setting to set.

=cut

sub remove {
	my $self = shift;
	my $name = shift;
	delete $self->{_settings}{$name};
	$self->session->db->write("delete from settings where name=".$self->session->db->quote($name));
}


#-------------------------------------------------------------------

=head2 session ( )

Returns a reference to the WebGUI::Session object.

=cut

sub session {
	my $self = shift;
	return $self->{_session};
}


#-------------------------------------------------------------------

=head2 set ( name, value )

Sets the value of a setting.

=head3 name

The name of the setting to set.

=head3 value

The value of the setting.

=cut

sub set {
	my $self = shift;
	my $name = shift;
	my $value = shift;
	$self->{_settings}{$name} = $value;
	$self->session->db->write("update settings set value=".$self->session->db->quote($value)." where name=".$self->session->db->quote($name));
}



1;

