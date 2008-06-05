# Tests WebGUI::Flux::Operand::TextValue
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
plan tests => 2;

#----------------------------------------------------------------------------
# put your tests here

use_ok('WebGUI::Flux::Operand');
my $dummy_user_object = 'ignored';
my $dummy_rule_object = 'ignored';

# Not much to test since WebGUI::Flux::Operand does all the heavy lifting (and that's tested in Operand.t)
{
    is( WebGUI::Flux::Operand->executeUsing(
            'TextValue',
            {   user => $dummy_user_object,
                rule => $dummy_rule_object,
                args => { value => 'test value' }
            }
        ),
        'test value'
    );
}

#----------------------------------------------------------------------------
# Cleanup
END {

}
