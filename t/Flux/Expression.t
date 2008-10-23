# Tests CRUD operations on WebGUI::Flux::Expression
#
#

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More;
use Test::Deep;
use Exception::Class;
use Readonly;

use WebGUI::Test;    # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Text;
use WebGUI::Flux::Rule;
use Test::Exception;

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;
WebGUI::Error->Trace(1);

# Start with a clean slate
$session->db->write('delete from fluxRule');
$session->db->write('delete from fluxExpression');
$session->db->write('delete from fluxRuleUserData');

#----------------------------------------------------------------------------
# Tests

plan tests => 26;

#----------------------------------------------------------------------------
# put your tests here

use_ok('WebGUI::Flux::Expression');

#######################################################################
#
# new
#
#######################################################################

# N.B. Just test for failures here - we test successful retrieval
# later after we've successfully create()'ed em
{
    throws_ok { my $expression = WebGUI::Flux::Expression->new() } 'WebGUI::Error::InvalidParam',
        'new takes exception to not giving it a Rule';
}

# Errors with a valid Rule
{
    my $rule = WebGUI::Flux::Rule->create($session);
    throws_ok { WebGUI::Flux::Expression->new($rule) } 'WebGUI::Error::InvalidParam',
        'new takes exception to not giving it a fluxExpressionId';
    throws_ok { WebGUI::Flux::Expression->new( $rule, 'neverAGUID' ) }  'WebGUI::Error::ObjectNotFound',
        'new takes exception to not giving it an existing fluxExpressionId';
}

#######################################################################
#
# create
#
#######################################################################
# Start with a clean slate
$session->db->write('delete from fluxExpression');

{
    throws_ok { WebGUI::Flux::Expression->create() } 'WebGUI::Error::InvalidParam',
        'create takes exception to not giving it a Rule';
}
{
    my $rule = WebGUI::Flux::Rule->create($session);
    throws_ok { WebGUI::Flux::Expression->create( $rule, 'not a hash ref' ) } 'WebGUI::Error::InvalidParam',
        'create takes exception to an invalid hash ref';
    $rule->delete();
}
{
    my $rule = WebGUI::Flux::Rule->create($session);
    throws_ok { WebGUI::Flux::Expression->create( $rule, { requiredFields => 'missing' } ) }
    'WebGUI::Error::InvalidParam', 'create takes exception to missing required fields in hash ref';
    $rule->delete();
}
{

    # Create Expression
    my $rule       = WebGUI::Flux::Rule->create($session);
    my $expression = WebGUI::Flux::Expression->create(
        $rule,
        {   operand1 => 'DUMMY_OPERAND_1',
            operand2 => 'DUMMY_OPERAND_2',
            operator => 'DUMMY_OPERATOR',
        }
    );

    isa_ok( $expression, 'WebGUI::Flux::Expression', 'create returns the right kind of object' );
    my $expressionCount = $session->db->quickScalar('select count(*) from fluxExpression');
    is( $expressionCount, 1, 'only 1 Flux Expression was created' );

    # Check Expression properties
    isa_ok( $expression->rule, 'WebGUI::Flux::Rule', 'rule method returns a Rule object' );
    is( $rule->getId(),               $expression->rule->getId(), 'rule method returns OUR Rule object' );
    is( $expression->get('operand1'), 'DUMMY_OPERAND_1',          'operand1 has the value we set' );
    is( $expression->get('operand2'), 'DUMMY_OPERAND_2',          'operand2 has the value we set' );
    is( $expression->get('operator'), 'DUMMY_OPERATOR',           'operator has the value we set' );

    # Check Expression defaults
    is( $expression->get('name'),           'Undefined', 'default value for name is "Undefined"' );
    is( $expression->get('sequenceNumber'), 1,           'sequenceNumber starts at 1' );

    # Add a second Expression (to test sequenceNumber)
    my $expression2 = $rule->addExpression(
        {   operand1 => 'DUMMY_OPERAND_1',
            operator => 'DUMMY_OPERATOR',
            operand2 => 'DUMMY_OPERAND_2',
        }
    );
    is( $expression2->get('sequenceNumber'), 2, 'second sequenceNumber is 2' );

    # Add a third Expression to test that we can use our own fluxExpressionId
    my $expression3 = $rule->addExpression(
        {   operand1         => 'DUMMY_OPERAND_1',
            operator         => 'DUMMY_OPERATOR',
            operand2         => 'DUMMY_OPERAND_2',
            fluxExpressionId => 'grandmamoses',
        }
    );
    is( $expression3->getId, 'grandmamoses', 'correct fluxExpressionId' );
}

#######################################################################
#
# getId
#
#######################################################################
{
    my $rule       = WebGUI::Flux::Rule->create($session);
    my $expression = WebGUI::Flux::Expression->create(
        $rule,
        {   operand1 => 'DUMMY_OPERAND_1',
            operator => 'DUMMY_OPERATOR',
            operand2 => 'DUMMY_OPERAND_2',
        }
    );
    is( $expression->getId(), $expression->get('fluxExpressionId'), 'getId is a shortcut for ->get' );
}

#######################################################################
#
# update
#
#######################################################################
{
    my $rule       = WebGUI::Flux::Rule->create($session);
    my $expression = WebGUI::Flux::Expression->create(
        $rule,
        {   operand1 => 'DUMMY_OPERAND_1',
            operand2 => 'DUMMY_OPERAND_2',
            operator => 'DUMMY_OPERATOR',
        }
    );

    my %newValues = (
        name     => 'New Name',
        operand1 => 'DUNNY_OPERAND_1',
        operand2 => 'DUNNY_OPERAND_2',
        operator => 'DUNNY_OPERATOR',
    );
    $expression->update( \%newValues );

    cmp_deeply( $expression->get(), superhashof( \%newValues ), 'update updates the object properties cache' );

    my $clonedExpression = WebGUI::Flux::Expression->new( $rule, $expression->getId() );
    cmp_deeply( $clonedExpression, $expression, 'update persists to the db, too' );

    # N.B. update() also gets tested indirectly by create() (above)

    # Check that Rule's combined expression gets reset as a side-effect of updating an expression
    $rule->update( { combinedExpression => 'E1' } );
    is( $rule->get('combinedExpression'), 'e1', 'Set combined expression (automatically converted to lc)' );
    $expression->update( \%newValues );
    is( $rule->get('combinedExpression'), undef, 'Combined expression correctly reset by update' );
}

#######################################################################
#
# delete
#
#######################################################################
{

    # Start with a clean slate
    $session->db->write('delete from fluxExpression');

    my $rule        = WebGUI::Flux::Rule->create($session);
    my $expression1 = WebGUI::Flux::Expression->create(
        $rule,
        {   operand1 => 'DUMMY_OPERAND_1',
            operand2 => 'DUMMY_OPERAND_2',
            operator => 'DUMMY_OPERATOR',
        }
    );
    my $expression2 = WebGUI::Flux::Expression->create(
        $rule,
        {   operand1 => 'DUMMY_OPERAND_1',
            operand2 => 'DUMMY_OPERAND_2',
            operator => 'DUMMY_OPERATOR',
        }
    );
    my $expressionCount = $session->db->quickScalar('select count(*) from fluxExpression');
    is( $expressionCount, 2, '2 Expressions to delete' );

    $expression1->delete();
    is( $session->db->quickScalar('select count(*) from fluxExpression'), 1, 'one down, one to go' );
    $expression2->delete();
    is( $session->db->quickScalar('select count(*) from fluxExpression'), 0, 'all gone' );
}

END {
    $session->db->write('delete from fluxRule');
    $session->db->write('delete from fluxExpression');
}
