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
our @EXPORT = qw(&purgeWidget &www_jumpDown &www_jumpUp &update &www_moveUp &www_moveDown &www_delete &www_deleteConfirm &www_cut &create &www_paste);

#-------------------------------------------------------------------
sub _reorderWidgets {
	my ($sth, $i, $wid);
	$sth = WebGUI::SQL->read("select widgetId from widget where pageId=$_[0] order by sequenceNumber",$session{dbh});
	while (($wid) = $sth->array) {
		$i++;
		WebGUI::SQL->write("update widget set sequenceNumber='$i' where widgetId=$wid",$session{dbh});
	}
	$sth->finish;
}

#-------------------------------------------------------------------
sub create {
	my ($widgetId, $nextSeq);
	$widgetId = getNextId("widgetId");
	($nextSeq) = WebGUI::SQL->quickArray("select max(sequenceNumber)+1 from widget where pageId=$session{page}{pageId}",$session{dbh});
        WebGUI::SQL->write("insert into widget values ($widgetId, $session{page}{pageId}, '$session{form}{widget}', '$nextSeq', ".quote($session{form}{title}).", '$session{form}{displayTitle}', ".quote($session{form}{description}).", '$session{form}{processMacros}', ".time().", '$session{user}{userId}', 0, 0)",$session{dbh});
	return $widgetId;
}

#-------------------------------------------------------------------
sub update {
	WebGUI::SQL->write("update widget set title=".quote($session{form}{title}).", displayTitle='$session{form}{displayTitle}', description=".quote($session{form}{description}).", processMacros='$session{form}{processMacros}', lastEdited=".time().", editedBy='$session{user}{userId}' where widgetId=$session{form}{wid}",$session{dbh});
}

#-------------------------------------------------------------------
sub purgeWidget {
	WebGUI::SQL->write("delete from widget where widgetId=$_[0]",$_[1]);
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
sub www_jumpDown {
        my (@data, $thisSeq);
        if (WebGUI::Privilege::canEditPage()) {
                WebGUI::SQL->write("update widget set sequenceNumber=9999 where widgetId=$session{form}{wid}",$session{dbh});
		_reorderWidgets($session{page}{pageId});
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_jumpUp {
        my (@data, $thisSeq);
        if (WebGUI::Privilege::canEditPage()) {
                WebGUI::SQL->write("update widget set sequenceNumber=0 where widgetId=$session{form}{wid}",$session{dbh});
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
		@data = WebGUI::SQL->quickArray("select widgetId from widget where pageId=$session{page}{pageId} and sequenceNumber=$thisSeq+1",$session{dbh});
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
                @data = WebGUI::SQL->quickArray("select widgetId from widget where pageId=$session{page}{pageId} and sequenceNumber=$thisSeq-1",$session{dbh});
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
