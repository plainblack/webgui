package WebGUI::Asset::Wobject::DataForm;

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
use Tie::CPHash;
use Tie::IxHash;
use WebGUI::Form;
use WebGUI::HTML;
use WebGUI::HTMLForm;
use WebGUI::International;
use WebGUI::Mail::Send;
use WebGUI::Macro;
use WebGUI::Inbox;
use WebGUI::SQL;
use WebGUI::Asset::Wobject;
use WebGUI::Utility qw(isIn);
use WebGUI::Pluggable;
use WebGUI::DateTime;
use WebGUI::User;
use WebGUI::Group;
use JSON;

our @ISA = qw(WebGUI::Asset::Wobject);

=head1 NAME

Package WebGUI::Asset::Wobject::DataForm

=head1 DESCRIPTION

A subclass of lib/WebGUI/Wobject. DataForm creates custom forms to save data in the WebGUI database.

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------
sub _createForm {
    my $self = shift;
    my $data = shift;
    my $value = shift;
    # copy select entries
    my %param = map { $_ => $data->{$_} } qw(name width extras vertical defaultValue options);
    $param{value} = $value;
    $param{size} = $param{width};
    $param{height} = $data->{rows};

    WebGUI::Macro::process($self->session, \( $param{defaultValue} ));

    my $type = "\u$data->{type}";
    if ($data->{type} eq "checkbox") {
        $param{defaultValue} = ($param{defaultValue} =~ /checked/i);
    }
    elsif ( isIn($type, qw(SelectList SelectBox CheckList RadioList)) ) {
        delete $param{size};
    }
    my $control = eval {
        WebGUI::Pluggable::instanciate("WebGUI::Form::$type", "new", [ $self->session, \%param ]);
    };
    return $control;
}

#-------------------------------------------------------------------
sub _fieldAdminIcons {
    my $self = shift;
    my $fieldName = shift;
    my $i18n = WebGUI::International->new($self->session,"Asset_DataForm");
    my $output;
    $output = $self->session->icon->delete('func=deleteFieldConfirm;fieldName='.$fieldName,$self->get("url"),$i18n->get(19))
        unless $self->getFieldConfig($fieldName)->{isMailField};
    $output .= $self->session->icon->edit('func=editField;fieldName='.$fieldName,$self->get("url"))
        . $self->session->icon->moveUp('func=moveFieldUp;fieldName='.$fieldName,$self->get("url"))
        . $self->session->icon->moveDown('func=moveFieldDown;fieldName='.$fieldName,$self->get("url"));
    return $output;
}
#-------------------------------------------------------------------
sub _tabAdminIcons {
    my $self = shift;
    my $tabId = shift;
    my $i18n = WebGUI::International->new($self->session,"Asset_DataForm");
    my $output
        = $self->session->icon->delete('func=deleteTabConfirm;tabId='.$tabId,$self->get("url"),$i18n->get(100))
        . $self->session->icon->edit('func=editTab;tabId='.$tabId,$self->get("url"))
        . $self->session->icon->moveLeft('func=moveTabLeft;tabId='.$tabId,$self->get("url"))
        . $self->session->icon->moveRight('func=moveTabRight;tabId='.$tabId,$self->get("url"));
    return $output;
}

#-------------------------------------------------------------------
sub _createTabInit {
	my $self = shift;
    my $tabCount = @{ $self->getTabOrder };
    my $output = '<script type="text/javascript">var numberOfTabs = '.$tabCount.'; initTabs();</script>';
	return $output;
}

#-------------------------------------------------------------------

sub defaultViewForm {
    my $self = shift;
    return ($self->get("defaultView") == 0);
}

sub deleteField {
    my $self = shift;
    my $fieldName = shift;
    my $fieldOrder = $self->getFieldOrder;
    my $currentPos;
    for ($currentPos = 0; $currentPos < @$fieldOrder; $currentPos++) {
        last
            if $fieldName eq $fieldOrder->[$currentPos];
    }
    splice @$fieldOrder, $currentPos, 1;
    delete $self->getFieldConfig->{$fieldName};
    $self->_saveFieldConfig;
    return 1;
}

sub deleteTab {
    my $self = shift;
    my $tabId = shift;
    my $tabOrder = $self->getTabOrder;
    my $currentPos;
    for ($currentPos = 0; $currentPos < @$tabOrder; $currentPos++) {
        last
            if $tabId eq $tabOrder->[$currentPos];
    }
    splice @$tabOrder, $currentPos, 1;
    delete $self->getTabConfig->{$tabId};
    for my $field (grep { $_->{tabId} eq $tabId } values %{ $self->getFieldConfig }) {
        $field->{tabId} = undef;
    }
    $self->_saveTabConfig;
    return 1;
}

sub renameField {
    my $self = shift;
    my $oldName = shift;
    my $newName = shift;
    my $fieldOrder = $self->getFieldOrder;
    my $currentPos;
    for my $fieldName (@$fieldOrder) {
        if ($fieldName eq $oldName) {
            $fieldName = $newName;
        }
    }
    $self->getFieldConfig->{$newName} = $self->getFieldConfig->{$oldName};
    delete $self->getFieldConfig->{$oldName};
    $self->getFieldConfig->{$newName}{name} = $newName;
}

sub _saveFieldConfig {
    my $self = shift;
    my @config = map {
        $self->getFieldConfig($_)
    } @{ $self->getFieldOrder };
    my $data = JSON::to_json(\@config);
    $self->update({fieldConfiguration => $data});
}

sub _saveTabConfig {
    my $self = shift;
    my @config = map {
        $self->getTabConfig($_)
    } @{ $self->getTabOrder };
    my $data = JSON::to_json(\@config);
    $self->update({tabConfiguration => $data});
}

#-------------------------------------------------------------------

=head2 definition ( session, [definition] )

Returns an array reference of definitions. Adds tableName, className, properties to array definition.

=head3 definition

An array of hashes to prepend to the list

=cut

