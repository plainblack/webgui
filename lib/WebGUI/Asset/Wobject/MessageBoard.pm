package WebGUI::Asset::Wobject::MessageBoard;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Asset::Wobject;
use WebGUI::DateTime;
use WebGUI::International;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;

our @ISA = qw(WebGUI::Asset::Wobject);


#-------------------------------------------------------------------
sub definition {
	my $class = shift;
	my $definition = shift;
	push(@{$definition}, {
		tableName=>'MessageBoard',
		className=>'WebGUI::Asset::Wobject::MessageBoard',
		properties=>{
			templateId =>{
				fieldType=>"template",
				defaultValue=>'PBtmpl0000000000000047'
				},
			}
		});
        return $class->SUPER::definition($definition);
}

#-------------------------------------------------------------------
sub getEditForm {
	my $self = shift;
	my $tabform = $self->SUPER::getEditForm();
   	$tabform->getTab("display")->template(
      		-value=>$self->getValue('templateId'),
      		-namespace=>"MessageBoard"
   		);
	return $tabform;
}


#-------------------------------------------------------------------
sub getName {
        return WebGUI::International::get(2,"MessageBoard");
}


#-------------------------------------------------------------------
sub view {
	my $self = shift;
	my %var;
	my $count;
	my $first;
	my @forum_loop;
	my $children = $self->getLineage(["children"],{includeOnlyClasses=>["WebGUI::Asset::Wobject::Collaboration"],returnObjects=>1});
	foreach my $child (@{$children}) {
		$count++;
		next unless ($child->canView);
		if ($count == 1) {
			$first = $child;
		}
		my %lastPostVars;
		my $lastPost = WebGUI::Asset::Wobject::MessageBoard->newByDynamicClass($child->get("lastPostId"));
		if (defined $lastPost) {
			%lastPostVars = (
				'forum.lastPost.url' => $lastPost->getUrl,
				'forum.lastPost.date' => WebGUI::DateTime::epochToHuman($lastPost->get("dateSubmitted"),"%z"),
				'forum.lastPost.time' => WebGUI::DateTime::epochToHuman($lastPost->get("dateSubmitted"),"%z"),
				'forum.lastPost.epoch' => $lastPost->get("dateSubmitted"),
				'forum.lastPost.subject' => $lastPost->get("title"),
				'forum.lastPost.user.id' => $lastPost->get("ownerUserId"),
				'forum.lastPost.user.name' => $lastPost->get("username"),
				'forum.lastPost.user.alias' => $lastPost->get("username"),
				'forum.lastPost.user.profile' => $lastPost->getPosterProfileUrl,
				'forum.lastPost.user.isVisitor' => ($lastPost->get("ownerUserId") eq '1')
				);
		}
		push(@forum_loop, {
			%lastPostVars,
			'forum.controls' => $child->getToolbar,
			'forum.count' => $count,
			'forum.title' => $child->get('title'),
			'forum.description' => $child->get("description"),
			'forum.replies' => $child->get("replies"),
			'forum.rating' => $child->get("rating"),
			'forum.views' => $child->get("views"),
			'forum.threads' => $child->get("threads"),
			'forum.url' => $child->getUrl,
			'forum.user.canView' => $child->canView,
			'forum.user.canPost' => $child->canPost
			});
	}
	$var{'default.listing'} = $first->view if ($count == 1 && defined $first);
	$var{'forum.add.url'} = $self->getUrl("func=add&class=WebGUI::Asset::Wobject::Collaboration");
	$var{'forum.add.label'} = WebGUI::International::get(75,"MessageBoard");
	$var{'title.label'} = WebGUI::International::get('title','MessageBoard');
	$var{'views.label'} = WebGUI::International::get('views',,'MessageBoard');
	$var{'rating.label'} = WebGUI::International::get('rating','MessageBoard');
	$var{'threads.label'} = WebGUI::International::get('threads','MessageBoard');
	$var{'replies.label'} = WebGUI::International::get('replies','MessageBoard');
	$var{'lastpost.label'} = WebGUI::International::get('lastpost','MessageBoard');
	$var{areMultipleForums} = ($count > 1);
	$var{forum_loop} = \@forum_loop;
       	return $self->processTemplate(\%var,$self->get("templateId"));
}


#-------------------------------------------------------------------
sub www_edit {
        my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	$self->getAdminConsole->setHelp("message board add/edit");
        return $self->getAdminConsole->render($self->getEditForm->print,WebGUI::International::get("6","MessageBoard"));
}


1;


