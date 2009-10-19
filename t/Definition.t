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

use Test::More 'no_plan'; #tests => 1;
my $called_getProperties;
{
    package WGT::Class;
    use WebGUI::Definition (
        attribute1 => 'attribute 1 value',
        properties => [
            property1 => {
                label => 'property1 label',
                defaultValue => sub { return shift },
            },
        ],
    );

    sub new {
        my $class = shift;
        my $self = $class->instantiate;
        return $self;
    }

    sub getProperties {
        $called_getProperties = 1;
        my $self = shift;
        return $self->next::method(@_);
    }
}

my $written;
{
    package WGT::SubClass;
    use base qw(WGT::Class);
    use WebGUI::Definition (
        attribute2 => 'attribute 2 value',
        properties => [
            property2 => {
                label => 'property2 label',
                defaultValue => sub { return "dynamic value" },
            },
            a_property => {
                defaultValue => 1,
            },
        ],
    );

    sub write {
        my $self = shift;
        $written = 1;
    }

    sub a_property {
        my $self = shift;
        my $value = shift;
        return $self->next::method("$value - BLAH");
    }
}

my $object = WGT::Class->new;
my $subclass_object = WGT::SubClass->new;

can_ok $object, qw(getProperties getProperty get update getAttribute instantiate property1);
can_ok $subclass_object, qw(getProperties getProperty get update getAttribute instantiate property1 property2 a_property);

is $object->property1('property 1 value'), 'property 1 value',
    'property mutator returns newly set value';
is $object->property1, 'property 1 value',
    'property accessor returns correct value';

is $subclass_object->property2('property 2 value'), 'property 2 value',
    'property mutator returns newly set value';
is $subclass_object->property2, 'property 2 value',
    'property accessor returns correct value';

is_deeply [ $object->getProperties ], ['property1'],
    'class has correct properties';
ok $called_getProperties, 'able to override getProperties';
undef $called_getProperties;
is_deeply [ $subclass_object->getProperties ], ['property1', 'property2', 'a_property'],
    'subclass has correct properties';
ok $called_getProperties, 'subclass uses correctly overridden getProperties';

is_deeply $object->get, { property1 => 'property 1 value' },
    'get returns hash with correct properties';
is_deeply $subclass_object->get, { property1 => undef, a_property => ' - BLAH', property2 => 'property 2 value' },
    'get returns hash with correct properties';

is_deeply $object->getProperty('property1'), { label => 'property1 label', defaultValue => $object },
    'getProperty returns correct hash for object';
is_deeply $subclass_object->getProperty('property2'), { label => 'property2 label', defaultValue => 'dynamic value' },
    'getProperty returns correct hash for subclass object';

is $object->getAttribute('attribute1'), 'attribute 1 value',
    'object has correct attribute';
is $subclass_object->getAttribute('attribute1'), 'attribute 1 value',
    'subclass object has correct inherited attribute';
is $subclass_object->getAttribute('attribute2'), 'attribute 2 value',
    'subclass object has correct own value';

ok eval { $object->update; 1},
    'update works when no write sub available';
ok eval { $subclass_object->update; 1},
    'update works when write sub available';
ok $written,
    'update calls write';

$object->update({ property1 => 'new value', nonproperty => 'other value' });

is $object->property1, 'new value', 'update sets all properties';

$object->property1(undef);

is $object->property1, undef, 'able to set undef as property value';

is +WGT::Class->instantiate(property1 => 'property value')->property1, 'property value',
    'instantiate sets correct values';

is $subclass_object->a_property('value'), 'value - BLAH', 'accessor calls custom filter if needed';


#->update
#->new

