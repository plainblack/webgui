# Tests WebGUI::Flux::Operand::FluxRule
#
#

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../lib";
use Test::More;
use Test::Deep;
use Data::Dumper;
use Readonly;
use WebGUI::Test;    # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Flux::Rule;
use WebGUI::History;
use JSON;

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests
plan tests => 7;

#----------------------------------------------------------------------------
# put your tests here
my ( $user, $user2, $rule );
use_ok('WebGUI::Flux::Operand::History');
$user  = WebGUI::User->new( $session, 'new' );
$user2 = WebGUI::User->new( $session, 'new' );
my $userId = $user->userId;

my $historyEventId = 'test-history-event';
my $assetId        = 'test-asset-id';

{
    $rule = WebGUI::Flux::Rule->create($session);
    my $ruleId     = $rule->getId;
    my $expression = $rule->addExpression(
        {   operand1     => 'History',
            operand1Args => encode_json( { historyEventId => $historyEventId } ),
            operator     => 'IsNotEmpty',
            operand2     => 'TruthValue',
            operand2Args => encode_json( { value => 1 } ),
            name         => 'Test history event exists',
        },
    );
    ok( !$rule->evaluateFor( { user => $user, } ), q{Mr User does not have history event yet} );

    WebGUI::History->create(
        $session,
        {   historyEventId => $historyEventId,
            userId         => $userId,
            assetId        => $assetId,
        }
    );
    ok( $rule->evaluateFor( { user => $user, } ), q{Now he's in!} );

    # Try it again, with the wrong historyEventId
    $expression->update( { operand1Args => encode_json( { historyEventId => 'not this one' } ), } );
    $rule = WebGUI::Flux::Rule->new( $session, $ruleId );
    ok( !$rule->evaluateFor( { user => $user, } ), q{Wrong eventId} );

    # Try it again, with the wrong assetId
    $expression->update(
        { operand1Args => encode_json( { historyEventId => $historyEventId, assetId => 'not this one' } ), } );
    $rule = WebGUI::Flux::Rule->new( $session, $ruleId );
    ok( !$rule->evaluateFor( { user => $user, } ), q{Wrong assetId} );

    # Try it again, with the wrong user
    $expression->update( { operand1Args => encode_json( { assetId => $assetId } ), } );
    $rule = WebGUI::Flux::Rule->new( $session, $ruleId );
    ok( !$rule->evaluateFor( { user => $user2, } ), q{Wrong user} );
    ok( $rule->evaluateFor( { user => $user, } ), q{That's better} );
}

#----------------------------------------------------------------------------
# Cleanup
END {
    $user->delete()  if $user;
    $user2->delete() if $user;
    $rule->delete()  if $rule;
}
