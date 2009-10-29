package WebGUI::Asset::EMSSubmission;

use lib '/root/pb/lib'; use dav;
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

use Class::C3;
use strict;
use Tie::IxHash;
use base qw(WebGUI::AssetAspect::Comments WebGUI::Asset);
use WebGUI::Utility;

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

=head2 addRevision

This method exists for demonstration purposes only.  The superclass
handles revisions to NewAsset Assets.

=cut

#sub addRevision {
#    my $self    = shift;
#    my $newSelf = $self->next::method(@_);
#    return $newSelf;
#}

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
    my $i18n       = WebGUI::International->new( $session, "Asset_EMSSubmission" );
    my $EMS_i18n = WebGUI::International->new($session, "Asset_EventManagementSystem");
    my $SKU_i18n = WebGUI::International->new($session, "Asset_Sku");
    tie my %properties, 'Tie::IxHash', (
		submissionId => {
			    noFormPost      => 1,
			    fieldType       => "hidden",
			    defaultValue => undef,
		},
		submissionStatus => {
			    fieldType    =>"selectList",
			    defaultValue => 'pending',
			customDrawMethod=> 'drawStatusField',
                        label                   => $i18n->get("submission status"),
                        hoverHelp               => $i18n->get("submission status help")
		},
                description => {
                        tab                             => "properties",
                        fieldType               => "HTMLArea",
                        defaultValue    => undef,
                        label                   => $SKU_i18n->get("description"),
                        hoverHelp               => $SKU_i18n->get("description help")
                        },
                sku => {
                        tab                             => "shop",
                        fieldType               => "text",
                        defaultValue    => $session->id->generate,
                        label                   => $SKU_i18n->get("sku"),
                        hoverHelp               => $SKU_i18n->get("sku help")
                        },
                displayTitle => {
                        tab                             => "display",
                        fieldType               => "yesNo",
                        defaultValue    => 1,
                        label                   => $SKU_i18n->get("display title"),
                        hoverHelp               => $SKU_i18n->get("display title help")
                        },
                vendorId => {
                        tab                             => "shop",
                        fieldType               => "vendor",
                        defaultValue    => 'defaultvendor000000000',
                        label                   => $SKU_i18n->get("vendor"),
                        hoverHelp               => $SKU_i18n->get("vendor help")
                        },
		shipsSeparately => {
		    tab             => 'shop',
		    fieldType       => 'yesNo',
		    defaultValue    => 0,
		    label           => $SKU_i18n->get('shipsSeparately'),
		    hoverHelp       => $SKU_i18n->get('shipsSeparately help'),
		},

		price => {
				tab             => "shop",
				fieldType       => "float",
				defaultValue    => 0.00,
				label           => $EMS_i18n->get("price"),
				hoverHelp       => $EMS_i18n->get("price help"),
		},
		seatsAvailable => {
				tab             => "shop",
				fieldType       => "integer",
				defaultValue    => 25,
				label           => $EMS_i18n->get("seats available"),
				hoverHelp       => $EMS_i18n->get("seats available help"),
		},
		startDate => {
			    noFormPost      => 1,
			    fieldType       => "dateTime",
			    defaultValue    => '',
			    label           => $EMS_i18n->get("add/edit event start date"),
			    hoverHelp       => $EMS_i18n->get("add/edit event start date help"),
			    autoGenerate    => 0,
		},
		duration => {
				tab             => "properties",
				fieldType       => "float",
				defaultValue    => 1.0,
				subtext         => $EMS_i18n->get('hours'),
				label           => $EMS_i18n->get("duration"),
				hoverHelp       => $EMS_i18n->get("duration help"),
		},
		location => {
				fieldType       => "combo",
				tab             => "properties",
				customDrawMethod=> 'drawLocationField',
				label           => $EMS_i18n->get("location"),
				hoverHelp       => $EMS_i18n->get("location help"),
		},
		relatedBadgeGroups => {
				tab             => "properties",
				fieldType       => "checkList",
				customDrawMethod=> 'drawRelatedBadgeGroupsField',
				label           => $EMS_i18n->get("related badge groups"),
				hoverHelp       => $EMS_i18n->get("related badge groups ticket help"),
		},
		relatedRibbons => {
				tab             => "properties",
				fieldType       => "checkList",
				customDrawMethod=> 'drawRelatedRibbonsField',
				label           => $EMS_i18n->get("related ribbons"),
				hoverHelp       => $EMS_i18n->get("related ribbons help"),
		},
		eventMetaData => {
				noFormPost              => 1,
				fieldType               => "hidden",
				defaultValue    => '{}',
		},
		sendEmailOnChange => {
		    tab          => "properties",
		    fieldType    => "yesNo",
		    defaultValue => 1,
		    label        => $i18n->get("send email label"),
		    hoverHelp    => $i18n->get("send email label help")
		},
                ticketId => {
				noFormPost              => 1,
				fieldType               => "hidden",
				defaultValue    => '',
                },
    );
    push @{$definition}, {
        assetName         => $i18n->get('assetName'),
        icon              => 'EMSSubmission.gif',
        autoGenerateForms => 1,
        tableName         => 'EMSSubmission',
        className         => 'WebGUI::Asset::EMSSubmission',
        properties        => \%properties,
        };
    return $class->next::method( $session, $definition );
} ## end sub definition

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
        return WebGUI::Form::SelectBox($self->session, {
                name    => 'location',
                value   => $self->get('submissionStatus'),
                options => $self->ems->getSubmissionStatus,
                });
}


