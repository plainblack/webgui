package WebGUI::Wobject::SiteMap;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2003 Plain Black LLC.
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

#-------------------------------------------------------------------
sub _traversePageTree {
        my ($parent, $sth, $data, $indent, @pages, $i, $currentDepth, $depth, $indentString, $alphabetic, $orderBy);
	$parent = $_[0];
	$currentDepth = $_[1];
	$depth = $_[2] || 99;
	$indent = $_[3];
        $alphabetic = $_[4];
        for ($i=1;$i<=($indent*$currentDepth);$i++) {
                $indentString .= "&nbsp;";
        }
        if ($currentDepth < $depth) {
                if ($alphabetic) {
                        $orderBy = 'title';
                } else {
                        $orderBy = 'sequenceNumber';
                }
                $sth = WebGUI::SQL->read("select urlizedTitle, menuTitle, title, pageId, synopsis from page where parentId='$parent' and hideFromNavigation = 0 order by $orderBy");
                while ($data = $sth->hashRef) {
                        if (($data->{pageId}<0 || $data->{pageId}>999 || $data->{pageId}==1) && WebGUI::Privilege::canViewPage($data->{pageId})) {
				push(@pages,{ 
                                	"page.indent" => $indentString,
					"page.url" => WebGUI::URL::gateway($data->{urlizedTitle}),
					"page.id" => $data->{pageId},
					"page.title" => $data->{title},
					"page.menuTitle" => $data->{menuTitle},
					"page.synopsis" => $data->{synopsis},
					"page.isRoot" => ($parent == 0),
					"page.isTop" => ($currentDepth == 0 || ($currentDepth == 1 && $parent == 0))
					});
                                push(@pages,@{_traversePageTree($data->{pageId},($currentDepth+1),$depth,$indent,$alphabetic)});
                        }
                }
                $sth->finish;
        }
        return \@pages;
}


#-------------------------------------------------------------------
sub name {
        return WebGUI::International::get(2,$_[0]->get("namespace"));
}

#-------------------------------------------------------------------
sub new {
        my $class = shift;
        my $property = shift;
        my $self = WebGUI::Wobject->new(
                -properties=>$property,
                -extendedProperties=>{
			startAtThisLevel=>{
				defaultValue=>1
				},
 			indent=>{
				defaultValue=>5
				}, 
			depth=>{
				defaultValue=>0
                                },
                        alphabetic=>{
                                defaultValue=>0
                                }
			},
		-useTemplate=>1
                );
        bless $self, $class;
}


#-------------------------------------------------------------------
sub www_edit {
	my $options = WebGUI::SQL->buildHashRef("select pageId,title from page where parentId=0 
		and (pageId=1 or pageId>999) order by title");
        my $layout = WebGUI::HTMLForm->new;
        my $properties = WebGUI::HTMLForm->new;
        $properties->select(
		-name=>"startAtThisLevel",
		-label=>WebGUI::International::get(3,$_[0]->get("namespace")),
		-value=>[$_[0]->getValue("startAtThisLevel")],
		-options=>{
               	 	0=>WebGUI::International::get(75,$_[0]->get("namespace")),
                	$session{page}{pageId}=>WebGUI::International::get(74,$_[0]->get("namespace")),
                	%{$options}
                	}
		);
        $layout->integer(
		-name=>"depth",
		-label=>WebGUI::International::get(4,$_[0]->get("namespace")),
		-value=>$_[0]->getValue("depth")
		);
	$layout->integer(
		-name=>"indent",
		-label=>WebGUI::International::get(6,$_[0]->get("namespace")),
		-value=>$_[0]->getValue("indent")
		);
	$layout->yesNo(
		-name=>"alphabetic",
		-label=>WebGUI::International::get(7,$_[0]->get("namespace")),
		-value=>$_[0]->getValue("alphabetic")
		);
	return $_[0]->SUPER::www_edit(
		-properties=>$properties->printRowsOnly,
		-layout=>$layout->printRowsOnly,
		-headingId=>5,
		-helpId=>1
		);
}


#-------------------------------------------------------------------
sub www_view {
        my (%var);
	$var{page_loop} = _traversePageTree($_[0]->get("startAtThisLevel"),0,$_[0]->get("depth"),$_[0]->get("indent"),$_[0]->get("alphabetic"));
	return $_[0]->processTemplate($_[0]->get("templateId"),\%var);
}

1;

