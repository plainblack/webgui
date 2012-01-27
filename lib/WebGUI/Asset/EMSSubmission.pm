package WebGUI::Asset::EMSSubmission;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2012 Plain Black Corporation.
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
use WebGUI::Form::Combo;
use WebGUI::Form::SelectBox;
use WebGUI::Form::CheckList;

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
    label     => [ "price", 'Asset_EventManagementSystem' ],
    hoverHelp => [ "price help", 'Asset_EventManagementSystem' ],
);
property seatsAvailable => (
    tab       => "shop",
    fieldType => "integer",
    default   => 25,
    label     => [ "seats available", 'Asset_EventManagementSystem' ],
    hoverHelp => [ "seats available help", 'Asset_EventManagementSystem' ],
);
property startDate => (
    noFormPost   => 1,
    fieldType    => "dateTime",
    builder      => '_default_startDate',
    label        => [ "add/edit event start date", 'Asset_EventManagementSystem' ],
    hoverHelp    => [ "add/edit event start date help", 'Asset_EventManagementSystem' ],
    autoGenerate => 0,
);
sub _default_startDate {
    return WebGUI::DateTime->new()->toMysql;
}
property duration => (
    tab       => "properties",
    fieldType => "float",
    default   => 1.0,
    subtext   => [ 'hours', 'Asset_EventManagementSystem' ],
    label     => [ "duration", 'Asset_EventManagementSystem' ],
    hoverHelp => [ "duration help", 'Asset_EventManagementSystem' ],
);
property location => (
    fieldType        => "combo",
    tab              => "properties",
    customDrawMethod => 'drawLocationField',
    label            => [ "location", 'Asset_EventManagementSystem' ],
    hoverHelp        => [ "location help", 'Asset_EventManagementSystem' ],
);
property relatedBadgeGroups => (
    tab              => "properties",
    fieldType        => "checkList",
    customDrawMethod => 'drawRelatedBadgeGroupsField',
    label            => [ "related badge groups", 'Asset_EventManagementSystem' ],
    hoverHelp        => [ "related badge groups ticket help", 'Asset_EventManagementSystem' ],
);
property relatedRibbons => (
    tab              => "properties",
    fieldType        => "checkList",
    customDrawMethod => 'drawRelatedRibbonsField',
    label            => [ "related ribbons", 'Asset_EventManagementSystem' ],
    hoverHelp        => [ "related ribbons help", 'Asset_EventManagementSystem' ],
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
use base qw(WebGUI::Asset);
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
	    return WebGUI::Form::Combo->new($self->session, {
		    name    => 'location',
		    value   => $self->get('location'),
		    options => $options,
		})->toHtml;
	} else {
	    return WebGUI::Form::SelectBox->new($self->session, {
		    name    => 'location',
		    value   => $self->get('location'),
		    options => $options,
		})->toHtml;
	}
}

#-------------------------------------------------------------------

=head2 drawRelatedBadgeGroupsField ()

Draws the field for the relatedBadgeGroups property.

=cut

sub drawRelatedBadgeGroupsField {
        my ($self, $params) = @_;
        return WebGUI::Form::CheckList->new($self->session, {
                name            => $params->{name},
                value           => $self->get($params->{name}),
                vertical        => 1,
                options         => $self->getParent->getParent->getBadgeGroups,
                })->toHtml;
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
        return WebGUI::Form::CheckList->new($self->session, {
                name            => $params->{name},
                value           => $self->get($params->{name}),
                vertical        => 1,
                options         => \%ribbons,
                })->toHtml;
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
        return WebGUI::Form::SelectBox->new($self->session, {
                name    => 'submissionStatus',
                value   => $currentStatus,
                options => $options,
                })->toHtml;
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
                $session->log->error(__PACKAGE__ . " - failed to instanciate asset with assetId $assetId");
            }
        }
        my $asset = $self || $parent;
	my $url = $asset->getUrl('func=editSubmissionSave');
        my $newform = WebGUI::FormBuilder->new($session,action => $url);
        $newform->addField( "hidden", name => 'assetId', value => $assetId);
	my $formDescription = $parent->getFormDescription;
        my @fieldNames = qw/title submissionStatus startDate duration seatsAvailable location description/;
        my $fields;
        my $class   = 'WebGUI::Asset::EMSSubmission';
        foreach my $fieldName (@fieldNames) {
            my $attr            = $class->meta->find_attribute_by_name( $fieldName );
            $fields->{$fieldName} = {
                                fieldId     => $fieldName,
                                name        => $fieldName,
                                fieldType   => $attr->fieldType,
                                noFormPost  => $attr->noFormPost,
                                %{ $class->getFormProperties( $session, $fieldName ) },
                    };
              if( $fieldName eq 'description' ) {
                  $fields->{description}{height} = 200;
                  $fields->{description}{width} = 350;
              }
              $fields->{$fieldName}{value} = $self->get($fieldName) if $self;
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
        $fields->{$fieldId}{options} = $metaField->{possibleValues};
        $fields->{$fieldId}{defaultValue} = $metaField->{defaultValues};
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
			$field->{addHidden} = 0;
			$field->{fieldType} = "readOnly";
		    }
 
	        $newform->addField( $field->{fieldType}, %$field);
	    } else {
	        my $value;
	        # TODO see that the data gets formatted
                if( $fieldId eq 'submissionStatus' ) {
                    $value = $field->{value} || 'pending';
                    $value = $i18n->get($value);
                } else {
                    $value = $field->{value} || '[ ]';
                }
		$newform->addField( "readOnly", 
		         label => $field->{label},
			 value => $value,
			 fieldId => $field->{fieldId},
	            );
	    }
	}
        $newform->addField( "submit", name => "send" );
	my $title = $asset->get('title');
        my $content = 
               $asset->processTemplate({
                      errors => $params->{errors} || [],
                      isDynamic => $session->form->get('asJson') || 0,
                      backUrl => $parent->getUrl,
                      pageTitle => $title,
                      pageForm => $newform->toHtml,
		      commentForm => $self ? $self->getFormattedComments : '',
		      commentFlag => $self ? 1 : 0 ,
                      %{ $newform->toTemplateVars },
                  },$parent->getParent->get('eventSubmissionTemplateId'));
	   WebGUI::Macro::process( $session, \$content );
    if( $params->{asHashRef} ) {
	return { text => $content, title => $title, };
    } elsif( $session->form->get('asJson') ) {
        $session->response->content_type( 'application/json' );
	return JSON->new->encode( { text => $content, title => $title, id => $assetId ne 'new' ? $assetId : 'new' . rand } );
    } else {
        $session->response->content_type( 'text/html' );
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
            my $tag = WebGUI::VersionTag->getWorking( $session );
            my $newRevision = $self->addRevision({%$formParams,tagId => $tag->getId, status => "pending",});
            $newRevision->setVersionLock;
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

1;

#vim:ft=perl
