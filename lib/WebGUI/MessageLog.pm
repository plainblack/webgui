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
use WebGUI::Session;
use WebGUI::SQL;

#-------------------------------------------------------------------
sub addEntry {
        my ($user, %userLanguage, $messageLogId, %message);
	$messageLogId = getNextId("messageLogId");
	if ($_[0] ne "") {
		($userLanguage{$_[0]}) = WebGUI::SQL->quickArray("select language from users where userId=$_[0]");
	}
	if ($_[1] ne "") {
		%userLanguage = (WebGUI::SQL->buildHash("select users.userId,users.language from groupings,users where groupings.groupId=$_[1] and groupings.userId=users.userId"),%userLanguage);
	}
	%message = WebGUI::SQL->buildHash("select language,message from international where internationalId=$_[3] and namespace='$_[4]'");
	foreach $user (keys %userLanguage) {
		WebGUI::SQL->write("insert into messageLog values ($messageLogId,$user,".quote($message{$userLanguage{$user}}).",".quote($_[2]).",".time().")");
		# here is where we'll trigger communication with external systems like email
	}
}

#-------------------------------------------------------------------
sub completeEntry {
	my ($sth, @data, $completeMessage);
	$completeMessage = WebGUI::International::get(350);
	# unfortunately had to loop through reading and writing because I couldn't
        # find a concatination function that worked the same in all DB servers
	$sth = WebGUI::SQL->read("select message,userId from messageLog where messageLogId=$_[0]");
	while (@data = $sth->array) {
		WebGUI::SQL->write("update messageLog set message=".quote($completeMessage.": ".$data[0]).", dateOfEntry=".time()." where messageLogId='$_[0]' and userId=$data[1]");
	}
	$sth->finish;
}


1;
