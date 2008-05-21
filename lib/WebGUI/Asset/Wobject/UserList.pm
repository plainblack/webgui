package WebGUI::Asset::Wobject::UserList;

#$VERSION = "2.0.0";

use strict;
use warnings;
use HTML::Entities;
use Tie::CPHash;
use Tie::IxHash;
use WebGUI::Utility;
use WebGUI::Asset::Wobject;
use WebGUI::Operation::Shared;
use WebGUI::International;

our @ISA = qw(WebGUI::Asset::Wobject);

=head1 LEGAL

Copyright 2004-2008 United Knowledge

http://www.unitedknowledge.nl
developmentinfo@unitedknowledge.nl

=head1 NAME

Package WebGUI::Asset::Wobject::UserList

=head1 DESCRIPTION

This wobject gives a list of webgui users.
The username is always shown.
The userId is only shown in Admin mode.
The wobject also checks the publicProfile and publicEmail setting for each user.

=head1 SYNOPSIS

use WebGUI::Asset::Wobject::UserList;

=cut

#-------------------------------------------------------------------

=head2 getAlphabetSearchLoop ( )

Returns an array ref that contains tmpl_vars for the Alphabet Search.

=cut

sub getAlphabetSearchLoop {
    my $self = shift;
    my $fieldName = shift;
    my $alphabet = shift;
    my (@alphabet, @alphabetLoop);
    $alphabet ||= "a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z";
    @alphabet = split(/,/,$alphabet);
    foreach my $letter (@alphabet){
        my $htmlEncodedLetter = encode_entities($letter);
        #print "adding letter ".$letter.",htmlEncodedLetter: $htmlEncodedLetter<br>"; 
        my $searchURL = "?searchExact_".$fieldName."=".$letter."%25"; 
        my $hasResults = $self->session->db->quickScalar("select if ("
            ."(select count(*) from userProfileData where lastName  like '".$letter."%')<>0, 1, 0)");
        push @alphabetLoop, {
            alphabetSearch_loop_label       => $htmlEncodedLetter || $letter,
            alphabetSearch_loop_hasResults  => $hasResults,
            alphabetSearch_loop_searchURL   => $searchURL,
        }
    }
    return \@alphabetLoop;
}

#-------------------------------------------------------------------

=head2 definition ( properties )

Defines wobject properties for UserList instances.

=head3 properties

A hash reference containing the properties of this wobject.

=cut

