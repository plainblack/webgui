package WebGUI::Flux;

use strict;
use warnings;

=head1 NAME

Package WebGUI::Flux

=head1 DESCRIPTION

Flux Rule-based authorisation layer for WebGUI

Flux adds a dynamic behavioral layer on top of wG, giving content managers a simple and
yet immensely powerful way to add rule-based authorisation to their websites. The design
aims for a system that is flexible and extensible to developers but simple and intuitive to
content managers.

=head1 SYNOPSIS

 use WebGUI::Flux;
 
 my @allRules = WebGUI::Flux->getRules($session);
 my $singleRule = WebGUI::Flux->getRule($session, $id);

=head1 METHODS

These methods are available from this class:

=cut

my %ruleCache;    # (hash) cache of WebGUI::Flux::Rule objects

#-------------------------------------------------------------------

=head2 getRule ( session, id )

Returns a Rule. Underlying call to WebGUI::Flux::Rule->new() will throw exception if Rule not found
N.B. A simple Rule cache is used. It WILL become stale if you delete a Rule (whereas C<getRules> 
consults the db first)/

=head3 session

A reference to the current session.

=head3 id

An existing Rule's unique id.

=cut

sub getRule {
    my ( $class, $session, $fluxRuleId ) = @_;

    # Check arguments..
    if ( !defined $session || !$session->isa('WebGUI::Session') ) {
        WebGUI::Error::InvalidObject->throw(
            expected => 'WebGUI::Session',
            got      => ( ref $session ),
            error    => 'Need a session.'
        );
    }
    if ( !defined $fluxRuleId ) {
        WebGUI::Error::InvalidParam->throw(
            param => $fluxRuleId,
            error => 'Need a fluxRuleId.'
        );
    }

    # Retreive Rule from cache or db..
    if ( !exists $ruleCache{$fluxRuleId} ) {
        $ruleCache{$fluxRuleId} = WebGUI::Flux::Rule->new( $session, $fluxRuleId );
    }

    return $ruleCache{$fluxRuleId};
}

#-------------------------------------------------------------------

=head2 getRules ( )

Returns an array reference of Rules

=cut

sub getRules {
    my ($class, $session)      = @_;

    # Check arguments..
    if ( !defined $session || !$session->isa('WebGUI::Session') ) {
        WebGUI::Error::InvalidObject->throw(
            expected => 'WebGUI::Session',
            got      => ( ref $session ),
            error    => 'Need a session.'
        );
    }

    # Collect an array of Rules
    my @ruleObjects = ();
    my $rules       = $session->db->read('select fluxRuleId from fluxRule');
    while ( my ($fluxRuleId) = $rules->array ) {
        push @ruleObjects, $class->getRule($session, $fluxRuleId);
    }
    
    return \@ruleObjects;
}

1;