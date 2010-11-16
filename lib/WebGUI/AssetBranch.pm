package WebGUI::Asset;

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

=head1 NAME

Package WebGUI::Asset (AssetBranch)

=head1 DESCRIPTION

This is a mixin package for WebGUI::Asset that contains all branch manipulation related functions.

=head1 SYNOPSIS

 use WebGUI::Asset;

=head1 METHODS

These methods are available from this class:

=cut



#-------------------------------------------------------------------

=head2 duplicateBranch ( [ $childrenOnly ] )

Duplicates this asset and the entire subtree below it.  Returns the root of the new subtree.

=head3 $childrenOnly

If true, then only children, and not descendants, will be duplicated.

=head3 $state

Set this to "clipboard" if you want the resulting asset to be on the clipboard
(rather than published) when we're done.

=cut

sub duplicateBranch {
    my ($self, $childrenOnly, $state) = @_;
    my $session   = $self->session;
    my $log       = $session->log;
    my $clipboard = $state && $state =~ /^clipboard/;

    my $newAsset = $self->duplicate(
        {   skipAutoCommitWorkflows => 1,
            skipNotification        => 1,
            state                   => $state,
        }
    );

    # Correctly handle positions for Layout assets
    my $contentPositions = $self->get("contentPositions");
    my $assetsToHide     = $self->get("assetsToHide");

    my $childIter = $self->getLineageIterator(["children"]);
    while ( 1 ) {
        my $child;
        eval { $child = $childIter->() };
        if ( my $x = WebGUI::Error->caught('WebGUI::Error::ObjectNotFound') ) {
            $self->session->log->error($x->full_message);
            next;
        }
        last unless $child;
        my $newChild;
        if ($childrenOnly) {
            $newChild = $child->duplicate(
                {   skipAutoCommitWorkflows => 1,
                    skipNotification        => 1,
                    state                   => $clipboard && 'clipboard-limbo',
                }
            );
        }
        elsif($clipboard) {
            $newChild = $child->duplicateBranch(0, 'clipboard-limbo');
        }
        else {
            $newChild = $child->duplicateBranch;
        }
        $newChild->setParent($newAsset);
        my ($oldChildId, $newChildId) = ($child->getId, $newChild->getId);
        $contentPositions =~ s/\Q${oldChildId}\E/${newChildId}/g if ($contentPositions);
        $assetsToHide     =~ s/\Q${oldChildId}\E/${newChildId}/g if ($assetsToHide);
    }

    $newAsset->update({contentPositions=>$contentPositions}) if $contentPositions;
    $newAsset->update({assetsToHide=>$assetsToHide})         if $assetsToHide;
    return $newAsset;
}


#-------------------------------------------------------------------

=head2 www_editBranch ( )

Creates a tabform to edit the Asset Tree. If canEdit returns False, returns insufficient Privilege page. 

=cut

