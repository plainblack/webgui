package WebGUI::Wobject::Article;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black Software.
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
use WebGUI::Discussion;
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
sub _canEditMessage {
        my (%message);
        tie %message, 'Tie::CPHash';
        %message = WebGUI::Discussion::getMessage($_[1]);
        if (
                (time()-$message{dateOfPost}) < 3600*$_[0]->get("editTimeout")
                && $message{userId} eq $session{user}{userId}
                || WebGUI::Privilege::isInGroup($_[0]->get("groupToModerate"))
                ) {
                return 1;
        } else {
                return 0;
        }
}

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
		allowDiscussion=>$_[0]->get("allowDiscussion"),
		groupToPost=>$_[0]->get("groupToPost"),
		groupToModerate=>$_[0]->get("groupToModerate"),
		editTimeout=>$_[0]->get("editTimeout")
		});
	WebGUI::Discussion::duplicate($_[0]->get("wobjectId"),$w->get("wobjectId"));
}

#-------------------------------------------------------------------
sub new {
        my ($self, $class, $property);
        $class = shift;
        $property = shift;
        $self = WebGUI::Wobject->new($property);
        bless $self, $class;
}

#-------------------------------------------------------------------
sub purge {
	WebGUI::Discussion::purge($_[0]->get("wobjectId"));
	$_[0]->SUPER::purge();
}

#-------------------------------------------------------------------
sub set {
        $_[0]->SUPER::set($_[1],
		[qw(image linkTitle linkURL attachment convertCarriageReturns alignImage allowDiscussion groupToPost groupToModerate editTimeout)]);
}

#-------------------------------------------------------------------
sub www_copy {
        if (WebGUI::Privilege::canEditPage()) {
                $_[0]->duplicate;
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteAttachment {
        if (WebGUI::Privilege::canEditPage()) {
		$_[0]->set({attachment=>''});
		return $_[0]->www_edit();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteImage {
        if (WebGUI::Privilege::canEditPage()) {
		$_[0]->set({image=>''});
                return $_[0]->www_edit();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteMessage {
	if (_canEditMessage($_[0],$session{form}{mid})) {
                return WebGUI::Discussion::deleteMessage();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteMessageConfirm {
	if (_canEditMessage($_[0],$session{form}{mid})) {
                return WebGUI::Discussion::deleteMessageConfirm();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_edit {
        my ($output, $editTimeout, $groupToModerate, %hash, $f);
	tie %hash, 'Tie::IxHash';
        if (WebGUI::Privilege::canEditPage()) {
		if ($_[0]->get("wobjectId") eq "new") {
                        $editTimeout = 1;
                } else {
                        $editTimeout = $_[0]->get("editTimeout");
                }
		$groupToModerate = $_[0]->get("groupToModerate") || 4;
                $output = helpIcon(1,$namespace);
		$output .= '<h1>'.WebGUI::International::get(12,$namespace).'</h1>';
		$f = WebGUI::HTMLForm->new;
		if ($_[0]->get("image") ne "") {
			$f->readOnly('<a href="'.WebGUI::URL::page('func=deleteImage&wid='.$session{form}{wid}).'">'.
				WebGUI::International::get(391).'</a>',WebGUI::International::get(6,$namespace));
		} else {
			$f->file("image",WebGUI::International::get(6,$namespace));
		}
                %hash = (
                        right => WebGUI::International::get(15,$namespace),
                        left => WebGUI::International::get(16,$namespace),
                        center => WebGUI::International::get(17,$namespace)
                        );
		$f->select("alignImage",\%hash,WebGUI::International::get(14,$namespace),[$_[0]->get("alignImage")]);
		if ($_[0]->get("attachment") ne "") {
			$f->readOnly('<a href="'.WebGUI::URL::page('func=deleteAttachment&wid='.$session{form}{wid}).'">'.
				WebGUI::International::get(391).'</a>',WebGUI::International::get(9,$namespace));
		} else {
			$f->file("attachment",WebGUI::International::get(9,$namespace));
		}
		$f->text("linkTitle",WebGUI::International::get(7,$namespace),$_[0]->get("linkTitle"));
                $f->url("linkURL",WebGUI::International::get(8,$namespace),$_[0]->get("linkURL"));
		$f->yesNo("convertCarriageReturns",WebGUI::International::get(10,$namespace),$_[0]->get("convertCarriageReturns")
			,'',' &nbsp; <span style="font-size: 8pt;">'.WebGUI::International::get(11,$namespace).'</span>');
		$f->yesNo("allowDiscussion",WebGUI::International::get(18,$namespace),$_[0]->get("allowDiscussion"));
		$f->group("groupToPost",WebGUI::International::get(19,$namespace),[$_[0]->get("groupToPost")]);
		$f->group("groupToModerate",WebGUI::International::get(20,$namespace),[$groupToModerate]);
		$f->integer("editTimeout",WebGUI::International::get(21,$namespace),$editTimeout);
		$output .= $_[0]->SUPER::www_edit($f->printRowsOnly);
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editSave {
        my ($image, $attachment, %property);
        if (WebGUI::Privilege::canEditPage()) {
		$_[0]->SUPER::www_editSave();
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
		$property{groupToModerate} = $session{form}{groupToModerate};
		$property{groupToPost} = $session{form}{groupToPost};
		$property{editTimeout} = $session{form}{editTimeout};
		$_[0]->set(\%property);
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_post {
        if (WebGUI::Privilege::isInGroup($_[0]->get("groupToPost"),$session{user}{userId})) {
                return WebGUI::Discussion::post();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_postSave {
        if (WebGUI::Privilege::isInGroup($_[0]->get("groupToPost"),$session{user}{userId})) {
                WebGUI::Discussion::postSave();
                return $_[0]->www_showMessage();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_showMessage {
        my ($submenu, $output, $defaultMid);
        ($defaultMid) = WebGUI::SQL->quickArray("select min(messageId) from discussion where wobjectId=$session{form}{wid}");
	$session{form}{mid} = $defaultMid if ($session{form}{mid} eq "");
        $submenu = '<a href="'.WebGUI::URL::page('func=post&replyTo='.$session{form}{mid}.'&wid='.$session{form}{wid})
        	.'">'.WebGUI::International::get(24,$namespace).'</a><br>';
	if (_canEditMessage($_[0],$session{form}{mid})) {
        	$submenu .= '<a href="'.WebGUI::URL::page('func=post&mid='.$session{form}{mid}.
                	'&wid='.$session{form}{wid}).'">'.WebGUI::International::get(25,$namespace).'</a><br>';
                $submenu .= '<a href="'.WebGUI::URL::page('func=deleteMessage&mid='.$session{form}{mid}.
			'&wid='.$session{form}{wid}).'">'.WebGUI::International::get(26,$namespace).'</a><br>';
        }
        $submenu .= '<a href="'.WebGUI::URL::page().'">'.WebGUI::International::get(27,$namespace).'</a><br>';
	$output = WebGUI::Discussion::showMessage($submenu);
	$output .= WebGUI::Discussion::showThreads();
        return $output;
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

