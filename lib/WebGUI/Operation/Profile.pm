package WebGUI::Operation::Profile;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2004 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use Exporter;
use strict qw(vars subs);
use URI;
use WebGUI::Operation::Auth;
use WebGUI::DateTime;
use WebGUI::ErrorHandler;
use WebGUI::FormProcessor;
use WebGUI::Grouping;
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

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_editProfile &www_editProfileSave &www_viewProfile);

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
       $label = eval $data->{fieldLabel};
	   $default = eval $data->{dataDefault};
	   if ($method eq "selectList") {
          $values = eval $data->{dataValues};
		  # note: this big if statement doesn't look elegant, but doing regular ORs caused problems with the array reference.
          if ($session{form}{$data->{fieldName}}) {
             $default = [$session{form}{$data->{fieldName}}];
	      } elsif ($session{user}{$data->{fieldName}}) {
        	 $default = [$session{user}{$data->{fieldName}}];
          } 
          $hash{'profile.formElement'} = WebGUI::Form::selectList({
                        "name"=>$data->{fieldName},
                        "options"=>$values,
                        "value"=>$default
                        });
	   } else {
          if ($session{form}{$data->{fieldName}}) {
             $default = $session{form}{$data->{fieldName}};
          } elsif (exists $session{user}{$data->{fieldName}}) {
             $default = $session{user}{$data->{fieldName}};
	  } else {
	     $default = $data->{dataDefault};
	  }
	     
		  my $cmd = 'WebGUI::Form::'.$method.'({"name"=>$data->{fieldName},"value"=>$default})';
		  $hash{'profile.formElement'} = eval($cmd);
		  
       }
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
 
=over

=item email
   
   email address to check for duplication

=back

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
      $data{$field{fieldName}} = WebGUI::Macro::negate(WebGUI::FormProcessor::process($field{fieldName},$field{dataType}));
	  if ($field{required} && $data{$field{fieldName}} eq "") {
	     $error .= '<li>'.(eval $field{fieldLabel}).' '.WebGUI::International::get(451);
	  }elsif($field{fieldName} eq "email" && isDuplicateEmail($data{$field{fieldName}})){
		 $warning .= '<li>'.WebGUI::International::get(1072);
	  }
   }
   $a->finish;
   return (\%data, $error, $warning);
}

#-------------------------------------------------------------------
sub www_editProfile {
   my ($a, $data, $method, $values, $category, $label, $default, $previousCategory, $subtext, $vars, @profile, @array);
   return WebGUI::Operation::Auth::www_auth("init") if($session{user}{userId} == 1);
   
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
	   $category = eval $data->{categoryName};
       $method = $data->{dataType};
       $label = eval $data->{fieldLabel};
	   $default = eval $data->{dataDefault};
	   
	   if ($method eq "selectList") {
          $values = eval $data->{dataValues};
		  # note: this big if statement doesn't look elegant, but doing regular ORs caused problems with the array reference.
          if ($session{form}{$data->{fieldName}}) {
             $default = [$session{form}{$data->{fieldName}}];
	      } elsif ($session{user}{$data->{fieldName}}) {
        	 $default = [$session{user}{$data->{fieldName}}];
          } 
          $hash{'profile.form.element'} = WebGUI::Form::selectList({
                        "name"=>$data->{fieldName},
                        "options"=>$values,
                        "value"=>$default
                        });
	   } else {
          if ($session{form}{$data->{fieldName}}) {
             $default = $session{form}{$data->{fieldName}};
          } elsif (exists $session{user}{$data->{fieldName}}) {
             $default = $session{user}{$data->{fieldName}};
	      }
		  my $cmd = 'WebGUI::Form::'.$method.'({"name"=>$data->{fieldName},"value"=>$default})';
		  $hash{'profile.form.element'} = eval($cmd);
		  
       }
	   $hash{'profile.form.element.label'} = $label;
	   if ($data->{required}) {
	      $hash{'profile.form.element.subtext'} = "*";
	   }
	   if (($previousCategory && $category ne $previousCategory) || $counter eq $a->rows) {
          my @temp = @profile;
		  my $hashRef;
		  $hashRef->{'profile.form.category'} = $previousCategory;
		  $hashRef->{'profile.form.category.loop'} = \@temp;
		  push(@array,$hashRef);
		  @profile = ();
	   }
	   push(@profile,\%hash);
	   $previousCategory = $category;
    }
    $a->finish;
	
	$vars->{'profile.form.elements'} = \@array;
    $vars->{'profile.form.submit'} = WebGUI::Form::submit({});
    $vars->{'profile.accountOptions'} = WebGUI::Operation::Shared::accountOptions();
	return WebGUI::Template::process(1,'Operation/Profile/Edit', $vars);
}

