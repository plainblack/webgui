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
			WebGUI::SQL->write("update userSession set lastPageView=".time().", lastIP='$ENV{REMOTE_ADDR}', 
				expires=".(time()+$_[1])." where sessionId='$_[0]'");
		} else {
                        setCookie("wgSession",$session{cookie}{wgSession},"-10y");
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
	my ($namespace, $cmd, @files, $file, $dir, $exclude);
	$dir = $session{config}{webguiRoot}.$session{os}{slash}."lib".$session{os}{slash}."WebGUI".$session{os}{slash}."Macro";
	opendir (DIR,$dir) or WebGUI::ErrorHandler::fatalError("Can't open macro directory!");
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
	my ($dir, @files, $file, $cmd, $namespace, $exclude);
	$dir = $session{config}{webguiRoot}.$session{os}{slash}."lib".$session{os}{slash}."WebGUI".$session{os}{slash}."Wobject";
	opendir (DIR,$dir) or WebGUI::ErrorHandler::fatalError("Can't open wobject directory!");
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
sub convertVisitorToUser {
	WebGUI::SQL->write("update userSession set userId=$_[1] where sessionId=".quote($_[0]));
	$session{var}{userId} = $_[1];
	refreshUserInfo($_[1]);
}

#-------------------------------------------------------------------
sub end {
	WebGUI::SQL->write("delete from userSession where sessionId='$_[0]'",$session{dbh});
	WebGUI::SQL->write("delete from userSessionScratch where sessionId='$_[0]'",$session{dbh});
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

	# Below is a patch which allow you to configure WebGUI with
	# environmentvariables in stead of using WebGUI.conf. To enable this
	# set a env var called wgConfigureByEnvironment to 'YES'. The var
	# names are those of WebGUI.conf prepended with 'wg'. 
	# 
	# NOTE: This is an undocumented an experimental feature. It seems to
	# work with apache/linux on multiple virtual hosts. For things like
	# runHourly.pm you STILL need WebGUI.conf!

        if ($ENV{wgConfigureByEnvironment} eq 'YES') {
                foreach (keys(%ENV)) {
                        if ($_ =~ /^wg(.+)$/) {
                                $session{config}{$1} = $ENV{'wg'.$1};
                        }
                }
        } else {
                $config = new Data::Config
		$session{config}{webguiRoot}.'/etc/'.$session{config}{configFile};
                foreach ($config->param) {
                        $session{config}{$_} = $config->param($_);
                }
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
	### session variables 
	if ($session{cookie}{wgSession} eq "") {
		start(1); #setting up a visitor session
	} else {
		_setupSessionVars($session{cookie}{wgSession},$session{setting}{sessionTimeout});
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
sub refreshSessionVars {
	_setupSessionVars($_[0],$session{setting}{sessionTimeout});
	refreshUserInfo($session{var}{userId});
}

#-------------------------------------------------------------------
sub refreshUserInfo {
	_setupUserInfo($_[0]);
	$session{isInGroup} = ();
}

#-------------------------------------------------------------------
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

 Sets a scratch variable for this user session.

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
sub start {
	my ($sessionId);
	if ($session{cookie}{wgSession} ne "") {  #fix for internet exploder cookie bug
		$sessionId = $session{cookie}{wgSession};
		end($sessionId);
	} else {
		$sessionId = _generateSessionId();
	}
	WebGUI::SQL->write("insert into userSession values ('$sessionId', ".
		(time()+$session{setting}{sessionTimeout}).", ".time().", 0, '$ENV{REMOTE_ADDR}', $_[0])");
	setCookie("wgSession",$sessionId);
	refreshSessionVars($sessionId);
}

1;
