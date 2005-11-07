package WebGUI::Asset::Shortcut;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Asset;
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;

our @ISA = qw(WebGUI::Asset);


#-------------------------------------------------------------------
sub definition {
        my $class = shift;
        my $definition = shift;
        push(@{$definition}, {
		assetName=>WebGUI::International::get('assetName',"Asset_Shortcut"),
		icon=>'shortcut.gif',
                tableName=>'Shortcut',
                className=>'WebGUI::Asset::Shortcut',
                properties=>{
                        shortcutToAssetId=>{
				noFormPost=>1,
				fieldType=>"hidden",
				defaultValue=>undef
				},
			overrideTitle=>{
				fieldType=>"yesNo",
				defaultValue=>0
				},
			overrideTemplate=>{
				fieldType=>"yesNo",
				defaultValue=>0
				},
			overrideDisplayTitle=>{
				fieldType=>"yesNo",
				defaultValue=>0
				},
			overrideDescription=>{
				fieldType=>"yesNo",
				defaultValue=>0
				},
			overrideTemplateId=>{
				fieldType=>"template",
				defaultValue=>undef
				},
			shortcutByCriteria=>{
				fieldType=>"yesNo",
				defaultValue=>0,
				},
			disableContentLock=>{
				fieldType=>"yesNo",
				defaultValue=>0
				},
			resolveMultiples=>{
				fieldType=>"selectList",
				defaultValue=>"mostRecent",
				},
			shortcutCriteria=>{
				fieldType=>"textarea",
				defaultValue=>"",
				},
			templateId=>{
				fieldType=>"template",
				defaultValue=>"PBtmpl0000000000000140"
				},
			description=>{
				fieldType=>"HTMLArea",
				defaultValue=>undef
				},
                        }
                });
        return $class->SUPER::definition($definition);
}



#-------------------------------------------------------------------
sub getEditForm {
	my $self = shift;
	my $tabform = $self->SUPER::getEditForm();
	my $originalTemplate;
	$tabform->getTab("properties")->HTMLArea(
		-value=>$self->getValue("description"),
                -label=>WebGUI::International::get(85, 'Asset_Shortcut'),
                -hoverHelp=>WebGUI::International::get('85 description', 'Asset_Shortcut'),
		-name=>"description"
		);
	$tabform->getTab("display")->template(
		-value=>$self->getValue("templateId"),
                -label=>WebGUI::International::get('shortcut template title', 'Asset_Shortcut'),
                -hoverHelp=>WebGUI::International::get('shortcut template title description', 'Asset_Shortcut'),
		-namespace=>"Shortcut"
		);
	if ($self->getShortcut->get("templateId")) {
		$originalTemplate = WebGUI::Asset::Template->new($self->getShortcut->get("templateId"));
		$originalTemplate = WebGUI::Asset::Template->new($self->getShortcut->get("collaborationTemplateId")) if (ref $self->getShortcut eq "WebGUI::Asset::Wobject::Collaboration");
		#Shortcuts of Posts and Threads and other assets without a "templateId" 
		# are going to be ->view'ed by their original parent's settings anyway.
		$tabform->getTab("display")->template(
			-name=>"overrideTemplateId",
			-value=>$self->getValue("overrideTemplateId") || $originalTemplate->getId,
        	        -label=>WebGUI::International::get('override asset template', 'Asset_Shortcut'),
               	 	-hoverHelp=>WebGUI::International::get('override asset template description', 'Asset_Shortcut'),
			-namespace=>$originalTemplate->get("namespace")
			);
		$tabform->getTab("display")->yesNo(
			-name=>"overrideTemplate",
			-value=>$self->getValue("overrideTemplate"),
			-label=>WebGUI::International::get(10,"Asset_Shortcut"),
			-hoverHelp=>WebGUI::International::get('10 description',"Asset_Shortcut")
			);
	}
	$tabform->getTab("properties")->yesNo(
		-name=>"overrideTitle",
		-value=>$self->getValue("overrideTitle"),
		-label=>WebGUI::International::get(7,"Asset_Shortcut"),
		-hoverHelp=>WebGUI::International::get('7 description',"Asset_Shortcut")
		);
	$tabform->getTab("display")->yesNo(
		-name=>"overrideDisplayTitle",
		-value=>$self->getValue("overrideDisplayTitle"),
		-label=>WebGUI::International::get(8,"Asset_Shortcut"),
		-hoverHelp=>WebGUI::International::get('8 description',"Asset_Shortcut")
		);
	$tabform->getTab("properties")->yesNo(
		-name=>"overrideDescription",
		-value=>$self->getValue("overrideDescription"),
		-label=>WebGUI::International::get(9,"Asset_Shortcut"),
		-hoverHelp=>WebGUI::International::get('9 description',"Asset_Shortcut")
		);
	$tabform->getTab("properties")->readOnly(
		-label=>WebGUI::International::get(1,"Asset_Shortcut"),
		-hoverHelp=>WebGUI::International::get('1 description',"Asset_Shortcut"),
		-value=>'<a href="'.$self->getShortcut->getUrl.'">'.$self->getShortcut->get('title').'</a> ('.$self->getShortcut->getId.')'
		);
	if($session{setting}{metaDataEnabled}) {
		$tabform->getTab("properties")->yesNo(
			-name=>"shortcutByCriteria",
			-value=>$self->getValue("shortcutByCriteria"),
			-label=>WebGUI::International::get("Shortcut by alternate criteria","Asset_Shortcut"),
			-hoverHelp=>WebGUI::International::get("Shortcut by alternate criteria description","Asset_Shortcut"),
			-extras=>q|Onchange="
				if (this.form.shortcutByCriteria[0].checked) { 
 					this.form.resolveMultiples.disabled=false;
					this.form.shortcutCriteria.disabled=false;
				} else {
 					this.form.resolveMultiples.disabled=true;
					this.form.shortcutCriteria.disabled=true;
				}"|
                );
		$tabform->getTab("properties")->yesNo(
			-name=>"disableContentLock",
			-value=>$self->getValue("disableContentLock"),
			-label=>WebGUI::International::get("disable content lock","Asset_Shortcut"),
			-hoverHelp=>WebGUI::International::get("disable content lock description","Asset_Shortcut")
			);
		if ($self->getValue("shortcutByCriteria") == 0) {
			$self->{_disabled} = 'disabled=true';
		}
		$tabform->getTab("properties")->selectList(
			-name=>"resolveMultiples",
			-value=>[ $self->getValue("resolveMultiples") ],
			-label=>WebGUI::International::get("Resolve Multiples","Asset_Shortcut"),
			-hoverHelp=>WebGUI::International::get("Resolve Multiples description","Asset_Shortcut"),
			-options=>{
				mostRecent=>WebGUI::International::get("Most Recent","Asset_Shortcut"),
				random=>WebGUI::International::get("Random","Asset_Shortcut"),
			},
			-extras=>$self->{_disabled}
		);

		 $tabform->getTab("properties")->readOnly(
        		-value=>$self->_drawQueryBuilder(),
		        -label=>WebGUI::International::get("Criteria","Asset_Shortcut"),
		        -hoverHelp=>WebGUI::International::get("Criteria description","Asset_Shortcut")
	        );
	}
	return $tabform;
}


