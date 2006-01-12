package WebGUI::Form::Date;

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
use WebGUI::Form::Hidden;
use WebGUI::Form::Text;
use WebGUI::International;

=head1 NAME

Package WebGUI::Form::Date

=head1 DESCRIPTION

Accepts and returns and epoch date and creates a date picker control.

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

Defaults to 10. Determines the maximum number of characters allowed in this field.

=head4 size

Defaults to 10. The displayed size of the box for the date to be typed in.

=head4 noDate

A default date is placed in the value field. Set this to "1" to leave it empty.

=head4 defaultValue

If no value is specified, this will be used. Defaults to today and now.

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
			defaultValue=>$i18n->get("479")
			},
		defaultValue=>{
			defaultValue=$session->datetime->time()
			},
		maxlength=>{
			defaultValue=> 10
			},
		size=>{
			defaultValue=> 10
			},
		noDate=>{
			defaultValue=>0
			},
		profileEnabled=>{
			defaultValue=>1
			},
		});
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 displayValue ( )

Return the date in a human readable format for the Profile system.

=cut

sub displayValue {
	my ($self) = @_;
	return $self->session->datetime->epochToHuman($self->get("value"),"%z");
}

#-------------------------------------------------------------------

=head2 getValueFromPost ( )

Returns a validated form post result. If the result does not pass validation, it returns undef instead.

=cut

sub getValueFromPost {
	my $self = shift;
	return $self->session->datetime->setToEpoch($self->session->request->param($self->get("name")));
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a date picker control.

=cut

sub toHtml {
        my $self = shift;
	if ($self->get("_defaulted") && $self->get("noDate") ) {
		$self->get("value") = '';
	}
	else {
		$self->get("value") = $self->session->datetime->epochToSet($self->get("value"));
	}
	my $language  = WebGUI::International::getLanguage($self->session->user->profileField("language"),"languageAbbreviation");
	unless ($language) {
		$language = WebGUI::International::getLanguage("English","languageAbbreviation");
	}
        $self->session->style->setScript($self->session->config->get("extrasURL").'/calendar/calendar.js',{ type=>'text/javascript' });
        $self->session->style->setScript($self->session->config->get("extrasURL").'/calendar/lang/calendar-'.$language.'.js',{ type=>'text/javascript' });
        $self->session->style->setScript($self->session->config->get("extrasURL").'/calendar/calendar-setup.js',{ type=>'text/javascript' });
        $self->session->style->setLink($self->session->config->get("extrasURL").'/calendar/calendar-win2k-1.css', { rel=>"stylesheet", type=>"text/css", media=>"all" });
        return $self->SUPER::toHtml. '<script type="text/javascript"> 
                        Calendar.setup({ 
                                inputField : "'.$self->{id}.'", 
                                ifFormat : "%Y-%m-%d", 
                                showsTime : false, 
                                step : 1,
                                timeFormat : "12",
                                firstDay : '.$self->session->user->profileField("firstDayOfWeek").'
                                }); 
                        </script>';
}

#-------------------------------------------------------------------

=head2 toHtmlAsHidden ( )

Renders the form field to HTML as a hidden field rather than whatever field type it was supposed to be.

=cut

sub toHtmlAsHidden {
        my $self = shift;
        return WebGUI::Form::Hidden->new(
                name=>$self->get("name"),
                value=>$self->session->datetime->epochToSet($self->get("value"))
                )->toHtmlAsHidden;
}

1;

