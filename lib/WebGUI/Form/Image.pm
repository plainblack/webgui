package WebGUI::Form::Image;

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
use base 'WebGUI::Form::File';
use WebGUI::International;
use WebGUI::Storage;
use WebGUI::Form::YesNo;

=head1 NAME

Package WebGUI::Form::Image

=head1 DESCRIPTION

Creates a text input box form field.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::File, and thereform WebGUI::Form::Image.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclasses for additional methods.

=cut

#-------------------------------------------------------------------

=head2 definition ( [ additionalTerms ] )

See the super class for additional details.

=head3 additionalTerms

The following additional parameters have been added via this sub class.

=head4 name

If no name is specified a default name of "file" will be used.

=head4 maxAttachments

Defaults to 1. Determines how many files the user can upload with this form control.

=head4 profileEnabled

Flag that tells the User Profile system that this is a valid form element in a User Profile

=cut

sub definition {
	my $class = shift;
	my $session = shift; use WebGUI; WebGUI::dumpSession($session);
	my $definition = shift || [];
	my $i18n = WebGUI::International->new($session);
	push(@{$definition}, {
		formName=>{
			defaultValue=>$i18n->get("image")
			},
		name=>{
			defaultValue=>"file"
			},
		maxAttachments=>{
			defaultValue=>1
			},
		profileEnabled=>{
			defaultValue=>1
			},
		});
        return $class->SUPER::definition($session, $definition);
}


#-------------------------------------------------------------------

=head2 displayValue ( )

This utility method is used to format values for the Profile system.  It
displays each image in the storage location that is the value of the
profile field.

=cut

sub displayValue {
	my ($self) = @_;
	return '' unless $self->get("value");
	my $location = WebGUI::Storage->get($self->session,$self->get("value"));
	local $_;
	my @files = map { sprintf qq!<img src="%s" />!, $location->getUrl($_) } @{ $location->getFiles };
	my $fileValue = join "<br />\n", @files;
	return $fileValue;
	}

1;
