package WebGUI::Operation::Trash;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use Exporter;
use strict qw(vars subs);
use WebGUI::Icon;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_purgeTrash &www_purgeTrashConfirm);

#-------------------------------------------------------------------
sub _purgeWobjects {
	my ($b, $wobjectId, $namespace, $w, $cmd);
	$b = WebGUI::SQL->read("select wobjectId, namespace from wobject where pageId=$_[0]");
        while (($wobjectId,$namespace) = $b->array) {
        	$cmd = "WebGUI::Wobject::".$namespace;
                $w = $cmd->new({wobjectId=>$wobjectId,namespace=>$namespace});
		$w->purge;
        }
        $b->finish;
}

#-------------------------------------------------------------------
sub _recursePageTree {
        my ($a, $pageId);
        $a = WebGUI::SQL->read("select pageId from page where parentId=$_[0]");
        while (($pageId) = $a->array) {
                _recursePageTree($pageId);
		_purgeWobjects($pageId);
                WebGUI::SQL->write("delete from page where pageId=$pageId");
        }
        $a->finish;
}

#-------------------------------------------------------------------
sub www_purgeTrash {
        my ($output);
        if (WebGUI::Privilege::isInGroup(3)) {
                $output = helpIcon(46);
		$output .= '<h1>'.WebGUI::International::get(42).'</h1>';
                $output .= WebGUI::International::get(162).'<p>';
                $output .= '<div align="center"><a href="'.WebGUI::URL::page('op=purgeTrashConfirm').
			'">'.WebGUI::International::get(44).'</a>';
                $output .= '&nbsp;&nbsp;&nbsp;&nbsp;<a href="'.WebGUI::URL::page().'">'.
			WebGUI::International::get(45).'</a></div>';
                return $output;
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}

#-------------------------------------------------------------------
sub www_purgeTrashConfirm {
        if (WebGUI::Privilege::isInGroup(3)) {
		_recursePageTree(3);
		_purgeWobjects(3);
		return "";
	} else {
		return WebGUI::Privilege::adminOnly();
	}
}

1;
