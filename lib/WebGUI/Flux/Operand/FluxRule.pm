package WebGUI::Flux::Operand::FluxRule;
use strict;
use warnings;
use WebGUI::Flux::Rule;

use base 'WebGUI::Flux::Operand';

my $MAX_DEPTH      = 1000;
my $_depth_counter = 0;

=head1 NAME

Package WebGUI::Flux::Operand::TextValue

=head1 DESCRIPTION

The boolean status of another Flux Rule

See WebGUI::Flux::Operand base class for more information.

=cut

#-------------------------------------------------------------------

sub execute {
    my ($arg_ref) = @_;

    # Assemble the ingredients..
    my $thisRule            = $arg_ref->{rule};
    my $requestedFluxRuleId = $arg_ref->{args}{fluxRuleId};

    # Immediately return the known result if the requested Rule has already been resolved
    my $resolvedRuleCache_ref = $thisRule->resolvedRuleCache();
    if ( exists $resolvedRuleCache_ref->{$requestedFluxRuleId} ) {
        return $resolvedRuleCache_ref->{$requestedFluxRuleId};
    }

    # If the requested Rule is already in the unresolved cache we have an infinite loop
    my $unresolvedRuleCache_ref = $thisRule->unresolvedRuleCache();
    if ( exists $unresolvedRuleCache_ref->{$requestedFluxRuleId} ) {
        WebGUI::Error::Flux::CircularRuleLoopDetected->throw(
            error            => 'Circular Rule loop detected.',
            sourceFluxRuleId => $thisRule->getId(),
            targetFluxRuleId => $requestedFluxRuleId,
            depth            => $_depth_counter,
        );
    }

    # Just in case..
    if ( $_depth_counter > $MAX_DEPTH ) {
        WebGUI::Error::Flux::CircularRuleLoopDetected->throw(
            error            => 'MAX_DEPTH exceeded. Do you have a circular Rule loop?',
            sourceFluxRuleId => $thisRule->getId(),
            targetFluxRuleId => $requestedFluxRuleId,
            depth            => $_depth_counter,
        );
    }

    # No infinite loops detected, ok to proceed..

    # Add the requested Rule to the unresolved cache..
    $unresolvedRuleCache_ref->{$requestedFluxRuleId} = $requestedFluxRuleId;

    # Instantiate the requested Rule and share our resolved/unresolved caches with it
    my $requestedRule = WebGUI::Flux::Rule->new( $thisRule->session(), $requestedFluxRuleId );
    $requestedRule->resolvedRuleCache($resolvedRuleCache_ref);
    $requestedRule->unresolvedRuleCache($unresolvedRuleCache_ref);

    $_depth_counter++;
    my $was_successful = $requestedRule->evaluateFor( $thisRule->evaluatingFor(), { indirect => 1, } );

    # Requested Rule is now resolved..
    delete $unresolvedRuleCache_ref->{$requestedFluxRuleId};          # so remove it from unresolved cache
    $resolvedRuleCache_ref->{$requestedFluxRuleId} = $was_successful; # .. and add to resolved cache

    return $was_successful;
}

#-------------------------------------------------------------------

=head3 getArgs

This Operand requies the following arguments

=head4 value

The simple string to be returned

=cut

sub getArgs {
    return { fluxRuleId => { type => 'fluxRuleId' } };
}

1;
