package WebGUI::Flux::Operand::FluxRule;
use strict;
use WebGUI::Flux::Rule;
use Readonly;

use base 'WebGUI::Flux::Operand';

=head1 NAME

Package WebGUI::Flux::Operand::TextValue

=head1 DESCRIPTION

The boolean status of another Flux Rule

See WebGUI::Flux::Operand base class for more information.

=cut

#-------------------------------------------------------------------

=head2 evaluate

See WebGUI::Flux::Operand base class for more information.

=cut

sub evaluate {
    my ($self) = @_;

    # Assemble the ingredients..
    my $thisRule            = $self->rule();
    my $requestedFluxRuleId = $self->args()->{fluxRuleId};
        
    # Immediately return the known result if the requested Rule has already been resolved
    if ($thisRule->hasResolvedRuleCached($requestedFluxRuleId)) {
        return $thisRule->getResolvedRuleResult($requestedFluxRuleId);
    }

    # If the requested Rule is already in the unresolved cache we have an infinite loop
    if ( $thisRule->hasUnresolvedRuleCached($requestedFluxRuleId) ) {
        WebGUI::Error::Flux::CircularRuleLoopDetected->throw(
            error            => 'Circular Rule loop detected.',
            sourceFluxRuleId => $thisRule->getId(),
            targetFluxRuleId => $requestedFluxRuleId,
        );
    }

    # No infinite loops detected, ok to proceed..

    # Add the requested Rule to the unresolved cache..
    $thisRule->cacheRuleAsUnresolved($requestedFluxRuleId);

    # Instantiate the requested Rule and init its resolved and unresolved rule caches from thisRule
    my $requestedRule = WebGUI::Flux::Rule->new( $thisRule->session(), $requestedFluxRuleId );
    $requestedRule->initCachesFrom($thisRule);

    my $was_successful = $requestedRule->evaluateFor(
        { user => $thisRule->evaluatingForUser(), access => 0, recursive => 1, assetId => $thisRule->evaluatingForAssetId() } );

    # Requested Rule is now resolved..
    $thisRule->cacheRuleAsResolved($requestedFluxRuleId, $was_successful);

    return $was_successful;
}

#-------------------------------------------------------------------

=head2 definition

See WebGUI::Flux::Operand base class for more information.

=cut

sub definition {
    return { args => { fluxRuleId => 1 } };
}

1;
