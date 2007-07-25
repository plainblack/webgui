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

#DSNs for parsing tests, particularly the database name
my $DSNs = [
	{
		dsn     => 'DBI:mysql:colonSeparated:myHost:8008',
		dbName  => 'colonSeparated',
        comment => 'explicit',
	},
	{
		dsn     => 'DBI:mysql:database=myDatabase',
		dbName  => 'myDatabase',
        comment => 'database=',
	},
	{
		dsn     => 'DBI:mysql:dbName=myDbName',
		dbName  => undef,
        comment => 'dbName=, bad capitalization',
	},
	{
		dsn     => 'DBI:mysql:dbname=mydbname',
		dbName  => 'mydbname',
        comment => 'dbname=',
	},
	{
		dsn     => 'DBI:mysql:dbnane=myDbName',
		dbName  => undef,
        comment => 'dbnane=, misspelling',
	},
	{
		dsn     => 'DBI:mysql:db=myDb',
		dbName  => 'myDb',
        comment => 'db=',
	},
];

#Grants for parsing tests, particularly the database name
my $grants = [
	{
		dsn        => 'DBI:mysql:myDb:myHost:8008',
		privileges => [qw/ALTER CREATE INSERT DELETE/],
        grants     => [
            'GRANT ALTER, CREATE, INSERT, DELETE ON *.* to user@localhost',
        ],
        privileged => 1,
        comment    => 'ACID on *.*, privileged',
	},
	{
		dsn        => 'DBI:mysql:myDb:myHost:8008',
		privileges => [qw/ALTER CREATE INSERT DELETE/],
        grants     => [
            'GRANT ALL PRIVILEGES ON *.* to user@localhost',
        ],
        privileged => 1,
        comment    => 'ALL PRIVILEGES on *.*, privileged',
	},
	{
		dsn        => 'DBI:mysql:myDb:myHost:8008',
		privileges => [qw/ALTER CREATE INSERT DELETE/],
        grants     => [
            'GRANT ALTER, CREATE, INSERT ON *.* to user@localhost',
        ],
        privileged => 0,
        comment    => 'Missing DELETE on *.*, unprivileged',
	},
	{
		dsn        => 'DBI:mysql:myDb:myHost:8008',
		privileges => [qw/ALTER CREATE INSERT DELETE/],
        grants     => [
            'GRANT ALL PRIVILEGES ON myDb.* to user@localhost',
        ],
        privileged => 1,
        comment    => 'ALL PRIVILEGES on explicit db name, privileged',
	},
	{
		dsn        => 'DBI:mysql:myDb:myHost:8008',
		privileges => [qw/ALTER CREATE INSERT DELETE/],
        grants     => [
            'GRANT ALL PRIVILEGES ON `myDb`.* to user@localhost',
        ],
        privileged => 1,
        comment    => 'ALL PRIVILEGES on quoted, explicit db name, privileged',
	},
	{
		dsn        => 'DBI:mysql:myDb:myHost:8008',
		privileges => [qw/ALTER CREATE INSERT DELETE/],
        grants     => [
            'GRANT ALL PRIVILEGES ON `my%`.* to user@localhost',
        ],
        privileged => 1,
        comment    => 'ALL PRIVILEGES on quoted, wildcard name, privileged',
	},
	{
		dsn        => 'DBI:mysql:yourDb:myHost:8008',
		privileges => [qw/ALTER CREATE INSERT DELETE/],
        grants     => [
            'GRANT ALL PRIVILEGES ON `my%`.* to user@localhost',
        ],
        privileged => 0,
        comment    => 'ALL PRIVILEGES on wrong db, unprivileged',
	},
];


plan tests => 2 + scalar @{ $DSNs } + scalar @{ $grants };

my $dbLink = WebGUI::DatabaseLink->new($session, 0);
is($dbLink->get->{DSN}, $session->config->get('dsn'), 'DSN set correctly for default database link');
my ($databaseName) = $session->db->quickArray('SELECT DATABASE()');
is ($dbLink->databaseName, $databaseName, 'databaseName parsed default DSN from config file');

foreach my $dsn (@{ $DSNs }) {
    my $dbl = WebGUI::DatabaseLink->create($session, { DSN => $dsn->{dsn} });
	is( $dbl->databaseName(), $dsn->{dbName}, $dsn->{comment} );
    $dbl->delete;
}

foreach my $grant (@{ $grants }) {
    my $dbl = WebGUI::DatabaseLink->create($session, { DSN => $grant->{dsn} });
	is(
        $dbl->checkPrivileges($grant->{privileges}, $grant->{grants}),
        $grant->{privileged},
        $grant->{comment}
    );
    $dbl->delete;
}

END {
	foreach my $link ($dbLink, ) {
		$link->delete if (defined $link and ref $link eq 'WebGUI::DatabaseLink');
	}
}
