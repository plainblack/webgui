package WebGUI::Form::SubscriptionGroup;

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
use base 'WebGUI::Form::Hidden';
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

=head2 definition ( [ additionalTerms ] )

See the super class for additional details.

=head3 additionalTerms

The following additional parameters have been added via this sub class.

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
			defaultValue=>$i18n->get("hidden")
			},
		profileEnabled=>{
			defaultValue=>0
			},
		});
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 toHtmlWithWrapper ( )

Renders the form field to HTML as a table row. The row is not displayed because there is nothing to display, but it may not be left away because <input> may not be a child of <table> according to the XHTML standard.

=cut

sub toHtmlWithWrapper {
	my $self         = shift;
    my $value        = $self->fixMacros($self->fixQuotes($self->fixSpecialCharacters($self->get("value")))) || '';
	
    my $manageButton = "&nbsp;";
    if($value) {
        $manageButton = $self->session->icon->manage("op=editGroup;gid=".$value);
    }
    
	if ($self->passUiLevelCheck) {
		my ($fieldClass, $rowClass, $labelClass, $hoverHelp, $subtext)  = $self->prepareWrapper;
		return '<tr'.$rowClass.'>
				<td'.$labelClass.$hoverHelp.' valign="top" style="width: 180px;"><label for="'.$self->get("id").'">'.$self->get("label").'</label></td>
				<td valign="top"'.$fieldClass.'>'.$manageButton.$self->toHtmlAsHidden."</td>
			</tr>\n";
	} else {
		return $self->toHtmlAsHidden;
	}
}


1;

