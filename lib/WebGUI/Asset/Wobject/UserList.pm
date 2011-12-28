package WebGUI::Asset::Wobject::UserList;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use HTML::Entities;
use Tie::IxHash;
use WebGUI::Asset::Wobject;
use WebGUI::Operation::Shared;
use WebGUI::International;
use WebGUI::Pluggable;
use WebGUI::Form::Image;
use WebGUI::Form::File;
use Moose;
use WebGUI::Definition::Asset;
extends 'WebGUI::Asset::Wobject';

define assetName => ['assetName', 'Asset_UserList'];
define icon      => 'userlist.gif';
define tableName => 'UserList';
property templateId => (
            fieldType   => "template",  
            default     => 'UserListTmpl0000000001',
		    namespace   => 'UserList',
    		tab         => "display",
            hoverHelp   => ["template description",'Asset_UserList'],
            label       => ["template label",'Asset_UserList'],
	    );

property showGroupId => (
		   	fieldType   => "group",  
            default     => "7",
		    label       => ["Group to show label",'Asset_UserList'],
            hoverHelp   => ['Group to show description','Asset_UserList'],
    		tab         => "display",
		);
property hideGroupId => (
	    	fieldType   => "group",  
            default     => "3",
		   	label       => ["Group to hide label",'Asset_UserList'],
		    hoverHelp   => ['Group to hide description','Asset_UserList'],
            tab         => "display",
		);
property usersPerPage => (
    		fieldType   => "integer",  
            default     => "25",
	    	tab         => "display",
		   	hoverHelp   => ['Users per page description','Asset_UserList'],
            label       => ["Users per page label",'Asset_UserList'],
		);
property alphabet => (
            fieldType   => "text",
            default     => "a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z",
            tab         => "display",
            label       => ["alphabet label",'Asset_UserList'],
            hoverHelp   => ['alphabet description','Asset_UserList'],
        );
property alphabetSearchField => (
            fieldType   => "selectBox",
            default     => "lastName",
            tab         => "display",
            options     => \&_alphabetSearchField_options,
            label       => ["alphabetSearchField label",'Asset_UserList'],
            hoverHelp   => ['alphabetSearchField description','Asset_UserList'],
        );
sub _alphabetSearchField_options {
    my $self    = shift;
    my $session = $self->session;
    my $i18n    = WebGUI::International->new($session, 'Asset_UserList');
    my $profileFields = $self->_get_profile_fields();
    my %alphabetSearchFieldOptions;
    tie %alphabetSearchFieldOptions, 'Tie::IxHash';
    %alphabetSearchFieldOptions = ('disableAlphabetSearch'=>'Disable Alphabet Search',%{ $profileFields } );
    return \%alphabetSearchFieldOptions;
}
sub _get_profile_fields {
    my $self    = shift;
    my $session = $self->session;
    my %profileFields;
    tie %profileFields, 'Tie::IxHash';
    my $fields = $session->db->read("SELECT field.fieldName, field.label FROM userProfileField as field "
        ."left join userProfileCategory as cat USING(profileCategoryId) ORDER BY cat.sequenceNumber, field.sequenceNumber");
    while (my $field = $fields->hashRef){
        my $label = WebGUI::Operation::Shared::secureEval($session,$field->{label});
        $profileFields{$field->{fieldName}} = $label;
    }
    return \%profileFields;
}
property showOnlyVisibleAsNamed => (
            fieldType   => "yesNo",
            default     => "0",
            tab         => "display",
            label       => ["showOnlyVisibleAsNamed label",'Asset_UserList'],
            hoverHelp   => ['showOnlyVisibleAsNamed description','Asset_UserList'],
        );
property sortOrder => (
            fieldType   => "selectBox",
            default     => 'asc',
            tab         => 'display',
            options     => \&_sortOrder_options,
            label       => ['sort order','Asset_UserList'],
            hoverHelp   => ['sort order description','Asset_UserList'],
        );
