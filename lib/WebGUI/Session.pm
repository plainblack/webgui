package WebGUI::Session;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2003 Plain Black LLC.
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
use Parse::PlainConfig;
use strict;
use Tie::CPHash;
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
 WebGUI::Session::end($sessionId);
 $header = WebGUI::Session::httpHeader();
 $header = WebGUI::Session::httpRedirect($url);
 WebGUI::Session::open($webguiRoot,$configFilename);
 WebGUI::Session::refreshPageInfo($pageId);
 WebGUI::Session::refreshSessionVars($sessionId);
 WebGUI::Session::refreshUserInfo($userId);
 WebGUI::Session::setCookie($name,$value);
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
		#$pageName =~ s/\///g;
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
						$r->custom_response(404, $session{page}{url} );
						$r->status(404);
					}
				} else {
					$session{header}{status} = '404';
				}
			}
		} else {
			$pageId = $session{setting}{defaultPage};
		}
	}
	%page = WebGUI::SQL->quickHash("select * from page where pageId='".$pageId."'");
	$page{url} = $session{config}{scripturl}."/".$page{urlizedTitle};
	$session{page} = \%page;
}

#-------------------------------------------------------------------
sub _setupSessionVars {
	my (%vars, $uid, $encryptedPassword);
	tie %vars, 'Tie::CPHash';
	if ($_[0] ne "") {
		%vars = WebGUI::SQL->quickHash("select * from userSession where sessionId='$_[0]'");
		if ($vars{sessionId} ne "") {
			$session{scratch} = WebGUI::SQL->buildHashRef("select name,value from userSessionScratch
                		where sessionId=".quote($_[0]));
			WebGUI::SQL->write("update userSession set lastPageView="._time().", lastIP='$ENV{REMOTE_ADDR}', 
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
		$user{alias} = $user{username};
		%profile = WebGUI::SQL->buildHash("select userProfileField.fieldName, userProfileData.fieldData 
			from userProfileData, userProfileField where userProfileData.fieldName=userProfileField.fieldName 
			and userProfileData.userId='$user{userId}'");
		%user = (%user, %profile);
		$user{language} = $session{page}{languageId} if ($user{userId} == 1);
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
	}
}

#-------------------------------------------------------------------
sub _time {
	return Date::Calc::Date_to_Time(Date::Calc::Today_and_Now());
}


#-------------------------------------------------------------------
sub _loadAuthentication {
	my ($dir, @files, $file, $cmd, $namespace, $exclude);
	$dir = $session{config}{webguiRoot}.$session{os}{slash}."lib".$session{os}{slash}."WebGUI".$session{os}{slash}."Authentication";
	opendir (DIR,$dir) or WebGUI::ErrorHandler::fatalError("Can't open Authentication module directory!");
	@files = readdir(DIR);
	foreach $file (@files) {
		if ($file =~ /(.*?)\.pm$/) {
			$namespace = $1;
			$cmd = "use WebGUI::Authentication::".$namespace;
			eval($cmd);
			unless ($@) {
				$exclude = $session{config}{excludeAuthentication};
                        	$exclude =~ s/ //g;
				unless (isIn($namespace, split(/,/,$exclude))) {
					$session{authentication}{$namespace} = $namespace;
				}
			} else {
				WebGUI::ErrorHandler::warn("Authentication module failed to compile: $namespace. ".$@);
				$session{authentication}{failed} .= "[".$namespace."] ";
			}
		}
	}
	closedir(DIR);
}

#-------------------------------------------------------------------
sub _loadMacros {
	foreach my $key (keys %{$session{config}{macros}}) {
		my $cmd = "use WebGUI::Macro::".$session{config}{macros}{$key};
		eval($cmd);
		WebGUI::ErrorHandler::fatalError("Macro failed to compile: $key.".$@) if($@);
	}
}

#-------------------------------------------------------------------
sub _loadWobjects {
	foreach my $namespace (@{$session{config}{wobjects}}) {
		my $cmd = "use WebGUI::Wobject::".$namespace;
		eval($cmd);
		if ($@) {
			WebGUI::ErrorHandler::warn("Wobject failed to compile: $namespace. ".$@);
		}
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
	$session{var}{userId} = $_[1];
	refreshUserInfo($_[1]);
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

=head2 httpHeader ( ) 

Generates an HTTP header.

=cut

sub httpHeader {
	unless ($session{header}{charset}) {
		$session{header}{charset} = $session{language}{characterSet} || "ISO-8859-1";
	}
	if ($session{header}{filename} && $session{header}{mimetype} eq "text/html") {
		$session{header}{mimetype} = "application/octet-stream";
	}
	return $session{cgi}->header( 
		-type => $session{header}{mimetype}.'; charset='.$session{header}{charset},
		-cookie => $session{header}{cookie}, 
		-status => $session{header}{status},
		-attachment => $session{header}{filename}
		);
}

#-------------------------------------------------------------------

=head2 httpRedirect ( url )

Generates an HTTP header for redirect.

=over

=item url

The URL to redirect to.

=back

=cut

sub httpRedirect {

	return $session{cgi}->redirect($_[0]);
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
	my ($key, $config);
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
	$session{config}{webguiRoot} = $_[0];
	$session{config}{configFile} = $_[1] || "WebGUI.conf";
	$config = Parse::PlainConfig->new('DELIM' => '=', 
		'FILE' => $session{config}{webguiRoot}.'/etc/'.$session{config}{configFile}, 
		'PURGE' => 1);
        foreach ($config->directives) {
                $session{config}{$_} = $config->get($_);
        }
	if( defined( $session{config}{scripturl} ) ) {
		# get rid of leading "/" if present.
		$session{config}{scripturl} =~ s/^\///;
	} else {
		# default to the "real" path to script.
		$session{config}{scripturl} = $ENV{SCRIPT_NAME};
	}
	$session{config}{extrasURL} = $session{config}{extrasURL} || $session{config}{extras} || "/extras";
	$session{config}{extras} = $session{config}{extras} || $session{config}{extrasURL}; # for backward compatibility
	$session{config}{extrasPath} = $session{config}{extrasPath} || "/data/WebGUI/www/extras";
	###----------------------------
	### default database handler object
	$session{dbh} = DBI->connect($session{config}{dsn},$session{config}{dbuser},$session{config}{dbpass},{ RaiseError=>0,AutoCommit=>1 });
	if ( $session{config}{dsn} =~ /Oracle/ ) { # Set Oracle specific attributes
		$session{dbh}->{LongReadLen} = 512 * 1024;
		$session{dbh}->{LongTruncOk} = 1;
	}
	###----------------------------
	### global system settings (from settings table)
	$session{setting} = WebGUI::SQL->buildHashRef("select name,value from settings");
	###----------------------------
	### CGI object
	$CGI::POST_MAX=1024 * $session{setting}{maxAttachmentSize};
	$session{cgi} = CGI->new();
        if ($session{cgi}->cgi_error =~ /^413/) {
		$session{header}{status} = $session{cgi}->cgi_error;
		WebGUI::ErrorHandler::warn("File upload too big. May need to adjust Max File Size setting.");
		$CGI::POST_MAX=-1;
		$session{cgi} = CGI->new();
        }
	###----------------------------
	### header variables
	$session{header}{mimetype} = 'text/html';
	###----------------------------
	### evironment variables from web server
	$session{env} = \%ENV;
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
	###----------------------------
	### language settings
	$session{language} = WebGUI::SQL->quickHashRef("select * from language where languageId=$session{user}{language}");
	###----------------------------
	### loading plugins
	_loadWobjects();
	_loadMacros();
	_loadAuthentication();  
}

#-------------------------------------------------------------------

=head2 refreshPageInfo ( [ pageId ] ) 

Updates the WebGUI session to reflect new page information.

=over

=item pageId

Defaults to page id "1". Specify the page id to change this WebGUI session to use.

=back

=cut

sub refreshPageInfo {
	my ($pageId);
	if ($_[0] == 0) {
		$pageId = 1;
	} else {
		$pageId = $_[0];
	}
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

=head2 setCookie ( name, value [ , timeToLive ] ) 

Sends a cookie to the browser.

=over

=item name

The name of the cookie to set. Must be unique from all other cookies from this domain or it will overwrite that cookie.

=item value

The value to set.

=item timeToLive

The time that the cookie should remain in the browser. Defaults to "+10y" (10 years from now).

=back

=cut

sub setCookie {
        my $ttl = $_[2] || '+10y';
        #my $domain = $session{env}{SERVER_NAME} if ($session{env}{HTTP_USER_AGENT} =~ m/MSIE/i);
	my $domain;
        push @{$session{header}{cookie}}, $session{cgi}->cookie(
                -name=>$_[0],
                -value=>$_[1],
                -expires=>$ttl,
                -path=>'/',
                -domain=>$domain
                );
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
		WebGUI::SQL->write("delete from userSessionScratch where sessionId=".quote($session{var}{sessionId})
			." and name=".quote($name));
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
	$sessionId = $_[1] || crypt((_time()*rand(1000)),rand(99));
	WebGUI::SQL->write("insert into userSession values ('$sessionId', ".
		(_time()+$session{setting}{sessionTimeout}).", "._time().", 0, '$ENV{REMOTE_ADDR}', $_[0])");
	setCookie("wgSession",$sessionId);
	refreshSessionVars($sessionId);
}

1;
