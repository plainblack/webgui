#!/usr/bin/perl

#-------------------------------------------------------------------
# WebGUI is Copyright 2001 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

BEGIN {
        unshift (@INC, "../lib");
}

use Data::Config;
use DBI;
use strict;
use WebGUI::DateTime;
use WebGUI::SQL;

my ($dbh, $config, $sth, @data);

if ($ARGV[0] ne "--GO") {
	print <<EOF;


Due to the large number of database changes in this release, we
decided it best to write a program to migrate your data rather than
simply giving you the standard upgrade_xxx-xxx.sql script that we
usually produce. This is a one time change to accomodate data
structures that better fit with databases that are not MySQL. 

If you're ready to begin the upgrade type:

	perl upgrade_1.1.0-1.2.0.pl --GO


Thanks for your support and patience.

	-- Plain Black Software


EOF
	exit;
}


print "\nWebGUI is upgrading your database tables...\n\n";

print "Reading config:\t\t";
if (eval{$config = new Data::Config '../etc/WebGUI.conf'}) {
	print "OK\n";
	print "Connecting to DB:\t";
	if (eval{$dbh = DBI->connect($config->param('dsn'), $config->param('dbuser'), $config->param('dbpass'))}) {
		print "OK\n";
		print "Renaming tables:\t";
		WebGUI::SQL->write("alter table user rename users",$dbh);
		print "Done\n";
		print "Creating new columns:\t";
		WebGUI::SQL->write("alter table Article add column startDate_upgrade int after startDate",$dbh);
		WebGUI::SQL->write("alter table Article add column endDate_upgrade int after endDate",$dbh);
		WebGUI::SQL->write("alter table SyndicatedContent add column lastFetched_upgrade int after lastFetched",$dbh);
		WebGUI::SQL->write("alter table event add column startDate_upgrade int after startDate",$dbh);
		WebGUI::SQL->write("alter table event add column endDate_upgrade int after endDate",$dbh);
		WebGUI::SQL->write("alter table message add column dateOfPost_upgrade int after dateOfPost",$dbh);
		WebGUI::SQL->write("alter table session add column expires_upgrade int after expires",$dbh);
		WebGUI::SQL->write("alter table session add column lastPageView_upgrade int after lastPageView",$dbh);
		WebGUI::SQL->write("alter table submission add column dateSubmitted_upgrade int after dateSubmitted",$dbh);
		WebGUI::SQL->write("alter table widget add column dateAdded_upgrade int after dateAdded",$dbh);
		WebGUI::SQL->write("alter table widget add column lastEdited_upgrade int after lastEdited",$dbh);
		print "Done\n";
		print "Migrating data:\t\t";
		WebGUI::SQL->write("update Article set endDate='2037-01-01 00:00:00' where endDate='2100-01-01 00:00:00'",$dbh);
		$sth = WebGUI::SQL->read("select widgetId, unix_timestamp(startDate), unix_timestamp(endDate) from Article",$dbh);
		while (@data = $sth->array) {
			WebGUI::SQL->write("update Article set startDate_upgrade='$data[1]', endDate_upgrade='$data[2]' where widgetId=$data[0]",$dbh);
		}
		$sth->finish;
		$sth = WebGUI::SQL->read("select widgetId, unix_timestamp(lastFetched) from SyndicatedContent",$dbh);
		while (@data = $sth->array) {
			WebGUI::SQL->write("update SyndicatedContent set lastFetched_upgrade='$data[1]' where widgetId=$data[0]",$dbh);
		}
		$sth->finish;
		$sth = WebGUI::SQL->read("select eventId, unix_timestamp(startDate), unix_timestamp(endDate) from event",$dbh);
		while (@data = $sth->array) {
			WebGUI::SQL->write("update event set startDate_upgrade='$data[1]', endDate_upgrade='$data[2]' where eventId=$data[0]",$dbh);
		}
		$sth->finish;
		$sth = WebGUI::SQL->read("select messageId, unix_timestamp(dateOfPost) from message",$dbh);
		while (@data = $sth->array) {
			WebGUI::SQL->write("update message set dateOfPost_upgrade='$data[1]' where messageId=$data[0]",$dbh);
		}
		$sth->finish;
		$sth = WebGUI::SQL->read("select sessionId, unix_timestamp(expires), unix_timestamp(lastPageView) from session",$dbh);
		while (@data = $sth->array) {
			WebGUI::SQL->write("update session set expires_upgrade='$data[1]', lastPageView_upgrade='$data[2]' where sessionId=".$dbh->quote($data[0])."",$dbh);
		}
		$sth->finish;
		$sth = WebGUI::SQL->read("select submissionId, unix_timestamp(dateSubmitted) from submission",$dbh);
		while (@data = $sth->array) {
			WebGUI::SQL->write("update submission set dateSubmitted_upgrade='$data[1]' where widgetId=$data[0]",$dbh);
		}
		$sth->finish;
		$sth = WebGUI::SQL->read("select widgetId, unix_timestamp(dateAdded), unix_timestamp(lastEdited) from widget",$dbh);
		while (@data = $sth->array) {
			WebGUI::SQL->write("update widget set dateAdded_upgrade='$data[1]', lastEdited='$data[2]' where widgetId=$data[0]",$dbh);
		}
		$sth->finish;
		print "Done\n";
		print "Discarding old columns:\t";
                WebGUI::SQL->write("alter table Article drop column startDate",$dbh);
                WebGUI::SQL->write("alter table Article drop column endDate",$dbh);
                WebGUI::SQL->write("alter table SyndicatedContent drop column lastFetched",$dbh);
                WebGUI::SQL->write("alter table event drop column startDate",$dbh);
                WebGUI::SQL->write("alter table event drop column endDate",$dbh);
                WebGUI::SQL->write("alter table message drop column dateOfPost",$dbh);
                WebGUI::SQL->write("alter table session drop column expires",$dbh);
                WebGUI::SQL->write("alter table session drop column lastPageView",$dbh);
                WebGUI::SQL->write("alter table submission drop column dateSubmitted",$dbh);
                WebGUI::SQL->write("alter table widget drop column dateAdded",$dbh);
                WebGUI::SQL->write("alter table widget drop column lastEdited",$dbh);		
		print "Done\n";
		print "Renaming columns:\t";
		WebGUI::SQL->write("alter table Article change column startDate_upgrade startDate int",$dbh);
                WebGUI::SQL->write("alter table Article change column endDate_upgrade endDate int",$dbh);
                WebGUI::SQL->write("alter table SyndicatedContent change column lastFetched_upgrade lastFetched int",$dbh);
                WebGUI::SQL->write("alter table event change column startDate_upgrade startDate int",$dbh);
                WebGUI::SQL->write("alter table event change column endDate_upgrade endDate int",$dbh);
                WebGUI::SQL->write("alter table message change column dateOfPost_upgrade dateOfPost int",$dbh);
                WebGUI::SQL->write("alter table session change column expires_upgrade expires int",$dbh);
                WebGUI::SQL->write("alter table session change column lastPageView_upgrade lastPageView int",$dbh);
                WebGUI::SQL->write("alter table submission change column dateSubmitted_upgrade dateSubmitted int",$dbh);
                WebGUI::SQL->write("alter table widget change column dateAdded_upgrade dateAdded int",$dbh);
                WebGUI::SQL->write("alter table widget change column lastEdited_upgrade lastEdited int",$dbh);
		print "Done\n";
		print "Cleaning up:\t\t";
		$dbh->disconnect();
		print "Done\n";
		print "\nUpgrade complete!\n";
	} else {
		print "Can't connect with info provided.\n";
	}
} else {
	print "Ouch...something went wrong!";
}




