package WebGUI::Account::Profile;

use strict;

use WebGUI::Exception;
use WebGUI::International;
use WebGUI::Pluggable;
use WebGUI::ProfileCategory;
use WebGUI::ProfileField;
use WebGUI::Utility;
use base qw/WebGUI::Account/;

=head1 NAME

Package WebGUI::Account::Profile

=head1 DESCRIPTION

This is the class which is used to display a users's profile information

=head1 SYNOPSIS

 use WebGUI::Account::Profile;

=head1 METHODS

These subroutines are available from this package:

=cut

#-------------------------------------------------------------------

=head2 appendCommonVars ( var )

    Appends common template variables that all inbox templates use
    
=head3 var

    The hash reference to append template variables to

=cut

sub appendCommonVars {
    my $self    = shift;
    my $var     = shift;
    my $session = $self->session;
    my $user    = $session->user;
    my $pageUrl = $session->url->page;

    $var->{'user_full_name'    } = $user->getWholeName;
    $var->{'user_member_since' } = $user->dateCreated;
    $var->{'view_profile_url'  } = $user->getProfileUrl($pageUrl);
    $var->{'edit_profile_url'  } = $self->getUrl("module=profile;do=edit");
    $var->{'back_url'          } = $session->env->get("HTTP_REFERER") || $var->{'view_profile_url'}
}

#-------------------------------------------------------------------

=head2 editSettingsForm ( )

  Creates form elements for user settings page custom to this account module

=cut

sub editSettingsForm {
    my $self    = shift;
    my $session = $self->session;
    my $setting = $session->setting;
    my $i18n    = WebGUI::International->new($session,'Account_Profile');
    my $f       = WebGUI::HTMLForm->new($session);

	$f->template(
		name      => "profileStyleTemplateId",
		value     => $self->getStyleTemplateId,
		namespace => "style",
		label     => $i18n->get("profile style template label"),
        hoverHelp => $i18n->get("profile style template hoverHelp")
	);
	$f->template(
		name      => "profileLayoutTemplateId",
		value     => $self->getLayoutTemplateId,
		namespace => "Account/Layout",
		label     => $i18n->get("profile layout template label"),
        hoverHelp => $i18n->get("profile layout template hoverHelp")
	);
    $f->template(
		name      => "profileEditLayoutTemplateId",
		value     => $self->getEditLayoutTemplateId,
		namespace => "Account/Layout",
		label     => $i18n->get("profile edit layout template label"),
        hoverHelp => $i18n->get("profile edit layout template hoverHelp")
	);
	$f->template(
        name      => "profileEditTemplateId",
        value     => $self->getEditTemplateId,
        namespace => "Account/Profile/Edit",
        label     => $i18n->get("profile edit template label"),
        hoverHelp => $i18n->get("profile edit template hoverHelp")
	);
    $f->template(
        name      => "profileViewTemplateId",
        value     => $self->getViewTemplateId,
        namespace => "Account/Profile/View",
        label     => $i18n->get("profile view template label"),
        hoverHelp => $i18n->get("profile view template hoverHelp")
	);

    return $f->printRowsOnly;
}


#-------------------------------------------------------------------

=head2 editSettingsFormSave ( )

  Creates form elements for user settings page custom to this account module

=cut

sub editSettingsFormSave {
    my $self    = shift;
    my $session = $self->session;
    my $setting = $session->setting;
    my $form    = $session->form;

    $setting->set("profileStyleTemplateId", $form->process("profileStyleTemplateId","template"));
    $setting->set("profileLayoutTemplateId", $form->process("profileLayoutTemplateId","template"));
    $setting->set("profileDisplayLayoutTemplateId", $form->process("profileDisplayLayoutTemplateId","template"));
    $setting->set("profileEditTemplateId", $form->process("profileEditTemplateId","template"));
    $setting->set("profileViewTempalteId", $form->process("profileViewTemplateId","template"));

}

#-------------------------------------------------------------------

=head2 getExtrasStyle ( field, fieldErrors, fieldValue )

This method returns the proper field to display for required fields.

=head3 field

field to check

=head3 fieldErrors

errors returned as a result of validation (see $self->validateProfileFields)

=head3 fieldValue

Value of the field to use when returning the style

=cut

sub getExtrasStyle {
    my $self        = shift;
    my $field       = shift;
    my $fieldErrors = shift;
    my $fieldValue  = shift;

    my $requiredStyleOff = q{class="profilefield_required_off"}; 
    my $requiredStyle    = q{class="profilefield_required"};
    my $errorStyle       = q{class="profilefield_error"};     #Required Field Not Filled In and Error Returend

    return $errorStyle if(WebGUI::Utility::isIn($field->getId,@{$fieldErrors}));
    return "" unless ($field->isRequired);
    return $requiredStyle unless($self->session->user->profileField($field->getId) || $fieldValue);
    return $requiredStyleOff;
}


