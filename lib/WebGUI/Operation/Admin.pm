package WebGUI::Operation::Admin;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001 Plain Black Software.
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
		WebGUI::SQL->write("update session set adminOn=0 where sessionId='$session{var}{sessionId}'",$session{dbh});
		WebGUI::Session::refreshSessionVars($session{var}{sessionId});
		return "";
	} else {
		return WebGUI::Privilege::insufficient();
	}
}

#-------------------------------------------------------------------
sub www_switchOnAdmin {
        if ($session{var}{sessionId}) {
                WebGUI::SQL->write("update session set adminOn=1 where sessionId='$session{var}{sessionId}'",$session{dbh});
                WebGUI::Session::refreshSessionVars($session{var}{sessionId});
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}


1;
