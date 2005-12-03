package WebGUI::Asset::Field;

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
use JSON;
use WebGUI::Asset;
use WebGUI::Asset::Template;
use WebGUI::Privilege;
use WebGUI::ErrorHandler;
use WebGUI::Form;
use Tie::IxHash;
use WebGUI::SQL;
use WebGUI::Macro;
use WebGUI::Session;

our @ISA = qw(WebGUI::Asset);


#-------------------------------------------------------------------
sub canManage {
	my $self = shift;
	return 1 if ($self->canEdit || (ref $self->getParent eq 'WebGUI::Asset::Shortcut' && $self->getParent->canManage));
	return 0;
}

#-------------------------------------------------------------------
sub canPersonalize {
	my $self = shift;
return (ref $self->getParent->getParent eq 'WebGUI::Asset::Wobject::Dashboard' && WebGUI::Grouping::isInGroup($self->getParent->getParent->get("usersGroupId")));
}


#-------------------------------------------------------------------

=head2 definition ( definition )

Defines the properties of this asset.

=head3 definition

A hash reference passed in from a subclass definition.

=cut

sub definition {
	my $class = shift;
	my $definition = shift;
	my $i18n = WebGUI::International->new("Asset_Shortcut");
	my %properties;
	tie %properties, 'Tie::IxHash';
	%properties = (
		#	formTemplateId=>{fieldType=>'template',defaultValue=>''},
		#	valueTemplateId=>{fieldType=>'template',defaultValue=>''},
		#	isUserPref=>{fieldType=>'hidden',defaultValue=>$session{form}{isUserPref},label=>'Is This Field a User Preference?'},
			fieldName=>{fieldType=>'text',defaultValue=>'',label=>$i18n->get('The unique name of a user preference parameter you are inventing')},
			fieldLabel=>{fieldType=>'text',defaultValue=>'',label=>$i18n->get('Label for This Field')},
			fieldDescription=>{fieldType=>'HTMLArea',defaultValue=>'',label=>$i18n->get('Hover Help Description for this Field')},
			fieldType=>{fieldType=>'fieldType',defaultValue=>'',label=>$i18n->get('Type of Field'),types=>['text','textarea','checkList','selectList']},
		#	overrideForm=>{fieldType=>'yesNo',defaultValue=>0},
		#	overrideValue=>{fieldType=>'yesNo',defaultValue=>0},
			possibleValues=>{fieldType=>'textarea',defaultValue=>'',label=>$i18n->get('Possible values'),hoverHelp=>$i18n->get('Possible values for this Field Only applies to selectList and checkList')},
			defaultValue=>{fieldType=>'textarea',defaultValue=>'',label=>$i18n->get('Default Value for this field')}
		);

	push(@{$definition}, {
		assetName=>$i18n->get("Field"),
		tableName=>'wgField',
		autoGenerateForms=>1,
		className=>'WebGUI::Asset::Field',
		properties=>\%properties
	});
	return $class->SUPER::definition($definition);
}

#-------------------------------------------------------------------

=head2 getEditForm ()

Returns the TabForm object that will be used in generating the edit page for this wobject.

=cut

sub getEditForm {
	my $self = shift;
	my $tabform = $self->SUPER::getEditForm();
	foreach my $definition (reverse @{$self->definition}) {
		my $properties = $definition->{properties};
		next unless ($definition->{autoGenerateForms});
		foreach my $fieldname (keys %{$properties}) {
			my %params;
			foreach my $key (keys %{$properties->{$fieldname}}) {
				next if ($key eq "tab");
				$params{$key} = $properties->{$fieldname}{$key};
			}
			$params{value} = $self->getValue($fieldname);
			$params{name} = $fieldname;
			my $tab = $properties->{$fieldname}{tab} || "properties";
			$tabform->getTab($tab)->dynamicField(%params);
		}
	}
	return $tabform;
}


#-------------------------------------------------------------------
sub getFieldName {
	my $self = shift;
	my $name = $self->get("fieldName") || "blankPlaceHolderWillOverrideNothing";
	return $name;
}

#-------------------------------------------------------------------
sub getUserPref {
	#This is a class method.  Can be called from the getDashletUserPref macro
	my $class = shift; #ignored when called from within this package/module.
	my $fieldId = shift;
	my $userId = shift || 'autoDerive';
	my $field;
	if ($userId eq 'autoDerive') {
		$field = WebGUI::Asset->newByDynamicClass($fieldId);
		$userId = ($field->canManage && WebGUI::Session::isAdminOn()) ? '1' : $session{user}{userId};
	}
	my $returnDataType = shift || 'string';
	my $returnDataFormat = shift || 'raw';
	my $sql = "select userValue from wgFieldUserData where assetId=".quote($fieldId)." and userId=".quote($userId);
#	WebGUI::ErrorHandler::warn($sql);
	my ($userValue) = WebGUI::SQL->quickArray($sql);
	unless ($userValue) {
		return '' if $fieldId eq 'skipThisRequest';
		$field = WebGUI::Asset->newByDynamicClass($fieldId) unless $field;
		return '' unless $field;
		if ($userId eq '1') {
			$userValue = $field->get("defaultValue");
			# fall back to wobject defaults if this is blank.
	#		$userValue = WebGUI::Asset->newByDynamicClass($field->getParent->get("shortcutToAssetId"))->get($field->get("fieldName")) if (ref $field->getParent eq 'WebGUI::Asset::Shortcut' && !($userValue) && !($field->get("isUserPref")));
		} else {
			$userValue = WebGUI::Asset::Field->getUserPref($fieldId,1);
		}
	}
	if ($returnDataType eq 'string' && $returnDataFormat eq 'raw') {
		return $userValue;
	}
}

#-------------------------------------------------------------------
sub setUserPref {
	my $class = shift; #ignored when called from within this package/module.
	my $fieldId = shift;
	my $valueToSet = shift;
	return 0 unless $valueToSet;
	my $userId = shift || 'autoDerive';
	my $field = WebGUI::Asset->newByDynamicClass($fieldId);
	if ($userId eq 'autoDerive') {
		$userId = ($field->canManage && WebGUI::Session::isAdminOn()) ? '1' : $session{user}{userId};
	}
	my $returnDataType = shift || 'string';
	my $returnDataFormat = shift || 'raw';
	my $sql = "delete from wgFieldUserData where assetId=".quote($fieldId)." and userId=".quote($userId);
	WebGUI::SQL->write($sql);
	my $sql2 = "insert into wgFieldUserData values (".quote($fieldId).",".quote($userId).",".quote($valueToSet).")";
#	WebGUI::ErrorHandler::warn($sql2);
	$field->getParent->uncacheOverrides;
	return WebGUI::SQL->write($sql2);
}

#-------------------------------------------------------------------
sub www_edit {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canManage;
	$self->getAdminConsole->setHelp("field add/edit","Asset_Shortcut");
	return $self->getAdminConsole->render($self->getEditForm->print,WebGUI::International::get('Edit User Preference Field',"Asset_Shortcut"));
}

#-------------------------------------------------------------------
sub www_view {
	my $self = shift;
	return WebGUI::Privilege::noAccess() unless $self->canView;
	$session{asset} = $self->getParent->getParent;
	return $self->getParent->getParent->www_view;
}

1;