sub definition {
    my $class = shift;
    my $session = shift;
    my $definition = shift;
    my $i18n = WebGUI::International->new($session,"Asset_DataForm");
    my %properties;
    tie %properties, 'Tie::IxHash';
    %properties = (
        templateId => {
            fieldType       => 'template',
            defaultValue    => 'PBtmpl0000000000000141',
            namespace       => 'DataForm',
            tab             => 'display',
            label           => $i18n->get(82),
            hoverHelp       => $i18n->get('82 description'),
            afterEdit       => 'func=edit',
        },
        emailTemplateId => {
            fieldType       => "template",
            defaultValue    => 'PBtmpl0000000000000085',
            namespace       => 'DataForm',
            tab             => 'display',
            label           => $i18n->get(80),
            hoverHelp       => $i18n->get('80 description'),
            afterEdit       => 'func=edit',
        },
        acknowlegementTemplateId => {
            fieldType       => "template",
            defaultValue    => 'PBtmpl0000000000000104',
            namespace       => 'DataForm',
            tab             => 'display',
            label           => $i18n->get(81),
            hoverHelp       => $i18n->get('81 description'),
            afterEdit       => 'func=edit',
        },
        listTemplateId => {
            fieldType       => "template",
            defaultValue    => 'PBtmpl0000000000000021',
            namespace       => 'DataForm/List',
            tab             => 'display',
            label           => $i18n->get(87),
            hoverHelp       => $i18n->get('87 description'),
            afterEdit       => 'func=edit',
        },
        defaultView => {
            fieldType       => "radioList",
            defaultValue    => 0,
            options         => {
                0 => $i18n->get('data form'),
                1 => $i18n->get('data list'),
            },
            label           => $i18n->get('defaultView'),
            hoverHelp       => $i18n->get('defaultView description'),
            tab             => 'display',
        },
        acknowledgement => {
            fieldType       => "HTMLArea",
            defaultValue    => undef,
            tab             => 'properties',
            label           => $i18n->get(16),
            hoverHelp       => $i18n->get('16 description'),
        },
        mailData => {
            fieldType       => "yesNo",
            defaultValue    => 0,
            tab             => 'display',
            label           => $i18n->get(74),
            hoverHelp       => $i18n->get('74 description'),
        },
        storeData => {
            fieldType       => "yesNo",
            defaultValue    => 1,
            tab             => 'display',
            label           => $i18n->get('store data'),
            hoverHelp       => $i18n->get('store data description'),
        },
        mailAttachments => {
            fieldType       => 'yesNo',
            defaultValue    => 0,
            tab             => 'properties',
            label           => $i18n->get("mail attachments"),
            hoverHelp       => $i18n->get("mail attachments description"),
        },
        groupToViewEntries => {
            fieldType       => "group",
            defaultValue    => 7,
            tab             => 'security',
            label           => $i18n->get('group to view entries'),
            hoverHelp       => $i18n->get('group to view entries description'),
        },
        useCaptcha  => {
            tab             => 'properties',
            fieldType       => "yesNo",
            defaultValue    => 0,
            label           => $i18n->get('editForm useCaptcha label'),
            hoverHelp       => $i18n->get('editForm useCaptcha description'),
        },
        fieldConfiguration => {
            fieldType       => 'hidden',
        },
        tabConfiguration => {
            fieldType       => 'hidden',
        },
    );
    my @defFieldConfig = (
        {
            name=>"from",
            label=>$i18n->get(10),
            status=>"editable",
            isMailField=>1,
            width=>0,
            type=>"email",
        },
        {
            name=>"to",
            label=>$i18n->get(11),
            status=>"hidden",
            isMailField=>1,
            width=>0,
            type=>"email",
            defaultValue=>$session->setting->get("companyEmail"),
        },
        {
            name=>"cc",
            label=>$i18n->get(12),
            status=>"hidden",
            isMailField=>1,
            width=>0,
            type=>"email",
        },
        {
            name=>"bcc",
            label=>$i18n->get(13),
            status=>"hidden",
            isMailField=>1,
            width=>0,
            type=>"email",
        },
        {
            name=>"subject",
            label=>$i18n->get(14),
            status=>"editable",
            isMailField=>1,
            width=>0,
            type=>"text",
            defaultValue=>$i18n->get(2),
        },
    );
    $properties{fieldConfiguration}{defaultValue} = JSON::to_json(\@defFieldConfig);
    push @$definition, {
        assetName           => $i18n->get('assetName'),
        uiLevel             => 5,
        tableName           => 'DataForm',
        icon                => 'dataForm.gif',
        className           => __PACKAGE__,
        properties          => \%properties,
        autoGenerateForms   => 1,
    };
    return $class->SUPER::definition($session, $definition);
}

sub _cacheFieldConfig {
    my $self = shift;
    if (!$self->{_fieldConfig}) {
        my $jsonData = $self->get("fieldConfiguration");
        my $fieldData;
        if ($jsonData && eval { $jsonData = JSON::from_json($jsonData) ; 1 }) {
            # jsonData is an array in the order the fields should be
            $self->{_fieldConfig} = {
                map { $_->{name}, $_ } @{ $jsonData }
            };
            $self->{_fieldOrder} = [
                map { $_->{name} } @{ $jsonData }
            ];
        }
        else {
            $self->{_fieldConfig} = {};
            $self->{_fieldOrder} = [];
        }
    }
    return 1;
}

sub _cacheTabConfig {
    my $self = shift;
    if (!$self->{_tabConfig}) {
        my $jsonData = $self->get("tabConfiguration");
        my $fieldData;
        if ($jsonData && eval { $jsonData = JSON::from_json($jsonData) ; 1 }) {
            # jsonData is an array in the order the fields should be
            $self->{_tabConfig} = {
                map { $_->{tabId}, $_ } @{ $jsonData }
            };
            $self->{_tabOrder} = [
                map { $_->{tabId} } @{ $jsonData }
            ];
        }
        else {
            $self->{_tabConfig} = {};
            $self->{_tabOrder} = [];
        }
    }
    return 1;
}