sub www_editBranch {
	my $self = shift;
	my $ac = WebGUI::AdminConsole->new($self->session,"assets");
	my $i18n = WebGUI::International->new($self->session,"Asset");
	my $i18n2 = WebGUI::International->new($self->session,"Asset_Wobject");
	return $self->session->privilege->insufficient() unless ($self->canEdit);
	my $tabform = WebGUI::TabForm->new($self->session);
	$tabform->hidden({name=>"func",value=>"editBranchSave"});
	$tabform->addTab("properties",$i18n->get("properties"),9);
        $tabform->getTab("properties")->readOnly(
                -label=>$i18n->get(104),
                -hoverHelp=>$i18n->get('edit branch url help'),
                -uiLevel=>9,
		-subtext=>'<br />'.$i18n->get("change").' '.WebGUI::Form::yesNo($self->session,{name=>"change_url"}),
		-value=>WebGUI::Form::selectBox($self->session, {
                	name=>"baseUrlBy",
			extras=>'onchange="toggleSpecificBaseUrl()"',
			id=>"baseUrlBy",
			options=>{
				parentUrl=>$i18n->get("parent url"),
				specifiedBase=>$i18n->get("specified base"),
				none=>$i18n->get("none")
				}
			}).'<span id="baseUrl"></span> / '.WebGUI::Form::selectBox($self->session, {
				name=>"endOfUrl",
				options=>{
					menuTitle=>$i18n->get(411),
					title=>$i18n->get(99),
					currentUrl=>$i18n->get("current url"),
					}
				})."<script type=\"text/javascript\">
			function toggleSpecificBaseUrl () {
				if (document.getElementById('baseUrlBy').options[document.getElementById('baseUrlBy').selectedIndex].value == 'specifiedBase') {
					document.getElementById('baseUrl').innerHTML='<input type=\"text\" name=\"baseUrl\" />';
				} else {
					document.getElementById('baseUrl').innerHTML='';
				}
			}
			toggleSpecificBaseUrl();
				</script>"
                );
	$tabform->addTab("display",$i18n->get(105),5);
	$tabform->getTab("display")->yesNo(
                -name=>"isHidden",
                -value=>$self->get("isHidden"),
                -label=>$i18n->get(886),
                -uiLevel=>6,
		-subtext=>'<br />'.$i18n->get("change").' '.WebGUI::Form::yesNo($self->session,{name=>"change_isHidden"}),
		-hoverHelp=>$i18n->get('886 description',"Asset"),
                );
        $tabform->getTab("display")->yesNo(
                -name=>"newWindow",
                -value=>$self->get("newWindow"),
                -label=>$i18n->get(940),
		-hoverHelp=>$i18n->get('940 description'),
                -uiLevel=>6,
		-subtext=>'<br />'.$i18n->get("change").' '.WebGUI::Form::yesNo($self->session,{name=>"change_newWindow"})
                );
	$tabform->getTab("display")->yesNo(
                -name=>"displayTitle",
                -label=>$i18n2->get(174),
		-hoverHelp=>$i18n2->get('174 description'),
                -value=>$self->get("displayTitle"),
                -uiLevel=>5,
		-subtext=>'<br />'.$i18n->get("change").' '.WebGUI::Form::yesNo($self->session,{name=>"change_displayTitle"})
                );
         $tabform->getTab("display")->template(
		-name=>"styleTemplateId",
		-label=>$i18n2->get(1073),
		-value=>$self->get("styleTemplateId"),
		-hoverHelp=>$i18n2->get('1073 description'),
		-namespace=>'style',
		-subtext=>'<br />'.$i18n->get("change").' '.WebGUI::Form::yesNo($self->session,{name=>"change_styleTemplateId"})
		);
         $tabform->getTab("display")->template(
		-name=>"printableStyleTemplateId",
		-label=>$i18n2->get(1079),
		-hoverHelp=>$i18n2->get('1079 description'),
		-value=>$self->get("printableStyleTemplateId"),
		-namespace=>'style',
		-subtext=>'<br />'.$i18n->get("change").' '.WebGUI::Form::yesNo($self->session,{name=>"change_printableStyleTemplateId"})
		);
        if ( $self->session->setting->get('useMobileStyle') ) {
            $tabform->getTab("display")->template(
                name        => 'mobileStyleTemplateId',
                label       => $i18n2->get('mobileStyleTemplateId label'),
                hoverHelp   => $i18n2->get('mobileStyleTemplateId description'),
                value       => $self->get('mobileStyleTemplateId'),
                namespace   => 'style',
                subtext     => '<br />' . $i18n->get('change') . q{ }
                    . WebGUI::Form::yesNo($self->session,{name=>"change_mobileStyleTemplateId"}),
            );
        }
	$tabform->addTab("security",$i18n->get(107),6);
        if ($self->session->config->get("sslEnabled")) {
            $tabform->getTab("security")->yesNo(
                -name=>"encryptPage",
                -value=>$self->get("encryptPage"),
                -label=>$i18n->get('encrypt page'),
		-hoverHelp=>$i18n->get('encrypt page description',"Asset"),
                -uiLevel=>6,
		-subtext=>'<br />'.$i18n->get("change").' '.WebGUI::Form::yesNo($self->session,{name=>"change_encryptPage"})
                );
        }
        $tabform->getTab("security")->user(
               -name=>"ownerUserId",
               -label=>$i18n->get(108),
               -hoverHelp=>$i18n->get('108 description',"Asset"),
               -value=>$self->get("ownerUserId"),
               -uiLevel=>6,
               -subtext=>'<br />'.$i18n->get("change").' '.WebGUI::Form::yesNo($self->session,{name=>"change_ownerUserId"})
               );
        $tabform->getTab("security")->group(
               -name=>"groupIdView",
               -label=>$i18n->get(872),
		-hoverHelp=>$i18n->get('872 description',"Asset"),
               -value=>[$self->get("groupIdView")],
               -uiLevel=>6,
		-subtext=>'<br />'.$i18n->get("change").' '.WebGUI::Form::yesNo($self->session,{name=>"change_groupIdView"})
               );
        $tabform->getTab("security")->group(
               -name=>"groupIdEdit",
               -label=>$i18n->get(871),
		-hoverHelp=>$i18n->get('871 description',"Asset"),
               -value=>[$self->get("groupIdEdit")],
               -excludeGroups=>[1,7],
               -uiLevel=>6,
		-subtext=>'<br />'.$i18n->get("change").' '.WebGUI::Form::yesNo($self->session,{name=>"change_groupIdEdit"})
		);
        $tabform->addTab("meta",$i18n->get("Metadata"),3);
        $tabform->getTab("meta")->textarea(
                -name=>"extraHeadTags",
                -label=>$i18n->get("extra head tags"),
                -hoverHelp=>$i18n->get('extra head tags description'),
                -value=>$self->get("extraHeadTags"),
                -uiLevel=>5,
		-subtext=>'<br />'.$i18n->get("change").' '.WebGUI::Form::yesNo($self->session,{name=>"change_extraHeadTags"})
                );


        $tabform->getTab("meta")->yesNo(
            -name         => 'usePackedHeadTags',
            -label        => $i18n->get('usePackedHeadTags label'),
            -hoverHelp    => $i18n->get('usePackedHeadTags description'),
            -uiLevel      => 7,
            -fieldType    => 'yesNo',
            -defaultValue => 0,
            -subtext      => '<br />'
                . $i18n->get("change") . ' '
                . WebGUI::Form::yesNo( $self->session, { name => "change_usePackedHeadTags" } ),
        );
        $tabform->getTab("meta")->yesNo(
            -name         => 'isPackage',
            -label        => $i18n->get("make package"),
            -hoverHelp    => $i18n->get('make package description'),
            -uiLevel      => 7,
            -fieldType    => 'yesNo',
            -defaultValue => 0,
            -subtext      => '<br />'
                . $i18n->get("change") . ' '
                . WebGUI::Form::yesNo( $self->session, { name => "change_isPackage" } ),
        );
        $tabform->getTab("meta")->yesNo(
            -name         => 'isPrototype',
            -label        => $i18n->get("make prototype"),
            -hoverHelp    => $i18n->get('make prototype description'),
            -uiLevel      => 9,
            -fieldType    => 'yesNo',
            -defaultValue => 0,
            -subtext      => '<br />'
                . $i18n->get("change") . ' '
                . WebGUI::Form::yesNo( $self->session, { name => "change_isPrototype" } ),
        );
        $tabform->getTab("meta")->yesNo(
            -name         => 'isExportable',
            -label        => $i18n->get('make asset exportable'),
            -hoverHelp    => $i18n->get('make asset exportable description'),
            -uiLevel      => 9,
            -fieldType    => 'yesNo',
            -defaultValue => 1,
            -subtext      => '<br />'
                . $i18n->get("change") . ' '
                . WebGUI::Form::yesNo( $self->session, { name => "change_isExportable" } ),
        );
        $tabform->getTab("meta")->yesNo(
            -name         => 'inheritUrlFromParent',
            -label        => $i18n->get('does asset inherit URL from parent'),
            -hoverHelp    => $i18n->get('does asset inherit URL from parent description'),
            -uiLevel      => 9,
            -fieldType    => 'yesNo',
            -defaultValue => 0,
            -subtext      => '<br />'
                . $i18n->get("change") . ' '
                . WebGUI::Form::yesNo( $self->session, { name => "change_inheritUrlFromParent" } ),
        );


        if ($self->session->setting->get("metaDataEnabled")) {
                my $meta = $self->getMetaDataFields();
                foreach my $field (keys %$meta) {
                    my $fieldType = $meta->{$field}{fieldType} || "text";
                    my $options = $meta->{$field}{possibleValues};
                    # Add a "Select..." option on top of a select list to prevent from
                    # saving the value on top of the list when no choice is made.
                    if("\l$fieldType" eq "selectBox") {
                        $options = "|" . $i18n->get("Select") . "\n" . $options;
                    }
                    $tabform->getTab("meta")->dynamicField(
                        fieldType       => $fieldType,
                        name            => "metadata_".$meta->{$field}{fieldId},
                        label           => $meta->{$field}{fieldName},
                        uiLevel         => 5,
                        value           => $meta->{$field}{value},
                        extras          => qq/title="$meta->{$field}{description}"/,
                        options         => $options,
                        defaultValue    => $meta->{$field}{defaultValue},
                        subtext         => '<br />'.$i18n->get("change").' '.WebGUI::Form::yesNo($self->session,{name=>"change_metadata_".$meta->{$field}{fieldId}}),
                    );
                }
        }	
	return $ac->render($tabform->print, $i18n->get('edit branch','Asset'));
}

