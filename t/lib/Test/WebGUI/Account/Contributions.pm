# vim:syntax=perl
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#------------------------------------------------------------------

# This tests the operation of WebGUI::Account modules. You can use
# as a base to test your own modules.

package Test::WebGUI::Account::Contributions;

use FindBin;
use strict;
use lib "$FindBin::Bin/lib";
use base 'Test::WebGUI::Account';
use Test::More;
use Test::Exception;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;

sub class {
     return 'WebGUI::Account::Contributions';
}

1;

#vim:ft=perl
