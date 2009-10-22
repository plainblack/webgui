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
use Test::Exception;
use WebGUI::Test;

{
    package WGT::Class;
    use WebGUI::Definition::Asset (
        attribute1 => 'attribute 1 value',
        tableName => 'mytable',
        properties => [
            showInForms => {
                fieldType => 'Text',
                label => ['show in forms'],
            },
            confirmChange => {
                fieldType => 'Text',
                label => ['confirm change', 'Asset'],
                tableName => 'othertable',
            },
            noTrans => {
                fieldType => 'Text',
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

{
    package WGT::Class2;
    use Test::Exception;
    throws_ok { WebGUI::Definition::Asset->import(
        properties => [],
    ) } 'WebGUI::Error::InvalidParam', 'Exception thrown when no tableName specified';
    throws_ok { WebGUI::Definition::Asset->import(
        tableName => 'mytable',
        properties => [
            'property1' => {
                label => 'label',
            },
        ],
    ) } 'WebGUI::Error::InvalidParam', 'Exception thrown when no fieldType specified';
    throws_ok { WebGUI::Definition::Asset->import(
        tableName => 'mytable',
        properties => [
            'property1' => {
                fieldType => sub { return 'Text' },
                label => 'label',
            },
        ],
    ) } 'WebGUI::Error::InvalidParam', 'Exception thrown when dynamic fieldType specified';
    throws_ok { WebGUI::Definition::Asset->import(
        tableName => 'mytable',
        properties => [
            'property1' => {
                tableName => sub { return 'othertable' },
                fieldType => 'Text',
                label => 'label',
            },
        ],
    ) } 'WebGUI::Error::InvalidParam', 'Exception thrown when dynamic tableName specified';
    throws_ok { WebGUI::Definition::Asset->import(
        tableName => 'mytable',
        properties => [
            'property1' => {
                fieldType => 'Text',
            },
        ],
    ) } 'WebGUI::Error::InvalidParam', 'Exception thrown when no label specified';
    throws_ok { WebGUI::Definition::Asset->import(
        tableName => 'mytable',
        properties => [
            'property1' => {
                fieldType => 'Text',
                noFormPost => sub { 1 },
            },
        ],
    ) } 'WebGUI::Error::InvalidParam', 'Exception thrown when no label and noFormPost is dynamic';
    lives_ok { WebGUI::Definition::Asset->import(
        tableName => 'mytable',
        properties => [
            'property1' => {
                fieldType => 'Text',
                noFormPost => 1,
            },
        ],
    ) } 'Allows no label when noFormPost specified';
}

