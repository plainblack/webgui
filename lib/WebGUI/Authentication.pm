package WebGUI::Authentication;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com			info@plainblack.com
#-------------------------------------------------------------------

use strict qw(vars subs);
use WebGUI::ErrorHandler;
use WebGUI::Session;
use WebGUI::SQL;


#-------------------------------------------------------------------
sub _execute {
	my ($authMethod, $function, $params) = @_;
        my $cmd = "WebGUI::Authentication::".$authMethod."::".$function;
        my $result = eval {&$cmd($params)};
        WebGUI::ErrorHandler::fatalError("Missing method in Authentication module: $authMethod. ".$@) if($@);
	return $result;
}

#-------------------------------------------------------------------

=head adminForm ( userId, authMethod )

 Returns the admin form for the specified authentication method.

=item userId
 
 This user's id.

=item authMethod

 Specify the authentication method.

=cut

sub adminForm {
        my $userId = shift;
        my $authMethod = shift;
        return _execute($authMethod,"adminForm",$userId);
}

#-------------------------------------------------------------------

=head adminFormSave ( userId, authMethod )

 Saves the specified user's authentication information to the database.

=item userId

 The user id to save the information for.

=item authMethod

 Specify the authentication method.

=cut

sub adminFormSave {
        my $userId = shift;
        my $authMethod = shift;
        return _execute($authMethod,"adminFormSave",$userId);
}

#-------------------------------------------------------------------

=head adminFormValidate ( authMethod )

 Returns an error string if there are any problems with the form data.

=item authMethod

 Specify the authentication method.

=cut

sub adminFormValidate {
        my $authMethod = shift;
        return _execute($authMethod,"adminFormValidate");
}

#-------------------------------------------------------------------

=head authenticate ( userId, identifier, authMethod )

 Check to see that the user supplied information is correct. Returns
 "1" if successful otherwise it returns an error message.

=item userId

 The user to authenticate.

=item identifier

 The password, pass phrase, PIN, or other unique identifier to
 verify this user.

=item authMethod

 The type of authentication to use to authenticate this user.

=cut

sub authenticate {
        my ($userId, $identifier, $authMethod) = @_;
        return _execute($authMethod,"authenticate",[$userId,$identifier]);
}

#-------------------------------------------------------------------

=head deleteParams ( userId )

 Removes the specified user's authentication parameters from the
 database for all authentication methods. This is primarily useful
 when deleting the user's account.

=item userId

 The user id for the user to have the parameters deleted.

=cut

sub deleteParams {
        my $uid = shift;
        if ($uid) {
                WebGUI::SQL->write("delete from authentication where userId=$uid");
        }
}


#-------------------------------------------------------------------

=head getParams (  userId  [ , authMethod ] )

 Returns an error string if there are any problems with the form data.

=item userId

 Specify a user id.

=item authMethod

 Optionally specify the authentication method. Defaults to the system-wide
 authentication method.

=cut

sub getParams {
	my $uid = shift;
	my $authMethod = shift;
	$authMethod = $session{setting}{authMethod} if ($authMethod eq "");
	return WebGUI::SQL->buildHashRef("select fieldName, fieldData from authentication 
		where userId=$uid and authMethod='$authMethod'");
}


#-------------------------------------------------------------------

=head optionsLabel ( authMethod )

 Returns a label that can be displayed to describe the settings for
 this auth method.

=item authMethod

 The authentication method.

=cut

sub optionsLabel {
        my $authMethod = shift;
        return _execute($authMethod,"optionsLabel");
}


#-------------------------------------------------------------------

=head registrationForm ( )

 Returns the user registration form for the default auth method.

=cut

sub registrationForm {
        my $authMethod = $session{setting}{authMethod};
        return _execute($authMethod,"registrationForm");
}

#-------------------------------------------------------------------

=head registrationFormSave ( userId )

 Creates the appropriate values in the database for this user based
 upon their registration information.

=item userId

 The user id to store with the registration data.

=cut

sub registrationFormSave {
        my $authMethod = $session{setting}{authMethod};
        _execute($authMethod,"registrationFormSave",$_[0]);
}

#-------------------------------------------------------------------

=head registrationFormValidate ( )

 Returns an error string if there are any problems with the form data.

=cut

sub registrationFormValidate {
        my $authMethod = $session{setting}{authMethod};
        return _execute($authMethod,"registrationFormValidate");
}


#-------------------------------------------------------------------

=head settingsForm ( authMethod )

 Returns a form for the WebGUI settings area.

=item authMethod

 The authentication method to display the form for.

=cut

sub settingsForm {
        my $authMethod = shift;
        return _execute($authMethod,"settingsForm");
}


#-------------------------------------------------------------------

=head saveParams ( userId, authMethod, data )

 Saves the user's authentication parameters to the database.

=item userId

 Specify a user id.

=item authMethod

 Specify the authentication method to save these paramaters under.

=item data

 A hash reference containing parameter names and values to be saved.

=cut

sub saveParams {
	my ($uid, $authMethod, $data) = @_;
	foreach (keys %{$data}) {
               	WebGUI::SQL->write("delete from authentication where 
			userId=$uid and authMethod=".quote($authMethod)." and fieldName=".quote($_));
               	WebGUI::SQL->write("insert into authentication (userId,authMethod,fieldData,fieldName) 
			values ($uid,".quote($authMethod).",".quote($data->{$_}).",".quote($_).")");
        }
}


#-------------------------------------------------------------------

=head userForm ( )

 Returns the user authentication data form.

=cut

sub userForm {
        my $authMethod = $session{user}{authMethod} || $session{setting}{authMethod};
        return _execute($authMethod,"userForm");
}


#-------------------------------------------------------------------

=head userFormSave ( )

 Saves user form data to the database.

=cut 

sub userFormSave {
        my $authMethod = $session{user}{authMethod} || $session{setting}{authMethod};
        _execute($authMethod,"userFormSave");
}

#-------------------------------------------------------------------

=head userFormValidate ( )

 Returns an error string if there are any problems with the form data.

=cut

sub userFormValidate {
	my $authMethod = $session{user}{authMethod} || $session{setting}{authMethod};
	return _execute($authMethod,"userFormValidate");
}



1;


