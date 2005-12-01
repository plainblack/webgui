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
use WebGUI::Operation::Shared;

#-------------------------------------------------------------------
# Builds Extra form requirements for anonymous registration. 
sub getRequiredProfileFields {
   my ($f,$a,$method,$label,$default,$values,$data,@array);

   #$f = WebGUI::HTMLForm->new();

   $a = WebGUI::SQL->read("select * from userProfileField, userProfileCategory where userProfileField.profileCategoryId=userProfileCategory.profileCategoryId and 
                                userProfileField.required=1 order by userProfileCategory.sequenceNumber,userProfileField.sequenceNumber",WebGUI::SQL->getSlave);
	while($data = $a->hashRef) {
		my %hash = ();
		$method = $data->{dataType};
		$label = WebGUI::Operation::Shared::secureEval($data->{fieldLabel});
		$default = WebGUI::Operation::Shared::secureEval($data->{dataDefault});
		$values = WebGUI::Operation::Shared::secureEval($data->{dataValues});
		my $default;
		if ($session{form}{$data->{fieldName}}) {
			$default = $session{form}{$data->{fieldName}};
		}
		elsif ($session{user}{$data->{fieldName}}) {
			$default = $session{user}{$data->{fieldName}};
		} 
		else {
			$default = WebGUI::Operation::Shared::secureEval($data->{dataDefault});
		}
		my $form = WebGUI::Form::DynamicField->new(
			name => $data->{fieldName},
			value => $default,
			options => $values,
			fieldType => $method,
		);

		$hash{'profile.form.element'} = $form->displayForm();
		$hash{'profile.formElement.label'} = $label;
		push(@array,\%hash)
	}
	$a->finish;
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
	my (%data, $error, $a, %field, $warning);
	tie %field, 'Tie::CPHash';
	$a = WebGUI::SQL->read("select * from userProfileField,userProfileCategory where userProfileField.profileCategoryId=userProfileCategory.profileCategoryId
		   and userProfileCategory.editable=1 and userProfileField.editable=1 order by userProfileCategory.sequenceNumber,userProfileField.sequenceNumber");
	while (%field = $a->hash) {
		my $holder = WebGUI::FormProcessor::process($field{fieldName},$field{dataType}, $field{dataDefault});
		WebGUI::Macro::negate(\$holder);
		$data{$field{fieldName}} = $holder;
		if ($field{required} && !($data{$field{fieldName}})) {
			$error .= '<li>'.(WebGUI::Operation::Shared::secureEval($field{fieldLabel})).' '.WebGUI::International::get(451).'</li>';
		}
		elsif($field{fieldName} eq "email" && isDuplicateEmail($data{$field{fieldName}})){
			$warning .= '<li>'.WebGUI::International::get(1072).'</li>';
		}
	}
	$a->finish;
	return (\%data, $error, $warning);
}

#-------------------------------------------------------------------
sub www_editProfile {
	my ($a, $data, $previousCategory, $subtext, $vars, @profile, @array);
	return WebGUI::Operation::Auth::www_auth("init") if($session{user}{userId} eq '1');

	$vars->{displayTitle} .= '<h1>'.WebGUI::International::get(338).'</h1>';

	$vars->{'profile.message'} = $_[0] if($_[0]);
	$vars->{'profile.form.header'} = "\n\n".WebGUI::Form::formHeader({});
	$vars->{'profile.form.footer'} = WebGUI::Form::formFooter();

	$vars->{'profile.form.hidden'} = WebGUI::Form::hidden({"name"=>"op","value"=>"editProfileSave"});
	$vars->{'profile.form.hidden'} .= WebGUI::Form::hidden({"name"=>"uid","value"=>$session{user}{userId}});

	$a = WebGUI::SQL->read("select * from userProfileField,userProfileCategory where userProfileField.profileCategoryId=userProfileCategory.profileCategoryId
		and userProfileCategory.editable=1 and userProfileField.editable=1 order by userProfileCategory.sequenceNumber,userProfileField.sequenceNumber");
	my $counter = 0;
	while($data = $a->hashRef) {
		$counter++;
		my %hash = ();
		my $category = WebGUI::Operation::Shared::secureEval($data->{categoryName});
		my $label = WebGUI::Operation::Shared::secureEval($data->{fieldLabel});
		my $values = WebGUI::Operation::Shared::secureEval($data->{dataValues});
		my $method = $data->{dataType};
		my $orderedValues = {};
		tie %{$orderedValues}, 'Tie::IxHash';
		foreach my $ov (sort keys %{$values}) {
			$orderedValues->{$ov} = $values->{$ov};
		}
		my $default;
		if ($session{form}{$data->{fieldName}}) {
			$default = $session{form}{$data->{fieldName}};
		}
		elsif ($session{user}{$data->{fieldName}}) {
			$default = $session{user}{$data->{fieldName}};
		} 
		else {
			$default = WebGUI::Operation::Shared::secureEval($data->{dataDefault});
		}
		my $form = WebGUI::Form::DynamicField->new(
			name => $data->{fieldName},
			value => $default,
			options => $orderedValues,
			fieldType => $method,
		);

		$hash{'profile.form.element'} = $form->displayForm();
		$hash{'profile.form.element.label'} = $label;

		if ($data->{required}) {
			$hash{'profile.form.element.subtext'} = "*";
		}
		push(@profile,\%hash);
		if (($previousCategory && $category ne $previousCategory) || $counter eq $a->rows) {
			my @temp = @profile;
			my $hashRef;
			$hashRef->{'profile.form.category'} = $previousCategory;
			$hashRef->{'profile.form.category.loop'} = \@temp;
			push(@array,$hashRef);
			@profile = ();
		}
		$previousCategory = $category;
	}
	$a->finish;

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
		$u->profileField($fieldName,WebGUI::HTML::filter(${$profile}{$fieldName},"javascript"));
	}
	WebGUI::Session::refreshUserInfo($session{user}{userId});
	return WebGUI::Operation::Auth::www_auth();
}

#-------------------------------------------------------------------
sub www_viewProfile {
	my ($a, %data, $category, $label, $value, $previousCategory, $u, $vars, @array);
	$u = WebGUI::User->new($session{form}{uid});
	$vars->{displayTitle} = '<h1>'.WebGUI::International::get(347).' '.$u->username.'</h1>';

	return WebGUI::Privilege::notMember() if($u->username eq "");

	return WebGUI::Operation::Shared::userStyle($vars->{displayTitle}.WebGUI::International::get(862)) if($u->profileField("publicProfile") < 1 && ($session{user}{userId} ne $session{form}{uid} || WebGUI::Grouping::isInGroup(3)));

	return WebGUI::Privilege::insufficient() if(!WebGUI::Grouping::isInGroup(2));

	$a = WebGUI::SQL->read("select * from userProfileField,userProfileCategory where userProfileField.profileCategoryId=userProfileCategory.profileCategoryId
		and userProfileCategory.visible=1 and userProfileField.visible=1 order by userProfileCategory.sequenceNumber,
		userProfileField.sequenceNumber",WebGUI::SQL->getSlave);

	while (%data = $a->hash) {

		$category = WebGUI::Operation::Shared::secureEval($data{categoryName});
		if ($category ne $previousCategory) {
			my $header;
			$header->{'profile.category'} = $category;
			push(@array,$header);
			$previousCategory = $category;
		}

		next if ($data{fieldName} eq "email" and $u->profileField("publicEmail"));

		$label = WebGUI::Operation::Shared::secureEval($data{fieldLabel});

		##If the form field has multiple selections, only display the one the user
		##currently has selected.
		if ($data{dataValues}) {
			$value = WebGUI::Operation::Shared::secureEval($data{dataValues});
			$value = ${$value}{$u->profileField($data{fieldName})};
		}
		else {
			$value = $u->profileField($data{fieldName});
		}

		my $form = WebGUI::Form::DynamicField->new(
			value => $value,
			fieldType => $data{dataType},
		);

		$value = $form->displayValue();

		my $hash;

		$hash->{'profile.label'} = $label;
		$hash->{'profile.value'} = $value;
		push(@array,$hash);
	}
	$vars->{'profile.elements'} = \@array;
	$a->finish;
	if ($session{user}{userId} eq $session{form}{uid}) {
		$vars->{'profile.accountOptions'} = WebGUI::Operation::Shared::accountOptions();
	}
	return WebGUI::Operation::Shared::userStyle(WebGUI::Asset::Template->new("PBtmpl0000000000000052")->process($vars));
}

1;