sub getFieldConfig {
    my $self = shift;
    my $field = shift;
    $self->_cacheFieldConfig;
    if ($field) {
        return $self->{_fieldConfig}{$field};
    }
    else {
        return $self->{_fieldConfig};
    }
}

sub getFieldOrder {
    my $self = shift;
    $self->_cacheFieldConfig;
    return $self->{_fieldOrder};
}

sub getTabConfig {
    my $self = shift;
    my $tabId = shift;
    $self->_cacheTabConfig;
    if ($tabId) {
        return $self->{_tabConfig}{$tabId};
    }
    else {
        return $self->{_tabConfig};
    }
}

sub getTabOrder {
    my $self = shift;
    $self->_cacheTabConfig;
    return $self->{_tabOrder};
}


#-------------------------------------------------------------------
sub deleteAttachedFiles {
    my $self = shift;
    my %params = @_;
    my $entryData = $params{entryData};
    my $entryId = $params{entryId};

    my $fields = $self->getFieldOrder;
    my $fieldConfig = $self->getFieldConfig;

    if ($entryId) {
        my ($entry) = $self->session->db->buildArray("select entryData from DataForm_entry where assetId=? and DataForm_entryId=?", [$self->getId, $entryId]);
        $entryData = JSON::from_json($entry);
    }
    if ($entryData) {
        for my $field ( @$fields ) {
            my $form = $self->_createForm($fieldConfig->{$field}, $entryData->{$field});
            if ($form->can('getStorageLocation')) {
                my $storage = $form->getStorageLocation;
                $storage->delete;
            }
        }
    }
    else {
        my $entries = $self->session->db->buildArrayRef("select entryData from DataForm_entry where assetId=?", [$self->getId]);
        foreach my $entry (@{ $entries}) {
            my $entryData = JSON::from_json($entry);
            for my $field (@{ $fields }) {
                my $form = $self->_createForm($fieldConfig->{$field}, $entryData->{$field});
                if ($form->can('getStorageLocation')) {
                    my $storage = $form->getStorageLocation;
                    $storage->delete;
                }
            }
        }
    }
}

#-------------------------------------------------------------------
sub getAttachedFiles {
    my $self = shift;
    my $entryData = shift;
    my $fieldConfig = $self->getFieldConfig;
    my @paths;
    for my $field ( values %{$fieldConfig} ) {
        my $form = $self->_createForm($field, $entryData->{$field->{name}});
        if ($form->can('getStorageLocation')) {
            my $storage = $form->getStorageLocation;
            if ($storage) {
                push @paths, $storage->getPath($storage->getFiles->[0]);
            }
        }
    }
    return \@paths;
}

