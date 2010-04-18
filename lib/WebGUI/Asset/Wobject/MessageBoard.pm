package WebGUI::Asset::Wobject::MessageBoard;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Asset::Wobject;
use WebGUI::International;
use WebGUI::SQL;

use Moose;
use WebGUI::Definition::Asset;
extends 'WebGUI::Asset::Wobject';
define assetName => ['assetName', 'Asset_MessageBoard'];
define icon      => 'messageBoard.gif';
define tableName => 'MessageBoard';
property templateId => (
                tab         => "display",
                fieldType   => "template",
                default     => 'PBtmpl0000000000000047',    
                namespace   => "MessageBoard",
                label       => [73, 'Asset_MessageBoard'],
                hoverHelp   => ['73 description', 'Asset_MessageBoard'],
         );
property visitorCacheTimeout => (
                tab         => "display",
                fieldType   => "interval",
                default     => 3600,
                uiLevel     => 8,
                label       => ["visitor cache timeout", 'Asset_MessageBoard'],
                hoverHelp   => ["visitor cache timeout help", 'Asset_MessageBoard'],
         );


#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
    my $self = shift;
    $self->SUPER::prepareView();
    my $template = WebGUI::Asset::Template->newById($self->session, $self->templateId);
    if (!$template) {
        WebGUI::Error::ObjectNotFound::Template->throw(
            error      => qq{Template not found},
            templateId => $self->templateId,
            assetId    => $self->getId,
        );
    }
    $template->prepare($self->getMetaDataAsTemplateVariables);
    $self->{_viewTemplate} = $template;
}

#-------------------------------------------------------------------

=head2 purgeCache ( )

See WebGUI::Asset::purgeCache() for details.

=cut

override purgeCache => sub {
	my $self = shift;
	eval{$self->session->cache->delete("view_".$self->getId)};
	super();
};

#-------------------------------------------------------------------

=head2 view ( )

See WebGUI::Asset::view() for details.

=cut

sub view {
	my $self = shift;
    my $cache = $self->session->cache;
	if ($self->session->user->isVisitor) {
		my $out = eval{$cache->get("view_".$self->getId)};
		return $out if $out;
	}
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
		my $lastPost = WebGUI::Asset::Wobject::MessageBoard->newById($self->session, $child->lastPostId);
		if (defined $lastPost) {
			%lastPostVars = (
				'forum.lastPost.url' => $lastPost->getUrl,
				'forum.lastPost.date' => $self->session->datetime->epochToHuman($lastPost->creationDate,"%z"),
				'forum.lastPost.time' => $self->session->datetime->epochToHuman($lastPost->creationDate,"%Z"),
				'forum.lastPost.epoch' => $lastPost->creationDate,
				'forum.lastPost.subject' => $lastPost->title,
				'forum.lastPost.user.hasRead' => $lastPost->getThread->isMarkedRead,
				'forum.lastPost.user.id' => $lastPost->ownerUserId,
				'forum.lastPost.user.name' => $lastPost->username,
				'forum.lastPost.user.alias' => $lastPost->username,
				'forum.lastPost.user.profile' => $lastPost->getPosterProfileUrl,
				'forum.lastPost.user.isVisitor' => ($lastPost->ownerUserId eq '1')
				);
		}

		push(@forum_loop, {
			%lastPostVars,
			'forum.controls' => $child->getToolbar,
			'forum.count' => $count,
			'forum.title' => $child->title,
			'forum.description' => $child->description,
			'forum.replies' => $child->replies,
			'forum.rating' => $child->rating,
			'forum.views' => $child->views,
			'forum.threads' => $child->threads,
			'forum.url' => $child->getUrl,
			'forum.user.canView' => $child->canView,
			'forum.user.canPost' => $child->canPost
			});
	}
	if ($count == 1 && defined $first) {
		$first->prepareView;
		$var{'default.listing'} = $first->view;
	}
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

	my $out = $self->processTemplate(\%var,undef,$self->{_viewTemplate});
	if ($self->session->user->isVisitor) {
		eval{$cache->set("view_".$self->getId, $out, $self->visitorCacheTimeout)};
	}
       	return $out;
}

#-------------------------------------------------------------------

=head2 www_view ( )

See WebGUI::Asset::Wobject::www_view() for details.

=cut

override www_view => sub {
	my $self = shift;
	$self->session->http->setCacheControl($self->visitorCacheTimeout) if ($self->session->user->isVisitor);
	super();
};

__PACKAGE__->meta->make_immutable;
1;


