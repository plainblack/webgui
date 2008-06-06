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

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests
plan tests => 11;

#----------------------------------------------------------------------------
# put your tests here

use_ok('WebGUI::Flux::Modifier');
my $dummy_user_object = 'ignored';
my $dummy_rule_object = 'ignored';

{
    eval { WebGUI::Flux::Modifier->applyUsing(); };
    my $e = Exception::Class->caught();
    isa_ok( $e, 'WebGUI::Error::InvalidParamCount', 'applyUsing takes exception to wrong number of args' );
    cmp_deeply(
        $e,
        methods(
            expected => 3,
            got      => 1,
        ),
        'applyUsing takes exception to wrong number of args',
    );
}
{
    eval { WebGUI::Flux::Modifier->applyUsing( 'Qbit', 'NotAHashRef' ); };
    my $e = Exception::Class->caught();
    isa_ok( $e, 'WebGUI::Error::InvalidNamedParamHashRef', 'applyUsing takes exception to missing hash ref' );
    cmp_deeply(
        $e,
        methods(
            param => 'NotAHashRef',
        ),
        'applyUsing takes exception to missing hash ref',
    );
}
{
    eval { WebGUI::Flux::Modifier->applyUsing( 'Qbit', {} ); };
    my $e = Exception::Class->caught();
    isa_ok( $e, 'WebGUI::Error::NamedParamMissing', 'applyUsing takes exception to missing fields' );
}
{
    eval {
        WebGUI::Flux::Modifier->applyUsing( 'Qbit',
            { user => $dummy_user_object, rule => $dummy_rule_object, operand => 0, args => {}, } );
    };
    my $e = Exception::Class->caught();
    isa_ok( $e, 'WebGUI::Error::Pluggable::LoadFailed', 'applyUsing takes exception to invalid Modifier' );
    cmp_deeply(
        $e,
        methods( error => re(qr/^Could not load WebGUI::Flux::Modifier::Qbit/), ),
        'applyUsing takes exception to invalid Modifier',
    );
}
{
    eval {
        WebGUI::Flux::Modifier->applyUsing( 'DateTimeFormat',
            { user => $dummy_user_object, rule => $dummy_rule_object, operand => 0, args => {}, } );
    };
    my $e = Exception::Class->caught();

    # N.B. Throws an exception b/c DateTimeFormat requires 'value' field in its args list
    isa_ok(
        $e, 'WebGUI::Error::InvalidParam',
        'applyUsing takes exception to missing field from Modifier arg list'
    );
    cmp_deeply(
        $e,
        methods( error => 'Missing required Modifier arg.', ),
        'applyUsing takes exception to missing field from Modifier arg list',
    );
}

{

    # Try out applyUsing(), using DateTimeFormat as our guinea pig
    my $dt = DateTime->new(
        year   => 1984,
        month  => 10,
        day    => 16,
        hour   => 16,
        minute => 12,
        second => 47,
        time_zone => 'Australia/Melbourne',
        
    );
    is( WebGUI::Flux::Modifier->applyUsing(
            'DateTimeFormat',
            {   user    => $dummy_user_object,
                rule    => $dummy_rule_object,
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
