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

use Test::More 'no_plan'; #tests => 1;
use Test::Deep;
use Test::Exception;

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

    # can retreive property metadata
    ::isa_ok +__PACKAGE__->getProperty('property1'), 'WebGUI::Definition::Meta::Property';

    ::is +__PACKAGE__->getProperty('property1')->form->{'arbitrary_key'}, 'arbitrary_value', 'arbitrary keys mapped into the form attribute';

    ::is +__PACKAGE__->getProperty('property2')->form->{'nother_key'}, 'nother_value', '... and again';

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
}

