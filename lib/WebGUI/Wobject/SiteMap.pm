package WebGUI::Wobject::SiteMap;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Tie::CPHash;
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::Wobject;

our @ISA = qw(WebGUI::Wobject);
our $namespace = "SiteMap";
our $name = WebGUI::International::get(2,$namespace);

#-------------------------------------------------------------------
sub _traversePageTree {
        my ($lineSpacing, $sth, @data, $output, $depth, $i, $toLevel);
        if ($_[2] > 0) {
                $toLevel = $_[2];
        } else {
                $toLevel = 99;
        }
        for ($i=1;$i<=($_[1]*$_[3]);$i++) {
                $depth .= "&nbsp;";
        }
	for ($i=1;$i<=$_[5];$i++) {
		$lineSpacing .= "<br>";
	}
        if ($_[1] < $toLevel) {
                $sth = WebGUI::SQL->read("select urlizedTitle, title, pageId, synopsis from page where parentId='$_[0]' order by sequenceNumber");
                while (@data = $sth->array) {
                        if (WebGUI::Privilege::canViewPage($data[2])) {
                                $output .= $depth.$_[4].' <a href="'.WebGUI::URL::gateway($data[0]).'">'.$data[1].'</a>';
				if ($data[3] ne "" && $_[6]) {
					$output .= ' - '.$data[3];
				}
				$output .= $lineSpacing;
                                $output .= _traversePageTree($data[2],($_[1]+1),$_[2],$_[3],$_[4],$_[5],$_[6]);
                        }
                }
                $sth->finish;
        }
        return $output;
}

#-------------------------------------------------------------------
sub duplicate {
        my ($w, $f);
        $w = $_[0]->SUPER::duplicate($_[1]);
        $w = WebGUI::Wobject::SiteMap->new({wobjectId=>$w,namespace=>$namespace});
        $w->set({
                startAtThisLevel=>$_[0]->get("startAtThisLevel"),
                indent=>$_[0]->get("indent"),
                bullet=>$_[0]->get("bullet"),
                lineSpacing=>$_[0]->get("lineSpacing"),
                displaySynopsis=>$_[0]->get("displaySynopsis"),
                depth=>$_[0]->get("depth")
                });
}

#-------------------------------------------------------------------
sub set {
        $_[0]->SUPER::set($_[1],[qw(startAtThisLevel displaySynopsis indent bullet lineSpacing depth)]);
}

#-------------------------------------------------------------------
sub www_edit {
        my ($output, $f, $indent, $bullet, $lineSpacing);
        if (WebGUI::Privilege::canEditPage()) {
		$indent = $_[0]->get("indent") || 5;
		$bullet = $_[0]->get("bullet") || '&middot;';
		$lineSpacing = $_[0]->get("lineSpacing") || 1;
                $output = helpIcon(1,$_[0]->get("namespace"));
                $output .= '<h1>'.WebGUI::International::get(5,$namespace).'</h1>';
                $f = WebGUI::HTMLForm->new;
		$f->yesNo("displaySynopsis",WebGUI::International::get(9,$namespace),$_[0]->get("displaySynopsis"));
                $f->yesNo("startAtThisLevel",WebGUI::International::get(3,$namespace),$_[0]->get("startAtThisLevel"));
                $f->integer("depth",WebGUI::International::get(4,$namespace),$_[0]->get("depth"));
		$f->integer("indent",WebGUI::International::get(6,$namespace),$indent);
                $f->text("bullet",WebGUI::International::get(7,$namespace),$bullet);
		$f->integer("lineSpacing",WebGUI::International::get(8,$namespace),$lineSpacing);
		$output .= $_[0]->SUPER::www_edit($f->printRowsOnly);
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editSave {
	my ($property);
        if (WebGUI::Privilege::canEditPage()) {
		$_[0]->SUPER::www_editSave();
		$property->{indent} = $session{form}{indent};
		$property->{displaySynopsis} = $session{form}{displaySynopsis};
		$property->{bullet} = $session{form}{bullet};
		$property->{startAtThisLevel} = $session{form}{startAtThisLevel};
		$property->{depth} = $session{form}{depth};
		$property->{lineSpacing} = $session{form}{lineSpacing};
		$_[0]->set($property);
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_view {
        my (@question, $output, $parent);
        $output = $_[0]->displayTitle;
        $output .= $_[0]->description;
	if ($_[0]->get("startAtThisLevel")) {
		$parent = $session{page}{pageId};
	} else {
		$parent = 1;
	}
	$output .= _traversePageTree($parent,0,$_[0]->get("depth"),$_[0]->get("indent"),$_[0]->get("bullet"),$_[0]->get("lineSpacing"),$_[0]->get("displaySynopsis"));
        return $_[0]->processMacros($output);
}

1;

