package WebGUI::Flux::Admin;

use strict;
use Class::InsideOut qw{ :std };
use WebGUI::Flux;
use Readonly;

=head1 NAME

Package WebGUI::Flux::Admin

=head1 DESCRIPTION

All the admin stuff that didn't fit elsewhere.
This module will remain mostly empty until the Flux GUI is implemented. 

=head1 SYNOPSIS

 use WebGUI::Flux::Admin;

 my $admin = WebGUI::Flux::Admin->new($session);

=head1 METHODS

These subroutines are available from this package:

=cut

readonly session => my %session;

#-------------------------------------------------------------------

=head2 new ( session )

Constructor. 

=head3 session

A reference to the current session.

=cut

sub new {
    my ( $class, $session ) = @_;
    unless ( defined $session && $session->isa("WebGUI::Session") ) {
        WebGUI::Error::InvalidObject->throw(
            expected => "WebGUI::Session",
            got      => ( ref $session ),
            error    => "Need a session."
        );
    }
    my $self = register $class;
    my $id   = id $self;
    $session{$id} = $session;
    return $self;
}

#-------------------------------------------------------------------

=head2 session () 

Returns a reference to the current session.

=cut

#-------------------------------------------------------------------

=head2 www_graph () 

Display a simple page showing the Flux Graph. This is currently just a proof-of-concept. 
You can view this at: http://dev.localhost.localdomain/?flux=admin&method=graph or by running
 > prove Flux.t
and then viewing /uploads/FluxGraph.png in an image viewer.

=cut

sub www_graph {
    my $self = shift;

    WebGUI::Flux->generateGraph( $self->session );

    # Return a simple hard-coded page displaying the Flux Graph.
    return qq{<h1>Behold the mighty Flux Graph</h1><img src="/uploads/FluxGraph.png">};
}

1;
