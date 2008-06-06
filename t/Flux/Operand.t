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

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests
plan tests => 11;

#----------------------------------------------------------------------------
# put your tests here

use_ok('WebGUI::Flux::Operand');
my $dummy_user_object = 'ignored';
my $dummy_rule_object = 'ignored';

{
    eval { WebGUI::Flux::Operand->executeUsing(); };
    my $e = Exception::Class->caught();
    isa_ok( $e, 'WebGUI::Error::InvalidParamCount', 'executeUsing takes exception to wrong number of args' );
    cmp_deeply(
        $e,
        methods(
            expected => 3,
            got      => 1,
        ),
        'compareUsing takes exception to wrong number of args',
    );
}
{
    eval { WebGUI::Flux::Operand->executeUsing( 'Qbit', 'NotAHashRef' ); };
    my $e = Exception::Class->caught();
    isa_ok( $e, 'WebGUI::Error::InvalidNamedParamHashRef', 'executeUsing takes exception to missing hash ref' );
    cmp_deeply(
        $e,
        methods(
            param => 'NotAHashRef',
        ),
        'executeUsing takes exception to missing hash ref',
    );
}
{
    eval { WebGUI::Flux::Operand->executeUsing( 'Qbit', {} ); };
    my $e = Exception::Class->caught();
    isa_ok( $e, 'WebGUI::Error::NamedParamMissing', 'executeUsing takes exception to missing fields' );
}
{
    eval {
        WebGUI::Flux::Operand->executeUsing( 'Qbit', { user => $dummy_user_object, rule => $dummy_rule_object, args => {}} );
    };
    my $e = Exception::Class->caught();
    isa_ok( $e, 'WebGUI::Error::Pluggable::LoadFailed', 'executeUsing takes exception to invalid Operand' );
    cmp_deeply(
        $e,
        methods( error => re(qr/^Could not load WebGUI::Flux::Operand::Qbit/), ),
        'executeUsing takes exception to invalid Operand',
    );
}
{
    eval {
        WebGUI::Flux::Operand->executeUsing( 'TextValue',
            { user => $dummy_user_object, rule => $dummy_rule_object, args => {} } );
    };
    my $e = Exception::Class->caught();

    # N.B. Throws an exception b/c TextValue requires 'value' field in its args list
    isa_ok( $e, 'WebGUI::Error::InvalidParam',
        'executeUsing takes exception to missing field from Operand arg list' );
    cmp_deeply(
        $e,
        methods( error => 'Missing required Operand arg.', ),
        'executeUsing takes exception to missing field from Operand arg list',
    );
}

{

    # Try out executeUsing(), using TextValue as our guinea pig
    is( WebGUI::Flux::Operand->executeUsing(
            'TextValue',
            { user => $dummy_user_object, rule => $dummy_rule_object, args => { value => 'test value' } }
        ),
        'test value',
        'operand execute() returns a sensible value'
    );
}

#----------------------------------------------------------------------------
# Cleanup
END {

}
