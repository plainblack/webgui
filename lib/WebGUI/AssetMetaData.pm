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

Package WebGUI::Asset (AssetMetaData)

=head1 DESCRIPTION

This is a mixin package for WebGUI::Asset that contains all metadata related functions.

=head1 SYNOPSIS

 use WebGUI::Asset;

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 addMetaDataField ( )

Adds a new field to the metadata system, or edit an existing one. The id of
the field is returned.

=head3 fieldId

The fieldId to be added.

=head3 fieldName

The name of the field

=head3 defaultValue

The default value of the metadata field, if none is chosen by the user.

=head3 description

A description for the field, in case you forget later why you ever bothered
wasting space in the db for this field.

=head3 fieldType

The form field type for metaData: selectBox, text, integer, or checkList, yesNo, radioList.

=head3 possibleValues

For fields that provide options, the list of options.  This is a string with
newline separated values.

=head3 classes

An arrayref of classnames that this metadata field applies to

=cut

sub addMetaDataField {
    my $self = shift;

    my $fieldId          = shift || 'new';
    my $fieldName        = shift || $self->session->id->generate();
    my $defaultValue     = shift;
    my $description      = shift || '';
    my $fieldType        = shift;
    my $possibleValues   = shift;
    my $classes          = shift;
    my $db               = $self->session->db;

	if($fieldId eq 'new') {
		$fieldId = $self->session->id->generate();
		$db->write("insert into metaData_properties (fieldId, fieldName, defaultValue, description, fieldType, possibleValues) values (?,?,?,?,?,?)",
            [ $fieldId, $fieldName, $defaultValue, $description, $fieldType, $possibleValues, ]
        );
	}
    else {
        $db->write("update metaData_properties set fieldName = ?, defaultValue = ?, description = ?, fieldType = ?, possibleValues = ? where fieldId = ?",
            [ $fieldName, $defaultValue, $description, $fieldType, $possibleValues, $fieldId, ]
        );
        $db->write('delete from metaData_classes where fieldId=?', [$fieldId]);
	}

    if ($classes && @$classes) {
        my $qfid = $db->quote($fieldId);
        $db->write('insert into metaData_classes (fieldId, className) values '
            .join(', ',
            map { my $q = $db->quote($_); "($qfid, $q)" } @$classes
        ));
    }

    return $fieldId;
}


#-------------------------------------------------------------------

=head2 deleteMetaDataField ( )

Deletes a field from the metadata system.

=head3 fieldId

The fieldId to be deleted.

=cut

sub deleteMetaDataField {
    my $self = shift;
    my $fieldId = shift;
    my $db = $self->session->db;
    $db->beginTransaction;
    for my $table (map { "metaData_$_" } qw(properties values classes)) {
        $db->write("delete from $table where fieldId = ?", [ $fieldId ]);
    }
    $db->commit;
}

#-------------------------------------------------------------------

=head2 getMetaDataAsFormFields

Returns a hashref of metadata field names WebGUI::Form objects appropriate
for use on edit forms.

=cut

sub getMetaDataAsFormFields {
    my $self    = shift;
    my $session = $self->session;
    my $i18n    = WebGUI::International->new($session, 'Asset');
    my $fields  = $self->getMetaDataFields;
    my %hash;
    for my $fid (keys %$fields) {
        my $info    = $fields->{$fid};
        my $type    = lcfirst ($info->{fieldType} || 'text');
        my $name    = $info->{fieldName};
        my $options = $info->{possibleValues};
        if($type eq 'selectBox') {
            my $label = $i18n->get('Select');
            $options = "|$label\n$options";
        }
        my $formClass = ucfirst $type;
        $hash{$name} = WebGUI::Pluggable::instanciate(
            "WebGUI::Form::$formClass",
            'new',
            [
                $session, {
                    name         => "metadata_$fid",
                    label        => $name,
                    value        => $info->{value},
                    extras       => qq'title="$info->{description}"',
                    defaultValue => $info->{defaultValue},
                    fieldType    => $type,
                    options      => $options,
                }
            ]
        )->toHtml;
    };
    \%hash;
}

#-------------------------------------------------------------------

=head2 getMetaDataAsTemplateVariables

Returns the metadata as template variables for use in the head block.

=cut

sub getMetaDataAsTemplateVariables {
    my $self    = shift;
    my $var     = {};
    my $meta    = {};

    if ($self->session->setting->get("metaDataEnabled")) {
        $meta = $self->getMetaDataFields();
    }
    foreach my $field (keys %$meta) {
        $var->{$meta->{$field}{fieldName}} = $meta->{$field}{value};
    }
    return $var;
}

#-------------------------------------------------------------------

