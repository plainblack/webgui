# Tests WebGUI::Flux::Operand::NumericValue
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

use_ok('WebGUI::Flux::Operand');
my $dummy_user_object = 'ignored';
my $dummy_rule_object = 'ignored';

# Not much to test since WebGUI::Flux::Operand does all the heavy lifting (and that's tested in Operand.t)

# TODO: If we need this "Numeric" at all (as distinct from String), which I'm not convinced we do,
# then we should be testing that the returned value is a perl number and not a perl string
{
    is( WebGUI::Flux::Operand->executeUsing(
            'NumericValue',
            {   user => $dummy_user_object,
                rule => $dummy_rule_object,
                args => { value => 3 }
            }
        ),
        3,
        q{3 == 3}
    );
    is( WebGUI::Flux::Operand->executeUsing(
            'NumericValue',
            {   user => $dummy_user_object,
                rule => $dummy_rule_object,
                args => { value => 123 }
            }
        ),
        '123',
        q{123 == '123'}
    );
}

#----------------------------------------------------------------------------
# Cleanup
END {

}
