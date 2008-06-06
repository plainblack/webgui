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

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests
plan tests => 3;

#----------------------------------------------------------------------------
# put your tests here

use_ok('WebGUI::Flux::Modifier');
my $dummy_user_object = 'ignored';
my $dummy_rule_object = 'ignored';

# Not much to test since WebGUI::Flux::Modifier does all the heavy lifting (and that's tested in Modifier.t)
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
    my $now = DateTime->now(time_zone => 'UTC');
    my $dur = $now->subtract_datetime($dt->set_time_zone('UTC')); # Math should be done all in UTC
    is( WebGUI::Flux::Modifier->applyUsing(
            'DateTimeCompareToNow',
            {   user    => $dummy_user_object,
                rule    => $dummy_rule_object,
                operand => $dt,
                args    => { units => 'years', time_zone => 'Australia/Melbourne' }
            }
        ),
        $dur->in_units('years'),
        'compare years'
    );
    is( WebGUI::Flux::Modifier->applyUsing(
            'DateTimeCompareToNow',
            {   user    => $dummy_user_object,
                rule    => $dummy_rule_object,
                operand => $dt,
                args    => { units => 'months', time_zone => 'Australia/Melbourne' }
            }
        ),
        $dur->in_units('months'),
        'compare months'
    );
}

#----------------------------------------------------------------------------
# Cleanup
END {

}