#-------------------------------------------------------------------

=head2 getExtraHeadTags (  )

Returns the extraHeadTags stored in the asset.  Called in WebGUI::Style::generateAdditionalHeadTags if this asset is the $session{asset}.  Also called in WebGUI::Layout::view for its child assets.  Overriden here in Shortcut.pm.

=cut

sub getExtraHeadTags {
	my $self = shift;
	return $self->get("extraHeadTags")."\n".$self->getShortcut->get("extraHeadTags");
}


#-------------------------------------------------------------------
sub getShortcut {
	my $self = shift;
	unless ($self->{_shortcut}) {
		if ($self->get("shortcutByCriteria")) {
			$self->{_shortcut} = $self->getShortcutByCriteria;
		} else {
			$self->{_shortcut} = $self->getShortcutDefault;
		}
	}
	$self->{_shortcut}{_properties}{templateId} = $self->get("overrideTemplateId") if ($self->get("overrideTemplate"));
	$self->{_shortcut}{_properties}{collaborationTemplateId} = $self->get("overrideTemplateId") if ($self->get("overrideTemplate"));
	$self->{_shortcut}{_properties}{title} = $self->get("title") if ($self->get("overrideTitle"));
	$self->{_shortcut}{_properties}{description} = $self->get("description") if ($self->get("overrideDescription"));
	$self->{_shortcut}{_properties}{title} = $self->get("displayTitle") if ($self->get("overrideDisplayTitle"));
	return $self->{_shortcut};
}

#-------------------------------------------------------------------

=head2 getShortcutByCriteria ( hashRef )

This function will search for a asset that match a metadata criteria set.
If no asset is found, undef will be returned.

=cut

