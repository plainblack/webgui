package WebGUI::Form::Float;

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

Package WebGUI::Form::Float

=head1 DESCRIPTION

Returns a floating point number (decimal) field.

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

Defaults to 14. Determines the maximum number of characters allowed in this field.

=head4 defaultValue

Defaults to 0. Used if no value is specified.

=head4 size

Defaults to 11. The number of characters that will be displayed at once in this field. Usually no need to override the default.

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
			defaultValue=>$i18n->get("float")
			},
		maxlength=>{
			defaultValue=> 14
			},
		defaultValue=>{
			defaultValue=>0
			},
		size=>{
			defaultValue=>11
			},
		profileEnabled=>{
			defaultValue=>1
			},
		});
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 getValueFromPost ( )

Returns the integer from the form post, or returns 0.0 if the post result is invalid.

=cut

sub getValueFromPost {
	my $self = shift;
	my $value = $self->session->request->param($self->get("name"));
	if ($value =~ /^[\d\-\.]+$/) {
                return $value;
        }
        return 0.0;
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a floating point field.

=cut

sub toHtml {
        my $self = shift;
	$self->session->style->setScript($self->session->config->get("extrasURL").'/inputCheck.js',{ type=>'text/javascript' });
	$self->set("extras", $self->get('extras') . ' onkeyup="doInputCheck(this.form.'.$self->get("name").',\'0123456789-.\')"');
	return $self->SUPER::toHtml;
}

1;

