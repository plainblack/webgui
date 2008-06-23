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
    my $output = undef;
    my $flux = $session->form->get("flux");
    return $output unless ($flux);
    my $function = "www_".$flux;
    if ($function ne "www_" && (my $sub = __PACKAGE__->can($function))) {
        $output = $sub->($session);
    }
    else {
        WebGUI::Error::MethodNotFound->throw(error=>"Couldn't call non-existant method $function", method=>$function);
    }
    return $output;
}

#-------------------------------------------------------------------

=head2 www_admin ()

Hand off to admin processor.

=cut

sub www_admin {
    my $session = shift;
    my $output = undef;
    my $method = "www_". ( $session->form->get("method") || "editSettings");
    my $admin = WebGUI::Flux::Admin->new($session);
    if ($admin->can($method)) {
        $output = $admin->$method();
    }
    else {
        WebGUI::Error::MethodNotFound->throw(error=>"Couldn't call non-existant method $method", method=>$method);
    }
    return $output;
}

1;

