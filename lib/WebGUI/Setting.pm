package WebGUI::Setting;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2005 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use WebGUI::Session;
use WebGUI::SQL;

=head1 NAME

Package WebGUI::Setting;

=head1 DESCRIPTION

This package stores and retrieves settings. It is generally only used internally by WebGUI and not by external scripts.

=head1 SYNOPSIS

 use WebGUI::Setting;

 WebGUI::Setting::set($name,$value);
 $hashRef = WebGUI::Setting::get();

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
	my $name = shift;
	my $value = shift;
	$WebGUI::Session::session{setting}{$name} = $value;
	WebGUI::SQL->write("insert into settings  values (".quote($name).",".quote($value).")");
	WebGUI::Cache->new("settings")->delete;
}


#-------------------------------------------------------------------

=head2 get ( )

Returns a hash reference containing all the settings.

=cut

sub get {
	my $cache = WebGUI::Cache->new("settings");
	my $settings = $cache->get;
	unless (defined $settings) {
		$settings = WebGUI::SQL->buildHashRef("select * from settings");
		$cache->set($settings,60*60*24);
	}
	return $settings;
}


#-------------------------------------------------------------------

=head2 remove ( name )

Removes a setting permanently.

=head3 name

The name of the setting to set.

=cut

sub remove {
	my $name = shift;
	WebGUI::SQL->write("delete from settings where name=".quote($name));
	WebGUI::Cache->new("settings")->delete;
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
	my $name = shift;
	my $value = shift;
	$WebGUI::Session::session{setting}{$name} = $value;
	WebGUI::SQL->write("update settings set value=".quote($value)." where name=".quote($name));
	WebGUI::Cache->new("settings")->delete;
}



1;

