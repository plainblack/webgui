package WebGUI::Content::FilePump;

use strict;
use WebGUI::AdminConsole;
use WebGUI::Exception;
use WebGUI::FilePump::Admin;

=head1 NAME

Package WebGUI::Content::FilePump

=head1 DESCRIPTION

Handle all requests for building and editing FilePump bundles

=head1 SYNOPSIS

 use WebGUI::Content::FilePump;
 my $output = WebGUI::Content::FilePump::handler($session);

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
    return undef unless $session->form->get('op') eq 'filePump';
    my $func    = $session->form->get( 'func' )
                ? 'www_' . $session->form->get( 'func' )
                : 'www_manage'
                ;
    if ($func ne "www_" && (my $sub = WebGUI::FilePump::Admin->can($func))) {
        $output = $sub->($session);
    }
    else {
        WebGUI::Error::MethodNotFound->throw(error=>"Couldn't call non-existant function $func inside FilePump", method=>$func);
    }
    return $output;
}

1;
