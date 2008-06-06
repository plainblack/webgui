#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
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
use Pod::Usage;
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
	'usersFile=s'=>\$usersFile,
	'configFile=s'=>\$configFile,
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

pod2usage( verbose => 2 ) if $help;
pod2usage() unless ($usersFile && $configFile);

if (!($^O =~ /^Win/i) && $> != 0 && !$override) {
        print "You must be the super user to use this utility.\n";
        exit;
}



print "Starting up..." unless ($quiet);
my $session = WebGUI::Session->open($webguiRoot,$configFile);
$session->user({userId=>3});
open(FILE,"<".$usersFile);
print "OK\n" unless ($quiet);

my $first = 1;
my $lineNumber = 0;
my @field;
my @profileFields = $session->db->buildArray("select fieldName from userProfileField");
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

		if ($user{username} eq "" && $user{firstName} ne "" && $user{lastName} ne "") {
			$user{username} = $user{firstName}.".".$user{lastName};
		}
                if ($user{password} eq "") {
                        $user{identifier} = $defaultIdentifier;
                } else {
                        $user{identifier} = $user{password};
                }
		$user{identifier} = Digest::MD5::md5_base64($user{identifier});
		$user{ldapUrl} = $ldapUrl if ($user{ldapUrl} eq "");
		$user{authMethod} = $authMethod if ($user{authMethod} eq "");
		$user{groups} = $groups if ($user{groups} eq "");
		$user{status} = $status if ($user{status} eq "");
		$user{expireOffset} = $expireOffset if ($user{expireOffset} eq "");
		$user{expireOffset} = calculateExpireOffset($user{expireOffset},$expireUnits);
        if ($user{birthdate}) {
            $user{birthdate} = WebGUI::DateTime->new($user{birthdate}." 00:00:00")->epoch();
        }
               if ($user{changePassword} eq "") {
                       if ($canChangePass) {
                               $user{changePassword} = 1;
                       } else {
                               $user{changePassword} = 0;
                       }
               }
		# process user
               my $u;
               my $queryHandler;
               my ($duplicate) = $session->db->quickArray("select userid from users where username=?",[$user{username}]);
               if ($user{username} eq "") { 
			print "Skipping line $lineNumber.\n" unless ($quiet); 
		} else {
                       # update only
                       if ($update) {
                               if ($duplicate) {
                                       print "Updating user $user{username}\n" unless ($quiet);
                                       $u = WebGUI::User->new($session, $duplicate);
                                       if ($replaceGroups and ($user{groups} ne "")) {
                                               $queryHandler = $session->db->prepare("delete from groupings where userid=?",[$duplicate]);
                                               if ($queryHandler) { $queryHandler->execute(); }
                                       }
                                       my ($pw) = $session->db->quickArray("select authentication.fieldData from authentication,users where authentication.authMethod='WebGUI' and users.username=? and users.userId=authentication.userId and authentication.fieldName='identifier'",[$user{username}]);
                                       $user{identifier} = $pw;
                               } else { 
					print "User $user{username} not found. Skipping.\n" unless ($quiet); 
				}
                       } elsif ($updateAdd) {     # update and add users 
                               if ($duplicate) {
                                       print "Updating user $user{username}\n" unless ($quiet);
                                       $u = WebGUI::User->new($session, $duplicate);
                                       if ($replaceGroups and ($user{groups} ne "")) {
                                               $queryHandler = $session->db->prepare("delete from groupings where userid=?",[$duplicate]);
                                               if ($queryHandler) { $queryHandler->execute(); }
                                       }
                                       my ($pw) = $session->db->quickArray("select authentication.fieldData from authentication,users where authentication.authMethod='WebGUI' and users.username=? and users.userId=authentication.userId and authentication.fieldName='identifier'",[$user{username}]);
                                       $user{identifier} = $pw;
                               } else { 
					$u = WebGUI::User->new($session, "new"); 
					print "Adding user $user{username}\n" unless ($quiet); 
				}
                       } else {    # add users only 
                               if ($duplicate) { 
					print "User $user{username} already exists. Skipping.\n" unless ($quiet); 
                               	} else { 
					$u = WebGUI::User->new($session, "new"); 
					print "Adding user $user{username}\n" unless ($quiet); 
				}
                       }
               }
               if ($u) {
 			$u->username($user{username});
			$u->authMethod($user{authMethod});
			$u->status($user{status});
			my $cmd = "WebGUI::Auth::".$authMethod;
        		my $load = "use ".$cmd;
        		$session->log->fatal("Authentication module failed to compile: $cmd.".$@) if($@);
        		eval($load);
    			my $auth = eval{$cmd->new($session, $authMethod,$u->userId)};
			$auth->saveParams($u->userId,"WebGUI",{identifier=>$user{identifier}});
			$auth->saveParams($u->userId,"LDAP",{
				ldapUrl=>$user{ldapUrl},
				connectDN=>$user{connectDN}
				});
			$auth->saveParams($u->userId,"WebGUI",{changePassword=>$user{changePassword}});
			foreach (keys %user) {
				if (isIn($_, @profileFields)) {
					$u->profileField($_,$user{$_});
				}
			}
			if ($user{groups} ne "") {
				my @groups = split(/,/,$user{groups});
				$u->addToGroups(\@groups,$user{expireOffset});
			}
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
		} else {
			return $seconds;
		}
	}
        if ($units eq "fixed") {
                my $seconds = (($offset - $session->datetime->time()));
                if ($seconds < 1) {
                        return undef;
                } else {
                        return int($seconds);
                }
        }
	return $session->datetime->intervalToSeconds($offset, $units)
}

