package WebGUI::Form::Captcha;

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
use WebGUI::Storage::Image;

=head1 NAME

Package WebGUI::Form::Captcha

=head1 DESCRIPTION

Creates a captcha form element that helps verify a human is submitting the form rather than a bot.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::Text.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclass for additional methods.

=cut

#-------------------------------------------------------------------

=head2 definition ( [ additionalTerms ] )

See the super class for additional details.

=head3 additionalTerms

The following additional parameters have been added via this sub class.

=head4 profileEnabled

Flag that tells the User Profile system that this is a valid form element in a User Profile

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift || [];
	my $i18n = WebGUI::International->new($session,"Form_Captcha");
	push(@{$definition}, {
		formName=>{
			defaultValue=>$i18n->get("topicName")
			},
		});
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 getValueFromPost ( )

Returns a boolean indicating whether the string typed matched the image.

=cut

sub getValueFromPost {
	my $self = shift;
	my $value = $self->session->form->param($self->get("name"));
	my $challenge = $self->session->scratch->get("captcha_".$self->get("name"));
	$self->session->scratch->delete("captcha_".$self->get("name"));
	return (lc($value) eq lc($challenge));
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a captcha field.

=cut

sub toHtml {
        my $self = shift;
 	my $storage = WebGUI::Storage::Image->createTemp($self->session);
        my ($filename, $challenge) = $storage->addFileFromCaptcha;
        $self->set("size", 6);
	$self->set("maxlength", 6);
	$self->session->scratch->set("captcha_".$self->get("name"), $challenge);
	$self->set("subtext", '<img src="'.$storage->getUrl($filename).'" style="border-style:none;" alt="captcha" align="middle" />'.$self->get("subtext"));
	return $self->SUPER::toHtml;
}

1;

