package WebGUI::Asset::Shortcut;

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
use WebGUI::Asset;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Operation::Profile;
use WebGUI::ProfileField;
use WebGUI::ProfileCategory;
use WebGUI::Macro;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;

our @ISA = qw(WebGUI::Asset);

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
		<a href="'.$self->session->url->page('func=manageMetaData').
		'">Click here</a> to define metadata attributes.';
	}

	# Static form fields
	my $shortcutCriteriaField = WebGUI::Form::textarea({
		name=>"shortcutCriteria",
		value=>$self->getValue("shortcutCriteria"),
		extras=>'style="width: 100%" '.$self->{_disabled}
	});
	my $conjunctionField = WebGUI::Form::selectBox({
		name=>"conjunction",
		options=>{
			"AND" => WebGUI::International::get("AND","Asset_Shortcut"),
			"OR" => WebGUI::International::get("OR","Asset_Shortcut")},
			value=>["OR"],
			extras=>'class="qbselect"',
		}
	);

	# html
	my $output;
	$output .= '<script type="text/javascript" src="'.
	$self->session->config->get("extrasURL").'/wobject/Shortcut/querybuilder.js"></script>';
	$output .= '<link href="'.$self->session->config->get("extrasURL").
	'/wobject/Shortcut/querybuilder.css" type="text/css" rel="stylesheet">';
	$output .= qq|<table cellspacing="0" cellpadding="0" border="0"><tr><td colspan="5" align="right">$shortcutCriteriaField</td></tr><tr><td></td><td></td><td></td><td></td><td class="qbtdright"></td></tr><tr><td></td><td></td><td></td><td></td><td class="qbtdright">$conjunctionField</td></tr>|;

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
		$output .= qq|<tr><td></td><td></td><td></td><td></td><td class="qbtdright"></td></tr>|;

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
sub _submenu {
	my $self = shift;
	my $workarea = shift;
	my $title = shift;
	my $help = shift;
	my $ac = WebGUI::AdminConsole->new($self->session,"shortcutmanager");
	$ac->setHelp($help) if ($help);
	$ac->setIcon($self->getIcon);
	$ac->addSubmenuItem($self->getUrl('func=edit'), WebGUI::International::get("Back to Edit Shortcut","Asset_Shortcut"));
	$ac->addSubmenuItem($self->getUrl("func=manageOverrides"),WebGUI::International::get("Manage Shortcut Overrides","Asset_Shortcut"));
	return $ac->render($workarea, $title);
}

#-------------------------------------------------------------------
sub canEdit {
	my $self = shift;
return 1 if ($self->SUPER::canEdit || ($self->isDashlet && $self->getParent->canManage));
	return 0;
}

#-------------------------------------------------------------------
sub canManage {
	my $self = shift;
	return $self->canEdit;
}

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
			shortcutByCriteria=>{
				fieldType=>"yesNo",
				defaultValue=>0,
			},
			disableContentLock=>{
				fieldType=>"yesNo",
				defaultValue=>0
			},
			resolveMultiples=>{
				fieldType=>"selectBox",
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
			prefFieldsToShow=>{
				fieldType=>"checkList",
				defaultValue=>undef
			},
			prefFieldsToImport=>{
				fieldType=>"checkList",
				defaultValue=>undef
			},
			showReloadIcon=>{
				fieldType=>"yesNo",
				defaultValue=>1
			}
		}
	});
	return $class->SUPER::definition($definition);
}

#-------------------------------------------------------------------
sub discernUserId {
	my $self = shift;
	return ($self->canManage && WebGUI::Session::isAdminOn()) ? '1' : $self->session->user->profileField("userId");
}