sub getShortcutByCriteria {
	my $self = shift;
	my $assetProxy = shift;
	my $criteria = $self->get("shortcutCriteria");
	my $order = $self->get("resolveMultiples");
	my $assetId = $self->getId;

	# Parse macro's in criteria
	WebGUI::Macro::process(\$criteria);

	# Once a asset is found, we will stick to that asset, 
	# to prevent the proxying of multiple- depth assets like Surveys and USS.
	my $scratchId;
	if ($assetId) {
		$scratchId = "Shortcut_" . $assetId;
		if($session{scratch}{$scratchId} && !$self->getValue("disableContentLock")) {
			return $session{scratch}{$scratchId} unless ($session{var}{adminOn});
		}
	}

	# $criteria = "State = Wisconsin AND Country != Sauk";
	#
	# State          =             Wisconsin AND Country != Sauk
	# |              |             |
	# |- $field      |_ $operator  |- $value
	# |_ $attribute                |_ $attribute
	my $operator = qr/<>|!=|=|>=|<=|>|<|like/i;
	my $attribute = qr/['"][^()|=><!]+['"]|[^()|=><!\s]+/i; 
                                                                                                      
	my $constraint = $criteria;
	
	# Get each expression from $criteria
	foreach my $expression ($criteria =~ /($attribute\s*$operator\s*$attribute)/gi) {
		# $expression will match "State = Wisconsin"

        	my $replacement = $expression;	# We don't want to modify $expression.
						# We need it later.

		# Get the field (State) and the value (Wisconsin) from the $expression.
	        $expression =~ /($attribute)\s*$operator\s*($attribute)/gi;
	        my $field = $1;
	        my $value = $2;

		# quote the field / value variables.
		my $quotedField = $field;
		my $quotedValue = $value;
		unless ($field =~ /^\s*['"].*['"]\s*/) {
			$quotedField = quote($field);
		}
                unless ($value =~ /^\s*['"].*['"]\s*/) {
                        $quotedValue = quote($value);
                }
		
		# transform replacement from "State = Wisconsin" to 
		# "(fieldname=State and value = Wisconsin)"
	        $replacement =~ s/\Q$field/(fieldname=$quotedField and value /;
	        $replacement =~ s/\Q$value/$quotedValue )/i;

		# replace $expression with the new $replacement in $constraint.
	        $constraint =~ s/\Q$expression/$replacement/;
	}
	my $sql =  "	select w.assetId 
			from metaData_values d, metaData_properties f, asset w 
			where f.fieldId = d.fieldId
				and w.assetId = d.assetId
				and w.className=".quote($self->getShortcutDefault->get("className"));

	
	# Add constraint only if it has been modified.
	$sql .= " and ".$constraint if (($constraint ne $criteria) && $constraint ne "");
# Can't do this without extensive refactoring.....!  
#	$sql .= " order by assetData.revisionDate desc";

	# Execute the query with an unconditional read
	my @ids;
        my $sth = WebGUI::SQL->unconditionalRead($sql);
        while (my ($data) = $sth->array) {
		push (@ids, $data);
        }
        $sth->finish;

	# No matching assets found.
        if (scalar(@ids) == 0) {
                return $self->getShortcutDefault; # fall back to the originally mirrored asset.
	}
	my $id;
	# Grab a wid from the results
	if ($order eq 'random') {
		$id = $ids[ rand @ids ];
	} else { 
				 #default order is mostRecent
		$id = $ids[0]; # 1st element in list is most recent.
	}

	# Store the matching assetId in user scratch. 
	WebGUI::Session::setScratch($scratchId,$id) if ($scratchId);

	return WebGUI::Asset->newByDynamicClass($id);		
}

#-------------------------------------------------------------------
sub getShortcutDefault {
	my $self = shift;
	return WebGUI::Asset->newByDynamicClass($self->get("shortcutToAssetId"));
}

#-------------------------------------------------------------------
sub processPropertiesFromFormPost {
	my $self = shift;
	$self->SUPER::processPropertiesFromFormPost;
	my $scratchId = "Shortcut_" . $self->getId;
	WebGUI::Session::deleteAllScratch($scratchId);
}

#-------------------------------------------------------------------
sub view {
	my $self = shift;
	my $content;
	if ($self->get("shortcutToAssetId") eq $self->get("parentId")) {
		$content = "Displaying this shortcut would cause a feedback loop.";
	} else {
		$content = $self->getShortcut->view;
	}
	my %var = (
		isShortcut => 1,
		'shortcut.content' => $content,
		'shortcut.label' => WebGUI::International::get('3',"Asset_Shortcut"),
		originalURL => $self->getShortcut->getUrl
		);
	return $self->processTemplate(\%var,$self->getValue("templateId"));
}


#-------------------------------------------------------------------
sub www_edit {
        my $self = shift;
        return WebGUI::Privilege::insufficient() unless $self->canEdit;
	$self->getAdminConsole->setHelp("shortcut add/edit","Asset_Shortcut");
        return $self->getAdminConsole->render($self->getEditForm->print,WebGUI::International::get(2,"Asset_Shortcut"));
}

#-------------------------------------------------------------------
sub _drawQueryBuilder {
	my $self = shift;
	# Initialize operators
	my @textFields = qw|text yesNo selectList radioList|;
	my %operator;
	foreach (@textFields) {
		$operator{$_} = {
				"=" => WebGUI::International::get("is","Asset_Shortcut"),
				"!=" => WebGUI::International::get("isnt","Asset_Shortcut")
			};
	}
	$operator{integer} = {
				"=" => WebGUI::International::get("equal to","Asset_Shortcut"),
                                "!=" => WebGUI::International::get("not equal to","Asset_Shortcut"),
				"<" => WebGUI::International::get("less than","Asset_Shortcut"),
				">" => WebGUI::International::get("greater than","Asset_Shortcut")
			};

	# Get the fields and count them	
	my $fields = $self->getMetaDataFields();
	my $fieldCount = scalar(keys %$fields);
	
	unless ($fieldCount) {	# No fields found....
		return 'No metadata defined yet.
			<a href="'.WebGUI::URL::page('op=manageMetaData').
			'">Click here</a> to define metadata attributes.';
	}

	# Static form fields
	my $shortcutCriteriaField = WebGUI::Form::textarea({
	                	        name=>"shortcutCriteria",
        	                	value=>$self->getValue("shortcutCriteria"),
					extras=>'style="width: 100%" '.$self->{_disabled}
                	        });
	my $conjunctionField = WebGUI::Form::selectList({
					name=>"conjunction",
					options=>{
						"AND" => WebGUI::International::get("AND","Asset_Shortcut"),
						"OR" => WebGUI::International::get("OR","Asset_Shortcut")},
					value=>["OR"],
					extras=>'class="qbselect"',
				});
	
	# html
	my $output;
	$output .= '<script type="text/javascript" src="'.
		$session{config}{extrasURL}.'/wobject/Shortcut/querybuilder.js"></script>';
	$output .= '<link href="'.$session{config}{extrasURL}.
			'/wobject/Shortcut/querybuilder.css" type="text/css" rel="stylesheet">';

	$output .= qq|<table cellspacing="0" cellpadding="0" border="0">
			  <tr>
			    <td colspan="5" align="right">$shortcutCriteriaField</td>
			  </tr>
			  <tr>
			    <td></td>
			    <td></td>
			    <td></td>
			    <td></td>
			    <td class="qbtdright">
			    </td>
			  </tr>
			  <tr>
			    <td></td>
			    <td></td>
			    <td></td>
			    <td></td>
			    <td class="qbtdright">
				$conjunctionField
			    </td>
			  </tr>
	|;

	# Here starts the field loop
	my $i = 1;
	foreach my $field (keys %$fields) {
		my $fieldLabel = $fields->{$field}{fieldName};
		my $fieldType = $fields->{$field}{fieldType} || "text";

		# The operator select field
		my $opFieldName = "op_field".$i;
		my $opField = WebGUI::Form::selectList({
						name=>$opFieldName,
						uiLevel=>5,
						options=>$operator{$fieldType},
						extras=>'class="qbselect"'
					});	
		# The value select field
		my $valFieldName = "val_field".$i;
		my $valueField = WebGUI::Form::dynamicField(
						fieldType=>$fieldType,
                                                name=>$valFieldName,
                                                uiLevel=>5,
                                                extras=>qq/title="$fields->{$field}{description}" class="qbselect"/,
                                                possibleValues=>$fields->{$field}{possibleValues},
					);
		# An empty row
		$output .= qq|
                          <tr>
                            <td></td>
                            <td></td>
                            <td></td>
                            <td></td>
                            <td class="qbtdright"></td>
                          </tr>
			|;
		
		# Table row with field info
		$output .= qq|
			  <tr>
			    <td class="qbtdleft"><p class="qbfieldLabel">$fieldLabel</p></td>
			    <td class="qbtd">
				$opField
			    </td>
			    <td class="qbtd">
				<span class="qbText">$valueField</span>
			    </td>
			    <td class="qbtd"></td>
			    <td class="qbtdright">
				<input class="qbButton" type=button value=Add onclick="addCriteria('$fieldLabel', this.form.$opFieldName, this.form.$valFieldName)"></td>
			  </tr>
			|;
		$i++;
	}
	# Close the table
	$output .= "</table>";

	return $output;
}

#-------------------------------------------------------------------
sub www_view {
	my $self = shift;
	return $self->getShortcut->www_view;
}


1;



