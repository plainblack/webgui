#!/usr/bin/perl

#-------------------------------------------------------------------
# WebGUI is Copyright 2001 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

BEGIN {
        unshift (@INC, "../lib/");
}

use CGI::Carp qw(fatalsToBrowser);
use strict;
use WebGUI;

print WebGUI::page();

