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
        &www_editPageSave &www_pastePage &www_moveTreePageUp &www_rearrangeWobjects
        &www_moveTreePageDown &www_moveTreePageLeft &www_moveTreePageRight);

#-------------------------------------------------------------------
=head2 _changeWobjectPrivileges ( page )

This private function changes the privileges of all wobjects on page.

=cut
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
=head2 _recursivelyChangeProperties ( page )

This private function set an entire subtree with $page as root to the same privilege and/or 
style settings. These properties are set to be a duplicate of those in page.

=over

=item page

This is the page whose ancestors should be changed. This must be an WebGUI::Page instance.

=back

=cut
# This combines _recusivelyChangePrivileges and _recusivelyChangeStyle, since there's no use in walking down a tree twice.
sub _recursivelyChangeProperties {
	my ($page, $currentPage);
	$page = shift;

	_changeWobjectPrivileges($page->get("pageId")) unless $session{form}{wobjectPrivileges};

	$page->walk_down({
		callback => sub {
			$currentPage = shift;
			if (WebGUI::Privilege::canEditPage($currentPage->get('pageId'))) {
				$currentPage->setWithoutRecache({
					startDate		=> WebGUI::FormProcessor::dateTime("startDate"),
					endDate			=> WebGUI::FormProcessor::dateTime("endDate"),
					ownerId			=> $session{form}{ownerId},
					groupIdView		=> $session{form}{groupIdView},
					groupIdEdit		=> $session{form}{groupIdEdit}
				}) if ($session{form}{recursePrivs});
				$currentPage->setWithoutRecache({
					styleId => $session{form}{styleId}
				}) if ($session{form}{recurseStyle});
			}
			return 1;
		}
	});
	
	WebGUI::Page->recachePageTree;
}