#-------------------------------------------------------------------

=head2 duplicate

This method exists for demonstration purposes only.  The superclass
handles duplicating NewAsset Assets.  This method will be called 
whenever a copy action is executed

=cut

#sub duplicate {
#    my $self     = shift;
#    my $newAsset = $self->next::method(@_);
#    return $newAsset;
#}

#-------------------------------------------------------------------

=head2 ems

returns the ems ansestor of this asset

=cut

sub ems {
    my $self = shift;
    $self->getParent->getParent
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
dav::log 'EMSSubmission::www_editSubmission: got class/parent params';
        } else {
            $self = $this;
            $parent = $self->getParent;
dav::log 'EMSSubmission::www_editSubmission: got self param';
        }
        my $params           = shift || { };
        my $session = $parent->session;
        my $i18n = WebGUI::International->new($parent->session,'Asset_EventManagementSystem');
        my $assetId = $self ? $self->getId : $params->{assetId} || $session->form->get('assetId') || 'new';

        if( $assetId ne 'new' ) {
dav::log 'EMSSubmission::www_editSubmission: asseId ne new';
            $self ||= WebGUI::Asset->newByDynamicClass($session,$assetId);
            if (!defined $self) {
                $session->errorHandler->error(__PACKAGE__ . " - failed to instanciate asset with assetId $assetId");
            }
        }
        my $asset = $self || $parent;
	my $url = $asset->getUrl('func=editSubmissionSave');
        my $newform = WebGUI::HTMLForm->new($session,action => $url);
        $newform->hidden(name => 'assetId', value => $assetId);
	my $formDescription = $parent->getFormDescription;
	my @defs = reverse @{__PACKAGE__->definition($session)};
        my $fields;
        for my $def ( @defs ) {
	    my $properties = $def->{properties};
	    for my $fieldName ( %$properties ) {
		if( defined $formDescription->{$fieldName} ) {
		      $fields->{$fieldName} = { %{$properties->{$fieldName}} }; # a simple first level copy
		      $fields->{$fieldName}{fieldId} = $fieldName;
		}
	    }
        }
        # add the meta field
        for my $metaField ( @{$parent->getParent->getEventMetaFields} ) {
	    if( defined $formDescription->{$metaField->{fieldId}} ) {
		$fields->{$metaField->{fieldId}} = { %$metaField }; # a simple first level copy
		# meta fields call it data type, we copy it to simplify later on
		$fields->{$metaField->{fieldId}}{fieldType} = $metaField->{dataType};
	    }
        }

	# for each field
	for my $field ( values %$fields ) {
	    if( $formDescription->{$field->{fieldId}} || $asset->ems->isRegistrationStaff ) {
		    my $drawMethod = __PACKAGE__ . '::' . $field->{customDrawMethod};
		    if ($asset->can( $drawMethod )) {
			$field->{value} = $asset->$drawMethod($field);
			delete $field->{name}; # don't want readOnly to generate a hidden field
			$field->{fieldType} = "readOnly";
		    }
 
	        $newform->dynamicField(%$field);
	    } else {
	        # TODO see that the data gets formatted
		$newform->readOnly(
		         label => $field->{label},
			 value => $field->{value} || '[       ]',
			 fieldId => $field->{fieldId},
	            );
	    }
	}
	# TODO add the comment form
        $newform->submit;
	my $title = $assetId eq 'new' ? $i18n->get('new submission') || 'new' : $asset->get('submissionId');
        my $content =  $asset->processStyle(
               $asset->processTemplate({
                      errors => $params->{errors} || [],
                      backUrl => $parent->getUrl,
                      pageForm => $newform->print,
                  },$parent->getParent->get('eventSubmissionTemplateId')));
    if( $session->form->get('asJson') ) {
        $session->http->setMimeType( 'application/json' );
	return JSON->new->encode( { text => $content, title => $title } );
    } else {
        $session->http->setMimeType( 'text/html' );
        return $content;
    }
}

