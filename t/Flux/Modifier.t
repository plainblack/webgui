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
use Test::Exception;

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests
plan tests => 8;
WebGUI::Error->Trace(1);

#----------------------------------------------------------------------------
# put your tests here

use_ok('WebGUI::Flux::Modifier');
my $rule = WebGUI::Flux::Rule->create($session);

# Errors
{
    throws_ok { WebGUI::Flux::Modifier->evaluateUsing() } 'WebGUI::Error::InvalidParam',
        'evaluateUsing takes exception to wrong number of args';
    throws_ok { WebGUI::Flux::Modifier->evaluateUsing( 'Qbit', 'NotAHashRef' ) } 'WebGUI::Error::InvalidParam',
        'evaluateUsing takes exception to missing hash ref';
    throws_ok { WebGUI::Flux::Modifier->evaluateUsing( 'Qbit', {} ) } 'WebGUI::Error::InvalidParam',
        'evaluateUsing takes exception to missing fields';
    throws_ok {
        WebGUI::Flux::Modifier->evaluateUsing( 'Qbit', { rule => $rule, operand => {}, args => {} } );
    }
    'WebGUI::Error::Pluggable::LoadFailed', 'evaluateUsing takes exception to invalid Modifier';
    throws_ok {
        WebGUI::Flux::Modifier->evaluateUsing( 'DateTimeFormat', { rule => $rule, operand => {}, args => {} } );
    }
    'WebGUI::Error::InvalidParam', 'evaluateUsing takes exception to missing field "value" from Modifier arg list';

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
        year      => 1984,
        month     => 10,
        day       => 16,
        hour      => 16,
        minute    => 12,
        second    => 47,
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