#-------------------------------------------------------------------
sub _selectPositions {
        my ($templates, $output, $f, $key);
        $f = WebGUI::HTMLForm->new(1);
        $templates = WebGUI::Page::getTemplateList();
	$f->template(
                -value=>$_[0],
		-namespace=>"page",
		-afterEdit=>'op=editPage&amp;npp='.$session{form}{npp},
                -extras=>'onChange="changeTemplatePreview(this.form.templateId.value)"'
                );
        $output = '
        <script language="JavaScript">
        function checkBrowserVersion(){
                this.ver=navigator.appVersion;
                this.dom=document.getElementById?1:0;
                this.ie5=(this.ver.indexOf("MSIE 5")>-1 && this.dom)?1:0;
                this.ie4=(document.all && !this.dom)?1:0;
                this.ns5=(this.dom && parseInt(this.ver) >= 5) ?1:0;
                this.ns4=(document.layers && !this.dom)?1:0;
                this.bw=(this.ie5 || this.ie4 || this.ns4 || this.ns5 || this.dom);
                return this;
        }
        pbw=new checkBrowserVersion();
        function makeChangeTextObj(obj){
                this.css=pbw.dom? document.getElementById(obj).style:pbw.ie4?document.all[obj].style:pbw.ns4?document.layers[obj]:0;
                this.writeref=pbw.dom? document.getElementById(obj):pbw.ie4?document.all[obj]:pbw.ns4?document.layers[obj].document:0
;
                this.writeIt=b_writeIt;
        }
        function b_writeIt(text){
                var obj;
                if(pbw.ns4) {
                if (document.loading) document.loading.visibility = "hidden";
                        this.writeref.write(text + "&nbsp;&nbsp;&nbsp;");
                        this.writeref.close();
                } else {
                        if (pbw.ie4) {
                        if (document.all.loading) obj = document.all.loading;
                }
                if (obj) obj.style.visibility = "hidden";
                        this.writeref.innerHTML=text;
                }
        }
        function init(){
                if(pbw.bw){
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
=head2 _traversePageTree( pageId [, initialDepth ] )

Walks down the page tree from page with id pageId and returns an indented list of the pages it
walks over. Also prints edit/delete/move buttons.

=item pageId

The id of the page you want to start from

=item initialDepth

The depth the tree should start with. Defaults to zero.

=over

=back

=cut
sub _traversePageTree {
        my ($top, $initialDepth, %wobject, $output, $spacer, $page, $currentPage, $options, $currentPageId, $currentUrlizedTitle, $wobjects);
	($top, $initialDepth) = @_;

	tie %wobject, 'Tie::CPHash';
        $spacer = '<img src="'.$session{config}{extrasURL}.'/spacer.gif" width=12>';
	
	$page = WebGUI::Page->getPage($top);
	$page->walk_down({
		callback => sub {
			($currentPage, $options) = @_;
			$currentPageId = $currentPage->get('pageId');
			$currentUrlizedTitle = $currentPage->get('urlizedTitle');
			if ($currentPageId < 2 || $currentPageId > 999) {
				$output .= $spacer x $options->{_depth}
					.pageIcon()
					.deleteIcon('op=deletePage',$currentUrlizedTitle)
                	                .moveLeftIcon(sprintf('op=moveTreePageLeft&pageId=%s',$currentPageId), $currentUrlizedTitle)
                        	        .moveUpIcon(sprintf('op=moveTreePageUp&pageId=%s',$currentPageId), $currentUrlizedTitle)
					.moveDownIcon(sprintf('op=moveTreePageDown&pageId=%s',$currentPageId), $currentUrlizedTitle)
					.moveRightIcon(sprintf('op=moveTreePageRight&pageId=%s',$currentPageId), $currentUrlizedTitle)
					.editIcon('op=editPage', $currentUrlizedTitle)
					.' <a href="'.WebGUI::URL::gateway($currentUrlizedTitle).'">'.$currentPage->get('title').'</a><br>';
				$wobjects = WebGUI::SQL->read("select * from wobject where pageId=$currentPageId");
				while (%wobject = $wobjects->hash) {
					$output .= $spacer x $options->{_depth} . $spacer
						.wobjectIcon()
						.deleteIcon('func=delete&wid='.$wobject{wobjectId},$currentUrlizedTitle)
						.editIcon('func=edit&wid='.$wobject{wobjectId},$currentUrlizedTitle)
						.' '. $wobject{title}.'<br>';
				}
				$wobjects->finish;
			}
		},
		_depth => $initialDepth || 0
	});
                
        return $output;
}

#-------------------------------------------------------------------
=head2 www_cutPage

This will cut the page defined by $session{page}{pageId} (ie. the current page) and all it's
children from the pagetree and place it on the clipboard.

=back

=cut
sub www_cutPage {
	my ($page);
        if ($session{page}{pageId} < 26 && $session{page}{pageId} >= 0) {
                return WebGUI::Privilege::vitalComponent();
		
        } elsif (WebGUI::Privilege::canEditPage()) {
		$page = WebGUI::Page->getPage($session{page}{pageId});
		$page->cut;
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
=head2 www_deletePage

This function returns an 'Are you sure' page for moving the page to the trash.

=back

=cut
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
=head2 www_deletePageConfirm

Actually transfers the page to the trash.

=back 

=cut
sub www_deletePageConfirm {
	if ($session{page}{pageId} < 1000 && $session{page}{pageId} > 0) {
		return WebGUI::Privilege::vitalComponent();
        } elsif (WebGUI::Privilege::canEditPage()) {
		my $page = WebGUI::Page->getPage($session{page}{pageId});
		$page->delete;
		WebGUI::Session::refreshPageInfo($session{page}{parentId});
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

use WebGUI::TabForm;
#-------------------------------------------------------------------
=head2 www_editPage

Displays the properties for a page.

=back

=cut
sub www_editPage {
        my ($f, $endDate, $output, $subtext, $childCount, %hash, %page);
	$session{page}{useAdminStyle} = 1;
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
                $f->getTab("properties")->text(
			-name=>"title",
			-label=>WebGUI::International::get(99),
			-value=>$page{title}
			);
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
		$f->getTab("properties")->selectList(
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
                $f->getTab("layout")->template(
			-name=>"styleId",
			-label=>WebGUI::International::get(912),
			-value=>($page{styleId} || 2),
			-namespace=>'style',
			-afterEdit=>'op=editPage&amp;npp='.$session{form}{npp},
			-uiLevel=>5
			);
                $f->getTab("layout")->template(
			-name=>"printableStyleId",
			-label=>WebGUI::International::get(1079),
			-value=>($page{printableStyleId} || 3),
			-namespace=>'style',
			-afterEdit=>'op=editPage&amp;npp='.$session{form}{npp},
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
			$subtext = manageIcon('op=listUsers');
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
		$f->getTab("privileges")->group(
			-name=>"groupIdView",
			-label=>WebGUI::International::get(872),
			-value=>[$page{groupIdView}],
			-uiLevel=>6
			);
                $f->getTab("privileges")->group(
                        -name=>"groupIdEdit",
                        -label=>WebGUI::International::get(871),
                        -value=>[$page{groupIdEdit}],
			-excludeGroups=>[1,7],
                        -uiLevel=>6
                        );
		$f->getTab("privileges")->yesNo(
			-name=>"wobjectPrivileges",
			-label=>WebGUI::International::get(1003),
			-value=>$page{wobjectPrivileges},
			-uiLevel=>9
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
=head2 www_editPageSave

Stores the data from www_editPage to the database and tree cache.

=back

=cut
sub www_editPageSave {
        my ($pageId, $currentPage, $page);
	
	if ($session{form}{pageId} eq "new") {
		$pageId = $session{form}{parentId};
	} else {
		$page = WebGUI::Page->getPage($session{form}{pageId});
		$pageId = $session{form}{pageId};
	}
	
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage($pageId));

	if ($session{form}{pageId} eq "new") {
		$currentPage = WebGUI::Page->getPage($pageId);
		$page = $currentPage->add;
	}

        $session{form}{title} = "no title" if ($session{form}{title} eq "");
        $session{form}{menuTitle} = $session{form}{title} if ($session{form}{menuTitle} eq "");
        $session{form}{urlizedTitle} = $session{form}{menuTitle} if ($session{form}{urlizedTitle} eq "");
	$session{form}{urlizedTitle} = WebGUI::Page::makeUnique(WebGUI::URL::urlize($session{form}{urlizedTitle}),$session{form}{pageId});
        $page->set({
		title			=> $session{form}{title}, 
		styleId			=> $session{form}{styleId}, 
		printableStyleId	=> $session{form}{printableStyleId}, 
		ownerId			=> $session{form}{ownerId}, 
		groupIdView		=> $session{form}{groupIdView}, 
		groupIdEdit		=> $session{form}{groupIdEdit}, 
		newWindow		=> $session{form}{newWindow},
		wobjectPrivileges	=> $session{form}{wobjectPrivileges},
		hideFromNavigation	=> $session{form}{hideFromNavigation},
		startDate		=> WebGUI::FormProcessor::dateTime("startDate"),
		endDate			=> WebGUI::FormProcessor::dateTime("endDate"),
		cacheTimeout		=> WebGUI::FormProcessor::interval("cacheTimeout"),
		cacheTimeoutVisitor	=> WebGUI::FormProcessor::interval("cacheTimeoutVisitor"),
		metaTags		=> $session{form}{metaTags},
		urlizedTitle		=> $session{form}{urlizedTitle}, 
		redirectURL		=> $session{form}{redirectURL}, 
		languageId		=> $session{form}{languageId}, 
		defaultMetaTags		=> $session{form}{defaultMetaTags}, 
		templateId		=> $session{form}{templateId}, 
		menuTitle		=> $session{form}{menuTitle}, 
		synopsis		=> $session{form}{synopsis}
		});
	unless ($session{form}{pageId} == 'new') {
		WebGUI::SQL->write("update wobject set templatePosition=1 where pageId=$session{form}{pageId} 
			and templatePosition>".WebGUI::Page::countTemplatePositions($session{form}{templateId}));
	}
	_recursivelyChangeProperties($page) if ($session{form}{recursePrivs} || $session{form}{recurseStyle});
	if ($session{form}{proceed} eq "gotoNewPage") {
		WebGUI::Session::refreshPageInfo($page->get('pageId'));
	} elsif ($session{form}{pageId} == $session{page}{pageId}) {
		WebGUI::Session::refreshPageInfo($session{page}{pageId});
	}
       	return "";
}

#-------------------------------------------------------------------
=head2 www_moqvePageDown

Moves page down in the context of it's sisters.

=back

=cut
sub www_movePageDown {
  if (WebGUI::Privilege::canEditPage($session{page}{pageId})) {
    WebGUI::Page->moveDown($session{page}{pageId});
    return "";
  } else {
    return WebGUI::Privilege::insufficient();
  }
}

#-------------------------------------------------------------------
=head2 www_movePageDown

Moves page up in the context of it's sisters.

=back

=cut
sub www_movePageUp {
  if (WebGUI::Privilege::canEditPage($session{page}{pageId})) {
    WebGUI::Page->moveUp($session{page}{pageId});
    return "";
  } else {
    return WebGUI::Privilege::insufficient();
  }
}

#-------------------------------------------------------------------
=head2 www_moveTreePageUp

Same as www_movePageUp wit this difference that this module returns the www_viewPageTree method.

=back

=cut
sub www_moveTreePageUp {
  if (WebGUI::Privilege::canEditPage($session{page}{pageId})) {
    WebGUI::Page->moveUp($session{page}{pageId});
    return www_viewPageTree();
  } else {
    return WebGUI::Privilege::insufficient();
  }
}

#-------------------------------------------------------------------
=head2 www_moveTreePageDown

Same as www_movePageDown with this difference that this module returns the www_viewPageTree method.

=back

=cut
sub www_moveTreePageDown {
  if (WebGUI::Privilege::canEditPage($session{page}{pageId})) {
    WebGUI::Page->moveDown($session{page}{pageId});
    return www_viewPageTree();
  } else {
    return WebGUI::Privilege::insufficient();
  }
}

#-------------------------------------------------------------------
=head2 www_moveTreePageLeft

Move the page one level left in the tree. In other words, the page is moved up one place in the hierarchy.
Another way to look at is that the mother of the current page becomes the elder sister of the current page.

=back

=cut
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
	my ($currentPage, $pageToPaste);
        if (WebGUI::Privilege::canEditPage()) {
		$currentPage = WebGUI::Page->getPage($session{page}{pageId});
		$pageToPaste = WebGUI::Page->getPage($session{form}{pageId});
		$pageToPaste->paste($currentPage);
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_rearrangeWobjects {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage($session{page}{pageId}));
	$session{page}{styleId} = 2;
	my @contentAreas = split(/\./,$session{form}{map});
	my $templatePosition = 1;
	foreach my $position (@contentAreas) {
		my @sequence = split(",",$position);
		my $sequenceNumber = 1;
		foreach my $wobjectId (@sequence) {
			$wobjectId =~ s/td(\d+)/$1/;
			WebGUI::SQL->setRow("wobject","wobjectId",{
				wobjectId=>$wobjectId,
				sequenceNumber=>$sequenceNumber,
				templatePosition=>$templatePosition
				});
			$sequenceNumber++;
		}
		$templatePosition++;
	}
	return $session{form}{map};
}


#-------------------------------------------------------------------
=head2 www_viewPageTree

Returns a HTML formatted indented pagetree complete with edit/delete/cut/move buttons

=back

=cut
sub www_viewPageTree {
	my ($output);
	$session{page}{useAdminStyle} = 1;
	$output = '<h1>'.WebGUI::International::get(448).'</h1>';
	$output .= _traversePageTree(0,0);
	return $output;
}

1;
