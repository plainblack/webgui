package WebGUI::Form::YesNo;

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
use base 'WebGUI::Form::Control';
use WebGUI::Form::Radio;
use WebGUI::International;

=head1 NAME

Package WebGUI::Form::YesNo

=head1 DESCRIPTION

Creates a yes/no question field.

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

Can be a 1 or 0. Defaults to 0 if no value is specified.

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
			defaultValue=>$i18n->get("483")
			},
		defaultValue=>{
			defaultValue=>0
			},
		profileEnabled=>{
			defaultValue=>1
			},
		});
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 getValueFromPost ( )

Returns either a 1 or 0 representing yes, no. 

=cut

sub yesNo {
	my $self = shift;
        if ($self->session->request->param($self->get("name")) > 0) {
                return 1;
        }
	return 0;
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a yes/no question field.

=cut

sub toHtml {
	my $self = shift;
	my $i18n = WebGUI::International->new($self->session);
        my ($checkYes, $checkNo);
        if ($self->get("value")) {
                $checkYes = 1;
        } else {
                $checkNo = 1;
        }
        my $output = WebGUI::Form::Radio->new($self->session,
                checked=>$checkYes,
                name=>$self->get("name"),
                value=>1,
                extras=>$self->get("extras")
                )->toHtml;
        $output .= $i18n->get(138);
        $output .= '&nbsp;&nbsp;&nbsp;';
        $output .= WebGUI::Form::Radio->new($self->session,
                checked=>$checkNo,
                name=>$self->get("name"),
                value=>0,
                extras=>$self->get("extras")
                )->toHtml;
        $output .= $i18n->get(139);
        return $output;
}


1;

