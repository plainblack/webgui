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
use Tie::IxHash;
use WebGUI::Cache;
use WebGUI::Asset::Wobject;
use WebGUI::International;
use WebGUI::SQL;

our @ISA = qw(WebGUI::Asset::Wobject);


#-------------------------------------------------------------------
sub definition {
	my $class = shift;
	my $session = shift;
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
				},
			visitorCacheTimeout => {
				tab => "display",
				fieldType => "interval",
				defaultValue => 3600,
				uiLevel => 8,
				label => $i18n->get("visitor cache timeout"),
				hoverHelp => $i18n->get("visitor cache timeout help")
				},
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

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
    my $self = shift;
    $self->SUPER::prepareView();
    my $template = WebGUI::Asset::Template->new($self->session, $self->get("templateId"));
    if (!$template) {
        WebGUI::Error::ObjectNotFound::Template->throw(
            error      => qq{Template not found},
            templateId => $self->get("templateId"),
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

sub purgeCache {
	my $self = shift;
	WebGUI::Cache->new($self->session,"view_".$self->getId)->delete;
	$self->SUPER::purgeCache;
}

#-------------------------------------------------------------------

=head2 view ( )

See WebGUI::Asset::view() for details.

=cut

sub view {
	my $self = shift;
	if ($self->session->user->isVisitor) {
		my $out = WebGUI::Cache->new($self->session,"view_".$self->getId)->get;
		return $out if $out;
	}
	my %var;
	my $count;
	my $first;
	my @forum_loop;
	my $i18n = WebGUI::International->new($self->session,"Asset_MessageBoard");
	my $childIter = $self->getLineageIterator(["children"],{includeOnlyClasses=>["WebGUI::Asset::Wobject::Collaboration"]});
        while ( 1 ) {
            my $child;
            eval { $child = $childIter->() };
            if ( my $x = WebGUI::Error->caught('WebGUI::Error::ObjectNotFound') ) {
                $self->session->log->error($x->full_message);
                next;
            }
            last unless $child;
		$count++;
		next unless ($child->canView);
		if ($count == 1) {
			$first = $child;
		}
		my %lastPostVars;
		my $lastPost = WebGUI::Asset::Wobject::MessageBoard->newByDynamicClass($self->session, $child->get("lastPostId"));
		if (defined $lastPost) {
			%lastPostVars = (
				'forum.lastPost.url' => $lastPost->getUrl,
				'forum.lastPost.date' => $self->session->datetime->epochToHuman($lastPost->get("creationDate"),"%z"),
				'forum.lastPost.time' => $self->session->datetime->epochToHuman($lastPost->get("creationDate"),"%Z"),
				'forum.lastPost.epoch' => $lastPost->get("creationDate"),
				'forum.lastPost.subject' => $lastPost->get("title"),
				'forum.lastPost.user.hasRead' => $lastPost->getThread->isMarkedRead,
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
		WebGUI::Cache->new($self->session,"view_".$self->getId)->set($out,$self->get("visitorCacheTimeout"));
	}
       	return $out;
}

#-------------------------------------------------------------------

=head2 www_view ( )

See WebGUI::Asset::Wobject::www_view() for details.

=cut

sub www_view {
	my $self = shift;
	$self->session->http->setCacheControl($self->get("visitorCacheTimeout")) if ($self->session->user->isVisitor);
	$self->SUPER::www_view(@_);
}

1;


