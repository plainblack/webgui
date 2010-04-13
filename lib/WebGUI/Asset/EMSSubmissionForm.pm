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

=head1 NAME

Package WebGUI::Asset::EMSSubmissionForm

=head1 DESCRIPTION

This Asset describes and builds a form which provides an interface for submitting a custom
subset of the EMSTicket asset.  Users create submissions which can be editted by admins
and then become EMSTicket's.

=head1 SYNOPSIS

use WebGUI::Asset::EMSSubmissionForm;

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 addSubmission

Creates an EMSSubmission object based on the params
( called by www_saveSubmission )

=cut

sub addSubmission {
    my $self = shift;
    my $form = $self->session->form;
    my $newParams = {};
    my $fieldList = $self->getFormDescription->{_fieldList};
    for  my $field ( @$fieldList ) {
        $newParams->{$field} = $form->get($field);
    }
    $newParams->{className} = 'WebGUI::Asset::EMSSubmission';
    $newParams->{submissionStatus} = 'pending';
    $newParams->{submissionId} = $self->ems->getNextSubmissionId;
    my $newAsset = $self->addChild($newParams);
    WebGUI::VersionTag->autoCommitWorkingIfEnabled($self->session, { override => 1, allowComments => 0 });
    $self = $self->cloneFromDb;
    return $newAsset;
}

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
            defaultValue => time + ( 30 * 24 * 60 * 60 ) , # 30 days
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

=head2 ems

returns the ems ansestor of this asset

=cut

sub ems {
    my $self = shift;
    $self->getParent
}

#-------------------------------------------------------------------

=head2  www_editSubmissionForm  ( [ parent, ] [ params ] )

create an html form for user to enter params for a new submissionForm asset

=head3 parent

the parent ems object -- needs to be passed only if this is a class level call

=head3 params

optional set of possibly incorrect submission form params

=cut

sub www_editSubmissionForm {
	my $this             = shift;
        my $self;
        my $parent;
        if( $this eq __PACKAGE__ ) {  # called as constructor or menu
	    $parent             = shift;
        } else {
            $self = $this;
            $parent = $self->getParent;
        }
	my $params           = shift || { };
	my $session = $parent->session;
	my $i18n = WebGUI::International->new($session,'Asset_EventManagementSystem');
        my $assetId = $self ? $self->getId : $params->{assetId} || $session->form->get('assetId');

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
		                $_->getQueueUrl,
				$_->get('title'),
				WebGUI::HTML::filter($_->get('description'),'all')
		             )
		           } ( @$res ) );
		my $title =  $i18n->get('select form to edit') ;
		my $content = '<h1>' . $title .  '</h1><ul>' . $listOfLinks . '</ul>' ;
                if( $params->{asHashRef} ) {
		    return { text => $content, title => $title, } ;
		} elsif( $session->form->get('asJson') ) {
		    $session->http->setMimeType( 'application/json' );
		    return JSON->new->encode( { text => $content, title => $title, id => 'list' . rand } );
		} else {
		    $session->http->setMimeType( 'text/html' );
		    return $parent->ems->processStyle( $content );
		}
	    }
        } elsif( $assetId ne 'new' ) {
	    $self ||= WebGUI::Asset->newByDynamicClass($session,$assetId);
	    if (!defined($self)) { 
		$session->errorHandler->error(__PACKAGE__ . " - failed to instanciate asset with assetId $assetId");
	    }
        }
        my $asset = $self || $parent;
        my $url = $asset->getUrl('func=editSubmissionFormSave');
	my $newform = WebGUI::HTMLForm->new( $session, action => $url );
	$newform->hidden(name => 'assetId', value => $assetId);
	my @fieldNames = qw/title description startDate duration seatsAvailable location/;
	my $fields;
	my @defs = reverse @{WebGUI::Asset::EMSSubmission->definition($session)};
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
	for my $metaField ( @{$parent->getEventMetaFields} ) {
	    push @fieldNames, $metaField->{fieldId};
	    $fields->{$metaField->{fieldId}} = { %$metaField }; # a simple first level copy
	    # meta fields call it data type, we copy it to simplify later on
	    $fields->{$metaField->{fieldId}}{fieldType} = $metaField->{dataType};
	    $fields->{$metaField->{fieldId}}{hoverHelp} = $metaField->{helpText};
	}
	$newform->hidden( name => 'fieldNames', value => join( ' ', @fieldNames ) );
	@defs = reverse @{WebGUI::Asset::EMSSubmissionForm->definition($session)};
        for my $def ( @defs ) {
	    my $properties = $def->{properties};
	    for my $fieldName ( qw/title menuTitle url description canSubmitGroupId daysBeforeCleanup
                               deleteCreatedItems submissionDeadline pastDeadlineMessage/ ) {
	        if( defined $properties->{$fieldName} ) {
                    my %fieldParams = %{$properties->{$fieldName}};
		    $fieldParams{name} = $fieldName;
		    $fieldParams{value} = $params->{$fieldName} || $self ? $self->get($fieldName) : undef ;
		    $newform->dynamicField(%fieldParams);
		}
	    }
        }

	my $formDescription = $params->{formDescription} || $self ? $self->getFormDescription : { };
        for my $fieldId ( @fieldNames ) {
            next if $fieldId eq 'submissionStatus';
	    my $field = $fields->{$fieldId};
	    $newform->yesNo(
	             label => $field->{label},
		     name => $field->{fieldId} . '_yesNo',
		     defaultValue => 0,
		     value => $formDescription->{$field->{fieldId}},
	    );
	}
	$newform->submit; 
        my $title = $assetId eq 'new' ? $i18n->get('new form') || 'new' : $asset->get('title');
	if( $params->{asHashRef} ) {
              ; # not setting mimie type
	} elsif( $session->form->get('asJson') ) {
	    $session->http->setMimeType( 'application/json' );
	} else {
	    $session->http->setMimeType( 'text/html' );
	}
	my $content = $asset->processTemplate({
		      errors => $params->{errors} || [],
                      isDynamic => $session->form->get('asJson') || 0,
                      backUrl => $parent->getUrl,
		      pageTitle => $title,
		      pageForm => $newform->print,
                  },$parent->get('eventSubmissionTemplateId'));
         WebGUI::Macro::process( $session, \$content );
	if( $params->{asHashRef} ) {
	    return { text => $content, title => $title };
	} elsif( $session->form->get('asJson') ) {
	    return JSON->new->encode( { text => $content, title => $title, id => $assetId ne 'new' ? $assetId : 'new' . rand } );
	} else {
	    return $asset->ems->processStyle( $content );
	}

}

