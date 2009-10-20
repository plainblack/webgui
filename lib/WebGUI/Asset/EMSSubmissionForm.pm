package WebGUI::Asset::EMSSubmissionForm;

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
use base 'WebGUI::Asset';
use JSON;
use WebGUI::Utility;

# TODO:
# To get an installer for your wobject, add the Installable AssetAspect
# See WebGUI::AssetAspect::Installable and sbin/installClass.pl for more
# details

=head1 NAME

Package WebGUI::Asset::EMSSubmissionForm

=head1 DESCRIPTION

This Asset describes and builds a form which provides an interface for submitting a custom
subset of the EMSTicket asset.  Users create submissions which can be editted by admins
and then become EMSTicket's.

=head1 SYNOPSIS

use WebGUI::Asset::EMSSubmissionForm;

=head1 TODO

add a lastSubmissionDate -- after that the submission form will be closed
    the link will still exist but the form will just say '<title> submissions closed as of <date>'


=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------
=head2 _generateFields ( tabform, targetField, formDescription )

adds input fields to the tab based on the target field
TODO: I should put this in the EMSSubmissionForm module instead

=head3 tabform

must be a tabform object

=head3 targetField

this is the definition of the field being described by the fields in the tab

=head3 formDescription

HASHREF to the current description

=cut

my $generators;

use lib '/root/pb/lib'; use dav;

sub _generateFields {
    my $tabform = shift;
    my $targetField = shift;
    my $formDescription = shift;
    my $fieldId = $targetField->{fieldId};
    my $fieldDescription = $formDescription->{$fieldId};
    my $dummy = $generators->{dummy}{generate};
    my $tab = $tabform->getTab($targetField->{fieldId});

dav::log '_generateFields::fieldId:', $targetField->{fieldId};

# TODO internationalize these
   $tab->checkbox(label => 'turn this field on',
              name => 'activeFields',
	      value => $fieldId,
	      checked => $fieldDescription->{on} || 0,
	  );
   $tab->integer(label => 'display order',
              name => $fieldId . '_displayOrder',
	      value => $fieldDescription->{displayOrder} || 0,
	  );
    (($generators->{$targetField->{fieldType}}||{})->{generate} || $dummy)->($tab,$fieldId,$fieldDescription);
   $tab->checkbox(label => 'value is required',
              name => 'requiredFields',
	      value => $fieldId,
	      checked => $fieldDescription->{required} || 0,
	  );
   $tab->text(label => 'default value',
              name => $fieldId . '_defaultValue',
	      value => $fieldDescription->{defaultValue} || '',
	  );
   $tab->text(label => 'override label',
              name => $fieldId . '_overrideLabel',
	      value => $fieldDescription->{overrideLabel} || '',
	  );
   $tab->textarea(label => 'override help',
              name => $fieldId . '_overrideHelp',
	      value => $fieldDescription->{overrideHelp} || '',
	  );
   $tab->hidden(
              name => $fieldId . '_fieldType',
	      value => $targetField->{fieldType} || '',
	  );
}

#-------------------------------------------------------------------
=head2 _readFields ( form, fieldId, formDescription )

copy field description values from session->form to description

=head3 form

the current session->form object

=head3 fieldId

fieldId for the field we are processing

=head3 formDescription

HASHREF to the current description

=cut

sub _readFields {
    my $form = shift;
    my $fieldId = shift;
    my $formDescription = shift;
    my $fieldDescription = $formDescription->{$fieldId} ||= {fieldType => $targetField->{fieldType}};
    my $dummy = $generators->{dummy}{readForm};

    # we get the default value even if the field is not active...
    $fieldDescription->{defaultValue} = $form->get($fieldId . '_defaultValue');

    return if ! grep $fieldId, ( @{$formDescription->{activeFields}} );

    $fieldDescription->{on} = 1;
    $fieldDescription->{required} = grep $fieldId, ( @{$formDescription->{requiredFields}} );
    $fieldDescription->{displayOrder} = $form->get( $fieldId . '_displayOrder' );
    $fieldDescription->{overrideLabel} = $form->get($fieldId . '_overrideLabel');
    $fieldDescription->{overrideHelp} = $form->get($fieldId . '_overrideHelp');
    $fieldDescription->{fieldType} = $form->get($fieldId . '_fieldType');
    (($generators->{$description->{fieldType}}||{})->{readForm} || $dummy)->($form,$targetField,$fieldDescription);
}


