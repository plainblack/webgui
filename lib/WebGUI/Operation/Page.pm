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
use WebGUI::FormProcessor;
use WebGUI::Grouping;
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Page;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::TabForm;
use WebGUI::URL;
use WebGUI::Utility;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_viewPageTree &www_movePageUp &www_movePageDown 
        &www_cutPage &www_deletePage &www_deletePageConfirm &www_editPage 
        &www_editPageSave &www_pastePage &www_moveTreePageUp 
        &www_moveTreePageDown &www_moveTreePageLeft &www_moveTreePageRight);

#-------------------------------------------------------------------
sub _changeWobjectPrivileges {
   my($wobject,$sth);
   $sth = WebGUI::SQL->read("select wobjectId from wobject where pageId=".quote($_[0]));
   while ($wobject = $sth->hashRef) {
      if (WebGUI::Privilege::canEditWobject($wobject->{wobjectId})) {
         WebGUI::SQL->write("update wobject set startDate=".WebGUI::FormProcessor::dateTime("startDate").", 
		                     endDate=".WebGUI::FormProcessor::dateTime("endDate").", 
							 ownerId=$session{form}{ownerId}, groupIdView=$session{form}{groupIdView}, 
							 groupIdEdit=$session{form}{groupIdEdit} where wobjectId=".quote($wobject->{wobjectId}));
	  }
    }
}			
		
#-------------------------------------------------------------------
sub _recursivelyChangePrivileges {
        my ($sth, $pageId);
        $sth = WebGUI::SQL->read("select pageId from page where parentId=$_[0]");
	    _changeWobjectPrivileges($_[0]) unless $session{form}{wobjectPrivileges};
        while (($pageId) = $sth->array) {
		if (WebGUI::Privilege::canEditPage($pageId)) {
        		WebGUI::SQL->write("update page set startDate=".WebGUI::FormProcessor::dateTime("startDate").", 
				endDate=".WebGUI::FormProcessor::dateTime("endDate").",
				ownerId=$session{form}{ownerId},  groupIdView=$session{form}{groupIdView}, 
				groupIdEdit=$session{form}{groupIdEdit} where pageId=$pageId");
                	_recursivelyChangePrivileges($pageId);
		}
        }
	$sth->finish;
}

#-------------------------------------------------------------------
sub _recursivelyChangeStyle {
	my ($sth, $pageId);
	$sth = WebGUI::SQL->read("select pageId from page where parentId=$_[0]");	
	while (($pageId) = $sth->array) {
		if (WebGUI::Privilege::canEditPage($pageId)) {
			WebGUI::SQL->write("update page set styleId=$session{form}{styleId} where pageId=$pageId");
			_recursivelyChangeStyle($pageId);
		}
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
        $a = WebGUI::SQL->read("select pageId,urlizedTitle,title from page where (pageId<2 or pageId>999) and parentId='$_[0]' order by sequenceNumber");
        while (%page = $a->hash) {
		if (WebGUI::Privilege::canEditPage($page{pageId})) {
                	$output .= $depth
				.pageIcon()
				.deleteIcon('op=deletePage',$page{urlizedTitle})
                                .moveLeftIcon(sprintf('op=moveTreePageLeft&pageId=%s',$page{pageId}),$page{urlizedTitle})
                                .moveUpIcon(sprintf('op=moveTreePageUp&pageId=%s',$page{pageId}),$page{urlizedTitle})
                                .moveDownIcon(sprintf('op=moveTreePageDown&pageId=%s',$page{pageId}),$page{urlizedTitle})
                                .moveRightIcon(sprintf('op=moveTreePageRight&pageId=%s',$page{pageId}),$page{urlizedTitle})
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
        if ($session{page}{pageId} < 26 && $session{page}{pageId} >= 0) {
                return WebGUI::Privilege::vitalComponent();
        } elsif (WebGUI::Privilege::canEditPage()) {
                WebGUI::SQL->write("update page set parentId=2, "
                        ."bufferUserId=".$session{user}{userId}.", "
                        ."bufferDate=".time().", "
                        ."bufferPrevId=".$session{page}{parentId}." "
                        ."where pageId=".$session{page}{pageId});
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
                WebGUI::SQL->write("update page set parentId=3, "
                        ."bufferUserId=".$session{user}{userId}.", "
                        ."bufferDate=".time().", "
                        ."bufferPrevId=".$session{page}{parentId}." "
                        ."where pageId=".$session{page}{pageId});
		_reorderPages($session{page}{parentId});
		WebGUI::Session::refreshPageInfo($session{page}{parentId});
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}
use WebGUI::TabForm;
#-------------------------------------------------------------------
sub www_editPage {
        my ($f, $endDate, $output, $subtext, $childCount, %hash, %page);
	tie %hash, "Tie::IxHash";
	tie %page, "Tie::CPHash";
        if (WebGUI::Privilege::canEditPage($session{form}{npp})) {
	        my %tabs;
        	tie %tabs, 'Tie::IxHash';
	        %tabs = (
        	        properties=>{
                	        label=>WebGUI::International::get(103)
	                        },
        	        layout=>{
                	        label=>WebGUI::International::get(105),
	                        uiLevel=>5
        	                },
                	privileges=>{
                        	label=>WebGUI::International::get(107),
	                        uiLevel=>6
        	                }
                	);
		$f = WebGUI::TabForm->new(\%tabs);
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
		$f->hidden({name=>"pageId",value=>$page{pageId}});
		$f->hidden({name=>"parentId",value=>$page{parentId}});
		$f->hidden({name=>"op",value=>"editPageSave"});
		$f->getTab("properties")->readOnly(
			-value=>$page{pageId},
			-label=>WebGUI::International::get(500),
			-uiLevel=>3
			);
                $f->getTab("properties")->text("title",WebGUI::International::get(99),$page{title});
		$f->getTab("properties")->text(
			-name=>"menuTitle",
			-label=>WebGUI::International::get(411),
			-value=>$page{menuTitle},
			-uiLevel=>1
			);
		$f->getTab("properties")->yesNo(
			-name=>"hideFromNavigation",
			-value=>$page{hideFromNavigation},
			-label=>WebGUI::International::get(886),
			-uiLevel=>6
			);
		$f->getTab("properties")->yesNo(
			-name=>"newWindow",
			-value=>$page{newWindow},
			-label=>WebGUI::International::get(940),
			-uiLevel=>6
			);
                $f->getTab("properties")->text(
			-name=>"urlizedTitle",
			-label=>WebGUI::International::get(104),
			-value=>$page{urlizedTitle},
			-uiLevel=>3
			);
		$f->getTab("properties")->select(
			-name=>"languageId",
			-label=>WebGUI::International::get(304),
			-value=>[$page{languageId}],
			-uiLevel=>1,
			-options=>WebGUI::International::getLanguages()
			);
                $f->getTab("properties")->url(
			-name=>"redirectURL",
			-label=>WebGUI::International::get(715),
			-value=>$page{redirectURL},
			-uiLevel=>9
			);
		$f->getTab("properties")->textarea(
			-name=>"synopsis",
			-label=>WebGUI::International::get(412),
			-value=>$page{synopsis},
			-uiLevel=>3
			);
		$f->getTab("properties")->textarea(
			-name=>"metaTags",
			-label=>WebGUI::International::get(100),
			-value=>$page{metaTags},
			-uiLevel=>7
			);
                $f->getTab("properties")->yesNo(
			-name=>"defaultMetaTags",
			-label=>WebGUI::International::get(307),
			-value=>$page{defaultMetaTags},
			-uiLevel=>5
			);
		my @data = WebGUI::DateTime::secondsToInterval($page{cacheTimeout});
	        $f->getTab("properties")->interval(
        	        -name=>"cacheTimeout",
                	-label=>WebGUI::International::get(895),
	                -intervalValue=>$data[0],
        	        -unitsValue=>$data[1],
			-uiLevel=>8
                	);
	        @data = WebGUI::DateTime::secondsToInterval($page{cacheTimeoutVisitor});
        	$f->getTab("properties")->interval(
                	-name=>"cacheTimeoutVisitor",
	                -label=>WebGUI::International::get(896),
        	        -intervalValue=>$data[0],
                	-unitsValue=>$data[1],
			-uiLevel=>8
                	);
		%hash = WebGUI::SQL->buildHash("select styleId,name from style where name<>'Reserved' order by name");
		if (WebGUI::Privilege::isInGroup(5)) {
			$subtext = ' &nbsp; <a href="'.WebGUI::URL::page('op=listStyles')
				.'">'.WebGUI::International::get(6).'</a>';
		} else {
			$subtext = "";
		}
                $f->getTab("layout")->select(
			-name=>"styleId",
			-options=>\%hash,
			-label=>WebGUI::International::get(105),
			-value=>[$page{styleId}],
			-subtext=>$subtext,
			-uiLevel=>5
			);
		if ($childCount) {
                	$f->getTab("layout")->yesNo(
				-name=>"recurseStyle",
				-subtext=>' &nbsp; '.WebGUI::International::get(106),
				-uiLevel=>9
				);
		}
                $f->getTab("layout")->readOnly(
                        -value=>_selectPositions($page{templateId}),
                        -label=>WebGUI::International::get(356),
                        -uiLevel=>5
                        );
        	$f->getTab("privileges")->dateTime(
			-name=>"startDate",
			-label=>WebGUI::International::get(497),
			-value=>$page{startDate},
			-uiLevel=>6
			);
        	$f->getTab("privileges")->dateTime(
			-name=>"endDate",
			-label=>WebGUI::International::get(498),
			-value=>$page{endDate},
			-uiLevel=>6
			);
		if (WebGUI::Privilege::isInGroup(3)) {
			$subtext = ' &nbsp; <a href="'.WebGUI::URL::page('op=listUsers').'">'
				.WebGUI::International::get(7).'</a>';
		} else {
			$subtext = "";
		}
		my $clause; 
		if (WebGUI::Privilege::isInGroup(3)) {
			my $contentManagers = WebGUI::Grouping::getUsersInGroup(4,1);
			push (@$contentManagers, $session{user}{userId});
			$clause = "userId in (".join(",",@$contentManagers).")";
		} else {
			$clause = "userId=$page{ownerId}";
                }
		my $users = WebGUI::SQL->buildHashRef("select userId,username from users where $clause order by username");
		$f->getTab("privileges")->select(
			-name=>"ownerId",
			-options=>$users,
			-label=>WebGUI::International::get(108),
			-value=>[$page{ownerId}],
			-subtext=>$subtext,
			-uiLevel=>6
			);
		if (WebGUI::Privilege::isInGroup(3)) {
			$subtext = ' &nbsp; <a href="'.WebGUI::URL::page('op=listGroups').'">'
				.WebGUI::International::get(5).'</a>';
		} else {
			$subtext = "";
		}
		$f->getTab("privileges")->group(
			-name=>"groupIdView",
			-label=>WebGUI::International::get(872),
			-value=>[$page{groupIdView}],
			-subtext=>$subtext,
			-uiLevel=>6
			);
                $f->getTab("privileges")->group(
                        -name=>"groupIdEdit",
                        -label=>WebGUI::International::get(871),
                        -value=>[$page{groupIdEdit}],
                        -subtext=>$subtext,
			-excludeGroups=>[1,7],
                        -uiLevel=>6
                        );
		if ($childCount) {
                	$f->getTab("privileges")->yesNo(
				-name=>"recursePrivs",
				-subtext=>' &nbsp; '.WebGUI::International::get(116),
				-uiLevel=>9
				);
		}
		if ($page{pageId} eq "new") {
                	$f->getTab("properties")->whatNext(
                        	-options=>{
                                	gotoNewPage=>WebGUI::International::get(823),
                               	 	backToPage=>WebGUI::International::get(847)
                                	},
                        	-value=>"gotoNewPage",
				-uiLevel=>1
                        	);
        	}
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
        WebGUI::SQL->write("update page set 
		title=".quote($session{form}{title}).", 
		styleId=$session{form}{styleId}, 
		ownerId=$session{form}{ownerId}, 
		groupIdView=$session{form}{groupIdView}, 
		groupIdEdit=$session{form}{groupIdEdit}, 
		newWindow=$session{form}{newWindow},
		hideFromNavigation=$session{form}{hideFromNavigation},
		startDate=".WebGUI::FormProcessor::dateTime("startDate").",
		endDate=".WebGUI::FormProcessor::dateTime("endDate").",
		cacheTimeout=".WebGUI::FormProcessor::interval("cacheTimeout").",
		cacheTimeoutVisitor=".WebGUI::FormProcessor::interval("cacheTimeoutVisitor").",
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
  if (WebGUI::Privilege::canEditPage($session{page}{pageId})) {
    WebGUI::Page->moveDown($session{page}{pageId});
    return "";
  } else {
    return WebGUI::Privilege::insufficient();
  }
}

#-------------------------------------------------------------------
sub www_movePageUp {
  if (WebGUI::Privilege::canEditPage($session{page}{pageId})) {
    WebGUI::Page->moveUp($session{page}{pageId});
    return "";
  } else {
    return WebGUI::Privilege::insufficient();
  }
}

#-------------------------------------------------------------------
sub www_moveTreePageUp {
  if (WebGUI::Privilege::canEditPage($session{page}{pageId})) {
    WebGUI::Page->moveUp($session{page}{pageId});
    return www_viewPageTree();
  } else {
    return WebGUI::Privilege::insufficient();
  }
}

#-------------------------------------------------------------------
sub www_moveTreePageDown {
  if (WebGUI::Privilege::canEditPage($session{page}{pageId})) {
    WebGUI::Page->moveDown($session{page}{pageId});
    return www_viewPageTree();
  } else {
    return WebGUI::Privilege::insufficient();
  }
}

#-------------------------------------------------------------------
sub www_moveTreePageLeft {
  if (WebGUI::Privilege::canEditPage($session{page}{pageId})) {
    WebGUI::Page->moveLeft($session{page}{pageId});
    return www_viewPageTree();
  } else {
    return WebGUI::Privilege::insufficient();
  }
}

#-------------------------------------------------------------------
sub www_moveTreePageRight {
  if (WebGUI::Privilege::canEditPage($session{page}{pageId})) {
    WebGUI::Page->moveRight($session{page}{pageId});
    return www_viewPageTree();
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
		WebGUI::SQL->write("update page set parentId=$session{page}{pageId}, sequenceNumber='$nextSeq', "
				  ."bufferUserId=NULL, bufferDate=NULL, bufferPrevId=NULL "
				  ."where pageId=$session{form}{pageId}");
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