#-------------------------------------------------------------------

=head2 www_editSubmissionSave

=cut

sub www_editSubmissionSave {
        my $self = shift;
        return $self->session->privilege->insufficient() unless $self->canEdit;
        my $formParams = WebGUI::Asset::EMSSubmission->processForm($self);
        if( $formParams->{_isValid} ) {
            delete $formParams->{_isValid};
            $self->update($formParams);
            return $self->getParent->getParent->www_viewSubmissionQueue;
        } else {
            return $self->www_editSubmission($formParams);
        }
}

#-------------------------------------------------------------------

=head2 www_view

calles ems->view

=cut

sub www_view { $_[0]->ems->www_view }

#-------------------------------------------------------------------

=head2 getEditForm ( )

Extends the base class to add Tax information for the Sku, in a new tab.

=cut

sub getEditForm {
    my $self    = shift;
    my $session = $self->session;

    my $tabform = $self->SUPER::getEditForm;

    my $comments        = $tabform->getTab( 'comments' );

    #add the comments...
    $comments->div({name => 'comments',
      contentCallback => sub { $self->getFormattedComments },
    });

    return $tabform;
}

#-------------------------------------------------------------------

=head2 getEditTabs ( )

Not to be modified, just defines 2 new tabs.
the shop tab is created here to mimic the function of the sku-created 
shop tab.  this class holds data like Sku assets so that they can be assigned
in the future when the sku asset is created from this data.

=cut

sub getEditTabs {
        my $self = shift;
        my $i18n = WebGUI::International->new($self->session,"Asset_EMSSubmission");
        my $sku_i18n = WebGUI::International->new($self->session,"Asset_Sku");
        return ($self->SUPER::getEditTabs(), ['shop', $sku_i18n->get('shop'), 9], ['comments', $i18n->get('comments'), 9]);
}

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

sub indexContent {
    my $self    = shift;
    my $indexer = $self->next::method;
    $indexer->setIsPublic(0);
}

#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
    my $self = shift;
    $self->ems->prepareView;
    #$self->next::method();
    #my $template = WebGUI::Asset::Template->new( $self->session, $self->get("templateId") );
    #$template->prepare($self->getMetaDataAsTemplateVariables);
    #$self->{_viewTemplate} = $template;
}

#----------------------------------------------------------------

=head2 processForm ( $parent )

pull data componenets out of $session->form

=head3 parent

reference to the EMS asset that is parent to the new submission form asset

=cut

use lib '/root/pb/lib'; use dav;

sub processForm {
    my $this = shift;
    my $form;
    if( $this eq __PACKAGE__ ) {
        my $parent = shift;
        $form = $parent->session->form;
    } elsif( ref $this eq __PACKAGE__ ) {
        $form = $this->session->form;
    } else {
        return {_isValid => 0, errors => [ { text => 'invalid function call' } ] };
    }
    my $params = {_isValid=>1};
    # TODO
    # get description from parent
    # for each active field
        # get data from session->form
}

#-------------------------------------------------------------------

=head2 processPropertiesFromFormPost ( )

Used to process properties from the form posted.  Do custom things with
noFormPost fields here, or do whatever you want.  This method is called
when /yourAssetUrl?func=editSave is requested/posted.

=cut

sub processPropertiesFromFormPost {
    my $self = shift;
    $self->next::method;
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
#    return $self->next::method;
#}

#-------------------------------------------------------------------

=head2 purgeRevision ( )

This method is called when data is purged by the system.

=cut

#sub purgeRevision {
#    my $self = shift;
#    return $self->next::method;
#}

#-------------------------------------------------------------------

=head2 view ( )

method called by the container www_view method. 

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
