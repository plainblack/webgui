#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
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
use WebGUI::Macro;
use WebGUI::Session;
use WebGUI::Macro_Config;
use Data::Dumper;

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

unless ($session->config->get('macros')->{'SQL'}) {
	Macro_Config::insert_macro($session, 'SQL', 'SQL');
}

unless ($session->config->get('macros')->{'/'}) {
	Macro_Config::insert_macro($session, '/', 'Slash_gatewayUrl');
}


my $macroText = '^SQL("%s","%s");';

my $url = "^/;";

WebGUI::Macro::process($session, \$url);

my @testSets = (
	{ ##first example from docs
	sql => q!select count(*) from users!,
	template => q!There are ^0; users!,
	output => q!There are 2 users!,
	},
	{ ##pretest for second example
	sql => q!select userId,username from users order by username!,
	template => q!^0;:^1;-!,
	output => q!3:Admin-1:Visitor-!,
	},
	{ ##second example from docs
	sql => q!select userId,username from users order by username!,
	template => q!<a href='^/;?op=viewProfile&uid=^0;'>^1;</a><br>!,
	output => join '', map {sprintf "<a href='%s?op=viewProfile&uid=%d'>%s</a><br>", @{ $_ }} ([$url, 3,'Admin'],[$url, 1,'Visitor']),
	},
);

my $numTests = scalar @testSets;

plan tests => $numTests;

foreach my $testSet (@testSets) {
	my $output = sprintf $macroText, $testSet->{sql}, $testSet->{template};
	my $macro = $output;
	WebGUI::Macro::process($session, \$output);
	is($output, $testSet->{output}, 'testing '.$macro);
}
