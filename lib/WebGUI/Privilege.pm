package WebGUI::Privilege;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Utility;

#-------------------------------------------------------------------
sub canEditPage {
	if ($session{page}{worldEdit}) {
		return 1;
	} elsif ($session{user}{userId} eq $session{page}{ownerId} && $session{page}{ownerEdit}) {
		return 1;
	} elsif (isInGroup(3)) {
		return 1;
	} elsif (isInGroup($session{page}{groupId}) && $session{page}{groupEdit}) {
		return 1;
	} else {
		return 0;
	}
}

#-------------------------------------------------------------------
sub canViewPage {
	my (%page);
	if ($_[0] eq "") {
		%page = %{$session{page}};
	} else {
		%page = WebGUI::SQL->quickHash("select * from page where pageId=$_[0]",$session{dbh});
	}
        if ($page{worldView}) {
                return 1;
        } elsif ($session{user}{userId} eq $page{ownerId} && $page{ownerView}) {
                return 1;
        } elsif (isInGroup(3)) {
                return 1;
        } elsif (isInGroup($page{groupId}) && $page{groupView}) {
                return 1;
        } else {
                return 0;
        }
}

#-------------------------------------------------------------------
sub insufficient {
	return '<h1>Permission Denied!</h1>You do not have sufficient privileges to perform this operation. Please <a href="'.$session{page}{url}.'?op=displayLogin">log in with an account</a> that has sufficient privileges before attempting this operation.<p>';
}

#-------------------------------------------------------------------
sub isInGroup {
	my ($gid, $uid, $result);
	($gid, $uid) = @_;
	if ($uid eq "") {
		$uid = $session{user}{userId};
	}
	($result) = WebGUI::SQL->quickArray("select count(*) from groupings where groupId='$gid' && userId='$uid'",$session{dbh});
	if ($result < 1 && $gid == 1) { 	# registered users can 
		isInGroup(2, $uid); 		# do anything visitors
	}					# can do
	return $result;
}






1;
