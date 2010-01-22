#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use FindBin;
use strict;
use warnings;
no warnings qw(uninitialized);
use lib "$FindBin::Bin/lib";

use WebGUI::Test;

use Test::More tests => 10;
use Test::Deep;
use Test::Exception;

my $session = WebGUI::Test->session;

my $called_getProperties;
{
    package WGT::Class;
    use WebGUI::Definition;

    attribute 'attribute1' => 'attribute1 value';
    property 'property1' => (
        arbitrary_key => 'arbitrary_value',
        label         => 'property1',
    );
    property 'property2' => (
        nother_key => 'nother_value',
        label         => 'property2',
    );

    # attributes create methods
    ::can_ok +__PACKAGE__, 'attribute1';

    # propeties create methods
    ::can_ok +__PACKAGE__, 'property1';

    # role applied
    ::can_ok +__PACKAGE__, 'update';
    ::can_ok +__PACKAGE__, 'get';
    ::can_ok +__PACKAGE__, 'set';

    ::cmp_deeply(
        [ +__PACKAGE__->getProperties ],
        [qw/property1 property2/],
        'getProperties works as a class method'
    );

}

{
    package WGT::Class2;
    use WebGUI::Definition;

    attribute 'attribute1' => 'attribute1 value';
    property  'property3' => ( label => 'label' );
    property  'property1' => ( label => 'label' );
    property  'property2' => ( label => 'label' );

    my @set_order = ();

    before 'property1' => sub {
        my $self = shift;
        push @set_order, '1';
    };

    before 'property2' => sub {
        my $self = shift;
        push @set_order, '2';
    };

    before 'property3' => sub {
        my $self = shift;
        push @set_order, '3';
    };

    my $object = WGT::Class2->new();
    $object->set(property1 => 1, property2 => 0, property3 => 1);
    ::cmp_deeply( [ @set_order ], [3,1,2], 'properties set in insertion order');

    @set_order = ();
    $object->set(property2 => 1, property3 => 0, property1 => 1);
    ::cmp_deeply( [ @set_order ], [3,1,2], '... and again');

    ::cmp_deeply(
        $object->getFormProperties('property1'),
        { label => 'label' },
        'getFormProperties works for a simple set of properties'
    );

}

{
    package WGT::Class3;
    use WebGUI::Definition;

    attribute 'attribute1' => 'attribute1 value';
    property  'property1' => (
        label   => ['webgui', 'WebGUI'],
        options => \&property1_options,
    );
    has session => (
        is       => 'ro',
        required => 1,
    );
    sub property1_options {
        return { one => 1, two => 2, three => 3 };
    }

    my $object = WGT::Class3->new({session => $session});

    ::cmp_deeply(
        $object->getFormProperties('property1'),
        {
            label   => 'WebGUI',
            options => { one => 1, two => 2, three => 3 },
        },
        'getFormProperties handles i18n and subroutines'
    );

}
