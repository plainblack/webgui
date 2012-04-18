package WebGUI::Asset::Wobject::DataForm;

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
use Tie::IxHash;
use WebGUI::Form;
use WebGUI::HTMLForm;
use WebGUI::International;
use WebGUI::Mail::Send;
use WebGUI::Macro;
use WebGUI::Inbox;
use WebGUI::SQL;
use WebGUI::Asset::Wobject;
use WebGUI::Pluggable;
use WebGUI::DateTime;
use WebGUI::User;
use WebGUI::Utility;
use WebGUI::Group;
use WebGUI::AssetCollateral::DataForm::Entry;
use WebGUI::Form::SelectRichEditor;
use WebGUI::Paginator;
use JSON ();

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
    my $self    = shift;
    my $data    = shift;
    my $value   = shift;
    my $session = $self->session;
    # copy select entries
    my %param      = map { $_ => $data->{$_} } qw(name width extras vertical defaultValue options);
    $param{value}  = $value;
    $param{size}   = $param{width};
    $param{height} = $data->{rows};

    WebGUI::Macro::process($session, \( $param{defaultValue} ));

    my $type = ucfirst $data->{type};
    my $class = "WebGUI::Form::$type";
    if (!  eval { WebGUI::Pluggable::load("WebGUI::Form::$type"); } ) {
        $session->log->error( "Unable to load form control - $type" );
        return undef;
    }
    if ($type eq "Checkbox") {
        $param{defaultValue} = ($param{defaultValue} =~ /checked/i);
    }
    elsif ( $class->isa('WebGUI::Form::List') ) {
        delete $param{size};
    }
    elsif ( $type eq 'HTMLArea' && $data->{htmlAreaRichEditor} ne '**Use_Default_Editor**') {
        $param{richEditId} = $data->{htmlAreaRichEditor}  ;
    }
    return $class->new($session, \%param);
}

#-------------------------------------------------------------------

=head2 _getFormFields ( )

Return a list of form fields for this DataForm.

=cut

sub _getFormFields {
    my $self          = shift;
    my $session       = $self->session;
    my $entry         = $self->entry;
    my @orderedFields = map { $self->getFieldConfig($_) } @{ $self->getFieldOrder };
    my $func       = $session->form->process('func');
    my $ignoreForm = $func eq 'editSave' || $func eq 'editFieldSave';
    my @forms      = ();
    for my $field (@orderedFields) {
        my $value;
        if ($entry) {
            $value = $entry->field( $field->{name} );
        }
        elsif (!$ignoreForm && defined (my $formValue = $self->session->form->process($field->{name}))) {
            $value = $formValue;
        }
        my $hidden
            = ($field->{status} eq 'hidden' && !$session->var->isAdminOn)
            || ($field->{isMailField} && !$self->get('mailData'));
	
        # populate Rich Editor field if the field is an HTMLArea
        if ($field->{type} eq "HTMLArea") { 
            $field->{htmlAreaRichEditor} = $self->get("htmlAreaRichEditor") ;
        }
        my $form = $self->_createForm($field, $value);
        $form->headTags();
        push @forms, [$field, $form];
    }
    return @forms;
}

#-------------------------------------------------------------------
sub _fieldAdminIcons {
    my $self = shift;
    my $fieldName = shift;
    my $i18n = WebGUI::International->new($self->session,"Asset_DataForm");
    my $mode = ";mode=" . $self->currentView;
    my $output;
    $output = $self->session->icon->delete('func=deleteFieldConfirm;fieldName='.$fieldName.$mode,$self->get("url"),$i18n->get(19))
        unless $self->getFieldConfig($fieldName)->{isMailField};
    $output .= $self->session->icon->edit('func=editField;fieldName='.$fieldName.$mode,$self->get("url"))
        . $self->session->icon->moveUp('func=moveFieldUp;fieldName='.$fieldName.$mode,$self->get("url"))
        . $self->session->icon->moveDown('func=moveFieldDown;fieldName='.$fieldName.$mode,$self->get("url"));
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

=head2 defaultViewForm 

Returns true if defaultView is set to 0.

=cut

sub defaultViewForm {
    my $self = shift;
    return ($self->get("defaultView") == 0);
}

#-------------------------------------------------------------------

=head2 defaultView 

Returns the kind of default view.  If defaultView == 0, it returns 'form'.  Otherwise,
it returns 'list'.

=cut

sub defaultView {
    my $self = shift;
    return ($self->get("defaultView") == 0 ? 'form' : 'list');
}

#-------------------------------------------------------------------

=head2 currentView 

By priority, returns that the current view is.  First, it checks in internally
cached mode, then it checks for a C<mode> form parameter, then it resorts to defaultView.

=cut

sub currentView {
    my $self = shift;
    my $view = $self->{_mode} || $self->session->form->param('mode') || $self->defaultView;
    return $view;
}

#-------------------------------------------------------------------

=head2 deleteField ($fieldName)

Removes a field from the DataForm.

=head3 $fieldName

The name of a field to delete.

=cut

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

#-------------------------------------------------------------------

=head2 deleteTab ( $tabId )

Deletes a tab from the tabs in this DataForm.

=head3 $tabId

The GUID of a tab to delete.

=cut

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

#-------------------------------------------------------------------

=head2 getContentLastModified 

Extends the base method to modify caching.  If the currentView is in list mode, or
an entry is being viewed, or the DataForm has a captcha, bypass caching altogether.

=cut

sub getContentLastModified {
    my $self = shift;
    if ($self->currentView eq 'list' || $self->session->form->process('entryId') || $self->hasCaptcha) {
        return time;
    }
    return $self->SUPER::getContentLastModified;
}

#-------------------------------------------------------------------

=head2 entry ( [ $entry ] )

Returns a DataForm Entry object.  If one is cached in the object, it will return it.
If the current request object has an entryId, then it will fetch the Entry from the database.
Otherwise, it will return an empty DataForm Entry object.

=head3 $entry

A DataForm Entry object.  If passed, it will set the cache in this object.  This takes precedence
over any other option.

=cut

sub entry {
    my $self = shift;
    my $entry = shift;
    $self->{_entry} = $entry if defined $entry;
    return $self->{_entry} if $self->{_entry};
    my $entryId = $self->session->form->process("entryId");
    $self->{_entry} = $self->entryClass->new($self, ($entryId && $self->canEdit) ? $entryId : ());
    return $self->{_entry};
}

#-------------------------------------------------------------------

=head2 hasCaptcha

Returns true if the DataForm uses a captcha as one of the fields.

=cut

sub hasCaptcha {
    my $self = shift;
    return isIn('Captcha', map { $_->{type} } map { $self->getFieldConfig($_) } @{ $self->getFieldOrder });
}

#-------------------------------------------------------------------

=head2 renameField ($oldName, $newName)

Renames a field by name

=head3 $oldName

The old name of the field.

=head3 $newName

The new name of the field.

=cut

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
    return $self->getFieldConfig->{$newName}{name} = $newName;
}

