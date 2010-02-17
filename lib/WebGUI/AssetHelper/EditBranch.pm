package WebGUI::AssetHelper::EditBranch;

use strict;
use Class::C3;
use base qw/WebGUI::AssetHelper/;
use WebGUI::User;
use WebGUI::HTML;

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

=head1 NAME

Package WebGUI::AssetHelper::EditBranch

=head1 DESCRIPTION

Displays the revisions for this asset.

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 process ( $class, $asset )

Opens a new tab for displaying the form and the output for editing a branch.

=cut

sub process {
    my ($class, $asset) = @_;
    my $session = $asset->session;
    my $i18n = WebGUI::International->new($session, "Asset");
    if (! $asset->canEdit) {
        return {
            error => $i18n->get('38', 'WebGUI'),
        }
    }

    return {
        open_tab => $asset->getUrl('op=assetHelper;className=WebGUI::AssetHelper::EditBranch;func=editBranch'),
    };
}

#-------------------------------------------------------------------

=head2 www_editBranch ( )

Creates a tabform to edit the Asset Tree. If canEdit returns False, returns insufficient Privilege page. 

=cut

sub www_editBranch {
    my ($class, $asset) = @_;
    my $session = $asset->session;
	my $ac      = WebGUI::AdminConsole->new($session,"assets");
	my $i18n    = WebGUI::International->new($session,"Asset");
	my $i18n2   = WebGUI::International->new($session,"Asset_Wobject");
	return $session->privilege->insufficient() unless ($asset->canEdit);
    my $change = '<br />'.$i18n->get("change") . ' ';
	my $tabform = WebGUI::TabForm->new($session);
	$tabform->hidden({name=>"func",value=>"editBranchSave"});
	$tabform->addTab("properties",$i18n->get("properties"),9);
    $tabform->getTab("properties")->readOnly(
                label    => $i18n->get(104),
                hoverHelp=> $i18n->get('edit branch url help'),
                uiLevel  => 9,
                subtext  => $change . WebGUI::Form::yesNo($session,{name=>"change_url"}),
                value    => WebGUI::Form::selectBox($session, {
                                name    => "baseUrlBy",
                                extras  => 'onchange="toggleSpecificBaseUrl()"',
                                id      => "baseUrlBy",
                                options => {
                                    parentUrl     => $i18n->get("parent url"),
                                    specifiedBase => $i18n->get("specified base"),
                                    none          => $i18n->get("none"),
                                },
                            })
                          . '<span id="baseUrl"></span> / '
                          . WebGUI::Form::selectBox($session, {
                                name    => "endOfUrl",
                                options => {
                                    menuTitle  => $i18n->get(411),
                                    title      => $i18n->get(99),
                                    currentUrl => $i18n->get("current url"),
                                }
                            })
                          . q!<script type="text/javascript">
			function toggleSpecificBaseUrl () {
				if (document.getElementById('baseUrlBy').options[document.getElementById('baseUrlBy').selectedIndex].value == 'specifiedBase') {
					document.getElementById('baseUrl').innerHTML='<input type="text" name="baseUrl" />';
				} else {
					document.getElementById('baseUrl').innerHTML='';
				}
			}
			toggleSpecificBaseUrl();
				</script>!
    );
	$tabform->addTab("display",$i18n->get(105),5);
	$tabform->getTab("display")->yesNo(
                name      => "isHidden",
                value     => $asset->get("isHidden"),
                label     => $i18n->get(886),
                uiLevel   => 6,
                subtext   => $change . WebGUI::Form::yesNo($session,{name=>"change_isHidden"}),
                hoverHelp => $i18n->get('886 description',"Asset"),
    );
    $tabform->getTab("display")->yesNo(
        name     => "newWindow",
        value    => $asset->get("newWindow"),
        label    => $i18n->get(940),
		hoverHelp=> $i18n->get('940 description'),
        uiLevel  => 6,
		subtext  => $change . WebGUI::Form::yesNo($session,{name=>"change_newWindow"}),
    );
	$tabform->getTab("display")->yesNo(
        name     => "displayTitle",
        label    => $i18n2->get(174),
		hoverHelp=> $i18n2->get('174 description'),
        value    => $asset->getValue("displayTitle"),
        uiLevel  => 5,
		subtext  => $change . WebGUI::Form::yesNo($session,{name=>"change_displayTitle"})
    );
     $tabform->getTab("display")->template(
		name      => "styleTemplateId",
		label     => $i18n2->get(1073),
		value     => $asset->getValue("styleTemplateId"),
		hoverHelp => $i18n2->get('1073 description'),
		namespace => 'style',
		subtext   => $change  . WebGUI::Form::yesNo($session,{name=>"change_styleTemplateId"})
    );
    $tabform->getTab("display")->template(
		name      => "printableStyleTemplateId",
		label     => $i18n2->get(1079),
		hoverHelp => $i18n2->get('1079 description'),
		value     => $asset->getValue("printableStyleTemplateId"),
		namespace => 'style',
		subtext   => $change  . WebGUI::Form::yesNo($session,{name=>"change_printableStyleTemplateId"})
    );
    if ( $session->setting->get('useMobileStyle') ) {
        $tabform->getTab("display")->template(
            name        => 'mobileStyleTemplateId',
            label       => $i18n2->get('mobileStyleTemplateId label'),
            hoverHelp   => $i18n2->get('mobileStyleTemplateId description'),
            value       => $asset->getValue('mobileStyleTemplateId'),
            namespace   => 'style',
            subtext     => $change . WebGUI::Form::yesNo($session,{name=>"change_mobileStyleTemplateId"}),
        );
    }
	$tabform->addTab("security",$i18n->get(107),6);
    if ($session->config->get("sslEnabled")) {
        $tabform->getTab("security")->yesNo(
            name      => "encryptPage",
            value     => $asset->get("encryptPage"),
            label     => $i18n->get('encrypt page'),
            hoverHelp => $i18n->get('encrypt page description',"Asset"),
            uiLevel   => 6,
            subtext   => $change . WebGUI::Form::yesNo($session,{name=>"change_encryptPage"})
        );
    }
    $tabform->getTab("security")->user(
        name      => "ownerUserId",
        label     => $i18n->get(108),
        hoverHelp => $i18n->get('108 description',"Asset"),
        value     => $asset->get("ownerUserId"),
        uiLevel   => 6,
        subtext   => $change . WebGUI::Form::yesNo($session,{name=>"change_ownerUserId"})
    );
    $tabform->getTab("security")->group(
        name      => "groupIdView",
        label     => $i18n->get(872),
        hoverHelp => $i18n->get('872 description',"Asset"),
        value     => [$asset->get("groupIdView")],
        uiLevel   => 6,
        subtext   => $change . WebGUI::Form::yesNo($session,{name=>"change_groupIdView"})
    );
    $tabform->getTab("security")->group(
        name          => "groupIdEdit",
        label         => $i18n->get(871),
        hoverHelp     => $i18n->get('871 description',"Asset"),
        value         => [$asset->get("groupIdEdit")],
        excludeGroups => [1,7],
        uiLevel       => 6,
        subtext       => $change . WebGUI::Form::yesNo($session,{name=>"change_groupIdEdit"})
    );
    $tabform->addTab("meta",$i18n->get("Metadata"),3);
    $tabform->getTab("meta")->textarea(
        name      => "extraHeadTags",
        label     => $i18n->get("extra head tags"),
        hoverHelp => $i18n->get('extra head tags description'),
        value     => $asset->get("extraHeadTags"),
        uiLevel   => 5,
        subtext   => $change . WebGUI::Form::yesNo($session,{name=>"change_extraHeadTags"})
    );


    $tabform->getTab("meta")->yesNo(
        name         => 'usePackedHeadTags',
        label        => $i18n->get('usePackedHeadTags label'),
        hoverHelp    => $i18n->get('usePackedHeadTags description'),
        uiLevel      => 7,
        fieldType    => 'yesNo',
        defaultValue => 0,
        subtext      => $change . WebGUI::Form::yesNo( $session, { name => "change_usePackedHeadTags" } ),
    );
    $tabform->getTab("meta")->yesNo(
        name         => 'isPackage',
        label        => $i18n->get("make package"),
        hoverHelp    => $i18n->get('make package description'),
        uiLevel      => 7,
        fieldType    => 'yesNo',
        defaultValue => 0,
        subtext      => $change . WebGUI::Form::yesNo( $session, { name => "change_isPackage" } ),
    );
    $tabform->getTab("meta")->yesNo(
        name         => 'isPrototype',
        label        => $i18n->get("make prototype"),
        hoverHelp    => $i18n->get('make prototype description'),
        uiLevel      => 9,
        fieldType    => 'yesNo',
        defaultValue => 0,
        subtext      => $change . WebGUI::Form::yesNo( $session, { name => "change_isPrototype" } ),
    );
    $tabform->getTab("meta")->yesNo(
        name         => 'isExportable',
        label        => $i18n->get('make asset exportable'),
        hoverHelp    => $i18n->get('make asset exportable description'),
        uiLevel      => 9,
        fieldType    => 'yesNo',
        defaultValue => 1,
        subtext      => $change . WebGUI::Form::yesNo( $session, { name => "change_isExportable" } ),
    );
    $tabform->getTab("meta")->yesNo(
        name         => 'inheritUrlFromParent',
        label        => $i18n->get('does asset inherit URL from parent'),
        hoverHelp    => $i18n->get('does asset inherit URL from parent description'),
        uiLevel      => 9,
        fieldType    => 'yesNo',
        defaultValue => 0,
        subtext      => $change . WebGUI::Form::yesNo( $session, { name => "change_inheritUrlFromParent" } ),
    );

    if ($session->setting->get("metaDataEnabled")) {
            my $meta = $asset->getMetaDataFields();
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
                    subtext         => $change . WebGUI::Form::yesNo($session,{name=>"change_metadata_".$meta->{$field}{fieldId}}),
                );
            }
    }	
	return $tabform->print;
}