__END__

=head1 NAME

userImport - Bulk load users into WebGUI database

=head1 SYNOPSIS

 userImport --configFile config.conf --usersFile pathname
            [--authMethod method]
            [--canChangePasswd]
            [--delimiter string]
            [--expireOffset integer [--expireUnits string]]
            [--groups groupid,...]
            [--ldapUrl uri]
            [--password text]
            [--status status]
            [--override]
            [--quiet]
            [--update | --updateAdd]
            [--replaceGroups]

 userImport --help

=head1 DESCRIPTION

This WebGUI utility script reads user information from a text file
and loads them into the specified WebGUI database. Default user
parameters can be specified through command line options, taking
overriding values from the file.

This utility is designed to be run as a superuser on Linux systems,
since it needs to be able to put files into WebGUI's data directories
and change ownership of files. If you want to run this utility without
superuser privileges, use the C<--override> option described below.

The user information is given in a simple TAB-delimited text file,
that describes both the field names and field data for each user. You
can change de actual delimiter with the C<--delimiter> option (see below).

The first line of the file contains the field names whose values are
going to be loaded. From then on, all non-blank lines in the file must have
the same number of fields. All-blank lines are ignored. The valid field
names are:

=over

=item C<username>
=item C<password>
=item C<authMethod>
=item C<status>
=item C<ldapUrl>
=item C<connectDN>
=item C<groups>
=item C<expireOffset>
=item Any valid User Profile field name available in WebGUI's database,
      e.g. C<firstName>, C<lastName>, C<mail>, etc.

=back

If you use the field C<groups>, each following line  should contain a comma
separated list of WebGUI Group Ids; note that this could be a problem
if you chose to use comma as a delimiter for fields.

If no username is specified it will default to C<firstName.lastName>. If
no C<username> is specified, nor C<firstName> and C<lastName>, then the
user will B<not> be loaded.

If you specify the C<userId> field for import on any record, that C<userId>
will be used instead of generating a new one automatically. If you do this,
be careful not to insert duplicates!

If you use an invalid field name, its values will be ignored.

=over

=item C<--configFile config.conf>

The WebGUI config file to use. Only the file name needs to be specified,
since it will be looked up inside WebGUI's configuration directory.
This parameter is required.

=item C<--usersFile pathname>

Pathname to the file containing users information for bulk loading.

=item C<--authMethod method>

Specify the default authentication method to set for each loaded user.
It can be overridden in the import file for specific users.
If left unspecified, it defaults to C<WebGUI>.

=item C<--canChangePass>

Set loaded users to be able to change their passwords. If left
unspecified, loaded users will B<NOT> be able to change their
passwords until and administrator grants them the privilege.

=item C<--delimiter string>

Specify the string delimiting fields in the import file. If left
unspecified, it defaults to a single TAB (ASCII 9).

=item C<--expireOffset integer>

Specify the default amount of time before the loaded user will be
expired from the groups they are added to. The units are specified
by C<--expireUnits> (see below). It can be overridden in the import
file for specific users. If left unspecified, it defaults to the
expire offset set in the group definition within WebGUI.

=item C<--expireUnits unidades>

Specify the units for C<--expireOffset> (see above). Valid values
are C<seconds>, C<minutes>, C<hours>, C<days>, C<weeks>, C<months>,
C<years>, C<epoch>, or C<fixed>. If set to C<epoch> the system will
assume that the expire offset should be taken as an epoch date
(absolute number of seconds since January 1, 1970) rather than an
interval. If set to C<fixed> the system will assume that the
C<--expireOffset> is a fixed date. If left unspecified, it defaults
to C<seconds>.

=item C<--groups groupid,...>

Specify a comma separated list of WebGUI Group Ids that each loaded
user will be set to. It can be overridden in the import file for
specific users.

=item C<--ldapUrl uri>

Specify the URI used to connect to the LDAP server for authentication.
The URI must conform to what L<Net::LDAP> uses for connecting.
It can be overridden in the import file for specific users.

=item C<--password string>
=item C<--identifier string>

Specify the default password to use for loaded users. It can (and should)
be overriden in the import file for specific users. If left unspecified,
it defaults to C<123qwe>.

=item C<--status status>

Specify the default account status for loaded users. Valid values are
C<Active> and C<Deactivated>. If left unspecified, it defaults to
C<Active>.

=item C<--update>

Search WebGUI's database for each user listed in the import file, and
update its information using the provided fields. Users in the import
file that are B<not> found in the database are B<ignored>. See
C<--updateAdd> below if you want to add the extra users.

=item C<--updateAdd>

Search WebGUI's database for each user listed in the import file, and
update its information using the provided fields. Users in the import
file that are B<not> found in the database are B<added>. See
C<--update> above if you do not want to add the extra users.

=item C<--replaceGroups>

If the user being updated with C<--update> or C<--updateAdd> already
belongs to some other groups, remove the user from them.

=item C<--override>

This flag will allow you to run this utility without being the super user,
but note that it may not work as intended.

=item C<--quiet>

Disable all output unless there's an error.

=item C<--help>

Shows this documentation, then exits.

=back

=head1 AUTHOR

Copyright 2001-2008 Plain Black Corporation.

=cut