# FUTURE: this list of functions shouldbe defined in the control classes themselves
$generators = {
     dummy => { generate => sub {
         my $tab = shift;
	 my $fieldId = shift;
	 my $description = shift;
	 $tab->readOnly( 
	           label => 'ERROR',
		   value => $description->{fieldType} . ' is not defined in EMS Submission Form generators list',
              );
     },
     readForm => sub {
         # nothing to do here...
     } },
     dateTime => { generate => sub {
         my $tab = shift;
	 my $fieldId = shift;
	 my $description = shift;
	 $tab->selectList( 
		  name => $fieldId . '_dateSelect',
	          multiple => 0,
		  size => 2,
		  options => {
		  # TODO internationalize this
		      selectList => 'select list',
		      dateSelect => 'date select',
		  },
		  defaultValue => $description->{dateSelect} || ['dateSelect'],
		  label => 'datetime selection label',
		  hoverHelp => 'datetime selection help',
              );
	$tab->textarea( 
		  name => $fieldId . '_dateTextArea',
		  label => 'datetime textarea label',
		  hoverHelp => 'datetime textarea help',
		  defaultValue => $description->{dateTextArea} || '',
              )
     },
     readForm => sub {
         my $form = shift;
	 my $fieldId = shift;
	 my $description = shift;
	 $description->{dateSelect} = $form->get($fieldId . '_dateSelect');
	 my @options;
	 for my $item ( split( , $form->get($fieldId . '_dateTextArea') ) {
	     push @options, WebGUI::DateTime->new($item)->epoch;
	 }
	 $description->{dateTextArea} = [ @options ];
	 # TODO perhaps we need to verify the text area is valid?
     }, },
     checkList => { generate => sub {
         my $tab = shift;
	 my $fieldId = shift;
	 my $description = shift;
	$tab->textarea( 
		  name => $fieldId . '_dateTextArea',
		  label => 'checklist textarea label',
		  hoverHelp => 'checklist textarea help',
		  defaultValue => $description->{checkListTextArea} || '',
              );
     },
     readForm => sub {
         my $form = shift;
	 my $fieldId = shift;
	 my $description = shift;
	 $description->{checkListTextArea} = $form->get($fieldId . '_checkListTextArea');
     }, },
     combo => { generate => sub {
         my $tab = shift;
	 my $fieldId = shift;
	 my $description = shift;
	 $tab->readOnly( 
	           label => 'TODO',
		   value => 'combo needs work<br>
		   hmmm, needs some thought...',
              );
     },
     readForm => sub {
         my $form = shift;
	 my $fieldId = shift;
	 my $description = shift;
         # add the correct variables to the description hash that is passed in
     }, },
     integer => { generate => sub {
         my $tab = shift;
	 my $fieldId = shift;
	 my $description = shift;
	 $tab->text( 
		   name => $fieldId . '_integerMin',
	           label => 'integer min label',
	           hoverHelp => 'integer min help',
		   defaultValue => $description->{integerMin} || '',
              );
	 $tab->text( 
		   name => $fieldId . '_integerMax',
	           label => 'integer max label',
	           hoverHelp => 'integer max help',
		   defaultValue => $description->{integerMax} || '',
              );
     },
     readForm => sub {
         my $form = shift;
	 my $fieldId = shift;
	 my $description = shift;
	 $description->{integerMax} = $form->get($fieldId . '_integerMax');
	 $description->{integerMin} = $form->get($fieldId . '_integerMin');
     }, },
     float => { generate => sub {
         my $tab = shift;
	 my $fieldId = shift;
	 my $description = shift;
	 $tab->text( 
		   name => $fieldId . '_floatMin',
	           label => 'float min label',
	           hoverHelp => 'float min help',
		   defaultValue => $description->{floatMin} || '',
              );
	 $tab->text( 
		   name => $fieldId . '_floatMax',
	           label => 'float max label',
	           hoverHelp => 'float max help',
		   defaultValue => $description->{floatMax} || '',
              );
     },
     readForm => sub {
         my $form = shift;
	 my $fieldId = shift;
	 my $description = shift;
	 $description->{floatMax} = $form->get($fieldId . '_floatMax');
	 $description->{floatMin} = $form->get($fieldId . '_floatMin');
     }, },
     vendor => { generate => sub {
         my $tab = shift;
	 my $fieldId = shift;
	 my $description = shift;
	 $tab->readOnly( 
	           label => 'TODO',
		   value => 'vendor needs work -- this might get eliminated',
              );
     },
     readForm => sub {
         my $form = shift;
	 my $fieldId = shift;
	 my $description = shift;
         # add the correct variables to the description hash that is passed in
     }, },
     yesNo => { generate => sub {
         my $tab = shift;
	 my $fieldId = shift;
	 my $description = shift;
         # nothing here...
	 #$tab->readOnly( 
	 #          label => 'TODO',
	#	   value => $field->{fieldType} . ' needs work -- possibly no extra options',
        #      );
     },
     readForm => sub {
         my $form = shift;
	 my $fieldId = shift;
	 my $description = shift;
         # nothing here...
     }, },
     text => { generate => sub {
         my $tab = shift;
	 my $fieldId = shift;
	 my $description = shift;
	 $tab->list( 
		  name => $fieldId . '_textSelect',
	          multiple => 0,
		  options => {
		  # TODO internationalize this
		      selectList => 'select list',
		      freeText => 'free text',
		  },
		  defaultValue => $description->{dateSelect} || ['freeText'],
		  label => 'text selection label',
		  hoverHelp => 'text selection help',
              );
	$tab->textarea( 
		  name => $fieldId . '_textTextArea',
		  label => 'text textarea label',
		  hoverHelp => 'text textarea help',
		  defaultValue => $description->{textTextArea} || '',
              );
     },
     readForm => sub {
         my $form = shift;
	 my $fieldId = shift;
	 my $description = shift;
	 $description->{textSelect} = $form->get($fieldId . '_textSelect');
	 $description->{textTextArea} = $form->get($fieldId . '_textTextArea');
     }, },
     textarea => { generate => sub {
         my $tab = shift;
	 my $fieldId = shift;
	 my $description = shift;
         # nothing here...
	 #$tab->readOnly( 
	 #          label => 'TODO',
	#	   value => $field->{fieldType} . ' needs work -- might get eliminated or have no options',
        #      );
     },
     readForm => sub {
         my $form = shift;
	 my $fieldId = shift;
	 my $description = shift;
         # nothing here...
     }, },
     file => { generate => sub {
         my $tab = shift;
	 my $fieldId = shift;
	 my $description = shift;
         # nothing here...
	 #$tab->readOnly( 
	 #          label => 'TODO',
	#	   value => $field->{fieldType} . ' needs work -- might get eliminated or have no options',
        #      );
     },
     readForm => sub {
         my $form = shift;
	 my $fieldId = shift;
	 my $description = shift;
         # nothing here...
     }, },
     HTMLArea => { generate => sub {
         my $tab = shift;
	 my $fieldId = shift;
	 my $description = shift;
         # nothing here...
	 #$tab->readOnly( 
	 #          label => 'TODO',
	#	   value => $field->{fieldType} . ' needs work -- might get eliminated or have no options',
        #      );
     },
     readForm => sub {
         my $form = shift;
	 my $fieldId = shift;
	 my $description = shift;
         # nothing here...
     }, },
     # TODO add all of the other control types
};

#-------------------------------------------------------------------

=head2 _readForm ( parent, @fieldIds )

reads the form description out of the session->form

=head3 parent

the parent of the form

=head3 fieldIds

list of fieldIds that are in the form

=cut

sub _readForm {
    my $parent = shift;
    my $form = shift;
    my $fieldList = shift;
    my $formDescription;

    $formDescription->{activeFields} = [ split ' ', $form->get('activeFields') ];
    $formDescription->{requiredFields} = [ split ' ', $form->get('requiredFields') ];

    for my $fieldId ( split ' ', $fieldList ) {
        _readFields($form,$fieldId,$formDescription);
    }

}

#-------------------------------------------------------------------

=head2 addSubmission

Creates an EMSSubmission object based on the params
( called by www_saveSubmission )

=cut

sub addSubmission {
    my $self = shift;
    my $session = $self->session;
    my $params = shift || {};
    return { isValid => 0, errors => [ 'no permissions' ] } if ! $self->canSubmit;
    my $newParams = $self->validateSubmission($params);
    return $newParams if ! $newParams->{isValid} ;
    $newParams->{className} = 'WebGUI::Asset::EMSSubmission';
    $newParams->{status} = 'pending';
    $newParams->{submissionId} = $self->get('nextSubmissionId');
    $self->update({nextSubmissionId => $newParams->{submissionId}+1 });
    $self->addChild($newParams);
}

#-------------------------------------------------------------------

=head2 addRevision

This me>thod exists for demonstration purposes only.  The superclass
handles revisions to NewAsset Assets.

=cut

#sub addRevision {
#    my $self    = shift;
#    my $newSelf = $self->SUPER::addRevision(@_);
#    return $newSelf;
#}

#-------------------------------------------------------------------

=head2 canSubmit

returns true if current user can submit using this form

=cut

sub canSubmit {
    my $self = shift;

    return $self->session->user->isInGroup($self->get('canSubmitGroupId'));
}

#-------------------------------------------------------------------

=head2 definition ( session, definition )

defines asset properties for New Asset instances.  You absolutely need 
this method in your new Assets. 

=head3 session

=head3 definition

A hash reference passed in from a subclass definition.

=cut

sub definition {
    my $class      = shift;
    my $session    = shift;
    my $definition = shift;
    my $i18n       = WebGUI::International->new( $session, "Asset_EMSSubmissionForm" );
    tie my %properties, 'Tie::IxHash', (
        nextSubmissionId => { 
            tab          => "properties",
            fieldType    => "integer",
            defaultValue => 0,
            label        => $i18n->get("next submission id label"),
            hoverHelp    => $i18n->get("next submission id label help")
        },
        canSubmitGroupId => { 
            tab          => "security",
            fieldType    => "group",
            defaultValue => 2,
            label        => $i18n->get("can submit group label"),
            hoverHelp    => $i18n->get("can submit group label help")
        },
        daysBeforeCleanup => { 
            tab          => "properties",
            fieldType    => "integer",
            defaultValue => 7,
            label        => $i18n->get("days before cleanup label"),
            hoverHelp    => $i18n->get("days before cleanup label help")
        },
        deleteCreatedItems => { 
            tab          => "properties",
            fieldType    => "yesNo",
            defaultValue => undef,
            label        => $i18n->get("delete created items label"),
            hoverHelp    => $i18n->get("delete created items label help")
        },
        submissionDeadline => { 
            tab          => "properties",
            fieldType    => "Date",
            defaultValue => '677496912', # far in the future...
            label        => $i18n->get("submission deadline label"),
            hoverHelp    => $i18n->get("submission deadline label help")
        },
        pastDeadlineMessage => { 
            tab          => "properties",
            fieldType    => "HTMLArea",
            defaultValue => $i18n->get('past deadline message'),
            label        => $i18n->get("past deadline label"),
            hoverHelp    => $i18n->get("past deadline label help")
        },
        formDescription => { 
            tab          => "properties",
            fieldType    => "textarea",
            defaultValue => '{ }',
            label        => $i18n->get("form dscription label"),
            hoverHelp    => $i18n->get("form dscription label help")
        },
    );
    push @{$definition}, {
        assetName         => $i18n->get('assetName'),
        icon              => 'EMSSubmissionForm.gif',
        autoGenerateForms => 1,
        tableName         => 'EMSSubmissionForm',
        className         => 'WebGUI::Asset::EMSSubmissionForm',
        properties        => \%properties,
    };
    return $class->SUPER::definition( $session, $definition );
} ## end sub definition

#-------------------------------------------------------------------

=head2 duplicate

This method exists for demonstration purposes only.  The superclass
handles duplicating NewAsset Assets.  This method will be called 
whenever a copy action is executed

=cut

#sub duplicate {
#    my $self     = shift;
#    my $newAsset = $self->SUPER::duplicate(@_);
#    return $newAsset;
#}

#-------------------------------------------------------------------

=head2 getFormDescription

returns a hash ref decoded from the JSON in the form description field

=cut

sub getFormDescription {
    my $self = shift;
    return JSON->new->decode($self->get('formDescription'));
}

#-------------------------------------------------------------------

=head2 indexContent ( )

Making private. See WebGUI::Asset::indexContent() for additonal details. 

=cut

#sub indexContent {
#    my $self    = shift;
#    my $indexer = $self->SUPER::indexContent;
#    $indexer->setIsPublic(0);
#}

#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
    my $self = shift;
    $self->SUPER::prepareView();
    my $template = WebGUI::Asset::Template->new( $self->session, $self->get("templateId") );
    $template->prepare($self->getMetaDataAsTemplateVariables);
    $self->{_viewTemplate} = $template;
}