#-------------------------------------------------------------------
sub getEditForm {
	my $self = shift;
	my $tabform = $self->SUPER::getEditForm();
	my $originalTemplate;
	my $i18n = WebGUI::International->new("Asset_Shortcut");
	$tabform->getTab("properties")->readOnly(
		-label=>WebGUI::International::get(1,"Asset_Shortcut"),
		-hoverHelp=>WebGUI::International::get('1 description',"Asset_Shortcut"),
		-value=>'<a href="'.$self->getShortcut->getUrl.'">'.$self->getShortcut->get('title').'</a> ('.$self->getShortcut->getId.')'
		);
	$tabform->getTab("display")->template(
		-value=>$self->getValue("templateId"),
		-label=>WebGUI::International::get('shortcut template title', 'Asset_Shortcut'),
		-hoverHelp=>WebGUI::International::get('shortcut template title description', 'Asset_Shortcut'),
		-namespace=>"Shortcut"
	);
	if($self->session->setting->get("metaDataEnabled")) {
		$tabform->getTab("properties")->yesNo(
			-name=>"shortcutByCriteria",
			-value=>$self->getValue("shortcutByCriteria"),
			-label=>WebGUI::International::get("Shortcut by alternate criteria","Asset_Shortcut"),
			-hoverHelp=>WebGUI::International::get("Shortcut by alternate criteria description","Asset_Shortcut"),
			-extras=>q|onchange="
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
		$tabform->getTab("properties")->selectBox(
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
	$tabform->addTab('overrides',$i18n->get('Overrides'));
	$tabform->getTab('overrides')->raw($self->getOverridesList);
	if ($self->isDashlet) {
		$tabform->addTab('preferences',$i18n->get('Preferences'));
		$tabform->getTab('preferences')->raw($self->getFieldsList);
		$tabform->getTab("properties")->yesNo(
			-value=>$self->getValue("showReloadIcon"),
			-name=>"showReloadIcon",
			-label=>WebGUI::International::get("show reload icon","Asset_Shortcut"),
			-hoverHelp=>WebGUI::International::get("show reload icon description","Asset_Shortcut")
		);
	}
	return $tabform;
}


#-------------------------------------------------------------------

=head2 getExtraHeadTags (  )

Returns the extraHeadTags stored in the asset.  Called in $self->session->style->generateAdditionalHeadTags if this asset is the $self->session->asset.  Also called in WebGUI::Layout::view for its child assets.  Overriden here in Shortcut.pm.

=cut

sub getExtraHeadTags {
	my $self = shift;
	return $self->get("extraHeadTags")."\n".$self->getShortcut->get("extraHeadTags");
}

#-------------------------------------------------------------------
sub getFieldsList {
	my $self = shift;
	my $i18n = WebGUI::International->new("Asset_Shortcut");
	my $output = '<a href="'.$self->getUrl('op=editProfileSettings').'" class="formLink">'.$i18n->get('Manage Profile Fields').'</a><br /><br />';
	my %fieldNames;
	tie %fieldNames, 'Tie::IxHash';
	foreach my $field (@{WebGUI::ProfileField->getFields}) {
		my $fieldId = $field->getId;
		next if $fieldId =~ /contentPositions/;
		$fieldNames{$fieldId} = $field->getLabel.' ['.$fieldId.']';
	}
	$output .= '<table cellspacing="0" cellpadding="3" border="1"><tr><td><table cellspacing="0" cellpadding="3" border="0">';
	my @prefFieldsToShow = split("\n",$self->getValue("prefFieldsToShow"));
	$output .= WebGUI::Form::CheckList->new(
		-name=>"prefFieldsToShow",
		-value=>\@prefFieldsToShow,
		-options=>\%fieldNames,
		-label=>$i18n->get('pref fields to show'),
		-hoverHelp=>$i18n->get('pref fields to show description'),
		-vertical=>1,
		-uiLevel=>9
	)->toHtmlWithWrapper;
	$output .= '</table></td><td><table cellspacing="0" cellpadding="3" border="0">';
	my @prefFieldsToImport = split("\n",$self->getValue("prefFieldsToImport"));
	$output .= WebGUI::Form::CheckList->new(
		-name=>"prefFieldsToImport",
		-value=>\@prefFieldsToImport,
		-options=>\%fieldNames,
		-label=>$i18n->get('pref fields to import'),
		-hoverHelp=>$i18n->get('pref fields to import description'),
		-vertical=>1,
		-uiLevel=>9
	)->toHtmlWithWrapper;
	$output .= '</table></td></tr></table>';
	return $output;
}

#-------------------------------------------------------------------
sub getOverridesList {
	my $self = shift;
	my $output = '';
	my $i18n = WebGUI::International->new("Asset_Shortcut");
	my %overrides = $self->getOverrides;
	$output .= '<table cellspacing="0" cellpadding="3" border="1">';
	$output .= '<tr class="tableHeader"><td>'.$i18n->get('fieldName').'</td><td>'.$i18n->get('edit delete fieldname').'</td><td>'.$i18n->get('Original Value').'</td><td>'.$i18n->get('New value').'</td><td>'.$i18n->get('Replacement value').'</td></tr>';
	foreach my $definition (@{$self->getShortcutOriginal->definition}) {
		foreach my $prop (keys %{$definition->{properties}}) {
			next if $definition->{properties}{$prop}{fieldType} eq 'hidden';
			$output .= '<tr>';
			$output .= '<td class="tableData"><a href="'.$self->getUrl('func=editOverride;fieldName='.$prop).'">'.$prop.'</a></td>';
			$output .= '<td class="tableData">';
			$output .= editIcon('func=editOverride;fieldName='.$prop,$self->get("url"));
			$output .= deleteIcon('func=deleteOverride;fieldName='.$prop,$self->get("url")) if exists $overrides{overrides}{$prop};
			$output .= '</td><td>';
			$output .= $overrides{overrides}{$prop}{origValue};
			$output .= '</td><td>';
			$output .= $overrides{overrides}{$prop}{newValue};
			$output .= '</td><td>';
			$output .= $overrides{overrides}{$prop}{parsedValue};
			$output .= '</td></tr>';
		}
	}
	$output .= '</table>';
	return $output;
}


#-------------------------------------------------------------------
sub getOverrides {
	my $self = shift;
	my $i = 0;
	#cache by userId, assetId of this shortcut, and whether adminMode is on or not.
	my $cache = WebGUI::Cache->new($self->session,["shortcutOverrides",$self->getId,$self->session->user->profileField("userId"),$self->session->var->get("adminOn")]);
	my $overridesRef = $cache->get;
	unless ($overridesRef->{cacheNotExpired}) {
		my %overrides;
		my $orig = $self->getShortcutOriginal;
		unless (exists $orig->{_propertyDefinitions}) {
			my %properties;
			foreach my $definition (@{$orig->definition}) {
				%properties = (%properties, %{$definition->{properties}});
			}
			$orig->{_propertyDefinitions} = \%properties;
		}
		$overrides{cacheNotExpired} = 1;
		my $sth = $self->session->db->read("select fieldName, newValue from Shortcut_overrides where assetId=".$self->session->db->quote($self->getId)." order by fieldName");
		while (my ($fieldName, $newValue) = $sth->array) {
			$overrides{overrides}{$fieldName}{fieldType} = $orig->{_propertyDefinitions}{$fieldName}{fieldType};
			$overrides{overrides}{$fieldName}{origValue} = $self->getShortcutOriginal->get($fieldName);
			$overrides{overrides}{$fieldName}{newValue} = $newValue;
			$overrides{overrides}{$fieldName}{parsedValue} = $newValue;
		}
		$sth->finish;
		if ($self->isDashlet) {
			my $u = WebGUI::User->new($self->discernUserId);
			my @userPrefs = $self->getPrefFieldsToImport;
			foreach my $fieldId (@userPrefs) {
				my $field = WebGUI::ProfileField->new($fieldId);
				next unless $field;
				my $fieldName = $field->getId;
				my $fieldValue = $u->profileField($field->getId);
				$overrides{userPrefs}{$fieldName}{value} = $fieldValue;
				$overrides{overrides}{$fieldName}{parsedValue} = $fieldValue;
				#  'myTemplateId is ##userPref:myTemplateId##', for example.
				foreach my $overr (keys %{$overrides{overrides}}) {
					$overrides{overrides}{$overr}{parsedValue} =~ s/\#\#userPref\:${fieldName}\#\#/$fieldValue/gm;
				}
			}
		}
		$cache->set(\%overrides, 60*60);
		$overridesRef = \%overrides;
	}
	return %$overridesRef;
}

#-------------------------------------------------------------------
sub getShortcut {
	my $self = shift;
	unless ($self->{_shortcut}) {
		$self->{_shortcut} = $self->getShortcutOriginal;
	}
	$self->{_shortcut}{_properties}{displayTitle} = undef if ($self->isDashlet);
	# Hide title by default.  If you want, you can create an override
	# to display it.  But it's being shown in the dragheader by default.
	my %overhash = $self->getOverrides;
	if (exists $overhash{overrides}) {
		my %overrides = %{$overhash{overrides}};
		foreach my $override (keys %overrides) {
			$self->{_shortcut}{_properties}{$override} = $overrides{$override}{parsedValue};
		}
		$self->{_shortcut}{_properties}{showReloadIcon} = $self->get("showReloadIcon");
	}
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
	WebGUI::Macro::process($self->session,\$criteria);

	# Once a asset is found, we will stick to that asset, 
	# to prevent the proxying of multiple- depth assets like Surveys and USS.
	my $scratchId;
	if ($assetId) {
		$scratchId = "Shortcut_" . $assetId;
		if($session{scratch}{$scratchId} && !$self->getValue("disableContentLock")) {
			return $session{scratch}{$scratchId} unless ($self->session->var->get("adminOn"));
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
			$quotedField = $self->session->db->quote($field);
		}
                unless ($value =~ /^\s*['"].*['"]\s*/) {
                        $quotedValue = $self->session->db->quote($value);
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
				and w.className=".$self->session->db->quote($self->getShortcutDefault->get("className"));

	
	# Add constraint only if it has been modified.
	$sql .= " and ".$constraint if (($constraint ne $criteria) && $constraint ne "");
# Can't do this without extensive refactoring.....!  
#	$sql .= " order by assetData.revisionDate desc";

	# Execute the query with an unconditional read
	my @ids;
        my $sth = $self->session->db->unconditionalRead($sql);
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
	$self->session->scratch->set($scratchId,$id) if ($scratchId);

	return WebGUI::Asset->newByDynamicClass($id);		
}

#-------------------------------------------------------------------
sub getShortcutDefault {
	my $self = shift;
	return WebGUI::Asset->newByDynamicClass($self->get("shortcutToAssetId"));
}

#-------------------------------------------------------------------
sub getShortcutOriginal {
	my $self = shift;
	if ($self->get("shortcutByCriteria")) {
		return $self->getShortcutByCriteria;
	} else {
		return $self->getShortcutDefault;
	}
}

#-------------------------------------------------------------------
sub getPrefFieldsToShow {
	my $self = shift;
	return split("\n",$self->getValue("prefFieldsToShow"));
}

#-------------------------------------------------------------------
sub getPrefFieldsToImport {
	my $self = shift;
	return split("\n",$self->getValue("prefFieldsToImport"));
}

#-------------------------------------------------------------------
sub isDashlet {
	my $self = shift;
	return 1 if ref $self->getParent eq 'WebGUI::Asset::Wobject::Dashboard';
	return 0;
}

#-------------------------------------------------------------------
sub processPropertiesFromFormPost {
	my $self = shift;
	$self->SUPER::processPropertiesFromFormPost;
	my $scratchId = "Shortcut_" . $self->getId;
	$self->session->scratch->deleteAll($scratchId);
}

#-------------------------------------------------------------------

sub uncacheOverrides {
	my $self = shift;
	WebGUI::Cache->new($self->session,["shortcutOverrides",$self->getId])->delete;
}

#-------------------------------------------------------------------
sub view {
	my $self = shift;
	my $content;
	my $shortcut = $self->getShortcut;
	if ($self->get("shortcutToAssetId") eq $self->get("parentId")) {
		$content = WebGUI::International::get("Displaying this shortcut would cause a feedback loop","Asset_Shortcut");
	} else {
		$content = $shortcut->view;
	}
	my %var = (
		isShortcut => 1,
		'shortcut.content' => $content,
		'shortcut.label' => WebGUI::International::get('assetName',"Asset_Shortcut"),
		originalURL => $shortcut->getUrl,
		'shortcut.url'=>$self->getUrl
		);
	foreach my $prop (keys %{$self->{_shortcut}{_properties}}) {
		next if ($prop eq 'content' || $prop eq 'label' || $prop eq 'url');
		$var{'shortcut.'.$prop} = $self->{_shortcut}{_properties}{$prop};
	$self->session->errorHandler->warn($prop.' = '.$self->{_shortcut}{_properties}{$prop});
	}
	return $self->processTemplate(\%var,$self->getValue("templateId"));
}

#-------------------------------------------------------------------
sub www_edit {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;
	$self->getAdminConsole->setHelp("shortcut add/edit","Asset_Shortcut");
	$self->getAdminConsole->addSubmenuItem($self->getUrl("func=manageOverrides"),WebGUI::International::get("Manage Shortcut Overrides","Asset_Shortcut"));
	return $self->getAdminConsole->render($self->getEditForm->print,WebGUI::International::get(2,"Asset_Shortcut"));
}

#-------------------------------------------------------------------
sub www_getUserPrefsForm {
	#This is a form retrieved by "ajax".
	my $self = shift;
	return 'You are no longer logged in' if $self->session->user->profileField("userId") eq '1';
	return 'You are not allowed to personalize this Dashboard.' unless $self->getParent->canPersonalize;
	my $output;
	my @fielden = $self->getPrefFieldsToShow;
	my $f = WebGUI::HTMLForm->new(extras=>' onSubmit="submitForm(this,\''.$self->getId.'\',\''.$self->getUrl.'\');return false;"');
	$f->raw('<table cellspacing="0" cellpadding="3" border="0">');
	$f->hidden(  
		-name => 'func', 
		-value => 'saveUserPrefs'
	);
	foreach my $fieldId (@fielden) {
		my $field = WebGUI::ProfileField->new($fieldId);
		next unless $field;
		my $params = {};
		if (lc($field->get("fieldType")) eq 'textarea') {
			$params->{rows} = 4;
			$params->{columns} = 20;
		}
		if (lc($field->get("fieldType")) eq 'text') {
			$params->{size} = 20;
		}
		$f->raw($field->formField($params,1));
	}
	$f->submit({extras=>'className="nothing"'});
	$f->raw('</table>');
	my $tags;
	foreach my $tag (@{$session{page}{head}{javascript}}) {
		$tags .= '<script';
		foreach my $name (keys %{$tag}) {
			$tags .= ' '.$name.'="'.$tag->{$name}.'"';
		}
		$tags .= '></script>'."\n";
	}
	$output .= $tags.$f->print;
	return $output;
}

#-------------------------------------------------------------------
sub www_manageOverrides {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;
	return $self->_submenu($self->getOverridesList,WebGUI::International::get("Manage Shortcut Overrides","Asset_Shortcut"));
}

#-------------------------------------------------------------------
sub www_purgeOverrideCache {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;
	$self->uncacheOverrides;
	return $self->www_manageOverrides;
}

#-------------------------------------------------------------------
sub www_deleteOverride {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;
	$self->session->db->write('delete from Shortcut_overrides where assetId='.$self->session->db->quote($self->getId).' and fieldName='.$self->session->db->quote($self->session->form->process("fieldName")));
	$self->uncacheOverrides;
	return $self->www_manageOverrides;
}

#-------------------------------------------------------------------
sub www_saveUserPrefs {
	my $self = shift;
	return '' unless $self->getParent->canPersonalize;
	my @fellowFields = $self->getPrefFieldsToShow;
	my %data = ();
	$self->uncacheOverrides;
	my $u = WebGUI::User->new($self->discernUserId);
	foreach my $fieldId (keys %{$session{form}}) {
		my $field = WebGUI::ProfileField->new($fieldId);
		next unless $field;
		$data{$field->getId} = $field->formProcess;
		if ($field->getId eq 'email' && WebGUI::Operation::Profile::isDuplicateEmail($data{$field->getId})) {
			return '<li>'.WebGUI::International::get(1072).'</li>';
		}
		if ($field->isRequired && !$data{$field->getId}) {
			return '<li>'.$field->getLabel.' '.WebGUI::International::get(451).'</li>';
		}
		$u->profileField($field->getId,$data{$field->getId});
	}
	return $self->view;
}

#-------------------------------------------------------------------
sub www_getNewTitle {
	my $self = shift;
	return '' unless $self->getParent->canPersonalize;
	my $foo = $self->getShortcut;
	return $foo->{_properties}{title};
}

#-------------------------------------------------------------------
sub www_editOverride {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;
	my $i18n = WebGUI::International->new("Asset_Shortcut");
	my $fieldName = $self->session->form->process("fieldName");
	my %overrides = $self->getOverrides;
	my $output = '';
	my %props;
	foreach my $def (@{$self->getShortcutOriginal->definition}) {
		%props = (%props,%{$def->{properties}});
	}
	$output .= '</table>';
  my $f = WebGUI::HTMLForm->new(-action=>$self->getUrl);
  $f->hidden(-name=>"func",-value=>"saveOverride");
  $f->hidden(-name=>"overrideFieldName",-value=>$self->session->form->process("fieldName"));
  $f->readOnly(-label=>$i18n->get("fieldName"),-value=>$self->session->form->process("fieldName"));
  $f->readOnly(-label=>$i18n->get("Original Value"),-value=>$overrides{overrides}{$fieldName}{origValue});
  my %params;
  foreach my $key (keys %{$props{$fieldName}}) {
		next if ($key eq "tab");
			$params{$key} = $props{$fieldName}{$key};
		}
	$params{value} = $overrides{overrides}{$fieldName}{origValue};
	$params{name} = $fieldName;
	$params{label} = $params{label} || $i18n->get("Edit Field Directly");
	$params{hoverhelp} = $params{hoverhelp} || $i18n->get("Use this field to edit the override using the native form handler for this field type");
	if ($fieldName eq 'templateId') {$params{namespace} = $params{namespace} || WebGUI::Asset->newByDynamicClass($overrides{overrides}{templateId}{origValue})->get("namespace");}
	$f->dynamicField(%params);
	$f->textarea(
		-name=>"newOverrideValueText",
		-label=>$i18n->get("New Override Value"),
		-value=>$overrides{overrides}{$fieldName}{newValue},
		-hoverHelp=>$i18n->get("Place something in this box if you dont want to use the automatically generated field")
	);
	$f->readOnly(-label=>$i18n->get("Replacement Value"),-value=>$overrides{overrides}{$fieldName}{parsedValue},-hoverHelp=>$i18n->get("This is the example output of the field when parsed for user preference macros")) if $self->isDashlet;
  $f->submit;
  $output .= $f->print;
	return $self->_submenu($output,$i18n->get('Edit Override'));
}

#-------------------------------------------------------------------
sub www_saveOverride {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;
	my $fieldName = $self->session->form->process("overrideFieldName");
	my %overrides = $self->getOverrides;
	my $output = '';
	my %props;
	foreach my $def (@{$self->getShortcutOriginal->definition}) {
		%props = (%props,%{$def->{properties}});
	}
	my $fieldType = $props{$fieldName}{fieldType};
	my $value = $self->session->form->process($fieldName,$fieldType);
	$value = $self->session->form->process("newOverrideValueText") || $value;
	$self->session->db->write("delete from Shortcut_overrides where assetId=".$self->session->db->quote($self->getId)." and fieldName=".$self->session->db->quote($fieldName));
	$self->session->db->write("insert into Shortcut_overrides values (".$self->session->db->quote($self->getId).",".$self->session->db->quote($fieldName).",".$self->session->db->quote($value).")");
	$self->uncacheOverrides;
	return $self->www_manageOverrides;
}

#-------------------------------------------------------------------
sub www_view {
	my $self = shift;
	if ($self->isDashlet) {
		return $self->session->privilege->noAccess() unless $self->canView;
		$self->session->asset = $self->getParent;
		return $self->session->asset->www_view;
	} else {
		return $self->getShortcut->www_view;
	}
}

1;