#-------------------------------------------------------------------

=head2 www_editBranchSaveStatus ( )

Verifies proper inputs in the Asset Tree and saves them. Returns ManageAssets method. If canEdit returns False, returns an insufficient privilege page.

=cut

sub www_editBranchSave {
    my ($class, $asset) = @_;
    my $session = $asset->session;
    return $session->privilege->insufficient() unless ($asset->canEdit && $session->user->isInGroup('4'));
    my $form    = $session->form;
    my %data;
    my $pb      = WebGUI::ProgressBar->new($session);
    my $i18n    = WebGUI::International->new($session, 'Asset');
    $data{isHidden}      = $form->yesNo("isHidden")         if ($form->yesNo("change_isHidden"));
    $data{newWindow}     = $form->yesNo("newWindow")        if ($form->yesNo("change_newWindow"));
    $data{encryptPage}   = $form->yesNo("encryptPage")      if ($form->yesNo("change_encryptPage"));
    $data{ownerUserId}   = $form->selectBox("ownerUserId")  if ($form->yesNo("change_ownerUserId"));
    $data{groupIdView}   = $form->group("groupIdView")      if ($form->yesNo("change_groupIdView"));
    $data{groupIdEdit}   = $form->group("groupIdEdit")      if ($form->yesNo("change_groupIdEdit"));
    $data{extraHeadTags} = $form->textarea("extraHeadTags") if $form->yesNo("change_extraHeadTags");
    $data{usePackedHeadTags}    = $form->yesNo("usePackedHeadTags")    if $form->yesNo("change_usePackedHeadTags");
    $data{isPackage}            = $form->yesNo("isPackage")            if $form->yesNo("change_isPackage");
    $data{isPrototype}          = $form->yesNo("isPrototype")          if $form->yesNo("change_isPrototype");
    $data{isExportable}         = $form->yesNo("isExportable")         if $form->yesNo("change_isExportable");
    $data{inheritUrlFromParent} = $form->yesNo("inheritUrlFromParent") if $form->yesNo("change_inheritUrlFromParent");

    my %wobjectData = %data;
    $wobjectData{displayTitle}             = $form->yesNo("displayTitle")                if $form->yesNo("change_displayTitle");
    $wobjectData{styleTemplateId}          = $form->template("styleTemplateId")          if $form->yesNo("change_styleTemplateId");
    $wobjectData{printableStyleTemplateId} = $form->template("printableStyleTemplateId") if $form->yesNo("change_printableStyleTemplateId");
    $wobjectData{mobileStyleTemplateId}    = $form->template("mobileStyleTemplateId")    if $form->yesNo("change_mobileStyleTemplateId");

    my ($urlBaseBy, $urlBase, $endOfUrl);
    my $changeUrl  = $form->yesNo("change_url");
    if ($changeUrl) {
        $urlBaseBy = $form->selectBox("baseUrlBy");
        $urlBase   = $form->text("baseUrl");
        $endOfUrl  = $form->selectBox("endOfUrl");
    }
    $pb->start($i18n->get('edit branch'), $session->url->extras('adminConsole/assets.gif'));
    my $descendants = $asset->getLineage(["self","descendants"],{returnObjects=>1});	
    DESCENDANT: foreach my $descendant (@{$descendants}) {
        if ( !$descendant->canEdit ) {
            $pb->update(sprintf $i18n->get('skipping %s'), $descendant->getTitle);
            next DESCENDANT;
        }
        $pb->update(sprintf $i18n->get('editing %s'), $descendant->getTitle);
        my $url;
        if ($changeUrl) {
            if ($urlBaseBy eq "parentUrl") {
                delete $descendant->{_parent};
                $data{url} = $descendant->getParent->get("url")."/";
            }
            elsif ($urlBaseBy eq "specifiedBase") {
                $data{url} = $urlBase."/";
            }
            else {
                $data{url} = "";
            }
            if ($endOfUrl eq "menuTitle") {
                $data{url} .= $descendant->get("menuTitle");
            }
            elsif ($endOfUrl eq "title") {
                $data{url} .= $descendant->get("title");
            }
            else {
                $data{url} .= $descendant->get("url");
            }
            $wobjectData{url} = $data{url};
        }
        my $newData = $descendant->isa('WebGUI::Asset::Wobject') ? \%wobjectData : \%data;
        my $revision;
        if (scalar %$newData > 0) {
            $revision = $descendant->addRevision(
                $newData,
                undef,
                {skipAutoCommitWorkflows => 1, skipNotification => 1},
            );
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
    if (WebGUI::VersionTag->autoCommitWorkingIfEnabled($session, {
        allowComments   => 1,
        returnUrl       => $asset->getUrl,
    }) eq 'redirect') {
        return undef;
    };
    delete $asset->{_parent};
    $session->asset($asset->getParent);
    ##Since this method originally returned the user to the AssetManager, we don't need
    ##to use $pb->finish to redirect back there.
    return $asset->getParent->www_manageAssets;
}


1;
