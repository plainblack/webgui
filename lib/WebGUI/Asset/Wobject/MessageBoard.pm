package WebGUI::Asset::Wobject::MessageBoard;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Tie::IxHash;
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
	return $class->SUPER::definition($definition);
	my $definition = shift;
	my $i18n = WebGUI::International->new($session,"Asset_MessageBoard");
	my %properties;
	tie %properties, 'Tie::IxHash';
	%properties = (
			templateId =>{
				tab=>"display",
				fieldType=>"template",
				defaultValue=>'PBtmpl0000000000000047',	
				namespace=>"MessageBoard",
                		label=>$i18n->get(73),
                		hoverHelp=>$i18n->get('73 description')
				}
		);
	push(@{$definition}, {
		assetName=>$i18n->get('assetName'),
		icon=>'messageBoard.gif',
		tableName=>'MessageBoard',
		className=>'WebGUI::Asset::Wobject::MessageBoard',
		autoGenerateForms=>1,
		properties=>\%properties
		});
        return $class->SUPER::definition($session, $definition);
}


#-------------------------------------------------------------------
sub view {
	my $self = shift;
	my %var;
	my $count;
	my $first;
	my @forum_loop;
	my $i18n = WebGUI::International->new($self->session,"Asset_MessageBoard");
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
				'forum.lastPost.date' => $self->session->datetime->epochToHuman($lastPost->get("dateSubmitted"),"%z"),
				'forum.lastPost.time' => $self->session->datetime->epochToHuman($lastPost->get("dateSubmitted"),"%Z"),
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
	$var{'forum.add.url'} = $self->getUrl("func=add;class=WebGUI::Asset::Wobject::Collaboration");
	$var{'forum.add.label'} = $i18n->get(75);
	$var{'title.label'} = $i18n->get('title');
	$var{'views.label'} = $i18n->get('views');
	$var{'rating.label'} = $i18n->get('rating');
	$var{'threads.label'} = $i18n->get('threads');
	$var{'replies.label'} = $i18n->get('replies');
	$var{'lastpost.label'} = $i18n->get('lastpost');
	$var{areMultipleForums} = ($count > 1);
	$var{forum_loop} = \@forum_loop;
       	return $self->processTemplate(\%var,$self->get("templateId"));
}

1;


