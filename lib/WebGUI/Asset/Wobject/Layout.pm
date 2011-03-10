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
use WebGUI::Asset::Wobject;
use WebGUI::Utility;
use WebGUI::Cache;

our @ISA = qw(WebGUI::Asset::Wobject);

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

=head2 definition ( definition )

Defines the properties of this asset.

=head3 definition

A hash reference passed in from a subclass definition.

=cut

sub definition {
    my $class = shift;
    my $session = shift;
    my $definition = shift;
    my $i18n = WebGUI::International->new($session,"Asset_Layout");
    
    push(@{$definition}, {
        assetName=>$i18n->get("assetName"),
        icon=>'layout.gif',
        tableName=>'Layout',
        className=>'WebGUI::Asset::Wobject::Layout',
        properties=>{
            templateId => {
                label        => $i18n->get('layout template title'),
                hoverHelp    => $i18n->get('template description'),
                fieldType    =>"template",
                namespace    => "Layout",
                defaultValue =>'PBtmpl0000000000000054',
            },
            mobileTemplateId => {
                fieldType    => ( $session->style->useMobileStyle ? 'template' : 'hidden' ),
                label        => $i18n->get('mobileTemplateId label'),
                hoverHelp    => $i18n->get('mobileTemplateId description'),
                namespace    => 'Layout',
                defaultValue => 'PBtmpl0000000000000054',
            },
            contentPositions => {
                noFormPost   =>1,
                defaultValue =>undef,
                fieldType    =>"hidden"
            },
            assetsToHide => {
                defaultValue =>undef,
                fieldType    =>"checkList"
            },
            assetOrder => {
                defaultValue => 'asc',
                fieldType    => 'selectBox',
                label        => $i18n->get('asset order label'),
                hoverHelp    => $i18n->get('asset order hoverHelp'),
            }
        }
    });
    return $class->SUPER::definition($session, $definition);
}


#-------------------------------------------------------------------

=head2 getEditForm ( )

Extends the base method to  handle the optional mobileTemplateId and assetsToHide.

=cut

