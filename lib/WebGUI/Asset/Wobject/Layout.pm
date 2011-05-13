package WebGUI::Asset::Wobject::Layout;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use WebGUI::AdSpace;
use Tie::IxHash;
use Moose;
use WebGUI::Definition::Asset;
extends 'WebGUI::Asset::Wobject';

define assetName => ["assetName", 'Asset_Layout'];
define icon      => 'layout.gif';
define tableName => 'Layout';

property templateId => (
             tab          => "display",
             fieldType    => "template",
             namespace    => "Layout",
             default      => 'PBtmpl0000000000000054',
             label        => ['layout template title', 'Asset_Layout'],
             hoverHelp    => ['template description', 'Asset_Layout'],
         );
property mobileTemplateId => (
             tab          => "display",
             fieldType    => 'template',
             namespace    => 'Layout',
             default      => 'PBtmpl0000000000000054',
             label        => ['mobileTemplateId label', 'Asset_Layout'],
             hoverHelp    => ['mobileTemplateId description', 'Asset_Layout'],
         );
property contentPositions => (
             noFormPost   => 1,
             default      => undef,
             fieldType    => "hidden",
         );
property assetsToHide => (
             tab          => "properties",
             default      => undef,
             fieldType    => "checkList",
             label          => ['assets to hide', 'Asset_Layout'],
             hoverHelp      => ['assets to hide description', 'Asset_Layout'],
             vertical  => 1,
             uiLevel   => 9,
             options        => sub {
                my ( $self ) = @_;
                my @assetsToHide = split("\n",$self->assetsToHide);
                my $children = $self->getLineage(["children"],{"returnObjects"=>1, excludeClasses=>["WebGUI::Asset::Wobject::Layout"]});
                my %childIds;
                foreach my $child (@{$children}) {
                    $childIds{$child->getId} = $child->getTitle;    
                }
                return \%childIds;
             },
         );
property assetOrder => (
             tab          => "display",
             default      => 'asc',
             fieldType    => 'selectBox',
             label        => ['asset order label', 'Asset_Layout'],
             hoverHelp    => ['asset order hoverHelp', 'Asset_Layout'],
             options      => sub {
                 my ( $self ) = @_;
                 my $i18n = WebGUI::International->new( $self->session, 'Asset_Layout' );
                 tie my %assetOrder, "Tie::IxHash", (
                    "asc"  => $i18n->get("asset order asc"),
                    "desc" => $i18n->get("asset order desc"),
                );
                return \%assetOrder;
             },
         );

=head1 NAME

Package WebGUI::Asset::Wobject::Layout

=head1 DESCRIPTION

Provides a mechanism to layout multiple assets on a single page.

=head1 SYNOPSIS

use WebGUI::Asset::Wobject::Layout;


=head1 METHODS

These methods are available from this class:

=cut



#-------------------------------------------------------------------

=head2 getEditForm ( )

Extends the base method to  handle the optional mobileTemplateId and assetsToHide.

=cut

override getEditForm => sub {
    my $self = shift;
    my $f = super();
    my $i18n = WebGUI::International->new($self->session,"Asset_Layout");

    my ($templateId);
    if (($self->assetId eq "new") && ($self->getParent->isa('WebGUI::Asset::Wobject::Layout'))) {
        $f->getTab('display')->getField('templateId')->set( value => $self->getParent->templateId );
    }

    if ( !$self->session->setting->get('useMobileStyle') ) {
        $f->getTab('display')->deleteField( 'mobileTemplateId' );
    }

    return $f;
};

#-------------------------------------------------------------------

=head2 prepareView 

Extends the base class to handle the optional mobile style template, to handle asset dragging
and to put children in their places.

=cut

