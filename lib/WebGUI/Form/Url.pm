package WebGUI::Form::Url;

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
use base 'WebGUI::Form::Text';
use WebGUI::International;

=head1 NAME

Package WebGUI::Form::Url

=head1 DESCRIPTION

Creates a URL form field.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::Text.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclass for additional methods.

=cut

#-------------------------------------------------------------------

=head2 definition ( [ additionalTerms ] )

See the superclass for additional details.

=head3 additionalTerms

The following additional parameters have been added via this sub class.

=head4 maxlength

Defaults to 2048. Determines the maximum number of characters allowed in this field.

=head4 profileEnabled

Flag that tells the User Profile system that this is a valid form element in a User Profile

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift || [];
	my $i18n = WebGUI::International->new($session);
	push(@{$definition}, {
		formName=>{
			defaultValue=>$i18n->get("478")
			},
		maxlength=>{
			defaultValue=> 2048
			},
		profileEnabled=>{
			defaultValue=>1
			},
		});
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 getValueFromPost ( )

Parses the posted value and tries to make corrections if necessary.

=cut

sub getValueFromPost {
	my $self = shift;
	my $value = $self->session->form->param($self->get("name"));
	$value =~ tr/\r\n//d;
     	if ($value =~ /mailto:/) {
                return $value;
        } elsif ($value =~ /^([A-Z0-9]+[._+-]?){1,}([A-Z0-9]+[_+-]?)+\@(([A-Z0-9]+[._-]?){1,}[A-Z0-9]+\.){1,}[A-Z]{2,4}$/i) {
                return "mailto:".$value;
        } elsif ($value =~ /^\// || $value =~ /:\/\// || $value =~ /^\^/) {
                return $value;
        }
        return "http://".$value;
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a URL field.

=cut

sub toHtml {
        my $self = shift;
	$self->session->style->setScript($self->session->url->extras('addHTTP.js'),{ type=>'text/javascript' });
	$self->set("extras", $self->get('extras') . ' onblur="addHTTP(this.form.'.$self->get("name").')"');
	return $self->SUPER::toHtml;
}

1;

