package WebGUI::Macro;

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
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;

#-------------------------------------------------------------------
sub _recurseCrumbTrail {
        my ($sth, %data, $output);
        %data = WebGUI::SQL->quickHash("select pageId,parentId,title,urlizedTitle from page where pageId=$_[0]",$session{dbh});
        if ($data{pageId} > 1) {
                $output .= _recurseCrumbTrail($data{parentId});
        }
        if ($data{title} ne "") {
                $output .= '<a href="'.$session{env}{SCRIPT_NAME}.'/'.$data{urlizedTitle}.'">'.$data{title}.'</a> &gt; ';
        }
        return $output;
}

#-------------------------------------------------------------------
sub _traversePageTree {
        my ($sth, @data, $output, $depth, $i, $toLevel);
	if ($_[2] > 0) {
		$toLevel = $_[2];
	} else {
		$toLevel = 99;
	}
        for ($i=0;$i<=$_[1];$i++) {
                $depth .= "&nbsp;&nbsp;";
        }
	if ($_[1] < $toLevel) {
        	$sth = WebGUI::SQL->read("select urlizedTitle, title, pageId from page where parentId='$_[0]' order by sequenceNumber",$session{dbh});
        	while (@data = $sth->array) {
                	if (WebGUI::Privilege::canViewPage($data[2])) {
                        	$output .= $depth.'<a href="'.$session{env}{SCRIPT_NAME}.'/'.$data[0].'">'.$data[1].'</a><br>';
                        	$output .= _traversePageTree($data[2],$_[1]+1,$_[2]);
                	}
        	}
        	$sth->finish;
	}
        return $output;
}

