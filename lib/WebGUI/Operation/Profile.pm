package WebGUI::Operation::Profile;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2003 Plain Black LLC.
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
use WebGUI::HTMLForm;
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::Mail;
use WebGUI::MessageLog;
use WebGUI::Paginator;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::User;
use WebGUI::Utility;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_editProfile &www_editProfileSave &www_viewProfile);

#-------------------------------------------------------------------
 sub accountOptions {
	my ($output);
	$output = '<div class="accountOptions"><ul>';
	if (WebGUI::Privilege::isInGroup(4) || WebGUI::Privilege::isInGroup(5) || WebGUI::Privilege::isInGroup(6) || WebGUI::Privilege::isInGroup(8) || WebGUI::Privilege::isInGroup(9) || WebGUI::Privilege::isInGroup(10) || WebGUI::Privilege::isInGroup(11)) {
		if ($session{var}{adminOn}) {
			$output .= '<li><a href="'.WebGUI::URL::page('op=switchOffAdmin').'">'.
				WebGUI::International::get(12).'</a>';
		} else {
			$output .= '<li><a href="'.WebGUI::URL::page('op=switchOnAdmin').'">'.WebGUI::International::get(63).'</a>';
		}
	}
	$output .= '<li><a href="'.WebGUI::URL::page('op=displayAccount').'">'.WebGUI::International::get(342).'</a>' 
		unless ($session{form}{op} eq "displayAccount");
	$output .= '<li><a href="'.WebGUI::URL::page('op=editProfile').'">'.WebGUI::International::get(341).'</a>'
		unless ($session{form}{op} eq "editProfile");
	$output .= '<li><a href="'.WebGUI::URL::page('op=viewProfile&uid='.$session{user}{userId}).'">'.WebGUI::International::get(343).'</a>'
		unless ($session{form}{op} eq "viewProfile");
	$output .= '<li><a href="'.WebGUI::URL::page('op=viewMessageLog').'">'.WebGUI::International::get(354).'</a>'
		unless ($session{form}{op} eq "viewMessageLog");
	$output .= '<li><a href="'.WebGUI::URL::page('op=logout').'">'.WebGUI::International::get(64).'</a>'; 

	$output .= '<li><a href="'.WebGUI::URL::page('op=deactivateAccount').'">'.WebGUI::International::get(65).'</a>' if ($session{setting}{selfDeactivation} && !WebGUI::Privilege::isInGroup(3));
	$output .= '</ul></div>';
	return $output;
}

