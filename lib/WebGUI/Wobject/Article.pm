package WebGUI::Wobject::Article;

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
our $namespace = "Article";
our $name = WebGUI::International::get(1,$namespace);


#-------------------------------------------------------------------
sub duplicate {
	my ($file, $w);
	$w = $_[0]->SUPER::duplicate($_[1]);
        $w = WebGUI::Wobject::Article->new({wobjectId=>$w,namespace=>$namespace});
	$file = WebGUI::Attachment->new($_[0]->get("image"),$_[0]->get("wobjectId"));
	$file->copy($w->get("wobjectId"));
        $file = WebGUI::Attachment->new($_[0]->get("attachment"),$_[0]->get("wobjectId"));
        $file->copy($w->get("wobjectId"));
	$w->set({
		image=>$_[0]->get("image"),
		linkTitle=>$_[0]->get("linkTitle"),
		linkURL=>$_[0]->get("linkURL"),
		attachment=>$_[0]->get("attachment"),
		convertCarriageReturns=>$_[0]->get("convertCarriageReturns"),
		alignImage=>$_[0]->get("alignImage"),
		allowDiscussion=>$_[0]->get("allowDiscussion")
		});
}

#-------------------------------------------------------------------
sub set {
        $_[0]->SUPER::set($_[1],[qw(image linkTitle linkURL attachment convertCarriageReturns alignImage allowDiscussion)]);
}

#-------------------------------------------------------------------
sub www_edit {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
        my ($output, $editTimeout, $groupToModerate, %hash, $f);
	tie %hash, 'Tie::IxHash';
	if ($_[0]->get("wobjectId") eq "new") {
                $editTimeout = 1;
        } else {
                $editTimeout = $_[0]->get("editTimeout");
        }
	$groupToModerate = $_[0]->get("groupToModerate") || 4;
        $output = helpIcon(1,$namespace);
	$output .= '<h1>'.WebGUI::International::get(12,$namespace).'</h1>';
	$f = WebGUI::HTMLForm->new;
	$f->raw(
		-value=>$_[0]->fileProperty("image",6),
		-uiLevel=>3
		);
        %hash = (
                right => WebGUI::International::get(15,$namespace),
                left => WebGUI::International::get(16,$namespace),
                center => WebGUI::International::get(17,$namespace)
                );
	$f->select(
		-name=>"alignImage",
		-options=>\%hash,
		-label=>WebGUI::International::get(14,$namespace),
		-value=>[$_[0]->get("alignImage")],
		-uiLevel=>3
		);
	$f->raw(
		-value=>$_[0]->fileProperty("attachment",9),
		-uiLevel=>1
		);
	$f->text(
		-name=>"linkTitle",
		-label=>WebGUI::International::get(7,$namespace),
		-value=>$_[0]->get("linkTitle"),
		-uiLevel=>3
		);
        $f->url(
		-name=>"linkURL",
		-label=>WebGUI::International::get(8,$namespace),
		-value=>$_[0]->get("linkURL"),
		-uiLevel=>3
		);
	$f->yesNo(
		-name=>"convertCarriageReturns",
		-label=>WebGUI::International::get(10,$namespace),
		-value=>$_[0]->get("convertCarriageReturns"),
		-subtext=>' &nbsp; <span style="font-size: 8pt;">'.WebGUI::International::get(11,$namespace).'</span>',
		-uiLevel=>5
		);
	$f->yesNo(
		-name=>"allowDiscussion",
		-label=>WebGUI::International::get(18,$namespace),
		-value=>$_[0]->get("allowDiscussion"),
		-uiLevel=>5
		);
	$f->raw($_[0]->SUPER::discussionProperties);
	$output .= $_[0]->SUPER::www_edit($f->printRowsOnly);
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
	$property{alignImage} = $session{form}{alignImage};
	$property{convertCarriageReturns} = $session{form}{convertCarriageReturns};
	$property{linkTitle} = $session{form}{linkTitle};
	$property{linkURL} = $session{form}{linkURL};
	$property{allowDiscussion} = $session{form}{allowDiscussion};
	$_[0]->SUPER::www_editSave(\%property);
        return "";
}

#-------------------------------------------------------------------
sub www_showMessage {
	return $_[0]->SUPER::www_showMessage('<a href="'.WebGUI::URL::page().'">'.WebGUI::International::get(27,$namespace).'</a><br>');
}

#-------------------------------------------------------------------
sub www_view {
	my ($file, $output, $image, $replies, $body);
	if ($_[0]->get("image") ne "") { # Images collide on successive articles if there is little text - prevent this.
		$output = '<table width="100%" border="0" cellpadding="0" cellspacing="0"><tr><td>';
	}
	$output .= $_[0]->displayTitle;
	if ($_[0]->get("image") ne "") {
		$image = WebGUI::Attachment->new($_[0]->get("image"),$_[0]->get("wobjectId"));
		$image = '<img src="'.$image->getURL.'"';
		if ($_[0]->get("alignImage") ne "center") {
			$image .= ' align="'.$_[0]->get("alignImage").'"';
		}
		$image .= ' border="0">';
		if ($_[0]->get("alignImage") eq "center") {
			$output .= '<div align="center">'.$image.'</div>';
		} else {
			$output .= $image;
		}
	}
        $body = $_[0]->description;
	if ($_[0]->get("convertCarriageReturns")) {
		$body =~ s/\n/\<br\>/g;
	}
	$output .= $body;
        if ($_[0]->get("linkURL") ne "" && $_[0]->get("linkTitle") ne "") {
        	$output .= '<p><a href="'.$_[0]->get("linkURL").'">'.$_[0]->get("linkTitle").'</a>';
        }
	if ($_[0]->get("attachment") ne "") {
		$file = WebGUI::Attachment->new($_[0]->get("attachment"),$_[0]->get("wobjectId"));
		$output .= $file->box;
	}
	if ($_[0]->get("image") ne "") {
		$output .= "</td></tr></table>";
	}
	$output = $_[0]->processMacros($output);
	if ($_[0]->get("allowDiscussion")) {
		($replies) = WebGUI::SQL->quickArray("select count(*) from discussion where wobjectId=".$_[0]->get("wobjectId"));
		$output .= '<p><table width="100%" cellspacing="2" cellpadding="1" border="0">';
		$output .= '<tr><td align="center" width="50%" class="tableMenu"><a href="'.
			WebGUI::URL::page('func=showMessage&wid='.$_[0]->get("wobjectId")).'">'.
			WebGUI::International::get(28,$namespace).' ('.$replies.')</a></td>';
		$output .= '<td align="center" width="50%" class="tableMenu"><a href="'.
                	WebGUI::URL::page('func=post&mid=new&wid='.$_[0]->get("wobjectId")).'">'.
                	WebGUI::International::get(24,$namespace).'</a></td></tr>';
		$output .= '</table>';
	}
	return $output;
}

1;