#-------------------------------------------------------------------

=head2 processPropertiesFromFormPost ( )

Used to process properties from the form posted.  Do custom things with
noFormPost fields here, or do whatever you want.  This method is called
when /yourAssetUrl?func=editSave is requested/posted.

=cut

sub processPropertiesFromFormPost {
    my $self = shift;
    $self->SUPER::processPropertiesFromFormPost;
}

#-------------------------------------------------------------------

=head2 purge ( )

This method is called when data is purged by the system.
removes collateral data associated with a NewAsset when the system
purges it's data.  This method is unnecessary, but if you have 
auxiliary, ancillary, or "collateral" data or files related to your 
asset instances, you will need to purge them here.

=cut

#sub purge {
#    my $self = shift;
#    return $self->SUPER::purge;
#}

#-------------------------------------------------------------------

=head2 purgeRevision ( )

This method is called when data is purged by the system.

=cut

#sub purgeRevision {
#    my $self = shift;
#    return $self->SUPER::purgeRevision;
#}

#-------------------------------------------------------------------

=head2 view ( )

method called by the container www_view method. 

=cut

sub view {
    my $self = shift;
    my $var  = $self->get;    # $var is a hash reference.
    $var->{controls} = $self->getToolbar;
    return $self->processTemplate( $var, undef, $self->{_viewTemplate} );
}

