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
			options=>WebGUI::SQL->buildHashRef("select listingId, concat('<a href=\\\"".
				$self->getUrl("func=viewDetail")."&amp;listingId=',listingId,'\\\">', productName,'</a>') from Matrix_listing 
				where assetId=".quote($self->getId)." and status='approved' order by productName")
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
	my ($hasRated) = WebGUI::SQL->quickArray("select count(*) from Matrix_rating where 
		((userId=".quote($session{user}{userId})." and userId<>'1') or (userId='1' and ipAddress=".quote($session{env}{HTTP_X_FORWARDED_FOR}).")) and 
		listingId=".quote($listingId)." and timeStamp>".(WebGUI::DateTime::time()-$ratingTimeout));
	return $hasRated;
}

#-------------------------------------------------------------------
sub incrementCounter {
	my $listingId = shift;
	my $counter = shift;
	my ($lastIp) = WebGUI::SQL->quickArray("select ".$counter."LastIp from Matrix_listing where listingId = ".quote($listingId));
	unless ($lastIp eq $session{env}{HTTP_X_FORWARDED_FOR}) {
		WebGUI::SQL->write("update Matrix_listing set $counter=$counter+1, ".$counter."LastIp=".quote($session{env}{HTTP_X_FORWARDED_FOR})." where listingId=".quote($listingId));
	}
}

#-------------------------------------------------------------------
sub getName {
        return "Matrix";
}
 
#-------------------------------------------------------------------
sub purge {
	my $self = shift;
	WebGUI::SQL->write("delete from Matrix_listing where assetId=".quote($self->getId));
	WebGUI::SQL->write("delete from Matrix_listingData where assetId=".quote($self->getId));
	WebGUI::SQL->write("delete from Matrix_field where assetId=".quote($self->getId));
	WebGUI::SQL->write("delete from Matrix_rating where assetId=".quote($self->getId));
	WebGUI::SQL->write("delete from Matrix_ratingSummary where assetId=".quote($self->getId));
	$self->SUPER::purge;
}


#-------------------------------------------------------------------
sub setRatings { 
	my $self = shift;
	my $listingId = shift;
	my $ratings = shift;
	foreach my $category ($self->getCategories) {
		if ($ratings->{$category}) {
			WebGUI::SQL->write("insert into Matrix_rating (userId, category, rating, timeStamp, listingId,ipAddress, assetId) values (
				".quote($session{user}{userId}).", ".quote($category).", ".quote($ratings->{$category}).", ".WebGUI::DateTime::time()
				.", ".quote($listingId).", ".quote($session{env}{HTTP_X_FORWARDED_FOR}).",".quote($self->getId).")");
		}
		my $sql = "from Matrix_rating where listingId=".quote($listingId)." and category=".quote($category);
		my ($sum) = WebGUI::SQL->quickArray("select sum(rating) $sql");
		my ($count) = WebGUI::SQL->quickArray("select count(*) $sql");
		my $half = round($count/2);
		my $mean = $sum / ($count || 1);
		my ($median) = WebGUI::SQL->quickArray("select rating $sql limit $half,$half");
		WebGUI::SQL->write("replace into Matrix_ratingSummary  (listingId, category, meanValue, medianValue, countValue,assetId) values (
			".quote($listingId).", ".quote($category).", $mean, ".quote($median).", $count, ".quote($self->getId).")");
	}
}

#-------------------------------------------------------------------
sub www_approveListing {
	my $self = shift;
        return WebGUI::Privilege::insufficient() unless($self->canEdit);
	my $listing = WebGUI::SQL->getRow("Matrix_listing","listingId",$session{form}{listingId});
	WebGUI::SQL->write("update Matrix_listing set status='approved' where listingId=".quote($session{form}{listingId}));
	WebGUI::MessageLog::addEntry($listing->{maintainerId},"","New Listing Approved","Your new listing, ".$listing->{productName}.", has been approved.",
		$self->formatURL("viewDetail",$session{form}{listingId}),"notice");
	WebGUI::MessageLog::completeEntry($session{form}{mlog});
	return $self->www_viewDetail;
}


#-------------------------------------------------------------------
sub www_click {
	my $self = shift;
	incrementCounter($session{form}{listingId},"clicks");
	my $listing = WebGUI::SQL->getRow("Matrix_listing","listingId",$session{form}{listingId});
	if ($session{form}{m}) {
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
		@cmsList = WebGUI::FormProcessor::checkList("listingId");
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
		my $data = WebGUI::SQL->quickHashRef("select listingId, productName, versionNumber, lastUpdated
			from Matrix_listing where listingId=".quote($cms));
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
				.$tableCount.".fieldId and ".$tableCount.".listingId=".quote($cms);
			$tableCount++;
		}
		my $sth = WebGUI::SQL->read("$select $from where a.category=".quote($category)." order by a.label");
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
	return "This asset may not be copied.";
}

#-------------------------------------------------------------------
sub www_deleteListing {
	my $self = shift;
	my $output = '<h1>Confirm Delete</h1>
	Are you absolutely sure you wish to delete this listing? This operation cannot be undone.
	<p>
	<a href="'.$self->getUrl("func=deleteListingConfirm&listingId=".$session{form}{listingId}).'">Yes!</a>
	<p>
	<a href="'.$self->formatURL("viewDetail",$session{form}{listingId}).'">No, I made a mistake.</a> ';
	return $self->processStyle($output);
}

#-------------------------------------------------------------------
sub www_deleteListingConfirm {
	my $self = shift;
        return WebGUI::Privilege::insufficient() unless($self->canEdit);
	my $listing = WebGUI::SQL->getRow("Matrix_listing","listingId",$session{form}{listingId});
	WebGUI::Asset::Wobject::Collaboration->new($listing->{forumId})->purge;
	WebGUI::SQL->write("delete from Matrix_listing where listingId=".quote($session{form}{listingId}));
	WebGUI::SQL->write("delete from Matrix_listingData where listingId=".quote($session{form}{listingId}));
	WebGUI::SQL->write("delete from Matrix_rating where listingId=".quote($session{form}{listingId}));
	WebGUI::SQL->write("delete from Matrix_ratingSummary where listingId=".quote($session{form}{listingId}));
	WebGUI::MessageLog::addEntry($listing->{maintainerId},"","Listing Deleted","Your listing, ".$listing->{productName}.", has been deleted from the matrix.","","notice");
	WebGUI::MessageLog::completeEntry($session{form}{mlog});
	return "";
}

#-------------------------------------------------------------------
sub getEditForm {
        my $self = shift;
        my $tabform = $self->SUPER::getEditForm();
	$tabform->getTab("properties")->textarea(
			-name=>"categories",
			-label=>"Categories",
			-value=>$self->getValue("categories"),
			-subtext=>"<br />Enter one per line in the order you want them to appear. Be sure to watch leading and trailing whitespace."
			);
	$tabform->getTab("properties")->integer(
			-name=>"maxComparisons",
			-label=>"Maximum Comparisons",
			-value=>$self->getValue("maxComparisons")
			);
	$tabform->getTab("properties")->integer(
			-name=>"maxComparisonsPrivileged",
			-label=>"Maximum Comparisons (For Privileged Users)",
			-value=>$self->getValue("maxComparisonsPrivileged")
			);
	$tabform->getTab("properties")->interval(
			-name=>"ratingTimeout",
			-label=>"Time Required Between Ratings",
			-value=>$self->getValue("ratingTimeout")
			);
	$tabform->getTab("properties")->interval(
			-name=>"ratingTimeoutPrivileged",
			-label=>"Time Required Between Ratings (For Privileged Users)",
			-value=>$self->getValue("ratingTimeoutPrivileged")
			);
	$tabform->getTab("security")->group(
			-name=>"groupToAdd",
			-label=>"Who can add listings?",
			-value=>[$self->getValue("groupToAdd")]
			);
	$tabform->getTab("security")->group(
			-name=>"privilegedGroup",
			-label=>"Who should have privileged rights?",
			-value=>[$self->getValue("privilegedGroup")]
			);
	$tabform->getTab("security")->group(
			-name=>"groupToRate",
			-label=>"Who can rate listings?",
			-value=>[$self->getValue("groupToRate")]
			);
	$tabform->getTab("display")->template(
			-name=>"templateId",
			-value=>$self->getValue("templateId"),
			-label=>"Main Template",
			-namespace=>"Matrix"
			);
	$tabform->getTab("display")->template(
			-name=>"detailTemplateId",
			-value=>$self->getValue("detailTemplateId"),
			-label=>"Detail Template",
			-namespace=>"Matrix/Detail"
			);
	$tabform->getTab("display")->template(
			-name=>"ratingDetailTemplateId",
			-value=>$self->getValue("ratingDetailTemplateId"),
			-label=>"Rating Detail Template",
			-namespace=>"Matrix/RatingDetail"
			);
	$tabform->getTab("display")->template(
			-name=>"searchTemplateId",
			-value=>$self->getValue("searchTemplateId"),
			-label=>"Search Template",
			-namespace=>"Matrix/Search"
			);
	$tabform->getTab("display")->template(
			-name=>"compareTemplateId",
			-value=>$self->getValue("compareTemplateId"),
			-label=>"Compare Template",
			-namespace=>"Matrix/Compare"
			);
	return $tabform;
}

#-------------------------------------------------------------------
sub www_edit {  
        my $self = shift;
        return WebGUI::Privilege::insufficient() unless $self->canEdit;
        return $self->getAdminConsole->render($self->getEditForm->print,"Edit Matrix");
}


 
#-------------------------------------------------------------------
sub www_editListing {
        my $self = shift;
        my $listing= WebGUI::SQL->getRow("Matrix_listing","listingId",$session{form}{listingId});
	return "You don't have the rights to edit this listing." unless (($session{form}{listingId} eq "new" && WebGUI::Grouping::isInGroup($self->get("groupToAdd"))) || $session{user}{userId} eq $listing->{maintainerId} || $self->canEdit);
        my $f = WebGUI::HTMLForm->new(-action=>$self->getUrl);
        $f->hidden(
                -name=>"func",
                -value=>"editListingSave"
                );
        $f->hidden(
                -name=>"listingId",
                -value=>$session{form}{listingId}
                );
	$f->text(
		-name=>"productName",
		-value=>$listing->{productName},
		-label=>"Product Name",
		-maxLength=>25
		);
	$f->text(
		-name=>"versionNumber",
		-value=>$listing->{versionNumber},
		-label=>"Version/Model Number"
		);
	$f->url(
		-name=>"productUrl",
		-value=>$listing->{productUrl},
		-label=>"Product URL"
		);
	$f->text(
		-name=>"manufacturerName",
		-value=>$listing->{manufacturerName},
		-label=>"Manufacturer Name"
		);
	$f->url(
		-name=>"manufacturerUrl",
		-value=>$listing->{manufacturerUrl},
		-label=>"Manufacturer URL"
		);
	$f->textarea(
		-name=>"description",
		-value=>$listing->{description},
		-label=>"Description"
		);
        if ($self->canEdit) {
		$f->selectList(
			-name=>"maintainerId",
			-value=>[$listing->{maintainerId}],
			-label=>"Listing Maintainer",
			-options=>WebGUI::SQL->buildHashRef("select userId,username from users order by username")
			);
	}
	my %goodBad = ("No"=>"No", "Yes"=>"Yes", "Free Add On"=>"Free Add On","Costs Extra"=>"Costs Extra", "Limited"=>"Limited");
	foreach my $category ($self->getCategories()) {
		$f->raw('<tr><td colspan="2"><b>'.$category.'</b></td></tr>');
		my $a;
		if ($session{form}{listingId} ne "new") {
			$a = WebGUI::SQL->read("select a.name, a.fieldType, a.defaultValue, a.description, a.label, b.value, a.fieldId
				from Matrix_field a left join Matrix_listingData b on a.fieldId=b.fieldId and 
				listingId=".quote($session{form}{listingId})."  where 
				a.category=".quote($category)." order by a.label");
		} else {
			$a = WebGUI::SQL->read("select name, fieldType, defaultValue, description, label, fieldId
				from Matrix_field where category=".quote($category)." and  assetId=".quote($self->getId));
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
				$f->selectList(
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
					-options=>WebGUI::SQL->buildHashRef("select distinct value,value from Matrix_listingData 
						where fieldId=".quote($field->{fieldId})." and
						 assetId=".quote($self->getId)." order by value"),
					-subtext=>"<br />".$field->{description}
					);
			}
			
		}
		$a->finish;
	}
        $f->submit;
        return $self->processStyle("<h1>Edit Listing</h1>".$f->print);
}
 
 
#-------------------------------------------------------------------
sub www_editListingSave {
        my $self = shift;
        my $listing = WebGUI::SQL->getRow("Matrix_listing","listingId",$session{form}{listingId});
	return "You don't have the rights to edit this listing." unless (($session{form}{listingId} eq "new" && WebGUI::Grouping::isInGroup($self->get("groupToAdd"))) || $session{user}{userId} eq $listing->{maintainerId} || $self->canEdit);
	my %data = (
		listingId => $session{form}{listingId},
		lastUpdated => WebGUI::DateTime::time(),
		productName => $session{form}{productName},
		productUrl => $session{form}{productUrl},
		manufacturerName => $session{form}{manufacturerName},
		manufacturerUrl => $session{form}{manufacturerUrl},
		description => $session{form}{description},
		versionNumber=>$session{form}{versionNumber}
		);
	my $isNew = 0;
	if ($session{form}{listingId} eq "new") {
		$data{maintainerId} = $session{user}{userId} if ($session{form}{listingId} eq "new");
		my $forum = $self->addChild({
			className=>"WebGUI::Asset::Wobject::Collaboration",
			title=>$session{form}{productName},
			menuTitle=>$session{form}{productName},
			url=>$session{form}{productName},
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
	$data{maintainerId} = $session{form}{maintainerId} if ($self->canEdit);
	$data{assetId} = $self->getId;
	$session{form}{listingId} = WebGUI::SQL->setRow("Matrix_listing","listingId",\%data);
	if ($data{status} eq "pending") {
		WebGUI::MessageLog::addEntry($self->get("ownerUserId"),$self->get("groupIdEdit"),"New Listing Added","A new listing, ".$data{productName}.", is waiting to be added.",
			WebGUI::URL::getSiteURL()."/".$self->formatURL("viewDetail",$session{form}{listingId}),"pending");
	}
	my $a = WebGUI::SQL->read("select fieldId, name, fieldType from Matrix_field");
	while (my ($id, $name, $type) = $a->array) {
		my $value;
		if ($type eq "goodBad") {
			$value = WebGUI::FormProcessor::selectList($name);
		} else {
			$value = WebGUI::FormProcessor::process($name,$type);
		}
		WebGUI::SQL->write("replace into Matrix_listingData (assetId, listingId, fieldId, value) values (
			".quote($self->getId).", ".quote($session{form}{listingId}).", ".quote($id).", ".quote($value).")");
	}
	$a->finish;
        return $self->www_viewDetail;
}
 
#-------------------------------------------------------------------
sub www_editField {
	my $self = shift;
        return WebGUI::Privilege::insufficient() unless($self->canEdit);
        my $field = WebGUI::SQL->getRow("Matrix_field","fieldId",$session{form}{fieldId});
        my $f = WebGUI::HTMLForm->new(-action=>$self->getUrl);
        $f->hidden(
                -name=>"func",
                -value=>"editFieldSave"
                );
        $f->hidden(
                -name=>"fieldId",
                -value=>$session{form}{fieldId}
		);
	$f->text(
		-name=>"name",
		-value=>$field->{name},
		-label=>"Name"
		);
	$f->text(
		-name=>"label",
		-value=>$field->{label},
		-label=>"Label"
		);
	$f->selectList(
		-name=>"fieldType",
		-value=>[$field->{fieldType}],
		-label=>"Type",
		-options=>{
			goodBad=>"Good Bad",
			text=>"Text",
			url=>"URL",
			textarea=>"Text Area",
			combo=>"Combo"
			}
		);
	$f->textarea(
		-name=>"description",
		-value=>$field->{description},
		-label=>"Description"
		);
	$f->text(
		-name=>"defaultValue",
		-value=>$field->{defaultValue},
		-label=>"Default Value"
		);
	my %cats;
	foreach my $category ($self->getCategories) {
		$cats{$category} = $category;
	}
	$f->selectList(
		-name=>"category",
		-value=>[$field->{category}],
		-label=>"Category",
		-options=>\%cats
		);
	$f->submit;
	return $self->processStyle("<h1>Edit Field</h1>".$f->print);
}


#-------------------------------------------------------------------
sub www_editFieldSave {
	my $self = shift;
        return WebGUI::Privilege::insufficient() unless($self->canEdit);
	WebGUI::SQL->setRow("Matrix_field","fieldId",{
		fieldId=>$session{form}{fieldId},
		name=>$session{form}{name},
		label=>$session{form}{label},
		fieldType=>$session{form}{fieldType},
		description=>$session{form}{description},
		defaultValue=>$session{form}{defaultValue},
		category=>$session{form}{category},
		assetId=>$self->getId
		});
	return $self->www_listFields();
}

#-------------------------------------------------------------------
sub www_listFields {
	my $self = shift;
        return WebGUI::Privilege::insufficient() unless($self->canEdit);
	my $output = '<h1>Field List</h1>
		<a href="'.$self->getUrl("func=editField&amp;fieldId=new").'">Add new field.</a>
		<p />';
	my $sth = WebGUI::SQL->read("select fieldId, label from Matrix_field where assetId=".quote($self->getId)." order by label");
	while (my ($id, $label) = $sth->array) {
		$output .= '<a href="'.$self->getUrl("func=editField&amp;fieldId=".$id).'">'.$label.'</a><br />';
	}
	$sth->finish;
	return $self->processStyle($output);
}


#-------------------------------------------------------------------
sub www_rate {
	my $self = shift;
	my $hasRated = $self->hasRated($session{form}{listingId});
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
	$self->setRatings($session{form}{listingId},$session{form});
	return $self->www_viewDetail;	
}

#-------------------------------------------------------------------
sub www_search {
	my $self = shift;
	my %var;
	my @list = WebGUI::SQL->buildArray("select listingId from Matrix_listing");
	if ($session{form}{doit}) {
		my $count;
		my $keyword;
		if ($session{form}{keyword}) {
			$keyword = " and (a.value like ".quote('%'.$session{form}{keyword}.'%')." or a.value='Any')";
		}
		my $sth = WebGUI::SQL->read("select name,fieldType from Matrix_field");	
		while (my ($name,$fieldType) = $sth->array) {
			next unless ($session{form}{$name});
			push(@list,0);	
			my $where;
			if ($fieldType ne "goodBad") {
                                $where = "("
					."a.value like ".quote("%".$session{form}{$name}."%")
					." or a.value='Any'"
                                        #." or a.value<".quote($session{form}{$name})
					." or a.value='Free'"
					.")";
			} else {
				$where = "a.value<>'no'";
			}
			@list = WebGUI::SQL->buildArray("select a.listingId from Matrix_listingData a left join Matrix_field b 
				on (a.fieldId=b.fieldId)
				where a.listingId in (".quoteAndJoin(\@list).") and $where and b.name=".quote($name));
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
		value=>$session{form}{keyword}
		});
	$var{'form.submit'} = WebGUI::Form::submit({
		value=>"search"
		});
	foreach my $category ($self->getCategories()) {
		my $sth = WebGUI::SQL->read("select name, fieldType, label, description from Matrix_field where category = ".quote($category)." order by label");	
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
		$var{WebGUI::URL::urlize($category)."_loop"} = \@loop;
	}
	return $self->processStyle($self->processTemplate(\%var,$self->get("searchTemplateId")));
}


#-------------------------------------------------------------------
sub view {
        my $self = shift;
        my (%var);
	$var{'compare.form'} = $self->getCompareForm;
	$var{'search.url'} = $self->getUrl("func=search");
	$var{'isLoggedIn'} = ($session{user}{userId} ne "1");
	$var{'field.list.url'} = $self->getUrl('func=listFields');	
	$var{'listing.add.url'} = $self->formatURL("editListing","new");

	my $data = WebGUI::SQL->quickHashRef("select views, productName, listingId from Matrix_listing 
		 where assetId=".quote($self->getId)." and status='approved' order by views desc limit 1");
	$var{'best.views.url'} = $self->formatURL("viewDetail",$data->{listingId});
	$var{'best.views.count'} = $data->{views}; 
	$var{'best.views.name'} = $data->{productName}; 
	my $data = WebGUI::SQL->quickHashRef("select compares, productName, listingId from Matrix_listing 
		where assetId=".quote($self->getId)." and status='approved'  order by compares desc limit 1");
	$var{'best.compares.url'} = $self->formatURL("viewDetail",$data->{listingId});
	$var{'best.compares.count'} = $data->{compares}; 
	$var{'best.compares.name'} = $data->{productName}; 
	my $data = WebGUI::SQL->quickHashRef("select clicks, productName, listingId from Matrix_listing 
		where assetId=".quote($self->getId)." and status='approved'  order by clicks desc limit 1");
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
				Matrix_ratingSummary.category=".quote($category)."
			where 
				Matrix_listing.assetId=".quote($self->getId)." and 
				Matrix_listing.status='approved' and
				Matrix_ratingSummary.countValue > 0
			order by 
				Matrix_ratingSummary.meanValue
			";
		my $data = WebGUI::SQL->quickHashRef($sql." desc limit 1");
		push(@best,{
			url=>$self->formatURL("viewDetail",$data->{listingId}),
			category=>$category,
			name=>$data->{productName},
			mean=>$data->{meanValue},
			median=>$data->{medianValue},
			count=>$data->{countValue}
			});
		$data = WebGUI::SQL->quickHashRef($sql." asc limit 1");
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
	my $data = WebGUI::SQL->quickHashRef("select lastUpdated, productName, listingId from Matrix_listing 
		where assetId=".quote($self->getId)." and status='approved'  order by lastUpdated desc limit 1");
	$var{'best.updated.url'} = $self->formatURL("viewDetail",$data->{listingId});
	$var{'best.updated.date'} = WebGUI::DateTime::epochToHuman($data->{lastUpdated},"%z");; 
	$var{'best.updated.name'} = $data->{productName}; 

	# site stats
	($var{'user.count'}) = WebGUI::SQL->quickArray("select count(*) from users");
	($var{'current.user.count'}) = WebGUI::SQL->quickArray("select count(*)+0 from userSession where lastPageView>".(WebGUI::DateTime::time()-600));
	($var{'listing.count'}) = WebGUI::SQL->quickArray("select count(*) from Matrix_listing where status = 'approved' and assetId=".quote($self->getId));
        my $sth = WebGUI::SQL->read("select listingId,productName from Matrix_listing where status='pending'");
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
	my $listingId = shift || $session{form}{listingId};
	my $hasRated = shift || $self->hasRated($listingId);
	my %var;
	my $listing = WebGUI::SQL->getRow("Matrix_listing","listingId",$listingId);
	my $forum = WebGUI::Asset::Wobject::Collaboration->new($listing->{forumId});
	$var{"discussion"} = $forum->view;
	if ($session{form}{do} eq "sendEmail") {
		if ($session{form}{body} ne "") {
			my $u = WebGUI::User->new($listing->{maintainerId});
			WebGUI::Mail::send($u->profileField("email"),$listing->{productName}." - ".$session{form}{subject},$session{form}{body},"",$session{form}{from});
		}
		$var{'email.wasSent'} = 1;
	} else {
		incrementCounter($listingId,"views");
	}
	$var{'edit.url'} = $self->formatURL("editListing",$listingId);
	$var{id} = $listingId;
	$var{'user.canEdit'} = ($session{user}{userId} eq $listing->{maintainerId} || $self->canEdit);
	$var{'user.canApprove'} = $self->canEdit;
	$var{'approve.url'} = $self->getUrl("func=approveListing&listingId=".$listingId."&mlog=".$session{form}{mlog});
	$var{'delete.url'} = $self->getUrl("func=deleteListing&listingId=".$listingId."&mlog=".$session{form}{mlog});
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
		-value=>$session{user}{email},
		-label=>"Your Email Address"
		);
	$f->selectList(
		-name=>"subject",
		-extras=>'class="content"',
		-options=>{
			"Report an error."=>"Report an error.",
			"General comment."=>"General comment."
			},
		-label=>"Type of Request"
		);
	$f->textarea(
		-rows=>4,
		-extras=>'class="content"',
		-columns=>35,
		-name=>"body",
		-label=>"Comment"
		);
	$f->submit(
		-extras=>'class="content"',
		-value=>"Send..."
		);
	$var{'email.form'} = $f->print;
	$var{views} = $listing->{views};
	$var{compares} = $listing->{compares};
	$var{clicks} = $listing->{clicks};
	my $sth = WebGUI::SQL->read("select a.value, b.name, b.label, b.description, category from Matrix_listingData a left join 
		Matrix_field b on a.fieldId=b.fieldId where listingId=".quote($listingId)." order by b.label");	
	while (my $data = $sth->hashRef) {
		$data->{description} =~ s/\n//g;
		$data->{description} =~ s/\r//g;
		$data->{description} =~ s/'/\\\'/g;
		$data->{description} =~ s/"/\&quot;/g;
		$data->{class} = lc($data->{value});
		$data->{class} =~ s/\s/_/g;
		$data->{class} =~ s/\W//g;
		my $cat = WebGUI::URL::urlize($data->{category})."_loop";
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
		my ($mean,$median,$count) = WebGUI::SQL->quickArray("select meanValue, medianValue, countValue from Matrix_ratingSummary
			where listingId=".quote($listingId)." and category=".quote($category));
		$ratingsTable .= '<tr><th>'.$category.'</th><td>'.$mean.'</td><td>'.$median.'</td><td>'.$count.'</td></tr>';
		$f->selectList(
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
		-label=>'<a href="'.$self->formatURL("rate",$listingId).'">Show Ratings</a>'
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
				Matrix_ratingSummary.category=".quote($category)."
			where 
				Matrix_listing.assetId=".quote($self->getId)." and 
				Matrix_listing.status='approved' and
				Matrix_ratingSummary.countValue > 0
			order by 
				Matrix_ratingSummary.meanValue desc
			";
		my $sth = WebGUI::SQL->read($sql);
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
 