#-------------------------------------------------------------------

sub _saveFieldConfig {
    my $self = shift;
    my @config = map {
        $self->getFieldConfig($_)
    } @{ $self->getFieldOrder };
    my $data = JSON::to_json(\@config);
    $self->update({fieldConfiguration => $data});
}

#-------------------------------------------------------------------

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
    
    # populate hash of Rich Editors and add an entry to the list to use the default
    my $selectRichEditor = WebGUI::Form::SelectRichEditor->new($session,{}) ;
    my $richEditorOptions  = $selectRichEditor->getOptions() ;
    $richEditorOptions->{'**Use_Default_Editor**'} = $i18n->get("Use Default Rich Editor");
    
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
        htmlAreaRichEditor =>{
            fieldType=>"selectBox",
            defaultValue=>0,
            options=>$richEditorOptions,
            tab=>'display',
            label=>$i18n->get('htmlAreaRichEditor'),
            hoverHelp=>$i18n->get('htmlAreaRichEditor description'),
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
        workflowIdAddEntry  => {
            tab             => "properties",
            fieldType       => "workflow",
            defaultValue    => undef,
            type            => "WebGUI::AssetCollateral::DataForm::Entry",
            none            => 1,
            label           => $i18n->get('editForm workflowIdAddEntry label'),
            hoverHelp       => $i18n->get('editForm workflowIdAddEntry description'),
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

#-------------------------------------------------------------------

sub _cacheFieldConfig {
    my $self = shift;
    if (!$self->{_fieldConfig}) {
        my $jsonData = $self->get("fieldConfiguration");
        my $fieldData;
        if ($jsonData && eval { $jsonData = JSON::from_json($jsonData) ; 1 }) {
            # jsonData is an array in the order the fields should be
            $self->{_fieldConfig} = {};
            $self->{_fieldOrder}  = [];
            FIELD: foreach my $field (@{ $jsonData } ) {
                next FIELD unless ref $field eq 'HASH';
                $self->{_fieldConfig}->{$field->{name}} = $field;
                push @{ $self->{_fieldOrder} }, $field->{name};
            }
        }
        else {
            $self->{_fieldConfig} = {};
            $self->{_fieldOrder} = [];
        }
    }
    return 1;
}

#-------------------------------------------------------------------

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

#-------------------------------------------------------------------

=head2 getFieldConfig ($field)

Returns the configuration for 1 field.

=head3 $field

The GUID of the field to return.  If left blank, it will return configurations for
all fields in this DataForm.

=cut

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

#-------------------------------------------------------------------

=head2 getFieldOrder 

Returns the internally cached field order, an array reference.

=cut

sub getFieldOrder {
    my $self = shift;
    $self->_cacheFieldConfig;
    return $self->{_fieldOrder};
}

#-------------------------------------------------------------------

=head2 getTabConfig ( $tabId )

Returns the configuration for 1 tab.

=head3 $tabId

The GUID of the tab to return a configuration for.  If no tabId is passed, then
it returns the configurations for all of them.

=cut

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

#-------------------------------------------------------------------

=head2 getTabOrder 

Returns the order of the tabs, an array reference.

=cut

sub getTabOrder {
    my $self = shift;
    $self->_cacheTabConfig;
    return $self->{_tabOrder};
}


#-------------------------------------------------------------------

=head2 deleteAttachedFiles 

Deletes all files attached to this DataForm, or to any fields or entries in the DataForm.

=cut

sub deleteAttachedFiles {
    my $self = shift;
    my %params = @_;
    my $entryData = $params{entryData};
    my $entryId = $params{entryId};

    my $fields = $self->getFieldOrder;
    my $fieldConfig = $self->getFieldConfig;

    if ($entryId) {
        my $entry = $self->entryClass->new($self, $entryId);
        $entryData = $entry->fields;
    }
    if ($entryData) {
        for my $field ( @$fields ) {
            my $form = $self->_createForm($fieldConfig->{$field}, $entryData->{$field});
            if ($form->can('getStorageLocation')) {
                my $storage = $form->getStorageLocation;
                $storage->delete if $storage;
            }
        }
    }
    else {
        my $entryIter = $self->entryClass->iterateAll($self);
        while (my $entry = $entryIter->()) {
            my $entryData = $entry->fields;
            for my $field (@{ $fields }) {
                my $form = $self->_createForm($fieldConfig->{$field}, $entryData->{$field});
                if ($form->can('getStorageLocation')) {
                    my $storage = $form->getStorageLocation;
                    $storage->delete if $storage;
                }
            }
        }
    }
}

#-------------------------------------------------------------------

=head2 getAttachedFiles ( $entryData )

Return an array reference to every file in every storage location in every field for
one set of entryData.

=head3 $entryData

=cut

sub getAttachedFiles {
    my $self = shift;
    my $entryData = shift;
    my $fieldConfig = $self->getFieldConfig;
    my @paths;
    for my $field ( values %{$fieldConfig} ) {
        my $form = $self->_createForm($field, $entryData->field($field->{name}));
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

=head2 getListTemplateVars ( $var )

Appends template variables for list mode.

=head3 $var

A hash reference.  New template variables will be appended to it.

=cut

sub getListTemplateVars {
	my $self    = shift;
    my $session = $self->session;
	my $var     = shift;
	my $i18n    = WebGUI::International->new($session,"Asset_DataForm");
	$var->{"back.url"} = $self->getFormUrl;
	$var->{"back.label"} = $i18n->get('go to form');
    my $fieldConfig = $self->getFieldConfig;
    my @fieldLoop = map {
        +{
            'field.name'        => $fieldConfig->{$_}{name},
            'field.label'       => $fieldConfig->{$_}{label},
            'field.isMailField' => $fieldConfig->{$_}{isMailField},
            'field.type'        => $fieldConfig->{$_}{type},
            "field.controls"          => $self->_fieldAdminIcons($fieldConfig->{$_}{name}),
        }
    } @{ $self->getFieldOrder };
    $var->{field_loop} = \@fieldLoop;
    my @recordLoop;
    my $p = WebGUI::Paginator->new($session,$self->getUrl("mode=list"));
    $p->setDataByCallback(sub { return $self->entryClass->iterateAll($self, { offset => $_[0], limit => $_[1], }); });
    my $entryIter = $p->getPageIterator();
    while ( my $entry = $entryIter->() ) {
        my $entryData = $entry->fields;
        my @dataLoop;
        my %dataVars;
        for my $fieldName ( @{ $self->getFieldOrder } ) {
            my $field = $fieldConfig->{$fieldName};
            my $form = $self->_createForm($field, $entryData->{$fieldName});
            $dataVars{ 'record.noloop.' . $fieldName } = $entryData->{$fieldName};
            push @dataLoop, {
                "record.data.name"          => $field->{name},
                "record.data.label"         => $field->{label},
                "record.data.value"         => $form->getValueAsHtml,
                "record.data.isMailField"   => $field->{isMailField},
                "record_data_type"          => $field->{type},
            };
        }
        push @recordLoop, {
            %dataVars,
            "record.ipAddress"              => $entry->ipAddress,
            "record.edit.url"               => $self->getFormUrl("func=view;entryId=".$entry->getId),
            "record.edit.icon"              => $session->icon->edit("func=view;entryId=".$entry->getId, $self->get('url')),
            "record.delete.url"             => $self->getUrl("func=deleteEntry;entryId=".$entry->getId),
            "record.delete.icon"            => $session->icon->delete("func=deleteEntry;entryId=".$entry->getId, $self->get('url'), $i18n->get('Delete entry confirmation')),
            "record.username"               => $entry->username,
            "record.userId"                 => $entry->userId,
            "record.submissionDate.epoch"   => $entry->submissionDate->epoch,
            "record.submissionDate.human"   => $entry->submissionDate->cloneToUserTimeZone->webguiDate,
            "record.entryId"                => $entry->getId,
            "record.data_loop"              => \@dataLoop
        };
    }
    $var->{record_loop} = \@recordLoop;
    $p->appendTemplateVars($var);
    return $var;
}

#-------------------------------------------------------------------

=head2 getFormUrl ($params)

Returns a URL to this DataForm in form mode.

=head3 $params

URL parameters to append to the form URL.

=cut

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

=head2 getRecordTemplateVars ($var, $entry)

Template variables for normal form view and email message

=head3 $var

A hash reference.  Template variables will be appended to it.

=head3 $entry

The data entered by the user, as a WebGUI::AssetCollateral::DataForm::Entry object.

=cut

sub getRecordTemplateVars {
    my $self = shift;
    my $var = shift;
    my $entry = shift;
    my $session = $self->session;
    my $i18n = WebGUI::International->new($session, 'Asset_DataForm');
    $var->{'back.url'} = $self->getUrl;
    $var->{'back.label'} = $i18n->get(18);
    $var->{'error_loop'} ||= [];
    $var->{'form.start'}
        = WebGUI::Form::formHeader($session, {action => $self->getUrl})
        . WebGUI::Form::hidden($session, {name => 'func', value => 'process'})
        ;
    my $fields = $self->getFieldConfig;
    # If we have an entry, we're doing this based on existing data
    my $entryData;
    if ($entry) {
        my $entryId = $entry->getId;
        $var->{'form.start'} .= WebGUI::Form::hidden($session,{name => "entryId", value => $entryId});
        $entryData = $entry->fields;
        my $date = $entry->submissionDate->cloneToUserTimeZone;
        $var->{'ipAddress'      } = $entry->ipAddress;
        $var->{'username'       } = $entry->username;
        $var->{'userId'         } = $entry->userId;
        $var->{'date'           } = $date->webguiDate;
        $var->{'epoch'          } = $date->epoch;
        $var->{'edit.URL'       } = $self->getFormUrl('entryId=' . $entryId);
        $var->{'delete.url'     } = $self->getUrl('func=deleteEntry;entryId=' . $entryId);
        $var->{'delete.label'   } = $i18n->get(90);
        $var->{'entryId'        } = $entryId;
    }

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
    if (!$self->{_cached_forms}) {
        $self->{_cached_forms} = [ $self->_getFormFields($entry) ];
    }
    my @fields = @{ $self->{_cached_forms} };
    for my $field_form (@fields) {
        my ($field, $form) = @{ $field_form };
        # need a copy
        my $hidden =  ($field->{status} eq 'hidden' && !$session->var->isAdminOn)
                   || ($field->{isMailField} && !$self->get('mailData'));
	
        # populate Rich Editor field if the field is an HTMLArea
        if ($field->{type} eq "HTMLArea") { 
            $field->{htmlAreaRichEditor} = $self->get("htmlAreaRichEditor") ;
        }
        my $value = $form->getValueAsHtml;
        my %fieldProperties = (
            "form"          => $form->toHtml,
            "name"          => $field->{name},
            "tid"           => $field->{tabId},
            "value"         => $form->getValueAsHtml,
            "label"         => $field->{label},
            "isMailField"   => $field->{isMailField},
            "isHidden"      => $hidden,
            "isDisplayed"   => ($field->{status} eq "visible" && !$hidden),
            "isRequired"    => ($field->{status} eq "required" && !$hidden),
            "subtext"       => $field->{subtext},
            "type"          => $field->{type},
            "controls"      => $self->_fieldAdminIcons($field->{name}),
            "inTab"         => ($field->{tabId} ? 1 : 0),
        );
        my %fieldLoopEntry;
        my %tabLoopEntry;
        while (my ($propKey, $propValue) = each %fieldProperties) {
            $var->{"field.noloop.$field->{name}.$propKey"} = $propValue;
            $fieldLoopEntry{"field.$propKey"} = $propValue;
            $tabLoopEntry{"tab.field.$propKey"} = $propValue;
        }
        push @fieldLoop, \%fieldLoopEntry;
        my $tab = $tabById{ $field->{tabId} };
        if ($tab) {
            push @{ $tab->{'tab.field_loop'} }, \%tabLoopEntry;
        }
    }
    $var->{field_loop} = \@fieldLoop;
    $var->{tab_loop} = \@tabLoop;
    $var->{'form.send'} = WebGUI::Form::submit($session, { value => $i18n->get(73) });
    $var->{'form.save'} = WebGUI::Form::submit($session);
    # Create CAPTCHA if configured and user is not a Registered User
    if ( $self->useCaptcha ) {
        # Create one captcha we can use multiple times
        $var->{ 'form_captcha' } = WebGUI::Form::Captcha( $session, {
            name        => 'captcha',
        } );
    }
    $var->{'form.end'} = WebGUI::Form::formFooter($session);
    return $var;
}

#----------------------------------------------------------------------------

=head2 getTemplateVars ( $var )

Gets the default template vars for the asset. Includes the asset properties
as well as shared template vars.

=head3 $var

A hash reference.  Template variables are appended to it.

=cut

sub getTemplateVars {
    my $self        = shift;
    my $var         = $self->get;
    my $i18n = WebGUI::International->new($self->session,"Asset_DataForm");

    $var->{'useCaptcha'             } = ( $self->useCaptcha ? 1 : 0 );
    $var->{'canEdit'                } = ($self->canEdit);
    $var->{'canViewEntries'         }  = ($self->session->user->isInGroup($self->get("groupToViewEntries")));
    $var->{'hasEntries'             } = $self->hasEntries;
    $var->{'entryList.url'          } = $self->getListUrl;
    $var->{'entryList.label'        } = $i18n->get(86);
    $var->{'export.tab.url'         } = $self->getUrl('func=exportTab');
    $var->{'export.tab.label'       } = $i18n->get(84);
    $var->{'addField.url'           } = $self->getUrl('func=editField');
    $var->{'addField.label'         } = $i18n->get(76);
    $var->{'deleteAllEntries.url'   } = $self->getUrl("func=deleteAllEntriesConfirm");
    $var->{'deleteAllEntries.label' } = $i18n->get(91);
    $var->{'javascript.confirmation.deleteAll'}
        = sprintf("return confirm('%s');",$i18n->get('confirm delete all'));
    $var->{'javascript.confirmation.deleteOne'}
        = sprintf("return confirm('%s');",$i18n->get('confirm delete one'));
    $var->{'addTab.label'           } =  $i18n->get(105);;
    $var->{'addTab.url'             }= $self->getUrl('func=editTab');
    $var->{'tab.init'               }= $self->_createTabInit($self->getId);

    return $var;
}

#-------------------------------------------------------------------

=head2 hasEntries ( )

Returns number of entries that exist for this dataform.

=cut

sub hasEntries {
    my $self = shift;
    return $self->entryClass->getCount($self);
}

#-------------------------------------------------------------------

=head2 prepareView ( )

Extends the base class to handle form and list mode.

=cut

sub prepareView {
    my $self = shift;
    $self->SUPER::prepareView(@_);
    my $view = $self->currentView;
    if ( $view eq 'form' ) {
        $self->prepareViewForm(@_);
    }
    else {
        $self->prepareViewList(@_);
    }
}

#-------------------------------------------------------------------

=head2 purge 

Extends the base method to handle deleting attached files and purging the
entry collateral.

=cut

sub purge {
    my $self = shift;
    $self->deleteAttachedFiles;
    $self->entryClass->purgeAssetEntries($self);
    return $self->SUPER::purge(@_);
}

#-------------------------------------------------------------------

=head2 sendEmail ($var, $entry)

Sends an email with information about the data entered by the user.  The email
is templated, and macros in the template will be expanded.

=head3 $var

A hash reference of template variables

=head3 $entry

The data entered by the user, as a WebGUI::AssetCollateral::DataForm::Entry object.

=cut

sub sendEmail {
    my $self = shift;
    my $var = shift;
    my $entry = shift;
    my $to = $entry->field('to');
    my $subject = $entry->field('subject');
    my $from = $entry->field('from');
    my $bcc = $entry->field('bcc');
    my $cc = $entry->field('cc');
    my $message = $self->processTemplate($var, $self->get("emailTemplateId"));
    WebGUI::Macro::process($self->session,\$message);
    my @attachments = $self->get('mailAttachments')
        ? @{ $self->getAttachedFiles($entry) }
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
            $self->session->errorHandler->warn($self->getId . ": Unable to send message, no user or group found.");
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

    if ( $self->get('useCaptcha') && $self->session->user->isVisitor ) {
        return 1;
    }

    return 0;
}

#-------------------------------------------------------------------

=head2 view 

Based on the view mode, renders either the form or the list.

=cut

sub view {
    my $self = shift;
    my $view = $self->currentView;
    if ( $view eq 'form' ) {
        return $self->viewForm(@_);
    }
    else {
        return $self->viewList(@_);
    }
}

#-------------------------------------------------------------------

=head2 canView 

Extends the base method to include users who can edit the DataForm in list mode,
or are part of the groupToViewEntries.

=cut

sub canView {
    my $self = shift;
    return 0
        if !$self->SUPER::canView;
    if ($self->currentView eq 'list') {
        return 1
            if $self->canEdit;
        return 1
            if $self->session->user->isInGroup($self->get('groupToViewEntries'));
        return 0;
    }
    return 1;
}

#-------------------------------------------------------------------

=head2 prepareViewList 

Like prepareView, but for the list view of the template.

=cut

sub prepareViewList {
    my $self = shift;
    my $templateId = $self->get('listTemplateId');
    my $template = WebGUI::Asset::Template->new($self->session, $templateId);
    if (!$template) {
        WebGUI::Error::ObjectNotFound::Template->throw(
            error      => qq{Template not found},
            templateId => $templateId,
            assetId    => $self->getId,
        );
    }
    $template->prepare($self->getMetaDataAsTemplateVariables);
    $self->{_viewListTemplate} = $template;
}

#-------------------------------------------------------------------

=head2 viewList 

Renders the list view of the DataForm.

=cut

sub viewList {
    my $self    = shift;
    return $self->session->privilege->insufficient
        unless $self->session->user->isInGroup($self->get("groupToViewEntries"));
    my $var     = $self->getTemplateVars;
    return $self->processTemplate($self->getListTemplateVars($var), undef, $self->{_viewListTemplate});
}

#-------------------------------------------------------------------

=head2 prepareViewForm 

Prepare the template for the form mode of the template.

=cut

sub prepareViewForm {
    my $self = shift;
    $self->session->style->setLink($self->session->url->extras('tabs/tabs.css'), {"type"=>"text/css"});
    $self->session->style->setScript($self->session->url->extras('tabs/tabs.js'), {"type"=>"text/javascript"});
    my $templateId = $self->get('templateId');
    my $template = WebGUI::Asset::Template->new($self->session, $templateId);
    if (!$template) {
        WebGUI::Error::ObjectNotFound::Template->throw(
            error      => qq{Template not found},
            templateId => $templateId,
            assetId    => $self->getId,
        );
    }
    ##Check to see if this already exists, since in www_process, getRecordTemplateVars is
    ##called before prepareViewForm.  Normally, however, this prepareViewForm will be called
    ##first.
    if (!$self->{_cached_forms}) {
        $self->{_cached_forms} = [ $self->_getFormFields() ];
    }
    $template->prepare($self->getMetaDataAsTemplateVariables);
    $self->{_viewFormTemplate} = $template;
}

#-------------------------------------------------------------------

=head2 viewForm ($passedVars, $entry)

Render the template for viewing the form of the DataForm.

=head3 $passedVars

A hash ref of template variables.  If passed in, the default record template
variables will not be fetched.

=head3 $entry

A DataForm::Entry collateral object.  If not passed in, then it will try to look up
an entry via the form variable C<entryId>.  If the user cannot edit the DataForm,
then they cannot edit data that has already been entered.

=cut

sub viewForm {
    my $self        = shift;
    my $passedVars  = shift;
    my $entry       = shift;
    my $var         = $self->getTemplateVars;
    if (!$entry) {
        $entry = $self->entry;
    }
    $var = $passedVars || $self->getRecordTemplateVars($var, $entry);
    if ($self->hasCaptcha) {
        $self->session->http->setCacheControl('none');
    }
    return $self->processTemplate($var, undef, $self->{_viewFormTemplate});
}

#-------------------------------------------------------------------

=head2 entryClass 

Returns a string, the classname for entry collateral.

=cut

sub entryClass {
    return 'WebGUI::AssetCollateral::DataForm::Entry';
}

#-------------------------------------------------------------------

=head2 www_deleteAllEntriesConfirm 

Web facing method for deleting all data entered into the DataForm.

=cut

sub www_deleteAllEntriesConfirm {
    my $self = shift;
    return $self->session->privilege->insufficient
        unless $self->canEdit;
    $self->deleteAttachedFiles;
    $self->entryClass->purgeAssetEntries($self);
    $self->{_mode} = 'list';
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

=head2 www_deleteEntry 

Web facing method for deleting one entry from the DataForm, identified
by the form variable C<entryId>.  Returns insufficient unless the
current user canEdit the DataForm.  Returns the user to www_view.

=cut

sub www_deleteEntry {
    my $self = shift;
    return $self->session->privilege->insufficient
        unless $self->canEdit;
    my $entryId = $self->session->form->process("entryId");
    $self->deleteAttachedFiles(entryId => $entryId);
    $self->entryClass->new($self, $entryId)->delete;
    $self->{_mode} = 'list';
    return $self->www_view;
}

#-------------------------------------------------------------------

=head2 www_deleteFieldConfirm 

Web facing method for deleting one field from the DataForm, identified
by the form variable C<fieldName>.  This operation is revisioned.

Returns insufficient unless the current user canEdit the DataForm.

Returns the user to www_view.

=cut

sub www_deleteFieldConfirm {
    my $self = shift;
    return $self->session->privilege->insufficient
        unless $self->canEdit;
    return $self->session->privilege->locked
        unless $self->canEditIfLocked;
    my $newSelf = $self->addRevision;
    $newSelf->deleteField($self->session->form->process("fieldName"));
    $newSelf->{_mode} = 'form';
    WebGUI::VersionTag->autoCommitWorkingIfEnabled($self->session);
    my $freshSelf = $newSelf->cloneFromDb();
    return $freshSelf->www_view;
}

#-------------------------------------------------------------------

=head2 www_deleteTabConfirm

Web facing method for deleting one tab from the DataForm, identified
by the form variable C<tabId>.  This operation is revisioned.

Returns insufficient unless the current user canEdit the DataForm.

Returns the user to www_view.

=cut

sub www_deleteTabConfirm {
    my $self = shift;
    return $self->session->privilege->insufficient
        unless $self->canEdit;
    return $self->session->privilege->locked
        unless $self->canEditIfLocked;
    my $newSelf = $self->addRevision;
    $newSelf->deleteTab($self->session->form->process("tabId"));
    $newSelf->{_mode} = 'form';
    WebGUI::VersionTag->autoCommitWorkingIfEnabled($self->session);
    my $freshSelf = $newSelf->cloneFromDb();
    return $freshSelf->www_view;
}

#-------------------------------------------------------------------

=head2 www_editField 

Renders a form to edit a field, identified by the form variable C<fieldName>.

Returns insufficient unless the current user canEdit the DataForm.

=cut

sub www_editField {
    my $self = shift;
    return $self->session->privilege->insufficient
        unless $self->canEdit;
    return $self->session->privilege->locked
        unless $self->canEditIfLocked;
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
    my $f = WebGUI::HTMLForm->new($self->session, action => $self->getUrl);
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

=head2 www_editFieldSave 

Process the editField form.  Returns insufficient unless the current
user canEdit the DataForm.

=cut

sub www_editFieldSave {
    my $self = shift;
    my $session = $self->session;
    return $session->privilege->insufficient
        unless $self->canEdit;
    return $self->session->privilege->locked
        unless $self->canEditIfLocked;
    my $form = $session->form;
    my $fieldName = $form->process('fieldName');
    my $newName = $session->url->urlize($form->process('newName') || $form->process('label'));
    $newName =~ tr{-/}{};

    # Make sure we don't rename special fields
    my $isMailField = 0;
    if ($fieldName) {
        my $field = $self->getFieldConfig($fieldName);
        if ($field->{isMailField}) {
            $newName = $fieldName;
            $isMailField = 1;
        }
    }

    # Make sure our field name is unique
    if (!$fieldName || $fieldName ne $newName) {
        my $i = '';
        while ($self->getFieldConfig($newName . $i)) {
            $i ||= 1;
            $i++;
        }
        $newName .= $i;
    }

    my %field = (
        width           => $form->process("width", 'integer'),
        label           => $form->process("label"),
        tabId           => $form->process("tabId") || undef,
        status          => $form->process("status", 'selectBox'),
        type            => $form->process("type", 'fieldType'),
        options         => $form->process("options", 'textarea'),
        defaultValue    => $form->process("defaultValue", 'textarea'),
        subtext         => $form->process("subtext"),
        rows            => $form->process("rows", 'integer'),
        vertical        => $form->process("vertical", 'yesNo'),
        extras          => $form->process("extras"),
    );
    if ($isMailField) {
        $field{isMailField} = 1;
    }

    my $newSelf = $self->addRevision;
    if ($fieldName) {
        if ($fieldName ne $newName) {
            $newSelf->renameField($fieldName, $newName);
        }
        $newSelf->setField($newName, \%field);
    }
    else {
        $newSelf->createField($newName, \%field);
    }

    WebGUI::VersionTag->autoCommitWorkingIfEnabled($session);
    my $freshSelf = $newSelf->cloneFromDb();
    if ($form->process("proceed") eq "editField") {
        return $freshSelf->www_editField('new');
    }
    $freshSelf->{_mode} = 'form';
    return $freshSelf->www_view;
}

#-------------------------------------------------------------------

=head2 createField ($fieldName, $field)

Create a new field in the DataForm.  Returns 1 if the creation
was successful

=head3 $fieldName

The name of the field to create.  Returns 0 if a field with the
same name already exists.

=head3 $field

A hash ref of field data, added to the field configuration for this field.

=cut

sub createField {
    my $self = shift;
    my $fieldName = shift;
    my $field = shift;
    my $copy = { %{ $field }, name => $fieldName };

    if ($self->getFieldConfig->{$fieldName}) {
        return 0;
    }

    $self->getFieldConfig->{$fieldName} = $copy;
    push @{ $self->getFieldOrder }, $fieldName;
    $self->_saveFieldConfig;
    return 1;
}

#-------------------------------------------------------------------

=head2 setField ($fieldName, $field)

Updates a field in the DataForm.  Returns 1 if the update was successful

=head3 $fieldName

The name of the field to update.  Returns 0 if a field with the
same name does not exist.

=head3 $field

A hash ref of field data, added to the field configuration for this field.

=cut

sub setField {
    my $self = shift;
    my $fieldName = shift;
    my $field = shift;
    
    $field->{ name } = $fieldName;

    my $fieldConfig = $self->getFieldConfig;
    if (!$fieldConfig->{$fieldName}) {
        return 0;
    }
    $fieldConfig->{$fieldName} = $field;
    $self->_saveFieldConfig;
    return 1;
}

#-------------------------------------------------------------------

=head2 www_editTab 

Renders a web form for adding new tabs, or editing existing tabs.  Returns
insufficient unless the current user canEdit this DataForm.  The GUID of
the tab is looked for in the form variable C<tabId>.

=cut

sub www_editTab {
    my $self = shift;
    return $self->session->privilege->insufficient
        unless $self->canEdit;
    return $self->session->privilege->locked
        unless $self->canEditIfLocked;
    my $i18n = WebGUI::International->new($self->session,"Asset_DataForm");
    my $tabId = shift || $self->session->form->process("tabId") || "new";
    my $tab;
    unless ($tabId eq "new") {
        $tab = $self->getTabConfig($tabId);
    }

    my $f = WebGUI::HTMLForm->new($self->session,-action=>$self->getUrl);
    $f->hidden(
        -name => "tabId",
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

=head2 www_editTabSave 

Process the editTab form.  Returns insufficient unless the current user canEdit
this DataForm.

=cut

sub www_editTabSave {
    my $self = shift;
    return $self->session->privilege->insufficient
        unless $self->canEdit;
    return $self->session->privilege->locked
        unless $self->canEditIfLocked;
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
    $self->{_mode} = 'form';
    return "";
}

#-------------------------------------------------------------------

=head2 www_exportTab 

Exports all the data entered into the DataForm in CSV format.  Returns
insufficient unless the current user canEdit this DataForm.

=cut

sub www_exportTab {
    my $self = shift;
    my $session = $self->session;
    return $session->privilege->insufficient
        unless $self->canEdit;
    my @exportFields;
    for my $field ( map { $self->getFieldConfig($_) } @{$self->getFieldOrder} ) {
        next
            if $field->{isMailField} && !$self->get('mailData');
        push @exportFields, $field->{name};
    }
    my $tsv = Text::CSV_XS->new({sep_char => "\t", eol => "\n", binary => 1});
    $tsv->combine(
        'entryId',
        'ipAddress',
        'username',
        'userId',
        'submissionDate',
        @exportFields,
    );

    $session->http->setFilename($self->get("url").".tab","text/plain");
    $session->http->sendHeader;
    $session->output->print($tsv->string, 1);

    my $entryIter = $self->entryClass->iterateAll($self);

    while (my $entry = $entryIter->()) {
        my $entryFields = $entry->fields;
        $tsv->combine(
            $entry->getId,
            $entry->ipAddress,
            $entry->username,
            $entry->userId,
            $entry->submissionDate->webguiDate,
            @{ $entryFields }{@exportFields},
        );
        $session->output->print($tsv->string, 1);
    }
    return 'chunked';
}

#-------------------------------------------------------------------

=head2 www_moveFieldDown 

Web facing method to move a field one position down.  The field is identified
by the form variable C<fieldName>.  Returns insufficient unless the current user canEdit
this DataForm.

This operation is revisioned.

=cut

sub www_moveFieldDown {
    my $self = shift;
    return $self->session->privilege->insufficient
        unless $self->canEdit;
    return $self->session->privilege->locked
        unless $self->canEditIfLocked;
    my $newSelf = $self->addRevision;
    my $fieldName = $self->session->form->process('fieldName');
    $newSelf->moveFieldDown($fieldName);
    WebGUI::VersionTag->autoCommitWorkingIfEnabled($self->session);
    my $freshSelf = $newSelf->cloneFromDb();
    return $freshSelf->www_view;
}

#-------------------------------------------------------------------

=head2 moveFieldDown ($fieldName)

Shifts the field one position down in the field order.

=head3 $fieldName

The name of the field to move.

=cut

sub moveFieldDown {
    my $self = shift;
    my $fieldName = shift;
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
    return 1;
}

#-------------------------------------------------------------------

=head2 www_moveFieldUp 

Web facing method to move a field one position up.  The field is identified
by the form variable C<fieldName>.  Returns insufficient unless the current user canEdit
this DataForm.

This operation is revisioned.

=cut

sub www_moveFieldUp {
    my $self = shift;
    return $self->session->privilege->insufficient
        unless $self->canEdit;
    return $self->session->privilege->locked
        unless $self->canEditIfLocked;
    my $newSelf = $self->addRevision;
    my $fieldName = $self->session->form->process('fieldName');
    $newSelf->moveFieldUp($fieldName);
    WebGUI::VersionTag->autoCommitWorkingIfEnabled($self->session);
    my $freshSelf = $newSelf->cloneFromDb();
    return $freshSelf->www_view;
}

#-------------------------------------------------------------------

=head2 moveFieldUp ($fieldName)

Shifts the field one position up in the field order.

=head3 $fieldName

The name of the field to move.

=cut

sub moveFieldUp {
    my $self = shift;
    my $fieldName = shift;
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
    return 1;
}

#-------------------------------------------------------------------

=head2 www_moveTabRight 

Web facing method to move a tab one position to the right.  The tab is identified
by the form variable C<tabId>.  Returns insufficient unless the current user canEdit
this DataForm.

This operation is revisioned.

=cut

sub www_moveTabRight {
    my $self = shift;
    return $self->session->privilege->insufficient
        unless $self->canEdit;
    return $self->session->privilege->locked
        unless $self->canEditIfLocked;
    my $newSelf = $self->addRevision;
    my $tabId = $self->session->form->process('tabId');
    $newSelf->moveTabRight($tabId);
    WebGUI::VersionTag->autoCommitWorkingIfEnabled($self->session);
    my $freshSelf = $newSelf->cloneFromDb();
    return $freshSelf->www_view;
}


#-------------------------------------------------------------------

=head2 moveTabRight ($tabId)

Shifts the tab one position to the right in the tab order.

=head3 $tabId

The GUID of the tab to move.

=cut

sub moveTabRight {
    my $self = shift;
    my $tabId = shift;
    my $tabOrder = $self->getTabOrder;
    my $currentPos;
    for ($currentPos = 0; $currentPos < @$tabOrder; $currentPos++) {
        last
            if $tabId eq $tabOrder->[$currentPos];
    }
    my $newPos = $currentPos + 1;
    if ($newPos < @$tabOrder) {
        splice @$tabOrder, $newPos, 0, splice(@$tabOrder, $currentPos, 1);
        $self->_saveTabConfig;
    }
    return 1;
}

#-------------------------------------------------------------------

=head2 www_moveTabLeft 

Web facing method to move a tab one position to the left.  The tab is identified
by the form variable C<tabId>.  Returns insufficient unless the current user canEdit
this DataForm.

This operation is revisioned.

=cut

sub www_moveTabLeft {
    my $self = shift;
    return $self->session->privilege->insufficient
        unless $self->canEdit;
    return $self->session->privilege->locked
        unless $self->canEditIfLocked;
    my $newSelf = $self->addRevision;
    my $tabId = $self->session->form->process('tabId');
    $newSelf->moveTabLeft($tabId);
    WebGUI::VersionTag->autoCommitWorkingIfEnabled($self->session);
    my $freshSelf = $newSelf->cloneFromDb();
    return $freshSelf->www_view;
}

#-------------------------------------------------------------------

=head2 moveTabLeft ($tabId)

Shifts the tab one position to the left in the tab order.

=head3 $tabId

The GUID of the tab to move.

=cut

sub moveTabLeft {
    my $self = shift;
    my $tabId = shift;
    my $tabOrder = $self->getTabOrder;
    my $currentPos;
    for ($currentPos = 0; $currentPos < @$tabOrder; $currentPos++) {
        last
            if $tabId eq $tabOrder->[$currentPos];
    }
    my $newPos = $currentPos - 1;
    if ($newPos >= 0) {
        splice @$tabOrder, $newPos, 0, splice(@$tabOrder, $currentPos, 1);

        $self->_saveTabConfig;
    }
    return 1;
}

#-------------------------------------------------------------------

=head2 www_process 

Process the form for a user entering new data.  Returns insufficient unless
the current user canView the DataForm.

=cut

sub www_process {
    my $self = shift;
    return $self->session->privilege->insufficient
        unless $self->canView;
    my $session = $self->session;
    my $i18n    = WebGUI::International->new($session,"Asset_DataForm");
    my $entry   = $self->entry;

    my $var = $self->getTemplateVars;

    # Process form
    my (@errors, $updating, $hadErrors);
    for my $field (values %{ $self->getFieldConfig }) {
        my $default = $field->{defaultValue};
        WebGUI::Macro::process($self->session, \$default);
        my $value = $entry->field( $field->{name} ) || $default;

        # WebGUI::Form::Integer::getValue() returns 0 even if no number is passed in.
        # Not really a suitable default if we want to trigger the error message

        if ($field->{status} eq "required" || $field->{status} eq "editable") {

            # get the raw value (by sending field type as blank)
            my $rawValue = $session->form->process($field->{name}, '');

            $value = $session->form->process($field->{name}, $field->{type}, undef, {
                defaultValue    => $default,
                value           => $value,
            });

            # this is a hack, but it's better than changing the default getValue() of Integer, which
            # could have massive effects downstream in other uses.
            if(($field->{type} =~ /integer/i) && defined($rawValue) && ($rawValue eq '') && ($value eq "0")) {
                $value = $rawValue;
            }

            WebGUI::Macro::filter(\$value);
        }
        if ($field->{status} eq "required" && (! defined($value) || $value =~ /^\s*$/)) {
            push @errors, {
                "error.message" => $field->{label} . " " . $i18n->get(29) . ".",
            };
        }
        $entry->field($field->{name}, $value);
    }

    # Process CAPTCHA
    if ( $self->useCaptcha  && !$session->form->process( 'captcha', 'captcha' ) ) {
        push @errors, {
            "error.message" => $i18n->get( 'error captcha' ),
        };
    }

    # Prepare template variables
    $var = $self->getRecordTemplateVars($var, $entry);

    # If errors, show error page
    if (@errors) {
        $var->{error_loop} = \@errors;
        $self->prepareViewForm;
        return $self->processStyle($self->viewForm($var, $entry), { noHeadTags => 1 });
    }

    # Send email
    if ($self->get("mailData") && !$entry->entryId) {
        $self->sendEmail($var, $entry);
    }

    # Save entry to database
    if ($self->get('storeData')) {
        $entry->save;
    }
    
    # Run the workflow
    if ( $self->get("workflowIdAddEntry") ) {
        my $instanceVar = {
            workflowId  => $self->get( "workflowIdAddEntry" ),
            className   => "WebGUI::AssetCollateral::DataForm::Entry",
        };

        # If we've saved the entry, we only need the ID
        if ( $self->get( 'storeData' ) ) {
            $instanceVar->{ methodName     } = "new";
            $instanceVar->{ parameters     } = $entry->getId;
        }
        # We haven't saved the entry, we need the whole thing
        else {
            $instanceVar->{ methodName     } = "newFromHash";
            $instanceVar->{ parameters     } = [ $self->getId, $entry->getHash ];
        }

        WebGUI::Workflow::Instance->create( $self->session, $instanceVar )->start;
    }

    return $self->processStyle($self->processTemplate($var,$self->get("acknowlegementTemplateId")))
        if $self->defaultViewForm;
    return '';
}

1;

