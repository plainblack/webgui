package WebGUI::Form::TimeField;

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
use WebGUI::Form::Button;
use WebGUI::Form::Hidden;
use WebGUI::International;

=head1 NAME

Package WebGUI::Form::TimeField

=head1 DESCRIPTION

Creates a time form field. 

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

Defaults to 8. Determines the maximum number of characters allowed in this field.

=head4 size

Default to 8. Determines how many characters wide the field wlll be.

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
			defaultValue=>$i18n->get("971")
			},
		maxlength=>{
			defaultValue=>8
			},
		size=>{
			defaultValue=>8
			},
		profileEnabled=>{
			defaultValue=>1
			},
		});
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 getValueFromPost ( )

Returns the number of seconds since 00:00:00 on a 24 hour clock. Note, this will adjust for the user's time offset in the reverse manner that the form field adjusts for it in order to make the times come out appropriately.

=cut

sub getValueFromPost {
	my $self = shift;
	return $self->session->datetime->timeToSeconds($self->session->request->param($self->get("name")))-($self->session->user->profileField("timeOffset")*3600);
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a time field.

=cut

sub toHtml {
        my $self = shift;
	my $value = $self->session->datetime->secondsToTime($self->get("value"));
	my $i18n = WebGUI::International->new($self->session);
	$self->session->style->setScript($self->session->config->get("extrasURL").'/inputCheck.js',{ type=>'text/javascript' });
	$self->set("extras", $self->get('extras') . ' onkeyup="doInputCheck(this.form.'.$self->get("name").',\'0123456789:\')"');
	return $self->SUPER::toHtml
		.WebGUI::Form::Button->new(
			$self->session,
			id=>$self->get('id'),
			extras=>'style="font-size: 8pt;" onclick="window.timeField = this.form.'.$self->get("name").';clockSet = window.open(\''.$self->session->config->get("extrasURL"). '/timeChooser.html\',\'timeChooser\',\'WIDTH=230,HEIGHT=100\');return false"',
			value=>$i18n->get(970)
			)->toHtml;
}

#-------------------------------------------------------------------

=head2 toHtmlAsHidden ( )

Renders the field as a hidden field.

=cut

sub toHtmlAsHidden {
	my $self = shift;
	return WebGUI::Form::Hidden->new(
		$self->session,
		name=>$self->get("name"),
		value=>secondsToTime($self->get("value"))
		)->toHtmlAsHidden;
}




1;

