package WebGUI::Operation::Profile;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict qw(vars subs);
use WebGUI::Content::Account;
use WebGUI::International;
use WebGUI::ProfileField;
use WebGUI::User;

=head1 NAME

Package WebGUI::Operation::Profile

=head1 DESCRIPTION

Operational handler for viewing, editing and validating user profile data.

=head1 METHODS

These methods are available from this package:

=cut

#-------------------------------------------------------------------

=head2 getRequiredProfileFields ( session )

Returns an array of hashes for required profile fields.  This array is ready
to be used as template variables in the WebGUI template system.

DEPRECATED - This method is deprecated, and should not be used in new code.  Use
the getRequiredFields method from WebGUI::ProfileField and specify the
translation to template variables directly instead.

NOTE: You should use the getRequiredFields method in WebGUI::ProfileField instead.

=head3 session

The current WebGUI session object.

=cut

# Builds Extra form requirements for anonymous registration.
sub getRequiredProfileFields {
	my $session = shift;
	my @array;
	foreach my $field (@{WebGUI::ProfileField->getRequiredFields($session)}) {
		push(@array, {
			'profile.formElement' => $field->formField,
			'profile.formElement.label' => $field->getLabel
			});
	}	
	return \@array;
}

#-------------------------------------------------------------------

=head2 isDuplicateEmail ( email )

Checks the value of the email address passed in to see if it is
duplicated in the system.  Returns true of false.  Will return false
if the email address passed in is same as the email address of the
current user.

DEPRECATED - This method is deprecated, and should not be used in new code.  Use
the isDuplicate method from WebGUI::ProfileField instead

=head3 email

email address to check for duplication

=cut

sub isDuplicateEmail {
    my $session     = shift;
    my $email       = shift;

    my $field = WebGUI::ProfileField->new($session,'email');
    return $field->isDuplicate($email);
}

#-------------------------------------------------------------------

=head2 saveProfileFields ( session, user, profile )

Saves profile data to a user's profile.  Does not validate any of the data.

DEPRECATED - This method is deprecated, and should not be used in new code.  Use
the update method in WebGUI::User

=head3 session

WebGUI session object

=head3 user

User object.  Profile data will be placed in this user's profile.

=head3 profile

Hash ref of profile data to save.

=cut

sub saveProfileFields {
	my $session = shift;
	my $u       = shift;
	my $profile = shift;
    $u->update($profile);
}

#-------------------------------------------------------------------

=head2 validateProfileData ( session )

Validates profile data from the session form variables.  Returns processed data, warnings
and errors.

DEPRECATED - This method is deprecated, and should not be used in new code.  Use
the validateProfileDataFromForm method from WebGUI::User instead

There are two levels of validation:

=over 4

=item 1

If the profile field is required, and the form field is blank, returns an error.

=item 2

If the profile field label is "email", then checks for a duplicate email and returns a
warning if it is a duplicate.

=back

=cut

sub validateProfileData {
	my $session   = shift;
	my $opts      = shift || {};
    my $regOnly   = $opts->{regOnly};
    
    my $fields    = $regOnly ? WebGUI::ProfileField->getRegistrationFields($session)
                          : WebGUI::ProfileField->getEditableFields($session);

    my $retHash   = $session->user->validateProfileDataFromForm($fields);

    my $format    = "<li>%s</li>";
    my $warningMessage  = "";
    my $errorMessage    = "";

    for my $warning ( @{ $retHash->{warnings} } ) {
        $warningMessage .= sprintf $format, $warning;
    }
    for my $error ( @{ $retHash->{errors} } ) {
        $errorMessage .= sprintf $format, $error;
    }

    return ($retHash->{profile}, $errorMessage, $warningMessage);
}

#-------------------------------------------------------------------

=head2 www_editProfile ( session )

DEPRECATED - This method is deprecated, and should not be used in new code.
Use WebGUI::Account::Profile::www_edit

=head3 session

A reference to the current session.

=cut

sub www_editProfile {
	my $session  = shift;
    return $session->privilege->insufficient if $session->user->isVisitor;
    my $instance = WebGUI::Content::Account->createInstance($session,"profile");
    return $instance->displayContent($instance->callMethod("edit"));
}


#-------------------------------------------------------------------

=head2 www_viewProfile ( session )

DEPRECATED:  This method is deprecated, and should not be used in new code.
Use WebGUI::Account::Profile::www_view

=head3 session

A reference to the current session.

=cut

sub www_viewProfile {
    my $session  = shift;
    my $uid      = $session->form->process("uid");
    my $instance = WebGUI::Content::Account->createInstance($session,"profile");
    return $instance->displayContent($instance->callMethod("view",[],$uid));
}


1;
