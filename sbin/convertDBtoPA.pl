our ($webguiRoot, $configFile);

BEGIN {
        $configFile = "WebGUI.conf";
        $webguiRoot = "..";
        unshift (@INC, $webguiRoot."/lib");
}

print 	"\n\n\nThis program converts the old userauthentication system to the new (pluggable) one.\n" .
	"It does NOT delete the old system so you can always go back to a stable WebGUI release.\n".
	"If you don't want this functionality you should delete the 'ldapURL', 'connectDN' and the 'identifier' columns ".
	"from the users table\n\n";

print	"Opening WebGUI Session...";

use strict;
use WebGUI;
use WebGUI::SQL;
use WebGUI::Session;

# Open a session for easy use of WebGUI::SQL
WebGUI::Session::open($webguiRoot, $configFile);
print	"Ready\n\n";

# Create the authentication table
my $sql;
print "Creating authentication table...";
my $sql = "create table authentication (userId int(11) not null, authMethod varchar(30) not null, fieldName varchar(128) not null, fieldData text, primary key (userId, authMethod, fieldName))";
WebGUI::SQL->write($sql);
print "OK\n\n";

# And go convert
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
