package WebGUI::Form::Date;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
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
use Scalar::Util qw/blessed/;

my $isaEpoch = qr/^-?\d+$/;

=head1 NAME

Package WebGUI::Form::Date

=head1 DESCRIPTION

Accepts and returns and epoch date and creates a date picker control.

If the current or default value is a MySQL date string, accepts and returns
a MySQL date string. 

NOTE: Does not do time-zone conversion.

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

Originals to 10. Determines the maximum number of characters allowed in this field.

=head4 size

Originals to 10. The displayed size of the box for the date to be typed in.

=head4 noDate

A default date is placed in the value field. Set this to "1" to leave it empty.

=head4 defaultValue

If no value is specified, this will be used. Originals to today and now.

If the defaultValue is a MySQL date string, this form control will return MySQL
date strings instead of epoch times.

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift || [];
	
    push(@{$definition}, {
		defaultValue=>{
			defaultValue=>time()
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
		});
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2  getDatabaseFieldType ( )

Returns "BIGINT".

=cut 

sub getDatabaseFieldType {
    return "BIGINT";
}

#-------------------------------------------------------------------

=head2 getName ( session )

Returns the human readable name of this control.

=cut

sub getName {
    my ($self, $session) = @_;
    return WebGUI::International->new($session, 'WebGUI')->get('352');
}

#-------------------------------------------------------------------

=head2 getValue ( [ value ] )

Returns a validated form post result. If the result does not pass validation, 
it returns undef instead.

=head3 value

An optional value to process, instead of POST input. This should be in the 'YY(YY)?-MM-DD' form.

=cut

sub getValue {
	my $self = shift;
    # This should probably be rewritten as a cascading ternary
    my $value = $self->SUPER::getValue(@_);
	if (!$self->getDefaultValue || $self->getDefaultValue =~ $isaEpoch) {
        # Epoch format
        if($value =~ $isaEpoch){
            return $value;
        }
        return $self->session->datetime->setToEpoch($value);
	} 
    else {
		# MySQL format
		# YY(YY)?-MM-DD
		
		# NOTE: Cannot fix time zone since we don't have a complete date/time

        if($value =~ $isaEpoch){
            return $self->session->datetime->epochToSet($value,$self->session->user->profileField( 'timeZone' ));
        }

        # Verify format
        return undef
			unless ($value =~ m/((?:\d{2}|\d{4})\D\d{2}\D\d{2})/);
        return $value;
	}
}

#-------------------------------------------------------------------

=head2 getValueAsHtml ( )

Return the date in a human readable format.

=cut

sub getValueAsHtml {
    my ($self) = @_;
    # This should probably be rewritten as a cascading ternary
    if ( !$self->get("defaultValue") 
      ||  $self->get("defaultValue") =~ $isaEpoch
      || !$self->get("value")     
      ||  $self->get("value")        =~ $isaEpoch) {
		return $self->session->datetime->epochToHuman($self->getOriginalValue, '%z');
    } 
    else {
        # MySQL format
        my $value = $self->getOriginalValue;
        return $value;
	}
}

#-------------------------------------------------------------------

=head2 headTags ()

Set head tags for this form plugin

=cut

sub headTags {
    my $self    = shift;
    my $session = $self->session;
    my $style   = $session->style;
    my $url     = $session->url;
    $style->setCss($url->extras('yui/build/calendar/assets/skins/sam/calendar.css'));
    $style->setScript($url->extras('yui/build/utilities/utilities.js'));
    $style->setScript($url->extras('yui/build/json/json-min.js'));
    $style->setScript($url->extras('yui/build/yahoo/yahoo-min.js'));
    $style->setScript($url->extras('yui/build/dom/dom-min.js'));
    $style->setScript($url->extras('yui/build/event/event-min.js'));
    $style->setScript($url->extras('yui/build/calendar/calendar-min.js'));
    $style->setScript($url->extras('yui-webgui/build/i18n/i18n.js' ));
    $style->setScript($url->extras('yui-webgui/build/datepicker/datepicker.js'));
}

#-------------------------------------------------------------------

=head2 isDynamicCompatible ( )

A class method that returns a boolean indicating whether this control is compatible with the DynamicField control.

=cut

sub isDynamicCompatible {
    return 1;
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a date picker control.

=cut

sub toHtml {
    my $self    = shift;
    my $session = $self->session;
    my $value;
	# This should probably be rewritten as a cascading ternary
    if ($self->get("_defaulted") && $self->get("noDate") ) {
        # No default date
        $value = $self->set("value",'');
    }
    else {
        my $originalValue = $self->getOriginalValue;
        my $dt = eval { WebGUI::DateTime->new($session, $originalValue); };
        $dt = WebGUI::DateTime->new($session,0) if ! (blessed $dt && $dt->isa('DateTime'));  ##Parsing error
        $dt->set_time_zone($session->datetime->getTimeZone);
        $value = $dt->toMysqlDate;
    }

    my $field = WebGUI::Form::Text->new($self->session,
        name      => $self->get("name"),
        value     => $value,
        size      => $self->get("size"),
        extras    => $self->get("extras") . ' onfocus="YAHOO.WebGUI.Form.DatePicker.display(this);"',
        id        => $self->get('id'),
        maxlength => $self->get("maxlength"),
    );
    $self->headTags;
    return $field->toHtml;
}

#-------------------------------------------------------------------

=head2 toHtmlAsHidden ( )

Renders the form field to HTML as a hidden field rather than whatever field type it was supposed to be.

=cut

sub toHtmlAsHidden {
    my $self    = shift;
    my $session = $self->session;
    my $value = WebGUI::DateTime->new($session, $self->getOriginalValue)->toMysqlDate;
    return WebGUI::Form::Hidden->new($session,
        name	=> $self->get("name"),
        value	=> $value,
    )->toHtmlAsHidden;
}

1;

