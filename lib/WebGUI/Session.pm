package WebGUI::Session;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2004 Plain Black LLC.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut


use CGI;
use Date::Calc;
use DBI;
use Exporter;
use strict;
use Tie::CPHash;
use WebGUI::Config;
use WebGUI::ErrorHandler;
use WebGUI::SQL;
use WebGUI::Utility;

our @ISA = qw(Exporter);
our @EXPORT = qw(%session);
our %session = ();
tie %session, 'Tie::CPHash';


=head1 NAME

Package WebGUI::Session

=head1 DESCRIPTION

This package is the heart and lifeblood of WebGUI. Without it WebGUI could not exist. By using this package a package gains access to WebGUI's $session variable which contains everything WebGUI needs to know to operate.

NOTE: It is important to distinguish the difference between a WebGUI session and a user session. A user session is attached to a WebGUI session. A WebGUI session is all of the basic data the WebGUI needs to operate.

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
sub _setupPageInfo {
	my (%page, $pageId, $pageName);
	tie %page, 'Tie::CPHash';
	($pageId) = $_[0];
	if ($pageId eq "") {
		$pageName = lc($ENV{PATH_INFO});
		$pageName =~ s/\/$//;
		$pageName =~ s/\///;
		$pageName =~ s/\'//;
		$pageName =~ s/\"//;
		if ($pageName ne "") {
			($pageId) = WebGUI::SQL->quickArray("select pageId from page where urlizedTitle='".$pageName."'");
			if ($pageId eq "") {
				$pageId = $session{setting}{notFoundPage};
				if($ENV{"MOD_PERL"}) {
					my $r = Apache->request;
					if(defined($r)) {
						$r->custom_response(404, $pageName);
						$r->status(404);
					}
				} else {
					$session{http}{status} = '404';
				}
			}
		} else {
			$pageId = $session{setting}{defaultPage};
		}
	}
	%page = WebGUI::SQL->quickHash("select * from page where pageId='".$pageId."'");
	$session{page} = \%page;
}

