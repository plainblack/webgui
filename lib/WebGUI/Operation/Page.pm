package WebGUI::Operation::Page;

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
use strict;
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Template;
use WebGUI::URL;
use WebGUI::Utility;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_viewPageTree &www_movePageUp &www_movePageDown &www_cutPage &www_deletePage &www_deletePageConfirm 
	&www_editPage &www_editPageSave &www_pastePage);

#-------------------------------------------------------------------
sub _recursivelyChangePrivileges {
        my ($sth, $pageId);
        $sth = WebGUI::SQL->read("select pageId from page where parentId=$_[0]");
        while (($pageId) = $sth->array) {
        	WebGUI::SQL->write("update page set ownerId=$session{form}{ownerId}, ownerView=$session{form}{ownerView}, 
			ownerEdit=$session{form}{ownerEdit}, groupId='$session{form}{groupId}', groupView=$session{form}{groupView}, 
			groupEdit=$session{form}{groupEdit}, worldView=$session{form}{worldView}, worldEdit=$session{form}{worldEdit} 
			where pageId=$pageId");
                _recursivelyChangePrivileges($pageId);
        }
	$sth->finish;
}

#-------------------------------------------------------------------
sub _recursivelyChangeStyle {
	my ($sth, $pageId);
	$sth = WebGUI::SQL->read("select pageId from page where parentId=$_[0]");	
	while (($pageId) = $sth->array) {
		WebGUI::SQL->write("update page set styleId=$session{form}{styleId} where pageId=$pageId");
		_recursivelyChangeStyle($pageId);
	}
	$sth->finish;
}

#-------------------------------------------------------------------
sub _reorderPages {
        my ($sth, $i, $pid);
        $sth = WebGUI::SQL->read("select pageId from page where parentId=$_[0] order by sequenceNumber");
        while (($pid) = $sth->array) {
                $i++;
                WebGUI::SQL->write("update page set sequenceNumber='$i' where pageId=$pid");
        }
        $sth->finish;
}

#-------------------------------------------------------------------
sub _traversePageTree {
        my ($a, $b, %page, %wobject, $output, $depth, $i, $spacer);
	tie %page, 'Tie::CPHash';
	tie %wobject, 'Tie::CPHash';
        $spacer = '<img src="'.$session{setting}{lib}.'/spacer.gif" width=12>';
        for ($i=1;$i<=$_[1];$i++) {
                $depth .= $spacer;
        }
        $a = WebGUI::SQL->read("select * from page where (pageId<2 or pageId>25) and parentId='$_[0]' order by sequenceNumber");
        while (%page = $a->hash) {
                $output .= $depth.'<img src="'.$session{setting}{lib}.'/page.gif" align="middle">'.
			' <a href="'.WebGUI::URL::gateway($page{urlizedTitle}).'">'.$page{title}.'</a><br>';
		$b = WebGUI::SQL->read("select * from wobject where pageId=$page{pageId}");
		while (%wobject = $b->hash) {
                	$output .= $depth.$spacer.
				'<img src="'.$session{setting}{lib}.'/wobject.gif"> '.
				$wobject{title}.'<br>';
		}
		$b->finish;
                $output .= _traversePageTree($page{pageId},$_[1]+1);
        }
        $a->finish;
        return $output;
}

#-------------------------------------------------------------------
sub www_cutPage {
        if ($session{page}{pageId} < 26) {
                return WebGUI::Privilege::vitalComponent();
        } elsif (WebGUI::Privilege::canEditPage()) {
                WebGUI::SQL->write("update page set parentId=2 where pageId=".$session{page}{pageId});
		_reorderPages($session{page}{parentId});
                WebGUI::Session::refreshPageInfo($session{page}{parentId});
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deletePage {
	my ($output);
	if ($session{page}{pageId} < 26) {
		return WebGUI::Privilege::vitalComponent();
	} elsif (WebGUI::Privilege::canEditPage()) {
		$output .= helpIcon(3);
		$output .= '<h1>'.WebGUI::International::get(42).'</h1>';
		$output .= WebGUI::International::get(101).'<p>';
		$output .= '<div align="center"><a href="'.WebGUI::URL::page('op=deletePageConfirm').
			'">'.WebGUI::International::get(44).'</a>';
		$output .= '&nbsp;&nbsp;&nbsp;&nbsp;<a href="'.WebGUI::URL::page().'">'.
			WebGUI::International::get(45).'</a></div>';
		return $output;
	} else {
		return WebGUI::Privilege::insufficient();
	}
}

#-------------------------------------------------------------------
sub www_deletePageConfirm {
        if ($session{page}{pageId} < 25) {
		return WebGUI::Privilege::vitalComponent();
        } elsif (WebGUI::Privilege::canEditPage()) {
		WebGUI::SQL->write("update page set parentId=3 where pageId=".$session{page}{pageId});
		_reorderPages($session{page}{parentId});
		WebGUI::Session::refreshPageInfo($session{page}{parentId});
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editPage {
        my ($f, $output, %hash, %page);
	tie %hash, "Tie::IxHash";
        if (WebGUI::Privilege::canEditPage($session{form}{npp})) {
		$f = WebGUI::HTMLForm->new;
		if ($session{form}{npp} ne "") {
			%page = WebGUI::SQL->quickHash("select * from page where pageId=$session{form}{npp}");
			$page{templateId} = 1;
			$page{pageId} = "new";
			$page{title} = $page{menuTitle} = $page{urlizedTitle} = $page{synopsis} = '';
			$page{parentId} = $session{form}{npp};
			$page{ownerEdit} = 1;
			$page{ownerView} = 1;
		} else {
			%page = %{$session{page}};
		}
                $output = helpIcon(1);
		$output .= '<h1>'.WebGUI::International::get(102).'</h1>';
		$f->hidden("pageId",$page{pageId});
		$f->hidden("parentId",$page{parentId});
		$f->hidden("op","editPageSave");
		$f->raw('<tr><td colspan=2><b>'.WebGUI::International::get(103).'</b></td></tr>');
		$f->readOnly($page{pageId},WebGUI::International::get(500));
                $f->text("title",WebGUI::International::get(99),$page{title});
		$f->text("menuTitle",WebGUI::International::get(411),$page{menuTitle});
                $f->text("urlizedTitle",WebGUI::International::get(104),$page{urlizedTitle});
		$f->readOnly(WebGUI::Template::selectTemplate($page{templateId}),WebGUI::International::get(356));
		$f->textarea("synopsis",WebGUI::International::get(412),$page{synopsis});
		$f->textarea("metatags",WebGUI::International::get(100),$page{metaTags});
                $f->yesNo("defaultMetaTags",WebGUI::International::get(307),$page{defaultMetaTags});
		$f->raw('<tr><td colspan=2><hr size=1><b>'.WebGUI::International::get(105).'</b></td></tr>');
		%hash = WebGUI::SQL->buildHash("select styleId,name from style where name<>'Reserved' order by name");
                $f->select("styleId",\%hash,WebGUI::International::get(105),[$page{styleId}],'','','',
			' &nbsp; <a href="'.WebGUI::URL::page('op=listStyles').'">'.WebGUI::International::get(6).'</a>');
                $f->yesNo("recurseStyle",'','','',' &nbsp; '.WebGUI::International::get(106));
		$f->raw('<tr><td colspan=2><hr size=1><b>'.WebGUI::International::get(107).'</b></td></tr>');
		%hash = WebGUI::SQL->buildHash("select users.userId,users.username from users,groupings 
			where groupings.groupId=4 and groupings.userId=users.userId order by users.username");
		$f->select("ownerId",\%hash,WebGUI::International::get(108),[$page{ownerId}],'','','',
			' &nbsp; <a href="'.WebGUI::URL::page('op=listUsers').'">'.WebGUI::International::get(7).'</a>');
		$f->yesNo("ownerView",WebGUI::International::get(109),$page{ownerView});
                $f->yesNo("ownerEdit",WebGUI::International::get(110),$page{ownerEdit});
		$f->group("groupId",WebGUI::International::get(111),[$page{groupId}],'','','',
			' &nbsp; <a href="'.WebGUI::URL::page('op=listGroups').'">'.WebGUI::International::get(5).'</a>');
		$f->yesNo("groupView",WebGUI::International::get(112),$page{groupView});
                $f->yesNo("groupEdit",WebGUI::International::get(113),$page{groupEdit});
                $f->yesNo("worldView",WebGUI::International::get(114),$page{worldView});
                $f->yesNo("worldEdit",WebGUI::International::get(115),$page{worldEdit});
                $f->yesNo("recursePrivs",'','','',' &nbsp; '.WebGUI::International::get(116));
		$f->submit;
		$output .= $f->print;
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editPageSave {
        my ($nextSeq, $pageId);
	if ($session{form}{pageId} eq "new") {
		$pageId = $session{form}{parentId};
	} else {
		$pageId = $session{form}{pageId};
	}
        if (WebGUI::Privilege::canEditPage($pageId)) {
		if ($session{form}{pageId} eq "new") {
			($nextSeq) = WebGUI::SQL->quickArray("select max(sequenceNumber) from page where pageId=$session{page}{parentId}");
                	$nextSeq += 1;
			$session{form}{pageId} = getNextId("pageId");
			WebGUI::SQL->write("insert into page (pageId,sequenceNumber,parentId) 
				values ($session{form}{pageId},$nextSeq,$session{form}{parentId})");
		}
                $session{form}{title} = "no title" if ($session{form}{title} eq "");
                $session{form}{menuTitle} = $session{form}{title} if ($session{form}{menuTitle} eq "");
                $session{form}{urlizedTitle} = $session{form}{menuTitle} if ($session{form}{urlizedTitle} eq "");
		$session{form}{urlizedTitle} = WebGUI::URL::makeUnique(WebGUI::URL::urlize($session{form}{urlizedTitle}),$session{form}{pageId});
                WebGUI::SQL->write("update page set 
			title=".quote($session{form}{title}).", 
			styleId=$session{form}{styleId}, 
			ownerId=$session{form}{ownerId}, 
			ownerView=$session{form}{ownerView}, 
			ownerEdit=$session{form}{ownerEdit}, 
			groupId='$session{form}{groupId}', 
			groupView=$session{form}{groupView}, 
			groupEdit=$session{form}{groupEdit}, 
			worldView=$session{form}{worldView}, 
			worldEdit=$session{form}{worldEdit},
			metaTags=".quote($session{form}{metaTags}).", 
			urlizedTitle='$session{form}{urlizedTitle}', 
			defaultMetaTags='$session{form}{defaultMetaTags}', 
			templateId='$session{form}{templateId}', 
			menuTitle=".quote($session{form}{menuTitle}).", 
			synopsis=".quote($session{form}{synopsis})." 
			where pageId=$session{form}{pageId}");
		_recursivelyChangeStyle($session{page}{pageId}) if ($session{form}{recurseStyle});
		_recursivelyChangePrivileges($session{page}{pageId}) if ($session{form}{recursePrivs});
		WebGUI::Session::refreshPageInfo($session{page}{pageId}) if ($session{form}{pageId} == $session{page}{pageId});
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_movePageDown {
        my (@data, $thisSeq);
        if (WebGUI::Privilege::canEditPage()) {
                ($thisSeq) = WebGUI::SQL->quickArray("select sequenceNumber from page where pageId=$session{page}{pageId}");
                @data = WebGUI::SQL->quickArray("select pageId from page where parentId=$session{page}{parentId} and sequenceNumber=$thisSeq+1");
                if ($data[0] ne "") {
                        WebGUI::SQL->write("update page set sequenceNumber=sequenceNumber+1 where pageId=$session{page}{pageId}");
                        WebGUI::SQL->write("update page set sequenceNumber=sequenceNumber-1 where pageId=$data[0]");
                }
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_movePageUp {
        my (@data, $thisSeq);
        if (WebGUI::Privilege::canEditPage()) {
                ($thisSeq) = WebGUI::SQL->quickArray("select sequenceNumber from page where pageId=$session{page}{pageId}");
                @data = WebGUI::SQL->quickArray("select pageId from page where parentId=$session{page}{parentId} and sequenceNumber=$thisSeq-1");
                if ($data[0] ne "") {
                        WebGUI::SQL->write("update page set sequenceNumber=sequenceNumber-1 where pageId=$session{page}{pageId}");
                        WebGUI::SQL->write("update page set sequenceNumber=sequenceNumber+1 where pageId=$data[0]");
                }
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_pastePage {
        my ($output, $nextSeq);
	($nextSeq) = WebGUI::SQL->quickArray("select max(sequenceNumber) from page where parentId=$session{page}{pageId}");
	$nextSeq += 1;
        if (WebGUI::Privilege::canEditPage()) {
                WebGUI::SQL->write("update page set parentId=$session{page}{pageId}, sequenceNumber='$nextSeq' where pageId=$session{form}{pageId}");
		_reorderPages($session{page}{pageId});
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_viewPageTree {
	my ($output);
	$output = '<h1>'.WebGUI::International::get(448).'</h1>';
	$output .= _traversePageTree(0,0);
	return $output;
}

1;

