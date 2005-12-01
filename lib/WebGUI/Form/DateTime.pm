package WebGUI::Form::DateTime;

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
use base 'WebGUI::Form::Text';
use WebGUI::Form::Hidden;
use WebGUI::DateTime;
use WebGUI::International;
use WebGUI::Session;
use WebGUI::Style;

=head1 NAME

Package WebGUI::Form::DateTime

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

Defaults to 19. Determines the maximum number of characters allowed in this field.

=head4 size

Defaults to 19. The displayed size of the box for the date to be typed in.

=head4 profileEnabled

Flag that tells the User Profile system that this is a valid form element in a User Profile

=head4 defaultValue

If no value is specified, this will be used. Defaults to today and now.

=cut

sub definition {
	my $class = shift;
	my $definition = shift || [];
	push(@{$definition}, {
		formName=>{
                        defaultValue=>WebGUI::International::get("972","WebGUI")
                        },
		defaultValue=>{
                        defaultValue=>time()
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
	return $class->SUPER::definition($definition);
}

#-------------------------------------------------------------------

=head2 getValueFromPost ( )

Returns a validated form post result. If the result does not pass validation, it returns undef instead.

=cut

sub getValueFromPost {
	my $self = shift;
	return WebGUI::DateTime::setToEpoch($session{req}->param($self->{name}));
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a date picker control.

=cut

sub toHtml {
        my $self = shift;
	my $value = WebGUI::DateTime::epochToSet($self->{value},1);
	my $language  = WebGUI::International::getLanguage($session{user}{language},"languageAbbreviation");
	unless ($language) {
		$language = WebGUI::International::getLanguage("English","languageAbbreviation");
	}
        WebGUI::Style::setScript($session{config}{extrasURL}.'/calendar/calendar.js',{ type=>'text/javascript' });
        WebGUI::Style::setScript($session{config}{extrasURL}.'/calendar/lang/calendar-'.$language.'.js',{ type=>'text/javascript' });
        WebGUI::Style::setScript($session{config}{extrasURL}.'/calendar/calendar-setup.js',{ type=>'text/javascript' });
        WebGUI::Style::setLink($session{config}{extrasURL}.'/calendar/calendar-win2k-1.css', { rel=>"stylesheet", type=>"text/css", media=>"all" });
	my $mondayFirst = $session{user}{firstDayOfWeek} ? "true" : "false";
        return WebGUI::Form::Text->new(
                name=>$self->{name},
                value=>$value,
                size=>$self->{size},
                extras=>$self->{extras},
		id=>$self->{id},
                maxlength=>$self->{maxlength}
                )->toHtml . '<script type="text/javascript"> 
                        Calendar.setup({ 
                                inputField : "'.$self->{id}.'", 
                                ifFormat : "%Y-%m-%d %H:%M:%S", 
                                showsTime : true, 
                                timeFormat : "12",
                                mondayFirst : '.$mondayFirst.'
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
		name=>$self->{name},
		value=>WebGUI::DateTime::epochToSet($self->{value},1)	
		)->toHtmlAsHidden;
}

1;

