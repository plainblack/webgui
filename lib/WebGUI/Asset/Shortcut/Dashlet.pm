package WebGUI::Asset::Shortcut::Dashlet;

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
use WebGUI::Asset::Shortcut;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;

our @ISA = qw(WebGUI::Asset::Shortcut);

#-------------------------------------------------------------------
sub _submenu {
	my $self = shift;
	my $workarea = shift;
	my $title = shift;
	my $help = shift;
	my $ac = WebGUI::AdminConsole->new("shortcutmanager");
	$ac->setHelp($help) if ($help);
	$ac->setIcon($self->getIcon);
	$ac->addSubmenuItem($self->getUrl('func=edit'), WebGUI::International::get("Back to Edit Shortcut","Asset_Shortcut"));
	$ac->addSubmenuItem($self->getUrl("func=manageOverrides"),WebGUI::International::get("Manage Shortcut Overrides","Asset_Shortcut"));
	$ac->addSubmenuItem($self->getUrl("func=manageUserPrefs"),WebGUI::International::get("Manage User Preferences","Asset_Shortcut"));
	return $ac->render($workarea, $title);
}

#-------------------------------------------------------------------
sub canEdit {
	my $self = shift;
return 1 if ($self->SUPER::canEdit || (ref $self->getParent eq 'WebGUI::Asset::Wobject::Dashboard' && $self->getParent->canManage));
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
		tableName=>'Dashlet',
		className=>'WebGUI::Asset::Shortcut::Dashlet',
		properties=>{
			prefFieldsToShow=>{
				fieldType=>"text",
				defaultValue=>0,
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
	my $i18n = WebGUI::International->new("Asset_Shortcut");
	$tabform->addTab('preferences',$i18n->get('Preferences'));
	$tabform->getTab('preferences')->raw($self->getPrefsList);
	return $tabform;
}


#-------------------------------------------------------------------
sub getPrefsList {
	my $self = shift;
	my $i18n = WebGUI::International->new("Asset_Shortcut");
	my $output = '<a href="'.$self->getUrl('func=add;class=WebGUI::Asset::Field').'" class="formLink">'.$i18n->get('Add Preference Field').'</a><br /><br />';
	my @fielden;
	@fielden = $self->getUserPrefs;
	return $output unless scalar @fielden > 0;
	$output .= '<table cellspacing="0" cellpadding="3" border="1">';
	$output .= '<tr class="tableHeader"><td>'.$i18n->get('fieldName').'</td><td>'.$i18n->get('edit delete fieldname').'</td></tr>';
	foreach my $field (@fielden) {
		$output .= '<tr>';
		$output .= '<td class="tableData"><a href="'.$field->getUrl('func=edit').'">'.$field->get("fieldName").'</a></td>';
		$output .= '<td class="tableData">';
		$output .= editIcon('func=edit',$field->getUrl());
		$output .= deleteIcon('func=delete',$field->getUrl());
		$output .= '</td>';
		$output .= '</tr>';
	}
	$output .= '</table>';
	return $output;
}

#-------------------------------------------------------------------
sub getOverrides {
	my $self = shift;
	my $i = 0;
	#cache by userId, assetId of this shortcut, and whether adminMode is on or not.
	my $cache = WebGUI::Cache->new(["shortcutOverrides",$self->getId,$session{user}{userId},$session{var}{adminOn}]);
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
		my $sth = WebGUI::SQL->read("select fieldName, newValue from Shortcut_overrides where assetId=".quote($self->getId)." order by fieldName");
		while (my ($fieldName, $newValue) = $sth->array) {
			$overrides{overrides}{$fieldName}{fieldType} = $orig->{_propertyDefinitions}{$fieldName}{fieldType};
			$overrides{overrides}{$fieldName}{origValue} = $self->getShortcutOriginal->get($fieldName);
			$overrides{overrides}{$fieldName}{newValue} = $newValue;
			$overrides{overrides}{$fieldName}{parsedValue} = $newValue;
		}
		$sth->finish;
		my @userPrefs = $self->getUserPrefs;
		foreach my $field (@userPrefs) {
			my $id = $field->getId;
			my $fieldName = $field->getFieldName;
			my $fieldValue = $field->getUserPref($id);
			$overrides{userPrefs}{$fieldName}{value} = $fieldValue;
			$overrides{overrides}{$fieldName}{parsedValue} = $fieldValue;
			#  'myTemplateId is ##userPref:myTemplateId##', for example.
			foreach my $overr (keys %{$overrides{overrides}}) {
				$overrides{overrides}{$overr}{parsedValue} =~ s/\#\#userPref\:${fieldName}\#\#/$fieldValue/gm;
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
	$self->{_shortcut}{_properties}{displayTitle} = undef if (ref $self->getParent eq 'WebGUI::Asset::Wobject::Dashboard');
	# Hide title by default.  If you want, you can create an override
	# to display it.  But it's being shown in the dragheader by default.
	my %overhash = $self->getOverrides;
	if (exists $overhash{overrides}) {
		my %overrides = %{$overhash{overrides}};
		foreach my $override (keys %overrides) {
			$self->{_shortcut}{_properties}{$override} = $overrides{$override}{parsedValue};
		}
		foreach my $userPref ($self->getUserPrefs) {
			$self->{_shortcut}{_properties}{$userPref->getFieldName} = $userPref->getUserPref($userPref->getId) unless (exists $overrides{$userPref->getFieldName});
		}
	}
	return $self->{_shortcut};
}

#-------------------------------------------------------------------
sub getUserPrefs {
	my $self = shift;
	my $bibibib = $self->getLineage(["children"],{includeOnlyClasses=>["WebGUI::Asset::Field"],returnObjects=>1});
	return @$bibibib;
}

#-------------------------------------------------------------------
sub processPropertiesFromFormPost {
	my $self = shift;
	$self->SUPER::processPropertiesFromFormPost;
	my $scratchId = "Shortcut_" . $self->getId;
	WebGUI::Session::deleteAllScratch($scratchId);
}

#-------------------------------------------------------------------
sub www_edit {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	$self->getAdminConsole->setHelp("shortcut add/edit","Asset_Shortcut");
	$self->getAdminConsole->addSubmenuItem($self->getUrl("func=manageOverrides"),WebGUI::International::get("Manage Shortcut Overrides","Asset_Shortcut"));
	$self->getAdminConsole->addSubmenuItem($self->getUrl("func=manageUserPrefs"),WebGUI::International::get("Manage User Preferences","Asset_Shortcut"));
	return $self->getAdminConsole->render($self->getEditForm->print,WebGUI::International::get(2,"Asset_Shortcut"));
}

#-------------------------------------------------------------------
sub www_getUserPrefsForm {
	#This is a form retrieved by "ajax".
	my $self = shift;
	return 'nuhuh' unless $self->getParent->canPersonalize;
	my @fielden = $self->getUserPrefs;
	my $f = WebGUI::HTMLForm->new(extras=>' onSubmit="submitForm(this,\''.$self->getId.'\',\''.$self->getUrl.'\');return false;"');
	$f->hidden(  
		-name => 'func', 
		-value => 'saveUserPrefs'
	);
	foreach my $field (@fielden) {
		my $fieldType = $field->get("fieldType") || "text";
		my $options;
		my $params = {name=>$field->getId,
			label=>$field->get("fieldName"),
			uiLevel=>5,
			value=>$field->getUserPref($field->getId),
			extras=>'',
			possibleValues=>$field->get("possibleValues"),
			options=>$options,
			fieldType=>$fieldType
		};
		if (lc($fieldType) eq 'textarea') {
			$params->{rows} = 4;
			$params->{columns} = 20;
		}
		$f->dynamicField(%$params);
	}
	$f->submit;
	return $f->print;
}

#-------------------------------------------------------------------
sub www_manageUserPrefs {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	my $output = $self->getFieldsList;
	return $self->_submenu($output,WebGUI::International::get("Manage User Preferences","Asset_Shortcut"));
}

#-------------------------------------------------------------------
sub www_saveUserPrefs {
	my $self = shift;
	return '' unless $self->getParent->canPersonalize;
	my @fellowFields = $self->getUserPrefs;
	foreach my $fieldId (keys %{$session{form}}) {
		my $field = WebGUI::Asset->newByDynamicClass($fieldId);
		next unless $field;
		$field->setUserPref($fieldId,$session{form}{$fieldId});
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
sub www_view {
	my $self = shift;
	if (ref($self->getParent) eq 'WebGUI::Asset::Wobject::Dashboard') {
		return WebGUI::Privilege::noAccess() unless $self->canView;
		$session{asset} = $self->getParent;
		return $session{asset}->www_view;
	} else {
		return $self->getShortcut->www_view;
	}
}

1;

