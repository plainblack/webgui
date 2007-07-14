#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2007 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use FindBin;
use strict;
use lib "$FindBin::Bin/lib";

use WebGUI::Test;
use WebGUI::Session;

use WebGUI::DatabaseLink;

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

my $DSNs = [
	{
		dsn    => 'DBI:mysql:colonSeparated:myHost:8008',
		dbName => 'colonSeparated',
	},
	{
		dsn    => 'DBI:mysql:database=myDatabase',
		dbName => 'myDatabase',
	},
	{
		dsn    => 'DBI:mysql:dbName=myDbName',
		dbName => 'myDbName',
	},
];

plan tests => 2;

my $dbLink = WebGUI::DatabaseLink->new($session, 0);
is($dbLink->get->{DSN}, $session->config->get('dsn'), 'DSN set correctly for default database link');
my ($databaseName) = $session->db->quickArray('SELECT DATABASE()');
is ($dbLink->databaseName, $databaseName, 'databaseName parsed default DSN from config file');

END {
	foreach my $link ($dbLink, ) {
		$link->delete if (defined $link and ref $link eq 'WebGUI::DatabaseLink');
	}
}
