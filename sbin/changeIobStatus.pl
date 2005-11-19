#!/usr/bin/perl

our ($webguiRoot);

BEGIN { 
	$webguiRoot = "..";
	unshift (@INC, $webguiRoot."/lib"); 
}

use Getopt::Long;
use strict;
use WebGUI::DateTime;
use WebGUI::MessageLog;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::User;

$|=1;

my $configFile;
my $help;
my $quiet;
my $whatsHappening = "Automatically signed out.";
my $newStatus = "Out";
my $currentStatus = "In";
my $userMessage = "You were logged out of the In/Out Board automatically.";
my $userMessageFile;


GetOptions(
	'configfile=s'=>\$configFile,
	'help'=>\$help,
	'quiet'=>\$quiet,
	'whatsHappening:s'=>\$whatsHappening,
	'userMessage:s'=>\$userMessage,
	'userMessageFile:s'=>\$userMessageFile,
	'currentStatus:s'=>\$currentStatus,
	'newStatus:s'=>\$newStatus
);





unless ($configFile && !$help) {
	print <<STOP;


Usage: perl $0 --configfile=<webguiConfig>

	--configFile	WebGUI config file (with no path info). 

Description:	This utility allows you to automate the switching of status
		for users in the IOB. For instance, you may wish to
		automatically mark out all users each night that haven't
		already marked out.

Options:

	--currentStatus	The status to check for. Defaults to "$currentStatus".

	--help		Display this help message.

	--newStatus	The status to set the user to. Defaults to 
			"$newStatus".

	--quiet         Disable output unless there's an error.

	--userMessage	A message to be sent to the user upon getting their
			status changed. Defaults to "$userMessage".

	--userMessageFile	A path to a filename to override the
			--userMessage with. This option will read the
			contents of the file and send that as the
			message.

	--whatsHappening	The message attached to the IOB when 
			changing status. Defaults to 
			"$whatsHappening".

STOP
	exit;
}




print "Starting up...\n" unless ($quiet);
WebGUI::Session::open($webguiRoot,$configFile);

if ($userMessageFile) {
	print "Opening message file.." unless ($quiet);
	if (open(FILE,"<".$userMessageFile)) {
		print "OK\n" unless ($quiet);
		my $contents;
		while (<FILE>) {
			$contents .= $_;
		}
		close(FILE);
		if (length($contents) == 0) {
			print "Message file empty, reverting to original message.\n";
		} else {
			$userMessage = $contents;
		}
	} else {
		print "Failed to open message file.\n";
	}
}

print "Searching for users with a status of $currentStatus ...\n" unless ($quiet);
my $userList;
my $now = WebGUI::DateTime::time();
my $sth = WebGUI::SQL->read("select userId,assetId from InOutBoard_status where status=".quote($currentStatus));
while (my ($userId,$assetId) = $sth->array) {
	my $user = WebGUI::User->new($userId);
	print "\tFound user ".$user->username."\n" unless ($quiet);
	$userList .= $user->username." (".$userId.")\n";
	WebGUI::SQL->write("update InOutBoard_status set dateStamp=".$now.", message=".quote($whatsHappening).",
		status=".quote($newStatus)." where userId=".quote($userId)." and assetId=".quote($assetId));
	WebGUI::SQL->write("insert into InOutBoard_statusLog (userId, createdBy, dateStamp, message, status, assetId) values (
		".quote($userId).", ".quote(3).", ".$now.", ".quote($whatsHappening).", ".quote($newStatus).", ".quote($assetId).")");
	WebGUI::MessageLog::addEntry($userId,undef,"IOB Update",$userMessage);
}
$sth->finish;

if (length($userList) > 0) {
	print "Alerting admins of changes\n" unless ($quiet);
	my $message = "The following users had their status changed:\n\n".$userList;
	WebGUI::MessageLog::addEntry(undef,"3","IOB Update",$message);
}
	
print "Cleaning up..." unless ($quiet);
WebGUI::Session::end($session{var}{sessionId});
WebGUI::Session::close();
print "OK\n" unless ($quiet);

