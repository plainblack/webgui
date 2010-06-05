package WebGUI::Asset::EMSSubmission;

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
use Moose;
use WebGUI::Definition::Asset;
use WebGUI::Asset;
use WebGUI::International;
extends 'WebGUI::Asset';
define tableName => 'EMSSubmission';
define assetNae  => ['assetName', 'Asset_EMSSubmission'];
define icon      => 'EMSSubmission.gif';

property submissionId => (
    noFormPost => 1,
    fieldType  => "hidden",
    default    => undef,
);
property submissionStatus => (
    fieldType        => "selectList",
    default          => 'pending',
    customDrawMethod => 'drawStatusField',
    label            => [ "submission status", 'Asset_EMSSubmission' ],
    hoverHelp        => [ "submission status help", 'Asset_EMSSubmission' ]
);
property description => (
    tab       => "properties",
    fieldType => "HTMLArea",
    default   => undef,
    label     => [ "description", 'Asset_Sku' ],
    hoverHelp => [ "description help", 'Asset_Sku' ]
);
property sku => (
    tab       => "shop",
    fieldType => "text",
    builder   => '_builder_sku',
    lazy      => 1,
    label     => [ "sku", 'Asset_Sku' ],
    hoverHelp => [ "sku help", 'Asset_Sku' ]
);
sub _builder_sku {
    my $self = shift;
    return $self->session->id->generate;
}
property displayTitle => (
    tab       => "display",
    fieldType => "yesNo",
    default   => 1,
    label     => [ "display title", 'Asset_Sku' ],
    hoverHelp => [ "display title help", 'Asset_Sku' ]
);
property vendorId => (
    tab       => "shop",
    fieldType => "vendor",
    default   => 'defaultvendor000000000',
    label     => [ "vendor", 'Asset_Sku' ],
    hoverHelp => [ "vendor help", 'Asset_Sku' ]
);
property shipsSeparately => (
    tab       => 'shop',
    fieldType => 'yesNo',
    default   => 0,
    label     => [ 'shipsSeparately', 'Asset_Sku' ],
    hoverHelp => [ 'shipsSeparately help', 'Asset_Sku' ],
);

property price => (
    tab       => "shop",
    fieldType => "float",
    default   => 0.00,
    label     => [ "price", 'Asset_EMSSubmission' ],
    hoverHelp => [ "price help", 'Asset_EMSSubmission' ],
);
property seatsAvailable => (
    tab       => "shop",
    fieldType => "integer",
    default   => 25,
    label     => [ "seats available", 'Asset_EMSSubmission' ],
    hoverHelp => [ "seats available help", 'Asset_EMSSubmission' ],
);
property startDate => (
    noFormPost   => 1,
    fieldType    => "dateTime",
    default      => '',
    label        => [ "add/edit event start date", 'Asset_EMSSubmission' ],
    hoverHelp    => [ "add/edit event start date help", 'Asset_EMSSubmission' ],
    autoGenerate => 0,
);
property duration => (
    tab       => "properties",
    fieldType => "float",
    default   => 1.0,
    subtext   => [ 'hours', 'Asset_EMSSubmission' ],
    label     => [ "duration", 'Asset_EMSSubmission' ],
    hoverHelp => [ "duration help", 'Asset_EMSSubmission' ],
);
property location => (
    fieldType        => "combo",
    tab              => "properties",
    customDrawMethod => 'drawLocationField',
    label            => [ "location", 'Asset_EMSSubmission' ],
    hoverHelp        => [ "location help", 'Asset_EMSSubmission' ],
);
property relatedBadgeGroups => (
    tab              => "properties",
    fieldType        => "checkList",
    customDrawMethod => 'drawRelatedBadgeGroupsField',
    label            => [ "related badge groups", 'Asset_EMSSubmission' ],
    hoverHelp        => [ "related badge groups ticket help", 'Asset_EMSSubmission' ],
);
property relatedRibbons => (
    tab              => "properties",
    fieldType        => "checkList",
    customDrawMethod => 'drawRelatedRibbonsField',
    label            => [ "related ribbons", 'Asset_EMSSubmission' ],
    hoverHelp        => [ "related ribbons help", 'Asset_EMSSubmission' ],
);
property eventMetaData => (
    noFormPost => 1,
    fieldType  => "hidden",
    default    => '{}',
);
property ticketId => (
    noFormPost => 1,
    fieldType  => "hidden",
    default    => '',
);

