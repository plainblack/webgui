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

