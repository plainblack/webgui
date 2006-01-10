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
	my $definition = shift;
	my %properties;
	tie %properties, 'Tie::IxHash';
	%properties = (
			templateId =>{
				tab=>"display",
				fieldType=>"template",
				defaultValue=>'PBtmpl0000000000000047',	
				namespace=>"MessageBoard",
                		label=>WebGUI::International::get(73,"Asset_MessageBoard"),
                		hoverHelp=>WebGUI::International::get('73 description',"Asset_MessageBoard")
				}
		);
	push(@{$definition}, {
		assetName=>WebGUI::International::get('assetName',"Asset_MessageBoard"),
		icon=>'messageBoard.gif',
		tableName=>'MessageBoard',
		className=>'WebGUI::Asset::Wobject::MessageBoard',
		autoGenerateForms=>1,
		properties=>\%properties
		});
        return $class->SUPER::definition($definition);
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
	$var{'forum.add.label'} = WebGUI::International::get(75,"Asset_MessageBoard");
	$var{'title.label'} = WebGUI::International::get('title','Asset_MessageBoard');
	$var{'views.label'} = WebGUI::International::get('views',,'Asset_MessageBoard');
	$var{'rating.label'} = WebGUI::International::get('rating','Asset_MessageBoard');
	$var{'threads.label'} = WebGUI::International::get('threads','Asset_MessageBoard');
	$var{'replies.label'} = WebGUI::International::get('replies','Asset_MessageBoard');
	$var{'lastpost.label'} = WebGUI::International::get('lastpost','Asset_MessageBoard');
	$var{areMultipleForums} = ($count > 1);
	$var{forum_loop} = \@forum_loop;
       	return $self->processTemplate(\%var,$self->get("templateId"));
}

1;


