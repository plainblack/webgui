package WebGUI::Content::PassiveAnalytics;

use strict;
use WebGUI::AdminConsole;
use WebGUI::Exception;
use WebGUI::PassiveAnalytics::Flow;

=head1 NAME

Package WebGUI::Content::PassiveAnalytics

=head1 DESCRIPTION

Handle all requests for building and editing Passive Analytic flows.

=head1 SYNOPSIS

 use WebGUI::Content::PassiveAnalytics;
 my $output = WebGUI::Content::PassiveAnalytics::handler($session);

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
    return undef unless $session->form->get('op') eq 'passiveAnalytics';
    my $function = "www_".$session->form->get('func');
    if ($function ne "www_" && (my $sub = WebGUI::PassiveAnalytics::Flow->can($function))) {
        $output = $sub->($session);
    }
    else {
        WebGUI::Error::MethodNotFound->throw(error=>"Couldn't call non-existant method $function inside PassiveAnalytics", method=>$function);
    }
    return $output;
}

1;
