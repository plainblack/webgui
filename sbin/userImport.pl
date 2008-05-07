#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2007 Plain Black Corporation.
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

use strict;
use Digest::MD5;
use Getopt::Long;
use WebGUI::DateTime;
use WebGUI::Group;
use WebGUI::Session;
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
my $expireOffset;
my $expireUnits = 'seconds';
my $override;
my $quiet;
my $update;
my $updateAdd;
my $replaceGroups;
my $canChangePass;

GetOptions(
	'usersfile=s'=>\$usersFile,
	'configfile=s'=>\$configFile,
	'help'=>\$help,
	'authMethod:s'=>\$authMethod,
	'delimiter:s'=>\$delimiter,
	'password|identifier:s'=>\$defaultIdentifier,
	'groups:s'=>\$groups,
	'ldapUrl:s'=>\$ldapUrl,
	'quiet'=>\$quiet,
	'status:s'=>\$status,
	'expireOffset:i'=>\$expireOffset,
	'expireUnits:s'=>\$expireUnits,
	'override'=>\$override,
	'update'=>\$update,
	'updateAdd'=>\$updateAdd,
	'replaceGroups'=>\$replaceGroups,
	'canChangePass'=>\$canChangePass
);





unless ($usersFile && $configFile && !$help) {
	print <<STOP;


Usage: perl $0 --usersfile=<pathToFile> --configfile=<webguiConfig>

	--usersFile	File (and path) containing import information.

	--configFile	WebGUI config file (with no path info). 


Options:

	--authMethod	The authentication method to be used for
			each user. Defaults to 'WebGUI'. Can be
			overridden in the import file.

	--canChangePass	If this flag is set users will be able to change
			their passwords.  Otherwise not.

	--delimiter	The string that separates each field in the
			import file. Defaults to tab.

	--expireOffset	The the amount of time before the user will
			be expired from the groups they are added
			to. Defaults to the expire offset set in
			the group definition within WebGUI. May be
			overridden in the import file.

	--expireUnits	Valid values are "seconds", "minutes",
			"hours", "days", "weeks", "months", "years",
			"epoch", or "fixed". Defaults to "seconds". This is 
			the units of the expire offset. If set to
			"epoch" the system will assume that the
			expire offset is an epoch date rather than
			an interval.  If set to "fixed" the 
			system will assume that the expireDate is
			a fixed date.

	--groups	A comma separated list of group ids that
			each user in the import file will be set
			to. Can be overridden in the import file.

	--help		Display this help message.

	--identifier	Alias for --password.  

	--ldapUrl	The URL used to connect to the LDAP server
			for authentication. Can be overridden in
			the import file.

	--override      This utility is designed to be run as
                        a privileged user on Linux style systems.
                        If you wish to run this utility without
                        being the super user, then use this flag,
                        but note that it may not work as
                        intended.

	--password	The default password to use when none is 
			specified with the user. Defaults to 
			'123qwe'. Can be overridden in the import
			file.

	--quiet         Disable output unless there's an error.

	--status	The user's account status. Defaults to
			'Active'. Other valid value is 'Deactivated'.
	
	--update	looks up all the users from the file in the database
				and updates all the given fields for each user that 
				exists in the database. users that are in the file
				and not in the database are ignored.
				
	--updateAdd	looks up the users from the file in the database
				and updates all the given fields for each user that
				exists in the database. users who do not exist in the
				database are added as new users.
				
	--replaceGroups	when updating, if the user already belongs to some group
					this flag will delete all the user's existing groups and
					and the new groups to him/her


User File Format:

	-Tab delimited fields (unless overridden with --delimiter).

	-First row contains field names.

	-Valid field names:
	
		username password authMethod status
		ldapUrl connectDN groups expireOffset

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

	-If userId is specified for an import record, that userId
        be used instead of generating one.

STOP
	exit;
}


if (!($^O =~ /^Win/i) && $> != 0 && !$override) {
        print "You must be the super user to use this utility.\n";
        exit;
}



print "Starting up..." unless ($quiet);
my $session = WebGUI::Session->open($webguiRoot,$configFile);
$session->user({userId=>3});
open(FILE,"<".$usersFile);
print "OK\n" unless ($quiet);