#-------------------------------------------------------------------
sub www_editProfileSave {
	my ($profile, $fieldName, $error, $u, $warning);
    return WebGUI::Operation::Auth::www_auth("init") if ($session{user}{userId} == 1);
	
	($profile, $error, $warning) = validateProfileData();
	$error .= $warning;
    
	return www_editProfile('<ul>'.$error.'</ul>') if($error ne "");
    
	$u = WebGUI::User->new($session{user}{userId});
    foreach $fieldName (keys %{$profile}) {
       $u->profileField($fieldName,${$profile}{$fieldName});
	}
	return WebGUI::Operation::Auth::www_displayAccount();
}

#-------------------------------------------------------------------
sub www_viewProfile {
    my ($a, %data, $category, $label, $value, $previousCategory, $u, %gender,$vars,@array);
	%gender = ('neuter'=>WebGUI::International::get(403),'male'=>WebGUI::International::get(339),'female'=>WebGUI::International::get(340));
	$u = WebGUI::User->new($session{form}{uid});
    $vars->{displayTitle} = '<h1>'.WebGUI::International::get(347).' '.$u->username.'</h1>';
	return WebGUI::Privilege::notMember() if($u->username eq "");
	return $vars->{displayTitle}.WebGUI::International::get(862) if($u->profileField("publicProfile") < 1);
	return WebGUI::Privilege::insufficient() if(!WebGUI::Grouping::isInGroup(2));
    $a = WebGUI::SQL->read("select * from userProfileField,userProfileCategory where userProfileField.profileCategoryId=userProfileCategory.profileCategoryId
		and userProfileCategory.visible=1 and userProfileField.visible=1 order by userProfileCategory.sequenceNumber,
		userProfileField.sequenceNumber",WebGUI::SQL->getSlave);
    while (%data = $a->hash) {
	   $category = eval $data{categoryName};
       if ($category ne $previousCategory) {
          my $header;
		  $header->{'profile.category'} = $category;
		  push(@array,$header);
       }
	   
	   $label = eval $data{fieldLabel};
	   if ($data{dataValues}) {
	      $value = eval $data{dataValues};
		  $value = ${$value}{$u->profileField($data{fieldName})};
	   } else {
		  $value = $u->profileField($data{fieldName});
	   }
	   if ($data{dataType} eq "date") {
          $value = WebGUI::DateTime::epochToHuman($value,"%z");
       }
	   unless ($data{fieldName} eq "email" and $u->profileField("publicEmail") < 1) {
		  my $hash;
		  $hash->{'profile.label'} = $label;
		  $hash->{'profile.value'} = $value;
		  push(@array,$hash);
	   }
       $previousCategory = $category;
    }
	$vars->{'profile.elements'} = \@array;
    $a->finish;
	if ($session{user}{userId} == $session{form}{uid}) {
       $vars->{'profile.accountOptions'} = WebGUI::Operation::Shared::accountOptions();
	}
    return WebGUI::Template::process(1,'Operation/Profile/View', $vars);
}

1;