sub _getMetaDataFieldsHelper {
	my $self    = shift;
	my $fieldId = shift;
	my $listAll = shift || $fieldId;
	my $db      = $self->session->db;
	my $sql = "select
		 	f.fieldId, 
			f.fieldName, 
			f.description, 
			f.defaultValue,
			f.fieldType,
			f.possibleValues,
			d.value
		from metaData_properties f
        left join metaData_values d
            on f.fieldId=d.fieldId
            and d.assetId=?
            and d.revisionDate = ?
        ";

    my @where;
    my @place = ($self->getId, $self->get('revisionDate'));
    unless ($listAll) {
        # Either there's no class info stored for this field or this class is
        # one of them.
        push @where, q{
            not exists (
                select * from metaData_classes where fieldId = f.fieldId
            )
            or exists (
                select *
                from metaData_classes
                where className = ?
                    and fieldId = f.fieldId
            )
        };
        push @place, ref $self;
    }

    if ($fieldId) {
        push @where, 'f.fieldId = ?';
        push @place, $fieldId;
    }

    if (@where) {
        $sql .= 'where ' . join(' AND ', map { "($_)" } @where);
    }

    my $hash = $db->buildHashRefOfHashRefs( $sql, \@place, 'fieldId' );

    return $fieldId ? $hash->{$fieldId} : $hash;
}

#-------------------------------------------------------------------

=head2 getAllMetaDataFields

getMetaDataFields without bothering about whether they apply to this class.

=cut

sub getAllMetaDataFields {
    my $self = shift;
    return $self->_getMetaDataFieldsHelper(undef, 1);
}

#-------------------------------------------------------------------

=head2 getMetaDataFields ( [fieldId] )

Returns a hash reference containing all metadata field properties for this Asset.
You can limit the output to a certain field by specifying a fieldId.

=head3 fieldId

If specified, the hashRef will contain only this field. In this case, you will
get that metadata field if it exists whether it applies to this asset or not.

=cut

sub getMetaDataFields {
    my ($self, $fieldId) = @_;
    return $self->_getMetaDataFieldsHelper($fieldId);
}

#-------------------------------------------------------------------

=head2 updateMetaData ( fieldId, value )

Updates the value of a metadata field for this asset.

=head3 fieldId

The unique Id of the field to update.

=head3 value

The value to set this field to. Leave blank to unset it.

=cut

sub updateMetaData {
	my $self = shift;
	my $fieldId = shift;
	my $value = shift;
    $self->session->db->write(
        'replace into metaData_values (fieldId, assetId, revisionDate, value) values (?, ?, ?, ?)',
        [$fieldId, $self->getId, $self->get('revisionDate'), $value]
    );
}


#-------------------------------------------------------------------

=head2 www_deleteMetaDataField ( )

Deletes a MetaDataField and returns www_manageMetaData on self, if user isInGroup(4), if not, renders a "content profiling" AdminConsole as insufficient privilege. 

=cut

sub www_deleteMetaDataField {
	my $self = shift;
	return $self->session->privilege->insufficient() unless ($self->session->user->isInGroup(4));
	$self->deleteMetaDataField($self->session->form->process("fid"));
	return $self->www_manageMetaData;
}


#-------------------------------------------------------------------

=head2 www_editMetaDataField ( )

Returns a rendered page to edit MetaData.  Will return an insufficient Privilege if not InGroup(4).

=cut