sub _sortOrder_options {
    my $self    = shift;
    my $session = $self->session;
    my $i18n    = WebGUI::International->new($session, 'Asset_UserList');
    my %options = ( asc => $i18n->get('ascending'),
                   desc => $i18n->get('descending') );
    return \%options;

}
property sortBy => (
            fieldType   => "selectBox",
            default     => 'lastName',
            tab         => 'display',
            options     => \&_get_profile_fields,
            label       => ['sort by','Asset_UserList'],
            hoverHelp   => ['sort by description','Asset_UserList'],
        );
property overridePublicEmail => (
            fieldType   => "yesNo",
            default     => "0",
            tab         => "display",
            label       => ["overridePublicEmail label",'Asset_UserList'],
            hoverHelp   => ['overridePublicEmail description','Asset_UserList'],
        );
property overridePublicProfile => (
            fieldType   => "yesNo",
            default     => "0",
            tab         => "display",
            label       => ["overridePublicProfile label",'Asset_UserList'],
            hoverHelp   => ['overridePublicProfile description','Asset_UserList'],
        );

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
    
    return [] if $fieldName eq 'disableAlphabetSearch';
    $alphabet ||= "a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z";
    @alphabet = split(/,/,$alphabet);
    foreach my $letter (@alphabet){
        my $htmlEncodedLetter = encode_entities($letter);
        my $searchURL = "?searchExact_".$fieldName."=".$letter."%25"; 
        my $hasResults;
        my $users = $self->session->db->read("select userId from users join userProfileData using (userId) where `$fieldName` like '".$letter."%'"); 
        while (my $user = $users->hashRef){
            my $showGroupId = $self->showGroupId;
            if ($showGroupId eq '0' || ($showGroupId && $self->isInGroup($showGroupId,$user->{userId}))){
                unless ($self->hideGroupId ne '0' && $self->isInGroup($self->hideGroupId,$user->{userId})){
                    $hasResults = 1;
                    last;
                }
            }
        }

        push @alphabetLoop, {
            alphabetSearch_loop_label       => $htmlEncodedLetter || $letter,
            alphabetSearch_loop_hasResults  => $hasResults,
            alphabetSearch_loop_searchURL   => $searchURL,
        }
    }
    return \@alphabetLoop;
}

#-------------------------------------------------------------------

=head2 getFormElement ( data )

Returns the form element tied to this field.

=head3 data

A hashref containing the properties of this field.

=cut

