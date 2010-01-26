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
use Test::Deep;
use Test::Exception;
use WebGUI::Test;

{
    package WGT::Class::Atset;
    use WebGUI::Definition::Asset;

    aspect tableName => 'asset';
    ::dies_ok  { property 'property1' => (); } 'must have a fieldType';
    ::dies_ok  { property 'property1' => (fieldType => 'text'); } 'must pass either a label or noFormPost flag';
    ::lives_ok { property 'property1' => (
                                            fieldType  => 'YUI Super Form',
                                            noFormPost => '1',
                                         );
               }  '... pass noFormPost flag';
    ::lives_ok { property 'property1' => (
                                            fieldType  => 'YUI Super Form',
                                            label      => 'JSON Powered Uber Widget',
                                         );
               }  '... pass label';

}

{
    package WGT::Class::Asset;
    use WebGUI::Definition::Asset;

    aspect tableName => 'asset';
    property 'property2' => (
        fieldType => 'text',
        label     => 'property2',
    );
    property 'property1' => (
        fieldType => 'text',
        label     => 'property1',
    );

    my $filter2 = 0;
    around 'property2' => sub {
        my $orig = shift;
        my $self = shift;
        $filter2 = 1;
        $self->$orig(@_);
    };

    my $written;
    sub write {
        $written++;
    }

    ::is +__PACKAGE__->meta->get_attribute('property1')->tableName, 'asset', 'tableName copied from attribute into property';
    ::isa_ok +__PACKAGE__->getProperty('property1'), 'WebGUI::Definition::Meta::Property::Asset';

    ::can_ok +__PACKAGE__, 'update';
    ::can_ok +__PACKAGE__, 'tableName';

    ::can_ok +__PACKAGE__->getProperty('property1'), 'tableName';
    ::is +__PACKAGE__->getProperty('property1')->tableName, 'asset', 'tableName set on property to asset';

    my $object = __PACKAGE__->new;
    $object->set({property1 => 'property value'});
    ::is $object->property1, 'property value', 'checking set, hashref form';

    $object->set('property1',  'newer property value');
    ::is $object->property1, 'newer property value', '... hash form';

    # write called
    $object->update;
    ::is $written, 1, 'update calls write';

    $object->property2('foo');
    ::is $filter2, 1, 'around modifier called';
    ::is $object->property2(), 'foo', '...and it works for set/get';

    $object->update(property2 => 'bar', property1 => 'baz');
    ::is $object->property1(), 'baz', 'update set property1';
    ::is $object->property2(), 'bar', 'and ... property1';

    ::is $object->tableName, 'asset', 'tableName set for object';
    $object->tableName('not asset');
    ::is $object->tableName, 'asset', 'tableName may not be set from the object';
    $object->meta->tableName('not asset');
    ::is $object->tableName, 'not asset', 'object can access meta and change the table';
    $object->meta->tableName('asset');

    ::cmp_deeply(
        [ $object->meta->get_property_list ],
        [qw/property2 property1/],
        '->meta->get_property_list returns properties as a list in insertion order'
    );

    ::cmp_deeply(
        [ $object->meta->get_all_properties ],
        ::array_each(::isa('WebGUI::Definition::Meta::Property::Asset')),
        '->meta->get_all_properties returns a list of Properties'
    );

    ::cmp_deeply(
        [$object->getProperties ],
        [qw/property2 property1/],
        'getProperties is an alias for ->meta->get_property_list'
    );

    ::cmp_deeply(
        [$object->meta->get_tables ],
        [qw/asset/],
        'get_tables returns a list of all tables used by this class'
    );

    my $object2 = __PACKAGE__->new(tableName => 'notAsset');
    ::is $object2->tableName, 'asset', 'tableName ignored in constructor';

    ::cmp_deeply(
        [ __PACKAGE__->meta->get_tables ],
        [qw/asset/],
        'get_tables works for a simple asset'
    );

}

{

    package WGT::Class::AlsoAsset;
    use WebGUI::Definition::Asset;

    aspect tableName => 'asset';
    property 'property1' => (
        fieldType => 'text',
        label     => 'property1',
    );
    property 'property2' => (
        fieldType => 'text',
        label     => 'property2',
    );
    property 'property3' => (
        fieldType => 'text',
        label     => 'property3',
    );

    package WGT::Class::Asset::Snippet;
    use WebGUI::Definition::Asset;
    extends 'WGT::Class::AlsoAsset';

    aspect tableName => 'snippet';
    property 'property10' => (
        fieldType => 'text',
        label     => 'property10',
    );
    property 'property11' => (
        fieldType => 'text',
        label     => 'property11',
    );

    package main;

    is +WGT::Class::AlsoAsset->getProperty('property1')->tableName, 'asset', 'tableName set in base class';

    is +WGT::Class::Asset::Snippet->getProperty('property10')->tableName, 'snippet', 'tableName set in subclass';
    is +WGT::Class::Asset::Snippet->getProperty('property1')->tableName,  'asset',   '... but inherited properties keep their tableName';

    cmp_bag(
        [ map {$_->name} WGT::Class::AlsoAsset->meta->get_attributes ],
        [qw/property1 property2 property3/],
        'get_attributes returns attributes for my class'
    );

    cmp_bag(
        [ map {$_->name} WGT::Class::Asset::Snippet->meta->get_attributes ],
        [qw/property10 property11/],
        '...even in a subclass'
    );

    cmp_deeply(
        [ WGT::Class::Asset::Snippet->getProperties ],
        [qw/property1 property2 property3 property10 property11/],
        'checking inheritance of properties by name, insertion order'
    );

    ::cmp_deeply(
        [ WGT::Class::AlsoAsset->meta->get_tables ],
        [qw/asset/],
        'get_tables: checking inheritance'
    );

    ::cmp_deeply(
        [ WGT::Class::Asset::Snippet->meta->get_tables ],
        [qw/asset snippet/],
        'get_tables: checking inheritance on subclass'
    );

}

{

    package WGT::Class::Asset::NotherOne;
    use WebGUI::Definition::Asset;
    extends 'WGT::Class::AlsoAsset';

    aspect tableName => 'snippet';
    property 'property10' => (
        fieldType => 'text',
        label     => 'property10',
    );
    property 'property1'  => (
        fieldType => 'text',
        label     => 'property1',
    );

    package main;

    cmp_deeply(
        [WGT::Class::Asset::NotherOne->getProperties],
        [qw/property1 property2 property3 property10/],
        'checking inheritance of properties by name, insertion order with an overridden property'
    );

}

{

    package WGT::Class::Asset::Tertiary;
    use WebGUI::Definition::Asset;
    extends 'WGT::Class::AlsoAsset';

    aspect tableName => 'tertius';
    property 'defaulted' => (
        fieldType => 'text',
        label     => 'defaulted',
        default   => 'a sane default',
    );
    property 'no_default'  => (
        fieldType => 'text',
        label     => 'noDefault',
    );

    package main;
    my $object = WGT::Class::Asset::Tertiary->new;
    is $object->defaulted(), 'a sane default', 'setup: checking default';
    is $object->no_default(), undef, '... and one without default';

    $object->defaulted(undef);
    is $object->defaulted(), undef, 'Moose setters accept undef';
}
