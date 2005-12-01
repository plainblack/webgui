package WebGUI::Asset;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2005 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use WebGUI::Session;

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

=head2 duplicateBranch ( [assetToDuplicate] )

Duplicates an asset and all its descendants. Calls addChild with assetToDuplicate as an argument. Returns a new Asset object.

=head3 assetToDuplicate

The asset to duplicate. Defaults to self.

=cut

sub duplicateBranch {
	my $self = shift;
	my $assetToDuplicate = shift || $self;
	my $newAsset = $self->duplicate($assetToDuplicate);
	my $contentPositions;
	$contentPositions = $assetToDuplicate->get("contentPositions");
	foreach my $child (@{$assetToDuplicate->getLineage(["children"],{returnObjects=>1})}) {
		my $newChild = $newAsset->duplicateBranch($child);
		if ($contentPositions) {
			my $newChildId = $newChild->getId;
			my $oldChildId = $child->getId;
			$contentPositions =~ s/${oldChildId}/${newChildId}/g;
		}
	}
	$newAsset->update({contentPositions=>$contentPositions}) if $contentPositions;
	return $newAsset;
}


#-------------------------------------------------------------------

=head2 purgeBranch ( )

Returns 1. Purges self and all descendants.

=cut

sub purgeBranch {
	my $self = shift;
	my $descendants = $self->getLineage(["self","descendants"],{returnObjects=>1, invertTree=>1, statesToInclude=>['trash','trash-limbo']});
	foreach my $descendant (@{$descendants}) {
		$descendant->purge;
	}
	return 1;
}


#-------------------------------------------------------------------

=head2 www_editBranch ( )

Creates a tabform to edit the Asset Tree. If canEdit returns False, returns insufficient Privilege page. 

=cut