#-------------------------------------------------------------------

=head2 validateSubmission ( submission )

test submitted data against form description

=head3 submission

hash ref with the submitted data

=cut

sub validateSubmission {
    my $self    = shift;
    my $submission = shift;
    my $adminOverride = JSON->new->decode( $submission->{adminOverride} || ' { } ' );
    my $session = $self->session;
    my $target = { isValid => 1, adminOverride => $adminOverride };
    my $form = $self->getFormDescription;
    for  my $field (keys %{$form}) {
        next if not defined $form->{$field}{type};
        my $value = $submission->{$field} || $form->{$field}{default} || '';
        $self->validateSubmissionField( $value, $form->{$field}, $field, $target );
    }
    return $target;
}

#-------------------------------------------------------------------

=head2 validateSubmissionField ( value, fieldDef, name )

test field data against definition

=head4 value

value submitted

=head4 fieldDef

field definition

=head4 name

name of the field -- for error reporting

=cut

sub validateSubmissionField {
     my $self = shift;
     my $value = shift;
     my $fieldDef = shift;
     my $name = shift;
     my $target = shift;
     if( exists $target->{adminOverride}{$name} ) {
	 if( ( $target->{adminOverride}{$name}{type} =~ /(float|integer)/i 
	      && $target->{adminOverride}{$name}{value} == $value ) 
	    || $target->{adminOverride}{$name}{value} eq $value 
	       ) {
	     $target->{$name} = $value;
	     return 1;
	  }
     }
     if( $value eq '' ) {
	 $target->{$name} = $value;
	 return 1;
     }
     if( $fieldDef->{required} && $value eq '' ) {
         $target->{isvalid} = 0;
	 push @{$target->{errors}}, $name . ' is a required field'; # TODO internationalize
	 return 0;
     }
     my $type = $fieldDef->{type};
     if( $type eq 'url' ) {
         if( $value !~ /^http:/ ) { # TODO get a better test for Earls
	     $target->{isValid} = 0;
	     push @{$target->{errors}}, $name . ' is not a valid Url'; # TODO internationalize
	     return 0;
	 }
     } elsif( $type eq 'integer' ) {
         $value = int( $value );
	 if( $fieldDef{integerMin} ne '' && $value < $fieldDef{integerMin} ) {
	     $target->{isValid} = 0;
	     push @{$target->{errors}}, $name . ' is less than the minimum allowed'; # TODO internationalize
	     return 0;
	 }
	 if( $fieldDef{integerMax} ne '' && $value > $fieldDef{integerMax} ) {
	     $target->{isValid} = 0;
	     push @{$target->{errors}}, $name . ' is greater than the maximum allowed'; # TODO internationalize
	     return 0;
	 }
     } elsif( $type eq 'float' ) {
	 if( $fieldDef{floatMin} ne '' && $value < $fieldDef{floatMin} ) {
	     $target->{isValid} = 0;
	     push @{$target->{errors}}, $name . ' is less than the minimum allowed'; # TODO internationalize
	     return 0;
	 }
	 if( $fieldDef{floatMax} ne '' && $value > $fieldDef{floatMax} ) {
	     $target->{isValid} = 0;
	     push @{$target->{errors}}, $name . ' is greater than the maximum allowed'; # TODO internationalize
	     return 0;
	 }
     } elsif( $type eq 'text' ) {
         ;   # there is no test here...
     } elsif( $type eq 'textarea' ) {
         ;   # there is no test here...
     } elsif( $type eq 'selectList' ) {
         if( ! grep { $_ eq $value } @{$fieldDef->{options}} ) {
	     $target->{isValid} = 0;
	     push @{$target->{errors}}, $name . ' is not a valid Selection';
	     return 0;
	 }
     } else {
	 push @{$target->{errors}}, $type . ' is not a valid data type';
	 return 0;
     }
     $target->{$name} = $value;
     return 1;
}

