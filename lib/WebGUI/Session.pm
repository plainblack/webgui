package WebGUI::Session;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use CGI;
use Data::Config;
use DBI;
use Exporter;
use strict;
use Tie::CPHash;
use WebGUI::SQL;

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
        	$pageName =~ s/\///;
		$pageName =~ s/\'//;
		$pageName =~ s/\"//;
        	if ($pageName ne "") {
                	($pageId) = WebGUI::SQL->quickArray("select pageId from page where urlizedTitle='".$pageName."'",$_[1]);
                	if ($pageId eq "") {
                        	$pageId = $_[2];
				$session{header}{status} = '404';
                	}
        	} else {
                	$pageId = 1;
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
	my (%user, $uid, %profile);
	tie %user, 'Tie::CPHash';
	$uid = $_[0] || 1;
	%user = WebGUI::SQL->quickHash("select * from users where userId='$uid'", $_[1]);
	if ($user{userId} eq "") {
		%user = _getUserInfo("1",$_[1]);
	}
	%profile = WebGUI::SQL->buildHash("select userProfileField.fieldName, userProfileData.fieldData from userProfileData, userProfileField where userProfileData.fieldName=userProfileField.fieldName and userProfileData.userId=$user{userId}", $_[1]);
	%user = (%user, %profile);
	$user{language} = 'English' if ($user{language} eq "");
	return \%user;
}

#-------------------------------------------------------------------
sub _loadWobjects {
        my ($dir, @files, $file, $cmd, $namespace);
        if ($^O =~ /Win/i) {
                $dir = "\\lib\\WebGUI\\Wobject";
        } else {
                $dir = "/lib/WebGUI/Wobject";
        }
        opendir (DIR,$session{config}{webguiRoot}.$dir) or WebGUI::ErrorHandler::fatalError("Can't open wobject directory!");
        @files = readdir(DIR);
        foreach $file (@files) {
                if ($file =~ /(.*?)\.pm$/) {
                        $namespace = $1;
                        $cmd = "use WebGUI::Wobject::".$namespace;
                        eval($cmd);
			$cmd = "\$WebGUI::Wobject::".$namespace."::name";
			$session{wobject}{$namespace} = eval($cmd);
                }
        }
        closedir(DIR);
}

#-------------------------------------------------------------------
sub close {
        $session{'dbh'}->disconnect();
	undef %session;
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
        return $session{cgi}->header( 
		-cookie => $session{header}{cookie}, 
		-status => $session{header}{status} 
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
        $session{cgi} = CGI->new();
	$CGI::POST_MAX=1024 * $session{setting}{maxAttachmentSize};
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
	### current user's account and profile information (from users and userProfileData tables)
        $session{user} = _getUserInfo($session{var}{userId},$session{dbh});
	###----------------------------
	### current page's properties (from page table)
	$session{page} = _getPageInfo("",$session{dbh},$session{setting}{notFoundPage},$session{config}{scripturl});
	###----------------------------
	### loading plugins
        _loadWobjects();
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
	$session{header}{cookie} = $session{cgi}->cookie(-name=>$_[0], -value=>$_[1], -expires=>'+10y', -path=>'/');	
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
