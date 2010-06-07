package WebGUI::Form::Username;

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
use WebGUI::International;

=head1 NAME

Package WebGUI::Form::Username

=head1 DESCRIPTION

Creates a text input box form field specifically for a user name.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::Text.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclass for additional methods.

=cut

#-------------------------------------------------------------------

=head2 definition ( [ additionalTerms ] )

See the super class for additional details.

=head3 additionalTerms

The following additional parameters have been added via this sub class.

=head4 maxlength

Defaults to 255. Determines the maximum number of characters allowed in this field.

=head4 size

Defaults to the setting textBoxSize or 30 if that's not set. Specifies how big of a text box to display.

=cut

#-------------------------------------------------------------------

=head2 getName ( session )

Returns the human readable name of this control.

=cut

sub getName {
    my ($self, $session) = @_;
    return WebGUI::International->new($session, 'Form_Username')->get('username');
}

#-------------------------------------------------------------------

=head2 getValue ( [ value ] )

Retrieves a value from a form GET or POST and returns it. If the value comes back as undef, this method will return the defaultValue instead.  Strip newlines/carriage returns from the value.

=head3 value

An optional value to process, instead of POST input.

=cut

sub getValue {
	my $self = shift;
    my $value = $self->SUPER::getValue(@_);
    $value =~ tr/\r\n//d;
    return $value;
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a user name field.

=cut

sub toHtml {
  my $self = shift;
  $self->session->style->setScript($self->session->url->extras('form/fieldCheck.js'),{ type=>'text/javascript' });
  $self->session->style->setScript($self->session->url->extras('yui/build/yahoo-dom-event/yahoo-dom-event.js'), {type=>'text/javascript'});
  $self->session->style->setScript($self->session->url->extras('yui/build/connection/connection-min.js'), {type => 'text/javascript'});
  $self->session->style->setScript($self->session->url->extras('yui/build/json/json-min.js'),                   {type=>'text/javascript'});
  $self->session->style->setScript($self->session->url->extras('yui/build/datasource/datasource-min.js'),       {type=>'text/javascript'});
  $self->session->style->setScript($self->session->url->extras('yui-webgui/build/i18n/i18n.js'), {type=>'text/javascript'});
  my $value = $self->fixMacros($self->fixQuotes($self->fixSpecialCharacters(scalar $self->getOriginalValue)));
  $self->set("extras", $self->get('extras') . ' onblur="new WebGUI.FieldCheck(\''. $self->get("id").'\',\'Username\',1);"');
  return '<input id="'.$self->get('id').'" type="text" name="'.$self->get("name").'" value="'.$value.'" size="'.$self->get("size").'" maxlength="'.$self->get("maxlength").'" '.$self->get("extras").' />';
}

#-------------------------------------------------------------------

=head2 www_check ($session)

www_check() is called by an Ajax call from the user registration page.

It checks whether a user name is free for registration. Returns a hash
(error => $error)
if the username is not free.

=cut

sub www_check {
  my $session = shift;
  my $input = $session->form->param('input');

  $session->http->setMimeType( 'application/json' );
  my $i18n = WebGUI::International->new($session, 'Form_Username');

  my $error = '';
  my ($existingUserId) = $session->db->quickArray("select userId from users where username=".$session->db->quote($input));
  $error = $i18n->get('username in use') if $existingUserId;

  my %checkResults = (error => $error);
  return JSON::encode_json(\%checkResults);
}

1;

