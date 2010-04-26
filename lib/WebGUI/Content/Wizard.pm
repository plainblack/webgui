package WebGUI::Content::Wizard;

sub handler {
    my ( $session ) = @_;

    if ( $session->form->get('op') eq 'wizard' && $session->form->get('wizard_class') ) {
        my $class = $session->form->get('wizard_class');
        WebGUI::Pluggable->load($class);
        if ( $class->isa( 'WebGUI::Wizard' ) ) {
            my $wizard  = $class->new( $session );
            return $wizard->dispatch;
        }
        else {
            return "Sminternal Smerver Smerror";
        }
    }
}

1;
