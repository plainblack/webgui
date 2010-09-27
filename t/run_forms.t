#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use File::Spec::Functions qw( catdir rel2abs );
use File::Basename;
use Test::Class;
use Module::Find;
use lib rel2abs( catdir ( dirname( __FILE__ ), 'tests' ) );

useall('Test::WebGUI::Form');
Test::Class->runtests;

