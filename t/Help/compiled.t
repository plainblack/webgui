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
use lib "$FindBin::Bin/../lib";

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Operation::Help;
use Test::More;
use Test::Exception;

#The goal of this test is to verify that all entries in the lib/WebGUI/Help
#directory compile.  This test is necessary because WebGUI::Operation::Help
#will return an empty hash if it won't compile, and the help will simply
#disappear.

my $numTests = 0;

my $session = WebGUI::Test->session;

my @helpFileSet = WebGUI::Operation::Help::_getHelpFilesList($session);

$numTests = scalar @helpFileSet; #One for each help compile

plan tests => $numTests + 2;

foreach my $helpSet (@helpFileSet) {
	my $helpName = $helpSet->[1];
	my $help = WebGUI::Operation::Help::_load($session, $helpName);
	ok(keys %{ $help }, "$helpName compiled");
}

#----------------------------------------------------------------------------
# Test invalid help files
WebGUI::Test->interceptLogging;
lives_ok { WebGUI::Operation::Help::_load( $session, '::HI::' ) } "invalid help module doesnt die";
like( $WebGUI::Test::logger_error, qr/^Help failed to compile/, 'invalid help module errored' );

WebGUI::Test->restoreLogging;
