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

$session->db->dbh->do('DROP TABLE IF EXISTS testTable');
$session->db->dbh->do('CREATE TABLE testTable (zero int(8), one int(8), two int(8), three int(8), four int(8), five int(8), six int(8), seven int(8), eight int(8), nine int(8), ten int(8), eleven int(8) ) TYPE=InnoDB');
$session->db->dbh->do('INSERT INTO testTable (zero, one, two, three, four, five, six, seven, eight, nine, ten, eleven ) VALUES(0,1,2,3,4,5,6,7,8,9,10,11)');
$session->db->dbh->do('INSERT INTO testTable (zero, one, two, three, four, five, six, seven, eight, nine, ten, eleven ) VALUES(100,101,102,103,104,105,106,107,108,109,110,111)');

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
	{ ##test two digit macros
	sql => q!select * from testTable order by one!,
	template => join(':', map { "^$_;" } 0..11).'-',
	output => '0:1:2:3:4:5:6:7:8:9:10:11-100:101:102:103:104:105:106:107:108:109:110:111-',
	},
	{ ##Test illegal SQL, update
	sql => q!update testTable set one=201 where one=101!,
	template => '^0;',
	output => 'Cannot execute this type of query.',
	},
	{ ##Test illegal SQL, update
	sql => q!INSERT INTO testTable (zero, one, two, three, four, five, six, seven, eight, nine, ten, eleven ) VALUES(200,201,202,203,204,205,206,207,208,209,210,211)!,
	template => '^0;',
	output => 'Cannot execute this type of query.',
	},
	{ ##Test unused macro variables
	sql => q!select zero,one,two,three from testTable order by one!,
	template => join(':', map { "^$_;" } 0..4).'-',
	output => '0:1:2:3:-100:101:102:103:-',
	},
	{ ##rownum test
	sql => q!select zero,one,two,three from testTable order by one!,
	template => join(':', map { "^$_;" } 'rownum', 0..3).',',
	output => '1:0:1:2:3,2:100:101:102:103,',
	},
);

my $numTests = scalar @testSets;

plan tests => $numTests;

unless ($session->config->get('macros')->{'SQL'}) {
	BAIL_OUT('SQL macro not enabled');
}

foreach my $testSet (@testSets) {
	my $output = sprintf $macroText, $testSet->{sql}, $testSet->{template};
	my $macro = $output;
	WebGUI::Macro::process($session, \$output);
	is($output, $testSet->{output}, 'testing '.$macro);
}

$session->db->dbh->do('DROP TABLE testTable');
