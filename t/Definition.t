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
#use Test::Exception;

my $called_getProperties;
{
    package WGT::Class;
    use WebGUI::Definition;

    attribute 'attribute1' => 'attribute1 value';
    property 'property1' => (
        arbitrary_key => 'arbitrary_value',
    );

    # attributes create methods
    ::can_ok +__PACKAGE__, 'attribute1';

    # propeties create methods
    ::can_ok +__PACKAGE__, 'property1';

    # role applied
    ::can_ok +__PACKAGE__, 'update';

    # can retreive property metadata
    ::is +__PACKAGE__->getProperty('property1')->form->{'arbitrary_key'}, 'arbitrary_value', 'arbitrary keys mapped into the form attribute';
}

{
    package WGT::Class::Asset;
    use WebGUI::Definition::Asset;

    attribute tableName => 'asset';
    property 'property1' => ();

    my $written;
    sub write {
        $written++;
    }

    ::is +__PACKAGE__->meta->get_attribute('property1')->tableName, 'asset', 'tableName copied from attribute into property';

    ::can_ok +__PACKAGE__, 'update';

    my $object = __PACKAGE__->new;
    $object->set({property1 => 'property value'});

    ::is $object->property1, 'property value', 'checking set';

    # write called
    $object->update;
    ::is $written, 1, 'update calls write';

}


