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
use WebGUI::URL;

#-------------------------------------------------------------------
sub adminOnly {
	if($session{env}{MOD_PERL}) {
        	my $r = Apache->request;
                if(defined($r)) {
                	$r->custom_response(403, $session{page}{url} );
                        $r->status(403);
                }
        } else {
		$session{header}{status} = 403;
	}
	my ($output, $sth, @data);
        $output = '<h1>'.WebGUI::International::get(35).'</h1>';
	$output .= WebGUI::International::get(36);
	$output .= '<ul>';
	$sth = WebGUI::SQL->read("select users.username,users.userId from users,groupings where users.userId=groupings.userId and groupings.groupId=3 order by users.username");
	while (@data = $sth->array) {
		$output .= '<li><a href="'.WebGUI::URL::page('op=viewProfile&uid='.$data[1]).'">'.$data[0].'</a>';
	}
	$sth->finish;
	$output .= '</ul><p>';
	return $output;
}

#-------------------------------------------------------------------
sub canEditPage {
	my ($isContentManager,%page);
	tie %page, 'Tie::CPHash';
	if ($_[0] ne "") {
		%page = WebGUI::SQL->quickHash("select * from page where pageId=$_[0]");
	} else {
		%page = %{$session{page}};
	}
	$isContentManager = isInGroup(4);
	if ($page{worldEdit} && $isContentManager) {
		return 1;
	} elsif ($session{user}{userId} eq $page{ownerId} && $page{ownerEdit} && $isContentManager) {
		return 1;
	} elsif (isInGroup(3)) {
		return 1;
	} elsif (isInGroup($page{groupId}) && $page{groupEdit} && $isContentManager) {
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
	if($session{env}{MOD_PERL}) {
                my $r = Apache->request;
                if(defined($r)) {
                        $r->custom_response(403, $session{page}{url} );
                        $r->status(403);
                }
        } else {
		$session{header}{status} = 403;
	}
	my ($output);
	$output = '<h1>'.WebGUI::International::get(37).'</h1>';
	$output .= WebGUI::International::get(38);
	$output .= '<p>';
	$output = WebGUI::Macro::process($output);
	return $output;
}

#-------------------------------------------------------------------
sub isInGroup {
	my ($gid, $uid, $result);
	($gid, $uid) = @_;
	if ($uid eq "") {
		$uid = $session{user}{userId};
	}
	if ($gid == 7) {
		return 1;		# If the "Everyone" group is specified then return true regardless of the user.
	}
	($result) = WebGUI::SQL->quickArray("select count(*) from groupings where groupId='$gid' and userId='$uid' and expireDate>".time());
        if ($result < 1 && $gid != 3) {         # admins can
                $result = isInGroup(3, $uid);   # do anything any 
        }                                       # user can do
	return $result;
}

#-------------------------------------------------------------------
sub noAccess {
	if($session{env}{MOD_PERL}) {
                my $r = Apache->request;
                if(defined($r)) {
                        $r->custom_response(403, $session{page}{url} );
                        $r->status(403);
                }
        } else {
		$session{header}{status} = 403;
	}
	my ($output);
        if ($session{user}{userId} <= 1) {
                $output = WebGUI::Operation::Account::www_displayAccount();
        } else {
                $output = '<h1>'.WebGUI::International::get(37).'</h1>';
                $output .= WebGUI::International::get(39);
                $output .= '<p>';
        }
        return $output;
}

#-------------------------------------------------------------------
sub notMember {
	if($session{env}{MOD_PERL}) {
                my $r = Apache->request;
                if(defined($r)) {
                        $r->custom_response(403, $session{page}{url} );
                        $r->status(403);
                }
        } else {
		$session{header}{status} = 403;
	}
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

