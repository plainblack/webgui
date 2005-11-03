package WebGUI::Form::LdapLink;

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
use base 'WebGUI::Form::Control';
use WebGUI::LDAPLink;
use WebGUI::Form::SelectList;
use WebGUI::Form::HiddenList;
use WebGUI::Grouping;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Session;
use WebGUI::URL;

=head1 NAME

Package WebGUI::Form::LdapLink

=head1 DESCRIPTION

Creates an LDAP connection chooser control.

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

=head4 name

The identifier for this field. Defaults to "ldapLinkId".

=head4 defaultValue

An LDAP link id. Defaults to "0", which is nothing.

=head4 afterEdit

A URL that will be acted upon after editing an LDAP link. 

=head4 size 
        
The number of characters tall this list should be. Defaults to '1'.
                         
=head4 multiple 
        
Boolean indicating whether the user can select multiple items from this list like a checkList. Defaults to "0".

=head4 label

A text label that will be displayed if toHtmlWithWrapper() is called. Defaults to getName().

=cut

sub definition {
	my $class = shift;
	my $definition = shift || [];
	push(@{$definition}, {
		label=>{
			defaultValue=>$class->getName()
			},
		name=>{
			defaultValue=>"ldapLinkId"
			},
		defaultValue=>{
			defaultValue=>[0]
			},
		size=>{
			defaultValue=>1
			},
		multiple=>{
			defaultValue=>0
			},
		afterEdit=>{
			defaultValue=>undef
			}
		});
	return $class->SUPER::definition($definition);
}

#-------------------------------------------------------------------

=head2 getName ()

Returns the human readable name or type of this form control.

=cut

sub getName {
        return WebGUI::International::get("LDAPLink_1075","AuthLDAP");
}

#-------------------------------------------------------------------

=head2 getValueFromPost ( )

Returns an array or a carriage return ("\n") separated scalar depending upon whether you're returning the values into an array or a scalar.

=cut

sub getValueFromPost {
        my $self = shift;
        my @data = $session{req}->param($self->{name});
        return wantarray ? @data : join("\n",@data);
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a database connection picker control.

=cut

sub toHtml {
	my $self = shift;
	return WebGUI::Form::SelectList->new(
		name=>$self->{name},
		id=>$self->{id},
		options=>WebGUI::LDAPLink::getList(),
		value=>$self->{value},
		multiple=>$self->{multiple},
		size=>$self->{size},
		extras=>$self->{extras}
		)->toHtml;
}

#-------------------------------------------------------------------

=head2 toHtmlAsHidden ( )

Creates a series of hidden fields representing the data in the list.

=cut

sub toHtmlAsHidden {
        my $self = shift;
        return WebGUI::Form::HiddenList->new(
                value=>$self->{value},
                name=>$self->{name},
                options=>WebGUI::LDAPLink::getList()
                )->toHtmlAsHidden;
}

#-------------------------------------------------------------------

=head2 toHtmlWithWrapper ( )

Renders the form field to HTML as a table row complete with labels, subtext, hoverhelp, etc. Also adds manage and edit icons next to the field if the current user is in the admins group.

=cut

sub toHtmlWithWrapper {
	my $self = shift;
	if (WebGUI::Grouping::isInGroup(3)) {
		my $subtext;
		if ($self->{afterEdit}) {
			$subtext = editIcon("op=editLDAPLink;llid=".$self->{value}.";afterEdit=".WebGUI::URL::escape($self->{afterEdit}));
		}
         	$subtext .= manageIcon("op=listLDAPLinks");
		$self->{subtext} = $subtext . $self->{subtext};
	}
	return $self->SUPER::toHtmlWithWrapper;
}



1;

