package WebGUI::Operation::Scratch;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2004 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use Exporter;
use strict;
use WebGUI::Session;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_setScratch &www_deleteScratch);

#-------------------------------------------------------------------
sub www_deleteScratch {
	WebGUI::Session::deleteScratch("www_".$session{form}{scratchName});
	return "";
}

#-------------------------------------------------------------------
sub www_setScratch {
	WebGUI::Session::setScratch("www_".$session{form}{scratchName},$session{form}{scratchValue});
	return "";
}


1;