with 'WebGUI::Role::Asset::Comments';

use Tie::IxHash;
use WebGUI::Utility;
use WebGUI::Inbox;

=head1 NAME

Package WebGUI::Asset::EMSSubmission

=head1 DESCRIPTION

Describe your New Asset's functionality and features here.

=head1 SYNOPSIS

use WebGUI::Asset::EMSSubmission;

=head1 TODO

the comments tab may need to be added in a getEditForm function like Sku::EMSTicket

make a button/link for the admin to view the submission as the owner sees it.

the www_edit function should see if the userid is the owner and call a seperate function
else if it is not in the admin group return insufitient priviledges
else call the getEditForm function like sku::EMSTicket does...


=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 addComment ( comment [, rating, user ] )

send email when a comment is added

=cut

around addComment => sub {
    my $orig = shift;
    my $self = shift;
    $self->update({lastReplyBy => $self->session->user->userId});
    $self->$orig(@_);
    $self->sendEmailUpdate;
};


#-------------------------------------------------------------------

=head2 drawLocationField ()

Draws the field for the location property.

=cut

sub drawLocationField {
        my ($self, $params) = @_;
	my $ems = $self->ems;
	my $options = { map { $_ => $_ } ( @{ $ems->getSubmissionLocations || [ $ems->getLocations ] } ) } ;
	if( $ems->isRegistrationStaff ) {
	    return WebGUI::Form::combo($self->session, {
		    name    => 'location',
		    value   => $self->get('location'),
		    options => $options,
		});
	} else {
	    return WebGUI::Form::selectBox($self->session, {
		    name    => 'location',
		    value   => $self->get('location'),
		    options => $options,
		});
	}
}

#-------------------------------------------------------------------

=head2 drawRelatedBadgeGroupsField ()

Draws the field for the relatedBadgeGroups property.

=cut

sub drawRelatedBadgeGroupsField {
        my ($self, $params) = @_;
        return WebGUI::Form::checkList($self->session, {
                name            => $params->{name},
                value           => $self->get($params->{name}),
                vertical        => 1,
                options         => $self->getParent->getParent->getBadgeGroups,
                });
}

#-------------------------------------------------------------------

=head2 drawRelatedRibbonsField ()

Draws the field for the relatedRibbons property.

=cut

sub drawRelatedRibbonsField {
        my ($self, $params) = @_;
        my %ribbons = ();
        foreach my $ribbon (@{$self->getParent->getParent->getRibbons}) {
                $ribbons{$ribbon->getId} = $ribbon->getTitle;
        }
        return WebGUI::Form::checkList($self->session, {
                name            => $params->{name},
                value           => $self->get($params->{name}),
                vertical        => 1,
                options         => \%ribbons,
                });
}

#-------------------------------------------------------------------

=head2 drawStatusField

=cut

sub drawStatusField {
        my ($self, $params) = @_;
        my $options = $self->ems->getSubmissionStatus;
        my $currentStatus = $self->get('submissionStatus');
        for my $key ( qw/pending created failed/ ) {
            delete $options->{$key} unless $currentStatus eq $key;
        }
        return WebGUI::Form::SelectBox($self->session, {
                name    => 'submissionStatus',
                value   => $currentStatus,
                options => $options,
                });
}


#-------------------------------------------------------------------

=head2 ems

returns the ems ansestor of this asset

=cut

sub ems {
    my $self = shift;
    $self->getParent->getParent
}

#-------------------------------------------------------------------

=head2 sendEmailUpdate

if the sendEmail on change is turned on then send email to the owner

=cut

sub sendEmailUpdate {
    my $self = shift;
    my $session = $self->session;
    my $i18n       = WebGUI::International->new( $session, "Asset_EMSSubmission" );
	WebGUI::Inbox->new($session)->addMessage( {
	   status => 'unread',
	   message => $i18n->get('your submission has been updated') . "\n\n" .
			 $self->get('title'),
	   userId => $self->get('createdBy'),
	   sentBy => $session->user->userId,
	});
}

#-------------------------------------------------------------------

=head2 www_editSubmission ( parent, params )

edit a submission

=head3 parent