#-------------------------------------------------------------------

=head2 www_editBranchSaveStatus ( )

Verifies proper inputs in the Asset Tree and saves them. Returns ManageAssets method. If canEdit returns False, returns an insufficient privilege page.

=cut

sub www_editBranchSave {
    my $self    = shift;
    my $session = $self->session;
    return $session->privilege->insufficient() unless ($self->canEdit && $session->user->isInGroup('4'));
    my $form    = $session->form;
    my %data;
    my $pb      = WebGUI::ProgressBar->new($session);
    my $i18n    = WebGUI::International->new($session, 'Asset');
    my $tag     = WebGUI::VersionTag->getWorking( $session );
    $pb->start($i18n->get('edit branch'), $session->url->extras('adminConsole/assets.gif'));
    $pb->update($i18n->get('Processing form data'));
    $data{isHidden}      = $form->yesNo("isHidden")        if ($form->yesNo("change_isHidden"));
    $data{newWindow}     = $form->yesNo("newWindow")       if ($form->yesNo("change_newWindow"));
    $data{encryptPage}   = $form->yesNo("encryptPage")     if ($form->yesNo("change_encryptPage"));
    $data{ownerUserId}   = $form->selectBox("ownerUserId") if ($form->yesNo("change_ownerUserId"));
    $data{groupIdView}   = $form->group("groupIdView")     if ($form->yesNo("change_groupIdView"));
    $data{groupIdEdit}   = $form->group("groupIdEdit")     if ($form->yesNo("change_groupIdEdit"));
    $data{extraHeadTags} = $form->textarea("extraHeadTags")
        if $form->yesNo("change_extraHeadTags");
    $data{usePackedHeadTags}    = $form->yesNo("usePackedHeadTags")
        if $form->yesNo("change_usePackedHeadTags");
    $data{isPackage}            = $form->yesNo("isPackage")
        if $form->yesNo("change_isPackage");
    $data{isPrototype}          = $form->yesNo("isPrototype")
        if $form->yesNo("change_isPrototype");
    $data{isExportable}         = $form->yesNo("isExportable")
        if $form->yesNo("change_isExportable");
    $data{inheritUrlFromParent} = $form->yesNo("inheritUrlFromParent")
        if $form->yesNo("change_inheritUrlFromParent");

    my %wobjectData = %data;
    $wobjectData{displayTitle} = $form->yesNo("displayTitle")
        if ($form->yesNo("change_displayTitle"));
    $wobjectData{styleTemplateId} = $form->template("styleTemplateId")
        if ($form->yesNo("change_styleTemplateId"));
    $wobjectData{printableStyleTemplateId} = $form->template("printableStyleTemplateId")
        if ($form->yesNo("change_printableStyleTemplateId"));
    $wobjectData{mobileStyleTemplateId} = $form->template("mobileStyleTemplateId")
        if ($form->yesNo("change_mobileStyleTemplateId"));

    my ($urlBaseBy, $urlBase, $endOfUrl);
    my $changeUrl  = $form->yesNo("change_url");
    if ($changeUrl) {
        $urlBaseBy = $form->selectBox("baseUrlBy");
        $urlBase   = $form->text("baseUrl");
        $endOfUrl  = $form->selectBox("endOfUrl");
    }
    my $descendantIter = $self->getLineageIterator(["self","descendants"]);
    while ( 1 ) {
        my $descendant;
        eval { $descendant = $descendantIter->() };
        if ( my $x = WebGUI::Error->caught('WebGUI::Error::ObjectNotFound') ) {
            $session->log->error($x->full_message);
            next;
        }
        last unless $descendant;
        if ( !$descendant->canEdit ) {
            $pb->update(sprintf $i18n->get('skipping %s'), $descendant->getTitle);
            next;
        }
        $pb->update(sprintf $i18n->get('editing %s'), $descendant->getTitle);
        my $url;
        if ($changeUrl) {
            if ($urlBaseBy eq "parentUrl") {
                delete $descendant->{_parent};
                $data{url} = $descendant->getParent->get("url")."/";
            } elsif ($urlBaseBy eq "specifiedBase") {
                $data{url} = $urlBase."/";
            } else {
                $data{url} = "";
            }
            if ($endOfUrl eq "menuTitle") {
                $data{url} .= $descendant->get("menuTitle");
            } elsif ($endOfUrl eq "title") {
                $data{url} .= $descendant->get("title");
            } else {
                $data{url} .= $descendant->get("url");
            }
            $wobjectData{url} = $data{url};
        }
        my $newData = $descendant->isa('WebGUI::Asset::Wobject') ? \%wobjectData : \%data;
        my $revision;
        if (scalar %$newData > 0) {
            $revision = $descendant->addRevision(
                { %$newData, tagId => $tag->getId, status => "pending" },
                undef,
                {skipAutoCommitWorkflows => 1, skipNotification => 1},
            );
            $revision->setVersionLock;
        }
        else {
            $revision = $descendant;
        }
        foreach my $param ($form->param) {
            if ($param =~ /^metadata_(.*)$/) {
                my $fieldName = $1;
                if ($form->yesNo("change_metadata_".$fieldName)) {
                    $revision->updateMetaData($fieldName,$form->process($form));
                }
            }
        }
    }
    $pb->update(sprintf $i18n->get('Attempting to commit changes'));
    if (WebGUI::VersionTag->autoCommitWorkingIfEnabled($self->session, {
        allowComments   => 1,
        returnUrl       => $self->getUrl,
    }) eq 'redirect') {
        return undef;
    };
    delete $self->{_parent};
    $self->session->asset($self->getParent);
    ##Since this method originally returned the user to the AssetManager, we don't need
    ##to use $pb->finish to redirect back there.
    return $self->getParent->www_manageAssets;
}



1;

