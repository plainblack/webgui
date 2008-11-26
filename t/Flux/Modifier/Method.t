# Tests WebGUI::Flux::Modifier::Method
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
plan tests => 5;

#----------------------------------------------------------------------------
# put your tests here

use_ok('WebGUI::Flux::Modifier');
my $rule   = WebGUI::Flux::Rule->create($session);

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
            'Method',
            {   rule    => $rule,
                operand => $dt,
                args    => { method => 'not_a_method' }
            }
        ),
        undef,
        'Returns nothing when invalid method requested'
    );
    
    is( WebGUI::Flux::Modifier->evaluateUsing(
            'Method',
            {   rule    => $rule,
                operand => {},
                args    => { method => 'not_a_method' }
            }
        ),
        undef,
        'Returns nothing when operand is not a blessed object'
    );
    
    is( WebGUI::Flux::Modifier->evaluateUsing(
            'Method',
            {   rule    => $rule,
                operand => $dt,
                args    => { method => 'hms' }
            }
        ),
        '16:12:47',
        'correctly called method'
    );
    
    is( WebGUI::Flux::Modifier->evaluateUsing(
            'Method',
            {   rule    => $rule,
                operand => $dt,
                args    => { method => 'hms', args => ['x'] }
            }
        ),
        '16x12x47',
        'correctly called method'
    );
}

#----------------------------------------------------------------------------
# Cleanup
END {
    $session->db->write('delete from fluxRule');
}
