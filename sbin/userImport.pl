#!/usr/bin/env perl

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Digest::MD5;
use Getopt::Long;
use Pod::Usage;
use WebGUI::Paths -inc;
use WebGUI::DateTime;
use WebGUI::Group;
use WebGUI::Session;
use WebGUI::User;

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
my $session = WebGUI::Session->open($configFile);
$session->user({userId=>3});
open(FILE,"<".$usersFile) || die("Could not open $usersFile for reading: $!");
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
            $session->log->fatal("Authentication module failed to compile: $mod.".$@) if($@);
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
            if ($field ~~ @profileFields) {
                $u->update({$field => $user{$field}});
            }
        }
        if ($user{groups}) {
            my @groups = split(/,/,$user{groups});
            # Groups that have : in them have unique expiration dates
            $u->addToGroups([grep { !/:/ } @groups],$user{expireOffset});
            for my $groupDef ( grep { /:/ } @groups ) {
                my ( $groupId, $expireDate ) = split /:/, $groupDef, 2;

                # Calculate expiration offset
                my $dtparse = DateTime::Format::Strptime->new(
                    pattern     => '%F %T',
                    on_error    => 'croak',
                );

                eval { 
                    my $expireOffset = $dtparse->parse_datetime( $expireDate )->epoch - time;
                    $u->addToGroups( [$groupId], $expireOffset );
                };
                if ( $@ ) {
                    print "Could not add user $user{username} to group $groupId: $@";
                }
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
        }
        else {
            return $seconds;
        }
    }
    if ($units eq "fixed") {
        my $seconds = (($offset - time()));
        if ($seconds < 1) {
            return undef;
        }
        else {
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
superuser privileges, use the B<--override> option described below.

The user information is given in a simple TAB-delimited text file,
that describes both the field names and field data for each user. You
can change de actual delimiter with the B<--delimiter> option (see below).

The first line of the file contains the field names whose values are
going to be loaded. From then on, all non-blank lines in the file must have
the same number of fields. All-blank lines are ignored. The valid field
names are:

=over

=item B<username>
=item B<password>
=item B<authMethod>
=item B<status>
=item B<ldapUrl>
=item B<connectDN>
=item B<groups>
=item B<expireOffset>
=item Any valid User Profile field name available in WebGUI's database,
      e.g. B<firstName>, B<lastName>, B<mail>, etc.

=back

If you use the field B<groups>, each following line  should contain a comma
separated list of WebGUI Group Ids; note that this could be a problem
if you chose to use comma as a delimiter for fields.

If no username is specified it will default to B<firstName.lastName>. If
no B<username> is specified, nor B<firstName> and B<lastName>, then the
user will B<not> be loaded.

If you specify the B<userId> field for import on any record, that B<userId>
will be used instead of generating a new one automatically. If you do this,
be careful not to insert duplicates!

If you use an invalid field name, its values will be ignored.

=over

=item B<--configFile config.conf>

The WebGUI config file to use. Only the file name needs to be specified,
since it will be looked up inside WebGUI's configuration directory.
This parameter is required.

=item B<--usersFile pathname>

Pathname to the file containing users information for bulk loading.

=item B<--authMethod method>

Specify the default authentication method to set for each loaded user.
It can be overridden in the import file for specific users.
If left unspecified, it defaults to B<WebGUI>.

=item B<--canChangePass>

Set loaded users to be able to change their passwords. If left
unspecified, loaded users will B<NOT> be able to change their
passwords until and administrator grants them the privilege.

=item B<--delimiter string>

Specify the string delimiting fields in the import file. If left
unspecified, it defaults to a single TAB (ASCII 9).

=item B<--expireOffset integer>

Specify the default amount of time before the loaded user will be
expired from the groups they are added to. The units are specified
by B<--expireUnits> (see below). It can be overridden in the import
file for specific users. If left unspecified, it defaults to the
expire offset set in the group definition within WebGUI.

=item B<--expireUnits unidades>

Specify the units for B<--expireOffset> (see above). Valid values
are B<seconds>, B<minutes>, B<hours>, B<days>, B<weeks>, B<months>,
B<years>, B<epoch>, or B<fixed>. If set to B<epoch> the system will
assume that the expire offset should be taken as an epoch date
(absolute number of seconds since January 1, 1970) rather than an
interval. If set to B<fixed> the system will assume that the
B<--expireOffset> is a fixed date. If left unspecified, it defaults
to B<seconds>.

=item B<--groups groupid,...>

Specify a comma separated list of WebGUI Group Ids that each loaded
user will be set to. It can be overridden in the import file for
specific users.

You can specify a unique expiration date for a group by adding it
after the group ID, separated by a colon. The date/time should be in
"YYYY-MM-DD HH:NN:SS" format.

 groupId:2000-01-01 01:00:00,groupId2:2001-01-02 02:00:00

=item B<--ldapUrl uri>

Specify the URI used to connect to the LDAP server for authentication.
The URI must conform to what L<Net::LDAP> uses for connecting.
It can be overridden in the import file for specific users.

=item B<--password string>
=item B<--identifier string>

Specify the default password to use for loaded users. It can (and should)
be overridden in the import file for specific users. If left unspecified,
it defaults to B<123qwe>.

=item B<--status status>

Specify the default account status for loaded users. Valid values are
B<Active> and B<Deactivated>. If left unspecified, it defaults to
B<Active>.

=item B<--update>

Search WebGUI's database for each user listed in the import file, and
update its information using the provided fields. Users in the import
file that are B<not> found in the database are B<ignored>. See
B<--updateAdd> below if you want to add the extra users.

=item B<--updateAdd>

Search WebGUI's database for each user listed in the import file, and
update its information using the provided fields. Users in the import
file that are B<not> found in the database are B<added>. See
B<--update> above if you do not want to add the extra users.

=item B<--replaceGroups>

If the user being updated with B<--update> or B<--updateAdd> already
belongs to some other groups, remove the user from them.

=item B<--override>

This flag will allow you to run this utility without being the super user,
but note that it may not work as intended.

=item B<--quiet>

Disable all output unless there's an error.

=item B<--help>

Shows this documentation, then exits.

=back

=head1 AUTHOR

Copyright 2001-2012 Plain Black Corporation.

=cut