sub definition {
    my $class = shift;
    my $session = shift;
    my $definition = shift;
    my %properties;
    my $i18n = WebGUI::International->new($session, 'Asset_UserList');

    my %sortByOptions;
    tie %sortByOptions, 'Tie::IxHash';
    my $fields = $session->db->read("SELECT field.fieldName, field.label FROM userProfileField as field "
        ."left join userProfileCategory as cat USING(profileCategoryId) ORDER BY cat.sequenceNumber, field.sequenceNumber");
    while (my $field = $fields->hashRef){
        my $label = WebGUI::Operation::Shared::secureEval($session,$field->{label});
        $sortByOptions{$field->{fieldName}} = $label;
    }

    tie %properties, 'Tie::IxHash';
    %properties = (
       	templateId =>{
            fieldType=>"template",  
            defaultValue=>'UserListTmpl0000001',
		    namespace=>'UserList',
    		tab=>"display",
	    },

        showGroupId=>{
		   	fieldType=>"group",  
            defaultValue=>"7",
		    label=>$i18n->get("Group to show label"),
            hoverHelp=>$i18n->get('Group to show description'),
    		tab=>"display",
		},
        hideGroupId=>{
	    	fieldType=>"group",  
            defaultValue=>"3",
		   	label=>$i18n->get("Group to hide label"),
		    hoverHelp=>$i18n->get('Group to hide description'),
            tab=>"display",
		},
	    usersPerPage=>{
    		fieldType=>"integer",  
            defaultValue=>"25",
	    	tab=>"display",
		   	hoverHelp=>$i18n->get('Users per page description'),
            label=>$i18n->get("Users per page label"),
		},
        alphabet=>{
            fieldType=>"text",
            defaultValue=>"",
            tab=>"display",
            label=>$i18n->get("alphabet label"),
            hoverHelp=>$i18n->get('alphabet description'),
        },
        showOnlyVisibleAsNamed=>{
            fieldType=>"yesNo",
            defaultValue=>"0",
            tab=>"display",
            label=>$i18n->get("showOnlyVisibleAsNamed label"),
            hoverHelp=>$i18n->get('showOnlyVisibleAsNamed description'),
        },
        sortOrder =>{
            fieldType=>"selectBox",
            defaultValue=>'asc',
            tab=>'display',
            options=>{ asc => $i18n->get('ascending'),
                       desc => $i18n->get('descending') },
            label=>$i18n->get('sort order'),
            hoverHelp=>$i18n->get('sort order description'),
        },
        sortBy =>{
            fieldType=>"selectBox",
            defaultValue=>'lastName',
            tab=>'display',
            options=>\%sortByOptions,
            label=>$i18n->get('sort by'),
            hoverHelp=>$i18n->get('sort by description'),
        },
    );
	
	push(@{$definition}, {                
		assetName=>$i18n->get('assetName'),                
		icon=>'userlist.gif', 
		autoGenerateForms=>1,                
		tableName=>'UserList',
		className=>'WebGUI::Asset::Wobject::UserList',
		properties=>\%properties                
	});
    return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 isInGroup ( [ groupId ] )

Returns a boolean (0|1) value signifying that the user has the required privileges. Always returns true for Admins.
The UserList Wobject has its own isInGroup method for performance reasons, instead of using the WebGUI::User API.
To use the API a User object would have to be created for every user. This in turn would mean to unnessecary hits on the
database. 

=head3 groupId

The group that you wish to verify against the user. Defaults to group with Id 3 (the Admin group).

=cut

sub isInGroup {
   my (@data, $groupId);
   my ($self, $gid, $uid, $secondRun) = @_;
   $gid = 3 unless (defined $gid);
   ### The following several checks are to increase performance. If this section were removed, everything would continue to work as normal.
   return 1 if ($gid eq '7');       # everyone is in the everyone group
   return 1 if ($gid eq '1' && $uid eq '1');    # visitors are in the visitors group
   return 1 if ($gid eq '2' && $uid ne '1');    # if you're not a visitor, then you're a registered user
   ### Get data for auxillary checks.
   my $isInGroup = $self->session->stow->get("isInGroup");
   ### Look to see if we've already looked up this group.
   return $isInGroup->{$uid}{$gid} if exists $isInGroup->{$uid}{$gid};
   ### Lookup the actual groupings.
   my $group = WebGUI::Group->new($self->session,$gid);
   # Cope with non-existant groups. Default to the admin group if the groupId is invalid.
   $group = WebGUI::Group->new($self->session, 3) unless $group;
   ### Check for groups of groups.
   my $users = $group->getAllUsers();
   foreach my $user (@{$users}) {
      $isInGroup->{$user}{$gid} = 1;
      if ($uid eq $user) {
         $self->session->stow->set("isInGroup",$isInGroup);
         return 1;
      }
   }
   $isInGroup->{$uid}{$gid} = 0;
   $self->session->stow->set("isInGroup",$isInGroup);
   return 0;
}

#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
    my $self = shift;
    $self->SUPER::prepareView();
    my $templateId = $self->get("templateId");
    if ($self->session->form->process("overrideTemplateId") ne "") {
        $templateId = $self->session->form->process("overrideTemplateId");
    }
    my $template = WebGUI::Asset::Template->new($self->session, $templateId);
    $template->prepare;
    $self->{_viewTemplate} = $template;
    
    return undef;
}

#-------------------------------------------------------------------

=head2 view ( )

=cut