#-------------------------------------------------------------------
sub getListTemplateVars {
	my $self = shift;
	my $var = shift;
	my $i18n = WebGUI::International->new($self->session,"Asset_DataForm");
	$var->{"back.url"} = $self->getFormUrl;
	$var->{"back.label"} = $i18n->get('go to form');
    my $fieldConfig = $self->getFieldConfig;
    my @fieldLoop = map {
        +{
            'field.name'        => $fieldConfig->{$_}{name},
            'field.label'       => $fieldConfig->{$_}{label},
            'field.isMailField' => $fieldConfig->{$_}{isMailField},
            'field.type'        => $fieldConfig->{$_}{type},
        }
    } @{ $self->getFieldOrder };
    $var->{field_loop} = \@fieldLoop;
    my @recordLoop;
    my $entries = $self->session->db->read(
        "SELECT `ipAddress`, `username`, `userId`, `submissionDate`, `DataForm_entryId`, `entryData`
        FROM `DataForm_entry` WHERE `assetId` = ? ORDER BY `submissionDate` DESC", [$self->getId]);
    while (my $record = $entries->hashRef) {
        my $recordData;
        if (!eval { $recordData = JSON::from_json($record->{entryData}) ; 1 }) {
            $self->session->errorHandler->warn('DataForm ' . $self->getId . ' entry ' . $record->{DataForm_entryId} . ' contains invalid data');
            next;
        }
        my @dataLoop;
        for my $fieldName ( @{ $self->getFieldOrder } ) {
            my $field = $fieldConfig->{$fieldName};
            my $form = $self->_createForm($field, $recordData->{$fieldName});
            push @dataLoop, {
                "record.data.name"          => $field->{name},
                "record.data.label"         => $field->{label},
                "record.data.value"         => $form->getValueAsHtml,
                "record.data.isMailField"   => $field->{isMailField},
                "record_data_type"          => $field->{type},
            };
        }
        my $date = WebGUI::DateTime->new($self->session, $record->{submissionDate});
        push @recordLoop, {
            "record.ipAddress"              => $recordData->{ipAddress},
            "record.edit.url"               => $self->getFormUrl("func=view;entryId=".$record->{DataForm_entryId}),
            "record.edit.icon"              => $self->session->icon->edit("func=view;entryId=".$record->{DataForm_entryId}, $self->get('url')),
            "record.delete.url"             => $self->getUrl("func=deleteEntry;entryId=".$record->{DataForm_entryId}),
            "record.delete.icon"            => $self->session->icon->delete("func=deleteEntry;entryId=".$record->{Asset_DataForm_entryId}, $self->get('url'), $i18n->get('Delete entry confirmation')),
            "record.username"               => $record->{username},
            "record.userId"                 => $record->{userId},
            "record.submissionDate.epoch"   => $date->epoch,
            "record.submissionDate.human"   => $date->cloneToUserTimeZone->webguiDate,
            "record.entryId"                => $record->{DataForm_entryId},
            "record.data_loop"              => \@dataLoop
        };
    }
    $entries->finish;
    $var->{record_loop} = \@recordLoop;
    return $var;
}

#-------------------------------------------------------------------

sub getFormUrl {
    my $self = shift;
    my $params = shift;
    my $url = $self->getUrl;
    unless ($self->defaultViewForm) {
        $url = $self->session->url->append($url, 'mode=form');
    }
    if ($params) {
        $url = $self->session->url->append($url, $params);
    }
    return $url;
}

#-------------------------------------------------------------------

=head2 getListUrl( params )

Get url of list of entries

=head3 params

Name value pairs of URL paramters in the form of:

 name1=value1;name2=value2;name3=value3

=cut

sub getListUrl {
    my $self = shift;
    my $params = shift;
    my $url = $self->getUrl;
    if ($self->defaultViewForm) {
        $url = $self->session->url->append($url, 'mode=list');
    }
    if ($params) {
        $url = $self->session->url->append($url, $params);
    }
    return $url;
}

#-------------------------------------------------------------------
# Template variables for normal form view and email message

sub getRecordTemplateVars {
	my $self = shift;
	my $var = shift;
    my $entryData = shift;
	my $i18n = WebGUI::International->new($self->session,"Asset_DataForm");
	$var->{"back.url"} = $self->getUrl;
	$var->{"back.label"} = $i18n->get(18);
	$var->{error_loop} = [] unless (exists $var->{error_loop});
	$var->{"form.start"} = WebGUI::Form::formHeader($self->session,{action=>$self->getUrl})
		.WebGUI::Form::hidden($self->session,{name=>"func",value=>"process"});
    my $fields = $self->getFieldConfig;
    # If we have an entry id, we're doing this based on existing data
    my $entry;
	if ($var->{entryId}) {
		$var->{"form.start"} .= WebGUI::Form::hidden($self->session,{name=>"entryId",value=>$var->{entryId}});
        $entry = $self->getCollateral("DataForm_entry","DataForm_entryId",$var->{entryId});
        $entryData = JSON::from_json( $entry->{entryData} );
        my $date = WebGUI::DateTime->new($self->session, $entry->{submissionDate})->cloneToUserTimeZone;
		$var->{ipAddress} = $entry->{ipAddress};
		$var->{username} = $entry->{username};
		$var->{userId} = $entry->{userId};
        $var->{date} = $date->webguiDate;
        $var->{epoch} = $date->epoch;
		$var->{"edit.URL"} = $self->getFormUrl('entryId='.$var->{entryId});
	    $var->{"delete.url"} = $self->getUrl('func=deleteEntry;entryId='.$var->{entryId});
	    $var->{"delete.label"} = $i18n->get(90);
	}
    my $ignoreForm = $self->session->form->process('func') eq 'editSave' || $self->session->form->process('func') eq 'editFieldSave';
    my %tabById;
    my @tabLoop;
    my $tabIdx = 0;
    for my $tabId (@{ $self->getTabOrder} ) {
        $tabIdx++;
        my $tab = $self->getTabConfig($tabId);
        my $tabVars = {
            "tab.start"         => '<div id="tabcontent' . $tabIdx . '" class="tabBody">',
            "tab.end"           => '</div>',
            "tab.sequence"      => $tabIdx,
            "tab.label"         => $tab->{label},
            "tab.tid"           => $tabId,
            "tab.subtext"       => $tab->{subtext},
            "tab.controls"      => $self->_tabAdminIcons($tabId),
            "tab.field_loop"    => [],
        };
        push @tabLoop, $tabVars;
        $tabById{$tabId} = $tabVars;
    }

    my @fieldLoop;
    my @fields = map { $self->getFieldConfig($_) } @{ $self->getFieldOrder };
    for my $field (@fields) {
        # need a copy
        my $value;
        if ($entry) {
            $value = $entryData->{ $field->{name} };
        }
        elsif (!$ignoreForm && defined (my $formValue = $self->session->form->process($field->{name}))) {
            $value = $formValue;
        }
        my $hidden = ($field->{status} eq 'hidden' && !$self->session->var->isAdminOn) || ($field->{isMailField} && !$self->get('mailData'));
        my $form = $self->_createForm($field, $value);
        $value = $form->getValueAsHtml;
        my %fieldProperties = (
            "form"          => $form->toHtml,
            "name"          => $field->{name},
            "tid"           => $field->{tabId},
            "inTab".$field->{tabId} => 1,
            "value"         => $form->getValueAsHtml,
            "label"         => $field->{label},
            "isMailField"   => $field->{isMailField},
            "isHidden"      => $hidden,
            "isDisplayed"   => ($field->{status} eq "visible" && !$hidden),
            "isRequired"    => ($field->{status} eq "required" && !$hidden),
            "subtext"       => $field->{subtext},
            "type"          => $field->{type},
            "controls"      => $self->_fieldAdminIcons($field->{name}),
        );
        my %fieldLoopEntry;
        my %tabLoopEntry;
        while (my ($propKey, $propValue) = each %fieldProperties) {
            $var->{"field.noloop.$field->{name}.$propKey"} = $propValue;
            $fieldLoopEntry{"field.$propKey"} = $propValue;
            $tabLoopEntry{"tab.field.$propKey"} = $propValue;
        }
        push @fieldLoop, \%fieldLoopEntry;
        my $tab = $tabById{$field->{tabId}};
        if ($tab) {
            push @{ $tab->{'tab.field_loop'} }, \%tabLoopEntry;
        }
    }
    $var->{field_loop} = \@fieldLoop;
    $var->{tab_loop} = \@tabLoop;
    $var->{'form.send'} = WebGUI::Form::submit($self->session,{value=>$i18n->get(73)});
    $var->{'form.save'} = WebGUI::Form::submit($self->session);
    # Create CAPTCHA if configured and user is not a Registered User
    if ( $self->useCaptcha ) {
        # Create one captcha we can use multiple times
        $var->{ 'form_captcha' } = WebGUI::Form::Captcha( $self->session, {
            name        => 'captcha',
        } );
    }
    $var->{"form.end"} = WebGUI::Form::formFooter($self->session);
    return $var;
}

#----------------------------------------------------------------------------

=head2 getTemplateVars ( )

Gets the default template vars for the asset. Includes the asset properties
as well as shared template vars.

=cut

sub getTemplateVars {
    my $self        = shift;
    my $var         = $self->get;
    my $i18n = WebGUI::International->new($self->session,"Asset_DataForm");

    $var->{ useCaptcha } = ( $self->useCaptcha ? 1 : 0 );
    $var->{canEdit} = ($self->canEdit);
    $var->{canViewEntries}  = ($self->session->user->isInGroup($self->get("groupToViewEntries")));
    $var->{"hasEntries"} = $self->hasEntries;
    $var->{"entryList.url"} = $self->getListUrl;
    $var->{"entryList.label"} = $i18n->get(86);
    $var->{"export.tab.url"} = $self->getUrl('func=exportTab');
    $var->{"export.tab.label"} = $i18n->get(84);
    $var->{"addField.url"} = $self->getUrl('func=editField');
    $var->{"addField.label"} = $i18n->get(76);
    $var->{"deleteAllEntries.url"} = $self->getUrl("func=deleteAllEntriesConfirm");
    $var->{"deleteAllEntries.label"} = $i18n->get(91);
    $var->{"javascript.confirmation.deleteAll"} = sprintf("return confirm('%s');",$i18n->get('confirm delete all'));
    $var->{"javascript.confirmation.deleteOne"} = sprintf("return confirm('%s');",$i18n->get('confirm delete one'));
    $var->{"addTab.label"}=  $i18n->get(105);;
    $var->{"addTab.url"}= $self->getUrl('func=editTab');
    $var->{"tab.init"}= $self->_createTabInit($self->getId);

    return $var;
}

#-------------------------------------------------------------------

=head2 hasEntries ( )

Returns number of entries that exist for this dataform.

=cut

sub hasEntries {
	my $self = shift;
	my ($entryCount) = $self->session->db->quickArray("select count(*) from DataForm_entry where assetId=?",[$self->getId]);
	
	return $entryCount;
}

#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
	my $self = shift;
	$self->SUPER::prepareView();
	# this one is so nutz that we don't even bother preparing, we just execute the whole thing
	my $passedVars = shift;
	##Priority encoding
	my $mode = $self->session->stow->get("mode") || $self->session->form->param("mode");
	if ( $mode eq "form") {
		$self->{_view} = $self->viewForm($passedVars);
	} elsif ( $mode eq "list") {
		$self->{_view} = $self->viewList;
	} elsif( $self->defaultViewForm ) {
		$self->{_view} = $self->viewForm($passedVars);
	} else {
		$self->{_view} = $self->viewList();
	}
}

