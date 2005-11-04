package WebGUI::Session;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2005 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use DBI;
use Exporter;
use strict;
use Tie::CPHash;
use WebGUI::Config;
use WebGUI::ErrorHandler;
use WebGUI::Id;
use WebGUI::Cache;
use WebGUI::Setting;
use WebGUI::SQL;
use WebGUI::User;
use WebGUI::Utility;
use URI::Escape;

our @ISA = qw(Exporter);
our @EXPORT = qw(%session);
our %session = ();
tie %session, 'Tie::CPHash';


=head1 NAME

Package WebGUI::Session

=head1 DESCRIPTION

This package is the heart and lifeblood of WebGUI. Without it WebGUI could not exist. By using this package a package gains access to WebGUI's $session variable which contains everything WebGUI needs to know to operate.

B<NOTE:> It is important to distinguish the difference between a WebGUI session and a user session. A user session is attached to a WebGUI session. A WebGUI session is all of the basic data the WebGUI needs to operate.

TIP: The $session variable is a case-insensitive hash. The contents of the has vary, but can be seen by adding debug=1 to the end of any WebGUI URL while logged in as an admin user.

=head1 SYNOPSIS

 use WebGUI::Session;
 WebGUI::Session::close();
 WebGUI::Session::convertVisitorToUser($sessionId,$userId);
 WebGUI::Session::deleteAllScratch($name);
 WebGUI::Session::deleteScratch($name);
 WebGUI::Session::end($sessionId);
 WebGUI::Session::open($webguiRoot,$configFilename);
 WebGUI::Session::refreshPageInfo($pageId);
 WebGUI::Session::refreshSessionVars($sessionId);
 WebGUI::Session::refreshUserInfo($userId);
 WebGUI::Session::setScratch($name,$value);
 WebGUI::Session::start($userId);

=head1 METHODS

These subroutines are available from this package:

=cut



