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

use Test::More;
#use Test::More tests => 17;
use Test::Deep;
use Test::Exception;

my $session = WebGUI::Test->session;

{
    package WGT::Class;
    use Moose;
    use WebGUI::Definition;

    define 'define1' => 'define1 value';
    property 'property1' => (
        arbitrary_key => 'arbitrary_value',
        label         => 'property1',
    );
    property 'property2' => (
        nother_key => 'nother_value',
        label         => 'property2',
    );

    # define creates methods
    ::can_ok +__PACKAGE__, 'define1';

    # properties create methods
    ::can_ok +__PACKAGE__, 'property1';

    # role applied
    ::can_ok +__PACKAGE__, 'update';
    ::can_ok +__PACKAGE__, 'get';
    ::can_ok +__PACKAGE__, 'set';

    ::ok +__PACKAGE__->meta->does_role('WebGUI::Definition::Role::Object'), 'meta class check on the package';

    ::cmp_deeply(
        [ +__PACKAGE__->getProperties ],
        [qw/property1 property2/],
        'getProperties works as a class method'
    );

}

{
    package WGT::Class2;
    use Moose;
    use WebGUI::Definition;

    define 'define1' => 'define1 value';
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
    use Moose;
    use WebGUI::Definition;

    define 'define1' => 'define1 value';
    property  'property1' => (
        label     => ['webgui', 'WebGUI'],
        hoverHelp => ['webgui help %s', 'WebGUI', 'extra'],
        options   => \&property1_options,
        named_url => \&named_url,
    );
    has session => (
        is       => 'ro',
        required => 1,
    );
    sub property1_options {
        return { one => 1, two => 2, three => 3 };
    }

    sub named_url {
        my ($self, $property, $property_name) = @_;
        ::note "Checking arguments passed to subroutine for defining a form property";
        ::isa_ok($self, 'WGT::Class3');
        ::ok($property->can('form'),      'propery has a form method');
        #::ok($property->can('serialize'), 'and a serialize method');
        ::is($property_name, 'named_url', 'form property name sent');
        return $property->name;
    }

    my $object = WGT::Class3->new({session => $session});

    ::cmp_deeply(
        $object->getFormProperties('property1'),
        {
            label     => 'WebGUI',
            hoverHelp => 'webgui help extra',
            options   => { one => 1, two => 2, three => 3 },
            named_url => 'property1',
        },
        'getFormProperties handles i18n and subroutines'
    );

}

{
    package WGT::Class4;
    use Moose;
    use WebGUI::Definition;
    extends 'WGT::Class3';

    define 'define41' => 'define41 value';
    property  'property41' => (
        label   => ['webgui', 'WebGUI'],
    );
    has something => (
        is       => 'rw',
    );

    my $object3 = WGT::Class3->new({session => $session});
    my $object4 = WGT::Class4->new({session => $session});

    ::cmp_bag (
        [WGT::Class3->meta->get_all_attributes_list],
        [qw/ property1 session /],
        'get_all_attributes_list returns all attributes in all metaclasses for the class'
    );

    ::cmp_bag (
        [WGT::Class4->meta->get_all_attributes_list],
        [qw/ property41 something property1 session /],
        '... checking inherited class'
    );
}

{
    package WGT::Class5;
    use Moose;
    use WebGUI::Definition;

    property  'traitorous' => (
        noFormPost => 1,
        traits  => ['Array'],
        isa     => 'ArrayRef',
        is      => 'ro',
        handles => {
            pop_traitor => 'pop',
            push_traitor => 'push',
        },
        default => sub { [] },
    );

    my $object5 = WGT::Class5->new({session => $session});
    $object5->push_traitor('Boggs');
    ::cmp_deeply($object5->traitorous, ['Boggs'], 'push_traitor handler worked');

}

{
    package WGT::Class6;
    use Moose;
    use Moose::Util::TypeConstraints;
    use WebGUI::Definition;
    use JSON;

    subtype 'WGT::Type::JSONArray'
        => as   'ArrayRef'
    ;
    coerce 'WGT::Type::JSONArray'
        => from Str
        => via  { my $struct = eval { JSON::from_json($_); }; $struct ||= []; return $struct },
    ;

    property  'leaded' => (
        noFormPost => 1,
        default    => sub { [] },
        traits     => ['Array', 'WebGUI::Definition::Meta::Property::Serialize'],
        isa        => 'WGT::Type::JSONArray',
        coerce     => 1,
    );

    property  'regular' => (
        noFormPost => 1,
        default    => sub { [] },
        traits     => ['Array'],
        isa        => 'ArrayRef',
    );

    my $object6 = WGT::Class6->new({session => $session});
    my $leaded  = $object6->meta->find_attribute_by_name('leaded');
    my $regular = $object6->meta->find_attribute_by_name('regular');
    use Moose::Util;
    ::ok Moose::Util::does_role($leaded, 'WebGUI::Definition::Meta::Property::Serialize'), 'does_role detects role';
    ::ok !Moose::Util::does_role($regular, 'WebGUI::Definition::Meta::Property::Serialize'), 'does_role detects lack of role';
    ::ok $leaded->does('WebGUI::Definition::Meta::Property::Serialize'), 'property does role';
    ::ok !$regular->does('WebGUI::Definition::Meta::Property::Serialize'), 'property lacks role';

    my $object6a = WGT::Class6->new({session => $session, leaded => '[{"a": "alpha"}]', });
    ::cmp_deeply(
        $object6a->leaded,
        [ { a => "alpha", }, ],
        'coercion from JSON worked on custom subtype'
    );

    my $object6b = WGT::Class6->new({session => $session, leaded => [{"b" => "beta"}], });
    ::cmp_deeply(
        $object6b->leaded,
        [ { b => "beta", }, ],
        'regular constructor without coercion'
    );

}


done_testing();
