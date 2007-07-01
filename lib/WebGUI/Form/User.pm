package WebGUI::Form::User;

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
use base 'WebGUI::Form::Control';
use WebGUI::User;
use WebGUI::Form::Button;
use WebGUI::Form::Hidden;
use WebGUI::Form::Text;

=head1 NAME

Package WebGUI::Form::User

=head1 DESCRIPTION

Creates a user selector field.

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

The name of the field. Defaults to "userId".

=head4 label

Defaults to "User".

=head4 readOnly

Defaults to 0.  Use for displaying a read-only user field.

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift || [];
	my $i18n = WebGUI::International->new($session, "WebGUI");
	push(@{$definition}, {
		formName=>{
			defaultValue=>$i18n->get("user"),
			},
		label=>{
			defaultValue=>$i18n->get("user"),
			},
		name=>{
			defaultValue=>"userId",
			},
		readOnly=>{
			defaultValue=>0,
			},
        dbDataType  => {
            defaultValue    => "VARCHAR(22) BINARY",
        },
		});
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a user selector.

=cut

sub toHtml {
	my $self = shift;
        my $user = WebGUI::User->new($self->session, $self->get("value"));
	my $manage = undef;
        if ($self->session->user->isInGroup(3)) {
                 $manage = " ".$self->session->icon->manage('op=listUsers');
        }
        return WebGUI::Form::Hidden->new($self->session,
                        name=>$self->get("name"),
                        extras=>$self->get("extras"),
                        value=>$user->userId,
			id=>$self->get("id"),
                        )->toHtml
                .WebGUI::Form::Text->new($self->session,
                        name=>$self->get("name")."_display",
                        extras=>' readonly="1" ',
                        value=>$user->username,
			id=>$self->get('id')."_display"
                        )->toHtml
                .($self->get('readOnly')?'':WebGUI::Form::Button->new($self->session,
                        value=>"...",
                        extras=>'onclick="window.open(\''.$self->session->url->page("op=formUsers;formId=".$self->get('id')).'\',\'userPicker\',\'toolbar=no, location=no, status=no, directories=no, width=400, height=400, scrollbars=yes\');"'
                        )->toHtml).$manage;
}

1;

