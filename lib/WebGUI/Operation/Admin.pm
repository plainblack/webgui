package WebGUI::Operation::Admin;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2003 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use Exporter;
use strict;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_switchOffAdmin &www_switchOnAdmin);

#-------------------------------------------------------------------
sub www_switchOffAdmin {
	if ($session{var}{sessionId}) {
		WebGUI::SQL->write("update userSession set adminOn=0 where sessionId='$session{var}{sessionId}'");
		WebGUI::Session::refreshSessionVars($session{var}{sessionId});
		return "";
	} else {
		return WebGUI::Privilege::insufficient();
	}
}

#-------------------------------------------------------------------
sub www_switchOnAdmin {
	my @groups = qw(3 4 5 6 8 9 10 11); # Groups that have a need to turn on admin.
	my $showAdmin = 0;
	if($session{var}{sessionId}){
		foreach (@groups){
			last if($showAdmin=WebGUI::Privilege::isInGroup($_));
		}
	}
        if ($showAdmin) {
                WebGUI::SQL->write("update userSession set adminOn=1 where sessionId='$session{var}{sessionId}'");
                WebGUI::Session::refreshSessionVars($session{var}{sessionId});
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}


1;
