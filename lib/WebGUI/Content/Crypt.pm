package WebGUI::Content::Crypt;

use strict;
use WebGUI::AdminConsole;
use WebGUI::Exception;
use WebGUI::Crypt::Admin;

=head1 NAME

Package WebGUI::Content::Crypt

=head1 DESCRIPTION

Handle all requests for Crypt admin.

=head1 SYNOPSIS

 use WebGUI::Content::Crypt;
 my $output = WebGUI::Content::Crypt::handler($session);

=head1 SUBROUTINES

These subroutines are available from this package:

=cut

#-------------------------------------------------------------------

=head2 handler ( session ) 

The content handler for this package.

=cut

sub handler {
    my ($session) = @_;
    my $output = undef;
    return undef unless $session->form->get('op') eq 'crypt';
    my $function = "www_" . $session->form->get('func');
    
    # default to www_providers
    $function = $function eq 'www_' ? 'www_providers' : $function;
    
    if ( my $sub = WebGUI::Crypt::Admin->can($function) ) {
        $output = $sub->($session);
    }
    else {
        WebGUI::Error::MethodNotFound->throw(
            error  => "Couldn't call non-existant method $function inside Crypt",
            method => $function
        );
    }
    return $output;
}

1;