#-------------------------------------------------------------------

=head2 getDisplayLayoutTemplateId ( )

This method returns the template ID for the account layout.

=cut

sub getEditLayoutTemplateId {
    my $self    = shift;
    return $self->session->setting->get("profileEditLayoutTemplateId") || "FJbUTvZ2nUTn65LpW6gjsA";
}

#-------------------------------------------------------------------

=head2 getEditTemplateId ( )

This method returns the template ID for the edit profile page.

=cut

sub getEditTemplateId {
    my $self = shift;
    return $self->session->setting->get("profileEditTemplateId") || "75CmQgpcCSkdsL-oawdn3Q";
}

#-------------------------------------------------------------------

=head2 getLayoutTemplateId ( )

This method returns the template ID for the account layout.

=cut

sub getLayoutTemplateId {
    my $self    = shift;
    my $session = $self->session;
    my $method  = $session->form->get("do");
    my $uid     = $session->form->get("uid");

    return $self->getEditLayoutTemplateId if($method eq "edit" || $uid eq "");
    return $session->setting->get("profileLayoutTemplateId") || $self->SUPER::getLayoutTemplateId;
}

#-------------------------------------------------------------------

=head2 getStyleTemplateId ( )

This method returns the template ID for the main style.

=cut

sub getStyleTemplateId {
    my $self = shift;
    return $self->session->setting->get("profileStyleTemplateId") || $self->SUPER::getStyleTemplateId;
}

#-------------------------------------------------------------------

=head2 getViewTemplateId ( )

This method returns the template ID for the view profile page.

=cut

sub getViewTemplateId {
    my $self = shift;
    return $self->session->setting->get("profileViewTemplateId") || "2CS-BErrjMmESOtGT90qOg";
}

#-------------------------------------------------------------------

=head2 saveProfileFields ( session, user, profile )

Saves profile data to a user's profile.  Does not validate any of the data.

=head3 session

WebGUI session object

=head3 user

User object.  Profile data will be placed in this user's profile.

=head3 profile

Hash ref of profile data to save.

=cut

sub saveProfileFields {
    my $class   = shift;
	my $session = shift;
	my $u       = shift;
	my $profile = shift;

	foreach my $fieldName (keys %{$profile}) {
		$u->profileField($fieldName,${$profile}{$fieldName});
	}
}

#-------------------------------------------------------------------

=head2 validateProfileFields ( session, fields )

Class method which validates profile data from the session form variables.  Returns an data structure which contains the following

{
    profile        => Hash reference containing all of the profile fields and their values
    errors         => Array reference of error messages to be displayed
    errorCategory  => Category in which the first error was thrown
    warnings       => Array reference of warnings to be displayed
    errorFields    => Array reference of the fieldIds that threw an error
    warningFields  => Array reference of the fieldIds that threw a warning
}

=head3 session

WebGUI session object

=head3 fields

An array reference of profile fields to validate.

=cut

sub validateProfileFields {
    my $class       = shift;
	my $session     = shift;
	my $fields      = shift;

    my $i18n        = WebGUI::International->new($session, 'Account_Profile');

    my $data        = {};
    my $errors      = [];
    my $warnings    = [];
    my $errorCat    = undef;
    my $errorFields = [];
    my $warnFields  = [];
    
	foreach my $field (@{$fields}) {
        my $fieldId       = $field->getId;
        my $fieldLabel    = $field->getLabel;
    	my $fieldValue    = $field->formProcess;
        my $isValid       = $field->isValid($fieldValue);

        $data->{$fieldId} = (ref $fieldValue eq "ARRAY") ? $fieldValue->[0] : $fieldValue;

        if(!$isValid) {
            $errorCat = $field->get("profileCategoryId") unless (defined $errorCat);
            push (@{$errors}, sprintf($i18n->get("required error"),$fieldLabel));
            push(@{$errorFields},$fieldId);
        }
        #The language field is special and must be always be valid or WebGUI will croak
        elsif($fieldId eq "language" && !(exists $i18n->getLanguages()->{$data->{$fieldId}})) {
            $errorCat = $field->get("profileCategoryId") unless (defined $errorCat);
            $session->log->warn("language $fieldValue does not exist");
            push (@{$errors}, sprintf($i18n->get("language not installed error"),$data->{$fieldId}));
            push(@{$errorFields},$fieldId);
        }
        #Duplicate emails throw warnings
        elsif($fieldId eq "email" && $field->isDuplicate($fieldValue)) {
            $errorCat = $field->get("profileCategoryId") unless (defined $errorCat);
            push (@{$warnings},$i18n->get("email already in use error"));
            push(@{$warnFields},$fieldId);
        }
    }

	return {
        profile       => $data,
        errors        => $errors,
        warnings      => $warnings,
        errorCategory => $errorCat,
        errorFields   => $errorFields,
        warningFields => $warnFields,
    };
}

