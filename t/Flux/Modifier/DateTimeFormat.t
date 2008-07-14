# Tests WebGUI::Flux::Modifier::DateTimeFormat
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

# Not much to test since WebGUI::Flux::Modifier does all the heavy lifting (and that's tested in Modifier.t)

{
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
        'correctly formatted date in same timezone'
    );
    is( WebGUI::Flux::Modifier->evaluateUsing(
            'DateTimeFormat',
            {   rule    => $rule,
                operand => $dt,
                args    => { pattern => '%x %X', time_zone => 'America/Chicago' }
            }
        ),
        'Oct 16, 1984 1:12:47 AM', 
        'America/Chicage 15hrs behind Australia/Melbourne'
    );
}

#----------------------------------------------------------------------------
# Cleanup
END {
    $session->db->write('delete from fluxRule');
}
