package WebGUI::Session;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com			info@plainblack.com
#-------------------------------------------------------------------

use CGI;
use Data::Config;
use DBI;
use Exporter;
use strict;
use Tie::CPHash;
use WebGUI::ErrorHandler;
use WebGUI::SQL;
use WebGUI::Utility;

our @ISA = qw(Exporter);
our @EXPORT = qw(%session);
our %session = ();
tie %session, 'Tie::CPHash';

#-------------------------------------------------------------------
sub _generateSessionId {
	my ($sessionId);
	$sessionId = crypt(time(),rand(99));
	return $sessionId;
}

#-------------------------------------------------------------------
sub _getPageInfo {
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
			($pageId) = WebGUI::SQL->quickArray("select pageId from page where urlizedTitle='".$pageName."'",$_[1]);
			if ($pageId eq "") {
				$pageId = $_[2];
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
	%page = WebGUI::SQL->quickHash("select * from page where pageId='".$pageId."'",$_[1]);
	$page{url} = $_[3]."/".$page{urlizedTitle};
	return \%page;
}

#-------------------------------------------------------------------
sub _getSessionVars {
	my (%vars, $uid, $encryptedPassword);
	tie %vars, 'Tie::CPHash';
	if ($_[0] ne "") {
		%vars = WebGUI::SQL->quickHash("select * from userSession where sessionId='$_[0]'", $_[1]);
		if ($vars{sessionId} ne "") {
			WebGUI::SQL->write("update userSession set lastPageView=".time().", lastIP='$ENV{REMOTE_ADDR}', expires=".(time()+$_[2])." where sessionId='$_[0]'",$_[1]);
		}
	}
	return \%vars;
}

#-------------------------------------------------------------------
sub _getUserInfo {
	my (%default, $key, %user, $uid, %profile, $value);
	tie %user, 'Tie::CPHash';
	$uid = $_[0] || 1;
	%user = WebGUI::SQL->quickHash("select * from users where userId='$uid'", $_[1]);
	if ($user{userId} eq "") {
		%user = {_getUserInfo("1",$_[1])};
	}
	%profile = WebGUI::SQL->buildHash("select userProfileField.fieldName, userProfileData.fieldData 
		from userProfileData, userProfileField where userProfileData.fieldName=userProfileField.fieldName 
		and userProfileData.userId='$user{userId}'", $_[1]);
	%user = (%user, %profile);
	%default = WebGUI::SQL->buildHash("select fieldName, dataDefault from userProfileField where profileCategoryId=4", $_[1]);
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
	return \%user;
}

#-------------------------------------------------------------------
sub _loadMacros {
	my ($slash, $namespace, $cmd, @files, $file, $dir, $exclude);
	$slash = ($^O =~ /Win/i) ? "\\" : "/";
	$dir = $slash."lib".$slash."WebGUI".$slash."Macro";
	opendir (DIR,$session{config}{webguiRoot}.$dir) or WebGUI::ErrorHandler::fatalError("Can't open macro directory!");
	@files = readdir(DIR);
	foreach $file (@files) {
		if ($file =~ /(.*?)\.pm$/) {
			$namespace = $1;
			$cmd = "use WebGUI::Macro::".$1;
			eval($cmd);
			WebGUI::ErrorHandler::fatalError("Macro failed to compile: $namespace.".$@) if($@);
			$exclude = $session{config}{excludeMacro};
                        $exclude =~ s/ //g;
                        unless (isIn($namespace, split(/,/,$exclude))) {
				$session{macro}{$namespace} = $namespace;
			}
		}
	}
	closedir(DIR);
}

#-------------------------------------------------------------------
sub _loadWobjects {
	my ($dir, @files, $slash, $file, $cmd, $namespace, $exclude);
	$slash = ($^O =~ /Win/i) ? "\\" : "/";
	$dir = $slash."lib".$slash."WebGUI".$slash."Wobject";
	opendir (DIR,$session{config}{webguiRoot}.$dir) or WebGUI::ErrorHandler::fatalError("Can't open wobject directory!");
	@files = readdir(DIR);
	foreach $file (@files) {
		if ($file =~ /(.*?)\.pm$/) {
			$namespace = $1;
			$cmd = "use WebGUI::Wobject::".$namespace;
			eval($cmd);
			unless ($@) {
				$exclude = $session{config}{excludeWobject};
                        	$exclude =~ s/ //g;
				next if (isIn($namespace, split(/,/,$exclude)));
				$cmd = "WebGUI::Wobject::".$namespace."::uiLevel";
				next if (eval($cmd) > $session{user}{uiLevel});	
				$cmd = "\$WebGUI::Wobject::".$namespace."::name";
				$session{wobject}{$namespace} = eval($cmd);
				if ($@) {
					WebGUI::ErrorHandler::warn("No name method in wobject: $namespace. ".$@);
					$session{wobject}{$namespace} = "ERROR: ".$namespace;
				}
			} else {
				WebGUI::ErrorHandler::warn("Wobject failed to compile: $namespace. ".$@);
				$session{wobject}{$namespace} = "ERROR: ".$namespace;
			}
		}
	}
	closedir(DIR);
}

#-------------------------------------------------------------------
sub close {
	$session{'dbh'}->disconnect();
	undef %session;
	$ENV{PATH_INFO} = "/"; #work around to fix a bug in mod_perl (win32)
}

#-------------------------------------------------------------------
sub end {
	WebGUI::SQL->write("delete from userSession where sessionId='$_[0]'",$session{dbh});
	if ($_[0] eq $session{var}{sessionId}) {
		refreshSessionVars();
	}
}

#-------------------------------------------------------------------
sub httpHeader {
	unless ($session{header}{charset}) {
		my ($charset) = WebGUI::SQL->quickArray("select characterSet from language where languageId=".$session{user}{language});
		$session{header}{charset} = $charset || "ISO-8859-1";
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
sub httpRedirect {
	return $session{cgi}->redirect($_[0]);
}

#-------------------------------------------------------------------
sub open {
	my ($key, $config);
	###----------------------------
	### config variables
	$session{config}{webguiRoot} = $_[0];
	$session{config}{configFile} = $_[1] || "WebGUI.conf";
	$config = new Data::Config $session{config}{webguiRoot}.'/etc/'.$session{config}{configFile};
	foreach ($config->param) {
		$session{config}{$_} = $config->param($_);
	}
	if( defined( $session{config}{scripturl} ) ) {
		# get rid of leading "/" if present.
		$session{config}{scripturl} =~ s/^\///;
	} else {
		# default to the "real" path to script.
		$session{config}{scripturl} = $ENV{SCRIPT_NAME};
	}
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
	### session variables (from userSession table)
	$session{var} = _getSessionVars($session{cookie}{wgSession},$session{dbh},$session{setting}{sessionTimeout});
	###----------------------------
	### session scratch variables (from userSessionScratch table)
	$session{scratch} = WebGUI::SQL->buildHashRef("select name,value from userSessionScratch 
		where sessionId=".quote($session{var}{sessionId}));
	###----------------------------
	### current user's account and profile information (from users and userProfileData tables)
	$session{user} = _getUserInfo($session{var}{userId},$session{dbh});
	if ($session{env}{MOD_PERL}) {
                my $r = Apache->request;
                if(defined($r)) {
			$r->user($session{user}{username}); 
		}
	}
	###----------------------------
	### current page's properties (from page table)
	$session{page} = _getPageInfo("",$session{dbh},$session{setting}{notFoundPage},$session{config}{scripturl});
	###----------------------------
	### language settings
	$session{language} = WebGUI::SQL->quickHashRef("select * from language where languageId=$session{user}{language}");
	###----------------------------
	### loading plugins
	_loadWobjects();
	_loadMacros();
}

#-------------------------------------------------------------------
sub refreshPageInfo {
	my ($pageId);
	if ($_[0] == 0) {
		$pageId = 1;
	} else {
		$pageId = $_[0];
	}
	$session{page} = _getPageInfo($pageId,$session{dbh},$session{setting}{notFoundPage},$session{config}{scripturl});
}

#-------------------------------------------------------------------
sub refreshSessionVars {
	$session{var} = _getSessionVars($_[0],$session{dbh},$session{setting}{sessionTimeout});
	refreshUserInfo($session{var}{userId});
}

#-------------------------------------------------------------------
sub refreshUserInfo {
	$session{user} = _getUserInfo($_[0],$session{dbh});
}

#-------------------------------------------------------------------
sub setCookie {
	push @{$session{header}{cookie}}, $session{cgi}->cookie(-name=>$_[0], -value=>$_[1], -expires=>'+10y', -path=>'/');
}

#-------------------------------------------------------------------

=head2 setScratch ( name, value )

 Sets a scratch variable for this user session.

=cut

sub setScratch {
	return "" unless ($session{var}{sessionId});
	if ($session{scratch}{$_[0]}) {
		WebGUI::SQL->write("update userSessionScratch set value=".quote($_[1])."
			where sessionId=".quote($session{var}{sessionId})." and name=".quote($_[0]));
	} else {
		WebGUI::SQL->write("insert into userSessionScratch (sessionId,name,value) values 
			(".quote($session{var}{sessionId}).", ".quote($_[0]).", ".quote($_[1]).")");
	}
	$session{scratch}{$_[0]} = $_[1];
}

#-------------------------------------------------------------------
sub start {
	my ($sessionId);
	$sessionId = _generateSessionId();
	WebGUI::SQL->write("insert into userSession values ('$sessionId', ".
		(time()+$session{setting}{sessionTimeout}).", ".
		time().", 0, '$ENV{REMOTE_ADDR}', $_[0])",$session{dbh});
	setCookie("wgSession",$sessionId);
	refreshSessionVars($sessionId);
}

1;