#-------------------------------------------------------------------
# Builds Extra form requirements for anonymous registration. 
sub getRequiredProfileFields {
   my ($f,$a,$method,$label,$default,$values,$data,@array);
      
   #$f = WebGUI::HTMLForm->new();
   
   $a = WebGUI::SQL->read("select * from userProfileField, userProfileCategory where userProfileField.profileCategoryId=userProfileCategory.profileCategoryId and 
	                        userProfileField.required=1 order by userProfileCategory.sequenceNumber,userProfileField.sequenceNumber");
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
	my ($otherEmail) = WebGUI::SQL->quickArray("select count(*) from userProfileData where fieldName='email' and fieldData = ".quote($email)." and userId <> ".$session{user}{userId});
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
      $data{$field{fieldName}} = WebGUI::FormProcessor::process($field{fieldName},$field{dataType});
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
   my ($output, $f, $a, %data, $method, $values, $category, $label, $default, $previousCategory, $subtext);
   return WebGUI::Operation::Auth::www_auth("init") if($session{user}{userId} == 1);
   
   tie %data, 'Tie::CPHash';
   $output .= '<h1>'.WebGUI::International::get(338).'</h1>';
   $f = WebGUI::HTMLForm->new;
   $f->hidden("op","editProfileSave");
   $f->hidden("uid",$session{user}{userId});
   $a = WebGUI::SQL->read("select * from userProfileField,userProfileCategory where userProfileField.profileCategoryId=userProfileCategory.profileCategoryId
		                   and userProfileCategory.editable=1 and userProfileField.editable=1 order by userProfileCategory.sequenceNumber,userProfileField.sequenceNumber");
      
   while(%data = $a->hash) {
      $category = eval $data{categoryName};
      if ($category ne $previousCategory) {
         $f->raw('<tr><td colspan="2" class="tableHeader">'.$category.'</td></tr>');
      }
      $values = eval $data{dataValues};
      $method = $data{dataType};
      $label = eval $data{fieldLabel};
	  $subtext = "";
	  if ($data{required}) {
	     $subtext = "*";
	  }
      
	  $default = eval $data{dataDefault};
	  
	  if ($method eq "selectList") {
         # note: this big if statement doesn't look elegant, but doing regular ORs caused problems with the array reference.
		 if ($session{form}{$data{fieldName}}) {
			$default = [$session{form}{$data{fieldName}}];
		 } elsif ($session{user}{$data{fieldName}}) {
			$default = [$session{user}{$data{fieldName}}];
		 }
         
		 $f->select(
			        -name=>$data{fieldName},
					-options=>$values,
					-label=>$label,
					-value=>$default,
					-subtext=>$subtext
		 );
      } else {
	     if ($session{form}{$data{fieldName}}) {
		    $default = $session{form}{$data{fieldName}};
		 } elsif (exists $session{user}{$data{fieldName}}) {
		    $default = $session{user}{$data{fieldName}};
		 }
		 
         $f->$method(
			        -name=>$data{fieldName},
					-label=>$label,
					-value=>$default,
					-subtext=>$subtext
		 );
      }
      $previousCategory = $category;
   }
   $a->finish;
   $f->submit;
   $output .= $f->print;
   $output .= accountOptions();
   return $output;
}

#-------------------------------------------------------------------
sub www_editProfileSave {
	my ($profile, $fieldName, $error, $u, $warning);
    return WebGUI::Operation::Auth::www_auth("init") if ($session{user}{userId} == 1);
	
	($profile, $error, $warning) = validateProfileData();
	$error .= $warning;
    
	return '<ul>'.$error.'</ul>'.www_editProfile() if($error ne "");
    
	$u = WebGUI::User->new($session{user}{userId});
    foreach $fieldName (keys %{$profile}) {
       $u->profileField($fieldName,${$profile}{$fieldName});
	}
	return WebGUI::Operation::Auth::www_displayAccount();
}

#-------------------------------------------------------------------
sub www_viewProfile {
    my ($a, %data, $category, $label, $value, $previousCategory, $output, $u, %gender);
	%gender = ('neuter'=>WebGUI::International::get(403),'male'=>WebGUI::International::get(339),'female'=>WebGUI::International::get(340));
	$u = WebGUI::User->new($session{form}{uid});
    my $header = '<h1>'.WebGUI::International::get(347).' '.$u->username.'</h1>';
	return WebGUI::Privilege::notMember() if($u->username eq "");
	return $header.WebGUI::International::get(862) if($u->profileField("publicProfile") < 1);
	return WebGUI::Privilege::insufficient() if(!WebGUI::Privilege::isInGroup(2));
    $output = $header;
    $output .= '<table>';
    $a = WebGUI::SQL->read("select * from userProfileField,userProfileCategory where userProfileField.profileCategoryId=userProfileCategory.profileCategoryId
		                    and userProfileCategory.visible=1 and userProfileField.visible=1 order by userProfileCategory.sequenceNumber,userProfileField.sequenceNumber");
    while (%data = $a->hash) {
       $category = eval $data{categoryName};
       if ($category ne $previousCategory) {
          $output .= '<tr><td colspan="2" class="tableHeader">'.$category.'</td></tr>';
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
		  $output .= '<tr><td class="tableHeader">'.$label.'</td><td class="tableData">'.$value.'</td></tr>';
	   }
       $previousCategory = $category;
    }
    $a->finish;
    $output .= '</table>';
	if ($session{user}{userId} == $session{form}{uid}) {
       $output .= accountOptions();
	}
	return $output;

}