sub prepareView {
    my $self = shift;
    $self->SUPER::prepareView;
    my $session = $self->session;
    my $templateId;

    if ($session->style->useMobileStyle) {
        $templateId = $self->mobileTemplateId;
    }
    else {
        $templateId = $self->templateId;
    }

    my $template = WebGUI::Asset->newById($session, $templateId);
    if (!$template) {
        WebGUI::Error::ObjectNotFound::Template->throw(
            error      => qq{Template not found},
            templateId => $templateId,
            assetId    => $self->getId,
        );
    }
    $template->prepare( $self->getMetaDataAsTemplateVariables );
    $self->{_viewTemplate} = $template;

    my $templateContent = $template->template;
    my $numPositions = 1;
    while ($templateContent =~ /position(\d+)_loop/g) {
        $numPositions = $1
            if $1 > $numPositions;
    }

    my %vars;
    $vars{showAdmin} = ($session->isAdminOn && $self->canEdit && $self->canEditIfLocked);

    my $splitter = $self->{_viewSplitter} = $self->getSeparator;

    my %hidden = map { $_ => 1 }
        split "\n", $self->assetsToHide;

    my %placeHolder;
    my @children;
    
    my $childIter = $self->getLineageIterator( ["children"], {
        excludeClasses  => ["WebGUI::Asset::Wobject::Layout"],
    } ); 
    while ( 1 ) {
        my $child;
        eval { $child = $childIter->() };
        if ( my $x = WebGUI::Error->caught('WebGUI::Error::ObjectNotFound') ) {
            $session->log->error($x->full_message);
            next;
        }
        last unless $child;
        my $assetId = $child->getId;
        next
            if ($hidden{$assetId} || ! $child->canView);
        $child->prepareView;
        $placeHolder{$assetId} = $child;
        push @children, {
            id             => $assetId,
            isUncommitted  => $child->status eq 'pending',
            content        => $splitter . $assetId . '~~',
        };
        if ($vars{showAdmin}) {
            $children[-1]->{'dragger.icon'} = sprintf '<div id="td%s_handle" class="dragable"><div class="dragTrigger dragTriggerWrap">%s</div></div>', $assetId, $session->icon->drag('class="dragTrigger"');
        };
    }

    my @positions = split /\./, $self->contentPositions;
    # cut positions off at the number we found in the template
    $#positions = $numPositions - 1
        if $numPositions < scalar @positions;

    my $positionIndex = 0;
    my @found;
    foreach my $position (@positions) {
        $positionIndex++;
        my @assets = split ',', $position;
        for my $assetId (@assets) {
            CHILD: for my $childIndex (0..$#children) {
                if ($children[$childIndex]{id} eq $assetId) {
                    # remove found child from child list, add it to the appropriate position loop
                    push @{ $vars{'position' . $positionIndex . '_loop'} },
                        splice @children, $childIndex, 1;
                    last CHILD;
                }
            }
        }
    }
    # deal with unplaced children
    # Add children to the top or bottom of the first content position based on assetOrder setting
    if($self->assetOrder eq "asc") {
        push @{ $vars{"position1_loop"} }, @children;
    }
    else {
        unshift @{ $vars{"position1_loop"} }, reverse @children;
    }

    # NOTE: This is the old way of doing the Layout drag/drop. The new way is injected by the WebGUI Admin
    # Interface if certain elements are present in the template
    if ($vars{showAdmin}) {
        # under normal circumstances we don't put HTML stuff in our code, but this will make it much easier
        # for end users to work with our templates
        $session->style->setScript($session->url->extras("yui/build/yahoo-dom-event/yahoo-dom-event.js"));
        $session->style->setScript($session->url->extras("yui/build/animation/animation-min.js"));
        $session->style->setScript($session->url->extras("yui/build/dragdrop/dragdrop.js"));
        $session->style->setScript($session->url->extras("yui-webgui/build/layout/draggable.js"));

        $session->style->setCss($session->url->extras("draggable.css"));
        $session->style->setRawHeadTags('
            <style type="text/css">
            .dragging, .empty {
                  background-image: url("'.$session->url->extras('opaque.gif').'");
            }
            </style>
        ');
        $vars{"dragger.init"} = '
            <iframe id="dragSubmitter" style="display: none;" src="'.$session->url->extras('spacer.gif').'"></iframe>
            <script type="text/javascript">
                dragable_init("'.$self->getUrl("func=setContentPositions;map=").'");
            </script>
            ';
    }

    $self->{_viewVars} = \%vars;
    $self->{_viewPlaceholder} = \%placeHolder;
}

#-------------------------------------------------------------------

=head2 view 

Render all the children.

Show performance indicators for the Layout and all children if enabled.

=cut

sub view {
    my $self = shift;
    my $session = $self->session;
    my $perfLog = $session->log->performanceLogger;
    my @parts = split $self->{_viewSplitter},
    $self->processTemplate($self->{_viewVars}, undef, $self->{_viewTemplate});
    my $output = "";

    if ($self->{_viewPrintOverride}) {
        $session->output->print(shift @parts);
    }
    else {
        $output .= shift @parts;
    }
    foreach my $part (@parts) {
        my ($assetId, $outputPart) = split '~~', $part, 2;
        my $asset = $self->{_viewPlaceholder}{$assetId};
        if (defined $asset) {
            my $t = $perfLog ? [Time::HiRes::gettimeofday()] : undef;
            my $assetOutput = $asset->view;
            $perfLog->({ asset => $asset, 'time' => Time::HiRes::tv_interval($t), type => 'Layout' })
                if $perfLog;
            if ($self->{_viewPrintOverride}) {
                $session->output->print($assetOutput);
            } else {
                $output .= $assetOutput;
            }
        }
        if ($self->{_viewPrintOverride}) {
            $session->output->print($outputPart);
        } else {
            $output .= $outputPart;
        }
    }
    return $output;
}

#-------------------------------------------------------------------

=head2 www_setContentPositions 

Method called via iFrame to handle reordering content positions.  This action creates
a new asset revision.

=cut

sub www_setContentPositions {
    my $self = shift;
    return $self->session->privilege->insufficient() unless ($self->canEdit);
    my $tag = WebGUI::VersionTag->getWorking( $self->session );
    my $newSelf = $self->addRevision({
        contentPositions=>$self->session->form->process("map")
        });
    $newSelf->setVersionLock;
    WebGUI::VersionTag->autoCommitWorkingIfEnabled($self->session);
    return "Map set: ".$self->session->form->process("map");
}

#-------------------------------------------------------------------

=head2 getContentLastModified 

Extend the base class to include looking at the last modified times of all children
of the page, by lineage.

=cut

override getContentLastModified => sub {
    # Buggo: this is a little too conservative.  Children that are hidden maybe shouldn't count.  Hm.
    my $self = shift;
    my $mtime = super();
    my $childIter = $self->getLineageIterator(["children"],{excludeClasses=>['WebGUI::Asset::Wobject::Layout']});
    while ( 1 ) {
        my $child;
        eval { $child = $childIter->() };
        if ( my $x = WebGUI::Error->caught('WebGUI::Error::ObjectNotFound') ) {
            $self->session->log->error($x->full_message);
            next;
        }
        last unless $child;
        my $child_mtime = $child->getContentLastModified;
        $mtime = $child_mtime if ($child_mtime > $mtime);
    }
    return $mtime;
};

#-------------------------------------------------------------------

=head2 getContentLastModifiedBy

Extend the base class to include the userid of the person that made last modification.

=cut

sub getContentLastModifiedBy {
    my $self      = shift;
    my $mtime     = $self->SUPER::getContentLastModified;
    my $userId    = $self->get('revisedBy');
    my $childIter = $self->getLineageIterator(["children"],{excludeClasses=>['WebGUI::Asset::Wobject::Layout']});
    while ( 1 ) {
        my $child;
        eval { $child = $childIter->() };
        if ( my $x = WebGUI::Error->caught('WebGUI::Error::ObjectNotFound') ) {
            $self->session->log->error($x->full_message);
            next;
        }
        last unless $child;
        my $child_mtime = $child->getContentLastModified;
        if ($child_mtime > $mtime) {
            $mtime = $child_mtime;
            $userId = $child->get("revisedBy");
        }
    }
    return $userId;
}

#-------------------------------------------------------------------

=head2 www_view 

Extend the base method to handle caching and ad rotation.

=cut

override www_view => sub {
    my $self = shift;
    my $session = $self->session;
    # slashdot / burst protection hack
    if ($session->user->isVisitor
        && $session->form->param() == 0
        && !$session->scratch->get('isExporting')
    ) {
        my $check = $self->checkView;
        return $check if (defined $check);
        my $cacheKey = $self->getWwwCacheKey('view');
        my $cache = $session->cache;
        my $out = $cache->get($cacheKey);
        unless ($out) {
            $self->prepareView;
            $session->stow->set("cacheFixOverride", 1);
            $out = $self->processStyle($self->view, { noHeadTags => 1 });
            $cache->set($cacheKey, $out, 60);
            $session->stow->delete("cacheFixOverride");
        }
        # keep those ads rotating even though the output is cached
        while ($out =~ /(\[AD\:([^\]]+)\])/gs) {
            my $code = $1;
            my $adSpace = WebGUI::AdSpace->newByName($session, $2);
            my $ad = $adSpace->displayImpression if (defined $adSpace);
            $out =~ s/\Q$code/$ad/ges;
        }
        $session->http->setLastModified($self->getContentLastModified);
        $session->http->sendHeader;
        $session->output->print($out, 1);
        return "chunked";
    }
    $self->{_viewPrintOverride} = 1; # we do this to make it output each asset as it goes, rather than waiting until the end
    return super();
};

__PACKAGE__->meta->make_immutable;
1;

