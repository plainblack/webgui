# Tests WebGUI::Flux::Modifier::DateTimeCompareToNow
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
use WebGUI::DateTime;

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests
plan tests => 3;

#----------------------------------------------------------------------------
# put your tests here

use_ok('WebGUI::Flux::Modifier');
my $rule   = WebGUI::Flux::Rule->create($session);

{
    my $dt = DateTime->new(
        year   => 2007,
        month  => 10,
        day    => 16,
        hour   => 16,
        minute => 12,
        second => 47,
        time_zone => 'Australia/Melbourne',
    );
    my $now = DateTime->now(time_zone => 'Australia/Melbourne');
    my $dur = $now->subtract_datetime($dt->set_time_zone('Australia/Melbourne'));
    is( WebGUI::Flux::Modifier->evaluateUsing(
            'DateTimeCompareToNow',
            {   rule    => $rule,
                operand => $dt,
                args    => { units => 'hours', time_zone => 'Australia/Melbourne' }
            }
        ),
        $dur->in_units('hours'),
        'compare hours'
    );
}
# Test using 'user' as timezone
# N.B. Need to test this via higher-level $rule->evaluate because it involves user object
{
    $session->user( { userId => 1 } );
    my $user = $session->user();
    
    # get the user's timezone
    my $tz = $user->profileField("timeZone");
    
    my $dt = DateTime->new(
        year   => 2007,
        month  => 10,
        day    => 16,
        hour   => 16,
        minute => 12,
        second => 47,
        time_zone => $tz,
    );
    my $dbDateTime = WebGUI::DateTime->new( $dt->epoch() )->toDatabase();
    
    my $now = DateTime->now(time_zone => $tz);
    my $dur = $now->subtract_datetime($dt->set_time_zone($tz));
    my $hours = $dur->in_units('hours');
    $rule->addExpression(
        {   operand1     => 'DateTime',
            operand1Args => qq[{"value":  "$dbDateTime"}],
            operand1Modifier => 'DateTimeCompareToNow',
            operand1ModifierArgs => qq[{ "units": "hours", "time_zone": "user" }],
            operand2     => 'TextValue',
            operand2Args => qq[{"value":  "$hours"}],
            operator     => 'IsEqualTo',
        }
    );
    ok( $rule->evaluateFor( { user => $user, } ), q{timezone can be specified as 'user'} );
}

#----------------------------------------------------------------------------
# Cleanup
END {
    $session->db->write('delete from fluxRule');
}
