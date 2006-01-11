package WebGUI::Operation::Profile;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
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
use WebGUI::Grouping;
use WebGUI::HTML;
use WebGUI::HTMLForm;
use WebGUI::International;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::User;
use WebGUI::Utility;
use WebGUI::ProfileField;
use WebGUI::ProfileCategory;
use WebGUI::Operation::Shared;

#-------------------------------------------------------------------
# Builds Extra form requirements for anonymous registration. 
sub getRequiredProfileFields {
	my $session = shift;
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
	my $session = shift;
	my $email = shift;
	my ($otherEmail) = $session->db->quickArray("select count(*) from userProfileData where fieldName='email' and fieldData = ".$session->db->quote($email)." and userId <> ".$session->db->quote($session->user->profileField("userId")));
	return ($otherEmail > 0);
}

#-------------------------------------------------------------------
sub saveProfileFields {
	my $session = shift;
   my $u = shift;
   my $profile = shift;
   
   foreach my $fieldName (keys %{$profile}) {
      $u->profileField($fieldName,${$profile}{$fieldName});
   }
}

#-------------------------------------------------------------------
sub validateProfileData {
	my $session = shift;
	my %data = ();
	my $error = "";
	my $warning = "";
	foreach my $field (@{WebGUI::ProfileField->getEditableFields}) {
		my $fieldValue = $field->formProcess;
		if (ref $fieldValue eq "ARRAY") {
			$data{$field->getId} = $$fieldValue[0];
		} else {
			$data{$field->getId} = $fieldValue;
		}
		if ($field->isRequired && !$data{$field->getId}) {
			$error .= '<li>'.$field->getLabel.' '.WebGUI::International::get(451).'</li>';
		} elsif ($field->getId eq "email" && isDuplicateEmail($data{$field->getId})) {
			$warning .= '<li>'.WebGUI::International::get(1072).'</li>';
		}
	}
	return (\%data, $error, $warning);
}

#-------------------------------------------------------------------
sub www_editProfile {
	my $session = shift;
	return WebGUI::Operation::Auth::www_auth("init") if($session->user->profileField("userId") eq '1');
	my $vars = {};
	$vars->{displayTitle} .= '<h1>'.WebGUI::International::get(338).'</h1>';
	$vars->{'profile.message'} = $_[0] if($_[0]);
	$vars->{'profile.form.header'} = "\n\n".WebGUI::Form::formHeader($session,{});
	$vars->{'profile.form.footer'} = WebGUI::Form::formFooter($session,);

	$vars->{'profile.form.hidden'} = WebGUI::Form::hidden($session,{"name"=>"op","value"=>"editProfileSave"});
	$vars->{'profile.form.hidden'} .= WebGUI::Form::hidden($session,{"name"=>"uid","value"=>$session->user->profileField("userId")});
	my @array = ();
	foreach my $category (@{WebGUI::ProfileCategory->getCategories}) {
		next unless $category->isEditable;
		my @temp = ();
		foreach my $field (@{$category->getFields}) {
			next unless ($field->isEditable);
			next if $field->getId =~ /contentPositions/;
			push(@temp, {
				'profile.form.element' => $field->formField,
				'profile.form.element.label' => $field->getLabel,
				'profile.form.element.subtext' => $field->isRequired ? "*" : undef
				});
		}
		push(@array, {
			'profile.form.category' => $category->getLabel,
                        'profile.form.category.loop' => \@temp
			});
	}
	$vars->{'profile.form.elements'} = \@array;
	$vars->{'profile.form.submit'} = WebGUI::Form::submit($session,{});
	$vars->{'profile.accountOptions'} = WebGUI::Operation::Shared::accountOptions();
	return $session->style->userStyle(WebGUI::Asset::Template->new("PBtmpl0000000000000051")->process($vars));
}

#-------------------------------------------------------------------
sub www_editProfileSave {
	my $session = shift;
	my ($profile, $fieldName, $error, $u, $warning);
	return WebGUI::Operation::Auth::www_auth("init") if ($session->user->profileField("userId") eq '1');
	
	($profile, $error, $warning) = validateProfileData();
	$error .= $warning;
    
	return www_editProfile('<ul>'.$error.'</ul>') if($error ne "");
    
	$u = WebGUI::User->new($session->user->profileField("userId"));
	foreach $fieldName (keys %{$profile}) {
		$u->profileField($fieldName,$profile->{$fieldName});
	}
	$session->user({user=>$u});
	return WebGUI::Operation::Auth::www_auth();
}

#-------------------------------------------------------------------
sub www_viewProfile {
	my $session = shift;
	my $u = WebGUI::User->new($session->form->process("uid"));
	my $vars = {};
	$vars->{displayTitle} = '<h1>'.WebGUI::International::get(347).' '.$u->username.'</h1>';

	return $session->privilege->notMember() if($u->username eq "");

	return $session->style->userStyle($vars->{displayTitle}.WebGUI::International::get(862)) if($u->profileField("publicProfile") < 1 && ($session->user->profileField("userId") ne $session->form->process("uid") || $session->user->isInGroup(3)));
	return $session->privilege->insufficient() if(!$session->user->isInGroup(2));

	my @array = ();
	foreach my $category (@{WebGUI::ProfileCategory->getCategories}) {
		next unless ($category->get("visible"));
		push(@array, {'profile.category' => $category->getLabel});
		foreach my $field (@{$category->getFields}) {
			next unless ($field->get("visible"));
			next if ($field->get("fieldName") eq "email" && !$u->profileField("publicEmail"));
			push(@array, {
				'profile.label' => $field->getLabel,
				'profile.value' => $field->formField(undef,2,$u)
				});
		}
	}
	$vars->{'profile.elements'} = \@array;
	if ($session->user->profileField("userId") eq $session->form->process("uid")) {
		$vars->{'profile.accountOptions'} = WebGUI::Operation::Shared::accountOptions();
	}
	return $session->style->userStyle(WebGUI::Asset::Template->new("PBtmpl0000000000000052")->process($vars));
}

1;
