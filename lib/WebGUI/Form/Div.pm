package WebGUI::Form::Div;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2012 Plain Black Corporation.
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
use WebGUI::International;

=head1 NAME

Package WebGUI::Form::Div

=head1 DESCRIPTION

Creates a HTML div element with contents provided by caller

=head1 SEE ALSO

This is a subclass of WebGUI::Form::Control.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclass for additional methods.

=cut

#-------------------------------------------------------------------

=head2 definition ( [ additionalTerms ] )

See the super class for additional details.

=head3 usage

    $form->div({
       contentCallback => sub { $self->getDivContents(shift); }
    });

=head3 additionalTerms

The following additional parameters have been added via this sub class.

=head4 contentCallback

A code enclosure which returns the html text to insert into the div element.  The divId is passed as parameter 0 when it is called.  This function MUST return good html text, it is NOT processed here at all.

=cut

sub definition {
    my $class = shift;
    my $session = shift;
    my $definition = shift || [];
    push(@{$definition}, {
        contentCallback=>{
                defaultValue=> sub { return '' },
            },
        });
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 getName ( session )

Returns the name of the form control.

=cut

sub getName {
    my ($class, $session) = @_;
    return WebGUI::International->new($session, "Form_Div")->get("topicName");
}


#-------------------------------------------------------------------

=head2 getValue ( [ value ] )

Does some special processing.

=cut

sub getValue {
    my $self = shift;
    return $self->get('contentCallback')->($self->get('id'));
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders an input tag of type text.

=cut

sub toHtml {
    my $self = shift;
    return '<div id="'.$self->get('id').'" name="'.$self->get("name").'"  '.$self->get("extras").'>' . $self->getValue . '</div>' ;
}

1;
#vim:ft=perl
