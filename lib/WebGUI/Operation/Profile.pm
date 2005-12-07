package WebGUI::Operation::Profile;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict qw(vars subs);
use URI;
use WebGUI::Asset::Template;
use WebGUI::Operation::Auth;
use WebGUI::DateTime;
use WebGUI::ErrorHandler;
use WebGUI::FormProcessor;
use WebGUI::Form::DynamicField;
use WebGUI::Grouping;
use WebGUI::HTML;
use WebGUI::HTMLForm;
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::Mail;
use WebGUI::MessageLog;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::User;
use WebGUI::Utility;
use WebGUI::ProfileField;
use WebGUI::ProfileCategory;
use WebGUI::Operation::Shared;

#-------------------------------------------------------------------
# Builds Extra form requirements for anonymous registration. 
sub getRequiredProfileFields {
	my @array;
	foreach my $field (@{WebGUI::ProfileField->getRequiredFields}) {
		push(@array, {
			'profile.formElement' => $field->formField,
			'profile.formElement.label' => $field->getLabel
			});
	}	
	return \@array;
}

#-------------------------------------------------------------------
=head2 isDuplicateEmail ( )

 Checks the value of the email address passed in to see if it is duplicated in the system.  Returns true of false.  Will return false if the email address passed in is
 same as the email address of the current user.
 
=head3 email
   
   email address to check for duplication

=cut

sub isDuplicateEmail {
	my $email = shift;
	my ($otherEmail) = WebGUI::SQL->quickArray("select count(*) from userProfileData where fieldName='email' and fieldData = ".quote($email)." and userId <> ".quote($session{user}{userId}));
	return ($otherEmail > 0);
}

#-------------------------------------------------------------------
sub saveProfileFields {
   my $u = shift;
   my $profile = shift;
   
   foreach my $fieldName (keys %{$profile}) {
      $u->profileField($fieldName,${$profile}{$fieldName});
   }
}

#-------------------------------------------------------------------
sub validateProfileData {
	my %data = ();
	my $error = "";
	my $warning = "";
	foreach my $field (@{WebGUI::ProfileField->getEditableFields}) {
		$data{$field->getId} = $field->formProcess;
		if ($field->get("required") && !$data{$field->getId}) {
			$error .= '<li>'.$field->getLabel.' '.WebGUI::International::get(451).'</li>';
		} elsif ($field->getId eq "email" && isDuplicateEmail($data{$field->getId})) {
			$warning .= '<li>'.WebGUI::International::get(1072).'</li>';
		}
	}
	return (\%data, $error, $warning);
}

#-------------------------------------------------------------------
sub www_editProfile {
	return WebGUI::Operation::Auth::www_auth("init") if($session{user}{userId} eq '1');
	my $vars = {};
	$vars->{displayTitle} .= '<h1>'.WebGUI::International::get(338).'</h1>';
	$vars->{'profile.message'} = $_[0] if($_[0]);
	$vars->{'profile.form.header'} = "\n\n".WebGUI::Form::formHeader({});
	$vars->{'profile.form.footer'} = WebGUI::Form::formFooter();

	$vars->{'profile.form.hidden'} = WebGUI::Form::hidden({"name"=>"op","value"=>"editProfileSave"});
	$vars->{'profile.form.hidden'} .= WebGUI::Form::hidden({"name"=>"uid","value"=>$session{user}{userId}});
	my @array = ();
	foreach my $category (@{WebGUI::ProfileCategory->getCategories}) {
		my @temp = ();
		foreach my $field (@{$category->getFields}) {
			push(@temp, {
				'profile.form.element' => $field->formField,
				'profile.form.element.label' => $field->getLabel,
				'profile.form.element.subtext' => $field->get("required") ? "*" : undef
				});
		}
		push(@array, {
			'profile.form.category' => $category->getLabel,
                        'profile.form.category.loop' => \@temp
			});
	}
	$vars->{'profile.form.elements'} = \@array;
	$vars->{'profile.form.submit'} = WebGUI::Form::submit({});
	$vars->{'profile.accountOptions'} = WebGUI::Operation::Shared::accountOptions();
	return WebGUI::Operation::Shared::userStyle(WebGUI::Asset::Template->new("PBtmpl0000000000000051")->process($vars));
}

#-------------------------------------------------------------------
sub www_editProfileSave {
	my ($profile, $fieldName, $error, $u, $warning);
	return WebGUI::Operation::Auth::www_auth("init") if ($session{user}{userId} eq '1');
	
	($profile, $error, $warning) = validateProfileData();
	$error .= $warning;
    
	return www_editProfile('<ul>'.$error.'</ul>') if($error ne "");
    
	$u = WebGUI::User->new($session{user}{userId});
	foreach $fieldName (keys %{$profile}) {
		$u->profileField($fieldName,$profile->{$fieldName});
	}
	WebGUI::Session::refreshUserInfo($session{user}{userId});
	return WebGUI::Operation::Auth::www_auth();
}

#-------------------------------------------------------------------
sub www_viewProfile {
	my $u = WebGUI::User->new($session{form}{uid});
	my $vars = {};
	$vars->{displayTitle} = '<h1>'.WebGUI::International::get(347).' '.$u->username.'</h1>';

	return WebGUI::Privilege::notMember() if($u->username eq "");

	return WebGUI::Operation::Shared::userStyle($vars->{displayTitle}.WebGUI::International::get(862)) if($u->profileField("publicProfile") < 1 && ($session{user}{userId} ne $session{form}{uid} || WebGUI::Grouping::isInGroup(3)));
	return WebGUI::Privilege::insufficient() if(!WebGUI::Grouping::isInGroup(2));

	my @array = ();
	foreach my $category (@{WebGUI::ProfileCategory->getCategories}) {
		next unless ($category->get("visible"));
		push(@array, {'profile.category' => $category->getLabel});
		foreach my $field (@{$category->getFields}) {
			next unless ($field->get("visible"));
			next if ($field->get("fieldName") eq "email" && !$u->profileField("publicEmail"));
			push(@array, {
				'profile.label' => $field->getLabel,
				'profile.value' => $u->profileField($field->getId)
				});
		}
	}
	$vars->{'profile.elements'} = \@array;
	if ($session{user}{userId} eq $session{form}{uid}) {
		$vars->{'profile.accountOptions'} = WebGUI::Operation::Shared::accountOptions();
	}
	return WebGUI::Operation::Shared::userStyle(WebGUI::Asset::Template->new("PBtmpl0000000000000052")->process($vars));
}

1;
