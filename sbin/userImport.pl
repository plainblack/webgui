#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------


our ($slash, $webguiRoot, $usersFile, $configFile, $defaultIdentifier);

BEGIN { 
	$slash = ($^O =~ /Win/i) ? "\\" : "/";
	$webguiRoot = "..";
	$usersFile = $ARGV[0];
	$configFile = $ARGV[1];
	$defaultIdentifier = $ARGV[2] || "password";
	unshift (@INC, $webguiRoot.$slash."lib"); 
}

unless ($usersFile ne "" && $configFile ne "") {
	print "\nUsage: $0 <pathToUserFile> <webguiConfigFile> [ <defaultIdentifier> ]\n\n";
	print "User file format:\n";
	print "\t-Tab delimited fields.\n";
	print "\t-First row contains field names.\n";
	print "\t-Valid field names:\n";
	print "\t\tusername password authMethod ldapURL connectDN\n";
	print "\t\tfirstName middleName lastName gender birthdate\n";
	print "\t\temail icq aim msnIM yahooIM cellPhone pager emailToPager\n";
	print "\t\thomeAddress homeCity homeState homeZip homeCountry homePhone homeURL\n";
	print "\t\tworkName workAddress workCity workState workZip workCountry workPhone workURL\n";
	print "\t\ttimeOffset dateFormat timeFormat language discussionLayout INBOXNotifications\n";
	print "\t\tgroups\n";
	print "\t-The special field name 'groups' should contain a comma separated list of group ids.\n";
	print "\n";
	print "Special cases:\n";
	print "\t-If no username is specified it will default to 'firstName.lastName'.\n";
	print "\t-If firstName and lastName or username are not specified, user will be skipped.\n";
	print "\t-If no identifier is specified, the default identifier will be used.\n";
	print "\t-If no default identifier is specified 'password' will be used.\n";
	print "\t-If no authMethod is specified 'WebGUI' will be used.\n";
	print "\t-Invalid field names will be ignored.\n";
	print "\t-Blank lines will be ignored.\n";
	print "\n";
	exit;
}

use strict;
use Data::Config;
use WebGUI::SQL;
use Digest::MD5 qw(md5_base64);

$|=1;

print "Starting...\n";

my ($i, $dbh, @row, %user, @field, $userId, $first, $dup, $lineNumber, $expireAfter, @group);
$first = 1;
$dbh = connectToDb();
open(FILE,"<".$usersFile);
while(<FILE>) {
	$lineNumber++;
	%user = ();
  	chomp;
  	@row = split("\t",$_);
  	$i=0;
	if ($first) {
                foreach (@row) {
                        chomp;
                        $field[$i] = $_;
                        $i++;
                }
		$first = 0;
	} else {
  		foreach (@row) {
    			chomp;
    			$user{$field[$i]} = $_;
			$user{$field[$i]} =~ s/\s+$//g; #remove trailing whitespace from each field
    			$i++;
  		}
		$user{username} = $user{firstName}.".".$user{lastName} if ($user{username} eq "" && $user{firstName} ne "" && $user{lastName} ne "");
		$user{identifier} = $defaultIdentifier if ($user{password} eq "");
		$user{authMethod} = "WebGUI" if ($user{authMethod} eq "");
		$user{identifier} = Digest::MD5::md5_base64($user{identifier});
		($dup) = WebGUI::SQL->quickArray("select count(*) from users where username=".$dbh->quote($user{username}),$dbh);
  		if ($user{username} eq "") {
    			print "Skipping line $lineNumber.\n";
		} elsif ($dup) {
			print "User $user{username} already exists. Skipping.\n";
		} else {
    			print "Adding user $user{username}\n";
    			$user{userId} = getUserId($dbh);
    			WebGUI::SQL->write("insert into users (userId,username,authMethod,dateCreated,lastUpdated) values 
				($user{userId},".$dbh->quote($user{username}).", ".$dbh->quote($user{authMethod}).",
				".time().",".time().")",$dbh);
			foreach (keys %user) {
				if (isIn($_, qw(discussionLayout INBOXNotifications gender birthdate timeOffset dateFormat timeFormat email language firstName middleName lastName icq aim msnIM yahooIM cellPhone pager emailToPager homeAddress homeCity homeState homeZip homeCountry homePhone homeURL workName workAddress workCity workState workZip workCountry workPhone workURL))) {
					WebGUI::SQL->write("insert into userProfileData (userId, fieldName, fieldData) values
						($user{userId}, '$_', ".$dbh->quote($user{$_}).")",$dbh);
				}
				if ($_ eq "identifier") {
					WebGUI::SQL->write("insert into authentication (userId,authMethod,fieldName,fieldData)
						values ($user{userId},'WebGUI','$_',".$dbh->quote($user{$_}).")");
				}
                                if (isIn($_, qw(ldapURL connectDN))) {
                                        WebGUI::SQL->write("insert into authentication (userId,authMethod,fieldName,fieldData)
                                                values ($user{userId},'LDAP','$_',".$dbh->quote($user{$_}).")");
                                }
			}
			($expireAfter) = WebGUI::SQL->quickArray("select expireAfter from groups where groupId=2",$dbh);
			$user{groups} =~ s/ //g;
			@group = split(/,/,$user{groups});
			foreach (@group) {
				($expireAfter) = WebGUI::SQL->quickArray("select expireAfter from groups where groupId=$_",$dbh);
				WebGUI::SQL->write("insert into groupings (groupId,userId,expireDate) values 
					($user{userId},$_,".(time()+$expireAfter).")",$dbh);
			}
  		}
	}
}
print "Cleaning up...\n";
close(FILE);
$dbh->disconnect;
print "Finished.\n";


#-----------------------------------------
sub connectToDb {
  	print "Connecting to database.\n";
  	my ($config, $dbh, $error);
  	$config = new Data::Config $webguiRoot.'/etc/'.$configFile;
  	$dbh = DBI->connect($config->param("dsn"), $config->param("dbuser"), $config->param("dbpass"), { RaiseError => 0, AutoCommit => 1 }) or $error=1;
  	unless ($error) {
    		print "Connection established.\n";
    		return $dbh;
  	} else {
    		print "Error: Could not connect to the database.\n";
    		exit;
  	}
}

#-----------------------------------------
sub isIn {
  	my ($i, @a, @b, @isect, %union, %isect, $e);
  	foreach $e (@_) {
    		if ($a[0] eq "") {
      			$a[0] = $e;
    		} else {
      			$b[$i] = $e;
      			$i++;
    		}
  	}
  	foreach $e (@a, @b) { $union{$e}++ && $isect{$e}++ }
  	@isect = keys %isect;
  	if (defined @isect) {
    		undef @isect;
    		return 1;
  	} else {
    		return 0;
  	}
}

#-----------------------------------------
sub getUserId {
  	my ($id);
  	($id) = WebGUI::SQL->quickArray("select nextValue from incrementer where incrementerId='userId'",$_[0]);
  	WebGUI::SQL->write("update incrementer set nextValue=nextValue+1 where incrementerId='userId'",$_[0]);
  	return $id;
}