#-------------------------------------------------------------------
sub _setupSessionVars {
	my (%vars, $uid);
	tie %vars, 'Tie::CPHash';
	if ($_[0] ne "") {
		%vars = WebGUI::SQL->quickHash("select * from userSession where sessionId=".quote($_[0]));
		if ($vars{expires} < time() ) { #|| $vars{lastIP} ne $session{env}{REMOTE_ADDR}) { # had to remove for revolving ip proxies
			%vars = ();
			WebGUI::Session::end($_[0]);
		}
		if ($vars{sessionId} ne "") {
			$session{scratch} = WebGUI::SQL->buildHashRef("select name,value from userSessionScratch
                		where sessionId=".quote($_[0]));
			WebGUI::SQL->write("update userSession set lastPageView=".time().", lastIP='$session{env}{REMOTE_ADDR}', 
				expires=".(time()+$session{setting}{sessionTimeout})." where sessionId='$_[0]'");
		} else {
			$vars{sessionId} = start(1,$_[0]);
                }
	}
	$session{var} = \%vars;
}

#-------------------------------------------------------------------
sub _setupUserInfo {
	my $u = WebGUI::User->new(shift);
	%{$session{user}} = (%{$u->{_profile}}, %{$u->{_user}});
       #	$session{req}->user($session{user}{username});
	$session{user}{alias} = $session{user}{username} if ($session{user}{alias} =~ /^\W+$/ || $session{user}{alias} eq "");
}


#-------------------------------------------------------------------
# This routine returns an unique session Id.
sub _uniqueSessionId {
	my $sessionId = WebGUI::Id::generate();
	my ($isDuplicate) = WebGUI::SQL->buildArray("select count(*) from userSession where sessionId =".quote($sessionId));
	if ($isDuplicate) {
		return _uniqueSessionId();
	} else {
		return $sessionId;
	}
}
#-------------------------------------------------------------------

=head2 close

Cleans up a WebGUI session information from memory and disconnects from any resources opened by the session.

=cut

sub close {
	$session{asset}->DESTROY() if (exists $session{asset} && $session{asset} ne "");
	foreach my $slavedbh (@{$session{slave}}) {
		$slavedbh->disconnect();
	}
	$session{dbh}->disconnect() if (exists $session{dbh});
	undef %session;
}

#-------------------------------------------------------------------
sub DESTROY {
	WebGUI::Session::close();
}

#-------------------------------------------------------------------

=head2 convertVisitorToUser ( sessionId, userId )

Converts a visitor session to a user session.

=head3 sessionId

The session to convert.

=head3 userId

The user for the session to become.

=cut

sub convertVisitorToUser {
	WebGUI::SQL->write("update userSession set userId=".quote($_[1])." where sessionId=".quote($_[0]));
	if ($session{setting}{passiveProfilingEnabled}) {
		WebGUI::SQL->write("update passiveProfileLog set userId = ".quote($_[1])." where sessionId = ".quote($_[0]));
	}	
	delete $session{isInGroup};		# decache some performance enhancers because we're
	delete $session{gotGroupsForUser};       # user ids.
	$session{var}{userId} = $_[1];
	refreshUserInfo($_[1]);
}

#-------------------------------------------------------------------

=head2 deleteAllScratch ( name )

Deletes a scratch variable for all users. This function must be used with care.

=head3 name

The name of the scratch variable.

=cut

sub deleteAllScratch {
        my ($name) = @_;
        return "" if ($name eq "");
        WebGUI::SQL->write("delete from userSessionScratch where name=".quote($name));
        $session{scratch}{$name} = "";
}

#-------------------------------------------------------------------

=head2 deleteScratch ( name )

Deletes a scratch variable.

=head3 name

The name of the scratch variable.

=cut

sub deleteScratch {
	my ($name) = @_;
	return "" unless ($session{var}{sessionId} ne "" && $name ne "");
	WebGUI::SQL->write("delete from userSessionScratch where sessionId=".quote($session{var}{sessionId})." and name=".quote($name));
	$session{scratch}{$name} = "";
}

#-------------------------------------------------------------------

=head2 end ( sessionId ) 

Removes the specified user session from memory and database.

=head3 sessionId

The session to end.

=cut

sub end {
	WebGUI::SQL->write("delete from userSession where sessionId=".quote($_[0]),$session{dbh});
	WebGUI::SQL->write("delete from userSessionScratch where sessionId=".quote($_[0]),$session{dbh});
	if ($_[0] eq $session{var}{sessionId}) {
		delete $session{user};
		delete $session{isInGroup};
		delete $session{var};
		delete $session{scratch};
	}
}


#-------------------------------------------------------------------

=head2 getScratch ( varName ) 

Retrieves the current value of a scratch variable.

=head3 varName

The name of the variable set with setScratch().

=cut

sub getScratch {
	my $var = shift;
	return $session{scratch}{$var};
}

#-------------------------------------------------------------------

=head2 isAdminOn  ( )

Returns a boolean indicating whether admin mode is on or not.

=cut

sub isAdminOn {
	return $session{var}{adminOn};	
}

#-------------------------------------------------------------------

=head2 open ( webguiRoot, configFile [ , fastcgi ] )

Opens a closed ( or new ) WebGUI session.

=head3 webguiRoot

The path to the WebGUI files.

=head3 configFile

The filename of the config file that WebGUI should operate from.

=head3 fastcgi

A pointer to a Fast CGI object.

=cut

sub open {
	my $webguiRoot = shift;
	my $configFile = shift;
	my ($key);
	###----------------------------
	### operating system specific things
	$session{os}{name} = $^O;
	if ($session{os}{name} =~ /MSWin32/i || $session{os}{name} =~ /^Win/i) {
		$session{os}{type} = "Windowsish";
		$session{os}{slash} = "\\";
	} else {
		$session{os}{type} = "Linuxish";
		$session{os}{slash} = "/";
	}
	###----------------------------
	### config variables
	$session{config} = WebGUI::Config::getConfig($webguiRoot,$configFile);
	###----------------------------
	### default database handler object
	$session{dbh} = DBI->connect($session{config}{dsn},$session{config}{dbuser},$session{config}{dbpass},{ RaiseError=>0,AutoCommit=>1 });
	if ( $session{config}{dsn} =~ /Oracle/ ) { # Set Oracle specific attributes
		$session{dbh}->{LongReadLen} = 512 * 1024;
		$session{dbh}->{LongTruncOk} = 1;
	}
	foreach (1..3) {
		if ($session{config}{"dbslave".$_}) {
			push(@{$session{slave}},DBI->connect($session{config}{"dbslave".$_}{dsn},$session{config}{"dbslave".$_}{user},$session{config}{"dbslave".$_}{pass}));
		}
	}
	###----------------------------
	### evironment variables from web server
	$session{env} = \%ENV;
	###----------------------------
	### global system settings (from settings table)
	$session{setting} = WebGUI::Setting::get();

	###----------------------------
	### session variables 
	if ($session{cookie}{wgSession} eq "") {
		start(1); #setting up a visitor session
	} else {
		_setupSessionVars($session{cookie}{wgSession});
	}
	###----------------------------
	### current user's account and profile information (from users and userProfileData tables)
	_setupUserInfo($session{var}{userId});
}

#-------------------------------------------------------------------

=head2 refreshPageInfo ( asset ) 

Updates the WebGUI session to reflect new asset information.

=head3 asset

Specify which asset you want to change to.

=cut

sub refreshPageInfo {
	my $self = shift;
	$session{asset} = $self;
}

#-------------------------------------------------------------------

=head2 refreshSessionVars ( sessionId )

Updates the user session variables from the database.

B<NOTE:> This also updates the user information.

=head3 sessionId

The session id to update.

=cut

sub refreshSessionVars {
	_setupSessionVars($_[0]);
	refreshUserInfo($session{var}{userId});
}

#-------------------------------------------------------------------

=head2 refreshUserInfo ( userId ) 

Refreshes the user's information from the database into this user session.

=head3 userId

 The user id to refresh into this session.

=cut

sub refreshUserInfo {
	my $userId = shift;
	WebGUI::Cache->new(["user",$userId])->delete;
	_setupUserInfo($userId);
	$session{isInGroup} = ();
}


#-------------------------------------------------------------------

=head2 setScratch ( name, value )

Sets a scratch variable for this user session. Scratch variables are just arbitrary bits of data that a programmer may wish to store in a user session from page to page.

=head3 name

The name of the scratch variable.

=head3 value

The value of the scratch variable. If the value is blank but defined or if it is set to "-delete-" then the scratch variable will be removed from the user session.

=cut

sub setScratch {
	my ($name, $value) = @_;
	return "" unless ($session{var}{sessionId} ne "" && $name ne "" && defined $value);
	if ($value eq "-delete-" || (defined $value && $value eq "")) {
		deleteScratch($name);
		$value = "";
	} elsif ($session{scratch}{$name} ne "") {
		WebGUI::SQL->write("update userSessionScratch set value=".quote($value)."
			where sessionId=".quote($session{var}{sessionId})." and name=".quote($name));
	} else {
		WebGUI::SQL->write("insert into userSessionScratch (sessionId,name,value) values 
			(".quote($session{var}{sessionId}).", ".quote($name).", ".quote($value).")");
	}
	$session{scratch}{$name} = $value;
}

#-------------------------------------------------------------------

=head2 start ( userId [ , sessionId ] )

Start a new user session.

=head3 userId

The user id of the user to create a session for.

=head3 sessionId

Session id will be generated if not specified. In almost every case you should let the system generate the session id.

=cut

sub start {
	my ($sessionId);
	$sessionId = $_[1] || _uniqueSessionId();
	WebGUI::SQL->write("insert into userSession values ('$sessionId', ".
		(time()+$session{setting}{sessionTimeout}).", ".time().", 0, '$ENV{REMOTE_ADDR}', ".quote($_[0]).")");
	refreshSessionVars($sessionId);
	return $sessionId;
}

#-------------------------------------------------------------------

=head2 switchAdminOff ( )

Disables admin mode.

=cut

sub switchAdminOff {
	WebGUI::SQL->write("update userSession set adminOn=0 where sessionId='$session{var}{sessionId}'");
	refreshSessionVars($session{var}{sessionId});
}

#-------------------------------------------------------------------

=head2 switchAdminOn ( )

Enables admin mode.

=cut

sub switchAdminOn {
	WebGUI::SQL->write("update userSession set adminOn=1 where sessionId='$session{var}{sessionId}'");
	refreshSessionVars($session{var}{sessionId});
}

1;
