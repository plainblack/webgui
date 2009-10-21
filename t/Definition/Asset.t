#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use warnings;
no warnings qw(uninitialized);

use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More 'no_plan'; #tests => 1;
use WebGUI::Test;

{
    package WGT::Class;
    use WebGUI::Definition::Asset (
        attribute1 => 'attribute 1 value',
        properties => [
            showInForms => {
                label => ['show in forms'],
            },
            confirmChange => {
                label => ['confirm change', 'Asset'],
            },
            noTrans => {
                label => 'this label will not be translated',
            },
        ],
    );

    sub session {
        return WebGUI::Test->session;
    }
}

my $object = WGT::Class->instantiate;

is_deeply $object->getProperty('showInForms')->{label}, 'Show In Forms?',
    'getProperty internationalizes label';
is_deeply $object->getProperty('confirmChange')->{label}, 'Are you sure?',
    'getProperty internationalizes label with namespace';
is_deeply $object->getProperty('noTrans')->{label}, 'this label will not be translated',
    q{getProperty doesn't internationalize plain scalars};

