package WebGUI::Widget;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use CGI::Carp qw(fatalsToBrowser);
use DBI;
use Exporter;
use strict;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Utility;

our @ISA = qw(Exporter);
our @EXPORT = qw(&update &www_moveUp &www_moveDown &www_delete &www_deleteConfirm &www_cut &create &www_paste);

#-------------------------------------------------------------------
sub _reorderWidgets {
	my ($sth, $i, $wid);
	$sth = WebGUI::SQL->read("select widgetId from widget where pageId=$_[0] order by sequenceNumber",$session{dbh});
	while (($wid) = $sth->array) {
		WebGUI::SQL->write("update widget set sequenceNumber='$i' where widgetId=$wid",$session{dbh});
		$i++;
	}
	$sth->finish;
}

#-------------------------------------------------------------------
sub create {
	my ($widgetId, $nextSeq);
	$widgetId = getNextId("widgetId");
	($nextSeq) = WebGUI::SQL->quickArray("select max(sequenceNumber)+1 from widget where pageId=$session{page}{pageId}",$session{dbh});
        WebGUI::SQL->write("insert into widget set widgetId=$widgetId, pageId=$session{page}{pageId}, widgetType='$session{form}{widget}', title=".quote($session{form}{title}).", displayTitle='$session{form}{displayTitle}', description=".quote($session{form}{description}).", sequenceNumber='$nextSeq'",$session{dbh});
	return $widgetId;
}

#-------------------------------------------------------------------
sub update {
	WebGUI::SQL->write("update widget set title=".quote($session{form}{title}).", displayTitle='$session{form}{displayTitle}', description=".quote($session{form}{description}).", processMacros='$session{form}{processMacros}' where widgetId=$session{form}{wid}",$session{dbh});
}

#-------------------------------------------------------------------
sub www_cut {
        if (WebGUI::Privilege::canEditPage()) {
                WebGUI::SQL->write("update widget set pageId=2 where widgetId=".$session{form}{wid},$session{dbh});
		_reorderWidgets($session{page}{pageId});
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_delete {
        my ($output);
        if (WebGUI::Privilege::canEditPage()) {
                $output .= '<a href="'.$session{page}{url}.'?op=viewHelp&hid=14"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a><h1>Please Confirm</h1>';
                $output .= 'Are you certain that you wish to delete this content?<p>';
                $output .= '<div align="center"><a href="'.$session{page}{url}.'?func=deleteConfirm&wid='.$session{form}{wid}.'">Yes, I\'m sure.</a>';
                $output .= '&nbsp;&nbsp;&nbsp;&nbsp;<a href="'.$session{page}{url}.'">No, I made a mistake.</a></div>';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteConfirm {
        if (WebGUI::Privilege::canEditPage()) {
                WebGUI::SQL->write("update widget set pageId=3 where widgetId=".$session{form}{wid},$session{dbh});
		_reorderWidgets($session{page}{pageId});
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_moveDown {
	my (@data, $thisSeq);
        if (WebGUI::Privilege::canEditPage()) {
		($thisSeq) = WebGUI::SQL->quickArray("select sequenceNumber from widget where widgetId=$session{form}{wid}",$session{dbh});
		@data = WebGUI::SQL->quickArray("select widgetId, min(sequenceNumber) from widget where pageId=$session{page}{pageId} and sequenceNumber>$thisSeq group by pageId",$session{dbh});
		if ($data[0] ne "") {
                	WebGUI::SQL->write("update widget set sequenceNumber=sequenceNumber+1 where widgetId=$session{form}{wid}",$session{dbh});
                	WebGUI::SQL->write("update widget set sequenceNumber=sequenceNumber-1 where widgetId=$data[0]",$session{dbh});
		}
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_moveUp {
        my (@data, $thisSeq);
        if (WebGUI::Privilege::canEditPage()) {
                ($thisSeq) = WebGUI::SQL->quickArray("select sequenceNumber from widget where widgetId=$session{form}{wid}",$session{dbh});
                @data = WebGUI::SQL->quickArray("select widgetId, max(sequenceNumber) from widget where pageId=$session{page}{pageId} and sequenceNumber<$thisSeq group by pageId",$session{dbh});
                if ($data[0] ne "") {
                        WebGUI::SQL->write("update widget set sequenceNumber=sequenceNumber-1 where widgetId=$session{form}{wid}",$session{dbh});
                        WebGUI::SQL->write("update widget set sequenceNumber=sequenceNumber+1 where widgetId=$data[0]",$session{dbh});
                }
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_paste {
        my ($output, $nextSeq);
        if (WebGUI::Privilege::canEditPage()) {
		($nextSeq) = WebGUI::SQL->quickArray("select max(sequenceNumber)+1 from widget where pageId=$session{page}{pageId}",$session{dbh});
                WebGUI::SQL->write("update widget set pageId=$session{page}{pageId}, sequenceNumber='$nextSeq' where widgetId=$session{form}{wid}",$session{dbh});
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

1;
