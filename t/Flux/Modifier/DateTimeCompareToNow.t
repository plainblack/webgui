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
use DateTime;
use DateTime::Duration;

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests
plan tests => 41;

#----------------------------------------------------------------------------
# put your tests here

use_ok('WebGUI::Flux::Modifier');
my $rule = WebGUI::Flux::Rule->create($session);

{
    # Check the basics comparison
    foreach my $unit qw(nanoseconds seconds minutes hours days weeks months years) {
        my $now = DateTime->now( time_zone => 'Australia/Melbourne' );
        is( WebGUI::Flux::Modifier->evaluateUsing(
                'DateTimeCompareToNow',
                {   rule    => $rule,
                    operand => $now,
                    args    => { units => $unit, time_zone => 'Australia/Melbourne', duration => 0 }
                }
            ),
            0,
            "now == now (in $unit)"
        );

        is(
            WebGUI::Flux::Modifier->evaluateUsing(
                'DateTimeCompareToNow',
                {   rule    => $rule,
                    operand => $now->clone->add( $unit => 1 ),
                    args    => { units => $unit, time_zone => 'Australia/Melbourne', duration => 0 }
                }
            ),
            1,
            "now + 1 $unit > now"
        );
        
        is(
            WebGUI::Flux::Modifier->evaluateUsing(
                'DateTimeCompareToNow',
                {   rule    => $rule,
                    operand => $now,
                    args    => { units => $unit, time_zone => 'Australia/Melbourne', duration => 1 }
                }
            ),
            1,
            "..same but using duration to add 1 $unit to dt"
        );
        
        is(
            WebGUI::Flux::Modifier->evaluateUsing(
                'DateTimeCompareToNow',
                {   rule    => $rule,
                    operand => $now->clone->add( $unit => -1 ),
                    args    => { units => $unit, time_zone => 'Australia/Melbourne', duration => 0 }
                }
            ),
            -1,
            "now - 1 $unit < now"
        );
        
        is(
            WebGUI::Flux::Modifier->evaluateUsing(
                'DateTimeCompareToNow',
                {   rule    => $rule,
                    operand => $now,
                    args    => { units => $unit, time_zone => 'Australia/Melbourne', duration => -1 }
                }
            ),
            -1,
            "..same but using duration to subtract 1 $unit from dt"
        );
    }
}

# TODO: I'm not so sure of an easy way to test the timezone functionality,
# unless we can cause the call in  DateTimeCompareToNow to DateTime->now() to return a mock value and then
# construct a couple of comparisons that return different results in different timezones.

## Test using 'user' as timezone
## N.B. Need to test this via higher-level $rule->evaluate because it involves user object
#{
#    $session->user( { userId => 1 } );
#    my $user = $session->user();
#
#    $user->profileField("timeZone", 'Australia/Melbourne');
#    
#    my $dbDateTime = $now->clone->set_time_zone('UTC')->toDatabase();
#
##    my $now   = DateTime->now( time_zone => $tz );
##    my $dur   = $now->subtract_datetime( $dt->set_time_zone($tz) );
##    my $hours = $dur->in_units('hours');
#    $rule->addExpression(
#        {   operand1             => 'DateTime',
#            operand1Args         => encode_json({value => $dbDateTime}),
#            operand1Modifier     => 'DateTimeCompareToNow',
#            operand1ModifierArgs => encode_json({units => 'hours', time_zone => 'user', duration => 0 }),
#            operator             => 'IsEqualTo',
#            operand2             => 'TextValue',
#            operand2Args         => encode_json({value => $hours}),
#        }
#    );
#    ok( $rule->evaluateFor( { user => $user, } ), q{timezone can be specified as 'user'} );
#}

#----------------------------------------------------------------------------
# Cleanup
END {
    $session->db->write('delete from fluxRule');
}
