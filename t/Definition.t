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

    property 'property1' => ();

}

{
    package WGT::Class::Asset;
    use WebGUI::Definition::Asset;

    attribute table => 'asset';
    property 'property1' => ();

    ::is +__PACKAGE__->meta->get_attribute('property1')->table, 'asset';
}


