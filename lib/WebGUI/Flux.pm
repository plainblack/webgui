package WebGUI::Flux;

use strict;
use warnings;

use Class::InsideOut qw{ :std };

=head1 NAME

Package WebGUI::Flux

=head1 DESCRIPTION

Rule-based authorisation layer for WebGUI

Flux adds a dynamic behavioral layer on top of wG, giving content managers a simple and
yet immensely powerful way to add rule-based authorisation to their websites. The design
aims for a system that is flexible and extensible to developers but simple and intuitive to
content managers.

=head1 SYNOPSIS

 use WebGUI::Flux;
 
 my @rules = WebGUI::Flux->get_rules();

=head1 METHODS

These methods are available from this class:

=cut

# InsideOut object properties and accessors
readonly session => my %session;
my $rule_count = 0;
my @rules;

#-------------------------------------------------------------------

=head2 count_rules ( session )

Return the number of defined Rules

=head3 session

A reference to the current session.

=cut

sub count_rules {
    my ( $class, $session ) = @_;
    if ( !defined $session || !$session->isa('WebGUI::Session') ) {
        WebGUI::Error::InvalidObject->throw(

            expected => 'WebGUI::Session',
            got      => ( ref $session ),
            error    => 'Need a Session.'
        );
    }
    return $rule_count;
}

#-------------------------------------------------------------------

=head2 get_rules ( )

Returns all defined Rules

=cut

sub get_rules {
     my ( $class, $session ) = @_;
     if ( !defined $session || !$session->isa('WebGUI::Session') ) {
        WebGUI::Error::InvalidObject->throw(

            expected => 'WebGUI::Session',
            got      => ( ref $session ),
            error    => 'Need a Session.'
        );
    }
    return \@rules;
}

1;