#-------------------------------------------------------------------
sub process {
	my ($output, $temp, @data, $sth, $first);
	$output = $_[0];
  #---carrot ^---
        if ($output =~ /\^\^/) {
                $output =~ s/\^\^/\^/g;
        }
  #---page url---
        if ($output =~ /\^\//) {
                $output =~ s/\^\//$session{env}{SCRIPT_NAME}/g;
        }
  #---username---
        if ($output =~ /\^\@/) {
                $output =~ s/\^\@/$session{user}{username}/g;
        }
  #---uid---
        if ($output =~ /\^\#/) {
                $output =~ s/\^\#/$session{user}{userId}/g;
        }
  #---random number---
        if ($output =~ /\^\*/) {
                $temp = rand()*1000000000;
                $output =~ s/\^\*/$temp/g;
        }
  #---account link---
	if ($output =~ /\^a/) {
        	$temp = '<a href="'.$session{page}{url}.'?op=displayAccount">My Account</a>';
        	$output =~ s/\^a/$temp/g;
	}
  #---company name---
	if ($output =~ /\^c/) {
		$output =~ s/\^c/$session{setting}{companyName}/g;
	}
  #---crumb trail---
	if ($output =~ /\^C/) {
        	$temp = '<span class="crumbTrail">'._recurseCrumbTrail($session{page}{parentId}).'<a href="'.$session{page}{url}.'">'.$session{page}{title}.'</a></span>';
        	$output =~ s/\^C/$temp/g;
	}
  #---date---
	if ($output =~ /\^D/) {
		$temp = localtime(time);
		$output =~ s/\^D/$temp/g;
	}
  #---company email---
        if ($output =~ /\^e/) {
                $output =~ s/\^e/$session{setting}{companyEmail}/g;
        }
  #---full menu (vertical)---
        if ($output =~ /\^f/) {
        	$temp = _traversePageTree(1,0);
                $output =~ s/\^f/$temp/g;
	}
  #---2 level menu (vertical)---
        if ($output =~ /\^F/) {
        	$temp = _traversePageTree(1,0,2);
                $output =~ s/\^F/$temp/g;
        }
  #---3 level menu (vertical)---
        if ($output =~ /\^h/) {
        	$temp = _traversePageTree(1,0,3);
                $output =~ s/\^h/$temp/g;
        }
  #---home link---
	if ($output =~ /\^H/) {
        	$temp = '<a href="'.$session{env}{SCRIPT_NAME}.'/home">Home</a>';
        	$output =~ s/\^H/$temp/g;
	}
  #---login box---
	if ($output =~ /\^L/) {
		$temp = '<div class="loginBox">';
        	if ($session{var}{sessionId}) {
                	$temp .= 'Hello '.$session{user}{username}.'. Click <a href="'.$session{page}{url}.'?op=logout">here</a> to log out.';
        	} else {
                	$temp .= '<form method="post" action="'.$session{page}{url}.'"> ';
                	$temp .= WebGUI::Form::hidden("op","login").'<span class="formSubtext">Username:<br></span>';
                	$temp .= WebGUI::Form::text("username",12,30).'<span class="formSubtext"><br>Password:<br></span>';
			$temp .= WebGUI::Form::password("identifier",12,30).'<span class="formSubtext"><br></span>';
                	$temp .= WebGUI::Form::submit("login");
                	$temp .= '</form>';
        	}
        	$temp .= '</div>';
        	$output =~ s/\^L/$temp/g;
	}
  #---current menu vertical---
	if ($output =~ /\^M/) {
       	 	$temp = '<span class="verticalMenu">';
        	$sth = WebGUI::SQL->read("select title,urlizedTitle,pageId from page where parentId=$session{page}{pageId} order by sequenceNumber",$session{dbh});
        	while (@data = $sth->array) {
			if (WebGUI::Privilege::canViewPage($data[2])) {
                		$temp .= '<a href="'.$session{env}{SCRIPT_NAME}.'/'.$data[1].'">'.$data[0].'</a><br>';
			}
        	}
        	$sth->finish;
        	$temp .= '</span>';
        	$output =~ s/\^M/$temp/g;
	}
  #---current menu horizontal ---
	if ($output =~ /\^m/) {
        	$temp = '<span class="horizontalMenu">';
		$first = 1;
        	$sth = WebGUI::SQL->read("select title,urlizedTitle,pageId from page where parentId=$session{page}{pageId} order by sequenceNumber",$session{dbh});
        	while (@data = $sth->array) {
			if (WebGUI::Privilege::canViewPage($data[2])) {
                		if ($first) {
                        		$first = 0;
                		} else {
                        		$temp .= " &middot; ";
                		}
                		$temp .= '<a href="'.$session{env}{SCRIPT_NAME}.'/'.$data[1].'">'.$data[0].'</a>';
			}
        	}
        	$sth->finish;
        	$temp .= '</span>';
        	$output =~ s/\^m/$temp/g;
	}
  #---top menu vertical---
	if ($output =~ /\^T/) {
		$temp = '<span class="verticalMenu">';
		$sth = WebGUI::SQL->read("select title,urlizedTitle,pageId from page where parentId=1 order by sequenceNumber",$session{dbh});
		while (@data = $sth->array) {
			if (WebGUI::Privilege::canViewPage($data[2])) {
				$temp .= '<a href="'.$session{env}{SCRIPT_NAME}.'/'.$data[1].'">'.$data[0].'</a><br>';
			}
		}
		$sth->finish;
		$temp .= '</span>';
        	$output =~ s/\^T/$temp/g;
	}
  #---top menu horizontal---
	if ($output =~ /\^t/) {
        	$temp = '<span class="horizontalMenu">';
		$first = 1;
        	$sth = WebGUI::SQL->read("select title,urlizedTitle,pageId from page where parentId=1 order by sequenceNumber",$session{dbh});
        	while (@data = $sth->array) {
			if (WebGUI::Privilege::canViewPage($data[2])) {
				if ($first) {
					$first = 0;
				} else {
					$temp .= " &middot; ";
				}
                		$temp .= '<a href="'.$session{env}{SCRIPT_NAME}.'/'.$data[1].'">'.$data[0].'</a>';
			}
        	}
        	$sth->finish;
        	$temp .= '</span>';
		$output =~ s/\^t/$temp/g;
	}
  #---company URL---
        if ($output =~ /\^u/) {
                $output =~ s/\^u/$session{setting}{companyURL}/g;
        }
	return $output;
}



1;