#-------------------------------------------------------------------

=head2 www_edit ( )

The edit page for the user's profile.

=cut

sub www_edit {
    my $self        = shift;
    my $errors      = shift || {};
    my $session     = $self->session;
    my $user        = $session->user;
    my $selected    = $errors->{errorCategory} || $session->form->get("selected"); #Allow users to template tabs or other category dividers
    my $var         = {};
    
    my $active      = 0; #Whether or not a category is selected
    my $counter     = 1; #Count the number of categories being displayed
    my $hasErrors   = scalar(keys %{$errors});

    my @errorFields = ();
    @errorFields = (@{$errors->{errorFields}},@{$errors->{warningFields}}) if($hasErrors);

    my @categories = ();
	foreach my $category (@{WebGUI::ProfileCategory->getCategories($session)}) {
        next unless $category->isEditable;
        my @fields = ();
        foreach my $field (@{$category->getFields}) {
            next unless ($field->isEditable); 
            next if $field->getId =~ m/contentPositions/; #This protects the contentPosition fields
            my $fieldId      = $field->getId;
            my $fieldLabel   = $field->getLabel;
            my $fieldForm    = $field->formField({ extras=>$self->getExtrasStyle($field,\@errorFields,$user->profileField($fieldId)) });
            my $fieldSubtext = $field->isRequired ? "*" : undef;
            my $fieldExtras  = $field->getExtras;
            #Create a seperate template var for each field
            $var->{'profile_field_'.$fieldId.'_form'   } = $fieldForm;
            $var->{'profile_field_'.$fieldId.'_label'  } = $fieldLabel;
            $var->{'profile_field_'.$fieldId.'_subtext'} = $fieldSubtext;
            $var->{'profile_field_'.$fieldId.'_extras' } = $fieldExtras;
            
            push(@fields, {
                'profile_field_id'      => $fieldId,
				'profile_field_form'    => $fieldForm,
				'profile_field_label'   => $fieldLabel,
				'profile_field_subtext' => $field->isRequired ? "*" : undef,
                'profile_field_extras'  => $field->getExtras,
			});
        }
        my $categoryId         = $category->getId;
        my $categoryLabel      = $category->getLabel;
        my $shortCategoryLabel = $category->getShortLabel;
        my $isActive           = $categoryId eq $selected;
        my $categoryIndex      = $counter++;

        $var->{'profile_category_'.$categoryId."_isActive"  } = $isActive; 
        $var->{'profile_category_'.$categoryId."_label"     } = $categoryLabel;
        $var->{'profile_category_'.$categoryId."_shortLabel"} = $shortCategoryLabel;
        $var->{'profile_category_'.$categoryId."_fields"    } = \@fields;
        $var->{'profile_category_'.$categoryId."_index"     } = $categoryIndex;

        push(@categories, {
            'profile_category_id'              => $categoryId,
            'profile_category_isActive'        => $isActive,
            'profile_category_is_'.$categoryId => "true",  #Test so users can tell what category they are at in the loop
            'profile_category_label'           => $categoryLabel,
            'profile_category_shortLabel'      => $shortCategoryLabel,
            'profile_category_index'           => $categoryIndex,
            'profile_fields_loop'              => \@fields,
        });
        #This value will determine whether or not a valid category is active or not
        $active ||= $isActive;
    }
    
    #If not category is selected, set the first category as the active one
    $categories[0]->{profile_category_isActive} = 1 unless($active);
        
    $var->{'profile_category_loop'}  = \@categories;

    $var->{'profile_form_submit'  }  = WebGUI::Form::submit($session,{});
    $var->{'profile_form_header'  }  = WebGUI::Form::formHeader($session,{
        action => $self->getUrl("module=profile;do=editSave")
    });
	$var->{'profile_form_footer'  }  = WebGUI::Form::formFooter($session);

    $var->{'profile_errors'       } = [];    
    map{ push(@{$var->{'profile_errors'}},{ error_message => $_ }) } @{$errors->{errors}} if($hasErrors);

    $self->appendCommonVars($var);
	
    return $self->processTemplate($var,$self->getEditTemplateId);
}


#-------------------------------------------------------------------

=head2 www_editSave ( )

The page which saves the user's profile and returns them to their profile view.

=cut