my $lineNumber = 0;
my @field;
my @profileFields = $session->db->buildArray("select fieldName from userProfileField");
while(my $line = <FILE>) {
    $lineNumber++;
    chomp $line;
    next
        if $line eq '';
    my @row = split($delimiter, $line);
    use Data::Dumper ();
    chomp @row;
    if ($lineNumber == 1) {
        @field = @row;
        next;
    }
    # parse fields
    my %user;
    foreach my $item (@row) {
        $item =~ s/\s+$//;
    }
    @user{@field} = @row;
    if ($user{username} eq "" && $user{firstName} ne "" && $user{lastName} ne "") {
        $user{username} = $user{firstName}.".".$user{lastName};
    }
    elsif ($user{username} eq '') {
        print "Skipping line ${lineNumber}: No username.\n" unless ($quiet); 
        next;
    }

    $user{identifier} ||= $user{password}
        if $user{password};
    $user{ldapUrl} ||= $ldapUrl
        if $ldapUrl;
    $user{authMethod} ||= $authMethod
        if $authMethod;
    $user{groups} ||= $groups
        if $groups;
    $user{status} ||= $status
        if $status;
    $user{expireOffset} ||= $expireOffset
        if $expireOffset;
    $user{expireOffset} = calculateExpireOffset($user{expireOffset},$expireUnits)
        if $user{expireOffset};
    $user{birthdate} = WebGUI::DateTime->new($user{birthdate}." 00:00:00")->epoch()
        if $user{birthdate};
    $user{changePassword} ||= $canChangePass
        if $user{changePassword} == '';
    # process user
    my $u;
    my ($userId) = $session->db->quickArray("select userid from users where username=?",[$user{username}]);
    if (($update || $updateAdd) && $userId) {
        # Allowed to update, and user exists
        print "Updating user '$user{username}'\n" unless ($quiet);
        $u = WebGUI::User->new($session, $userId);
        if ($replaceGroups && $user{groups}) {
            my $groups = $u->getGroups;
            $u->deleteFromGroups(@$groups);
        }
    }
    elsif ($update) {
        # Can only update, user doesn't exist
        print "User '$user{username}' not found. Skipping.\n" unless ($quiet); 
        next;
    }
    elsif ($userId) {
        print "User '$user{username}' already exists. Skipping.\n" unless ($quiet); 
        next;
    }
    else {
        # Allowed to add, user doesn't exist
        print "Adding user '$user{username}'\n" unless ($quiet); 
        $u = WebGUI::User->new($session, "new");
        $user{identifier} ||= $defaultIdentifier
    }
    $user{identifier} = Digest::MD5::md5_base64($user{identifier})
        if ($user{identifier});
    if ($u) {
        $u->username($user{username});
        $u->authMethod($user{authMethod})
            if $user{authMethod};
        $u->status($user{status})
            if $user{status};
        my $class = "WebGUI::Auth::".$authMethod;
        (my $mod = "$class.pm") =~ s{::|'}{/}g;
        if (! eval { require $mod; 1 } ) {
            $session->errorHandler->fatal("Authentication module failed to compile: $class.".$@) if($@);
            exit;
        }
        my $auth = $class->new($session, $authMethod,$u->userId);
        $auth->saveParams($u->userId,"WebGUI",{identifier=>$user{identifier}})
            if $user{identifier};
        $auth->saveParams($u->userId,"LDAP",{ldapUrl=>$user{ldapUrl}})
            if $user{ldapUrl};
        $auth->saveParams($u->userId,"LDAP",{connectDN=>$user{connectDN}})
            if $user{connectDN};
        $auth->saveParams($u->userId,"WebGUI",{changePassword=>$user{changePassword}});
        foreach my $field (keys %user) {
            if (isIn($field, @profileFields)) {
                $u->profileField($field,$user{$field});
            }
        }
        if ($user{groups}) {
            my @groups = split(/,/,$user{groups});
            $u->addToGroups(\@groups,$user{expireOffset});
        }
    }
}
print "Cleaning up..." unless ($quiet);
close(FILE);
$session->var->end;
$session->close;
print "OK\n" unless ($quiet);


#-------------------------------------------------
# calculateExpireOffset(expireOffset,expireUnits)
# return: offsetInSeconds
sub calculateExpireOffset {
    my ($offset, $units) = @_;
    return undef if ($offset < 1);
    if ($units eq "epoch") {
        my $seconds = ($offset);
        if ($seconds < 1) {
            return undef;
        }
        else {
            return $seconds;
        }
    }
    if ($units eq "fixed") {
        my $seconds = (($offset - $session->datetime->time()));
        if ($seconds < 1) {
            return undef;
        }
        else {
            return int($seconds);
        }
    }
    return $session->datetime->intervalToSeconds($offset, $units)
}

