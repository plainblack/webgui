package WebGUI::Wobject::Article;

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
use WebGUI::Attachment;
use WebGUI::DateTime;
use WebGUI::HTML;
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Paginator;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::Wobject;

our @ISA = qw(WebGUI::Wobject);


#-------------------------------------------------------------------
sub duplicate {
	my ($file, $w);
	$w = $_[0]->SUPER::duplicate($_[1]);
	$file = WebGUI::Attachment->new($_[0]->get("image"),$_[0]->get("wobjectId"));
	$file->copy($w);
        $file = WebGUI::Attachment->new($_[0]->get("attachment"),$_[0]->get("wobjectId"));
        $file->copy($w);
}

#-------------------------------------------------------------------
sub name {
	return WebGUI::International::get(1,$_[0]->get("namespace"));
}

#-------------------------------------------------------------------
sub new {
        my $class = shift;
        my $property = shift;
        my $self = WebGUI::Wobject->new(
		-properties=>$property,
		-extendedProperties=>{
			image=>{ },
                	templateId=>{
                        	defaultValue=>1
                        	},
                	linkTitle=>{ },
                	linkURL=>{ },
                	attachment=>{ },
                	convertCarriageReturns=>{
                        	defaultValue=>0
                        	}
			},
		-useDiscussion=>1
		);
        bless $self, $class;
}

#-------------------------------------------------------------------
sub www_edit {
	my $properties = WebGUI::HTMLForm->new;
	my $layout = WebGUI::HTMLForm->new;
	$layout->template(
                -name=>"templateId",
                -value=>$_[0]->getValue("templateId"),
                -namespace=>$_[0]->get("namespace"),
                -label=>WebGUI::International::get(356),
                -afterEdit=>'func=edit&wid='.$_[0]->get("wobjectId")
                );
	$properties->raw(
		-value=>$_[0]->fileProperty("image",6),
		-uiLevel=>3
		);
	$properties->raw(
		-value=>$_[0]->fileProperty("attachment",9),
		-uiLevel=>1
		);
	$properties->text(
		-name=>"linkTitle",
		-label=>WebGUI::International::get(7,$_[0]->get("namespace")),
		-value=>$_[0]->getValue("linkTitle"),
		-uiLevel=>3
		);
        $properties->url(
		-name=>"linkURL",
		-label=>WebGUI::International::get(8,$_[0]->get("namespace")),
		-value=>$_[0]->getValue("linkURL"),
		-uiLevel=>3
		);
	$layout->yesNo(
		-name=>"convertCarriageReturns",
		-label=>WebGUI::International::get(10,$_[0]->get("namespace")),
		-value=>$_[0]->getValue("convertCarriageReturns"),
		-subtext=>' &nbsp; <span style="font-size: 8pt;">'.WebGUI::International::get(11,$_[0]->get("namespace")).'</span>',
		-uiLevel=>5
		);
	return $_[0]->SUPER::www_edit(
		-properties=>$properties->printRowsOnly,
		-layout=>$layout->printRowsOnly,
		-headingId=>12,
		-helpId=>1
		);
}

#-------------------------------------------------------------------
sub www_editSave {
        my ($image, $attachment, %property);
	$_[0]->SUPER::www_editSave() if ($_[0]->get("wobjectId") eq "new");
        $image = WebGUI::Attachment->new("",$_[0]->get("wobjectId"));
	$image->save("image");
        $attachment = WebGUI::Attachment->new("",$_[0]->get("wobjectId"));
	$attachment->save("attachment");
	$property{image} = $image->getFilename if ($image->getFilename ne "");
	$property{attachment} = $attachment->getFilename if ($attachment->getFilename ne "");
	return $_[0]->SUPER::www_editSave(\%property);
}

#-------------------------------------------------------------------
sub www_showMessage {
	return $_[0]->SUPER::www_showMessage('<a href="'.WebGUI::URL::page().'">'.WebGUI::International::get(27,$_[0]->get("namespace")).'</a><br>');
}

#-------------------------------------------------------------------
sub www_view {
	my ($file, %var);
	if ($_[0]->get("image") ne "") {
		$file = WebGUI::Attachment->new($_[0]->get("image"),$_[0]->get("wobjectId"));
		$var{"image.url"} = $file->getURL;
		$var{"image.thumbnail"} = $file->getThumbnail;
	}
        $var{description} = $_[0]->get("description");
	if ($_[0]->get("convertCarriageReturns")) {
		$var{description} =~ s/\n/\<br\>/g;
	}
	if ($session{form}{makePrintable}) {
		$var{description} =~ s/\^\-\;//g;
		$var{isFirstPage} = 1;
		$var{isLastPage} = 1;
	} else {
		my @pages = split(/\^\-\;/,$var{description});
		my $p = WebGUI::Paginator->new(WebGUI::URL::page("wid=".$_[0]->get("wobjectId")."&func=view"),\@pages,1);
		$var{description} = $p->getPage;
		$var{firstPage} = $p->getFirstPageLink;
        	$var{lastPage} = $p->getLastPageLink;
        	$var{nextPage} = $p->getNextPageLink;
        	$var{pageList} = $p->getPageLinks;
        	$var{previousPage} = $p->getPreviousPageLink;
        	$var{multiplePages} = ($p->getNumberOfPages > 1);
		$var{isLastPage} = ($p->getNumberOfPages == $p->getPageNumber);
		$var{isFirstPage} = (1 == $p->getPageNumber);
	}
	if ($_[0]->get("attachment") ne "") {
		$file = WebGUI::Attachment->new($_[0]->get("attachment"),$_[0]->get("wobjectId"));
		$var{"attachment.box"} = $file->box;
		$var{"attachment.icon"} = $file->getIcon;
		$var{"attachment.url"} = $file->getURL;
		$var{"attachment.name"} = $file->getFilename;
	}
	if ($_[0]->get("allowDiscussion")) {
		($var{"replies.count"}) = WebGUI::SQL->quickArray("select count(*) from discussion 
			where wobjectId=".$_[0]->get("wobjectId"));
		$var{"replies.URL"} = WebGUI::URL::page('func=showMessage&wid='.$_[0]->get("wobjectId"));
		$var{"replies.label"} = WebGUI::International::get(28,$_[0]->get("namespace"));
        	$var{"post.URL"} = WebGUI::URL::page('func=post&mid=new&wid='.$_[0]->get("wobjectId"));
        	$var{"post.label"} = WebGUI::International::get(24,$_[0]->get("namespace"));
	}
	return $_[0]->processTemplate($_[0]->get("templateId"),\%var);
}


1;

