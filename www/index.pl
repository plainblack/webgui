#!/data/perl/bin/perl

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2004 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

our ($webguiRoot, $configFile);

BEGIN {
        $configFile = "webgui.conf";
        $webguiRoot = "/data/WebGUI";
        unshift (@INC, $webguiRoot."/lib");
}

#-----------------DO NOT MODIFY BELOW THIS LINE--------------------

use CGI::Carp qw(fatalsToBrowser);
use strict;
use WebGUI;

print WebGUI::page($webguiRoot,$configFile);

