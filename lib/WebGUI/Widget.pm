package WebGUI::Widget;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black Software.
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
use strict qw(subs vars);
use Tie::IxHash;
use WebGUI::Attachment;
use WebGUI::International;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Template;
use WebGUI::URL;

our @ISA = qw(Exporter);
our @EXPORT = qw(&getProperties &purgeWidget &www_jumpDown &www_jumpUp &update &www_moveUp &www_moveDown &www_delete &www_deleteConfirm &www_cut &create &www_paste);

#-------------------------------------------------------------------
sub _reorderWidgets {
	my ($sth, $i, $wid);
	$sth = WebGUI::SQL->read("select widgetId from widget where pageId=$_[0] order by templatePosition,sequenceNumber");
	while (($wid) = $sth->array) {
		$i++;
		WebGUI::SQL->write("update widget set sequenceNumber='$i' where widgetId=$wid");
	}
	$sth->finish;
}

#-------------------------------------------------------------------
sub create {
	my ($widgetId, $nextSeq);
	$widgetId = getNextId("widgetId");
	($nextSeq) = WebGUI::SQL->quickArray("select max(sequenceNumber)+1 from widget where pageId=$_[0]");
        WebGUI::SQL->write("insert into widget values ($widgetId, $_[0], '$_[1]', '$nextSeq', ".quote($_[2]).", '$_[3]', ".quote($_[4]).", '$_[5]', ".time().", '$session{user}{userId}', 0, 0, '$_[6]')");
	return $widgetId;
}

#-------------------------------------------------------------------
sub getPositions {
	my (%hash);
	tie %hash, "Tie::IxHash";
	%hash = WebGUI::Template::getPositions($session{page}{template});
	return %hash;
}

#-------------------------------------------------------------------
sub getProperties {
        my (%data);
        tie %data, 'Tie::CPHash';
        %data = WebGUI::SQL->quickHash("select * from widget,$_[0] where widget.widgetId=$_[1] and widget.widgetId=$_[0].widgetId");
        return %data;
}

#-------------------------------------------------------------------
sub purgeWidget {
        WebGUI::SQL->write("delete from $_[2] where widgetId=$_[0]",$_[1]);
        WebGUI::SQL->write("delete from widget where widgetId=$_[0]",$_[1]);
        WebGUI::Attachment::purgeWidget($_[0]);
}

#-------------------------------------------------------------------
sub update {
	WebGUI::SQL->write("update widget set title=".quote($session{form}{title}).", displayTitle='$session{form}{displayTitle}', description=".quote($session{form}{description}).", processMacros='$session{form}{processMacros}', lastEdited=".time().", editedBy='$session{user}{userId}', templatePosition='$session{form}{templatePosition}' where widgetId=$session{form}{wid}");
}

#-------------------------------------------------------------------
sub www_cut {
        if (WebGUI::Privilege::canEditPage()) {
                WebGUI::SQL->write("update widget set pageId=2 where widgetId=".$session{form}{wid});
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
                $output = '<a href="'.WebGUI::URL::page('op=viewHelp&hid=14').'"><img src="'.
			$session{setting}{lib}.'/help.gif" border="0" align="right"></a>';
		$output .= '<h1>'.WebGUI::International::get(42).'</h1>';
                $output .= WebGUI::International::get(43);
		$output .= '<p>';
                $output .= '<div align="center"><a href="'.WebGUI::URL::page('func=deleteConfirm&wid='.
			$session{form}{wid}).'">';
		$output .= WebGUI::International::get(44); 
		$output .= '</a>';
                $output .= '&nbsp;&nbsp;&nbsp;&nbsp;<a href="'.WebGUI::URL::page().'">';
		$output .= WebGUI::International::get(45);
		$output .= '</a></div>';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteConfirm {
        if (WebGUI::Privilege::canEditPage()) {
                WebGUI::SQL->write("update widget set pageId=3 where widgetId=".$session{form}{wid});
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
                WebGUI::SQL->write("update widget set sequenceNumber=9999 where widgetId=$session{form}{wid}");
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
                WebGUI::SQL->write("update widget set sequenceNumber=0 where widgetId=$session{form}{wid}");
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
		($thisSeq) = WebGUI::SQL->quickArray("select sequenceNumber from widget where widgetId=$session{form}{wid}");
		@data = WebGUI::SQL->quickArray("select widgetId from widget where pageId=$session{page}{pageId} and sequenceNumber=$thisSeq+1");
		if ($data[0] ne "") {
                	WebGUI::SQL->write("update widget set sequenceNumber=sequenceNumber+1 where widgetId=$session{form}{wid}");
                	WebGUI::SQL->write("update widget set sequenceNumber=sequenceNumber-1 where widgetId=$data[0]");
                	_reorderWidgets($session{page}{pageId});
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
                ($thisSeq) = WebGUI::SQL->quickArray("select sequenceNumber from widget where widgetId=$session{form}{wid}");
                @data = WebGUI::SQL->quickArray("select widgetId from widget where pageId=$session{page}{pageId} and sequenceNumber=$thisSeq-1");
                if ($data[0] ne "") {
                        WebGUI::SQL->write("update widget set sequenceNumber=sequenceNumber-1 where widgetId=$session{form}{wid}");
                        WebGUI::SQL->write("update widget set sequenceNumber=sequenceNumber+1 where widgetId=$data[0]");
                	_reorderWidgets($session{page}{pageId});
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
		($nextSeq) = WebGUI::SQL->quickArray("select max(sequenceNumber)+1 from widget where pageId=$session{page}{pageId}");
                WebGUI::SQL->write("update widget set pageId=$session{page}{pageId}, sequenceNumber='$nextSeq' where widgetId=$session{form}{wid}");
               	_reorderWidgets($session{page}{pageId});
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

1;
