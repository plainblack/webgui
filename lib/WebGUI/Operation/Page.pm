package WebGUI::Operation::Page;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2003 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use Exporter;
use strict;
use WebGUI::DateTime;
use WebGUI::Grouping;
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Page;
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
        	WebGUI::SQL->write("update page set startDate=$session{form}{startDate}, endDate=$session{form}{endDate},
			ownerId=$session{form}{ownerId},  groupIdView=$session{form}{groupIdView}, 
			groupIdEdit=$session{form}{groupIdEdit} where pageId=$pageId");
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
sub _selectPositions {
        my ($templates, $output, $f, $key);
        $f = WebGUI::HTMLForm->new(1);
        $templates = WebGUI::Page::getTemplateList();
        $f->select("templateId",$templates,'',[$_[0]],'','','onChange="changeTemplatePreview(this.form.templateId.value)"');
        $output = '
        <script language="JavaScript">
        function checkBrowser(){
                this.ver=navigator.appVersion;
                this.dom=document.getElementById?1:0;
                this.ie5=(this.ver.indexOf("MSIE 5")>-1 && this.dom)?1:0;
                this.ie4=(document.all && !this.dom)?1:0;
                this.ns5=(this.dom && parseInt(this.ver) >= 5) ?1:0;
                this.ns4=(document.layers && !this.dom)?1:0;
                this.bw=(this.ie5 || this.ie4 || this.ns4 || this.ns5 || this.dom);
                return this;
        }
        bw=new checkBrowser();
        function makeChangeTextObj(obj){
                this.css=bw.dom? document.getElementById(obj).style:bw.ie4?document.all[obj].style:bw.ns4?document.layers[obj]:0;
                this.writeref=bw.dom? document.getElementById(obj):bw.ie4?document.all[obj]:bw.ns4?document.layers[obj].document:0
;
                this.writeIt=b_writeIt;
        }
        function b_writeIt(text){
                var obj;
                if(bw.ns4) {
                if (document.loading) document.loading.visibility = "hidden";
                        this.writeref.write(text + "&nbsp;&nbsp;&nbsp;");
                        this.writeref.close();
                } else {
                        if (bw.ie4) {
                        if (document.all.loading) obj = document.all.loading;
                }
                if (obj) obj.style.visibility = "hidden";
                        this.writeref.innerHTML=text;
                }
        }
        function init(){
                if(bw.bw){
                        oMessage=new makeChangeTextObj("templatePreview");
                        oMessage.css.visibility="visible";
                        changeTemplatePreview('.$_[0].');
                }
        }
        onload=init
        function changeTemplatePreview(value) {
                oMessage.writeIt(eval("b"+value));
        }
        ';
        foreach $key (keys %{$templates}) {
                $output .= "    var b".$key." = '".WebGUI::Page::drawTemplate($key)."';\n";
        }
        $output .= '</script>';
        $output .= $f->printRowsOnly;
        $output .= '<div id="templatePreview" style="padding: 5px;"></div>';
        return $output;
}

#-------------------------------------------------------------------
sub _traversePageTree {
        my ($a, $b, %page, %wobject, $output, $depth, $i, $spacer);
	tie %page, 'Tie::CPHash';
	tie %wobject, 'Tie::CPHash';
        $spacer = '<img src="'.$session{config}{extrasURL}.'/spacer.gif" width=12>';
        for ($i=1;$i<=$_[1];$i++) {
                $depth .= $spacer;
        }
        $a = WebGUI::SQL->read("select * from page where (pageId=1 or pageId>999) and parentId='$_[0]' order by sequenceNumber");
        while (%page = $a->hash) {
		if (WebGUI::Privilege::canEditPage($page{pageId})) {
                	$output .= $depth
				.pageIcon()
				.deleteIcon('op=deletePage',$page{urlizedTitle})
				.editIcon('op=editPage',$page{urlizedTitle})
				.' <a href="'.WebGUI::URL::gateway($page{urlizedTitle}).'">'.$page{title}.'</a><br>';
			$b = WebGUI::SQL->read("select * from wobject where pageId=$page{pageId}");
			while (%wobject = $b->hash) {
                		$output .= $depth.$spacer
					.wobjectIcon()
					.deleteIcon('func=delete&wid='.$wobject{wobjectId},$page{urlizedTitle})
					.editIcon('func=edit&wid='.$wobject{wobjectId},$page{urlizedTitle})
					.' '. $wobject{title}.'<br>';
			}
			$b->finish;
		}
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
	if ($session{page}{pageId} < 1000 && $session{page}{pageId} > 0) {
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
	if ($session{page}{pageId} < 1000 && $session{page}{pageId} > 0) {
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
        my ($f, $endDate, $output, $subtext, $childCount, %hash, %page);
	tie %hash, "Tie::IxHash";
	tie %page, "Tie::CPHash";
        if (WebGUI::Privilege::canEditPage($session{form}{npp})) {
		$f = WebGUI::HTMLForm->new;
		if ($session{form}{npp} ne "") {
			my $buildFromPage = $session{form}{npp};
			if ($buildFromPage == 0) {
				$buildFromPage = $session{setting}{defaultPage};
			}
			%page = WebGUI::SQL->quickHash("select * from page where pageId=$buildFromPage");
			$page{templateId} = 1;
			$page{pageId} = "new";
			$page{title} = $page{menuTitle} = $page{urlizedTitle} = $page{synopsis} = '';
			$page{parentId} = $session{form}{npp};
			$page{ownerId} = $session{user}{userId};
		} else {
			%page = %{$session{page}};
			($childCount) = WebGUI::SQL->quickArray("select count(*) from page where parentId=$page{pageId}");
		}
		$page{endDate} = (addToDate(time(),10)) if ($page{endDate} < 0);
                $output = helpIcon(1);
		$output .= '<h1>'.WebGUI::International::get(102).'</h1>';
		$f->hidden("pageId",$page{pageId});
		$f->hidden("parentId",$page{parentId});
		$f->hidden("op","editPageSave");
		$f->submit if ($page{pageId} ne "new");
		$f->raw(
			-value=>'<tr><td colspan=2><b>'.WebGUI::International::get(103).'</b></td></tr>',
			-uiLevel=>5
			);
		$f->readOnly(
			-value=>$page{pageId},
			-label=>WebGUI::International::get(500),
			-uiLevel=>3
			);
                $f->text("title",WebGUI::International::get(99),$page{title});
		$f->text(
			-name=>"menuTitle",
			-label=>WebGUI::International::get(411),
			-value=>$page{menuTitle},
			-uiLevel=>1
			);
                $f->text(
			-name=>"urlizedTitle",
			-label=>WebGUI::International::get(104),
			-value=>$page{urlizedTitle},
			-uiLevel=>3
			);
		$f->select(
			-name=>"languageId",
			-label=>WebGUI::International::get(304),
			-value=>[$page{languageId}],
			-uiLevel=>1,
			-options=>WebGUI::International::getLanguages()
			);
                $f->url(
			-name=>"redirectURL",
			-label=>WebGUI::International::get(715),
			-value=>$page{redirectURL},
			-uiLevel=>9
			);
		$f->textarea(
			-name=>"synopsis",
			-label=>WebGUI::International::get(412),
			-value=>$page{synopsis},
			-uiLevel=>3
			);
		$f->textarea(
			-name=>"metaTags",
			-label=>WebGUI::International::get(100),
			-value=>$page{metaTags},
			-uiLevel=>7
			);
                $f->yesNo(
			-name=>"defaultMetaTags",
			-label=>WebGUI::International::get(307),
			-value=>$page{defaultMetaTags},
			-uiLevel=>5
			);
		$f->raw(
			-value=>'<tr><td colspan=2><hr size=1><b>'.WebGUI::International::get(105).'</b></td></tr>',
			-uiLevel=>5
			);
		%hash = WebGUI::SQL->buildHash("select styleId,name from style where name<>'Reserved' order by name");
		if (WebGUI::Privilege::isInGroup($session{setting}{styleManagersGroup})) {
			$subtext = ' &nbsp; <a href="'.WebGUI::URL::page('op=listStyles')
				.'">'.WebGUI::International::get(6).'</a>';
		} else {
			$subtext = "";
		}
                $f->select(
			-name=>"styleId",
			-options=>\%hash,
			-label=>WebGUI::International::get(105),
			-value=>[$page{styleId}],
			-subtext=>$subtext,
			-uiLevel=>5
			);
		if ($childCount) {
                	$f->yesNo(
				-name=>"recurseStyle",
				-subtext=>' &nbsp; '.WebGUI::International::get(106),
				-uiLevel=>9
				);
		}
                $f->readOnly(
                        -value=>_selectPositions($page{templateId}),
                        -label=>WebGUI::International::get(356),
                        -uiLevel=>5
                        );
		$f->raw(
			-value=>'<tr><td colspan=2><hr size=1><b>'.WebGUI::International::get(107).'</b></td></tr>',
			-uiLevel=>9
			);
        	$f->date(
			-name=>"startDate",
			-label=>WebGUI::International::get(497),
			-value=>$page{startDate},
			-uiLevel=>9
			);
        	$f->date(
			-name=>"endDate",
			-label=>WebGUI::International::get(498),
			-value=>$page{endDate},
			-uiLevel=>9
			);
		if (WebGUI::Privilege::isInGroup(3)) {
			$subtext = ' &nbsp; <a href="'.WebGUI::URL::page('op=listUsers').'">'
				.WebGUI::International::get(7).'</a>';
		} else {
			$subtext = "";
		}
		my $clause; 
		if (WebGUI::Privilege::isInGroup(3)) {
			my $contentManagers = WebGUI::Grouping::getUsersInGroup(4);
			$clause = "userId in ($session{user}{userId},".join(",",@$contentManagers).")";
		} else {
			$clause = "userId=$page{ownerId}";
                }
		my $users = WebGUI::SQL->buildHashRef("select userId,username from users where $clause order by username");
		$f->select(
			-name=>"ownerId",
			-options=>$users,
			-label=>WebGUI::International::get(108),
			-value=>[$page{ownerId}],
			-subtext=>$subtext,
			-uiLevel=>9
			);
		if (WebGUI::Privilege::isInGroup(3)) {
			$subtext = ' &nbsp; <a href="'.WebGUI::URL::page('op=listGroups').'">'
				.WebGUI::International::get(5).'</a>';
		} else {
			$subtext = "";
		}
		$f->group(
			-name=>"groupIdView",
			-label=>WebGUI::International::get(872),
			-value=>[$page{groupIdView}],
			-subtext=>$subtext,
			-uiLevel=>9
			);
                $f->group(
                        -name=>"groupIdEdit",
                        -label=>WebGUI::International::get(871),
                        -value=>[$page{groupIdEdit}],
                        -subtext=>$subtext,
			-excludeGroups=>[1,7],
                        -uiLevel=>9
                        );
		if ($childCount) {
                	$f->yesNo(
				-name=>"recursePrivs",
				-subtext=>' &nbsp; '.WebGUI::International::get(116),
				-uiLevel=>9
				);
		}
		$f->raw(
                        -value=>'<tr><td colspan=2><hr size=1/></td></tr>',
                        -uiLevel=>5
                        );
		if ($page{pageId} eq "new") {
                	$f->whatNext(
                        	-options=>{
                                	gotoNewPage=>WebGUI::International::get(823),
                               	 	backToPage=>WebGUI::International::get(847)
                                	},
                        	-value=>"gotoNewPage",
				-uiLevel=>1
                        	);
        	}
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
        return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage($pageId));
	if ($session{form}{pageId} eq "new") {
		($nextSeq) = WebGUI::SQL->quickArray("select max(sequenceNumber) from page where parentId=$session{form}{parentId}");
               	$nextSeq++;
		$session{form}{pageId} = getNextId("pageId");
		WebGUI::SQL->write("insert into page (pageId,sequenceNumber,parentId) 
			values ($session{form}{pageId},$nextSeq,$session{form}{parentId})");
	}
        $session{form}{title} = "no title" if ($session{form}{title} eq "");
        $session{form}{menuTitle} = $session{form}{title} if ($session{form}{menuTitle} eq "");
        $session{form}{urlizedTitle} = $session{form}{menuTitle} if ($session{form}{urlizedTitle} eq "");
	$session{form}{urlizedTitle} = WebGUI::Page::makeUnique(WebGUI::URL::urlize($session{form}{urlizedTitle}),$session{form}{pageId});
	$session{form}{startDate} = setToEpoch($session{form}{startDate}) || setToEpoch(time());
       	$session{form}{endDate} = setToEpoch($session{form}{endDate}) || setToEpoch(addToDate(time(),10));
        WebGUI::SQL->write("update page set 
		title=".quote($session{form}{title}).", 
		styleId=$session{form}{styleId}, 
		ownerId=$session{form}{ownerId}, 
		groupIdView=$session{form}{groupIdView}, 
		groupIdEdit=$session{form}{groupIdEdit}, 
		startDate=$session{form}{startDate},
		endDate=$session{form}{endDate},
		metaTags=".quote($session{form}{metaTags}).", 
		urlizedTitle='$session{form}{urlizedTitle}', 
		redirectURL='$session{form}{redirectURL}', 
		languageId='$session{form}{languageId}', 
		defaultMetaTags='$session{form}{defaultMetaTags}', 
		templateId='$session{form}{templateId}', 
		menuTitle=".quote($session{form}{menuTitle}).", 
		synopsis=".quote($session{form}{synopsis})." 
		where pageId=$session{form}{pageId}");
	WebGUI::SQL->write("update wobject set templatePosition=1 where pageId=$session{form}{pageId} 
		and templatePosition>".WebGUI::Page::countTemplatePositions($session{form}{templateId}));
	_recursivelyChangeStyle($session{form}{pageId}) if ($session{form}{recurseStyle});
	_recursivelyChangePrivileges($session{form}{pageId}) if ($session{form}{recursePrivs});
	if ($session{form}{proceed} eq "gotoNewPage") {
		WebGUI::Session::refreshPageInfo($session{form}{pageId});
	} elsif ($session{form}{pageId} == $session{page}{pageId}) {
		WebGUI::Session::refreshPageInfo($session{page}{pageId});
	}
       	return "";
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

