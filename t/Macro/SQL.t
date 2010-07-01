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
use WebGUI::Macro::Slash_gatewayUrl;
use WebGUI::Session;
use WebGUI::International;
use WebGUI::DatabaseLink;
use WebGUI::Macro::SQL;
use Data::Dumper;

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

my $url = WebGUI::Macro::Slash_gatewayUrl::process($session);

my $i18n = WebGUI::International->new($session, 'Macro_SQL');

my $WebGUIdbLink = WebGUI::DatabaseLink->new($session, '0');
my $originalMacroAccessValue = $WebGUIdbLink->macroAccessIsAllowed();

$session->db->dbh->do('DROP TABLE IF EXISTS testTable');
WebGUI::Test->addToCleanup(SQL => 'DROP TABLE testTable');
$session->db->dbh->do('CREATE TABLE testTable (zero int(8), one int(8), two int(8), three int(8), four int(8), five int(8), six int(8), seven int(8), eight int(8), nine int(8), ten int(8), eleven int(8) ) TYPE=InnoDB');
$session->db->dbh->do('INSERT INTO testTable (zero, one, two, three, four, five, six, seven, eight, nine, ten, eleven ) VALUES(0,1,2,3,4,5,6,7,8,9,10,11)');
$session->db->dbh->do('INSERT INTO testTable (zero, one, two, three, four, five, six, seven, eight, nine, ten, eleven ) VALUES(100,101,102,103,104,105,106,107,108,109,110,111)');

my @testSets = (
	{
		comment => q!first example from docs!,
		sql => q!select count(*) from users!,
		template => q!There are ^0; users!,
		output => q!There are 2 users!,
	},
	{
		comment => q!pretest for second example!,
		sql => q!select userId,username from users order by username!,
		template => q!^0;:^1;-!,
		output => q!3:Admin-1:Visitor-!,
	},
	{
		comment => q!second example from docs!,
		sql => q!select userId,username from users order by username!,
		template => qq!<a href='$url?op=viewProfile&uid=^0;'>^1;</a><br>!,
		output => join '', map {sprintf "<a href='%s?op=viewProfile&uid=%d'>%s</a><br>", @{ $_ }} ([$url, 3,'Admin'],[$url, 1,'Visitor']),
	},
	{
		comment => q!Null template returns ^0;!,
		sql => q!select count(*) from users!,
		template => q!!,
		output => q!2!,
	},
	{
		comment => q!test two digit macros!,
		sql => q!select * from testTable order by one!,
		template => join(':', map { "^$_;" } 0..11).'-',
		output => '0:1:2:3:4:5:6:7:8:9:10:11-100:101:102:103:104:105:106:107:108:109:110:111-',
	},
	{
		comment => q!Test illegal SQL, update!,
		sql => q!update testTable set one=201 where one=101!,
		template => '^0;',
		output => $i18n->get('illegal query'),
	},
	{
		comment => q!Test illegal SQL, update!,
		sql => q!INSERT INTO testTable (zero, one, two, three, four, five, six, seven, eight, nine, ten, eleven ) VALUES(200,201,202,203,204,205,206,207,208,209,210,211)!,
		template => '^0;',
		output => $i18n->get('illegal query'),
	},
	{
		comment => q!Test valid SQL, show!,
		sql => q!show columns from testTable like 'zero'!,
		template => '^0;',
		output => 'zero',
	},
	{
		comment => q!Test valid SQL, describe!,
		sql => q!DESCRIBE testTable 'one'!,
		template => '^0;',
		output => 'one',
	},
	{
		comment => q!Test unused macro variables!,
		sql => q!select zero,one,two,three from testTable order by one!,
		template => join(':', map { "^$_;" } 0..4).'-',
		output => '0:1:2:3:-100:101:102:103:-',
	},
	{
		comment => q!rownum test!,
		sql => q!select zero,one,two,three from testTable order by one!,
		template => join(':', map { "^$_;" } 'rownum', 0..3).',',
		output => '1:0:1:2:3,2:100:101:102:103,',
	},
	{
		comment => q!Multiline output test using rownum!,
		sql => q!select zero from testTable order by one!,
		template => "^rownum;\n",
		output => "1\n2\n",
	},
	{
		comment => q!SQL error!,
		sql => q!select ** from testTable order by one!,
		template => join(':', map { "^$_;" } 'rownum', 0..3).',',
		output => sprintf $i18n->get('sql error'),
			q!You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near '* from testTable order by one' at line 1!,
	},
);

my $numTests = scalar @testSets
             + 2
             ;
 
plan tests => $numTests;

$WebGUIdbLink->set({allowMacroAccess=>0});

# run one test to test allowMacroAccess
my $output = WebGUI::Macro::SQL::process($session, 'select count(*) from users', 'There are ^0; users');
is($output, $i18n->get('database access not allowed'), 'Test allow access from macros setting.');

# set allowMacroAccess to 1 to allow other tests to run
$WebGUIdbLink->set({allowMacroAccess=>1});

foreach my $testSet (@testSets) {
    # we know some of these will fail.  Keep them quiet.
    local $SIG{__WARN__} = sub {};

	my $output = WebGUI::Macro::SQL::process($session, $testSet->{sql}, $testSet->{template});
	is($output, $testSet->{output}, $testSet->{comment});
}

# reset allowMacroAccess to original value
$WebGUIdbLink->set({allowMacroAccess=>$originalMacroAccessValue});

my $newLinkId = $WebGUIdbLink->copy;
addToCleanup(WebGUI::DatabaseLink->new($session, $newLinkId));
my $output = WebGUI::Macro::SQL::process(
    $session,
    q{show columns from testTable like 'zero'},
    q{^0;},
    $newLinkId,
);
is($output, 'zero', 'alternate linkId works');

#vim:ft=perl
