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
        $w = WebGUI::Wobject::Article->new({wobjectId=>$w,namespace=>$_[0]->get("namespace")});
	$file = WebGUI::Attachment->new($_[0]->get("image"),$_[0]->get("wobjectId"));
	$file->copy($w->get("wobjectId"));
        $file = WebGUI::Attachment->new($_[0]->get("attachment"),$_[0]->get("wobjectId"));
        $file->copy($w->get("wobjectId"));
	$w->set({
		templateId=>$_[0]->get("templateId"),
		image=>$_[0]->get("image"),
		linkTitle=>$_[0]->get("linkTitle"),
		linkURL=>$_[0]->get("linkURL"),
		attachment=>$_[0]->get("attachment"),
		convertCarriageReturns=>$_[0]->get("convertCarriageReturns")
		});
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
		$property,
		[qw(image templateId linkTitle linkURL attachment convertCarriageReturns)],
		1
		);
        bless $self, $class;
}

#-------------------------------------------------------------------
sub www_edit {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
        my ($output, $editTimeout, $groupToModerate, $template);
	if ($_[0]->get("wobjectId") eq "new") {
                $editTimeout = 1;
        } else {
                $editTimeout = $_[0]->get("editTimeout");
        }
	$template = $_[0]->get("templateId") || 1;
	$groupToModerate = $_[0]->get("groupToModerate") || 4;
        $output = helpIcon(1,$_[0]->get("namespace"));
	$output .= '<h1>'.WebGUI::International::get(12,$_[0]->get("namespace")).'</h1>';
	my $properties = WebGUI::HTMLForm->new;
	my $layout = WebGUI::HTMLForm->new;
	$layout->template(
                -name=>"templateId",
                -value=>$template,
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
		-value=>$_[0]->get("linkTitle"),
		-uiLevel=>3
		);
        $properties->url(
		-name=>"linkURL",
		-label=>WebGUI::International::get(8,$_[0]->get("namespace")),
		-value=>$_[0]->get("linkURL"),
		-uiLevel=>3
		);
	$layout->yesNo(
		-name=>"convertCarriageReturns",
		-label=>WebGUI::International::get(10,$_[0]->get("namespace")),
		-value=>$_[0]->get("convertCarriageReturns"),
		-subtext=>' &nbsp; <span style="font-size: 8pt;">'.WebGUI::International::get(11,$_[0]->get("namespace")).'</span>',
		-uiLevel=>5
		);
	$output .= $_[0]->SUPER::www_edit(
		-properties=>$properties->printRowsOnly,
		-layout=>$layout->printRowsOnly
		);
        return $output;
}

#-------------------------------------------------------------------
sub www_editSave {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
        my ($image, $attachment, %property);
	$_[0]->SUPER::www_editSave() if ($_[0]->get("wobjectId") eq "new");
        $image = WebGUI::Attachment->new("",$_[0]->get("wobjectId"));
	$image->save("image");
        $attachment = WebGUI::Attachment->new("",$_[0]->get("wobjectId"));
	$attachment->save("attachment");
	$property{image} = $image->getFilename if ($image->getFilename ne "");
	$property{attachment} = $attachment->getFilename if ($attachment->getFilename ne "");
	$property{convertCarriageReturns} = $session{form}{convertCarriageReturns};
	$property{linkTitle} = $session{form}{linkTitle};
	$property{templateId} = $session{form}{templateId};
	$property{linkURL} = $session{form}{linkURL};
	$_[0]->SUPER::www_editSave(\%property);
       	return "";
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
        $var{description} = $_[0]->description;
	if ($_[0]->get("convertCarriageReturns")) {
		$var{description} =~ s/\n/\<br\>/g;
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

