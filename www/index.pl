#!/usr/bin/perl

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

our ($webguiRoot, $configFile);

BEGIN {
        $configFile = "WebGUI.conf";
        $webguiRoot = "..";
        unshift (@INC, $webguiRoot."/lib");
}

#-----------------DO NOT MODIFY BELOW THIS LINE--------------------

use CGI::Carp qw(fatalsToBrowser);
use strict;
use WebGUI;

print WebGUI::page($webguiRoot,$configFile);

