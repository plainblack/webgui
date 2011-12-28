package WebGUI::Form::SubscriptionGroup;

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

Package WebGUI::Form::SubscriptionGroup

=head1 DESCRIPTION

Creates a hidden subscription group field.  Returns the field and a button to manage the group specified by value

=head1 SEE ALSO

This is a subclass of WebGUI::Form::Hidden.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclass for additional methods.

=cut


#-------------------------------------------------------------------

=head2 getName ( session )

Returns the human readable name of this control.

=cut

sub getName {
    my ($self, $session) = @_;
    return WebGUI::International->new($session, 'WebGUI')->get('SubscriptionGroup formName');
}

#-------------------------------------------------------------------

=head2 isDynamicCompatible ( )

A class method that returns a boolean indicating whether this control is compatible with the DynamicField control. Returns 0.

=cut

sub isDynamicCompatible {
    return 0;
}

#-------------------------------------------------------------------

=head2 toHtml ( )

A synonym for toHtmlAsHidden.

=cut

sub toHtml {
    my $self = shift;
    $self->toHtmlAsHidden;
}

#----------------------------------------------------------------

=head2 toHtmlWithWrapper ( )

Renders the form field to HTML as a table row. The row is not displayed because there is nothing to display, but it may not be left away because <input> may not be a child of <table> according to the XHTML standard.

=cut

sub toHtmlWithWrapper {
	my $self         = shift;
    my $value        = $self->fixMacros($self->fixQuotes($self->fixSpecialCharacters(scalar $self->getOriginalValue))) || '';
    if ($value) {
        my $manageButton = $self->session->icon->manage("op=editGroup;gid=".$value);
        $self->set("subtext",$manageButton . $self->get("subtext"));
        return $self->SUPER::toHtmlWithWrapper;
    }
    else {
        return $self->toHtmlAsHidden;
    }
}


1;

