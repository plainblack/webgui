package WebGUI::MessageLog;

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
use WebGUI::Mail;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;

#-------------------------------------------------------------------
sub _getUserInfo {
        my (%default, $key, %user, %profile, $value);
        tie %user, 'Tie::CPHash';
        %user = WebGUI::SQL->quickHash("select * from users where userId='$_[0]'");
        if ($user{userId} ne "") {
        	%profile = WebGUI::SQL->buildHash("select userProfileField.fieldName, userProfileData.fieldData 
			from userProfileData, userProfileField 
			where userProfileData.fieldName=userProfileField.fieldName and userProfileData.userId=$user{userId}");
        	%user = (%user, %profile);
        	%default = WebGUI::SQL->buildHash("select fieldName, dataDefault from userProfileField where profileCategoryId=4");
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
	}
        return \%user;
}

#-------------------------------------------------------------------
sub addEntry {
        my (@users, $messageLogId,$sth, $user, %message, %subject, $message, $subject);
	$messageLogId = getNextId("messageLogId");
	%message = WebGUI::SQL->buildHash("select language,message from international where internationalId=$_[3] and namespace='$_[4]'");
	%subject = WebGUI::SQL->buildHash("select language,message from international where internationalId=523 and namespace='WebGUI'");
	if ($_[1] ne "") {
		@users = WebGUI::SQL->quickArray("select userId from groupings where groupId=$_[1]");
	}
	@users = ($_[0],@users);
	foreach $user (@users) {
		$user = _getUserInfo($user);
		if (${$user}{userId} ne "") {
			WebGUI::SQL->write("insert into messageLog values ($messageLogId,".${$user}{userId}.",
				".quote($message{${$user}{language}}).",".quote($_[2]).",".time().")");
			$subject = $subject{${$user}{language}};
			$message = $message{${$user}{language}}."\n".WebGUI::URL::append('http://'.$session{env}{HTTP_HOST}.$_[2],'mlog='.$messageLogId);
			if (${$user}{INBOXNotifications} = "email") {
				if (${$user}{email} ne "") {
					WebGUI::Mail::send(${$user}{email},$subject,$message);
				}
			} elsif (${$user}{INBOXNotifications} = "emailToPager") {
				if (${$user}{emailToPagerGateway} ne "") {
					WebGUI::Mail::send(${$user}{emailToPagerGateway},$subject,$message);
				}
			} elsif (${$user}{INBOXNotifications} = "icq") {
				if (${$user}{icq}) {
					WebGUI::Mail::send(${$user}{icq}.'@pager.icq.com',$subject,$message);
				}
			}
		}
	}
}

#-------------------------------------------------------------------
sub completeEntry {
	my ($sth, @data, $completeMessage);
	$completeMessage = WebGUI::International::get(350);
	# unfortunately had to loop through reading and writing because I couldn't
        # find a concatination function that worked the same in all DB servers
	$sth = WebGUI::SQL->read("select message,userId from messageLog where messageLogId='$_[0]'");
	while (@data = $sth->array) {
		WebGUI::SQL->write("update messageLog set message=".quote($completeMessage.": ".$data[0]).", dateOfEntry=".time()." where messageLogId='$_[0]' and userId=$data[1]");
	}
	$sth->finish;
}


1;
