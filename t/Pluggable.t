#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2007 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#------------------------------------------------------------------

# Write a little about what this script tests.
# 
#

use FindBin;
use strict;
use lib "$FindBin::Bin/lib";
use Test::More;
use WebGUI::Test;


use WebGUI::Pluggable;

#----------------------------------------------------------------------------
# Init


#----------------------------------------------------------------------------
# Tests

plan tests => 4;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# put your tests here
eval { WebGUI::Pluggable::load("No::Way::In::Hell") };
isnt($@, '', "Module shouldn't load.");
eval { WebGUI::Pluggable::load("Config::JSON") };
is($@, '', "Module should load.");
my $string = WebGUI::Pluggable::run("Data::Dumper","Dumper",[ {color=>"black", make=>"honda"}]);
is($string, q|$VAR1 = {
          'make' => 'honda',
          'color' => 'black'
        };
|, "Can run a function.");
my $dumper = WebGUI::Pluggable::instanciate("Data::Dumper","new",[ [{color=>"black", make=>"honda"}]]);
is($dumper->Dump, q|$VAR1 = {
          'make' => 'honda',
          'color' => 'black'
        };
|, "Can instanciate an object.");

#----------------------------------------------------------------------------
# Cleanup

END {

}

