package WebGUI::Session::Os;

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

Package WebGUI::Session::Os

=head1 DESCRIPTION

This package allows you to reference environment variables.

=head1 SYNOPSIS

$os = WebGUI::Session::Os->new;

$value = $os->get('name');

=head1 METHODS

These methods are available from this package:

=cut

#-------------------------------------------------------------------

=head2 get( varName ) 

Retrieves the current value of an operating system variable.

=head3 varName

The name of the variable.

=head4 name

The name of the operating system as reported by perl.

=head4 type

Will either be "Windowsish" or "Linuxish", which is often more useful than name because the differences between various flavors of Unix, Linux, and BSD are usually not that significant.

=cut

sub get {
	my $self = shift;
	my $var = shift;
	return $self->{_os}{$var};
}


#-------------------------------------------------------------------

=head2 new ( )

Constructor. Returns an OS object.

=cut

sub new {
	my $class = shift;
	my $self = {};
	$self->{_os}{name} = $^O;
        if ($self->{_os}{name} =~ /MSWin32/i || $self->{_os}{name} =~ /^Win/i) {
                $self->{_os}{type} = "Windowsish";
        } else {
                $self->{_os}{type} = "Linuxish";
        }
	bless $self, $class;
}



1;