#-------------------------------------------------------------------

=head2  www_editSubmissionFormSave  

test and save new params

=cut

sub www_editSubmissionFormSave {
        my $self = shift;
        return $self->session->privilege->insufficient() unless $self->canEdit;
        my $formParams = $self->processForm();
        if( $formParams->{_isValid} ) {
            delete $formParams->{_isValid};
            $self->addRevision($formParams);
            WebGUI::VersionTag->autoCommitWorkingIfEnabled($self->session);
            $self = $self->cloneFromDb;
            return $self->getParent->www_viewSubmissionQueue;
        } else {
            return $self->www_editSubmissionForm($formParams);
        }
}

#-------------------------------------------------------------------

=head2 www_view

calls ems->view

=cut

sub www_view { $_[0]->ems->www_viewSubmissionQueue }


#-------------------------------------------------------------------

=head2 getFormDescription

returns a hash ref decoded from the JSON in the form description field

=cut

sub getFormDescription {
    my $self = shift;
    return JSON->new->decode($self->get('formDescription'));
}

#-------------------------------------------------------------------

=head2 getQueueUrl

returns the URL for the submission queue page with the submisison id in the hash part

=cut

sub getQueueUrl {
    my $self = shift;
    return $self->ems->getUrl('func=viewSubmissionQueue#' . $self->getId );
}



#-------------------------------------------------------------------

=head2 view ( )

method called by the container www_view method. 
Note: this really shouldn't get called, all views are redirected elsewhere

=cut

sub view {
    my $self = shift;
    return $self->ems->view;
}


#----------------------------------------------------------------

=head2 www_addSubmission ( )

calls www_editSubmission with assetId == new

=cut

sub www_addSubmission {
    my $self = shift;
    my $params = shift || { };
    $self->www_editSubmission( { assetId => 'new', %$params } );
}

#-------------------------------------------------------------------

=head2  www_editSubmission  { params }

calls WebGUI::Asset::EMSSubmission->editSubmission

=cut

sub www_editSubmission {
    my $self             = shift;
    return $self->session->privilege->insufficient() unless $self->canSubmit;
    return WebGUI::Asset::EMSSubmission->www_editSubmission($self,shift);
}

#-------------------------------------------------------------------

=head2  www_editSubmissionSave

validate and create a new submission

=cut

sub www_editSubmissionSave {
        my $self = shift;
        return $self->session->privilege->insufficient() unless $self->canSubmit;
        my $formParams = WebGUI::Asset::EMSSubmission->processForm($self);
        if( $formParams->{_isValid} ) {
            delete $formParams->{_isValid};
            $self->addSubmission($formParams);
            return $self->getParent->www_viewSubmissionQueue;
        } else {
            return $self->www_editSubmission($formParams);
        }
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
    my $session;
    if( $this eq __PACKAGE__ ) {
	my $parent = shift;
	$session = $parent->session;
	$form = $session->form;
    } elsif( ref $this eq __PACKAGE__ ) {
	$session = $this->session;
	$form = $session->form;
    } else {
        return {_isValid => 0, errors => [ { text => 'invalid function call' } ] };
    }
    my $params = {_isValid=>1};
    for my $fieldName ( qw/assetId title menuTitle url description canSubmitGroupId daysBeforeCleanup
		       deleteCreatedItems submissionDeadline pastDeadlineMessage/ ) {
	$params->{$fieldName} = $form->get($fieldName);
    }
    my @fieldNames = split( ' ', $form->get('fieldNames') );
    $params->{formDescription} = { map { $_ => $form->get($_ . '_yesNo') } ( @fieldNames ) };
    $params->{formDescription}{submissionStatus} = 0;
    $params->{formDescription}{_fieldList} = [ map { $params->{formDescription}{$_} ? $_ : () } ( @fieldNames ) ];
    if( scalar( @{$params->{formDescription}{_fieldList}} ) == 0 ) {
	$params->{_isValid} = 0;
        my $i18n       = WebGUI::International->new( $session, "Asset_EMSSubmissionForm" );
	push @{$params->{errors}}, {text => $i18n->get('turn on one field') };
    }
    return $params;
}

#-------------------------------------------------------------------

=head2 update ( )

We overload the update method from WebGUI::Asset in order to handle file system privileges.

=cut

sub update {
    my $self = shift;
    my $properties = shift;
    if( ref $properties->{formDescription} eq 'HASH' ) {
        $properties->{formDescription} = JSON->new->encode($properties->{formDescription});
    }
    $self->SUPER::update({%$properties, isHidden => 1});
}

1;

#vim:ft=perl