#-------------------------------------------------------------------
sub purge {
    my $self = shift;
    $self->deleteAttachedFiles;
    $self->session->db->write("delete from DataForm_entry where assetId=?", [$self->getId]);
    return $self->SUPER::purge(@_);
}

#-------------------------------------------------------------------
sub sendEmail {
	my $self = shift;
	my $var = shift;
    my $entryData = shift;
    my $to = $entryData->{to};
    my $subject = $entryData->{subject};
    my $from = $entryData->{from};
    my $bcc = $entryData->{bcc};
    my $cc = $entryData->{cc};
    my $message = $self->processTemplate($var,$self->get("emailTemplateId"));
    WebGUI::Macro::process($self->session,\$message);
    my @attachments = $self->get('mailAttachments')
        ? @{ $self->getAttachedFiles($entryData) }
		: ();
	if ($to =~ /\@/) {
		my $mail = WebGUI::Mail::Send->create($self->session,{
		    to      => $to,
		    replyTo => $from,
		    subject => $subject,
		    cc      => $cc,
		    from    => $from,
		    bcc     => $bcc,
		});
		$mail->addHtml($message);
		$mail->addFooter;
		$mail->addAttachment($_) for (@attachments);
		$mail->queue;
	}
    else {
        my $userId;
        my $groupId;
        if (my $user = WebGUI::User->newByUsername($self->session, $to)) {
            $userId = $user->userId;
        }
        elsif (my $group = WebGUI::Group->find($self->session, $to)) {
            $groupId = $group->getId;
        }
        else {
            $self->session->errorHandler->warn($self->getId.": Unable to send message, no user or group found.");
            return;
        }
        WebGUI::Inbox->new($self->session)->addMessage({
            userId  => $userId,
            groupId => $groupId,
            sentBy  => $self->session->user->userId,
            subject => $subject,
            message => $message,
            status  => 'unread',
        });
        if ($cc) {
            my $mail =  WebGUI::Mail::Send->create($self->session,{to=>$cc, replyTo=>$from, subject=>$subject, from=>$from});
            $mail->addHtml($message);
            $mail->addAttachment($_) for (@attachments);
            $mail->addFooter;
            $mail->queue;
        }
        if ($bcc) {
            my $mail = WebGUI::Mail::Send->create($self->session, {to=>$bcc, replyTo=>$from, subject=>$subject, from=>$from});
            $mail->addHtml($message);
            $mail->addAttachment($_) for (@attachments);
            $mail->addFooter;
            $mail->queue;
        }
    }
}

#----------------------------------------------------------------------------

=head2 useCaptcha ( )

Returns true if we should use and process the CAPTCHA.

We should use the CAPTCHA if it is selected in the asset properties and the
user is not a Registered User.

=cut

sub useCaptcha {
    my $self        = shift;

    if ( $self->get('useCaptcha') ) {
        if ( !$self->session->user->isInGroup( '2' ) ) {
            return 1;
        }
    }

    return 0;
}

#-------------------------------------------------------------------
sub view {
	my $self = shift;
	return $self->{_view}; # see prepareView()
}

#-------------------------------------------------------------------

sub viewList {
	my $self    = shift;
    my $var     = $self->getTemplateVars;
	return $self->session->privilege->insufficient() unless ($self->session->user->isInGroup($self->get("groupToViewEntries")));
	return $self->processTemplate($self->getListTemplateVars($var),$self->get("listTemplateId"));
}

#-------------------------------------------------------------------

