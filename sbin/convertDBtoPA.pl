our ($webguiRoot, $configFile);

BEGIN {
        $configFile = "WebGUI.conf";
        $webguiRoot = "..";
        unshift (@INC, $webguiRoot."/lib");
	print 	"\n".
		"This program converts the old userauthentication system to the new (pluggable)\n".
		"one. It does NOT delete the old system so you can always use an older stable\n". 
		"WebGUI release. If you don't want to return to the primitive days without\n".
		"pluggable authentication, you should delete the 'ldapURL', 'connectDN' and the\n".
		"'identifier' columns from the users table\n\n";
} 

use strict;
use WebGUI;
use WebGUI::SQL;
use WebGUI::Session;
use WebGUI::Utility;

#--- Open a session for easy use of WebGUI::SQL --------------------------
print "Opening WebGUI Session...";
WebGUI::Session::open($webguiRoot, $configFile);
print	"Ready\n\n";

#--- Check if the authentication table already exists --------------------
my @tables = WebGUI::SQL->buildArray("show tables");
die "Table 'authentication' already exists!\n" if isIn('authentication', @tables);

#--- Create the authentication table -------------------------------------
print "Creating authentication table...";
my $sql = "create table authentication (userId int(11) not null, authMethod varchar(30) not null, fieldName varchar(128) not null, fieldData text, primary key (userId, authMethod, fieldName))";
WebGUI::SQL->write($sql);
print "OK\n\n";

#--- And go convert ------------------------------------------------------
my $sth = WebGUI::SQL->read("select * from users");
while (my %hash = $sth->hash) {
	print "Converting user $hash{username} (id: $hash{userId})";
	WebGUI::SQL->write("insert into authentication values ($hash{userId}, 'LDAP',  'ldapUrl', ". quote($hash{ldapUrl}) .")");
	print ".";
	WebGUI::SQL->write("insert into authentication values ($hash{userId}, 'LDAP',  'connectDN', ". quote($hash{connectDN}) .")");
	print ".";
	WebGUI::SQL->write("insert into authentication values ($hash{userId}, 'WebGUI',  'identifier', ". quote($hash{identifier}) .")");
	print "OK\n";
	
}
