package WebGUI::Content::Flux;

use strict;

=head1 NAME

Package WebGUI::Content::Flux

=head1 DESCRIPTION

A content handler for Flux

=head1 SYNOPSIS

 use WebGUI::Content::Flux;
 my $output = WebGUI::Content::Flux::handler($session);

=head1 SUBROUTINES

These subroutines are available from this package:

=cut

#-------------------------------------------------------------------

=head2 handler ( session ) 

The content handler for this package.

=cut

sub handler {
    my ($session) = @_;
    my $output    = undef;
    
    # Get the requested action..
    my $flux      = $session->form->get('flux');
    return $output 
        if !$flux;
    
    # Construct the www_ method from the action..
    my $method = 'www_' . ( $flux || 'admin' );
    
    # Call the method on the Flux Admin object
    my $admin = WebGUI::Flux::Admin->new($session);
    if ( $admin->can($method) ) {
        $output = $admin->$method();
    }
    else {
        WebGUI::Error::MethodNotFound->throw(
            error  => "Couldn't call non-existant method $method",
            method => $method
        );
    }
    return $output;
}

1;

