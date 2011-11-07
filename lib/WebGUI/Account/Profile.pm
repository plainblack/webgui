package WebGUI::Account::Profile;

use strict;

use WebGUI::Exception;
use WebGUI::International;
use WebGUI::Pluggable;
use WebGUI::ProfileCategory;
use WebGUI::ProfileField;
use WebGUI::Shop::AddressBook;
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

=head2 appendCategoryVars ( var, category [,fields, errors] )

Appends cateogry variables to the hash ref passed in

=head3 var

The hash reference to append template variables to

=head3 category

WebGUI::ProfileCategory object to append variables for

=head3 fields

Optional array ref of fields in this category

=head3 errors

Optional array ref of errors to attach to the category loop

=cut

sub appendCategoryVars {
    my $self     = shift;
    my $var      = shift || {};
    my $category = shift;
    my $fields   = shift;
    my $errors   = shift;
    my $selected = $self->store->{selected} || $self->session->form->get("selected");
    
    my $categoryId         = $category->getId;
    my $categoryLabel      = $category->getLabel;
    my $shortCategoryLabel = $category->getShortLabel;
    my $isActive           = $categoryId eq $selected;

    my $index  = scalar(@{$var->{'profile_category_loop'}}) + 1;

    push(@{ $var->{'profile_category_loop'} }, {
        'profile_category_id'              => $categoryId,
        'profile_category_isActive'        => $isActive,
        'profile_category_is_'.$categoryId => "true",  #Test so users can tell what category they are at in the loop
        'profile_category_label'           => $categoryLabel,
        'profile_category_shortLabel'      => $shortCategoryLabel,
        'profile_category_index'           => $index,
        'profile_fields_loop'              => $fields,
        'profile_errors'                   => $errors,
    });

    $var->{'profile_category_'.$categoryId."_isActive"  } = $isActive; 
    $var->{'profile_category_'.$categoryId."_label"     } = $categoryLabel;
    $var->{'profile_category_'.$categoryId."_shortLabel"} = $shortCategoryLabel;
    $var->{'profile_category_'.$categoryId."_index"     } = $index;
    $var->{'profile_category_'.$categoryId."_fields"    } = $fields;

    $var->{'can_edit_profile'  } = $self->uid eq $self->session->user->userId;

    #Update the isActive flag to determine the default active tab
    $self->store->{hasActiveTab} = ($self->store->{hasActiveTab} || $isActive);

    #return $index;
}

#-------------------------------------------------------------------

=head2 appendCommonVars ( var )

Appends common template variables that all profile templates use

=head3 var

The hash reference to append template variables to

=cut

