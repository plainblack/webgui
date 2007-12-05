package WebGUI::Form::TimeField;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2007 Plain Black Corporation.
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

If the default value is a MySQL time, the value returned by this form element 
will be a MySQL time. Note: Will not be adjusted for the user's time zone.

Otherwise, the value returned by this form element will be a number of seconds,
adjusted for the user's time zone..

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

=head4 defaultValue

Either a number of seconds or a MySQL time.

=head4 maxlength

Defaults to 8. Determines the maximum number of characters allowed in this field.

=head4 size

Default to 8. Determines how many characters wide the field wlll be.

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
			defaultValue=>$i18n->get("971")
			},
		maxlength=>{
			defaultValue=>8
			},
		size=>{
			defaultValue=>8
			},
		format => {
            defaultValue => undef,
        },
        profileEnabled=>{
			defaultValue=>1
			},
        dbDataType  => {
            defaultValue    => "BIGINT",
        },
		});
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 getValueFromPost ( [ value ] )

If the defaultValue is a MySQL time, the value returned by this form element 
will be a MySQL time. Note: Will not be adjusted for the user's time zone.

Otherwise, the value returned by this form element will be a number of seconds,
adjusted for the user's time zone..

=head3 value

An optional value to process, instead of POST input. This should be in the form of an integer of seconds, 'HH:MM', or 'HH:MM:SS'.

=cut

sub getValueFromPost {
	my $self = shift;

	if (@_) {
		my $value = shift;
		if ($self->get('format') ne 'mysql' && (
            !$self->get("defaultValue") 
        || $self->get("defaultValue") =~ m/^\d+$/
        || !$value     
        || $value =~ m/^\d+$/)) {
			return $self->session->datetime->timeToSeconds($value)-($self->session->user->profileField("timeOffset")*3600);
		}
		elsif ($value =~ /^\d{2}\D\d{2}(\D\d{2})?$/) {
			return $value
		}
		else {
			return;
		}
	}

    # This should probably be rewritten as a cascading ternary
	if ($self->get('format') ne 'mysql' && (
        !$self->get("defaultValue") 
        || $self->get("defaultValue") =~ m/^\d+$/
        || !$self->get("value")     
        || $self->get("value") =~ m/^\d+$/)) {
		# epoch format
		return $self->session->datetime->timeToSeconds($self->session->form->param($self->get("name")))-($self->session->user->profileField("timeOffset")*3600);
	} else {
		# Mysql format
		my $value = $self->session->form->param($self->get("name"));
		return unless $value =~ /^\d{2}\D\d{2}(\D\d{2})?$/;
		return $value;
	}
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a time field.

=cut

sub toHtml {
    my $self = shift;
	my $value;
    # This should probably be rewritten as a cascading ternary
	if (!$self->get("defaultValue") 
        || $self->get("defaultValue") =~ m/^\d+$/
        || !$self->get("value")     
        || $self->get("value") =~ m/^\d+$/) {
		# Epoch format
		$value 	= $self->session->datetime->secondsToTime($self->get("value"));
	} else {
		# MySQL format
		$value	= $self->get("value");
	}
	my $i18n = WebGUI::International->new($self->session);
	$self->session->style->setScript($self->session->url->extras('inputCheck.js'),{ type=>'text/javascript' });
	$self->set("extras", $self->get('extras') . ' onkeyup="doInputCheck(document.getElementById(\''.$self->get("id").'\'),\'0123456789:\')"');
	return $self->SUPER::toHtml
		.WebGUI::Form::Button->new($self->session,
			id=>$self->get('id'),
			extras=>'style="font-size: 8pt;" onclick="window.timeField = this.form.'.$self->get("name").';clockSet = window.open(\''.$self->session->url->extras('timeChooser.html').'\',\'timeChooser\',\'WIDTH=230,HEIGHT=100\');return false"',
			value=>$i18n->get(970)
			)->toHtml;
}

#-------------------------------------------------------------------

=head2 toHtmlAsHidden ( )

Renders the field as a hidden field.

=cut

sub toHtmlAsHidden {
	my $self = shift;
	my $value;
    # This should probably be rewritten as a cascading ternary
	if (!$self->get("defaultValue") 
        || $self->get("defaultValue") =~ m/^\d+$/
        || !$self->get("value")     
        || $self->get("value") =~ m/^\d+$/) {
		# Epoch format
		$value 	= $self->session->datetime->secondsToTime($self->get("value"));
	} else {
		# MySQL format
		$value	= $self->get("value");
	}
	return WebGUI::Form::Hidden->new($self->session,
		name=>$self->get("name"),
		value=>$value
		)->toHtmlAsHidden;
}

1;