sub viewForm {
	my $self        = shift;
	my $passedVars  = shift;
	my $var         = $self->getTemplateVars;
	$self->session->style->setLink($self->session->url->extras('tabs/tabs.css'), {"type"=>"text/css"});
	$self->session->style->setScript($self->session->url->extras('tabs/tabs.js'), {"type"=>"text/javascript"});
	$var->{entryId} = $self->session->form->process("entryId") if ($self->canEdit);
	$var = $passedVars || $self->getRecordTemplateVars($var);
    #warn Data::Dumper::Dumper($var);
	return $self->processTemplate($var,$self->get("templateId"));
}

#-------------------------------------------------------------------
sub www_deleteAllEntriesConfirm {
	my $self = shift;
    return $self->session->privilege->insufficient() unless $self->canEdit;
    $self->deleteAttachedFiles;
    $self->session->db->write("DELETE FROM `DataForm_entry` WHERE `assetId`=?", [$self->getId]);
	return $self->www_view;
}

#-------------------------------------------------------------------
#sub www_deleteAttachedFile {
#	my $self = shift;
#	my $fieldId = $self->session->form->process('fieldId');
#	return $self->session->privilege->insufficient() unless ($self->canEdit);
#	$self->deleteAttachedFiles($fieldId);
#	return $self->www_view;
#}

#-------------------------------------------------------------------
sub www_deleteEntry {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;
    my $entryId = $self->session->form->process("entryId");
	$self->deleteAttachedFiles(entryId => $entryId);
	$self->deleteCollateral("DataForm_entry","DataForm_entryId",$entryId);
	$self->session->stow->set("mode","list");
	return $self->www_view;
}

#-------------------------------------------------------------------
sub www_deleteFieldConfirm {
    my $self = shift;
    return $self->session->privilege->insufficient() unless $self->canEdit;
    $self->deleteField($self->session->form->process("fieldName"));
    return "";
}

#-------------------------------------------------------------------
sub www_deleteTabConfirm {
	my $self = shift;
	return $self->session->privilege->insufficient() unless $self->canEdit;
    $self->deleteTab($self->session->form->process("tabId"));
    return "";
}

#-------------------------------------------------------------------
sub www_editField {
    my $self = shift;
    return $self->session->privilege->insufficient() unless $self->canEdit;
    my $i18n = WebGUI::International->new($self->session,"Asset_DataForm");
    my $fieldName = shift || $self->session->form->process("fieldName");
    my $field;
    undef $fieldName
        if $fieldName eq 'new';
    if ($fieldName) {
        $field = $self->getFieldConfig($fieldName);
    }
    else {
        $field = {};
    }
    my $f = WebGUI::HTMLForm->new($self->session,-action=>$self->getUrl);
    $f->hidden(
        name => "fieldName",
        value => $field->{name},
    );
    $f->hidden(
        name => "func",
        value => "editFieldSave"
    );
    $f->text(
        name=>"label",
        label=>$i18n->get(77),
        hoverHelp=>$i18n->get('77 description'),
        value=>$field->{label}
    );
    if ($field->{isMailField}) {
        $f->readOnly(
            name        => "newName",
            label       => $i18n->get(21),
            hoverHelp   => $i18n->get('21 description'),
            value       => $field->{name},
        );
    }
    else {
        $f->text(
            name        => "newName",
            label       => $i18n->get(21),
            hoverHelp   => $i18n->get('21 description'),
            value       => $field->{name},
        );
    }
    tie my %tabs, 'Tie::IxHash';
    %tabs = (
        0   => $i18n->get("no tab"),
        map { $_ => $self->getTabConfig($_)->{label} } @{ $self->getTabOrder },
    );
    $f->selectBox(
        name        => "tabId",
        options     => \%tabs,
        label       => $i18n->get(104),
        hoverHelp   => $i18n->get('104 description'),
        value       => [ $field->{tabId} ]
    );
    $f->text(
        name        => "subtext",
        value       => $field->{subtext},
        label       => $i18n->get(79),
        hoverHelp   => $i18n->get('79 description'),
    );
    tie my %fieldStatus, 'Tie::IxHash';
    %fieldStatus = (
        "hidden"    => $i18n->get(4),
        "visible"   => $i18n->get(5),
        "editable"  => $i18n->get(6),
        "required"  => $i18n->get(75),
    );
    $f->selectBox(
        name        => "status",
        options     => \%fieldStatus,
        label       => $i18n->get(22),
        hoverHelp   => $i18n->get('22 description'),
        value       => [ $field->{status} || "editable" ],
    );
    $f->fieldType(
        name        => "type",
        label       => $i18n->get(23),
        hoverHelp   => $i18n->get('23 description'),
        value       => "\u$field->{type}" || "Text",
        types       => [qw(DateTime TimeField Float Zipcode Text Textarea HTMLArea Url Date Email Phone Integer YesNo SelectList RadioList CheckList SelectBox File)],
    );
    $f->integer(
        name        => "width",
        label       => $i18n->get(8),
        hoverHelp   => $i18n->get('8 description'),
        value       => ($field->{width} || 0),
    );
    $f->integer(
        name        => "rows",
        value       => $field->{rows} || 0,
        label       => $i18n->get(27),
        hoverHelp   => $i18n->get('27 description'),
        subtext     => $i18n->get(28),
    );
    $f->yesNo(
        name=>"vertical",
        value=>$field->{vertical},
        label=>$i18n->get('editField vertical label'),
        hoverHelp=>$i18n->get('editField vertical label description'),
        subtext=>$i18n->get('editField vertical subtext')
    );
    $f->text(
        name=>"extras",
        value=>$field->{extras},
        label=>$i18n->get('editField extras label'),
        hoverHelp=>$i18n->get('editField extras label description'),
    );
    $f->textarea(
        -name=>"options",
        -label=>$i18n->get(24),
        -hoverHelp=>$i18n->get('24 description'),
        -value=>$field->{options},
        -subtext=>'<br />'.$i18n->get(85)
    );
    $f->textarea(
        -name=>"defaultValue",
        -label=>$i18n->get(25),
        -hoverHelp=>$i18n->get('25 description'),
        -value=>$field->{defaultValue},
        -subtext=>'<br />'.$i18n->get(85)
    );
    if (!$fieldName) {
        $f->whatNext(
            options => {
                "editField"     => $i18n->get(76),
                "viewDataForm"  => $i18n->get(745),
            },
            value  => "editField"
        );
    }
    $f->submit;
    my $ac = $self->getAdminConsole;
    return $ac->render($f->print,$i18n->get('20'));
}

