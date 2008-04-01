package WebGUI::Asset;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2008 Plain Black Corporation.
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

Package WebGUI::Asset

=head1 DESCRIPTION

This is a mixin package for WebGUI::Asset that contains all branch manipulation related functions.

=head1 SYNOPSIS

 use WebGUI::Asset;

=head1 METHODS

These methods are available from this class:

=cut



#-------------------------------------------------------------------

=head2 duplicateBranch ( )

Duplicates this asset and the entire subtree below it.  Returns the root of the new subtree.

=cut

sub duplicateBranch {
    my $self = shift;
    my $childrenOnly = shift || 0;

    my $newAsset = $self->duplicate({skipAutoCommitWorkflows=>1});
    my $contentPositions = $self->get("contentPositions");
    my $assetsToHide = $self->get("assetsToHide");

    foreach my $child (@{$self->getLineage(["children"],{returnObjects=>1})}) {
        my $newChild = $childrenOnly ? $child->duplicate({skipAutoCommitWorkflows=>1}) : $child->duplicateBranch;
        $newChild->setParent($newAsset);
        my ($oldChildId, $newChildId) = ($child->getId, $newChild->getId);
        $contentPositions =~ s/\Q${oldChildId}\E/${newChildId}/g if ($contentPositions);
        $assetsToHide =~ s/\Q${oldChildId}\E/${newChildId}/g if ($assetsToHide);
    }

    $newAsset->update({contentPositions=>$contentPositions}) if $contentPositions;
    $newAsset->update({assetsToHide=>$assetsToHide}) if $assetsToHide;
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
                -value=>$self->getValue("displayTitle"),
                -uiLevel=>5,
		-subtext=>'<br />'.$i18n->get("change").' '.WebGUI::Form::yesNo($self->session,{name=>"change_displayTitle"})
                );
         $tabform->getTab("display")->template(
		-name=>"styleTemplateId",
		-label=>$i18n2->get(1073),
		-value=>$self->getValue("styleTemplateId"),
		-hoverHelp=>$i18n2->get('1073 description'),
		-namespace=>'style',
		-afterEdit=>'op=editPage;npp='.$self->session->form->process("npp"),
		-subtext=>'<br />'.$i18n->get("change").' '.WebGUI::Form::yesNo($self->session,{name=>"change_styleTemplateId"})
		);
         $tabform->getTab("display")->template(
		-name=>"printableStyleTemplateId",
		-label=>$i18n2->get(1079),
		-hoverHelp=>$i18n2->get('1079 description'),
		-value=>$self->getValue("printableStyleTemplateId"),
		-namespace=>'style',
		-afterEdit=>'op=editPage;npp='.$self->session->form->process("npp"),
		-subtext=>'<br />'.$i18n->get("change").' '.WebGUI::Form::yesNo($self->session,{name=>"change_printableStyleTemplateId"})
		);
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
        if ($self->session->setting->get("metaDataEnabled")) {
                my $meta = $self->getMetaDataFields();
                foreach my $field (keys %$meta) {
                        my $fieldType = $meta->{$field}{fieldType} || "text";
                        my $options;
                        # Add a "Select..." option on top of a select list to prevent from
                        # saving the value on top of the list when no choice is made.
                        if($fieldType eq "selectList") {
                                $options = {"", $i18n->get("Select")};
                        }
                        $tabform->getTab("meta")->dynamicField(
                                 name=>"metadata_".$meta->{$field}{fieldId},
                                 label=>$meta->{$field}{fieldName},
                                 uiLevel=>5,
                                 value=>$meta->{$field}{value},
                                 extras=>qq/title="$meta->{$field}{description}"/,
                                 possibleValues=>$meta->{$field}{possibleValues},
                                 options=>$options,
				 subtext=>'<br />'.$i18n->get("change").' '.WebGUI::Form::yesNo($self->session,{name=>"change_metadata_".$meta->{$field}{fieldId}}),
				fieldType=>$fieldType
                                );
                }
        }	
	return $ac->render($tabform->print, $i18n->get('edit branch','Asset'));
}

#-------------------------------------------------------------------

=head2 www_editBranchSave ( )

Verifies proper inputs in the Asset Tree and saves them. Returns ManageAssets method. If canEdit returns False, returns an insufficient privilege page.

=cut

sub www_editBranchSave {
	my $self = shift;
	return $self->session->privilege->insufficient() unless ($self->canEdit && $self->session->user->isInGroup('4'));
	my %data;
	$data{isHidden} = $self->session->form->yesNo("isHidden") if ($self->session->form->yesNo("change_isHidden"));
	$data{newWindow} = $self->session->form->yesNo("newWindow") if ($self->session->form->yesNo("change_newWindow"));
	$data{encryptPage} = $self->session->form->yesNo("encryptPage") if ($self->session->form->yesNo("change_encryptPage"));
	$data{ownerUserId} = $self->session->form->selectBox("ownerUserId") if ($self->session->form->yesNo("change_ownerUserId"));
	$data{groupIdView} = $self->session->form->group("groupIdView") if ($self->session->form->yesNo("change_groupIdView"));
	$data{groupIdEdit} = $self->session->form->group("groupIdEdit") if ($self->session->form->yesNo("change_groupIdEdit"));
	$data{extraHeadTags} = $self->session->form->group("extraHeadTags") if ($self->session->form->yesNo("change_extraHeadTags"));
    my %wobjectData = %data;
    $wobjectData{displayTitle} = $self->session->form->yesNo("displayTitle")
        if ($self->session->form->yesNo("change_displayTitle"));
    $wobjectData{styleTemplateId} = $self->session->form->template("styleTemplateId")
        if ($self->session->form->yesNo("change_styleTemplateId"));
    $wobjectData{printableStyleTemplateId} = $self->session->form->template("printableStyleTemplateId")
        if ($self->session->form->yesNo("change_printableStyleTemplateId"));
	my ($urlBaseBy, $urlBase, $endOfUrl);
	my $changeUrl = $self->session->form->yesNo("change_url");
	if ($changeUrl) {
		$urlBaseBy = $self->session->form->selectBox("baseUrlBy");
		$urlBase = $self->session->form->text("baseUrl");
		$endOfUrl = $self->session->form->selectBox("endOfUrl");
	}
	my $descendants = $self->getLineage(["self","descendants"],{returnObjects=>1});	
	foreach my $descendant (@{$descendants}) {
		next unless $descendant->canEdit;
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
		}
        my $newData = $descendant->isa('WebGUI::Asset::Wobject') ? \%wobjectData : \%data;
        next
            if (scalar %$newData == 0);
        my $newRevision = $descendant->addRevision(
            $newData,
            undef,
            {skipAutoCommitWorkflows => 1, skipNotification => 1},
        );
		foreach my $form ($self->session->form->param) {
                	if ($form =~ /^metadata_(.*)$/) {
				my $fieldName = $1;
				if ($self->session->form->yesNo("change_metadata_".$fieldName)) {
                        		$newRevision->updateMetaData($fieldName,$self->session->form->process($form));
				}
                	}
        	}
	}
	if ($self->session->setting->get("autoRequestCommit")) {
        if ($self->session->setting->get("skipCommitComments")) {
            WebGUI::VersionTag->getWorking($self->session)->requestCommit;
        } else {
		    $self->session->http->setRedirect($self->getUrl("op=commitVersionTag;tagId=".WebGUI::VersionTag->getWorking($self->session)->getId));
            return undef;
        }
	}
	delete $self->{_parent};
	$self->session->asset($self->getParent);
	return $self->getParent->www_manageAssets;
}



1;

