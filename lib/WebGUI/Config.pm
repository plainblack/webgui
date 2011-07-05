package WebGUI::Config;

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

use Moose;
extends 'Config::JSON';

use WebGUI::Paths;
use Cwd ();
use File::Spec;

=head1 NAME

Package WebGUI::Config

=head1 DESCRIPTION

This package parses the WebGUI config file.

=head1 SYNOPSIS

 use WebGUI::Config;

 my $config = WebGUI::Config->new($configFileName);

 my $value = $config->get($param);
 $config->set($param,$value);

 $config->delete($param);
 $config->deleteFromHash($name, $key);
 $config->deleteFromArray($name, $value);

 $config->addToHash($name, $key, $value);
 $config->addToArray($name, $value);

 my $configFileName = $config->getFilename;

=head1 ISA

Config::JSON

=head1 METHODS

These subroutines are available from this package:

=cut

#-------------------------------------------------------------------

=head2 getCookieName ( ) 

Returns the cookie name defined in the config file. Returns "wgSession" if one isn't defined.

=cut

sub getCookieName {
	my $self = shift;
	return $self->get("cookieName") || "wgSession";	
}

#-------------------------------------------------------------------

=head2 getCookieTTL ( ) 

Returns the cookie time to live defined in the config file. Returns "+10y" if one isn't defined.
This may also be "session" to indicate that the cookie should only live for the current browser
session.

=cut

sub getCookieTTL {
	my $self = shift;
	my $configTTL = $self->get("cookieTTL");
	return defined($configTTL)? $configTTL : "+10y";
}

#-------------------------------------------------------------------

=head2 new ( configFile )

Returns a WebGUI::Config object for the given file.  The file name
can be either an absolute file path, or a path relative to the
WebGUI configuration directory.

=head3 configFile

The filename of the config file to read.

=cut

around BUILDARGS => sub {
    my $orig = shift;
    my $class = shift;
    my $filename = shift;
    $filename = Cwd::realpath(File::Spec->rel2abs($filename, WebGUI::Paths->configBase));
    return $class->$orig($filename);
};

1;

