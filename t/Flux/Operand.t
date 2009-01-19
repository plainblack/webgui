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
use Test::Exception;

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;
WebGUI::Error->Trace(1);

#----------------------------------------------------------------------------
# Tests
plan tests => 7;

#----------------------------------------------------------------------------
# put your tests here

use_ok('WebGUI::Flux::Operand');
my $rule = WebGUI::Flux::Rule->create($session);

# Errors
{
    throws_ok { WebGUI::Flux::Operand->evaluateUsing() } 'WebGUI::Error::InvalidParam',
        'evaluateUsing takes exception to wrong number of args';
    throws_ok { WebGUI::Flux::Operand->evaluateUsing( 'Qbit', 'NotAHashRef' ) } 'WebGUI::Error::InvalidParam',
        'evaluateUsing takes exception to missing hash ref';
    throws_ok { WebGUI::Flux::Operand->evaluateUsing( 'Qbit', {} ) } 'WebGUI::Error::InvalidParam',
        'evaluateUsing takes exception to missing fields';
    throws_ok {
        WebGUI::Flux::Operand->evaluateUsing( 'Qbit', { rule => $rule, args => {} } )
    }
    'WebGUI::Error::Pluggable::LoadFailed', 'evaluateUsing takes exception to invalid Operand';
    throws_ok {
        WebGUI::Flux::Operand->evaluateUsing( 'TextValue', { rule => $rule, args => {} } )
    }   
    'WebGUI::Error::InvalidParam', 'evaluateUsing takes exception to missing field "value" from Operand arg list';
}

{

    # Try out evaluateUsing(), using TextValue as our guinea pig
    is( WebGUI::Flux::Operand->evaluateUsing( 'TextValue', { rule => $rule, args => { value => 'test value' } } ),
        'test value',
        'operand execute() returns a sensible value'
    );
}
