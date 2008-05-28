package WebGUI::Flux::Rule;

use strict;
use warnings;

use Class::InsideOut qw{ :std };

=head1 NAME

Package WebGUI::Flux::Rule

=head1 DESCRIPTION

Rule to be used as part of Flux rule-based authorisation layer for WebGUI 

Flux Rules are comprised of one or more Boolean Expressions. Rules and Expressions are
manipulated by content managers through a simple graphical interface. The power of Flux
lies in the fact that Rules can be based on user-specific, date-specific and/or Wobject-
specific information. Rules can also depend on other Rules, meaning that we end up with a
Flux Graph of interconnected Rules. Workflow triggers are built-in, and Flux is designed to
be modular with many plug-in points, making the system truly extensible.

=head1 SYNOPSIS

 use WebGUI::Flux::Rule;
 
 my $rule = WebGUI::Flux::Rule->new(
    $session,
    {   name          => 'My Rule',
        created_by    => $session->user(),
        sticky_access => 1,
    }
 );

=head1 METHODS

These methods are available from this class:

=cut

# InsideOut object properties and accessors
readonly session => my %session;

#-------------------------------------------------------------------

=head2 new ( session )

Constructor.

=head3 session

A reference to the current session.

=cut

sub new {
    my ( $class, $session ) = @_;
    if ( !defined $session || !$session->isa('WebGUI::Session') ) {
        WebGUI::Error::InvalidObject->throw(

            expected => 'WebGUI::Session',
            got      => ( ref $session ),
            error    => 'Need a Session.'
        );
    }
    
    my $self = register $class;
    $session{ id $self } = $session;
    return $self;
}

1;