sub view {

	my $self = shift;
    my $form = $self->session->form;
    my $url = $self->session->url;
	my $i18n = WebGUI::International->new($self->session, "Asset_UserList");
	my (%var, @users, @profileField_loop, @profileFields);
	my ($defaultPublicProfile, $defaultPublicEmail, $user, $sth, $sql, $profileField);
#    my $error = $self->session->errorHandler;
#    my $start_time = time();

    my $currentUrlWithoutSort = $self->getUrl();
    foreach ($form->param) {
        unless (WebGUI::Utility::isIn($_,qw(orderBy orderType op func)) || $_ =~ /identifier/i || $_ =~ /password/i) {
            $currentUrlWithoutSort = $url->append($currentUrlWithoutSort, $url->escape($_)
            .'='.$url->escape($form->process($_)));
        }
    }

#    $error->info("time :".(time() - $start_time));

	$sth = $self->session->db->read("SELECT field.fieldName, field.label, field.sequenceNumber, field.visible "
        ."FROM userProfileField as field "
		."left join userProfileCategory as category USING(profileCategoryId) "
		."ORDER BY category.sequenceNumber, field.sequenceNumber");
	while ($profileField = $sth->hashRef){
        my $label = WebGUI::Operation::Shared::secureEval($self->session,$profileField->{label});
        my $fieldName = $profileField->{fieldName};
        my $sortByURL = $url->append($currentUrlWithoutSort,'orderBy='.$url->escape($fieldName));
        if ($form->process('orderType') eq 'asc' && $form->process('orderBy') eq $fieldName){
            $sortByURL = $url->append($sortByURL,'orderType=desc');
        }
        else{
            $sortByURL = $url->append($sortByURL,'orderType=asc');
        }
  		push(@profileFields, {
    				"fieldName"=>$fieldName,
	    			"label"=>$label,
		    		"sequenceNumber"=>$profileField->{sequenceNumber},
                    "visible"=>$profileField->{visible},
			    	});
        push (@profileField_loop, {
            "profileField_label"=>$label,
            "profileField_sortByURL"=>$sortByURL,
        });
        unless($self->get("showOnlyVisibleAsNamed") && $profileField->{visible} != 1){
            $var{'profileField_'.$fieldName.'_label'} = $label;
            $var{'profileField_'.$fieldName.'_sortByURL'} = $sortByURL;
        }
        # create field specific templ_vars for search
        $var{'search_'.$fieldName.'_text'} = WebGUI::Form::Text($self->session, {
            -name   => 'search_'.$fieldName,
            -value  => $form->process('search_'.$fieldName),
        }); 
        $var{'searchExact_'.$fieldName.'_text'} = WebGUI::Form::Text($self->session, {
            -name   => 'searchExact_'.$fieldName,
            -value  => $form->process('searchExact_'.$fieldName),
        });
        $var{'includeInSearch_'.$fieldName.'_hidden'} =  WebGUI::Form::Hidden($self->session, {
            -name   => 'includeInSearch_'.$fieldName,
            -value  => '1',
        });
        $var{'includeInSearch_'.$fieldName.'_checkBox'} = WebGUI::Form::Checkbox($self->session, {
            -name   => 'includeInSearch_'.$fieldName,
            -value  => '1',
            -checked=> $form->process('includeInSearch_'.$fieldName),
        });
	}
    
#    $error->info("selected profile fields, time :".(time() - $start_time));
	$sql = "select distinct users.userId, users.userName, userProfileData.publicProfile, userProfileData.publicEmail ";
	
	foreach my $profileField (@profileFields){
    	$sql .= ", userProfileData.$profileField->{fieldName}";
	}
	$sql .= "	from users";
	$sql .= " left join userProfileData using(userId) where users.userId != '1'";
	
#    $error->info("creating constraint, time :".(time() - $start_time));
	my $constraint;
    my @profileSearchFields = ();
    my $searchType = $form->process('searchType') || 'or';
	if ($form->process('search')){
        # Normal search with one query takes precedence over other search options
        if($form->process('limitSearch')){
            # Normal search with one query in a limited number of fields
            foreach my $profileField (@profileFields){
                if ($form->process('includeInSearch_'.$profileField->{fieldName})){    
                    push(@profileSearchFields,'userProfileData.'.$profileField->{fieldName}
                    .' like "%'.$form->process('search').'%"');
                }
            }
        }
        else{
            # Normal search with one query in all fields
    		$constraint = "(".join(' or ', map {'userProfileData.'.$_->{fieldName}
            .' like "%'.$form->process('search').'%"'} @profileFields).")";	
        }
	}
    elsif ($form->process('searchExact')){
        # Exact search with one query
        if($form->process('limitSearch')){
            # Exact search with one query in a limited number of fields
            foreach my $profileField (@profileFields){
                if ($form->process('includeInSearch_'.$profileField->{fieldName})){
                    push(@profileSearchFields,'userProfileData.'.$profileField->{fieldName}
                    .' like "'.$form->process('search').'"');
                }
            }
        }
        else{
            # Exact search with one query in all fields
            $constraint = "(".join(' or ', map {'userProfileData.'.$_->{fieldName}
            .' like "'.$form->process('searchExact').'"'} @profileFields).")";
        }
    }
    else{
        # Mixed normal and exact search with different queries for each field.
    	foreach my $profileField (@profileFields){
            # Exact search has precedence over normal search
            if ($form->process('searchExact_'.$profileField->{fieldName})){
                push(@profileSearchFields,'userProfileData.'.$profileField->{fieldName}
                    .' like "'.$form->process('searchExact_'.$profileField->{fieldName}).'"');
            }
            elsif ($form->process('search_'.$profileField->{fieldName})){
                push(@profileSearchFields,'userProfileData.'.$profileField->{fieldName}
                    .' like "%'.$form->process('search_'.$profileField->{fieldName}).'%"');
            }
	    }
	}
    if (scalar(@profileSearchFields) > 0){
        $constraint = '('.join(' '.$searchType.' ',@profileSearchFields).')';
    }
	$sql .= " and ".$constraint if ($constraint);

#	$error->info("created constraint, time :".(time() - $start_time));

	my $orderBy = $form->process('orderBy') || $self->get('sortBy') || 'users.username';
	my $orderType = $form->process('orderType') || $self->get('sortOrder') || 'asc';
	
    my @orderByUserProperties = ('dateCreated', 'lastUpdated', 'karma', 'userId');
    if(isIn($orderBy,@orderByUserProperties)){
            $orderBy = 'users.'.$orderBy;
    }
	$sql .= " order by ".$orderBy." ".$orderType;

	($defaultPublicProfile) = $self->session->db->quickArray("SELECT dataDefault FROM userProfileField WHERE fieldName='publicProfile'");
	($defaultPublicEmail) = $self->session->db->quickArray("SELECT dataDefault FROM userProfileField WHERE fieldName='publicEmail'");

	my $paginatePage = $form->param('pn') || 1;
	my $currentUrl = $self->getUrl();
	foreach ($form->param) {
        unless ($_ eq "pn" || $_ eq "op" || $_ eq "func" || $_ =~ /identifier/i || $_ =~ /password/i) {
            $currentUrl = $url->append($currentUrl, $url->escape($_)
            .'='.$url->escape($form->process($_)));
        }
    }

	my $p = WebGUI::Paginator->new($self->session,$currentUrl,$self->getValue("usersPerPage"), undef, $paginatePage);

#    $error->info("reading from database, time :".(time() - $start_time));
	$sth = $self->session->db->read($sql);
#    $error->info("users read from database, time :".(time() - $start_time));
	my @visibleUsers;
	while (my $user = $sth->hashRef){
		my $showGroupId = $self->get("showGroupId");
		if ($showGroupId eq '0' || ($showGroupId && $self->isInGroup($showGroupId,$user->{userId}))){
			unless ($self->get("hideGroupId") ne '0' && $self->isInGroup($self->get("hideGroupId"),$user->{userId})){
				push(@visibleUsers,$user);
			}
		}
	}
#    $error->info("applied group constraints, time :".(time() - $start_time));
	$p->setDataByArrayRef(\@visibleUsers);
	my $users = $p->getPageData($paginatePage);
#    $error->info("set data by page, time :".(time() - $start_time));
	foreach my $user (@$users){
	    if ($user->{publicProfile} eq "1" || ($user->{publicProfile} eq "" && $defaultPublicProfile eq "1")){
		    my (@profileFieldValues);
			my %userProperties;
			my $emailNotPublic;
			$emailNotPublic = 1 if ($user->{publicEmail} eq "0" || ($user->{publicEmail} eq "" && $defaultPublicEmail ne "1"));
			foreach my $profileField (@profileFields){
				if ($profileField->{fieldName} eq "email" && $emailNotPublic){
			    	push (@profileFieldValues, {
				    	"profile_emailNotPublic"=>1,
    				});
				}
                else{
					push (@profileFieldValues, {
    					"profile_value"=>$user->{$profileField->{fieldName}},
					});
                    my $profileFieldName = $profileField->{fieldName};
                    $profileFieldName =~ s/ /_/g;
                    $profileFieldName =~ s/\./_/g;
                    unless($self->get("showOnlyVisibleAsNamed") && $profileField->{visible} != 1){
                        $userProperties{'user_profile_'.$profileFieldName.'_value'} = $user->{$profileField->{fieldName}};
                    }
		    		#$userProperties{"user.profile.".$profileFieldName.".value"} = $user->{$profileField->{fieldName}};
				}
			}
			$userProperties{"user_profile_emailNotPublic"} = $emailNotPublic;
			$userProperties{"user_id"} = $user->{userId};
			$userProperties{"user_name"} = $user->{userName};
			$userProperties{"user_profile_loop"} = \@profileFieldValues;
			push(@users,\%userProperties);
		}
        else{
			push(@users, {
		    	"user_id"=>$user->{userId},
			    "user_name"=>$user->{userName},
			});
		}
	}
#    $error->info("created tmpl vars for users, time :".(time() - $start_time));
    $p->appendTemplateVars(\%var);

	$var{numberOfProfileFields} = scalar(@profileFields);

	$var{profileField_loop}     = \@profileField_loop;
	$var{user_loop}             = \@users;
    $var{alphabetSearch_loop}   = $self->getAlphabetSearchLoop("lastName",$self->get("alphabet"));

	$var{searchFormHeader}      = WebGUI::Form::formHeader($self->session,{action => $self->getUrl});
    $var{searchFormSubmit}      = WebGUI::Form::submit($self->session,{value => $i18n->get('submit search label')});
    $var{searchFormFooter}      = WebGUI::Form::formFooter($self->session);

    $var{limitSearch}           = WebGUI::Form::hidden($self->session, {name=>'limitSearch', value=>'1'});
	$var{searchFormTypeOr}      = WebGUI::Form::hidden($self->session, {name=>'searchType', value=>'or'});
	$var{searchFormTypeAnd}     = WebGUI::Form::hidden($self->session, {name=>'searchType', value=>'and'});
	$var{searchFormTypeSelect}  = WebGUI::Form::selectBox($self->session,{
        name    =>  'searchType',
        value   =>  $form->process('searchType') || 'or',
        options =>  {
            'or'    =>  $i18n->get('or label'),
            'and'   =>  $i18n->get('and label'),
        }
    });
    $var{searchFormQuery_form}  = WebGUI::Form::text($self->session,{
        name    =>  'search',
        value   =>  $form->process("search"),
    });
        

#    $error->info("global tmpl_vars created, time :".(time() - $start_time));
	my $out = $self->processTemplate(\%var,$self->get("templateId"));
#    $error->info("done, going to return output, time :".(time() - $start_time));
	return $out;
}

1;
