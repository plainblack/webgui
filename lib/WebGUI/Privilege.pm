package WebGUI::Privilege;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Tie::CPHash;
use WebGUI::International;
use WebGUI::Operation::Account ();
use WebGUI::Session;
use WebGUI::SQL;

#-------------------------------------------------------------------
sub adminOnly {
	my ($output, $sth, @data);
        $output = '<h1>'.WebGUI::International::get(35).'</h1>';
	$output .= WebGUI::International::get(36);
	$output .= '<ul>';
	$sth = WebGUI::SQL->read("select users.username, users.email from users,groupings where users.userId=groupings.userId and groupings.groupId=3 order by users.username");
	while (@data = $sth->array) {
		$output .= '<li>'.$data[0].' (<a href="mailto:'.$data[1].'">'.$data[1].'</a>)';
	}
	$sth->finish;
	$output .= '</ul><p>';
	return $output;
}

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
	tie %page, 'Tie::CPHash';
	if ($_[0] eq "") {
		%page = %{$session{page}};
	} else {
		%page = WebGUI::SQL->quickHash("select * from page where pageId=$_[0]");
	}
	if ($page{worldView}) {
                return 1;
        } elsif ($session{user}{userId} eq $page{ownerId} && $page{ownerView}) {
                return 1;
        } elsif (isInGroup(3)) { # admin check
	        return 1;
        } elsif (isInGroup($page{groupId}) && $page{groupView}) {
                return 1;
        } else {
                return 0;
        }
}

#-------------------------------------------------------------------
sub insufficient {
	my ($output);
	if ($session{user}{userId} eq "") {
		$output = WebGUI::Operation::Account::displayAccount();
	} else {
		$output = '<h1>'.WebGUI::International::get(37).'</h1>';
		$output .= WebGUI::International::get(38);
		$output .= '<p>';
		$output = WebGUI::Macro::process($output);
	}
	return $output;
}

#-------------------------------------------------------------------
sub isInGroup {
	my ($gid, $uid, $result);
	($gid, $uid) = @_;
	if ($uid eq "") {
		$uid = $session{user}{userId};
	}
	($result) = WebGUI::SQL->quickArray("select count(*) from groupings where groupId='$gid' and userId='$uid' and expireDate>".time());
	if ($result < 1 && $gid == 1) { 	# registered users can 
		$result = isInGroup(2, $uid); 	# do anything visitors
	}					# can do
        if ($result < 1 && $gid != 3) {         # admins can
                $result = isInGroup(3, $uid);   # do anything any 
        }                                       # user can do
	return $result;
}

#-------------------------------------------------------------------
sub noAccess {
	my ($output);
        $output = '<h1>'.WebGUI::International::get(37).'</h1>';
	$output .= WebGUI::International::get(39);
	$output .= '<p>';
	return $output;
}

#-------------------------------------------------------------------
sub notMember {
	my ($output);
	$output = '<h1>'.WebGUI::International::get(345).'</h1>';
	$output .= WebGUI::International::get(346);
	$output .= '<p>';
	return $output;
}

#-------------------------------------------------------------------
sub vitalComponent {
	my ($output);
        $output = '<h1>'.WebGUI::International::get(40).'</h1>';
	$output .= WebGUI::International::get(41);
	$output .= '<p>';
	return $output;
}






1;

