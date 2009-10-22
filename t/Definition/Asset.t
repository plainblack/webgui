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
        tableName => 'mytable',
        properties => [
            showInForms => {
                label => ['show in forms'],
            },
            confirmChange => {
                label => ['confirm change', 'Asset'],
                tableName => 'othertable',
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

is $object->getProperty('showInForms')->{tableName}, 'mytable',
    'properties copy tableName attribute';
is $object->getProperty('confirmChange')->{tableName}, 'othertable',
    'tableName property element not overwritten if manually specified';

is $object->getProperty('showInForms')->{label}, 'Show In Forms?',
    'getProperty internationalizes label';
is $object->getProperty('confirmChange')->{label}, 'Are you sure?',
    'getProperty internationalizes label with namespace';
is $object->getProperty('noTrans')->{label}, 'this label will not be translated',
    q{getProperty doesn't internationalize plain scalars};

