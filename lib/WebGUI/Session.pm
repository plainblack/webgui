package WebGUI::Session;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use CGI;
use DBI;
use Exporter;
use strict;
use WebGUI::Config;
use WebGUI::SQL;

our @ISA = qw(Exporter);
our @EXPORT = qw(%session);
our %session = ();

#-------------------------------------------------------------------
sub _getPageInfo {
        my (%page, $pageId, $pageName);
	($pageId) = $_[0];
	if ($pageId eq "") {
        	$pageName = lc($ENV{PATH_INFO});
        	$pageName =~ s/\///;
        	if ($pageName ne "") {
                	($pageId) = WebGUI::SQL->quickArray("select pageId from page where urlizedTitle='".$pageName."'",$_[1]);
                	if ($pageId eq "") {
                        	$pageId = 1;
                	}
        	} else {
                	$pageId = 1;
        	}
	}
	%page = WebGUI::SQL->quickHash("select * from page where pageId='".$pageId."'",$_[1]);
	$page{url} = $ENV{SCRIPT_NAME}."/".$page{urlizedTitle};
        return %page;
}

#-------------------------------------------------------------------
sub _getSessionVars {
        my (%vars, $uid, $encryptedPassword);
        if ($_[0] ne "") {
        	%vars = WebGUI::SQL->quickHash("select * from session where sessionId='$_[0]'", $_[1]);
		if ($vars{sessionId} ne "") {
			WebGUI::SQL->write("update session set lastPageView=now(), lastIP='$ENV{REMOTE_ADDR}', expires=date_add(now(),interval $_[2] second) where sessionId='$_[0]'",$_[1]);
		}
	}
        return %vars;
}

#-------------------------------------------------------------------
sub _getUserInfo {
	my (%user, $uid, $encryptedPassword);
	if ($_[0] ne "") {
		($uid, $encryptedPassword) = split(/\|/,$_[0]);
	} else {
		$uid = 1;
	}
	%user = WebGUI::SQL->quickHash("select * from user where userId='$uid'", $_[1]);
	if ($user{userId} eq "") {
		%user = _getUserInfo(1,$_[1]);
	}
	return %user;
}

#-------------------------------------------------------------------
sub close {
        $session{'dbh'}->disconnect();
	undef %session;
}

#-------------------------------------------------------------------
sub end {
	WebGUI::SQL->write("delete from session where sessionId='$_[0]'",$session{dbh});
	refreshSessionVars();
}

#-------------------------------------------------------------------
sub httpHeader {
        return $session{cgi}->header( -cookie => $session{header}{cookie});
}

#-------------------------------------------------------------------
sub httpRedirect {
        return $session{cgi}->redirect($_[0]);
}

#-------------------------------------------------------------------
sub open {
        my ($key, %WebGUI, %CONFIG, %VARS, %PAGE, %FORM, $query, %COOKIES, $config, %USER, %SETTINGS, $dbh);
	%WebGUI = (version=>"0.11.0", date=>"2001-08-22");
        $config = new WebGUI::Config '../etc/WebGUI.conf';
        foreach ($config->param) {
                $CONFIG{$_} = $config->param($_);
        }
        $dbh = DBI->connect($CONFIG{dsn}, $CONFIG{dbuser}, $CONFIG{dbpass});
        $query = CGI->new();
        foreach ($query->param) {
                $FORM{$_} = $query->param($_);
        }
        foreach ($query->cookie) {
                $COOKIES{$_} = $query->cookie($_);
        }
        %SETTINGS = WebGUI::SQL->buildHash("select name,value from settings",$dbh);
	%VARS = _getSessionVars($COOKIES{wgSession},$dbh,$SETTINGS{sessionTimeout});
        %USER = _getUserInfo($VARS{sessionId},$dbh);
	$CGI::POST_MAX=1024 * $SETTINGS{maxAttachmentSize};
	%PAGE = _getPageInfo("",$dbh);
        %session = (
                env => \%ENV,					# environment variables from the web server
        #       config=> \%CONFIG,				# variables loaded from the config file
                user => \%USER,					# the user's account information
		var => \%VARS,					# session specific variables
                form => \%FORM,					# variables passed in from a form
                cookie => \%COOKIES,				# variables passed in via cookie
                setting => \%SETTINGS,				# variables set by the administrator
                cgi => $query,					# interface to the CGI environment
                page => \%PAGE,					# variables related to the current page 
                header => {},					# settings to be passed back through the http header
                dbh => $dbh,					# interface to the default WebGUI database
		wg => \%WebGUI					# WebGUI internal settings
        );
}

#-------------------------------------------------------------------
sub refreshPageInfo {
        my (%PAGE);
        %PAGE = _getPageInfo($_[0],$session{dbh});
        $session{page} = \%PAGE;
}

#-------------------------------------------------------------------
sub refreshSessionVars {
        my (%VARS);
        %VARS = _getSessionVars($_[0],$session{dbh},$session{setting}{sessionTimeout});
        $session{var} = \%VARS;
	refreshUserInfo($session{var}{sessionId});
}

#-------------------------------------------------------------------
sub refreshUserInfo {
	my (%USER);
	%USER = _getUserInfo($_[0],$session{dbh});
	$session{user} = \%USER;
}

#-------------------------------------------------------------------
sub setCookie {
	$session{header}{cookie} = $session{cgi}->cookie(-name=>$_[0], -value=>$_[1], -expires=>'+10y', -path=>'/');	
}

#-------------------------------------------------------------------
sub start {
	my (%user, $uid, $encryptedPassword);
        ($uid, $encryptedPassword) = split(/\|/,$_[0]);
	%user = WebGUI::SQL->quickHash("select * from user where userId='$uid'", $session{dbh});
        if (crypt($user{identifier},"yJ") eq $encryptedPassword) {
		WebGUI::SQL->write("insert into session set sessionId='$_[0]', expires=date_add(now(),interval $session{setting}{sessionTimeout} second)",$session{dbh});
		refreshSessionVars($_[0]);
		return 1;
        } else {
		return 0;
	}
}

1;