sub appendCommonVars {
    my $self          = shift;
    my $var           = shift;
    my $session       = $self->session;
    my $user          = $self->getUser;
    my $pageUrl       = $session->url->page;

    $self->SUPER::appendCommonVars($var);

    $var->{'edit_profile_url'     } = $self->getUrl("module=profile;do=edit");
    $var->{'invitations_enabled'  } = $user->get('ableToBeFriend');
    $var->{'profile_category_loop'} = [];

    #Append the categories
    my $categories = WebGUI::ProfileCategory->getCategories($session, { editable=>1 } );
    map { $self->appendCategoryVars($var,$_) } @ { $categories };
    unless ($self->store->{hasActiveTab}) {
        $var->{'profile_category_loop'}->[0]->{'profile_category_isActive'} = 1;
    }    

    #Append the form submit if it's in edit mode
    if($self->method eq "edit" || $self->uid eq "") {
        $var->{'is_edit'      } = "true";
        $var->{'form_header'  } = WebGUI::Form::formHeader($session,{
            action => $self->getUrl("module=profile;do=editSave")
        });
        $var->{'form_footer'  } = WebGUI::Form::formFooter($session);
    }
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
    my $f       = WebGUI::FormBuilder->new($session);

	$f->addField( "template",
		name      => "profileStyleTemplateId",
		value     => $self->getStyleTemplateId,
		namespace => "style",
		label     => $i18n->get("profile style template label"),
        hoverHelp => $i18n->get("profile style template hoverHelp")
	);
	$f->addField( "template",
		name      => "profileLayoutTemplateId",
		value     => $self->getLayoutTemplateId,
		namespace => "Account/Layout",
		label     => $i18n->get("profile layout template label"),
        hoverHelp => $i18n->get("profile layout template hoverHelp")
	);
	$f->addField( "template",
        name      => "profileEditTemplateId",
        value     => $self->getEditTemplateId,
        namespace => "Account/Profile/Edit",
        label     => $i18n->get("profile edit template label"),
        hoverHelp => $i18n->get("profile edit template hoverHelp")
	);
    $f->addField( "template",
        name      => "profileViewTemplateId",
        value     => $self->getViewTemplateId,
        namespace => "Account/Profile/View",
        label     => $i18n->get("profile view template label"),
        hoverHelp => $i18n->get("profile view template hoverHelp")
	);
    $f->addField( "template",
        name      => "profileErrorTemplateId",
        value     => $self->getErrorTemplateId,
        namespace => "Account/Profile/Error",
        label     => $i18n->get("profile error template label"),
        hoverHelp => $i18n->get("profile error template hoverHelp")
	);


    return $f;
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
    $setting->set("profileViewTemplateId", $form->process("profileViewTemplateId","template"));
    $setting->set("profileErrorTemplateId",$form->process("profileErrorTemplateId","template"));

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

    return $errorStyle if $field->getId ~~ $fieldErrors;
    return "" unless ($field->isRequired);
    return $requiredStyle unless($self->session->user->get($field->getId) || $fieldValue);
    return $requiredStyleOff;
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

=head2 getErrorTemplateId ( )

This method returns the template ID used to display the error page.

=cut

sub getErrorTemplateId {
    my $self = shift;
    return $self->session->setting->get("profileErrorTemplateId") || "MBmWlA_YEA2I6D29OMGtRg";
}


#-------------------------------------------------------------------

=head2 getLayoutTemplateId ( )

This method returns the template ID for the account layout.

=cut

sub getLayoutTemplateId {
    my $self    = shift;
    return $self->session->setting->get("profileLayoutTemplateId") || "FJbUTvZ2nUTn65LpW6gjsA";
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

=head2 www_edit ( )

The edit page for the user's profile.

=cut

sub www_edit {
    my $self        = shift;
    my $errors      = shift || {};
    my $session     = $self->session;
    my $user        = $session->user;
    my $var         = {};

    #Handle errors
    my @errorFields          = ();
    $var->{'profile_errors'} = [];

    if( scalar(keys %{$errors}) ) {
        #Warnings and errors are the same here - set the fields so we can tell which fields errored
        @errorFields = (@{$errors->{errorFields}},@{$errors->{warningFields}});
        #Build the error message loop
        map {
            push( @{$var->{'profile_errors'}},{ error_message => $_ })
        }  @{$errors->{errors}};
    }

    my $count = 0;

    #Set the active flag to the default.  We'll know more later 
    $self->store->{hasActiveTab} = 0;    
    
    #Initialize the category template loop which gets filled inside the loop
    $var->{'profile_category_loop'}  = [];

    #Cache the privacy settings
    my $privacySettingsHash = WebGUI::ProfileField->getPrivacyOptions($session);
    #Get the editable categories
    my $categories = WebGUI::ProfileCategory->getCategories($session, { editable => 1 } );
	foreach my $category (@{ $categories } ) {
        my @fields = ();
        foreach my $field (@{ $category->getFields( { editable => 1 } ) }) {
            my $fieldId             = $field->getId;
            my $fieldLabel          = $field->getLabel;
            my $fieldForm           = $field->formField({ extras=>$self->getExtrasStyle($field,\@errorFields,$user->get($fieldId)) });
            my $fieldRequired       = $field->isRequired;
            my $fieldExtras         = $field->getExtras;
            my $fieldViewable       = $field->isViewable;
            my $rawPrivacySetting   = $user->getProfileFieldPrivacySetting($fieldId);
            my $fieldPrivacySetting = $privacySettingsHash->{$rawPrivacySetting};
            
            my $fieldPrivacy = WebGUI::Form::selectBox($session,{
                name    => "privacy_$fieldId",
                options => $privacySettingsHash,
                value   => $rawPrivacySetting,
                extras  => (!$fieldViewable) ? " disabled" : ""
            });

            #Create a seperate template var for each field
            my $fieldBase = 'profile_field_'.$fieldId;
            $var->{$fieldBase.'_form'                           } = $fieldForm;
            $var->{$fieldBase.'_label'                          } = $fieldLabel;
            $var->{$fieldBase.'_required'                       } = $fieldRequired;
            $var->{$fieldBase.'_extras'                         } = $fieldExtras;
            $var->{$fieldBase.'_privacy_form'                   } = $fieldPrivacy;
            $var->{$fieldBase.'_field_viewable'                 } = $fieldViewable;
            $var->{$fieldBase.'_privacy_setting'                } = $fieldPrivacySetting;
            $var->{$fieldBase.'_privacy_is_'.$rawPrivacySetting } = $rawPrivacySetting;
            
            push(@fields, {
                'profile_field_id'                             => $fieldId,
				'profile_field_form'                           => $fieldForm,
				'profile_field_label'                          => $fieldLabel,
				'profile_field_required'                       => $fieldRequired,
                'profile_field_extras'                         => $fieldExtras,
                'profile_field_viewable'                       => $fieldViewable,
                'profile_field_privacy_form'                   => $fieldPrivacy,
                'profile_field_privacy_setting'                => $fieldPrivacySetting,
                'profile_field_privacy_is_'.$rawPrivacySetting => $rawPrivacySetting,
			});
        }

        #Append the category variables
        $self->appendCategoryVars($var,$category,\@fields,$var->{'profile_errors'});
    }
 
    #If not category is selected, set the first category as the active one
    unless ($self->store->{hasActiveTab}) {
        $var->{'profile_category_loop'}->[0]->{'profile_category_isActive'} = 1;
    }

    #Call the superclass common vars method cause we don't need to build the categories again
    $self->SUPER::appendCommonVars($var);

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
    my $retHash    = $session->user->validateProfileDataFromForm($fields);
	push (@{$retHash->{errors}},@{$retHash->{warnings}});

    unless(scalar(@{$retHash->{errors}})) {
        my $profile  = $retHash->{profile};

        my $privacy  = {};
        $session->user->update($profile);

        my $address          = {};
        my $address_mappings = WebGUI::Shop::AddressBook->getProfileAddressMappings;
        foreach my $fieldName (keys %{$profile}) {
            #set the shop address fields
            my $address_key          = $address_mappings->{$fieldName};
            $address->{$address_key} = $profile->{ $fieldName } if ($address_key);

            #set the privacy settings
            my $privacySetting     = $session->form->get("privacy_".$fieldName);
            next unless $privacySetting;
            $privacy->{$fieldName} = $privacySetting;
        }

        $session->user->setProfileFieldPrivacySetting($privacy);

        #Update or create and update the shop address
        if ( keys %$address ) {
            $address->{'isProfile'        } = 1;

            #Get the address book for the user (one is created if it does not exist)
            my $addressBook     = WebGUI::Shop::AddressBook->newByUserId($session,$self->uid);
            my $profileAddress = eval { $addressBook->getProfileAddress() };

            my $e;
            if($e = WebGUI::Error->caught('WebGUI::Error::ObjectNotFound')) {
                #Get home address only mappings to avoid creating addresses with just firstName, lastName, email
                my %home_address_map = %{$address_mappings};
                delete $home_address_map{qw/firstName lastName email/};
                #Add the profile address for the user if there are homeAddress fields
                if( grep { $address->{$_} } values %home_address_map ) {
                    $address->{label} = "Profile Address";
                    my $new_address = $addressBook->addAddress($address);
                    #Set this as the default address if one doesn't already exist
                    my $defaultAddress = eval{ $addressBook->getDefaultAddress };
                    if(WebGUI::Error->caught('WebGUI::Error::ObjectNotFound')) {
                        $addressBook->update( {
                            defaultAddressId => $new_address->getId
                        } );
                    }
                }
            }
            elsif ($e = WebGUI::Error->caught) {
                #Bad stuff happened - log an error but don't fail since this isn't a vital function
                $session->log->error(
                    q{Could not update Shop Profile Address for user }
                        .$self->username.q{ : }.$e->error
                );
            }
            else {
                #Update the profile address for the user
                $profileAddress->update($address);
            }
        }
    }

    #Store the category the error occurred in the object for reference
    $self->store->{selected} = $retHash->{errorCategory};

    return $self->www_edit($retHash);
}

#-------------------------------------------------------------------

=head2 www_view ( )

The display page of the .

=cut

sub www_view {
    my $self     = shift;
    my $session  = $self->session;
    my $var      = {};
    my $uid      = $self->uid;
    my $selected = $session->form->get("selected"); #Allow users to template tabs or other category dividers

    my $active      = 0; #Whether or not a category is selected
    my $counter     = 1; #Count the number of categories being displayed

    #Ensure uid is passed in if they want to view a profile.  This controls the tab state.
    return $self->www_edit unless ($uid);

    my $user     = WebGUI::User->new($session,$uid);

    $self->appendCommonVars($var);

    my $privacySetting = $user->get('publicProfile') || 'none';
    $var->{"profile_privacy_$privacySetting"} = "true";

    $var->{'acceptsPrivateMessages'} 
        = $user->acceptsPrivateMessages($session->user->userId);

    $var->{'acceptsFriendsRequests'} 
        = $user->acceptsFriendsRequests($session->user);

    #Check user privileges
    unless ($user->profileIsViewable($session->user)) {
        my $i18n = WebGUI::International->new($session,'Account_Profile');
        $var->{'notViewable'}   = 1;
        $var->{'error_message'} = $i18n->get("profile not public error");
        return $self->processTemplate($var,$self->getViewTemplateId);
    }

    #Cache the privacy settings
    my $privacySettingsHash = WebGUI::ProfileField->getPrivacyOptions($session);
    $var->{'profile_category_loop' } = [];
	foreach my $category (@{WebGUI::ProfileCategory->getCategories($session,{ visible => 1})}) {
        my @fields = ();
        foreach my $field (@{$category->getFields({ visible => 1 })}) {
            next unless ($user->canViewField($field->getId,$session->user));
            my $rawPrivacySetting  = $user->getProfileFieldPrivacySetting($field->getId);
            my $privacySetting     = $privacySettingsHash->{$rawPrivacySetting};
            my $fieldId            = $field->getId;
            my $fieldLabel         = $field->getLabel;
            my $fieldValue         = $field->formField(undef,2,$user);
            my $fieldRaw           = $user->get($fieldId);;
            #Create a seperate template var for each field
            my $fieldBase = 'profile_field_'.$fieldId;
            $var->{$fieldBase.'_label'                          } = $fieldLabel;
            $var->{$fieldBase.'_value'                          } = $fieldValue;
            $var->{$fieldBase.'_raw'                            } = $fieldRaw;
            $var->{$fieldBase.'_privacySetting'                 } = $privacySetting;
            $var->{$fieldBase.'_privacy_is_'.$rawPrivacySetting } = "true";
            push(@fields, {
                'profile_field_id'                             => $fieldId,
                'profile_field_is_'.$fieldId                   => "true",
				'profile_field_label'                          => $fieldLabel,
                'profile_field_value'                          => $fieldValue,
                'profile_field_raw'                            => $fieldRaw,
                'profile_field_privacySetting'                 => $privacySetting,
                'profile_field_privacy_is_'.$rawPrivacySetting => "true",
			});
        }
        #Don't bother displaying the category if there's nothing in it.
        next unless (scalar(@fields));
        #Append the category variables
        $self->appendCategoryVars($var,$category,\@fields);
    }

    #If not category is selected, set the first category as the active one
    unless ($self->store->{hasActiveTab}) {
        $var->{'profile_category_loop'}->[0]->{'profile_category_isActive'} = 1;
    }

    return $self->processTemplate($var,$self->getViewTemplateId);
}

1;
