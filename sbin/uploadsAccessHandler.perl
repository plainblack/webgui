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
	use Apache;
	my $s = Apache->server;
        $webguiRoot = $s->dir_config('WebguiRoot');
        unshift (@INC, $webguiRoot."/lib");
}

print "Starting WebGUI Uploads Access Handler\n";

use strict;
use Apache::Constants qw(:common);
use CGI::Util qw/escape/;
use WebGUI::Grouping;
use WebGUI::Session;
use WebGUI::URL;

sub handler {
	my $r = shift;
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
				my $cookie = $r->header_in('Cookie');
				$cookie =~ s/wgSession\=(.*)/$1/;
				$cookie = WebGUI::URL::unescape($cookie);
				WebGUI::Session::refreshSessionVars($cookie);
				return OK if ($session{user}{userId} eq $privs[0] || WebGUI::Grouping::isInGroup($privs[1]) || WebGUI::Grouping::isInGroup($privs[2]));	
				WebGUI::Session::close();
				return 401;
			}
		}
		return OK;
	} else {
		return NOT_FOUND;
	}
}

1;
