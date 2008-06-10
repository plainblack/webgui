# Tests the WebGUI::Flux::Operand base class
#
#

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More;
use Test::Deep;
use Data::Dumper;
use Readonly;
use WebGUI::Test;    # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Flux::Rule;

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests
plan tests => 11;

#----------------------------------------------------------------------------
# put your tests here

use_ok('WebGUI::Flux::Operand');
my $rule = WebGUI::Flux::Rule->create($session);

{
    eval { WebGUI::Flux::Operand->evaluateUsing(); };
    my $e = Exception::Class->caught();
    isa_ok( $e, 'WebGUI::Error::InvalidParamCount', 'evaluateUsing takes exception to wrong number of args' );
    cmp_deeply(
        $e,
        methods(
            expected => 3,
            got      => 1,
        ),
        'evaluateUsing takes exception to wrong number of args',
    );
}
{
    eval { WebGUI::Flux::Operand->evaluateUsing( 'Qbit', 'NotAHashRef' ); };
    my $e = Exception::Class->caught();
    isa_ok( $e, 'WebGUI::Error::InvalidNamedParamHashRef', 'evaluateUsing takes exception to missing hash ref' );
    cmp_deeply(
        $e,
        methods(
            param => 'NotAHashRef',
        ),
        'evaluateUsing takes exception to missing hash ref',
    );
}
{
    eval { WebGUI::Flux::Operand->evaluateUsing( 'Qbit', {} ); };
    my $e = Exception::Class->caught();
    isa_ok( $e, 'WebGUI::Error::NamedParamMissing', 'evaluateUsing takes exception to missing fields' );
}
{
    eval {
        WebGUI::Flux::Operand->evaluateUsing( 'Qbit', { rule => $rule, args => {}} );
    };
    my $e = Exception::Class->caught();
    isa_ok( $e, 'WebGUI::Error::Pluggable::LoadFailed', 'evaluateUsing takes exception to invalid Operand' );
    cmp_deeply(
        $e,
        methods( error => re(qr/^Could not load WebGUI::Flux::Operand::Qbit/), ),
        'evaluateUsing takes exception to invalid Operand',
    );
}
{
    eval {
        WebGUI::Flux::Operand->evaluateUsing( 'TextValue',
            { rule => $rule, args => {} } );
    };
    my $e = Exception::Class->caught();

    # N.B. Throws an exception b/c TextValue requires 'value' field in its args list
    isa_ok( $e, 'WebGUI::Error::InvalidParam',
        'evaluateUsing takes exception to missing field from Operand arg list' );
    cmp_deeply(
        $e,
        methods( error => 'Missing required Operand arg.', ),
        'evaluateUsing takes exception to missing field from Operand arg list',
    );
}

{

    # Try out evaluateUsing(), using TextValue as our guinea pig
    is( WebGUI::Flux::Operand->evaluateUsing(
            'TextValue',
            { rule => $rule, args => { value => 'test value' } }
        ),
        'test value',
        'operand execute() returns a sensible value'
    );
}

#----------------------------------------------------------------------------
# Cleanup
END {

}
