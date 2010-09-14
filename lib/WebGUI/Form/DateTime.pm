package WebGUI::Form::DateTime;

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
use WebGUI::DateTime;

my $isaEpoch = qr/^-?\d+$/;

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

=head4 defaultValue

If no value is specified, this will be used. Defaults to today and now.

=head4 timeZone

The time zone in which MySQL date/time strings are entered. Values selected using 
this form control will be converted from this time zone to UTC. This control will 
return MySQL date/time strings adjusted for this time zone.

Defaults to the users time zone.

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
			defaultValue=> 19
			},
		size=>{
			defaultValue=> 19
			},
        timeZone=>{
            defaultValue=> $session->user->profileField("timeZone")
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
    return WebGUI::International->new($session, 'WebGUI')->get('972');
}

#-------------------------------------------------------------------

=head2 getValue ( [ value ] )

Returns a validated form post result. If the result does not pass validation, it returns undef instead.

=head3 value

An optional value to process, instead of POST input. This should be in the 'YY(YY)?-MM-DD HH:MM:SS' form.

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
		# YY(YY)?-MM-DD HH:MM:SS

        if($value =~ $isaEpoch){
            return $self->session->datetime->epochToSet($value,$self->session->user->profileField( 'timeZone' ));
        }
		
		# Verify format
		return undef
			unless ($value =~ m/(?:\d{2}|\d{4})\D\d{2}\D\d{2}\D\d{2}\D\d{2}\D\d{2}/);
		
		# Fix time zone

		$value 	= WebGUI::DateTime->new($self->session,mysql => $value, time_zone=>$self->session->user->profileField( 'timeZone' ))
			    ->set_time_zone("UTC")->toMysql;
		
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
		return $self->session->datetime->epochToHuman($self->getOriginalValue,"%z %Z");
	} 
    else {
		# MySQL format
		my $value = $self->getOriginalValue;
        # Fix time zone
        $value  = WebGUI::DateTime->new($self->session, mysql => $value)
                ->set_time_zone($self->get("timeZone"))
                ->strftime("%Y-%m-%d %H:%M:%S");
        return $value;
	}
}

#-------------------------------------------------------------------

=head2 headTags ( )

Set the head tags for this form plugin

=cut

sub headTags {
    my $self = shift;
    my $session = $self->session;

    my $style   = $session->style;
    my $url     = $session->url;
    $style->setLink($url->extras('yui/build/calendar/assets/skins/sam/calendar.css'), { rel=>"stylesheet", type=>"text/css", media=>"all" });
    $style->setScript($url->extras('/yui/build/utilities/utilities.js'),        { type => 'text/javascript' });
    $style->setScript($url->extras('yui/build/json/json-min.js'),               { type => 'text/javascript' });
    $style->setScript($url->extras('yui/build/yahoo/yahoo-min.js'),             { type => 'text/javascript' });
    $style->setScript($url->extras('yui/build/dom/dom-min.js'),                 { type => 'text/javascript' });
    $style->setScript($url->extras('yui/build/event/event-min.js'),             { type => 'text/javascript' });
    $style->setScript($url->extras('yui/build/calendar/calendar-min.js'),       { type => 'text/javascript' });
    $style->setScript($url->extras('yui-webgui/build/i18n/i18n.js' ),           { type => 'text/javascript' });
    $style->setScript($url->extras('yui-webgui/build/datepicker/datepicker.js'),{ type => 'text/javascript' });
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
    my $value   = eval { WebGUI::DateTime->new($session, $self->getOriginalValue); };
    $value      = WebGUI::DateTime->new($session,0) if $value eq '';
    $value      = $value->set_time_zone($self->get("timeZone"))->strftime("%Y-%m-%d %H:%M:%S");

    $self->headTags;
    return WebGUI::Form::Text->new($self->session,
            name      => $self->get("name"),
            value     => $value,
            size      => $self->get("size"),
            extras    => $self->get("extras") . ' onfocus="YAHOO.WebGUI.Form.DatePicker.display(this, true);"',
            id        => $self->get('id'),
            maxlength => $self->get("maxlength")
            )->toHtml;
}

#-------------------------------------------------------------------

=head2 toHtmlAsHidden ( )

Renders the form field to HTML as a hidden field rather than whatever field type it was supposed to be.

=cut

sub toHtmlAsHidden {
    my $self = shift;
    my $value = WebGUI::DateTime->new($self->session, $self->getOriginalValue)
              ->set_time_zone($self->get("timeZone"))
              ->strftime("%Y-%m-%d %H:%M:%S");
	
    return WebGUI::Form::Hidden->new($self->session,
        name	=> $self->get("name"),
        value	=> $value,
        )->toHtmlAsHidden;
}

1;

