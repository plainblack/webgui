package WebGUI::Authentication;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2002 Plain Black LLC.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut



use strict qw(vars subs);
use WebGUI::ErrorHandler;
use WebGUI::Session;
use WebGUI::SQL;


=head1 NAME

Package WebGUI::Authentication

=head1 DESCRIPTION

This package is used to access WebGUI's pluggable authentication system.

=head1 SYNOPSIS

 use WebGUI::Authentication;

 $html = WebGUI::Authentication::adminForm($userId,$authMethod);
 WebGUI::Authentication::adminFormSave($userId,$authMethod);
 $error = WebGUI::Authentication::adminFormValidate($authMethod);

 $result = WebGUI::Authentication::authenticate($userId,$identifier,$authMethod);

 WebGUI::Authentication::deleteParams($userId);
 $params = WebGUI::Authentication::getParams($userId,$authMethod);
 WebGUI::Authentication::saveParams($userId,$authMethod,\%data);

 $label = WebGUI::Authentication::optionsLabel($authMethod);

 $html = WebGUI::Authentication::settingsForm($authMethod);

 $html = WebGUI::Authentication::registrationForm();
 WebGUI::Authentication::registrationFormSave($userId);
 $error = WebGUI::Authentication::registrationFormValidate();

 $html = WebGUI::Authentication::userForm();
 WebGUI::Authentication::userFormSave();
 $error = WebGUI::Authentication::userFormValidate();

=head1 METHODS

These functions are available from this package:

=cut




#-------------------------------------------------------------------
sub _execute {
	my ($authMethod, $function, $params) = @_;
        my $cmd = "WebGUI::Authentication::".$authMethod."::".$function;
        return eval {&$cmd($params)} unless ($@);
        WebGUI::ErrorHandler::fatalError("Missing method in Authentication module: $authMethod. ".$@);
}

#-------------------------------------------------------------------

=head2 adminForm ( userId, authMethod )

Returns the admin form for the specified authentication method.

=over

=item userId
 
This user's id.

=item authMethod

Specify the authentication method.

=back

=cut

sub adminForm {
        my $userId = shift;
        my $authMethod = shift;
        return _execute($authMethod,"adminForm",$userId);
}

#-------------------------------------------------------------------

=head2 adminFormSave ( userId, authMethod )

Saves the specified user's authentication information to the database.

=over

=item userId

The user id to save the information for.

=item authMethod

Specify the authentication method.

=back

=cut

sub adminFormSave {
        my $userId = shift;
        my $authMethod = shift;
        return _execute($authMethod,"adminFormSave",$userId);
}

#-------------------------------------------------------------------

=head2 adminFormValidate ( authMethod )

Returns an error string if there are any problems with the form data.

=over

=item authMethod

Specify the authentication method.

=back

=cut

sub adminFormValidate {
        my $authMethod = shift;
        return _execute($authMethod,"adminFormValidate");
}

#-------------------------------------------------------------------

=head2 authenticate ( userId, identifier, authMethod )

Check to see that the user supplied information is correct. Returns "1" if successful otherwise it returns an error message.

=over

=item userId

The user to authenticate.

=item identifier

The password, pass phrase, PIN, or other unique identifier to verify this user.

=item authMethod

The type of authentication to use to authenticate this user.

=back

=cut

sub authenticate {
        my ($userId, $identifier, $authMethod) = @_;
        return _execute($authMethod,"authenticate",[$userId,$identifier]);
}

#-------------------------------------------------------------------

=head2 deleteParams ( userId )

Removes the specified user's authentication parameters from the database for all authentication methods. This is primarily useful when deleting the user's account.

=over

=item userId

The user id for the user to have the parameters deleted.

=back

=cut

sub deleteParams {
        my $uid = shift;
        if ($uid) {
                WebGUI::SQL->write("delete from authentication where userId=$uid");
        }
}


#-------------------------------------------------------------------

=head2 getParams (  userId  [ , authMethod ] )

Returns a hash reference with the user's authentication information.

=over

=item userId

Specify a user id.

=item authMethod

Optionally specify the authentication method. Defaults to the system-wide authentication method.

=back

=cut

sub getParams {
	my $uid = shift;
	my $authMethod = shift;
	$authMethod = $session{setting}{authMethod} if ($authMethod eq "");
	return WebGUI::SQL->buildHashRef("select fieldName, fieldData from authentication 
		where userId=$uid and authMethod='$authMethod'");
}


#-------------------------------------------------------------------

=head2 optionsLabel ( authMethod )

Returns a label that can be displayed to describe the settings for this auth method.

=over

=item authMethod

The authentication method.

=back

=cut

sub optionsLabel {
        my $authMethod = shift;
        return _execute($authMethod,"optionsLabel");
}


#-------------------------------------------------------------------

=head2 registrationForm ( )

Returns the user registration form for the default auth method.

=cut

sub registrationForm {
        my $authMethod = $session{setting}{authMethod};
        return _execute($authMethod,"registrationForm");
}

#-------------------------------------------------------------------

=head2 registrationFormSave ( userId )

Creates the appropriate values in the database for this user based upon their registration information.

=over

=item userId

The user id to store with the registration data.

=back

=cut

sub registrationFormSave {
        my $authMethod = $session{setting}{authMethod};
        _execute($authMethod,"registrationFormSave",$_[0]);
}

#-------------------------------------------------------------------

=head2 registrationFormValidate ( )

Returns the WebGUI username to user for this user, and returns an error string if there are any problems with the form data. 

=cut

sub registrationFormValidate {
        my $authMethod = $session{setting}{authMethod};
        return _execute($authMethod,"registrationFormValidate");
}


#-------------------------------------------------------------------

=head2 settingsForm ( authMethod )

Returns a form for the WebGUI settings area.

=over

=item authMethod

The authentication method to display the form for.

=back

=cut

sub settingsForm {
        my $authMethod = shift;
        return _execute($authMethod,"settingsForm");
}


#-------------------------------------------------------------------

=head2 saveParams ( userId, authMethod, data )

Saves the user's authentication parameters to the database.

=over

=item userId

Specify a user id.

=item authMethod

Specify the authentication method to save these paramaters under.

=item data

A hash reference containing parameter names and values to be saved.

=back

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

=head2 userForm ( )

Returns the user authentication data form.

=cut

sub userForm {
        my $authMethod = $session{user}{authMethod} || $session{setting}{authMethod};
        return _execute($authMethod,"userForm");
}


#-------------------------------------------------------------------

=head2 userFormSave ( )

Saves user form data to the database.

=cut 

sub userFormSave {
        my $authMethod = $session{user}{authMethod} || $session{setting}{authMethod};
        _execute($authMethod,"userFormSave");
}

#-------------------------------------------------------------------

=head2 userFormValidate ( )

Returns the WebGUI username to use for this user, and returns an error string if there are any problems with the form data.

=cut

sub userFormValidate {
	my $authMethod = $session{user}{authMethod} || $session{setting}{authMethod};
	return _execute($authMethod,"userFormValidate");
}



1;


