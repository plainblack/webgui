# Tests the WebGUI::Flux::Modifier base class
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
use DateTime;
use WebGUI::Flux::Rule;

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests
plan tests => 12;

#----------------------------------------------------------------------------
# put your tests here

use_ok('WebGUI::Flux::Modifier');
my $rule = WebGUI::Flux::Rule->create($session);

{
    eval { WebGUI::Flux::Modifier->evaluateUsing(); };
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
    eval { WebGUI::Flux::Modifier->evaluateUsing( 'Qbit', 'NotAHashRef' ); };
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
    eval { WebGUI::Flux::Modifier->evaluateUsing( 'Qbit', {} ); };
    my $e = Exception::Class->caught();
    isa_ok( $e, 'WebGUI::Error::NamedParamMissing', 'evaluateUsing takes exception to missing fields' );
}
{
    eval {
        WebGUI::Flux::Modifier->evaluateUsing( 'Qbit',
            { rule => $rule, operand => {}, args => {}} );
    };
    my $e = Exception::Class->caught();
    isa_ok( $e, 'WebGUI::Error::Pluggable::LoadFailed', 'evaluateUsing takes exception to invalid Modifier' );
    cmp_deeply(
        $e,
        methods( error => re(qr/^Could not load WebGUI::Flux::Modifier::Qbit/), ),
        'evaluateUsing takes exception to invalid Modifier',
    );
}
{
    eval {
        WebGUI::Flux::Modifier->evaluateUsing( 'DateTimeFormat',
            { rule => $rule, operand => {}, args => {}} );
    };
    my $e = Exception::Class->caught();

    # N.B. Throws an exception b/c DateTimeFormat requires 'value' field in its args list
    isa_ok(
        $e, 'WebGUI::Error::InvalidParam',
        'evaluateUsing takes exception to missing field from Modifier arg list'
    );
    cmp_deeply(
        $e,
        methods( error => 'Missing required Modifier arg.', ),
        'evaluateUsing takes exception to missing field from Modifier arg list',
    );
}

{

    # Try out evaluateUsing(), using DateTimeFormat as our guinea pig
    
    # First check that an empty string is returned if the operand is undefined
    is( WebGUI::Flux::Modifier->evaluateUsing(
            'DateTimeFormat',
            {   rule    => $rule,
                operand => undef,
                args    => { pattern => 'DUMMY', time_zone => 'DUMMY' }
            }
        ),
        '',
        'Undefined operand returns empty string'
    );

    my $dt = DateTime->new(
        year   => 1984,
        month  => 10,
        day    => 16,
        hour   => 16,
        minute => 12,
        second => 47,
        time_zone => 'Australia/Melbourne',
        
    );
    is( WebGUI::Flux::Modifier->evaluateUsing(
            'DateTimeFormat',
            {   rule    => $rule,
                operand => $dt,
                args    => { pattern => '%x %X', time_zone => 'Australia/Melbourne' }
            }
        ),
        'Oct 16, 1984 4:12:47 PM',
        'modifier execute() returns a sensible value'
    );
}

#----------------------------------------------------------------------------
# Cleanup
END {

}