sub www_editSave {
    my $self       = shift;
    my $session    = $self->session;

    my $fields     = WebGUI::ProfileField->getEditableFields($session);
    my $retHash    = $self->validateProfileFields($session,$fields);
	push (@{$retHash->{errors}},@{$retHash->{warnings}});

    unless(scalar(@{$retHash->{errors}})) {
        foreach my $fieldName (keys %{$retHash->{profile}}) {
            $session->user->profileField($fieldName,$retHash->{profile}->{$fieldName});
        }
    }

    return $self->www_edit($retHash);
}

#-------------------------------------------------------------------

=head2 www_view ( )

The display page of the .

=cut

sub www_view {
    my $self     = shift;
    my $session  = $self->session;
    my $i18n     = WebGUI::International->new($session, 'Account_Profile');
    my $var      = {};
    my $uid      = $session->form->get("uid");
    my $selected = $session->form->get("selected"); #Allow users to template tabs or other category dividers

    my $active      = 0; #Whether or not a category is selected
    my $counter     = 1; #Count the number of categories being displayed

    #Ensure uid is passed in if they want to view a profile.  This controls the tab state.
    return $self->www_edit unless ($uid);

    my $user     = WebGUI::User->new($session,$uid);    

    #Check user privileges
    #return $session->style->userStyle($vars->{displayTitle}.'. '.$i18n->get(862)) if($u->profileField("publicProfile") < 1 && ($session->user->userId ne $session->form->process("uid") || $session->user->isAdmin));
    #return $session->privilege->insufficient() if(!$session->user->isRegistered);

    if($user->isVisitor) {
        $var->{'restricted'   } = "true";
        $var->{'error_message'} = $i18n->get("visitor profile restricted");
    }

    my @categories = ();
	foreach my $category (@{WebGUI::ProfileCategory->getCategories($session)}) {
        next unless $category->isViewable;
        my @fields = ();
        foreach my $field (@{$category->getFields}) {
            next unless ($field->isViewable); 
            next if $field->getId =~ m/contentPositions/; #This protects the contentPosition fields
            my $fieldId      = $field->getId;
            my $fieldLabel   = $field->getLabel;
            my $fieldValue   = $field->formField(undef,2,$user);
            my $fieldRaw     = $user->profileField($fieldId);;
            #Create a seperate template var for each field
            $var->{'profile_field_'.$fieldId.'_label' } = $fieldLabel;
            $var->{'profile_field_'.$fieldId.'_value' } = $fieldValue;
            $var->{'profile_field_'.$fieldId.'_raw'   } = $fieldRaw;
            
            push(@fields, {
                'profile_field_id'           => $fieldId,
                'profile_field_is_'.$fieldId => "true",
				'profile_field_label'        => $fieldLabel,
                'profile_field_value'        => $fieldValue,
                'profile_field_raw'          => $fieldRaw
			});
        }
        my $categoryId         = $category->getId;
        my $categoryLabel      = $category->getLabel;
        my $shortCategoryLabel = $category->getShortLabel;
        my $isActive           = $categoryId eq $selected;
        my $categoryIndex      = $counter++;
        
        $var->{'profile_category_'.$categoryId."_isActive"  } = $isActive;
        $var->{'profile_category_'.$categoryId."_label"     } = $categoryLabel;
        $var->{'profile_category_'.$categoryId."_shortLabel"} = $shortCategoryLabel;
        $var->{'profile_category_'.$categoryId."_fields"    } = \@fields;
        $var->{'profile_category_'.$categoryId."_index"     } = $categoryIndex;

        push(@categories, {
            'profile_category_id'              => $categoryId,
            'profile_category_isActive'        => $isActive,
            'profile_category_is_'.$categoryId => "true",
            'profile_category_label'           => $categoryLabel,
            'profile_category_shortLabel'      => $shortCategoryLabel,
            'profile_category_index'           => $categoryIndex,
            'profile_fields_loop'              => \@fields,
        });
        #This value will determine whether or not a valid category is active or not
        $active ||= $isActive;
    }

    #If not category is selected, set the first category as the active one
    $categories[0]->{profile_category_isActive} = 1 unless($active);

    $var->{'profile_category_loop' } = \@categories;
    $var->{'profile_user_id'       } = $user->userId;
    $var->{'can_edit_profile'      } = $uid eq $session->user->userId;
    $var->{'acceptsPrivateMessages'} = $user->acceptsPrivateMessages($session->user->userId);
    $var->{'acceptsFriendsRequests'} = $user->acceptsFriendsRequests($session->user);

    $self->appendCommonVars($var);

    #Overwrite these
    $var->{'user_full_name'    } = $user->getWholeName;
    $var->{'user_member_since' } = $user->dateCreated;

    return $self->processTemplate($var,$self->getViewTemplateId);
}



1;
