package WebGUI::UploadsAccessHandler;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

our $webguiRoot;

BEGIN {
	my $s;
        if ($mod_perl::VERSION >= 1.999023) {
                $s = Apache2::ServerUtil->server;
        } else {
                $s = Apache->server;
        }
        $webguiRoot = $s->dir_config('WebguiRoot');
        unshift (@INC, $webguiRoot."/lib");
}

print "Starting WebGUI Uploads Access Handler\n";

use strict;
use CGI::Util qw/escape/;
use WebGUI::Grouping;
use WebGUI::Session;
use WebGUI::URL;

sub handler {
	my $r;
	my $ok;	
	my $notfound;
	if ($mod_perl::VERSION >= 1.999023) {
        	$r = Apache2::RequestUtil->request;
		$ok = Apache2::Const::OK();
		$notfound = Apache2::Const::NOT_FOUND();
        } else {
                $r = Apache->request;
		$ok = Apache::OK();
		$notfound = Apache::NOT_FOUND();
        }
	if (-e $r->filename) {
		my $path = $r->filename;
		$path =~ s/^(\/.*\/).*$/$1/;
		if (-e $path.".wgaccess") {
		 	my $fileContents;	
			open(FILE,"<".$path.".wgaccess");
			while (<FILE>) {
				$fileContents .= $_;
			}
			close(FILE);
			my @privs = split("\n",$fileContents);
			unless ($privs[1] eq "7" || $privs[1] eq "1") {
				WebGUI::Session::open($webguiRoot, $r->dir_config('WebguiConfig'));
				my $cookie = $r->headers_in->{Cookie} || '';
				$cookie =~ s/wgSession\=(.*)/$1/;
				$cookie = WebGUI::URL::unescape($cookie);
				WebGUI::Session::refreshSessionVars($cookie);
				return $ok if ($session{user}{userId} eq $privs[0] || WebGUI::Grouping::isInGroup($privs[1]) || WebGUI::Grouping::isInGroup($privs[2]));	
				WebGUI::Session::close();
				return 401;
			}
		}
		return $ok; 
	} else {
		return $notfound;
	}
}

1;