#-------------------------------------------------------------------
sub _setupSessionVars {
	my (%vars, $uid, $encryptedPassword);
	tie %vars, 'Tie::CPHash';
	if ($_[0] ne "") {
		%vars = WebGUI::SQL->quickHash("select * from userSession where sessionId='$_[0]'");
		if ($vars{expires} < _time() ) { #|| $vars{lastIP} ne $session{env}{REMOTE_ADDR}) { # had to remove for revolving ip proxies
			%vars = ();
			WebGUI::Session::end($_[0]);
		}
		if ($vars{sessionId} ne "") {
			$session{scratch} = WebGUI::SQL->buildHashRef("select name,value from userSessionScratch
                		where sessionId=".quote($_[0]));
			WebGUI::SQL->write("update userSession set lastPageView="._time().", lastIP='$session{env}{REMOTE_ADDR}', 
				expires=".(_time()+$session{setting}{sessionTimeout})." where sessionId='$_[0]'");
		} else {
			start(1,$_[0]);
                }
	}
	$session{var} = \%vars;
}

#-------------------------------------------------------------------
sub _setupUserInfo {
	my (%default, $key, %user, $uid, %profile, $value);
	tie %user, 'Tie::CPHash';
	$uid = $_[0] || 1;
	%user = WebGUI::SQL->quickHash("select * from users where userId='$uid'");
	if ($user{userId} eq "") {
		_setupUserInfo("1");
	} else {
		%profile = WebGUI::SQL->buildHash("select userProfileField.fieldName, userProfileData.fieldData 
			from userProfileData, userProfileField where userProfileData.fieldName=userProfileField.fieldName 
			and userProfileData.userId='$user{userId}'");
		%user = (%user, %profile);
		$user{language} = $session{page}{languageId} if ($user{userId} == 1 || $user{language} eq '');
		%default = WebGUI::SQL->buildHash("select fieldName, dataDefault from userProfileField 
			where profileCategoryId=4");
		foreach $key (keys %default) {
			if ($user{$key} eq "") {
				$value = eval($default{$key});
				if (ref $value eq "ARRAY") {
					$user{$key} = $$value[0];
				} else {
					$user{$key} = $value;
				}
			}
		}
		$session{user} = \%user;
		if ($session{env}{MOD_PERL}) {
               		my $r = Apache->request;
               		if(defined($r)) {
                       		$r->user($session{user}{username});
               		}
       		}
		$session{user}{alias} = $session{user}{username} if ($session{user}{alias} =~ /^\W+$/);
		$session{user}{alias} = $session{user}{username} if ($session{user}{alias} eq "");
	}
}

#-------------------------------------------------------------------
sub _time {
	return Date::Calc::Date_to_Time(Date::Calc::Today_and_Now());
}


#-------------------------------------------------------------------
# This routine returns an unique session Id.
sub _uniqueSessionId {
	my $sessionId = crypt((_time()*rand(1000)),rand(99));
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
	$session{'dbh'}->disconnect();
	undef %session;
	$ENV{PATH_INFO} = "/"; #work around to fix a bug in mod_perl (win32)
}

#-------------------------------------------------------------------

=head2 convertVisitorToUser ( sessionId, userId )

Converts a visitor session to a user session.

=over

=item sessionId

The session to convert.

=item userId

The user for the session to become.

=back

=cut

sub convertVisitorToUser {
	WebGUI::SQL->write("update userSession set userId=$_[1] where sessionId=".quote($_[0]));
	if ($session{setting}{passiveProfilingEnabled}) {
		WebGUI::SQL->write("update passiveProfileLog set userId = ".quote($_[1])." where sessionId = ".quote($_[0]));
	}	
	undef $session{isInGroup};		# decache some performance enhancers because we're
	undef $session{gotGroupsForUser};       # user ids.
	$session{var}{userId} = $_[1];
	refreshUserInfo($_[1]);
}

#-------------------------------------------------------------------

=head2 deleteAllScratch ( name )

Deletes a scratch variable for all users. This function must be used with care.

=over

=item name

The name of the scratch variable.

=back

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

=over

=item name

The name of the scratch variable.

=back

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

=over

=item sessionId

The session to end.

=back

=cut

sub end {
	WebGUI::SQL->write("delete from userSession where sessionId='$_[0]'",$session{dbh});
	WebGUI::SQL->write("delete from userSessionScratch where sessionId='$_[0]'",$session{dbh});
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

=over

=item varName

The name of the variable set with setScratch().

=back

=cut

sub getScratch {
	my $var = shift;
	return $session{scratch}{$var};
}

#-------------------------------------------------------------------

=head2 open ( webguiRoot [ , configFile ] )

Opens a closed ( or new ) WebGUI session.

=over

=item webguiRoot

The path to the WebGUI files.

=item configFile

The filename of the config file that WebGUI should operate from.

=back

=cut

sub open {
	my $webguiRoot = shift;
	my $configFile = shift;
	my ($key);
	###----------------------------
	### operating system specific things
	$session{os}{name} = $^O;
	if ($session{os}{name} =~ /^Win/i) {
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
	### global system settings (from settings table)
	$session{setting} = WebGUI::SQL->buildHashRef("select name,value from settings");
	###----------------------------
	### CGI object
	$CGI::POST_MAX=1024 * $session{setting}{maxAttachmentSize};
	$session{cgi} = CGI->new();
        if ($session{cgi}->cgi_error =~ /^413/) {
		$session{http}{status} = $session{cgi}->cgi_error;
		WebGUI::ErrorHandler::warn("File upload too big. May need to adjust Max File Size setting.");
		$CGI::POST_MAX=-1;
		$session{cgi} = CGI->new();
        }
	###----------------------------
	### evironment variables from web server
	$session{env} = \%ENV;
	### check to see if client is proxied and adjust remote_addr as necessary
	if (($session{setting}{proxiedClientAddress} eq "1") && ($ENV{HTTP_X_FORWARDED_FOR} ne "")) {
		$session{env}{REMOTE_ADDR} = $ENV{HTTP_X_FORWARDED_FOR};
	}
	###----------------------------
	### form variables
	foreach ($session{cgi}->param) {
		$session{form}{$_} = $session{cgi}->param($_);
	}
	###----------------------------
	### cookies
	foreach ($session{cgi}->cookie) {
		$session{cookie}{$_} = $session{cgi}->cookie($_);
	}
	###----------------------------
	### session variables 
	if ($session{cookie}{wgSession} eq "") {
		start(1); #setting up a visitor session
	} else {
		_setupSessionVars($session{cookie}{wgSession});
	}
        ###----------------------------
        ### current page's properties (from page table)
        _setupPageInfo("");
	###----------------------------
	### current user's account and profile information (from users and userProfileData tables)
	_setupUserInfo($session{var}{userId});
}

#-------------------------------------------------------------------

=head2 refreshPageInfo ( [ pageId ] ) 

Updates the WebGUI session to reflect new page information.

=over

=item pageId

Defaults to the current page. Specify the page id to change this WebGUI session to use.

=back

=cut

sub refreshPageInfo {
	my $pageId = $_[0];
	_setupPageInfo($pageId);
}

#-------------------------------------------------------------------

=head2 refreshSessionVars ( sessionId )

Updates the user session variables from the database.

NOTE: This also updates the user information.

=over

=item sessionId

The session id to update.

=back

=cut

sub refreshSessionVars {
	_setupSessionVars($_[0]);
	refreshUserInfo($session{var}{userId});
}

#-------------------------------------------------------------------

=head2 refreshUserInfo ( userId ) 

Refreshes the user's information from the database into this user session.

=over

=item userId

 The user id to refresh into this session.

=back

=cut

sub refreshUserInfo {
	_setupUserInfo($_[0]);
	$session{isInGroup} = ();
}


#-------------------------------------------------------------------

=head2 setScratch ( name, value )

Sets a scratch variable for this user session. Scratch variables are just arbitrary bits of data that a programmer may wish to store in a user session from page to page.

=over

=item name

The name of the scratch variable.

=item value

The value of the scratch variable. If the value is blank but defined or if it is set to "-delete-" then the scratch variable will be removed from the user session.

=back

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

=over

=item userId

The user id of the user to create a session for.

=item sessionId

Session id will be generated if not specified. In almost every case you should let the system generate the session id.

=back

=cut

sub start {
	my ($sessionId);
	$sessionId = $_[1] || _uniqueSessionId();
	if (($session{setting}{proxiedClientAddress} eq "1") && ($ENV{HTTP_X_FORWARDED_FOR} ne "")) {
		WebGUI::SQL->write("insert into userSession values ('$sessionId', ".
			(_time()+$session{setting}{sessionTimeout}).", "._time().", 0, '$ENV{HTTP_X_FORWARDED_FOR}', $_[0])");
	} else {
		WebGUI::SQL->write("insert into userSession values ('$sessionId', ".
			(_time()+$session{setting}{sessionTimeout}).", "._time().", 0, '$ENV{REMOTE_ADDR}', $_[0])");
	}
	push @{$session{http}{cookie}}, $session{cgi}->cookie(
                -name=>"wgSession",
                -value=>$sessionId,
                -expires=>'+10y',
                -path=>'/'
                );
	refreshSessionVars($sessionId);
}

1;