ref to the EMSSubmissionForm that is parent to the new submission

=head3 params

parameters for the submission

=cut

sub www_editSubmission {
        my $this             = shift;
        my $self;
        my $parent;
        if( $this eq __PACKAGE__ ) {   # called as a constructor
            $parent             = shift;
        } else {
            $self = $this;
            $parent = $self->getParent;
        }
        my $params           = shift || { };
        my $session = $parent->session;
        my $i18n = WebGUI::International->new($parent->session,'Asset_EventManagementSystem');
        my $i18n_WG = WebGUI::International->new($parent->session,'WebGUI');
        my $assetId = $self ? $self->getId : $params->{assetId} || $session->form->get('assetId') || 'new';

        if( $assetId ne 'new' ) {
            $self ||= eval { WebGUI::Asset->newById($session,$assetId); };
            if (Exception::Class->caught()) {
                $session->errorHandler->error(__PACKAGE__ . " - failed to instanciate asset with assetId $assetId");
            }
        }
        my $asset = $self || $parent;
	my $url = $asset->getUrl('func=editSubmissionSave');
        my $newform = WebGUI::HTMLForm->new($session,action => $url);
        $newform->hidden(name => 'assetId', value => $assetId);
	my $formDescription = $parent->getFormDescription;
	my @defs = reverse @{__PACKAGE__->definition($session)};
        my @fieldNames = qw/title submissionStatus startDate duration seatsAvailable location description/;
        my $fields;
        for my $def ( @defs ) {
	    my $properties = $def->{properties};
	    for my $fieldName ( keys %$properties ) {
		if( defined $formDescription->{$fieldName} ) {
		      $fields->{$fieldName} = { %{$properties->{$fieldName}} }; # a simple first level copy
		      if( $fieldName eq 'description' ) {
		          $fields->{description}{height} = 200;
		          $fields->{description}{width} = 350;
		      }
		      $fields->{$fieldName}{fieldId} = $fieldName;
		      $fields->{$fieldName}{name} = $fieldName;
		      $fields->{$fieldName}{value} = $self->get($fieldName) if $self;
		}
	    }
        }
        # add the meta field
        for my $metaField ( @{$parent->getParent->getEventMetaFields} ) {
	    my $fieldId = $metaField->{fieldId};
	    if( defined $formDescription->{$fieldId} ) {
		push @fieldNames, $fieldId;
		$fields->{$fieldId} = { %$metaField }; # a simple first level copy
		# meta fields call it data type, we copy it to simplify later on
		$fields->{$fieldId}{fieldType} = $metaField->{dataType};
		$fields->{$fieldId}{name} = $fieldId;
		$fields->{$fieldId}{value} = $self->get($fieldId) if $self;
	    }
        }

	# for each field
        if( $fields->{submissionStatus}{value} eq 'created' ) {
             $formDescription = { } ; # no editable fields once the ticket is created.
        }
	for my $fieldId ( @fieldNames ) {
	    my $field = $fields->{$fieldId};
	    if( $formDescription->{$field->{fieldId}} || $asset->ems->isRegistrationStaff ) {
		    my $drawMethod = __PACKAGE__ . '::' . $field->{customDrawMethod};
		    if ($asset->can( $drawMethod )) {
			$field->{value} = $asset->$drawMethod($field);
			delete $field->{name}; # don't want readOnly to generate a hidden field
			$field->{fieldType} = "readOnly";
		    }
 
	        $newform->dynamicField(%$field);
	    } else {
	        my $value;
	        # TODO see that the data gets formatted
                if( $fieldId eq 'submissionStatus' ) {
                    $value = $field->{value} || 'pending';
                    $value = $i18n->get($value);
                } else {
                    $value = $field->{value} || '[ ]';
                }
		$newform->readOnly(
		         label => $field->{label},
			 value => $value,
			 fieldId => $field->{fieldId},
	            );
	    }
	}
        $newform->submit;
	my $title = $asset->get('title');
        my $content = 
               $asset->processTemplate({
                      errors => $params->{errors} || [],
                      isDynamic => $session->form->get('asJson') || 0,
                      backUrl => $parent->getUrl,
                      pageTitle => $title,
                      pageForm => $newform->print,
		      commentForm => $self ? $self->getFormattedComments : '',
		      commentFlag => $self ? 1 : 0 ,
                  },$parent->getParent->get('eventSubmissionTemplateId'));
	   WebGUI::Macro::process( $session, \$content );
    if( $params->{asHashRef} ) {
	return { text => $content, title => $title, };
    } elsif( $session->form->get('asJson') ) {
        $session->http->setMimeType( 'application/json' );
	return JSON->new->encode( { text => $content, title => $title, id => $assetId ne 'new' ? $assetId : 'new' . rand } );
    } else {
        $session->http->setMimeType( 'text/html' );
        return $asset->processStyle( $content );
    }
}