sub www_editMetaDataField {
	my $self = shift;
	my $i18n = WebGUI::International->new($self->session,'Asset');
	my $ac = WebGUI::AdminConsole->new($self->session,"contentProfiling");
	return $self->session->privilege->insufficient() unless ($self->session->user->isInGroup(4));
        my $fieldInfo;
	if($self->session->form->process("fid") && $self->session->form->process("fid") ne "new") {
		$fieldInfo = $self->getMetaDataFields($self->session->form->process("fid"));
	}
	my $fid = $self->session->form->process("fid") || "new";
	my $f = WebGUI::HTMLForm->new($self->session,-action=>$self->getUrl);
	$f->hidden(
		-name => "func",
		-value => "editMetaDataFieldSave"
	);
	$f->hidden(
		-name => "fid",
		-value => $fid
	);
	$f->readOnly(
		-value=>$fid,
		-label=>$i18n->get('Field Id'),
	);
	$f->text(
		-name=>"fieldName",
		-label=>$i18n->get('Field name'),
		-hoverHelp=>$i18n->get('Field Name description'),
		-value=>$fieldInfo->{fieldName}
	);
	$f->textarea(
		-name=>"description",
		-label=>$i18n->get(85),
		-hoverHelp=>$i18n->get('Metadata Description description'),
		-value=>$fieldInfo->{description}
        );
	$f->fieldType(
		-name=>"fieldType",
		-label=>$i18n->get(486),
		-hoverHelp=>$i18n->get('Data Type description'),
		-value=>$fieldInfo->{fieldType} || "text",
		-types=> [ qw /text integer yesNo selectBox radioList checkList date/ ]
	);

    my $default = WebGUI::Asset->definition($self->session)->[0]->{assetName};
    my %classOptions;
    # usedNames maps a name to a class. If a name exists there, it has been
    # used.  If it maps to a classname, that classname needs to be renamed.
    my %usedNames;
    for my $class (WebGUI::Pluggable::findAndLoad('WebGUI::Asset')) {
        next unless $class->isa('WebGUI::Asset');
        my $name  = $class->definition($self->session)->[0]->{assetName};
        next unless $name; # abstract classes (e.g. wobject) don't have names

        # We don't want things named "Asset".
        if ($name eq $default) {
            $name = $class;
        }
        elsif (exists $usedNames{$name}) {
            if (my $rename = $usedNames{$name}) {
                $classOptions{$rename} = "$name ($rename)";
                undef $usedNames{$name};
            }
            $name = "$name ($class)";
        }
        $usedNames{$name} = $class;
        $classOptions{$class} = $name;
    }

    $f->selectList(
        name         => 'classes',
        label        => $i18n->get('Allowed Classes'),
        hoverHelp    => $i18n->get('Allowed Classes hoverHelp'),
        options      => \%classOptions,
        defaultValue => $fid ne 'new' && $self->session->db->buildArrayRef(
            'select className from metaData_classes where fieldId = ?',
            [ $fid ]
        ),
        sortByValue  => 1,
    );

	$f->textarea(
		-name=>"possibleValues",
		-label=>$i18n->get(487),
		-hoverHelp=>$i18n->get('Possible Values description'),
		-value=>$fieldInfo->{possibleValues}
	);
	$f->textarea(
		-name=>"defaultValue",
		-label=>$i18n->get('default value'),
		-hoverHelp=>$i18n->get('default value description'),
		-value=>$fieldInfo->{defaultValue}
	);
	$f->submit();
	return $ac->render($f->print, $i18n->get('Edit Metadata'));
}

#-------------------------------------------------------------------

=head2 www_editMetaDataFieldSave ( )

Verifies that MetaData fields aren't duplicated or blank, assigns default values, and returns the www_manageMetaData() method. Will return an insufficient Privilege if not InGroup(4).

=cut

sub www_editMetaDataFieldSave {
	my $self = shift;
	my $ac = WebGUI::AdminConsole->new($self->session,"content profiling");
	return $self->session->privilege->insufficient() unless ($self->session->user->isInGroup(4));
	my $i18n = WebGUI::International->new($self->session,"Asset");
	# Check for duplicate field names
    my $fid       = $self->session->form->process("fid");
    my $fieldName = $self->session->form->process("fieldName");
	my $sql = "select count(*) from metaData_properties where fieldName = ".
                                $self->session->db->quote($fieldName);
	if ($fid ne "new") {
		$sql .= " and fieldId <> ".$self->session->db->quote($fid);
	}
	my ($isDuplicate) = $self->session->db->buildArray($sql);
	if($isDuplicate) {
		my $error = $i18n->get("duplicateField");
		$error =~ s/\%field\%/$fieldName/;
		return $ac->render($error,$i18n->get('Edit Metadata'));
	}
	if($fieldName eq "") {
		return $ac->render($i18n->get("errorEmptyField"),$i18n->get('Edit Metadata'));
	}
    $self->addMetaDataField(
        $fid,
        $fieldName,
        $self->session->form->process("defaultValue"),
        $self->session->form->process("description") || '',
        $self->session->form->process("fieldType"),
        $self->session->form->process("possibleValues"),
        [ $self->session->form->process("classes") ],
    );

	return $self->www_manageMetaData; 
}


#-------------------------------------------------------------------

=head2 www_manageMetaData ( )

Returns an AdminConsole to deal with MetaDataFields. If isInGroup(4) is False, renders an insufficient privilege page.

=cut

sub www_manageMetaData {
	my $self = shift;
	my $ac = WebGUI::AdminConsole->new($self->session,"contentProfiling");
	return $self->session->privilege->insufficient() unless ($self->session->user->isInGroup(4));
	my $i18n = WebGUI::International->new($self->session,"Asset");
	$ac->addSubmenuItem($self->getUrl('func=editMetaDataField'), $i18n->get("Add new field"));
	my $output;
	my $fields = $self->getAllMetaDataFields;
	foreach my $fieldId (keys %{$fields}) {
		$output .= $self->session->icon->delete("func=deleteMetaDataField;fid=".$fieldId,$self->get("url"),$i18n->get('deleteConfirm'));
		$output .= $self->session->icon->edit("func=editMetaDataField;fid=".$fieldId,$self->get("url"));
		$output .= " <b>".$fields->{$fieldId}{fieldName}."</b><br />";
	}	
	return $ac->render($output);
}




1;

