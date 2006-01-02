package WebGUI::Asset::Wobject::Matrix;
 
use strict;
use Tie::IxHash;
use WebGUI::DateTime;
use WebGUI::Form;
use WebGUI::FormProcessor;
use WebGUI::HTMLForm;
use WebGUI::HTTP;
use WebGUI::Mail;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::User;
use WebGUI::Utility;
use WebGUI::Asset::Wobject;
use WebGUI::Asset::Wobject::Collaboration;

 
our @ISA = qw(WebGUI::Asset::Wobject);
 
#-------------------------------------------------------------------
sub definition {
        my $class = shift;
        my $definition = shift;
        push(@{$definition}, {
		icon=>'matrix.gif',
                tableName=>'Matrix',
                className=>'WebGUI::Asset::Wobject::Matrix',
		assetName=>WebGUI::International::get('assetName',"Asset_Matrix"),
                properties=>{
			categories=>{
                                defaultValue=>"Features\nBenefits",
				fieldType=>"textarea"
                                },
			maxComparisons=>{
				defaultValue=>10,
				fieldName=>"integer"
				},
                        templateId=>{
                                defaultValue=>"matrixtmpl000000000001",
				fieldType=>"template"
                                },
                        searchTemplateId=>{
                                defaultValue=>"matrixtmpl000000000005",
				fieldType=>"template"
                                },
                        detailTemplateId=>{
                                defaultValue=>"matrixtmpl000000000003",
				fieldType=>"template"
                                },
                        ratingDetailTemplateId=>{                                
				defaultValue=>"matrixtmpl000000000004",
				fieldType=>"template"
                                },                  
                        compareTemplateId=>{
                                defaultValue=>"matrixtmpl000000000002",
				fieldType=>"template"
                                },
			privilegedGroup=>{
				defaultValue=>'2',
				fieldType=>"group",
				},
			groupToRate=>{
				defaultValue=>'2',
				fieldType=>"group",
				},
			groupToAdd=>{
				defaultValue=>'2',
				fieldType=>"group",
				},
			maxComparisonsPrivileged=>{
				defaultValue=>10,
				fieldType=>"integer",
				},
			ratingTimeout=>{
				defaultValue=>60*60*24*365,
				fieldType=>"interval"
				},
			ratingTimeoutPrivileged=>{
				defaultValue=>60*60*24*365,
				fieldType=>"interval"
				}
                        }
                });
        return $class->SUPER::definition($definition);
}

#-------------------------------------------------------------------
sub duplicate {
	return "";
}


#-------------------------------------------------------------------
sub formatURL {
	my $self = shift;
	my $func = shift;
	my $listingId = shift;
	my $url = $self->getUrl("func=".$func."&listingId=".$listingId);
	return $url;
}


#-------------------------------------------------------------------
sub getCategories {
	my $self = shift;
	my $cat = $self->getValue("categories");
	$cat =~ s/\r//g;
	chomp($cat);
	my @categories = split(/\n/,$cat);
	return @categories;
}