#-------------------------------------------------------------------

=head2 www_editSubmissionSave

=cut

sub www_editSubmissionSave {
        my $self = shift;
        my $session = $self->session;
        return $session->privilege->insufficient() unless $self->canEdit;
        my $formParams = $self->processForm;
        if( $formParams->{_isValid} ) {
            delete $formParams->{_isValid};
            $self->addRevision($formParams);
	    WebGUI::VersionTag->autoCommitWorkingIfEnabled($session, { override => 1, allowComments => 0 });
	    $self = $self->cloneFromDb;
            $self->sendEmailUpdate;
            return $self->ems->www_viewSubmissionQueue;
        } else {
            return $self->www_editSubmission($formParams);
        }
}

#-------------------------------------------------------------------

=head2 www_view

calles ems->view

=cut

sub www_view { $_[0]->ems->www_viewSubmissionQueue }

#-------------------------------------------------------------------

=head2 getEditTabs ( )

defines 2 new tabs.
the shop tab is created here to mimic the function of the sku-created 
shop tab.  this class holds data like Sku assets so that they can be assigned
in the future when the sku asset is created from this data.

=cut

override getEditTabs => sub {
    my $self = shift;
    my $sku_i18n = WebGUI::International->new($self->session,"Asset_Sku");
    return (super(), ['shop', $sku_i18n->get('shop'), 9],);
};

#-------------------------------------------------------------------

=head2 getQueueUrl

returns the URL for the submission queue page with the submisison id in the hash part

=cut

sub getQueueUrl {
    my $self = shift;
    return $self->ems->getUrl('func=viewSubmissionQueue#' . $self->get('submissionId') );
}

#-------------------------------------------------------------------

=head2 indexContent ( )

Making private. See WebGUI::Asset::indexContent() for additonal details. 

=cut

override indexContent => sub {
    my $self    = shift;
    my $indexer = super();
    $indexer->setIsPublic(0);
};

#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
    my $self = shift;
    $self->ems->prepareView;
}

#----------------------------------------------------------------

=head2 processForm ( $parent )

pull data componenets out of $session->form

=head3 parent

reference to the EMS asset that is parent to the new submission form asset

=cut


sub processForm {
    my $this = shift;
    my $form;
    my $asset;
    my $parent;
    my $self;
    if( $this eq __PACKAGE__ ) {
        $parent = shift;
        $form = $parent->session->form;
	$asset = $parent;
    } else {
	$self = $this;
	$parent = $self->getParent;
        $form = $self->session->form;
	$asset = $self;
    }
    my $params = {_isValid=>1};
    my $formDescription = $parent->getFormDescription;
    my @idList;
    if( $asset->ems->isRegistrationStaff ) {
	@idList = ( 'submissionStatus', keys %$formDescription );
    } else {
	@idList = @{$formDescription->{_fieldList}} ;
    }
    for my $fieldId ( @idList ) {
	next if $fieldId =~ /^_/;
	$params->{$fieldId} = $form->get($fieldId);
    }
    return $params;
}


#-------------------------------------------------------------------

=head2 view ( )

method called by the container www_view method. 
NOTE: this should net get called, all views are redirected elsewhere.

=cut

sub view {
    my $self = shift;
    return $self->ems->view;
    #my $var  = $self->get;    # $var is a hash reference.
    #$var->{controls} = $self->getToolbar;
    #return $self->processTemplate( $var, undef, $self->{_viewTemplate} );
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
    my $i18n = WebGUI::International->new( $session, 'Asset_EMSSubmission' );
    return $self->getAdminConsole->render( $self->getEditForm->print, $i18n->get('edit asset') );
}

1;

#vim:ft=perl