#-------------------------------------------------------------------
sub www_editFieldSave {
    my $self = shift;
    return $self->session->privilege->insufficient() unless $self->canEdit;
    my $form = $self->session->form;
    my $fieldName = $form->process('fieldName');
    my $newName = $self->session->url->urlize($form->process('newName') || $form->process('label'));
    $newName =~ tr{-/}{};
    if ($fieldName) {
        my $field = $self->getFieldConfig($fieldName);
        if ($field->{isMailField}) {
            $newName = $fieldName;
        }
    }
    if (!$fieldName || $fieldName ne $newName) {
        my $i = '';
        while ($self->getFieldConfig($newName . $i)) {
            $i ||= 1;
            $i++;
        }
        $newName .= $i;
    }
    my $field;
    if ($fieldName) {
        if ($fieldName ne $newName) {
            $self->renameField($fieldName, $newName);
        }
        $field = $self->getFieldConfig($newName);
    }
    else {
        $field = {
            name => $newName,
        };
        $self->getFieldConfig->{$newName} = $field;
        push @{ $self->getFieldOrder }, $newName;
    }


    $field->{width}             = $form->process("width", 'integer');
    $field->{label}             = $form->process("label");
    $field->{tabId}             = $form->process("tabId") || undef;
    $field->{status}            = $form->process("status", 'selectBox');
    $field->{type}              = $form->process("type", 'fieldType');
    $field->{options}           = $form->process("options", 'textarea');
    $field->{defaultValue}      = $form->process("defaultValue", 'textarea');
    $field->{subtext}           = $form->process("subtext");
    $field->{rows}              = $form->process("rows", 'integer');
    $field->{vertical}          = $form->process("vertical", 'yesNo');
    $field->{extras}            = $form->process("extras"),
    $self->_saveFieldConfig;
    if ($self->session->stow->get('whatNext') eq "editField" || $form->process("proceed") eq "editField") {
        return $self->www_editField('new');
    }
    return "";
}

#-------------------------------------------------------------------
sub www_editTab {
    my $self = shift;
    return $self->session->privilege->insufficient() unless $self->canEdit;
    my $i18n = WebGUI::International->new($self->session,"Asset_DataForm");
    my $tabId = shift || $self->session->form->process("tabId") || "new";
    my $tab;
    unless ($tabId eq "new") {
        $tab = $self->getTabConfig($tabId);
    }

    my $f = WebGUI::HTMLForm->new($self->session,-action=>$self->getUrl);
    $f->hidden(
        -name => "tabIdd",
        -value => $tabId,
    );
    $f->hidden(
        -name => "func",
        -value => "editTabSave"
    );
    $f->text(
        -name=>"label",
        -label=>$i18n->get(101),
        -value=>$tab->{label}
    );
    $f->textarea(
        -name=>"subtext",
        -label=>$i18n->get(79),
        -value=>$tab->{subtext},
        -subtext=>""
    );
    if ($tabId eq "new") {
        $f->whatNext(
            options=>{
                editTab=>$i18n->get(103),
                ""=>$i18n->get(745)
            },
            -value=>"editTab"
        );
    }
    $f->submit;
    my $ac = $self->getAdminConsole;
    return $ac->render($f->print,$i18n->get('103')) if $tabId eq "new";
    return $ac->render($f->print,$i18n->get('102'));
}

#-------------------------------------------------------------------
sub www_editTabSave {
    my $self = shift;
    return $self->session->privilege->insufficient() unless $self->canEdit;
    my $name = $self->session->form->process("name") || $self->session->form->process("label");
    $name = $self->session->url->urlize($name);
    my $tabId = $self->session->form->process('tabId');
    undef $tabId
        if $tabId eq 'new';

    $name =~ tr{-/}{};
    my $tab;
    if (!$tabId || !($tab = $self->getTabConfig($tabId)) ) {
        $tabId = $self->session->id->generate;
        $tab = {
            tabId   => $tabId,
        };
        $self->getTabConfig->{$tabId} = $tab;
        push @{ $self->getTabOrder }, $tabId;
    }
    $tab->{label}   = $self->session->form->process("label");
    $tab->{subtext} = $self->session->form->process("subtext", 'textarea');
    $self->_saveTabConfig;
    if ($self->session->form->process("proceed") eq "editTab") {
        return $self->www_editTab("new");
    }
    return "";
}

#-------------------------------------------------------------------
sub www_exportTab {
        my $self = shift;
        return $self->session->privilege->insufficient() unless $self->canEdit;
        my @exportRows;
        my $entries = $self->session->db->read("select * from DataForm_entry where assetId=?", [$self->getId]);
        my @exportFields;
        for my $field ( map { $self->getFieldConfig($_) } @{ $self->getFieldOrder } ) {
            next
                if $field->{isMailField} && !$self->get('mailData');
            push @exportFields, $field->{name};
        }
        my $tsv = Text::CSV_XS->new({sep_char => "\t", eol => "\n"});
        $tsv->combine(
            'entryId',
            'ipAddress',
            'username',
            'userId',
            'submissionDate',
            @exportFields,
        );
        my $outText = $tsv->string;

        while (my $entryData = $entries->hashRef) {
            my $entryFields = JSON::from_json($entryData->{entryData});
            $tsv->combine(
                $entryData->{DataForm_entryId},
                $entryData->{ipAddress},
                $entryData->{username},
                $entryData->{userId},
                WebGUI::DateTime->new($self->session, $entryData->{submissionDate})->webguiDate,
                @{ $entryFields }{@exportFields},
            );
            $outText .= $tsv->string;
        }
        $entries->finish;
        $self->session->http->setFilename($self->get("url").".tab","text/plain");
        return $outText;
}