#-------------------------------------------------------------------

=head2 www_edit ( )

Web facing method which is the default edit page.  Unless the method needs
special handling or formatting, it does not need to be included in
the module.

=cut

sub www_edit {
    my $self    = shift;
    my $session = $self->session;
    return $session->privilege->insufficient() unless $self->canEdit;
    return $session->privilege->locked()       unless $self->canEditIfLocked;
    my $i18n = WebGUI::International->new( $session, 'Asset_EMSSubmissionForm' );
    return $self->getAdminConsole->render( $self->getEditForm->print, $i18n->get('edit asset') );
}

#-------------------------------------------------------------------

=head2  www_editSubmissionForm 

is assetId is 'new' edit a blank form, else edit a form with stuff filled in...

=cut

sub editSubmissionForm {
	my $class             = shift;
	my $parent             = shift;
	my $session = $parent->session;
	my $i18n = WebGUI::International->new($parent->session,'Asset_EventManagementSystem');
	my $form = $session->form;
        my $assetId = shift || $form->get('assetId');
	my $self;

        if( ! defined( $assetId ) ) {
	   my $res = $parent->getLineage(['children'],{ returnObjects => 1,
		 includeOnlyClasses => ['WebGUI::Asset::EMSSubmissionForm'],
	     } );
	    if( scalar(@$res) == 1 ) {
	        $self = $res->[0];
		$assetId = $self->getId;
	    } else {
	        my $makeAnchorList =sub{ my $u=shift; my $n=shift; my $d=shift;
		            return qq{<li><a href='$u' title='$d'>$n</a></li>} } ;
	        my $listOfLinks = join '', ( map {
		      $makeAnchorList->(
		                $parent->getUrl('func=editSubmissionForm;assetId=' . $_->getId ),
				$_->get('title'),
				WebGUI::HTML::filter($_->get('description'),'all')
		             )
		           } ( @$res ) );
		return $parent->processStyle( '<h1>' . $i18n->get('select form to edit') .
		                            '</h1><ul>' . $listOfLinks . '</ul>' );
	    }
        } elsif( $assetId ne 'new' ) {
	    $self = WebGUI::Asset->newByDynamicClass($session,$assetId);
	    if (!defined $self) { 
		$session->errorHandler->error(__PACKAGE__ . " - failed to instanciate asset with assetId $assetId");
	    }
        }
	my $tabform = WebGUI::TabForm->new($session,undef,undef,$parent->getUrl());
	my $fields;
	# fixed order for the regular tabs
	my @fieldNames = qw/startDate duration seatsAvailable location /;
	my @defs = reverse @{WebGUI::Asset::EMSSubmission->definition($session)};
dav::dump 'editSubmissionForm::definition:', [@defs];
	for my $def ( @defs ) {
	    foreach my $fieldName ( @fieldNames ) {
                my $properties = $def->{properties};
	        if( defined $properties->{$fieldName} ) {
		      $fields->{$fieldName} = { %{$properties->{$fieldName}} }; # a simple first level copy
		      # field definitions don't contain their own name, we will need it later on
		      $fields->{$fieldName}{fieldId} = $fieldName;
		  };
	    }
	}
	# add the meta field tabs
	for my $metaField ( @{$parent->getEventMetaFields} ) {
	    push @fieldNames, $metaField->{fieldId};
	    $fields->{$metaField->{fieldId}} = { %$metaField }; # a simple first level copy
	    # meta fields call it data type, we copy it to simplify later on
	    $fields->{$metaField->{fieldId}}{fieldType} = $metaField->{dataType};
	}
        unshift @fieldNames, 'main';
        $fields->{main} = { label => $i18n->get('main tab label'), fieldId => 'main' };
        # create tabs
        for my $tabname ( @fieldNames ) {
                $tabform->addTab($tabname, $fields->{$tabname}{label}, $0 );
        }
        my $maintab = $tabform->getTab('main');
	$maintab->hidden(name => 'fieldList', value => join( ' ', @fieldNames ) );
	@defs = reverse @{WebGUI::Asset::EMSSubmissionForm->definition($session)};
dav::dump 'editSubmissionForm::dump submission form def', \@defs ;
        for my $def ( @defs ) {
	    my $properties = $def->{properties};
	    for my $fieldName ( qw/title menuTitle url description canSubmitGroupId daysBeforeCleanup
                               deleteCreatedItems submissionDeadline pastDeadlineMessage/ ) {
	        if( defined $properties->{$fieldName} ) {
                    my %param = %{$properties->{$fieldName}};
		    $param{value} = $form->get($fieldName) || $self ? $self->get($fieldName) : $param{defaultValue} || '';
		    $param{name} = $fieldName;
dav::dump 'editSubmissionForm::properties for ', $fieldName, \%param ;
		    $maintab->dynamicField(%param);
		}
	    }
        }
dav::dump 'editSubmissionForm::dump before generate:',$fields;
	my $formDescription;
	     # TODO move the fieldList to session scratch or something on the server... - this is a security issue...
	if( my $fieldList = $form->get('fieldList') ) {  # if this form variable exists then the form was submitted...
	    $formDescription = _readForm($parent,$form,$fieldList);  # so we get the description from the form
	} else {
	    $formDescription = $self ? $self->getFormDescription : { };
	}
        for my $field ( values %$fields ) {
            next if $field->{fieldId} eq 'main' ;
	    _generateFields($tabform, $field,$formDescription);
	}
	return $parent->processStyle(
               $parent->processTemplate({
                      backUrl => $parent->getUrl,
		      pageForm => $tabform->print,
                  },$parent->get('eventSubmissionFormTemplateId')));
}

1;

#vim:ft=perl
