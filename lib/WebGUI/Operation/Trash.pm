package WebGUI::Operation::Trash;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use Exporter;
use strict qw(vars subs);
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::Shortcut;
use WebGUI::SQL;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_purgeTrash &www_purgeTrashConfirm);

#-------------------------------------------------------------------
sub _purgeWidgets {
	my ($b, $widgetId, $widgetType, $func);
	$b = WebGUI::SQL->read("select widgetId, namespace from widget where pageId=$_[0]");
        while (($widgetId,$widgetType) = $b->array) {
        	$func = "WebGUI::Widget::".$widgetType."::purge";
                &$func($widgetId);
        }
        $b->finish;
}

#-------------------------------------------------------------------
sub _recursePageTree {
        my ($a, $pageId);
        $a = WebGUI::SQL->read("select pageId from page where parentId=$_[0]");
        while (($pageId) = $a->array) {
                _recursePageTree($pageId);
		_purgeWidgets($pageId);
                WebGUI::SQL->write("delete from page where pageId=$pageId");
        }
        $a->finish;
}

#-------------------------------------------------------------------
sub www_purgeTrash {
        my ($output);
        if (WebGUI::Privilege::isInGroup(3)) {
                $output = helpLink(46);
		$output .= '<h1>'.WebGUI::International::get(42).'</h1>';
                $output .= WebGUI::International::get(162).'<p>';
                $output .= '<div align="center"><a href="'.$session{page}{url}.'?op=purgeTrashConfirm">'.WebGUI::International::get(44).'</a>';
                $output .= '&nbsp;&nbsp;&nbsp;&nbsp;<a href="'.$session{page}{url}.'">'.WebGUI::International::get(45).'</a></div>';
                return $output;
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_purgeTrashConfirm {
        if (WebGUI::Privilege::isInGroup(3)) {
		_recursePageTree(3);
		_purgeWidgets(3);
		return "";
	} else {
		return WebGUI::Privilege::adminOnly();
	}
}

1;
