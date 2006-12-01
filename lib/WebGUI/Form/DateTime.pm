package WebGUI::Form::DateTime;

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
use WebGUI::International;
use WebGUI::DateTime;

=head1 NAME

Package WebGUI::Form::DateTime

=head1 DESCRIPTION

Accepts and returns an epoch date and creates a date picker control.

If the default value is a MySQL date/time string, accepts and returns MySQL
date/time strings.

NOTE: Does not adjust for the user's time zone unless using MySQL date/time 
strings.

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

Defaults to 19. Determines the maximum number of characters allowed in this field.

=head4 size

Defaults to 19. The displayed size of the box for the date to be typed in.

=head4 profileEnabled

Flag that tells the User Profile system that this is a valid form element in a User Profile

=head4 defaultValue

If no value is specified, this will be used. Defaults to today and now.

If the defaultValue is a MySQL date/time string, this form control will return
MySQL date/time strings adjusted for the user's time zone.

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift || [];
	my $i18n = WebGUI::International->new($session);
	push(@{$definition}, {
		formName=>{
                        defaultValue=>$i18n->get("972")
                        },
		defaultValue=>{
                        defaultValue=>$session->datetime->time()
                        },
		maxlength=>{
			defaultValue=> 19
			},
		size=>{
			defaultValue=> 19
			},
		profileEnabled=>{
			defaultValue=>1
			},
		});
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 getValueFromPost ( )

Returns a validated form post result. If the result does not pass validation, it returns undef instead.

=cut

sub getValueFromPost {
	my $self = shift;
	if (!$self->get("defaultValue") || $self->get("defaultValue") =~ m/^\d+$/) {
		# Epoch format
		return $self->session->datetime->setToEpoch($self->session->form->param($self->get("name")),1);
	} else {
		# MySQL format
		# YY(YY)?-MM-DD HH:MM:SS
		my $value	= $self->session->form->param($self->get("name"));
		$self->session->errorHandler->warn("Date value: $value");
		
		# Verify format
		return undef
			unless ($value =~ m/(?:\d{2}|\d{4})\D\d{2}\D\d{2}\D\d{2}\D\d{2}\D\d{2}/);
		
		# Fix time zone
		$value 	= WebGUI::DateTime->new(mysql => $value, time_zone => $self->session->user->profileField("timeZone"))
			->set_time_zone("UTC")->toMysql;
		
		return $value;
	}
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a date picker control.

=cut

sub toHtml {
        my $self = shift;
	my $value;
	if (!$self->get("defaultValue") || $self->get("defaultValue") =~ m/^\d+$/) {
		# Epoch format
		$value	= $self->session->datetime->epochToSet($self->get("value"),1);
	} else {
		# MySQL format
		$value	= $self->get("value");
		# Fix time zone
		$value 	= WebGUI::DateTime->new($value)
			->set_time_zone($self->session->user->profileField("timeZone"))
			->toMysql;
	}
	my $i18n = WebGUI::International->new($self->session);
	my $language  = $i18n->getLanguage($self->session->user->profileField("language"),"languageAbbreviation");
	unless ($language) {
		$language = $i18n->getLanguage("English","languageAbbreviation");
	}
        $self->session->style->setScript($self->session->url->extras('calendar/calendar.js'),{ type=>'text/javascript' });
        $self->session->style->setScript($self->session->url->extras('calendar/lang/calendar-'.$language.'.js'),{ type=>'text/javascript' });
        $self->session->style->setScript($self->session->url->extras('calendar/calendar-setup.js'),{ type=>'text/javascript' });
        $self->session->style->setLink($self->session->url->extras('calendar/calendar-win2k-1.css'), { rel=>"stylesheet", type=>"text/css", media=>"all" });
	my $mondayFirst = $self->session->user->profileField("firstDayOfWeek") ? "true" : "false";
        return WebGUI::Form::Text->new($self->session,
                name=>$self->get("name"),
                value=>$value,
                size=>$self->get("size"),
                extras=>$self->get("extras"),
		id=>$self->get('id'),
                maxlength=>$self->get("maxlength")
                )->toHtml . '<script type="text/javascript"> 
                        Calendar.setup({ 
                                inputField : "'.$self->get('id').'", 
                                ifFormat : "%Y-%m-%d %H:%M:%S", 
                                showsTime : true, 
                                step : 1,
                                timeFormat : "12",
                                firstDay : '.$mondayFirst.'
                                }); 
                        </script>';
}

#-------------------------------------------------------------------

=head2 toHtmlAsHidden ( )

Renders the form field to HTML as a hidden field rather than whatever field type it was supposed to be.

=cut

sub toHtmlAsHidden {
        my $self = shift;
	my $value;
	
	if (!$self->get("defaultValue") || $self->get("defaultValue") =~ m/^\d+$/) {
		$value = $self->session->datetime->epochToSet($self->get("value"),1);
	} else {
		# MySQL format
		$value = $self->get("value");
		# Fix Time zone
		$value 	= WebGUI::DateTime->new($value)
			->set_time_zone($self->session->user->profileField("timeZone"))
			->toMysql;
	}
	
	return WebGUI::Form::Hidden->new(
		name	=> $self->get("name"),
		value	=> $value,
		)->toHtmlAsHidden;
}

1;

