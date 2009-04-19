package WebGUI::Form::ThingFieldsList;

use strict;
use base 'WebGUI::Form::SelectList';


#----------------------------------------------------------------------------

sub www_getThingFields {
    my ( $session ) = @_;

    my $thingId = $session->form->get('thingId');
    my %fields
        = $session->db->buildHash(
            "SELECT fieldId, label FROM Thingy_fields WHERE thingId=?",
            [$thingId]
        );

    $session->http->setMimeType( 'application/json' );
    return JSON->new->encode( \%fields );
}

1;
