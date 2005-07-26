package WebGUI::Form::databaseLink;

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
use base 'WebGUI::Form::Control';
use WebGUI::DatabaseLink;
use WebGUI::Form::selectList;
use WebGUI::Session;

=head1 NAME

Package WebGUI::Form::databaseLink

=head1 DESCRIPTION

Creates a database connection chooser control.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::Control.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclass for additional methods.

=cut

#-------------------------------------------------------------------

=head2 definition ( [ additionalTerms ] )

See the super class for additional details.

=head3 additionalTerms

The following additional parameters have been added via this sub class.

=head4 name

The identifier for this field. Defaults to "databaseLinkId".

=head4 defaultValue

A database link id. Defaults to "0", which is the WebGUI database.

=cut

sub definition {
	my $class = shift;
	my $definition = shift || [];
	push(@{$definition}, {
		name=>{
			defaultValue=>"databaseLinkId"
			},
		defaultValue=>{
			defaultValue=>0
			},
		});
	return $class->SUPER::definition($definition);
}


#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a database connection picker control.

=cut

sub toHtml {
	my $self = shift;
	return WebGUI::Form::selectList->new(
		name=>$self->{name},
		options=>WebGUI::DatabaseLink::getList(),
		value=>[$self->{value}]
		)->toHtml;
}



1;

