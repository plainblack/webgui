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
use WebGUI::Form;
use WebGUI::International;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::Shortcut;
use WebGUI::SQL;
use WebGUI::Template;
use WebGUI::URL;
use WebGUI::Utility;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_movePageUp &www_movePageDown &www_addPage &www_addPageSave &www_cutPage &www_deletePage &www_deletePageConfirm &www_editPage &www_editPageSave &www_pastePage);

#-------------------------------------------------------------------
sub _recursivelyChangePrivileges {
        my ($sth, $pageId);
        $sth = WebGUI::SQL->read("select pageId from page where parentId=$_[0]");
        while (($pageId) = $sth->array) {
        	WebGUI::SQL->write("update page set ownerId=$session{form}{ownerId}, ownerView=$session{form}{ownerView}, ownerEdit=$session{form}{ownerEdit}, groupId='$session{form}{groupId}', groupView=$session{form}{groupView}, groupEdit=$session{form}{groupEdit}, worldView=$session{form}{worldView}, worldEdit=$session{form}{worldEdit} where pageId=$pageId");
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
                WebGUI::SQL->write("update page set sequenceNumber='$i' where pageId=$pid");
                $i++;
        }
        $sth->finish;
}

#-------------------------------------------------------------------
sub www_addPage {
	my ($output, @array, %hash);
	tie %hash, "Tie::IxHash";
	if (WebGUI::Privilege::canEditPage()) {
		$output = helpLink(1);
		$output .= '<h1>'.WebGUI::International::get(98).'</h1>';
		$output .= formHeader();
		$output .= WebGUI::Form::hidden("op","addPageSave");
		$output .= WebGUI::Form::hidden("root","1");
		$output .= '<table>';
		$output .= tableFormRow(WebGUI::International::get(99),WebGUI::Form::text("title",20,128,$session{form}{title}));
		%hash = sortHash(WebGUI::Template::getList());
		$array[0] = "Default";
		$output .= '<script language="JavaScript"> function updateTemplateImage(template) { document.template.src = "'.$session{setting}{lib}.'/templates/"+template+".gif"; } </script>';
		$output .= tableFormRow(WebGUI::International::get(356),WebGUI::Form::selectList("template",\%hash, \@array, 1, 0, "updateTemplateImage(this.form.template.value)").'<br><img src="'.$session{setting}{lib}.'/templates/Default.gif" name="template">');
		$output .= tableFormRow(WebGUI::International::get(100),WebGUI::Form::textArea("metaTags",$session{form}{metaTags}));
                $output .= tableFormRow(WebGUI::International::get(307),WebGUI::Form::checkbox("defaultMetaTags",1,1));
		$output .= formSave();
		$output .= '</table></form>';	
		return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_addPageSave {
	my ($urlizedTitle, $test, $nextSeq, $parentId);
	if (WebGUI::Privilege::canEditPage()) {
		($nextSeq) = WebGUI::SQL->quickArray("select max(sequenceNumber)+1 from page where parentId=$session{page}{pageId}");
		if ($session{form}{title} eq "") {
			$session{form}{title} = "no title";
		}
		if ($session{form}{root}) {
			$parentId = 0;
		} else {
			$parentId = $session{page}{pageId};
		}
		$urlizedTitle = WebGUI::URL::urlize($session{form}{title});
		while (($test) = WebGUI::SQL->quickArray("select urlizedTitle from page where urlizedTitle='$urlizedTitle'")) {
			$urlizedTitle .= 2;
		}
		WebGUI::SQL->write("insert into page values (".getNextId("pageId").", $parentId, ".quote($session{form}{title}).", $session{page}{styleId}, $session{user}{userId}, $session{page}{ownerView}, $session{page}{ownerEdit}, $session{page}{groupId}, $session{page}{groupView}, $session{page}{groupEdit}, $session{page}{worldView}, $session{page}{worldEdit}, '$nextSeq', ".quote($session{form}{metaTags}).", '$urlizedTitle', '$session{form}{defaultMetaTags}', '$session{form}{template}')");
		return "";
	} else {
		return WebGUI::Privilege::insufficient();
	}
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
		$output .= helpLink(3);
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
        my ($output, %yesNo, %hash, @array);
	tie %hash, "Tie::IxHash";
        if (WebGUI::Privilege::canEditPage()) {
		%yesNo = ("0"=>"No", "1"=>"Yes");
                $output = helpLink(1);
		$output .= '<h1>'.WebGUI::International::get(102).'</h1>';
		$output .= formHeader();
                $output .= WebGUI::Form::hidden("op","editPageSave");
                $output .= '<table>';
		$output .= '<tr><td colspan=2><b>'.WebGUI::International::get(103).'</b></td></tr>';
                $output .= tableFormRow(WebGUI::International::get(99),
			WebGUI::Form::text("title",20,128,$session{page}{title}));
                $output .= tableFormRow(WebGUI::International::get(104),
			WebGUI::Form::text("urlizedTitle",20,128,$session{page}{urlizedTitle}));
		%hash = sortHash(WebGUI::Template::getList());
                $array[0] = $session{page}{template};
                $output .= '<script language="JavaScript"> function updateTemplateImage(template) { document.template.src = "'.$session{setting}{lib}.'/templates/"+template+".gif"; } </script>';
                $output .= tableFormRow(WebGUI::International::get(356),
			WebGUI::Form::selectList("template",\%hash,\@array,1,0,"updateTemplateImage(this.form.template.value)").'<br><img src="'.$session{setting}{lib}.'/templates/'.$session{page}{template}.'.gif" name="template">');
                $output .= tableFormRow(WebGUI::International::get(100),WebGUI::Form::textArea("metaTags",$session{page}{metaTags}));
                $output .= tableFormRow(WebGUI::International::get(307),WebGUI::Form::checkbox("defaultMetaTags",1,$session{page}{defaultMetaTags}));
		$output .= '<tr><td colspan=2><hr size=1><b>'.WebGUI::International::get(105).'</b></td></tr>';
		%hash = WebGUI::SQL->buildHash("select styleId,name from style where name<>'Reserved' order by name");
		$array[0] = $session{page}{styleId};
                $output .= tableFormRow(WebGUI::International::get(105),
			WebGUI::Form::selectList("styleId",\%hash,\@array).
			' <span class="formSubtext"><a href="'.WebGUI::URL::page('op=listStyles').
			'">'.WebGUI::International::get(6).'</a></span>');
                $output .= tableFormRow("",WebGUI::Form::checkbox("recurseStyle","yes").' <span class="formSubtext">'.WebGUI::International::get(106).'</span>');
		$output .= '<tr><td colspan=2><hr size=1><b>'.WebGUI::International::get(107).'</b></td></tr>';
		%hash = WebGUI::SQL->buildHash("select users.userId,users.username from users,groupings where groupings.groupId=4 and groupings.userId=users.userId order by users.username");
		$array[0] = $session{page}{ownerId};
                $output .= tableFormRow(WebGUI::International::get(108),
			WebGUI::Form::selectList("ownerId",\%hash,\@array).
			' <span class="formSubtext"><a href="'.WebGUI::URL::page('op=listUsers').'">'.
			WebGUI::International::get(7).'</a></span>');
		$array[0] = $session{page}{ownerView};
                $output .= tableFormRow(WebGUI::International::get(109),
			WebGUI::Form::selectList("ownerView",\%yesNo,\@array));
		$array[0] = $session{page}{ownerEdit};
                $output .= tableFormRow(WebGUI::International::get(110),
			WebGUI::Form::selectList("ownerEdit",\%yesNo,\@array));
		%hash = WebGUI::SQL->buildHash("select groupId,groupName from groups where groupName<>'Reserved' order by groupName");
		$array[0] = $session{page}{groupId};
                $output .= tableFormRow(WebGUI::International::get(111),
			WebGUI::Form::selectList("groupId",\%hash,\@array).
			' <span class="formSubtext"><a href="'.WebGUI::URL::page('op=listGroups').'">'.
			WebGUI::International::get(5).'</a></span>');
		$array[0] = $session{page}{groupView};
                $output .= tableFormRow(WebGUI::International::get(112),WebGUI::Form::selectList("groupView",\%yesNo,\@array));
		$array[0] = $session{page}{groupEdit};
                $output .= tableFormRow(WebGUI::International::get(113),WebGUI::Form::selectList("groupEdit",\%yesNo,\@array));
		$array[0] = $session{page}{worldView};
                $output .= tableFormRow(WebGUI::International::get(114),WebGUI::Form::selectList("worldView",\%yesNo,\@array));
		$array[0] = $session{page}{worldEdit};
                $output .= tableFormRow(WebGUI::International::get(115),WebGUI::Form::selectList("worldEdit",\%yesNo,\@array));
                $output .= tableFormRow("",WebGUI::Form::checkbox("recursePrivs","yes").' <span class="formSubtext">'.WebGUI::International::get(116).'</span>');
                $output .= formSave();
                $output .= '</table></form>';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editPageSave {
        my (%parent, $urlizedTitle, $test);
        if (WebGUI::Privilege::canEditPage()) {
                if ($session{form}{title} eq "") {
                        $session{form}{title} = "no title";
                }
                $urlizedTitle = WebGUI::URL::urlize($session{form}{urlizedTitle});
                while (($test) = WebGUI::SQL->quickArray("select urlizedTitle from page where urlizedTitle='$urlizedTitle' and pageId<>$session{page}{pageId}")) {
                        $urlizedTitle .= 2;
                }
                WebGUI::SQL->write("update page set title=".quote($session{form}{title}).", styleId=$session{form}{styleId}, ownerId=$session{form}{ownerId}, ownerView=$session{form}{ownerView}, ownerEdit=$session{form}{ownerEdit}, groupId='$session{form}{groupId}', groupView=$session{form}{groupView}, groupEdit=$session{form}{groupEdit}, worldView=$session{form}{worldView}, worldEdit=$session{form}{worldEdit}, metaTags=".quote($session{form}{metaTags}).", urlizedTitle='$urlizedTitle', defaultMetaTags='$session{form}{defaultMetaTags}', template='$session{form}{template}' where pageId=$session{page}{pageId}");
		if ($session{form}{recurseStyle} eq "yes") {
			_recursivelyChangeStyle($session{page}{pageId});
		}
		if ($session{form}{recursePrivs} eq "yes") {
			_recursivelyChangePrivileges($session{page}{pageId});
		}
		WebGUI::Session::refreshPageInfo($session{page}{pageId});
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
		($nextSeq) = WebGUI::SQL->quickArray("select max(sequenceNumber)+1 from page where parentId=$session{page}{pageId}");
        if (WebGUI::Privilege::canEditPage()) {
                WebGUI::SQL->write("update page set parentId=$session{page}{pageId}, sequenceNumber='$nextSeq' where pageId=$session{form}{pageId}");
		_reorderPages($session{page}{pageId});
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}


1;