#-------------------------------------------------------------------
sub getCompareForm {
	my $self = shift;
	my @ids = @_;
	my $form = WebGUI::Form::formHeader({action=>$self->getUrl})
		.WebGUI::Form::submit({
			value=>"compare"
			})
		."<br />"
		."<br />"
		.WebGUI::Form::hidden({
			name=>"func",
			value=>"compare"
			})
		.WebGUI::Form::checkList({
			name=>"listingId",
			vertical=>1,
			value=>\@ids,
			options=>$self->session->db->buildHashRef("select listingId, concat('<a href=\\\"".
				$self->getUrl("func=viewDetail")."&amp;listingId=',listingId,'\\\">', productName,'</a>') from Matrix_listing 
				where assetId=".$self->session->db->quote($self->getId)." and status='approved' order by productName")
			})
		."<br />"
		.WebGUI::Form::submit({
			value=>"compare"
			})
		."</form>";
	return $form;
}


#-------------------------------------------------------------------
sub hasRated {
	my $self = shift;
	my $listingId = shift;
	return 1 unless (WebGUI::Grouping::isInGroup($self->get("groupToRate")));
	my $ratingTimeout = WebGUI::Grouping::isInGroup($self->get("privilegedGroup")) ? $self->get("ratingTimeoutPrivileged") : $self->get("ratingTimeout");
	my ($hasRated) = $self->session->db->quickArray("select count(*) from Matrix_rating where 
		((userId=".$self->session->db->quote($self->session->user->profileField("userId"))." and userId<>'1') or (userId='1' and ipAddress=".$self->session->db->quote($self->session->env->get("HTTP_X_FORWARDED_FOR")).")) and 
		listingId=".$self->session->db->quote($listingId)." and timeStamp>".(WebGUI::DateTime::time()-$ratingTimeout));
	return $hasRated;
}

#-------------------------------------------------------------------
sub incrementCounter {
	my $listingId = shift;
	my $counter = shift;
	my ($lastIp) = $self->session->db->quickArray("select ".$counter."LastIp from Matrix_listing where listingId = ".$self->session->db->quote($listingId));
	unless ($lastIp eq $self->session->env->get("HTTP_X_FORWARDED_FOR")) {
		$self->session->db->write("update Matrix_listing set $counter=$counter+1, ".$counter."LastIp=".$self->session->db->quote($self->session->env->get("HTTP_X_FORWARDED_FOR"))." where listingId=".$self->session->db->quote($listingId));
	}
}

#-------------------------------------------------------------------
sub purge {
       my $self = shift;
       $self->session->db->write("delete from Matrix_listing where assetId=".$self->session->db->quote($self->getId));
       $self->session->db->write("delete from Matrix_listingData where assetId=".$self->session->db->quote($self->getId));
       $self->session->db->write("delete from Matrix_field where assetId=".$self->session->db->quote($self->getId));
       $self->session->db->write("delete from Matrix_rating where assetId=".$self->session->db->quote($self->getId));
       $self->session->db->write("delete from Matrix_ratingSummary where assetId=".$self->session->db->quote($self->getId));
       $self->SUPER::purge;
}

#-------------------------------------------------------------------
sub setRatings { 
	my $self = shift;
	my $listingId = shift;
	my $ratings = shift;
	foreach my $category ($self->getCategories) {
		if ($ratings->{$category}) {
			$self->session->db->write("insert into Matrix_rating (userId, category, rating, timeStamp, listingId,ipAddress, assetId) values (
				".$self->session->db->quote($self->session->user->profileField("userId")).", ".$self->session->db->quote($category).", ".$self->session->db->quote($ratings->{$category}).", ".WebGUI::DateTime::time()
				.", ".$self->session->db->quote($listingId).", ".$self->session->db->quote($self->session->env->get("HTTP_X_FORWARDED_FOR")).",".$self->session->db->quote($self->getId).")");
		}
		my $sql = "from Matrix_rating where listingId=".$self->session->db->quote($listingId)." and category=".$self->session->db->quote($category);
		my ($sum) = $self->session->db->quickArray("select sum(rating) $sql");
		my ($count) = $self->session->db->quickArray("select count(*) $sql");
		my $half = round($count/2);
		my $mean = $sum / ($count || 1);
		my ($median) = $self->session->db->quickArray("select rating $sql limit $half,$half");
		$self->session->db->write("replace into Matrix_ratingSummary  (listingId, category, meanValue, medianValue, countValue,assetId) values (
			".$self->session->db->quote($listingId).", ".$self->session->db->quote($category).", $mean, ".$self->session->db->quote($median).", $count, ".$self->session->db->quote($self->getId).")");
	}
}

#-------------------------------------------------------------------
sub www_approveListing {
	my $self = shift;
        return WebGUI::Privilege::insufficient() unless($self->canEdit);
	my $listing = $self->session->db->getRow("Matrix_listing","listingId",$self->session->form->process("listingId"));
	$self->session->db->write("update Matrix_listing set status='approved' where listingId=".$self->session->db->quote($self->session->form->process("listingId")));
	WebGUI::MessageLog::addEntry($listing->{maintainerId},"","New Listing Approved","Your new listing, ".$listing->{productName}.", has been approved.",
		$self->formatURL("viewDetail",$self->session->form->process("listingId")),"notice");
	WebGUI::MessageLog::completeEntry($self->session->form->process("mlog"));
	return $self->www_viewDetail;
}


#-------------------------------------------------------------------
sub www_click {
	my $self = shift;
	incrementCounter($self->session->form->process("listingId"),"clicks");
	my $listing = $self->session->db->getRow("Matrix_listing","listingId",$self->session->form->process("listingId"));
	if ($self->session->form->process("m")) {
		WebGUI::HTTP::setRedirect($listing->{manufacturerUrl});
	} else {
		WebGUI::HTTP::setRedirect($listing->{productUrl});
	}
	return "";
}


#-------------------------------------------------------------------
sub www_compare {
	my $self = shift;
	my @cmsList = @_;
	unless (scalar(@cmsList)) {
		@cmsList = $self->session->form->checkList("listingId");
	}
	my ( %var, @prodcol, @datecol);
	my $max = WebGUI::Grouping::isInGroup($self->get("privilegedGroup")) ? $self->get("maxComparisonsPrivileged") : $self->get("maxComparisons");
	$var{isTooMany} = (scalar(@cmsList)>$max);
	$var{isTooFew} = (scalar(@cmsList)<2);
	$var{'compare.form'} = $self->getCompareForm(@cmsList);
	if ($var{isTooMany} || $var{isTooFew}) {
		return $self->processStyle($self->processTemplate(\%var,$self->get("compareTemplateId")));
	}
	foreach my $cms (@cmsList) {
		incrementCounter($cms,"compares");
		my $data = $self->session->db->quickHashRef("select listingId, productName, versionNumber, lastUpdated
			from Matrix_listing where listingId=".$self->session->db->quote($cms));
		push(@prodcol, {
			name=>$data->{productName} || "__untitled__",
			version=>$data->{versionNumber},
			url=>$self->formatURL("viewDetail",$cms)
			});
		push(@datecol, {
			lastUpdated=>WebGUI::DateTime::epochToHuman($data->{lastUpdated},"%z")
			});
	}
	$var{product_loop} = \@prodcol;
	$var{lastupdated_loop} = \@datecol;
	my @categoryloop;
	foreach my $category ($self->getCategories()) {
		my @rowloop;
		my $select = "select a.label, a.description";
		my $from = "from Matrix_field a";
		my $tableCount = "b";
		foreach my $cms (@cmsList) {
			$select .= ", ".$tableCount.".value";
			$from .= " left join Matrix_listingData ".$tableCount." on a.fieldId="
				.$tableCount.".fieldId and ".$tableCount.".listingId=".$self->session->db->quote($cms);
			$tableCount++;
		}
		my $sth = $self->session->db->read("$select $from where a.category=".$self->session->db->quote($category)." order by a.label");
		while (my @row = $sth->array) {
			my @columnloop;
			my $first = 1;
			foreach my $value (@row) {
				my $desc = "";
				if ($first) {
					$desc = $row[1];
					shift(@row);
					$desc =~ s/\n//g;
					$desc =~ s/\r//g;
					$desc =~ s/'/\\\'/g;
					$desc =~ s/"/\&quot;/g;
					$first = 0;
				}
				my $class = lc($value);
				$class =~ s/\s/_/g;
				$class =~ s/\W//g;
				push(@columnloop,{
					value=>$value,
					class=>$class,
					description=>$desc
					});
			}
			push(@rowloop,{
				column_loop=>\@columnloop
				});
		}
		$sth->finish;
		push(@categoryloop,{
			category=>$category,
			columnCount=>$#cmsList+2,
			row_loop=>\@rowloop
			});
	}		
	$var{category_loop} = \@categoryloop;
	return $self->processStyle($self->processTemplate(\%var,$self->get("compareTemplateId")));
}

#-------------------------------------------------------------------
sub www_copy {
	return WebGUI::International::get('no copy','Asset_Matrix');
}

#-------------------------------------------------------------------
sub www_deleteListing {
	my $self = shift;
	my $output = sprintf WebGUI::International::get('delete listing confirmation','Asset_Matrix'),
		$self->getUrl("func=deleteListingConfirm&listingId=".$self->session->form->process("listingId")),
		$self->formatURL("viewDetail",$self->session->form->process("listingId"));
	return $self->processStyle($output);
}

#-------------------------------------------------------------------
sub www_deleteListingConfirm {
	my $self = shift;
        return WebGUI::Privilege::insufficient() unless($self->canEdit);
	my $listing = $self->session->db->getRow("Matrix_listing","listingId",$self->session->form->process("listingId"));
	WebGUI::Asset::Wobject::Collaboration->new($listing->{forumId})->purge;
	$self->session->db->write("delete from Matrix_listing where listingId=".$self->session->db->quote($self->session->form->process("listingId")));
	$self->session->db->write("delete from Matrix_listingData where listingId=".$self->session->db->quote($self->session->form->process("listingId")));
	$self->session->db->write("delete from Matrix_rating where listingId=".$self->session->db->quote($self->session->form->process("listingId")));
	$self->session->db->write("delete from Matrix_ratingSummary where listingId=".$self->session->db->quote($self->session->form->process("listingId")));
	WebGUI::MessageLog::addEntry($listing->{maintainerId},"","Listing Deleted","Your listing, ".$listing->{productName}.", has been deleted from the matrix.","","notice");
	WebGUI::MessageLog::completeEntry($self->session->form->process("mlog"));
	return "";
}

#-------------------------------------------------------------------
sub getEditForm {
        my $self = shift;
        my $tabform = $self->SUPER::getEditForm();
	$tabform->getTab("properties")->textarea(
			-name=>"categories",
			-label=>WebGUI::International::get('categories', 'Asset_Matrix'),
			-hoverHelp=>WebGUI::International::get('categories description', 'Asset_Matrix'),
			-value=>$self->getValue("categories"),
			-subtext=>WebGUI::International::get('categories subtext', 'Asset_Matrix'),
			);
	$tabform->getTab("properties")->integer(
			-name=>"maxComparisons",
			-label=>WebGUI::International::get("max comparisons","Asset_Matrix"),
			-hoverHelp=>WebGUI::International::get("max comparisons description","Asset_Matrix"),
			-value=>$self->getValue("maxComparisons")
			);
	$tabform->getTab("properties")->integer(
			-name=>"maxComparisonsPrivileged",
			-label=>WebGUI::International::get("max comparisons privileged","Asset_Matrix"),
			-hoverHelp=>WebGUI::International::get("max comparisons privileged description","Asset_Matrix"),
			-value=>$self->getValue("maxComparisonsPrivileged")
			);
	$tabform->getTab("properties")->interval(
			-name=>"ratingTimeout",
			-label=>WebGUI::International::get("rating timeout","Asset_Matrix"),
			-hoverHelp=>WebGUI::International::get("rating timeout description","Asset_Matrix"),
			-value=>$self->getValue("ratingTimeout")
			);
	$tabform->getTab("properties")->interval(
			-name=>"ratingTimeoutPrivileged",
			-label=>WebGUI::International::get("rating timeout privileged","Asset_Matrix"),
			-hoverHelp=>WebGUI::International::get("rating timeout privileged description","Asset_Matrix"),
			-value=>$self->getValue("ratingTimeoutPrivileged")
			);
	$tabform->getTab("security")->group(
			-name=>"groupToAdd",
			-label=>WebGUI::International::get("group to add","Asset_Matrix"),
			-hoverHelp=>WebGUI::International::get("group to add description","Asset_Matrix"),
			-value=>[$self->getValue("groupToAdd")]
			);
	$tabform->getTab("security")->group(
			-name=>"privilegedGroup",
			-label=>WebGUI::International::get("privileged group","Asset_Matrix"),
			-hoverHelp=>WebGUI::International::get("privileged group description","Asset_Matrix"),
			-value=>[$self->getValue("privilegedGroup")]
			);
	$tabform->getTab("security")->group(
			-name=>"groupToRate",
			-label=>WebGUI::International::get("rating group","Asset_Matrix"),
			-hoverHelp=>WebGUI::International::get("rating group description","Asset_Matrix"),
			-value=>[$self->getValue("groupToRate")]
			);
	$tabform->getTab("display")->template(
			-name=>"templateId",
			-value=>$self->getValue("templateId"),
			-label=>WebGUI::International::get("main template","Asset_Matrix"),
			-hoverHelp=>WebGUI::International::get("main template description","Asset_Matrix"),
			-namespace=>"Matrix"
			);
	$tabform->getTab("display")->template(
			-name=>"detailTemplateId",
			-value=>$self->getValue("detailTemplateId"),
			-label=>WebGUI::International::get("detail template","Asset_Matrix"),
			-hoverHelp=>WebGUI::International::get("detail template description","Asset_Matrix"),
			-namespace=>"Matrix/Detail"
			);
	$tabform->getTab("display")->template(
			-name=>"ratingDetailTemplateId",
			-value=>$self->getValue("ratingDetailTemplateId"),
			-label=>WebGUI::International::get("rating detail template","Asset_Matrix"),
			-hoverHelp=>WebGUI::International::get("rating detail template description","Asset_Matrix"),
			-namespace=>"Matrix/RatingDetail"
			);
	$tabform->getTab("display")->template(
			-name=>"searchTemplateId",
			-value=>$self->getValue("searchTemplateId"),
			-label=>WebGUI::International::get("search template","Asset_Matrix"),
			-hoverHelp=>WebGUI::International::get("search template description","Asset_Matrix"),
			-namespace=>"Matrix/Search"
			);
	$tabform->getTab("display")->template(
			-name=>"compareTemplateId",
			-value=>$self->getValue("compareTemplateId"),
			-label=>WebGUI::International::get("compare template","Asset_Matrix"),
			-hoverHelp=>WebGUI::International::get("compare template description","Asset_Matrix"),
			-namespace=>"Matrix/Compare"
			);
	return $tabform;
}

#-------------------------------------------------------------------
sub www_edit {  
        my $self = shift;
        return WebGUI::Privilege::insufficient() unless $self->canEdit;
        return $self->getAdminConsole->render($self->getEditForm->print,
					WebGUI::International::get("edit matrix",'Asset_Matrix'));
}


 
#-------------------------------------------------------------------
sub www_editListing {
        my $self = shift;
        my $listing= $self->session->db->getRow("Matrix_listing","listingId",$self->session->form->process("listingId"));
	return WebGUI::International('no edit rights','Asset_Matrix') unless (($self->session->form->process("listingId") eq "new" && WebGUI::Grouping::isInGroup($self->get("groupToAdd"))) || $self->session->user->profileField("userId") eq $listing->{maintainerId} || $self->canEdit);
        my $f = WebGUI::HTMLForm->new(-action=>$self->getUrl);
        $f->hidden(
                -name=>"func",
                -value=>"editListingSave"
                );
        $f->hidden(
                -name=>"listingId",
                -value=>$self->session->form->process("listingId")
                );
	$f->text(
		-name=>"productName",
		-value=>$listing->{productName},
		-label=>WebGUI::International::get('product name','Asset_Matrix'),
		-maxLength=>25
		);
	$f->text(
		-name=>"versionNumber",
		-value=>$listing->{versionNumber},
		-label=>WebGUI::International::get('version number','Asset_Matrix'),
		);
	$f->url(
		-name=>"productUrl",
		-value=>$listing->{productUrl},
		-label=>WebGUI::International::get('product url','Asset_Matrix'),
		);
	$f->text(
		-name=>"manufacturerName",
		-value=>$listing->{manufacturerName},
		-label=>WebGUI::International::get('manufacturer name','Asset_Matrix'),
		);
	$f->url(
		-name=>"manufacturerUrl",
		-value=>$listing->{manufacturerUrl},
		-label=>WebGUI::International::get('manufacturer url','Asset_Matrix'),
		);
	$f->textarea(
		-name=>"description",
		-value=>$listing->{description},
		-label=>WebGUI::International::get('description','Asset_Matrix'),
		);
        if ($self->canEdit) {
		$f->selectBox(
			-name=>"maintainerId",
			-value=>[$listing->{maintainerId}],
			-label=>WebGUI::International::get('listing maintainer','Asset_Matrix'),
			-options=>$self->session->db->buildHashRef("select userId,username from users order by username")
			);
	}
	my %goodBad = (
		"No"          => WebGUI::International::get("no",'Asset_Matrix'),
		"Yes"         => WebGUI::International::get("yes",'Asset_Matrix'),
		"Free Add On" => WebGUI::International::get("free",'Asset_Matrix'),
		"Costs Extra" => WebGUI::International::get("extra",'Asset_Matrix'),
		"Limited"     => WebGUI::International::get("limited",'Asset_Matrix'),
	);
	foreach my $category ($self->getCategories()) {
		$f->raw('<tr><td colspan="2"><b>'.$category.'</b></td></tr>');
		my $a;
		if ($self->session->form->process("listingId") ne "new") {
			$a = $self->session->db->read("select a.name, a.fieldType, a.defaultValue, a.description, a.label, b.value, a.fieldId
				from Matrix_field a left join Matrix_listingData b on a.fieldId=b.fieldId and 
				listingId=".$self->session->db->quote($self->session->form->process("listingId"))."  where 
				a.category=".$self->session->db->quote($category)." order by a.label");
		} else {
			$a = $self->session->db->read("select name, fieldType, defaultValue, description, label, fieldId
				from Matrix_field where category=".$self->session->db->quote($category)." and  assetId=".$self->session->db->quote($self->getId));
		}
		while (my $field = $a->hashRef) {
			if ($field->{fieldType} eq "text") {
				$f->text(
					-name=>$field->{name},
					-value=>$field->{value} || $field->{defaultValue},
					-label=>$field->{label},
					-subtext=>"<br />".$field->{description}
					);
			} elsif ($field->{fieldType} eq "goodBad") {
				my $value = ($field->{value} || $field->{defaultValue} || "No");
				$f->selectBox(
					-name=>$field->{name},
					-value=>[$value],
					-label=>$field->{label},
					-options=>\%goodBad,
					-subtext=>"<br />".$field->{description}
					);
			} elsif ($field->{fieldType} eq "textarea") {
				$f->textarea(
					-name=>$field->{name},
					-value=>$field->{value} || $field->{defaultValue},
					-label=>$field->{label},
					-subtext=>"<br />".$field->{description}
					);
			} elsif ($field->{fieldType} eq "url") {
				$f->url(
					-name=>$field->{name},
					-value=>$field->{value} || $field->{defaultValue},
					-label=>$field->{label},
					-subtext=>"<br />".$field->{description}
					);
			} elsif ($field->{fieldType} eq "combo") {
				my $value = ($field->{value} || $field->{defaultValue});
				$f->combo(
					-name=>$field->{name},
					-value=>[$value],
					-label=>$field->{label},
					-options=>$self->session->db->buildHashRef("select distinct value,value from Matrix_listingData 
						where fieldId=".$self->session->db->quote($field->{fieldId})." and
						 assetId=".$self->session->db->quote($self->getId)." order by value"),
					-subtext=>"<br />".$field->{description}
					);
			}
			
		}
		$a->finish;
	}
        $f->submit;
        return $self->processStyle(WebGUI::International::get('edit listing','Asset_Matrix').$f->print);
}
 
 
#-------------------------------------------------------------------
sub www_editListingSave {
        my $self = shift;
        my $listing = $self->session->db->getRow("Matrix_listing","listingId",$self->session->form->process("listingId"));
	return WebGUI::International('no edit rights','Asset_Matrix') unless (($self->session->form->process("listingId") eq "new" && WebGUI::Grouping::isInGroup($self->get("groupToAdd"))) || $self->session->user->profileField("userId") eq $listing->{maintainerId} || $self->canEdit);
	my %data = (
		listingId => $self->session->form->process("listingId"),
		lastUpdated => WebGUI::DateTime::time(),
		productName => $self->session->form->process("productName"),
		productUrl => $self->session->form->process("productUrl"),
		manufacturerName => $self->session->form->process("manufacturerName"),
		manufacturerUrl => $self->session->form->process("manufacturerUrl"),
		description => $self->session->form->process("description"),
		versionNumber=>$self->session->form->process("versionNumber")
		);
	my $isNew = 0;
	if ($self->session->form->process("listingId") eq "new") {
		$data{maintainerId} = $self->session->user->profileField("userId") if ($self->session->form->process("listingId") eq "new");
		my $forum = $self->addChild({
			className=>"WebGUI::Asset::Wobject::Collaboration",
			title=>$self->session->form->process("productName"),
			menuTitle=>$self->session->form->process("productName"),
			url=>$self->session->form->process("productName"),
			groupIdView=>7,
			groupIdEdit=>3,
			startDate=>time(),
			endDate=>time()+60*60*24*365*15,
                        displayLastReply => 0,
                        allowReplies => 1,
                        threadsPerPage => 30,
                        postsPerPage => 10,
                        archiveAfter =>31536000,
        		useContentFilter => 1,
                        filterCode => 'javascript',
                        richEditor => "PBrichedit000000000002",
                        attachmentsPerPost => 0,
                        editTimeout => 3600,
                        addEditStampToPosts => 0,
                        usePreview => 1,
                        sortOrder => 'desc',
                        sortBy => 'dateUpdated',
                        notificationTemplateId =>'PBtmpl0000000000000027',
                        searchTemplateId =>'PBtmpl0000000000000031',
                        postFormTemplateId =>'PBtmpl0000000000000029',
                        threadTemplateId =>'PBtmpl0000000000000032',
   			collaborationTemplateId =>'PBtmpl0000000000000026',
                        karmaPerPost =>0,
                        karmaSpentToRate => 0,
                        karmaRatingMultiplier => 0,
                        moderatePosts => 0,
                        moderateGroupId => '4',
                        postGroupId => '7'
			});
		$data{forumId} = $forum->getId;
		$data{status} = "pending";
		$isNew = 1;
	}
	$data{maintainerId} = $self->session->form->process("maintainerId") if ($self->canEdit);
	$data{assetId} = $self->getId;
	$self->session->form->process("listingId") = $self->session->db->setRow("Matrix_listing","listingId",\%data);
	if ($data{status} eq "pending") {
		WebGUI::MessageLog::addEntry($self->get("ownerUserId"),$self->get("groupIdEdit"),"New Listing Added","A new listing, ".$data{productName}.", is waiting to be added.",
			$self->session->url->getSiteURL()."/".$self->formatURL("viewDetail",$self->session->form->process("listingId")),"pending");
	}
	my $a = $self->session->db->read("select fieldId, name, fieldType from Matrix_field");
	while (my ($id, $name, $type) = $a->array) {
		my $value;
		if ($type eq "goodBad") {
			$value = $self->session->form->selectBox($name);
		} else {
			$value = $self->session->form->process($name,$type);
		}
		$self->session->db->write("replace into Matrix_listingData (assetId, listingId, fieldId, value) values (
			".$self->session->db->quote($self->getId).", ".$self->session->db->quote($self->session->form->process("listingId")).", ".$self->session->db->quote($id).", ".$self->session->db->quote($value).")");
	}
	$a->finish;
        return $self->www_viewDetail;
}
 
#-------------------------------------------------------------------
sub www_editField {
	my $self = shift;
        return WebGUI::Privilege::insufficient() unless($self->canEdit);
        my $field = $self->session->db->getRow("Matrix_field","fieldId",$self->session->form->process("fieldId"));
        my $f = WebGUI::HTMLForm->new(-action=>$self->getUrl);
        $f->hidden(
                -name=>"func",
                -value=>"editFieldSave"
                );
        $f->hidden(
                -name=>"fieldId",
                -value=>$self->session->form->process("fieldId")
		);
	$f->text(
		-name=>"name",
		-value=>$field->{name},
		-label=>WebGUI::International::get('name','Asset_Matrix'),
		);
	$f->text(
		-name=>"label",
		-value=>$field->{label},
		-label=>WebGUI::International::get('label','Asset_Matrix'),
		);
	$f->selectBox(
		-name=>"fieldType",
		-value=>[$field->{fieldType}],
		-label=>WebGUI::International::get('type','Asset_Matrix'),
		-options=>{
			'goodBad'  => WebGUI::International::get('good bad','Asset_Matrix'),
			'text'     => WebGUI::International::get('text','Asset_Matrix'),
			'url'      => WebGUI::International::get('url','Asset_Matrix'),
			'textarea' => WebGUI::International::get('text area','Asset_Matrix'),
			'combo'    => WebGUI::International::get('combo','Asset_Matrix'),
			}
		);
	$f->textarea(
		-name=>"description",
		-value=>$field->{description},
		-label=>WebGUI::International::get('description','Asset_Matrix'),
		);
	$f->text(
		-name=>"defaultValue",
		-value=>$field->{defaultValue},
		-label=>WebGUI::International::get('default value','Asset_Matrix'),
		);
	my %cats;
	foreach my $category ($self->getCategories) {
		$cats{$category} = $category;
	}
	$f->selectBox(
		-name=>"category",
		-value=>[$field->{category}],
		-label=>WebGUI::International::get('category','Asset_Matrix'),
		-options=>\%cats
		);
	$f->submit;
	return $self->processStyle(WebGUI::International::get('edit field','Asset_Matrix').$f->print);
}


#-------------------------------------------------------------------
sub www_editFieldSave {
	my $self = shift;
        return WebGUI::Privilege::insufficient() unless($self->canEdit);
	$self->session->db->setRow("Matrix_field","fieldId",{
		fieldId=>$self->session->form->process("fieldId"),
		name=>$self->session->form->process("name"),
		label=>$self->session->form->process("label"),
		fieldType=>$self->session->form->process("fieldType"),
		description=>$self->session->form->process("description"),
		defaultValue=>$self->session->form->process("defaultValue"),
		category=>$self->session->form->process("category"),
		assetId=>$self->getId
		});
	return $self->www_listFields();
}

#-------------------------------------------------------------------
sub www_listFields {
	my $self = shift;
        return WebGUI::Privilege::insufficient() unless($self->canEdit);
	my $output = sprintf WebGUI::International::get('list fields','Asset_Matrix'),
				$self->getUrl("func=editField&amp;fieldId=new");
	my $sth = $self->session->db->read("select fieldId, label from Matrix_field where assetId=".$self->session->db->quote($self->getId)." order by label");
	while (my ($id, $label) = $sth->array) {
		$output .= '<a href="'.$self->getUrl("func=editField&amp;fieldId=".$id).'">'.$label.'</a><br />';
	}
	$sth->finish;
	return $self->processStyle($output);
}


#-------------------------------------------------------------------
sub www_rate {
	my $self = shift;
	my $hasRated = $self->hasRated($self->session->form->process("listingId"));
	my $sameRating = 1;
	my $first = 1;
	my $lastRating;
	foreach my $category ($self->getCategories) {
		if ($first) {
			$first=0;
		} else {
			if ($lastRating != $session{form}{$category}) {
				$sameRating = 0;
			} 
		}
		$lastRating = $session{form}{$category};
	} 
	return $self->www_viewDetail("",1) if ($hasRated || $sameRating); # Throw out ratings that are all the same number, or if the user rates twice.
	$self->setRatings($self->session->form->process("listingId"),$session{form});
	return $self->www_viewDetail;	
}

#-------------------------------------------------------------------
sub www_search {
	my $self = shift;
	my %var;
	my @list = $self->session->db->buildArray("select listingId from Matrix_listing");
	if ($self->session->form->process("doit")) {
		my $count;
		my $keyword;
		if ($self->session->form->process("keyword")) {
			$keyword = " and (a.value like ".$self->session->db->quote('%'.$self->session->form->process("keyword").'%')." or a.value='Any')";
		}
		my $sth = $self->session->db->read("select name,fieldType from Matrix_field");	
		while (my ($name,$fieldType) = $sth->array) {
			next unless ($session{form}{$name});
			push(@list,0);	
			my $where;
			if ($fieldType ne "goodBad") {
                                $where = "("
					."a.value like ".$self->session->db->quote("%".$session{form}{$name}."%")
					." or a.value='Any'"
                                        #." or a.value<".$self->session->db->quote($session{form}{$name})
					." or a.value='Free'"
					.")";
			} else {
				$where = "a.value<>'no'";
			}
			@list = $self->session->db->buildArray("select a.listingId from Matrix_listingData a left join Matrix_field b 
				on (a.fieldId=b.fieldId)
				where a.listingId in (".$self->session->db->quoteAndJoin(\@list).") and $where and b.name=".$self->session->db->quote($name));
			$count = scalar(@list);
			last unless ($count > 0);
		}
		$sth->finish;
		if ($count > 1 && $count < 11) {
			return $self->www_compare(@list);
		} elsif ($count == 1) {
			return $self->www_viewDetail($list[0]);
		} else {
			my $max = WebGUI::Grouping::isInGroup($self->get("privilegedGroup")) ? $self->get("maxComparisonsPrivileged") : $self->get("maxComparisons");
			$var{isTooMany} = ($count>$max);
			$var{isTooFew} = ($count<2);
		}
	}
	$var{'compare.form'} = $self->getCompareForm(@list);
	$var{'form.header'} = WebGUI::Form::formHeader({action=>$self->getUrl})
		.WebGUI::Form::hidden({
			name=>"doit",
			value=>"1"
			})
		.WebGUI::Form::hidden({
			name=>"func",
			value=>"search"
			});
	$var{'form.footer'} = "</form>";
	$var{'form.keyword'} = WebGUI::Form::text({
		name=>"keyword",
		value=>$self->session->form->process("keyword")
		});
	$var{'form.submit'} = WebGUI::Form::submit({
		value=>"search"
		});
	foreach my $category ($self->getCategories()) {
		my $sth = $self->session->db->read("select name, fieldType, label, description from Matrix_field where category = ".$self->session->db->quote($category)." order by label");	
		my @loop;
		while (my $data = $sth->hashRef) {
			$data->{description} =~ s/\n//g;
			$data->{description} =~ s/\r//g;
			$data->{description} =~ s/'/\\\'/g;
			$data->{description} =~ s/"/\&quot;/g;
			if ($data->{fieldType} ne "goodBad") {
				$data->{form} = WebGUI::Form::text({
					name=>$data->{name},
					value=>$session{form}{$data->{name}}
					});
			} else {
				$data->{form} = WebGUI::Form::checkbox({
					name=>$data->{name},
					value=>"1",
					checked=>$session{form}{$data->{name}}
					});
			}
			push(@loop,$data);
		}
		$sth->finish;
		$var{$self->session->url->urlize($category)."_loop"} = \@loop;
	}
	return $self->processStyle($self->processTemplate(\%var,$self->get("searchTemplateId")));
}


#-------------------------------------------------------------------
sub view {
        my $self = shift;
        my (%var);
	$var{'compare.form'} = $self->getCompareForm;
	$var{'search.url'} = $self->getUrl("func=search");
	$var{'isLoggedIn'} = ($self->session->user->profileField("userId") ne "1");
	$var{'field.list.url'} = $self->getUrl('func=listFields');	
	$var{'listing.add.url'} = $self->formatURL("editListing","new");

	my $data = $self->session->db->quickHashRef("select views, productName, listingId from Matrix_listing 
		 where assetId=".$self->session->db->quote($self->getId)." and status='approved' order by views desc limit 1");
	$var{'best.views.url'} = $self->formatURL("viewDetail",$data->{listingId});
	$var{'best.views.count'} = $data->{views}; 
	$var{'best.views.name'} = $data->{productName}; 
	my $data = $self->session->db->quickHashRef("select compares, productName, listingId from Matrix_listing 
		where assetId=".$self->session->db->quote($self->getId)." and status='approved'  order by compares desc limit 1");
	$var{'best.compares.url'} = $self->formatURL("viewDetail",$data->{listingId});
	$var{'best.compares.count'} = $data->{compares}; 
	$var{'best.compares.name'} = $data->{productName}; 
	my $data = $self->session->db->quickHashRef("select clicks, productName, listingId from Matrix_listing 
		where assetId=".$self->session->db->quote($self->getId)." and status='approved'  order by clicks desc limit 1");
	$var{'best.clicks.url'} = $self->formatURL("viewDetail",$data->{listingId});
	$var{'best.clicks.count'} = $data->{clicks}; 
	$var{'best.clicks.name'} = $data->{productName}; 
	my (@best,@worst);
	foreach my $category ($self->getCategories) {
		my $sql = "
			select 
				Matrix_listing.productName, 
				Matrix_listing.listingId,
				Matrix_ratingSummary.meanValue,
				Matrix_ratingSummary.medianValue,
				Matrix_ratingSummary.countValue
			from 
				Matrix_listing 
			left join
				Matrix_ratingSummary
			on
				Matrix_listing.listingId=Matrix_ratingSummary.listingId and
				Matrix_ratingSummary.category=".$self->session->db->quote($category)."
			where 
				Matrix_listing.assetId=".$self->session->db->quote($self->getId)." and 
				Matrix_listing.status='approved' and
				Matrix_ratingSummary.countValue > 0
			order by 
				Matrix_ratingSummary.meanValue
			";
		my $data = $self->session->db->quickHashRef($sql." desc limit 1");
		push(@best,{
			url=>$self->formatURL("viewDetail",$data->{listingId}),
			category=>$category,
			name=>$data->{productName},
			mean=>$data->{meanValue},
			median=>$data->{medianValue},
			count=>$data->{countValue}
			});
		$data = $self->session->db->quickHashRef($sql." asc limit 1");
		push(@worst,{
			url=>$self->formatURL("viewDetail",$data->{listingId}),
			category=>$category,
			name=>$data->{productName},
			mean=>$data->{meanValue},
			median=>$data->{medianValue},
			count=>$data->{countValue}
			});
	}
	$var{'best_rating_loop'} = \@best;
	$var{'worst_rating_loop'} = \@worst;
	$var{'ratings.details.url'} = $self->getUrl("func=viewRatingDetails");
	my $data = $self->session->db->quickHashRef("select lastUpdated, productName, listingId from Matrix_listing 
		where assetId=".$self->session->db->quote($self->getId)." and status='approved'  order by lastUpdated desc limit 1");
	my @lastUpdated;
        my $sth = $self->session->db->read("select listingId,lastUpdated,productName from Matrix_listing order by lastUpdated desc limit 20");
        while (my ($listingId, $lastUpdated, $productName) = $sth->array) {
                push(@lastUpdated, {
                        url => $self->formatURL("viewDetail",$listingId),
                        name=>$productName,
                        lastUpdated=>WebGUI::DateTime::epochToHuman($lastUpdated,"%z")
                        });
        }
        $var{'last_updated_loop'} = \@lastUpdated;
	$var{'best.updated.url'} = $self->formatURL("viewDetail",$data->{listingId});
	$var{'best.updated.date'} = WebGUI::DateTime::epochToHuman($data->{lastUpdated},"%z");; 
	$var{'best.updated.name'} = $data->{productName}; 

	# site stats
	($var{'user.count'}) = $self->session->db->quickArray("select count(*) from users");
	($var{'current.user.count'}) = $self->session->db->quickArray("select count(*)+0 from userSession where lastPageView>".(WebGUI::DateTime::time()-600));
	($var{'listing.count'}) = $self->session->db->quickArray("select count(*) from Matrix_listing where status = 'approved' and assetId=".$self->session->db->quote($self->getId));
        my $sth = $self->session->db->read("select listingId,productName from Matrix_listing where status='pending'");
        while (my ($id,$name) = $sth->array) {
                push(@{$var{pending_list}},{
                        url=>$self->formatURL("viewDetail",$id),
                        productName=>$name
                        });
        }
        $sth->finish;
        return $self->processTemplate(\%var,$self->get("templateId"));
}
 
#-------------------------------------------------------------------
sub www_viewDetail {
	my $self = shift;
	my $listingId = shift || $self->session->form->process("listingId");
	my $hasRated = shift || $self->hasRated($listingId);
	my %var;
	my $listing = $self->session->db->getRow("Matrix_listing","listingId",$listingId);
	my $forum = WebGUI::Asset::Wobject::Collaboration->new($listing->{forumId});
	$var{"discussion"} = $forum->view;
	if ($self->session->form->process("do") eq "sendEmail") {
		if ($self->session->form->process("body") ne "") {
			my $u = WebGUI::User->new($listing->{maintainerId});
			WebGUI::Mail::send($u->profileField("email"),$listing->{productName}." - ".$self->session->form->process("subject"),$self->session->form->process("body"),"",$self->session->form->process("from"));
		}
		$var{'email.wasSent'} = 1;
	} else {
		incrementCounter($listingId,"views");
	}
	$var{'edit.url'} = $self->formatURL("editListing",$listingId);
	$var{id} = $listingId;
	$var{'user.canEdit'} = ($self->session->user->profileField("userId") eq $listing->{maintainerId} || $self->canEdit);
	$var{'user.canApprove'} = $self->canEdit;
	$var{'approve.url'} = $self->getUrl("func=approveListing&listingId=".$listingId."&mlog=".$self->session->form->process("mlog"));
	$var{'delete.url'} = $self->getUrl("func=deleteListing&listingId=".$listingId."&mlog=".$self->session->form->process("mlog"));
	$var{'isPending'} = ($listing->{status} eq "pending");
	$var{'lastUpdated.epoch'} = $listing->{lastupdated};
	$var{'lastUpdated.date'} = WebGUI::DateTime::epochToHuman($listing->{lastUpdated},"%z");
	$var{description} = $listing->{description};
	$var{productName} = $listing->{productName};
	$var{productUrl} = $listing->{productUrl};
	$var{'productUrl.click'} = $self->formatURL("click",$listingId);
	$var{manufacturerName} = $listing->{manufacturerName};
	$var{manufacturerUrl} = $listing->{manufacturerUrl};
	$var{'manufacturerUrl.click'} = $self->getUrl("m=1&amp;func=click&amp;listingId=".$listingId);
	$var{versionNumber} = $listing->{versionNumber};
	my $f = WebGUI::HTMLForm->new(
		-extras=>'class="content"',
		-tableExtras=>'class="content"'
		);
	$f->hidden(
		-name=>"func",
		-value=>"viewDetail"
		);
	$f->hidden(
		-name=>"do",
		-value=>"sendEmail"
		);
	$f->hidden(
		-name=>"listingId",
		-value=>$listingId
		);
	$f->email(
		-extras=>'class="content"',
		-name=>"from",
		-value=>$self->session->user->profileField("email"),
		-label=>WebGUI::International::get('your email','Asset_Matrix'),
		);
	$f->selectBox(
		-name=>"subject",
		-extras=>'class="content"',
		-options=>{
			WebGUI::International::get('report error','Asset_Matrix')=>"Report an error.",
			WebGUI::International::get('general comment','Asset_Matrix')=>"General comment.",
			},
		-label=>WebGUI::International::get('request type','Asset_Matrix'),
		);
	$f->textarea(
		-rows=>4,
		-extras=>'class="content"',
		-columns=>35,
		-name=>"body",
		-label=>WebGUI::International::get('comment','Asset_Matrix'),
		);
	$f->submit(
		-extras=>'class="content"',
		-value=>"Send..."
		);
	$var{'email.form'} = $f->print;
	$var{views} = $listing->{views};
	$var{compares} = $listing->{compares};
	$var{clicks} = $listing->{clicks};
	my $sth = $self->session->db->read("select a.value, b.name, b.label, b.description, category from Matrix_listingData a left join 
		Matrix_field b on a.fieldId=b.fieldId where listingId=".$self->session->db->quote($listingId)." order by b.label");	
	while (my $data = $sth->hashRef) {
		$data->{description} =~ s/\n//g;
		$data->{description} =~ s/\r//g;
		$data->{description} =~ s/'/\\\'/g;
		$data->{description} =~ s/"/\&quot;/g;
		$data->{class} = lc($data->{value});
		$data->{class} =~ s/\s/_/g;
		$data->{class} =~ s/\W//g;
		my $cat = $self->session->url->urlize($data->{category})."_loop";
		push(@{$var{$cat}},$data);
	}
	$sth->finish;
	my %rating;
	tie %rating, 'Tie::IxHash';
	%rating = (
		1=>"1 - Worst",
                2=>2,
                3=>3,
                4=>4,
                5=>"5 - Respectable",
                6=>6,
                7=>7,
                8=>8,
                9=>9,
                10=>"10 - Best"
		);
	my $ratingsTable = '<table class="ratingForm"><tbody><tr><th></th><th>Mean</th><th>Median</th><th>Count</th></tr>';
	$f = WebGUI::HTMLForm->new(
		-extras=>'class="ratingForm"',
		-tableExtras=>'class="ratingForm"'
		);
	$f->hidden(
		-name=>"listingId",
		-value=>$listingId
		);
	$f->hidden(
		-name=>"func",
		-value=>"rate"
		);
	foreach my $category ($self->getCategories) {
		my ($mean,$median,$count) = $self->session->db->quickArray("select meanValue, medianValue, countValue from Matrix_ratingSummary
			where listingId=".$self->session->db->quote($listingId)." and category=".$self->session->db->quote($category));
		$ratingsTable .= '<tr><th>'.$category.'</th><td>'.$mean.'</td><td>'.$median.'</td><td>'.$count.'</td></tr>';
		$f->selectBox(
			-name=>$category,
			-label=>$category,
			-value=>[5],
			-extras=>'class="ratingForm"',
			-options=>\%rating
			);
	}
	$ratingsTable .= '</tbody></table>';
	$f->submit(
		-extras=>'class="ratingForm"',
		-value=>"Rate",
		-label=>'<a href="'.$self->formatURL("rate",$listingId).'">'.WebGUI::International::get('show ratings','Asset_Matrix').'</A>'
		);
	if ($hasRated) {
		$var{'ratings'} = $ratingsTable;
	} else {
		$var{'ratings'} = $f->print;
	}
	return $self->processStyle($self->processTemplate(\%var,$self->get("detailTemplateId")));
}


#-----------------------------------------------
sub www_viewRatingDetails {
	my $self = shift;
	my %var;
	my @ratingloop;
	foreach my $category ($self->getCategories) {
		my @detailloop;
		my $sql = "
			select 
				Matrix_listing.productName, 
				Matrix_listing.listingId,
				Matrix_ratingSummary.meanValue,
				Matrix_ratingSummary.medianValue,
				Matrix_ratingSummary.countValue
			from 
				Matrix_listing 
			left join
				Matrix_ratingSummary
			on
				Matrix_listing.listingId=Matrix_ratingSummary.listingId and
				Matrix_ratingSummary.category=".$self->session->db->quote($category)."
			where 
				Matrix_listing.assetId=".$self->session->db->quote($self->getId)." and 
				Matrix_listing.status='approved' and
				Matrix_ratingSummary.countValue > 0
			order by 
				Matrix_ratingSummary.meanValue desc
			";
		my $sth = $self->session->db->read($sql);
		while (my $data = $sth->hashRef) {
			push(@detailloop,{
				url=>$self->formatURL("viewDetail",$data->{listingId}),
				mean=>$data->{meanValue}, 
				median=>$data->{medianValue}, 
				count=>$data->{countValue}, 
				name=>$data->{productName}
				});
		}
		$sth->finish;
		push(@ratingloop,{
			category=>$category,
			detail_loop=>\@detailloop
			});
	}
	$var{rating_loop} = \@ratingloop;
	return $self->processStyle($self->processTemplate(\%var,$self->get("ratingDetailTemplateId")));
}


 


1;
 
