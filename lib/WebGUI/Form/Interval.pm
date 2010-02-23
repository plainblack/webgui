package WebGUI::Form::Interval;

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
use base qw(WebGUI::Form::Control);
use Tie::IxHash;
use WebGUI::Form::SelectBox;
use WebGUI::Form::Hidden;
use WebGUI::Form::Integer;
use WebGUI::International;

=head1 NAME

Package WebGUI::Form::Interval

=head1 DESCRIPTION

Creates an interval (hours, minutes, seconds, etc) selector.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::Control.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclass for additional methods.

=cut

#-------------------------------------------------------------------

=head2 definition ( [ additionalTerms ] )

See the super class for additional details.

=head3 additionalTerms

The following additional parameters have been added via this sub class.

=head4 defaultValue

A time interval in seconds that is used if value is not specified. Defaults to 1.

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift || [];
	push(@{$definition}, {
		defaultValue=>{
			defaultValue=>1,
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
    return WebGUI::International->new($session, 'WebGUI')->get('interval');
}

#-------------------------------------------------------------------

=head2 getUnitOptions (  )

Returns a hash with i18n labels and values for units of time.

=cut

sub getUnitOptions {
    my $self = shift;
    tie my %units, 'Tie::IxHash';
    my $i18n = WebGUI::International->new($self->session);
    %units = (seconds => $i18n->get(704),
              minutes => $i18n->get(705),
              hours   => $i18n->get(706),
              days    => $i18n->get(700),
              weeks   => $i18n->get(701),
              months  => $i18n->get(702),
              years   => $i18n->get(703),
    );
    return %units;
}

#-------------------------------------------------------------------

=head2 getValue ( [ num_and_units ] )

Returns either the interval that was posted (in seconds) or if nothing comes back it returns 0.

=head3 num_and_units

The number and units for this interval, to use instead of POST input, which is the default. ("3 days", for example.) Valid units are (case-insensitive): seconds, minutes, hours, days, weeks, months, years.

=cut

sub getValue {
	my $self = shift;

	if (@_) {
		my @args = split /\s+/, shift;
		return $self->session->datetime->intervalToSeconds(@args);
	}

	return $self->session->datetime->intervalToSeconds($self->session->form->param($self->get("name")."_interval"),$self->session->form->param($self->get("name")."_units")) || 0;
}

#-------------------------------------------------------------------

=head2 getValueAsHtml (  )

Returns the interval formatted as quantity and units.

=cut

sub getValueAsHtml {
	my $self = shift;
    return join ' ', $self->session->datetime->secondsToExactInterval($self->getOriginalValue);
}

#-------------------------------------------------------------------

=head2 isDynamicCompatible ( )

A class method that returns a boolean indicating whether this control is compatible with the DynamicField control.

=cut

sub isDynamicCompatible {
    return 1;
}

#-------------------------------------------------------------------

=head2 isInRequest ( )

=cut

sub isInRequest {
    my $self = shift;
    my $form = $self->session->form;
    my $name = $self->get('name');
    return $form->hasParam($name.'_interval')
        || $form->hasParam($name.'_units');
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders an interval control.

=cut

sub toHtml {
    my $self = shift;
    my %units = $self->getUnitOptions();
    my %reverseUnits = reverse %units;
    my ($interval, $units) = $self->session->datetime->secondsToExactInterval($self->getOriginalValue);
    # not sure why, but these things need to be defined like this or
    # they fail under some circumstnaces 
    my $cmd = "WebGUI::Form::Integer";
    my $out = $cmd->new($self->session,
        name   => $self->get("name")."_interval",
        value  => $interval,
        extras => $self->get("extras"),
        id     => $self->get('id')."_interval",
        )->toHtml;
    $cmd = "WebGUI::Form::SelectBox";
    my $key = $reverseUnits{$units};
    $out .= $cmd->new($self->session,
        options => \%units,
        name    => $self->get("name")."_units",
        id      => $self->get('id')."_units",
        value   => $key,
        )->toHtml;
    return $out;
}


#-------------------------------------------------------------------

=head2 toHtmlAsHidden ( )

Returns the field as hidden controls rather than displayable controls.

=cut

sub toHtmlAsHidden {
    my $self    = shift;
    my $session = $self->session;
    my %units   = $self->getUnitOptions();
    my %reverseUnits = reverse %units;
    my ($interval, $units) = $session->datetime->secondsToExactInterval($self->getOriginalValue);
    my $unitVal = $reverseUnits{$units};
    return WebGUI::Form::Hidden->new($session,
                    name  => $self->get("name").'_interval',
                    value => $interval,
           )->toHtmlAsHidden
         . WebGUI::Form::Hidden->new($session,
                    name  => $self->get("name").'_units',
                    value => $unitVal,
          )->toHtmlAsHidden;
}

1;

