#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2003 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

our ($webguiRoot);

BEGIN { 
	$webguiRoot = "..";
	unshift (@INC, $webguiRoot."/lib"); 
}

use Digest::MD5;
use Getopt::Long;
use strict;
use WebGUI::Grouping;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::User;
use WebGUI::Utility;

$|=1;

my $delimiter = "\t";
my $usersFile;
my $configFile;
my $defaultIdentifier = '123qwe';
my $help;
my $authMethod = 'WebGUI';
my $groups;
my $ldapUrl;
my $status = 'Active';

GetOptions(
	'usersfile=s'=>\$usersFile,
	'configfile=s'=>\$configFile,
	'help'=>\$help,
	'authMethod:s'=>\$authMethod,
	'delimiter:s'=>\$delimiter,
	'password|identifier:s'=>\$defaultIdentifier,
	'groups:s'=>\$groups,
	'ldapUrl:s'=>\$ldapUrl,
	'status:s'=>\$status
);





unless ($usersFile && $configFile && !$help) {
	print <<STOP;


Usage: $0 --userfile=<pathToFile> --configfile=<webguiConfig>

	--usersFile	File containing import information.

	--configFile	WebGUI config file.


Options:

	--authMethod	The authentication method to be used for
			each user. Defaults to 'WebGUI'. Can be
			overridden in the import file.

	--delimiter	The string that separates each field in the
			import file. Defaults to tab.

	--groups	A comma separated list of group ids that
			each user in the import file will be set
			to. Can be overridden in the import file.

	--help		Display this help message.

	--identifier	Alias for --password.  

	--ldapUrl	The URL used to connect to the LDAP server
			for authentication. Can be overridden in
			the import file.

	--password	The default password to use when none is 
			specified with the user. Defaults to 
			'123qwe'. Can be overridden in the import
			file.

	--status	The user's account status. Defaults to
			'Active'. Other valid value is 'Deactivated'.


User File Format:

	-Tab delimited fields (unless overridden with --delimiter).

	-First row contains field names.

	-Valid field names:
	
		username password authMethod status
		ldapUrl connectDN groups

	-In addition to the field names above, you may use any 
	valid profile field name.
	
	-The special field name 'groups' should contain a comma 
	separated list of group ids.


Special Cases:

	-If no username is specified it will default to 
	'firstName.lastName'.

	-If firstName and lastName or username are not specified, 
	the user will be skipped.

	-Invalid field names will be ignored.

	-Blank lines will be ignored.

STOP
	exit;
}


print "Starting up...";
WebGUI::Session::open($webguiRoot,$configFile);
WebGUI::Session::refreshUserInfo(3); # The script should run as admin.
open(FILE,"<".$usersFile);
print "OK\n";

my $first = 1;
my $lineNumber = 0;
my @field;
my @profileFields = WebGUI::SQL->buildArray("select fieldName from userProfileField");
while(<FILE>) {
	$lineNumber++;
  	chomp;
  	my @row = split($delimiter,$_);
  	my $i=0;
	if ($first) {
		# parse field headers
                foreach (@row) {
                        chomp;
                        $field[$i] = $_;
                        $i++;
                }
		$first = 0;

	} else {
		# parse fields
		my %user = ();
  		foreach (@row) {
    			chomp;
    			$user{$field[$i]} = $_;
			$user{$field[$i]} =~ s/\s+$//g; #remove trailing whitespace from each field
    			$i++;
  		}

		# deal with defaults and overrides
		if ($user{username} eq "" && $user{firstName} ne "" && $user{lastName} ne "") {
			$user{username} = $user{firstName}.".".$user{lastName};
		}
		$user{identifier} = $defaultIdentifier if ($user{password} eq "");
		$user{identifier} = Digest::MD5::md5_base64($user{identifier});
		$user{ldapUrl} = $ldapUrl if ($user{ldapUrl} eq "");
		$user{authMethod} = $authMethod if ($user{authMethod} eq "");
		$user{groups} = $groups if ($user{groups} eq "");
		$user{status} = $status if ($user{status} eq "");

		# process user
		my ($duplicate) = WebGUI::SQL->quickArray("select count(*) from users where username=".quote($user{username}));
  		if ($user{username} eq "") {
    			print "Skipping line $lineNumber.\n";
		} elsif ($duplicate) {
			print "User $user{username} already exists. Skipping.\n";
		} else {
    			print "Adding user $user{username}\n";
			my $u = WebGUI::User->new("new");
			$u->username($user{username});
			$u->authMethod($user{authMethod});
			$u->status($user{status});
			WebGUI::Authentication::saveParams($u->userId,"WebGUI",{identifier=>$user{identifier}});
			WebGUI::Authentication::saveParams($u->userId,"LDAP",{
				ldapUrl=>$user{ldapUrl},
				connectDN=>$user{connectDN}
				});
			foreach (keys %user) {
				if (isIn($_, @profileFields)) {
					$u->profileField($_,$user{$_});
				}
			}
			if ($user{groups} ne "") {
				my @groups = split(/,/,$user{groups});
				$u->addToGroups(\@groups);
			}
  		}
	}
}
print "Cleaning up...";
close(FILE);
WebGUI::Session::close();
print "OK\n";





