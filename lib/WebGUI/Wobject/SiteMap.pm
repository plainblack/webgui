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
        my ($parent, $sth, $data, $indent, @pages, $i, $currentDepth, $depth, $indentString);
	$parent = $_[0];
	$currentDepth = $_[1];
	$depth = $_[2] || 99;
	$indent = $_[3];
        for ($i=1;$i<=($indent*$currentDepth);$i++) {
                $indentString .= "&nbsp;";
        }
        if ($currentDepth < $depth) {
                $sth = WebGUI::SQL->read("select urlizedTitle, title, pageId, synopsis from page 
			where parentId='$parent' order by sequenceNumber");
                while ($data = $sth->hashRef) {
                        if (($data->{pageId}>999 || $data->{pageId}==1) && WebGUI::Privilege::canViewPage($data->{pageId})) {
				push(@pages,{ 
                                	"page.indent" => $indentString,
					"page.url" => WebGUI::URL::gateway($data->{urlizedTitle}),
					"page.id" => $data->{pageId},
					"page.title" => $data->{title},
					"page.menuTitle" => $data->{menuTitle},
					"page.synopsis" => $data->{synopsis},
					"page.isRoot" => ($parent == 0)
					});
                                push(@pages,@{_traversePageTree($data->{pageId},($currentDepth+1),$depth,$indent)});
                        }
                }
                $sth->finish;
        }
        return \@pages;
}

#-------------------------------------------------------------------
sub duplicate {
        my ($w, $f);
        $w = $_[0]->SUPER::duplicate($_[1]);
        $w = WebGUI::Wobject::SiteMap->new({wobjectId=>$w,namespace=>$namespace});
        $w->set({
                startAtThisLevel=>$_[0]->get("startAtThisLevel"),
                templateId=>$_[0]->get("templateId"),
                indent=>$_[0]->get("indent"),
                depth=>$_[0]->get("depth")
                });
}

#-------------------------------------------------------------------
sub set {
        $_[0]->SUPER::set($_[1],[qw(startAtThisLevel indent templateId depth)]);
}

#-------------------------------------------------------------------
sub www_edit {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
        my ($output, $f, $indent, $startLevel);
	if ($_[0]->get("wobjectId") eq "new") {
		$startLevel = 1;
	} else {
		$startLevel = $_[0]->get("startAtThisLevel");
	}
	my $options = WebGUI::SQL->buildHashRef("select pageId,title from page where parentId=0 
		and (pageId=1 or pageId>999) order by title");
	$indent = $_[0]->get("indent") || 5;
        $output = helpIcon(1,$_[0]->get("namespace"));
        $output .= '<h1>'.WebGUI::International::get(5,$namespace).'</h1>';
        $f = WebGUI::HTMLForm->new;
	$f->template(
                -name=>"templateId",
                -value=>$_[0]->get("templateId"),
                -namespace=>$namespace,
                -afterEdit=>'func=edit&wid='.$_[0]->get("wobjectId")
                );
        $f->select(
		-name=>"startAtThisLevel",
		-label=>WebGUI::International::get(3,$namespace),
		-value=>[$startLevel],
		-options=>{
               	 	0=>WebGUI::International::get(75,$namespace),
                	$session{page}{pageId}=>WebGUI::International::get(74,$namespace),
                	%{$options}
                	}
		);
        $f->integer("depth",WebGUI::International::get(4,$namespace),$_[0]->get("depth"));
	$f->integer("indent",WebGUI::International::get(6,$namespace),$indent);
	$output .= $_[0]->SUPER::www_edit($f->printRowsOnly);
        return $output;
}

#-------------------------------------------------------------------
sub www_editSave {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
	$_[0]->SUPER::www_editSave({
		indent=>$session{form}{indent},
		startAtThisLevel=>$session{form}{startAtThisLevel},
		depth=>$session{form}{depth},
		templateId=>$session{form}{templateId}
		});
        return "";
}

#-------------------------------------------------------------------
sub www_view {
        my (%var);
	$var{page_loop} = _traversePageTree($_[0]->get("startAtThisLevel"),0,$_[0]->get("depth"),$_[0]->get("indent"));
	return $_[0]->processMacros($_[0]->processTemplate($_[0]->get("templateId"),\%var));
}

1;

