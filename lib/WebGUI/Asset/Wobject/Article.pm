package WebGUI::Asset::Wobject::Article;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2004 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Tie::CPHash;
use WebGUI::DateTime;
use WebGUI::Forum;
use WebGUI::Forum::UI;
use WebGUI::HTML;
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Paginator;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::URL;
use WebGUI::Wobject;

our @ISA = qw(WebGUI::Asset::Wobject);


#-------------------------------------------------------------------
sub definition {
	my $class = shift;
	my $definition = shift;
	push(@{$definition}, {
		tableName=>'Article',
		className=>'WebGUI::Asset::Wobject::Article',
		properties=>{
				linkURL=>{
					fieldType=>'url',
					defaultValue=>undef
					},
				linkTitle=>{
					fieldType=>'text',
					defaultValue=>undef
					},
				convertCarriageReturns=>{
					fieldType=>'yesNo',
					defaultValue=>0
					}
			}
		});
        return $class->SUPER::definition($definition);
}



#-------------------------------------------------------------------
sub getEditForm {
	my $self = shift;
	my $tabform = $self->SUPER::getEditForm();
	$tabform->getTab("properties")->text(
		-name=>"linkTitle",
		-label=>WebGUI::International::get(7,$self->get("namespace")),
		-value=>$self->getValue("linkTitle"),
		-uiLevel=>3
		);
        $tabform->getTab("properties")->url(
		-name=>"linkURL",
		-label=>WebGUI::International::get(8,$self->get("namespace")),
		-value=>$self->getValue("linkURL"),
		-uiLevel=>3
		);
	$tabform->getTab("layout")->yesNo(
		-name=>"convertCarriageReturns",
		-label=>WebGUI::International::get(10,$_[0]->get("namespace")),
		-value=>$_[0]->getValue("convertCarriageReturns"),
		-subtext=>' &nbsp; <span style="font-size: 8pt;">'.WebGUI::International::get(11,$_[0]->get("namespace")).'</span>',
		-uiLevel=>5,
		-defaultValue=>0
		);
	return $tabform;
}


#-------------------------------------------------------------------
sub getName {
	return WebGUI::International::get(1,"Article");
}


#-------------------------------------------------------------------
sub www_edit {
        my $self = shift;
        return WebGUI::Privilege::insufficient() unless $self->canEdit;
	$self->getAdminConsole->setHelp("article add/edit");
        return $self->getAdminConsole->render($self->getEditForm,WebGUI::International::get("12","Article"));
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
sub www_view {
	my $self = shift;
	$self->logView() if ($session{setting}{passiveProfilingEnabled});
	my ($file, %var);
	if ($self->get("image") ne "") {
		$file = WebGUI::Attachment->new($self->get("image"),$self->get("wobjectId"));
		$var{"image.url"} = $file->getURL;
		$var{"image.thumbnail"} = $file->getThumbnail;
	}
        $var{description} = $self->get("description");
	if ($self->get("convertCarriageReturns")) {
		$var{description} =~ s/\n/\<br\>\n/g;
	}
	$var{"new.template"} = WebGUI::URL::page("wid=".$self->get("wobjectId")."&func=view")."&overrideTemplateId=";
	$var{"description.full"} = $var{description};
	$var{"description.full"} =~ s/\^\-\;//g;
	$var{"description.first.100words"} = $var{"description.full"};
	$var{"description.first.100words"} =~ s/(((\S+)\s+){100}).*/$1/s;
	$var{"description.first.75words"} = $var{"description.first.100words"};
	$var{"description.first.75words"} =~ s/(((\S+)\s+){75}).*/$1/s;
	$var{"description.first.50words"} = $var{"description.first.75words"};
	$var{"description.first.50words"} =~ s/(((\S+)\s+){50}).*/$1/s;
	$var{"description.first.25words"} = $var{"description.first.50words"};
	$var{"description.first.25words"} =~ s/(((\S+)\s+){25}).*/$1/s;
	$var{"description.first.10words"} = $var{"description.first.25words"};
	$var{"description.first.10words"} =~ s/(((\S+)\s+){10}).*/$1/s;
	$var{"description.first.2paragraphs"} = $var{"description.full"};
	$var{"description.first.2paragraphs"} =~ s/^((.*?\n){2}).*/$1/s;
	$var{"description.first.paragraph"} = $var{"description.first.2paragraphs"};
	$var{"description.first.paragraph"} =~ s/^(.*?\n).*/$1/s;
	$var{"description.first.4sentences"} = $var{"description.full"};
	$var{"description.first.4sentences"} =~ s/^((.*?\.){4}).*/$1/s;
	$var{"description.first.3sentences"} = $var{"description.first.4sentences"};
	$var{"description.first.3sentences"} =~ s/^((.*?\.){3}).*/$1/s;
	$var{"description.first.2sentences"} = $var{"description.first.3sentences"};
	$var{"description.first.2sentences"} =~ s/^((.*?\.){2}).*/$1/s;
	$var{"description.first.sentence"} = $var{"description.first.2sentences"};
	$var{"description.first.sentence"} =~ s/^(.*?\.).*/$1/s;
	my $p = WebGUI::Paginator->new(WebGUI::URL::page("wid=".$self->get("wobjectId")."&func=view"),1);
	if ($session{form}{makePrintable} || $var{description} eq "") {
		$var{description} =~ s/\^\-\;//g;
		$p->setDataByArrayRef([$var{description}]);
	} else {
		my @pages = split(/\^\-\;/,$var{description});
		$p->setDataByArrayRef(\@pages);
		$var{description} = $p->getPage;
	}
	$p->appendTemplateVars(\%var);
	if ($self->get("attachment") ne "") {
		$file = WebGUI::Attachment->new($self->get("attachment"),$self->get("wobjectId"));
		$var{"attachment.box"} = $file->box;
		$var{"attachment.icon"} = $file->getIcon;
		$var{"attachment.url"} = $file->getURL;
		$var{"attachment.name"} = $file->getFilename;
	}	
	my $callback = WebGUI::URL::page("func=view&amp;wid=".$self->get("wobjectId"));
	if ($self->get("allowDiscussion")) {
		my $forum = WebGUI::Forum->new($self->get("forumId"));
		$var{"replies.count"} = ($forum->get("replies") + $forum->get("threads"));
		$var{"replies.URL"} = WebGUI::Forum::UI::formatForumURL($callback,$forum->get("forumId"));
		$var{"replies.label"} = WebGUI::International::get(28,$self->get("namespace"));
		$var{"post.URL"} = WebGUI::Forum::UI::formatNewThreadURL($callback,$forum->get("forumId"));
        	$var{"post.label"} = WebGUI::International::get(24,$self->get("namespace"));
	}
	my $templateId = $self->get("templateId");
        if ($session{form}{overrideTemplateId} ne "") {
                $templateId = $session{form}{overrideTemplateId};
        }
	if ($session{form}{forumOp}) {
		return WebGUI::Forum::UI::forumOp({
			callback=>$callback,
			title=>$self->get("title"),
			description=>$self->get("description"),
			forumId=>$self->get("forumId")
			});
	} else {
		return $self->processTemplate($templateId,\%var);
	}
}


1;

