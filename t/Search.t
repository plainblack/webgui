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

# Write a little about what this script tests.
# 
#

use FindBin;
use strict;
use lib "$FindBin::Bin/lib";
use Test::More;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

plan tests => 7;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# put your tests here

use_ok('WebGUI::Search');

my $search = WebGUI::Search->new($session);

################################################
#
# _isStopword
#
################################################

ok(! $search->_isStopword('not a stopword'), '_isStopword: not a stopword');
ok(  $search->_isStopword('the'),            '_isStopword: "the" is a stopword');
ok(  $search->_isStopword('all*'),           '_isStopword: regex metacharacter * does not crash the search');
ok(  $search->_isStopword('anybody+'),       '_isStopword: regex metacharacter + does not crash the search');
ok(  $search->_isStopword('maybe?'),         '_isStopword: regex metacharacter ? does not crash the search');
ok(! $search->_isStopword('private.+'),      '_isStopword: regex metacharacters .+ do not crash the search');

#----------------------------------------------------------------------------
# Cleanup
END {

}
#vim:ft=perl