sub www_editBranch {
	my $self = shift;
	my $ac = WebGUI::AdminConsole->new("assets");
	return WebGUI::Privilege::insufficient() unless ($self->canEdit);
	my $tabform = WebGUI::TabForm->new;
	$tabform->hidden({name=>"func",value=>"editBranchSave"});
	$tabform->addTab("properties",WebGUI::International::get("properties","Asset"),9);
        $tabform->getTab("properties")->readOnly(
                -label=>WebGUI::International::get(104,"Asset"),
                -uiLevel=>9,
		-subtext=>'<br />'.WebGUI::International::get("change","Asset").' '.WebGUI::Form::yesNo({name=>"change_url"}),
		-value=>WebGUI::Form::selectBox({
                	name=>"baseUrlBy",
			extras=>'onchange="toggleSpecificBaseUrl()"',
			id=>"baseUrlBy",
			options=>{
				parentUrl=>"Parent URL",
				specifiedBase=>"Specified Base",
				none=>"None"
				}
			}).'<span id="baseUrl"></span> / '.WebGUI::Form::selectBox({
				name=>"endOfUrl",
				options=>{
					menuTitle=>WebGUI::International::get(411,"Asset"),
					title=>WebGUI::International::get(99,"Asset"),
					currentUrl=>"Current URL"
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
	$tabform->addTab("display",WebGUI::International::get(105,"Asset"),5);
	$tabform->getTab("display")->yesNo(
                -name=>"isHidden",
                -value=>$self->get("isHidden"),
                -label=>WebGUI::International::get(886,"Asset"),
                -uiLevel=>6,
		-subtext=>'<br />'.WebGUI::International::get("change","Asset").' '.WebGUI::Form::yesNo({name=>"change_isHidden"})
                );
        $tabform->getTab("display")->yesNo(
                -name=>"newWindow",
                -value=>$self->get("newWindow"),
                -label=>WebGUI::International::get(940,"Asset"),
                -uiLevel=>6,
		-subtext=>'<br />'.WebGUI::International::get("change","Asset").' '.WebGUI::Form::yesNo({name=>"change_newWindow"})
                );
	$tabform->getTab("display")->yesNo(
                -name=>"displayTitle",
                -label=>WebGUI::International::get(174,"Asset"),
                -value=>$self->getValue("displayTitle"),
                -uiLevel=>5,
		-subtext=>'<br />'.WebGUI::International::get("change","Asset").' '.WebGUI::Form::yesNo({name=>"change_displayTitle"})
                );
         $tabform->getTab("display")->template(
		-name=>"styleTemplateId",
		-label=>WebGUI::International::get(1073,"Asset"),
		-value=>$self->getValue("styleTemplateId"),
		-namespace=>'style',
		-afterEdit=>'op=editPage;npp='.$session{form}{npp},
		-subtext=>'<br />'.WebGUI::International::get("change","Asset").' '.WebGUI::Form::yesNo({name=>"change_styleTemplateId"})
		);
         $tabform->getTab("display")->template(
		-name=>"printableStyleTemplateId",
		-label=>WebGUI::International::get(1079,"Asset"),
		-value=>$self->getValue("printableStyleTemplateId"),
		-namespace=>'style',
		-afterEdit=>'op=editPage;npp='.$session{form}{npp},
		-subtext=>'<br />'.WebGUI::International::get("change","Asset").' '.WebGUI::Form::yesNo({name=>"change_printableStyleTemplateId"})
		);
        $tabform->getTab("display")->interval(
                -name=>"cacheTimeout",
                -label=>WebGUI::International::get(895,"Asset"),
                -value=>$self->getValue("cacheTimeout"),
                -uiLevel=>8,
		-subtext=>'<br />'.WebGUI::International::get("change","Asset").' '.WebGUI::Form::yesNo({name=>"change_cacheTimeout"})
                );
        $tabform->getTab("display")->interval(
                -name=>"cacheTimeoutVisitor",
                -label=>WebGUI::International::get(896,"Asset"),
                -value=>$self->getValue("cacheTimeoutVisitor"),
                -uiLevel=>8,
		-subtext=>'<br />'.WebGUI::International::get("change","Asset").' '.WebGUI::Form::yesNo({name=>"change_cacheTimeoutVisitor"})
                );
	$tabform->addTab("security",WebGUI::International::get(107,"Asset"),6);
        $tabform->getTab("security")->yesNo(
                -name=>"encryptPage",
                -value=>$self->get("encryptPage"),
                -label=>WebGUI::International::get('encrypt page',"Asset"),
                -uiLevel=>6,
		-subtext=>'<br />'.WebGUI::International::get("change","Asset").' '.WebGUI::Form::yesNo({name=>"change_encryptPage"})
                );
	$tabform->getTab("security")->dateTime(
                -name=>"startDate",
                -label=>WebGUI::International::get(497,"Asset"),
                -value=>$self->get("startDate"),
                -uiLevel=>6,
		-subtext=>'<br />'.WebGUI::International::get("change","Asset").' '.WebGUI::Form::yesNo({name=>"change_startDate"})
                );
        $tabform->getTab("security")->dateTime(
                -name=>"endDate",
                -label=>WebGUI::International::get(498,"Asset"),
                -value=>$self->get("endDate"),
                -uiLevel=>6,
		-subtext=>'<br />'.WebGUI::International::get("change","Asset").' '.WebGUI::Form::yesNo({name=>"change_endDate"})
                );
	my $subtext;
        if (WebGUI::Grouping::isInGroup(3)) {
                 $subtext = manageIcon('op=listUsers');
        } else {
                 $subtext = "";
        }
        my $clause;
        if (WebGUI::Grouping::isInGroup(3)) {
                my $contentManagers = WebGUI::Grouping::getUsersInGroup(4,1);
                push (@$contentManagers, $session{user}{userId});
                $clause = "userId in (".quoteAndJoin($contentManagers).")";
        } else {
                $clause = "userId=".quote($self->get("ownerUserId"));
        }
        my $users = WebGUI::SQL->buildHashRef("select userId,username from users where $clause order by username");
        $tabform->getTab("security")->selectBox(
               -name=>"ownerUserId",
               -options=>$users,
               -label=>WebGUI::International::get(108,"Asset"),
               -value=>[$self->get("ownerUserId")],
               -subtext=>$subtext,
               -uiLevel=>6,
		-subtext=>'<br />'.WebGUI::International::get("change","Asset").' '.WebGUI::Form::yesNo({name=>"change_ownerUserId"})
               );
        $tabform->getTab("security")->group(
               -name=>"groupIdView",
               -label=>WebGUI::International::get(872,"Asset"),
               -value=>[$self->get("groupIdView")],
               -uiLevel=>6,
		-subtext=>'<br />'.WebGUI::International::get("change","Asset").' '.WebGUI::Form::yesNo({name=>"change_groupIdView"})
               );
        $tabform->getTab("security")->group(
               -name=>"groupIdEdit",
               -label=>WebGUI::International::get(871,"Asset"),
               -value=>[$self->get("groupIdEdit")],
               -excludeGroups=>[1,7],
               -uiLevel=>6,
		-subtext=>'<br />'.WebGUI::International::get("change","Asset").' '.WebGUI::Form::yesNo({name=>"change_groupIdEdit"})
		);
        $tabform->addTab("meta",WebGUI::International::get("Metadata","Asset"),3);
        $tabform->getTab("meta")->textarea(
                -name=>"extraHeadTags",
                -label=>WebGUI::International::get("extra head tags","Asset"),
                -hoverHelp=>WebGUI::International::get('extra head tags description',"Asset"),
                -value=>$self->get("extraHeadTags"),
                -uiLevel=>5,
		-subtext=>'<br />'.WebGUI::International::get("change","Asset").' '.WebGUI::Form::yesNo({name=>"change_extraHeadTags"})
                );
        if ($session{setting}{metaDataEnabled}) {
                my $meta = $self->getMetaDataFields();
                foreach my $field (keys %$meta) {
                        my $fieldType = $meta->{$field}{fieldType} || "text";
                        my $options;
                        # Add a "Select..." option on top of a select list to prevent from
                        # saving the value on top of the list when no choice is made.
                        if($fieldType eq "selectList") {
                                $options = {"", WebGUI::International::get("Select","Asset")};
                        }
                        $tabform->getTab("meta")->dynamicField(
                                 name=>"metadata_".$meta->{$field}{fieldId},
                                 label=>$meta->{$field}{fieldName},
                                 uiLevel=>5,
                                 value=>$meta->{$field}{value},
                                 extras=>qq/title="$meta->{$field}{description}"/,
                                 possibleValues=>$meta->{$field}{possibleValues},
                                 options=>$options,
				 subtext=>'<br />'.WebGUI::International::get("change","Asset").' '.WebGUI::Form::yesNo({name=>"change_metadata_".$meta->{$field}{fieldId}}),
				fieldType=>$fieldType
                                );
                }
        }	
	return $ac->render($tabform->print, "Edit Branch");
}

#-------------------------------------------------------------------

=head2 www_editBranchSave ( )

Verifies proper inputs in the Asset Tree and saves them. Returns ManageAssets method. If canEdit returns False, returns an insufficient privilege page.

=cut

sub www_editBranchSave {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless ($self->canEdit);
	my %data;
	$data{isHidden} = WebGUI::FormProcessor::yesNo("isHidden") if (WebGUI::FormProcessor::yesNo("change_isHidden"));
	$data{newWindow} = WebGUI::FormProcessor::yesNo("newWindow") if (WebGUI::FormProcessor::yesNo("change_newWindow"));
	$data{displayTitle} = WebGUI::FormProcessor::yesNo("displayTitle") if (WebGUI::FormProcessor::yesNo("change_displayTitle"));
	$data{styleTemplateId} = WebGUI::FormProcessor::template("styleTemplateId") if (WebGUI::FormProcessor::yesNo("change_styleTemplateId"));
	$data{printableStyleTemplateId} = WebGUI::FormProcessor::template("printableStyleTemplateId") if (WebGUI::FormProcessor::yesNo("change_printableStyleTemplateId"));
	$data{cacheTimeout} = WebGUI::FormProcessor::interval("cacheTimeout") if (WebGUI::FormProcessor::yesNo("change_cacheTimeout"));
	$data{cacheTimeoutVisitor} = WebGUI::FormProcessor::interval("cacheTimeoutVisitor") if (WebGUI::FormProcessor::yesNo("change_cacheTimeoutVisitor"));
	$data{encryptPage} = WebGUI::FormProcessor::yesNo("encryptPage") if (WebGUI::FormProcessor::yesNo("change_encryptPage"));
	$data{startDate} = WebGUI::FormProcessor::dateTime("startDate") if (WebGUI::FormProcessor::yesNo("change_startDate"));
	$data{endDate} = WebGUI::FormProcessor::dateTime("endDate") if (WebGUI::FormProcessor::yesNo("change_endDate"));
	$data{ownerUserId} = WebGUI::FormProcessor::selectBox("ownerUserId") if (WebGUI::FormProcessor::yesNo("change_ownerUserId"));
	$data{groupIdView} = WebGUI::FormProcessor::group("groupIdView") if (WebGUI::FormProcessor::yesNo("change_groupIdView"));
	$data{groupIdEdit} = WebGUI::FormProcessor::group("groupIdEdit") if (WebGUI::FormProcessor::yesNo("change_groupIdEdit"));
	$data{extraHeadTags} = WebGUI::FormProcessor::group("extraHeadTags") if (WebGUI::FormProcessor::yesNo("change_extraHeadTags"));
	my ($urlBaseBy, $urlBase, $endOfUrl);
	my $changeUrl = WebGUI::FormProcessor::yesNo("change_url");
	if ($changeUrl) {
		$urlBaseBy = WebGUI::FormProcessor::selectBox("baseUrlBy");
		$urlBase = WebGUI::FormProcessor::text("baseUrl");
		$endOfUrl = WebGUI::FormProcessor::selectBox("endOfUrl");
	}
	my $descendants = $self->getLineage(["self","descendants"],{returnObjects=>1});	
	foreach my $descendant (@{$descendants}) {
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
		my $newRevision = $descendant->addRevision(\%data);
		foreach my $form (keys %{$session{form}}) {
                	if ($form =~ /^metadata_(.*)$/) {
				my $fieldName = $1;
				if (WebGUI::FormProcessor::yesNo("change_metadata_".$fieldName)) {
                        		$newRevision->updateMetaData($fieldName,$session{form}{$form});
				}
                	}
        	}
	}
	delete $self->{_parent};
	$session{asset} = $self->getParent;
	return $self->getParent->www_manageAssets;
}



1;