#-------------------------------------------------------------------
sub www_moveFieldDown {
    my $self = shift;
    return $self->session->privilege->insufficient() unless $self->canEdit;
    my $fieldName = $self->session->form->process('fieldName');
    my $fieldOrder = $self->getFieldOrder;
    my $currentPos;
    for ($currentPos = 0; $currentPos < @$fieldOrder; $currentPos++) {
        last
            if $fieldName eq $fieldOrder->[$currentPos];
    }
    my $tabId = $self->getFieldConfig($fieldName)->{tabId};
    my $newPos;
    for ($newPos = $currentPos + 1; $newPos < @$fieldOrder; $newPos++) {
        last
            if $tabId eq $self->getFieldConfig($fieldOrder->[$newPos])->{tabId};
    }
    if ($newPos < @$fieldOrder) {
        splice @$fieldOrder, $newPos, 0, splice(@$fieldOrder, $currentPos, 1);
        $self->_saveFieldConfig;
    }
    return "";
}

#-------------------------------------------------------------------
sub www_moveFieldUp {
    my $self = shift;
    return $self->session->privilege->insufficient() unless $self->canEdit;
    my $fieldName = $self->session->form->process('fieldName');
    my $fieldOrder = $self->getFieldOrder;
    my $currentPos;
    for ($currentPos = 0; $currentPos < @$fieldOrder; $currentPos++) {
        last
            if $fieldName eq $fieldOrder->[$currentPos];
    }
    my $tabId = $self->getFieldConfig($fieldName)->{tabId};
    my $newPos;
    for ($newPos = $currentPos - 1; $newPos < 0; $newPos--) {
        last
            if $tabId eq $self->getFieldConfig($fieldOrder->[$newPos])->{tabId};
    }

    if ($newPos >= 0) {
        splice @$fieldOrder, $newPos, 0, splice(@$fieldOrder, $currentPos, 1);
        $self->_saveFieldConfig;
    }
    return "";
}

#-------------------------------------------------------------------
sub www_moveTabRight {
    my $self = shift;
    return $self->session->privilege->insufficient() unless $self->canEdit;
    my $tabId = $self->session->form->process('tabId');
    my $tabOrder = $self->getTabOrder;
    my $currentPos;
    for ($currentPos = 0; $currentPos < @$tabOrder; $currentPos++) {
        last
            if $tabId eq $tabOrder->[$currentPos];
    }
    my $newPos = $currentPos + 1;
    if ($newPos < @$tabOrder) {
        splice @$tabOrder, $newPos, 0, splice(@$tabOrder, $currentPos, 1);
        $self->_saveFieldConfig;
    }
    return "";
}

#-------------------------------------------------------------------
sub www_moveTabLeft {
    my $self = shift;
    return $self->session->privilege->insufficient() unless $self->canEdit;
    my $tabId = $self->session->form->process('tabId');
    my $tabOrder = $self->getTabOrder;
    my $currentPos;
    for ($currentPos = 0; $currentPos < @$tabOrder; $currentPos++) {
        last
            if $tabId eq $tabOrder->[$currentPos];
    }
    my $newPos = $currentPos - 1;
    if ($newPos >= 0) {
        splice @$tabOrder, $newPos, 0, splice(@$tabOrder, $currentPos, 1);
        $self->_saveFieldConfig;
    }
    return "";
}

#-------------------------------------------------------------------
sub www_process {
    my $self = shift;
    return $self->session->privilege->insufficient() unless $self->canView;
    my $session = $self->session;
    my $db      = $self->session->db;
    my $i18n    = WebGUI::International->new($session,"Asset_DataForm");
    my $entryId = $self->session->form->process('entryId');
    my $entry;
    my $entryData;
    if ($entryId) {
        my $entry = $self->getCollateral("DataForm_entry","DataForm_entryId", $entryId);
        eval {
            $entryData = JSON::from_json($entry->{entryData});
        };
    }

    my $var = $self->getTemplateVars;

    # Process form
    my (@errors, $updating, $hadErrors);
    for my $field (values %{ $self->getFieldConfig }) {
        my $default = $field->{defaultValue};
        WebGUI::Macro::process($self->session, \$default);
        my $value = $entryData->{ $field->{name} } || $default;
        if ($field->{status} eq "required" || $field->{status} eq "editable") {
            $value = $self->session->form->process($field->{name}, $field->{type}, undef, {
                defaultValue    => $default,
                value           => $value,
            });
            WebGUI::Macro::filter(\$value);
        }
        if ($field->{status} eq "required" && (! defined($value) || $value =~ /^\s*$/)) {
            push @errors, {
                "error.message" => $field->{label} . " " . $i18n->get(29) . ".",
            };
        }
        $entryData->{ $field->{name} } = $value;
    }

    # Process CAPTCHA
    if ( $self->useCaptcha ) {
        if ( !$self->session->form->process( 'captcha', 'captcha' ) ) {
            push @errors, {
                "error.message" => $i18n->get( 'error captcha' ),
            };
        }
    }

    $var->{error_loop} = \@errors;
    $var = $self->getRecordTemplateVars($var, $entryData);
    if (@errors) {
        $self->prepareView($var);
        return $self->processStyle($self->view);
    }
    if ($self->get("mailData") && !$entryId) {
        $self->sendEmail($var, $entryData);
    }
    if ($self->get('storeData')) {
        my $entryJSON = JSON::to_json($entryData);
        my $collData = {
            DataForm_entryId    => $entryId,
            userId              => $self->session->user->userId,
            username            => $self->session->user->username,
            ipAddress           => $self->session->env->getIp,
            submissionDate      => WebGUI::DateTime->new($self->session, time())->toDatabase,
            entryData           => $entryJSON,
        };
        $self->setCollateral("DataForm_entry","DataForm_entryId", $collData, 0, 1);
    }
    return $self->session->style->process($self->processTemplate($var,$self->get("acknowlegementTemplateId")),$self->get("styleTemplateId"))
        if $self->defaultViewForm;
}

1;