sub getFormElement {

    my $self = shift;
    my $data = shift;
    my %param;

    $param{name} = $data->{name};
    my $name = $param{name};
    $param{value}  = $data->{value} || WebGUI::Operation::Shared::secureEval($self->session,$data->{dataDefault});
    $param{fieldType} = $data->{fieldType};

    if ($data->{fieldType} eq "Checkbox") {
        $param{value} = ($data->{defaultValue} =~ /checked/xi) ? 1 : "";
    }

    if ($data->{fieldType} ~~ [qw(SelectList CheckList SelectBox Attachments SelectSlider)]) {
        my @defaultValues;
        if ($self->session->form->param($name)) {
                    @defaultValues = $self->session->form->selectList($name);
                } else {
                    foreach (split(/\n/x, $data->{value})) {
                            s/\s+$//x; # remove trailing spaces
                                push(@defaultValues, $_);
                    }
                }
        $param{value} = \@defaultValues;
    }

    if ($data->{possibleValues}){
        my $values = WebGUI::Operation::Shared::secureEval($self->session,$data->{possibleValues});
        unless (ref $values eq 'HASH') {
            if ($self->possibleValues =~ /\S/) {
                $self->session->log->warn("Could not get a hash out of possible values for profile field "
                .$self->getId);
            }
            $values = {};
        }
        $param{options} = $values;
    }

    if ($data->{fieldType} eq "YesNo") {
        if ($data->{defaultValue} =~ /yes/xi) {
                    $param{value} = 1;
                } elsif ($data->{defaultValue} =~ /no/xi) {
                    $param{value} = 0;
                }
    }

    my $formElement =  eval { WebGUI::Pluggable::instanciate("WebGUI::Form::". ucfirst $param{fieldType}, "new",
[$self->session, \%param ])};
    return $formElement->toHtml();

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

override prepareView => sub {
    my $self = shift;
    super();
    my $templateId = $self->templateId;
    if ($self->session->form->process("overrideTemplateId") ne "") {
        $templateId = $self->session->form->process("overrideTemplateId");
    }
    my $template = WebGUI::Asset::Template->newById($self->session, $templateId);
    if (!$template) {
        WebGUI::Error::ObjectNotFound::Template->throw(
            error      => qq{Template not found},
            templateId => $templateId,
            assetId    => $self->getId,
        );
    }
    $template->prepare($self->getMetaDataAsTemplateVariables);
    $self->{_viewTemplate} = $template;
    
    return undef;
};

#-------------------------------------------------------------------

=head2 view ( )

=cut

sub view {

	my $self = shift;
    my $form = $self->session->form;
    my $url  = $self->session->url;
    my $dbh  = $self->session->db->dbh;
	my $i18n = WebGUI::International->new($self->session, "Asset_UserList");
	my (%var, @users, @profileField_loop, @profileFields);
	my ($user, $sth, $sql, $profileField);

    my $currentUrlWithoutSort = $self->getUrl();
    foreach ($form->param) {
        unless ( $_ ~~ [qw(sortBy sortOrder op func), qr/identifier/i, qr/password/i]) {
            $currentUrlWithoutSort = $url->append($currentUrlWithoutSort, $url->escape($_)
            .'='.$url->escape($form->process($_)));
        }
    }

	$sth = $self->session->db->read(
        "SELECT field.fieldName, field.label, field.sequenceNumber, field.visible, field.fieldType, "
        ."field.dataDefault, field.possibleValues "
        ."FROM userProfileField as field "
		."left join userProfileCategory as category USING(profileCategoryId) "
        ."where !(field.fieldName like '______________________contentPositions')"
		."ORDER BY category.sequenceNumber, field.sequenceNumber");
	while ($profileField = $sth->hashRef){
        my $label = WebGUI::Operation::Shared::secureEval($self->session,$profileField->{label});
        my $fieldName = $profileField->{fieldName};
        my $sortByURL = $url->append($currentUrlWithoutSort,'sortBy='.$url->escape($fieldName));
        if ($form->process('sortOrder') eq 'asc' && $form->process('sortBy') eq $fieldName){
            $sortByURL = $url->append($sortByURL,'sortOrder=desc');
        }
        else{
            $sortByURL = $url->append($sortByURL,'sortOrder=asc');
        }
  		push(@profileFields, {
    				"fieldName"=>$fieldName,
	    			"label"=>$label,
		    		"sequenceNumber"=>$profileField->{sequenceNumber},
                    "visible"=>$profileField->{visible},
                    "fieldType"=>$profileField->{fieldType},
                    "dataDefault"=>$profileField->{dataDefault},
			    	});
        if($profileField->{visible}){
            push (@profileField_loop, {
                "profileField_label"=>$label,
                "profileField_sortByURL"=>$sortByURL,
            });
        }
        unless($self->showOnlyVisibleAsNamed && $profileField->{visible} != 1){
            $var{'profileField_'.$fieldName.'_label'} = $label;
            $var{'profileField_'.$fieldName.'_sortByURL'} = $sortByURL;
        }
        # create field specific templ_vars for search
        my %formElementProperties = %{$profileField};

        $formElementProperties{value} = $form->process('search_'.$fieldName);
        $formElementProperties{name} = 'search_'.$fieldName;
        $var{'search_'.$fieldName.'_form'} = $self->getFormElement(\%formElementProperties);
        $var{'search_'.$fieldName.'_text'} = WebGUI::Form::Text($self->session, {
            -name   => 'search_'.$fieldName,
            -value  => scalar $form->process('search_'.$fieldName),
        }); 

        $formElementProperties{value} = $form->process('search_Exact'.$fieldName);
        $formElementProperties{name} = 'searchExact_'.$fieldName;
        $var{'searchExact_'.$fieldName.'_form'} = $self->getFormElement(\%formElementProperties);
        $var{'searchExact_'.$fieldName.'_text'} = WebGUI::Form::Text($self->session, {
            -name   => 'searchExact_'.$fieldName,
            -value  => scalar $form->process('searchExact_'.$fieldName),
        });

        $var{'includeInSearch_'.$fieldName.'_hidden'} =  WebGUI::Form::Hidden($self->session, {
            -name   => 'includeInSearch_'.$fieldName,
            -value  => '1',
        });

        $var{'includeInSearch_'.$fieldName.'_checkBox'} = WebGUI::Form::Checkbox($self->session, {
            -name   => 'includeInSearch_'.$fieldName,
            -value  => '1',
            -checked=> scalar $form->process('includeInSearch_'.$fieldName),
        });
	}
    
    # Query user profile data. Exclude the visitor account and users that have been deactivated.
	$sql = "select distinct users.userId, users.userName, users.publicProfile ";
	# Include remaining profile fields in the query
	foreach my $profileField (@profileFields){
    	$sql .= ", " . $dbh->quote_identifier($profileField->{fieldName});
	}
	$sql .= " from users";
	$sql .= " left join userProfileData using(userId) where users.userId != '1' and users.status = 'active'";
	
	my $constraint;
    my @profileSearchFields = ();
    my $searchType = lc $form->process('searchType') eq 'and' ? 'and' : 'or';
	if ($form->process('search')){
        # Normal search with one keyword takes precedence over other search options
        if($form->process('limitSearch')){
            # Normal search with one keyword in a limited number of fields
            foreach my $profileField (@profileFields){
                if ($form->process('includeInSearch_'.$profileField->{fieldName})){    
                    push(@profileSearchFields, $dbh->quote_identifier($profileField->{fieldName})
                    .' like '. $dbh->quote('%'.$form->process('search').'%'));
                }
            }
        }
        else{
            # Normal search with one keyword in all fields
    		$constraint = "(".join(' or ', map {$dbh->quote_identifier($_->{fieldName})
            .' like '.$dbh->quote('%'.$form->process('search').'%')} @profileFields).")";	
        }
	}
    elsif ($form->process('searchExact')){
        # Exact search with one keyword
        if($form->process('limitSearch')){
            # Exact search with one keyword in a limited number of fields
            foreach my $profileField (@profileFields){
                if ($form->process('includeInSearch_'.$profileField->{fieldName})){
                    push(@profileSearchFields,$dbh->quote_identifier($profileField->{fieldName})
                    .' like '.$dbh->quote($form->process('search')));
                }
            }
        }
        else{
            # Exact search with one keyword in all fields
            $constraint = "(".join(' or ', map {$dbh->quote_identifier($_->{fieldName})
            .' like ' . $dbh->quote($form->process('searchExact'))} @profileFields).")";
        }
    }
    else{
        # Mixed normal and exact search with different queries for each field.
    	foreach my $profileField (@profileFields){
            # Exact search has precedence over normal search
            if ($form->process('searchExact_'.$profileField->{fieldName})){
                push(@profileSearchFields,$dbh->quote_identifier($profileField->{fieldName})
                    .' like '. $dbh->quote($form->process('searchExact_'.$profileField->{fieldName})));
            }
            elsif ($form->process('search_'.$profileField->{fieldName})){
                push(@profileSearchFields,$dbh->quote_identifier($profileField->{fieldName})
                    .' like '. $dbh->quote('%'.$form->process('search_'.$profileField->{fieldName})));
            }
	    }
	}
    if (scalar(@profileSearchFields) > 0){
        $constraint = '('.join(' '.$searchType.' ',@profileSearchFields).')';
    }
	$sql .= " and ".$constraint if ($constraint);

	my $sortBy    = $form->process('sortBy')    || $self->sortBy    || 'users.username';
	my $sortOrder = $form->process('sortOrder') || $self->sortOrder || 'asc';
    if (lc $sortOrder ne 'desc') {
        $sortOrder = 'asc';
    }

    my @sortByUserProperties = ('dateCreated', 'lastUpdated', 'karma', 'userId');
    if( $sortBy ~~ @sortByUserProperties ){
            $sortBy = 'users.'.$sortBy;
    }
    $sortBy = join '.', map { $dbh->quote_identifier($_) } split /\./, $sortBy;
	$sql .= " order by ".$sortBy." ".$sortOrder;

	my $paginatePage = $form->param('pn') || 1;
	my $currentUrl = $self->getUrl();
	foreach ($form->param) {
        unless ($_ eq "pn" || $_ eq "op" || $_ eq "func" || $_ =~ /identifier/i || $_ =~ /password/i) {
            $currentUrl = $url->append($currentUrl, $url->escape($_)
            .'='.$url->escape($form->process($_)));
        }
    }

	my $p = WebGUI::Paginator->new($self->session,$currentUrl,$self->usersPerPage, undef, $paginatePage);

	$sth = $self->session->db->read($sql);
	my @visibleUsers;
	while (my $user = $sth->hashRef){
		my $showGroupId = $self->showGroupId;
		if ($showGroupId eq '0' || ($showGroupId && $self->isInGroup($showGroupId,$user->{userId}))){
			unless ($self->hideGroupId ne '0' && $self->isInGroup($self->hideGroupId,$user->{userId})){
				push(@visibleUsers,$user);
			}
		}
	}
	$p->setDataByArrayRef(\@visibleUsers);
	my $users = $p->getPageData($paginatePage);
	foreach my $user (@$users){
        my $userObject = WebGUI::User->new($self->session,$user->{userId});
	    if ($self->overridePublicProfile || $userObject->profileIsViewable()) {
		    my (@profileFieldValues);
			my %userProperties;
			foreach my $profileField (@profileFields){
                # Assign field name
                my $profileFieldName = $profileField->{fieldName};
                $profileFieldName =~ s/ /_/g;
                $profileFieldName =~ s/\./_/g;

				if ($userObject->canViewField($profileField->{fieldName},$self->session->user)){
                    # Assign value
                    my $value = $user->{$profileField->{fieldName}};
                    # Assign default value if not available
                    $value = $profileField->{dataDefault} if $value eq '';
                    # Handle special case of alias, which does not have a default value but is set to the username by default
                    $value = $user->{userName} if ($profileFieldName eq 'alias' && $value eq '');
                    my %profileFieldValues;
                    if ((ucfirst $profileField->{fieldType}) ~~ [qw(File Image)] && $value ne ''){
                        my $file = WebGUI::Form::DynamicField->new($self->session,
                            fieldType=>$profileField->{fieldType},
                            value=>$value
                        )->getValueAsHtml();
                        $profileFieldValues{profile_file} = $file;
                        $userProperties{'user_profile_'.$profileFieldName.'_file'} = $file;
                    }
                    $profileFieldValues{profile_value} = $value;
                    if($profileField->{visible}){
    					push (@profileFieldValues, \%profileFieldValues);
                    }
                    unless($self->showOnlyVisibleAsNamed && $profileField->{visible} != 1){
                        $userProperties{'user_profile_'.$profileFieldName.'_value'} = $value;
                    }
				}
                else{
                    push (@profileFieldValues, {
                        "profile_notPublic"=>1,
                    });
                    $userProperties{'user_profile_'.$profileFieldName.'_notPublic'} = 1;
                }
			}
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
    $p->appendTemplateVars(\%var);

	$var{numberOfProfileFields} = scalar(@profileFields);

	$var{profileField_loop}     = \@profileField_loop;
	$var{user_loop}             = \@users;
    $var{alphabetSearch_loop}   = $self->getAlphabetSearchLoop($self->alphabetSearchField,$self->alphabet);

	$var{searchFormHeader}      = WebGUI::Form::formHeader($self->session,{action => $self->getUrl, method => 'GET', });
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
        value   =>  scalar $form->process("search"),
    });
        

	my $out = $self->processTemplate(\%var,$self->templateId);
	return $out;
}


__PACKAGE__->meta->make_immutable;
1;