sub getEditForm {
    my $self = shift;
    my $tabform = $self->SUPER::getEditForm();
    my $i18n = WebGUI::International->new($self->session,"Asset_Layout");

    my ($templateId);
    if (($self->get("assetId") eq "new") && ($self->getParent->get('className') eq 'WebGUI::Asset::Wobject::Layout')) {
        $templateId = $self->getParent->getValue('templateId');
    } else {
        $templateId = $self->getValue('templateId');
    }

    tie my %extraFields, "Tie::IxHash";
    %extraFields = (
      templateId => {
          fieldType => 'template',
          tab       => 'display',
          value     => $templateId,
          label     => $i18n->get('layout template title'),
          hoverHelp => $i18n->get('template description'),
          namespace => "Layout",
      });

    if ( $self->session->setting->get('useMobileStyle') ) {
      $extraFields{mobileTemplateId} = {
        fieldType   => 'template',
        tab         => 'display',
        name        => 'mobileTemplateId',
        value       => $self->getValue('mobileTemplateId'),
        label       => $i18n->get('mobileTemplateId label'),
        hoverHelp   => $i18n->get('mobileTemplateId description'),
        namespace   => 'Layout',
      };
    }
    else {
        $extraFields{mobileTemplateId} = {
            fieldType   => 'hidden',
            tab         => 'display',
            name        => 'mobileTemplateId',
            value       => $self->getValue('mobileTemplateId'),
        };
    }

	tie my %assetOrder, "Tie::IxHash";
	%assetOrder = (
		"asc"  => $i18n->get("asset order asc"),
		"desc" => $i18n->get("asset order desc"),
	);
    $extraFields{assetOrder} = {
        tab         => 'display',
        fieldType   => 'selectBox',
        name        => 'assetOrder',
        label       => $i18n->get('asset order label'),
        hoverHelp   => $i18n->get('asset order hoverHelp'),
        value       => $self->getValue('assetOrder'),
        options     => \%assetOrder,
    };

    if ($self->get("assetId") eq "new") {
        $extraFields{whatNext} = {
            fieldType   => 'whatNext',
            value       => "view",
            options     => {
                view       => $i18n->get(823),
                viewParent => $i18n->get(847)
            },
        };
    }
    else {
        my @assetsToHide = split("\n",$self->getValue("assetsToHide"));
        my $childIter = $self->getLineageIterator(["children"],{excludeClasses=>["WebGUI::Asset::Wobject::Layout"]});
        my %childIds;
        while ( 1 ) {
            my $child;
            eval { $child = $childIter->() };
            if ( my $x = WebGUI::Error->caught('WebGUI::Error::ObjectNotFound') ) {
                $self->session->log->error($x->full_message);
                next;
            }
            last unless $child;
            $childIds{$child->getId} = $child->getTitle;    
        }
        $extraFields{assetsToHide} = {
            fieldType => 'checkList',
            tab       => 'display',
            name      => "assetsToHide",
            value     => \@assetsToHide,
            options   => \%childIds,
            label     => $i18n->get('assets to hide'),
            hoverHelp => $i18n->get('assets to hide description'),
            vertical  => 1,
            uiLevel   => 9,
        };
    }

    my $overrides = $self->session->config->get("assets/".$self->get("className"));
    foreach my $fieldName (keys %extraFields) {
        $self->setupFormField($tabform, $fieldName, \%extraFields, $overrides);
    }

    return $tabform;
}

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
        $templateId = $self->get('mobileTemplateId');
    }
    else {
        $templateId = $self->get('templateId');
    }

    my $template = WebGUI::Asset->new($session,$templateId,"WebGUI::Asset::Template");
    if (!$template) {
        WebGUI::Error::ObjectNotFound::Template->throw(
            error      => qq{Template not found},
            templateId => $templateId,
            assetId    => $self->getId,
        );
    }
    $template->prepare( $self->getMetaDataAsTemplateVariables );
    $self->{_viewTemplate} = $template;

    my $templateContent = $template->get("template");
    my $numPositions = 1;
    while ($templateContent =~ /position(\d+)_loop/g) {
        $numPositions = $1
            if $1 > $numPositions;
    }

    my %vars;
    $vars{showAdmin} = ($session->var->isAdminOn && $self->canEdit && $self->canEditIfLocked);

    my $splitter = $self->{_viewSplitter} = $self->getSeparator;

    my %hidden = map { $_ => 1 }
        split "\n", $self->get("assetsToHide");

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
            isUncommitted  => $child->get('status') eq 'pending',
            content        => $splitter . $assetId . '~~',
        };
        if ($vars{showAdmin}) {
            $children[-1]->{'dragger.icon'} = sprintf '<div id="td%s_handle" class="dragable"><div class="dragTrigger dragTriggerWrap">%s</div></div>', $assetId, $session->icon->drag('class="dragTrigger"');
        };
    }

    my @positions = split /\./, $self->get("contentPositions");
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
    if($self->getValue("assetOrder") eq "asc") {
        push @{ $vars{"position1_loop"} }, @children;
    }
    else {
        unshift @{ $vars{"position1_loop"} }, reverse @children;
    }

    if ($vars{showAdmin}) {
        # under normal circumstances we don't put HTML stuff in our code, but this will make it much easier
        # for end users to work with our templates
        $session->style->setScript($session->url->extras("yui/build/yahoo-dom-event/yahoo-dom-event.js"),{ type=>"text/javascript" });
        $session->style->setScript($session->url->extras("yui/build/animation/animation-min.js"),{ type=>"text/javascript" });
        $session->style->setScript($session->url->extras("yui/build/dragdrop/dragdrop.js"),{ type=>"text/javascript" });
        $session->style->setScript($session->url->extras("yui-webgui/build/layout/draggable.js"),{ type=>"text/javascript" });

        $session->style->setLink($session->url->extras("draggable.css"),{ type=>"text/css", rel=>"stylesheet", media=>"all" });
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
    my $showPerformance = $session->errorHandler->canShowPerformanceIndicators;
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
            my $t = [Time::HiRes::gettimeofday()] if ($showPerformance);
            my $assetOutput = $asset->view;
            $assetOutput .= "Asset:".Time::HiRes::tv_interval($t) if ($showPerformance);
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
    $self->addRevision({
        contentPositions=>$self->session->form->process("map")
        });
    WebGUI::VersionTag->autoCommitWorkingIfEnabled($self->session);
    return "Map set: ".$self->session->form->process("map");
}

#-------------------------------------------------------------------

=head2 getContentLastModified 

Extend the base class to include looking at the last modified times of all children
of the page, by lineage.

=cut

sub getContentLastModified {
    # Buggo: this is a little too conservative.  Children that are hidden maybe shouldn't count.  Hm.
    my $self = shift;
    my $mtime = $self->SUPER::getContentLastModified;
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
}

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

sub www_view {
    my $self = shift;
    my $session = $self->session;
    # slashdot / burst protection hack
    if ($session->var->get("userId") eq "1"
        && $session->form->param() == 0
        && !$session->scratch->get('isExporting')
    ) {
        my $check = $self->checkView;
        return $check if (defined $check);
        my $cache = $self->getCache;
        my $out   = $cache->get if defined $cache;
        unless ($out) {
            $self->prepareView;
            $session->stow->set("cacheFixOverride", 1);
            $out = $self->processStyle($self->view, { noHeadTags => 1 });
            $cache->set($out, 60);
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
    return $self->SUPER::www_view;
}

1;

