package WebGUI::Asset::Wobject::Matrix;
 
use strict;
use Tie::IxHash;
use WebGUI::Form;
use WebGUI::HTMLForm;
use WebGUI::Cache;
use WebGUI::Mail::Send;
use WebGUI::SQL;
use WebGUI::User;
use WebGUI::Utility;
use WebGUI::Inbox;
use WebGUI::Asset::Wobject;
use WebGUI::Asset::Wobject::Collaboration;

 
our @ISA = qw(WebGUI::Asset::Wobject);
 
#-------------------------------------------------------------------
sub definition {
        my $class = shift;
	my $session = shift;
        my $definition = shift;
	my $i18n = WebGUI::International->new($session,"Asset_Matrix");
        push(@{$definition}, {
		icon=>'matrix.gif',
                tableName=>'Matrix',
                className=>'WebGUI::Asset::Wobject::Matrix',
		assetName=>$i18n->get('assetName'),
                properties=>{
			visitorCacheTimeout => {
				tab => "display",
				fieldType => "interval",
				defaultValue => 3600,
				uiLevel => 8,
				label => $i18n->get("visitor cache timeout"),
				hoverHelp => $i18n->get("visitor cache timeout help")
				},
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
        return $class->SUPER::definition($session, $definition);
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
	my $url = $self->getUrl("func=".$func.";listingId=".$listingId);
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
	my $form = WebGUI::Form::formHeader($self->session,{action=>$self->getUrl})
		.WebGUI::Form::submit($self->session, {
			value=>"compare"
			})
		."<br />"
		."<br />"
		.WebGUI::Form::hidden($self->session, {
			name=>"func",
			value=>"compare"
			})
		.WebGUI::Form::checkList($self->session, {
			name=>"listingId",
			vertical=>1,
			value=>\@ids,
			options=>$self->session->db->buildHashRef("select listingId, concat('<a href=\\\"".
				$self->getUrl("func=viewDetail").";listingId=',listingId,'\\\">', productName,'</a>') from Matrix_listing 
				where assetId=".$self->session->db->quote($self->getId)." and status='approved' order by productName")
			})
		."<br />"
		.WebGUI::Form::submit($self->session,{
			value=>"compare"
			})
		."</form>";
	return $form;
}


#-------------------------------------------------------------------
sub hasRated {
	my $self = shift;
	my $listingId = shift;
	return 1 unless ($self->session->user->isInGroup($self->get("groupToRate")));
	my $ratingTimeout = $self->session->user->isInGroup($self->get("privilegedGroup")) ? $self->get("ratingTimeoutPrivileged") : $self->get("ratingTimeout");
	my ($hasRated) = $self->session->db->quickArray("select count(*) from Matrix_rating where 
		((userId=".$self->session->db->quote($self->session->user->userId)." and userId<>'1') or (userId='1' and ipAddress=".$self->session->db->quote($self->session->env->get("HTTP_X_FORWARDED_FOR")).")) and 
		listingId=".$self->session->db->quote($listingId)." and timeStamp>".($self->session->datetime->time()-$ratingTimeout));
	return $hasRated;
}

#-------------------------------------------------------------------
sub incrementCounter {
	my $self = shift;
	my $listingId = shift;
	my $counter = shift;
	my ($lastIp) = $self->session->db->quickArray("select ".$counter."LastIp from Matrix_listing where listingId = ".$self->session->db->quote($listingId));
	unless ($lastIp eq $self->session->env->get("HTTP_X_FORWARDED_FOR")) {
		$self->session->db->write("update Matrix_listing set $counter=$counter+1, ".$counter."LastIp=".$self->session->db->quote($self->session->env->get("HTTP_X_FORWARDED_FOR"))." where listingId=".$self->session->db->quote($listingId));
	}
}

#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
	my $self = shift;
	$self->SUPER::prepareView();
	my $template = WebGUI::Asset::Template->new($self->session, $self->get("templateId"));
	$template->prepare;
	$self->{_viewTemplate} = $template;
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

=head2 purgeCache ()

See WebGUI::Asset::purgeCache() for details.

=cut

sub purgeCache {
	my $self = shift;
	WebGUI::Cache->new($self->session,"view_".$self->getId)->delete;
	$self->SUPER::purgeCache;
}

#-------------------------------------------------------------------
sub setRatings { 
	my $self = shift;
	my $listingId = shift;
	my $ratings = shift;
	foreach my $category ($self->getCategories) {
		if ($ratings->{$category}) {
			$self->session->db->write("insert into Matrix_rating (userId, category, rating, timeStamp, listingId,ipAddress, assetId) values (
				".$self->session->db->quote($self->session->user->userId).", ".$self->session->db->quote($category).", ".$self->session->db->quote($ratings->{$category}).", ".$self->session->datetime->time()
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
        return $self->session->privilege->insufficient() unless($self->canEdit);
	my $listing = $self->session->db->getRow("Matrix_listing","listingId",$self->session->form->process("listingId"));
	$self->session->db->write("update Matrix_listing set status='approved' where listingId=".$self->session->db->quote($self->session->form->process("listingId")));
	my $inbox = WebGUI::Inbox->new($self->session);
	$inbox->addMessage({
		subject=>"New Listing Approved",
		message=>"Your new listing, ".$listing->{productName}.", has been approved.",
		status=>'completed',
		userId=>$listing->{maintainerId}
		});
	my $message = $inbox->getMessage($listing->{approvalMessageId});
	if (defined $message) {
		$message->setCompleted;
	}
	return $self->www_viewDetail;
}


#-------------------------------------------------------------------
sub www_click {
	my $self = shift;
	$self->incrementCounter($self->session->form->process("listingId"),"clicks");
	my $listing = $self->session->db->getRow("Matrix_listing","listingId",$self->session->form->process("listingId"));
	if ($self->session->form->process("m")) {
		$self->session->http->setRedirect($listing->{manufacturerUrl});
	} else {
		$self->session->http->setRedirect($listing->{productUrl});
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
	my $max = $self->session->user->isInGroup($self->get("privilegedGroup")) ? $self->get("maxComparisonsPrivileged") : $self->get("maxComparisons");
	$var{isTooMany} = (scalar(@cmsList)>$max);
	$var{isTooFew} = (scalar(@cmsList)<2);
	$var{'compare.form'} = $self->getCompareForm(@cmsList);
	$var{'isLoggedIn'} = ($self->session->user->get("userId") ne "1");
	if ($var{isTooMany} || $var{isTooFew}) {
		return $self->processStyle($self->processTemplate(\%var,$self->get("compareTemplateId")));
	}
	foreach my $cms (@cmsList) {
		$self->incrementCounter($cms,"compares");
		my $data = $self->session->db->quickHashRef("select listingId, productName, versionNumber, lastUpdated
			from Matrix_listing where listingId=".$self->session->db->quote($cms));
		push(@prodcol, {
			name=>$data->{productName} || "__untitled__",
			version=>$data->{versionNumber},
			url=>$self->formatURL("viewDetail",$cms)
			});
		push(@datecol, {
			lastUpdated=>$self->session->datetime->epochToHuman($data->{lastUpdated},"%z")
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
	my $self = shift;
	my $i18n = WebGUI::International->new($self->session,'Asset_Matrix');
	return $i18n->get('no copy');
}

#-------------------------------------------------------------------
sub www_deleteListing {
	my $self = shift;
	my $i18n = WebGUI::International->new($self->session,'Asset_Matrix');
	my $output = sprintf $i18n->get('delete listing confirmation'),
		$self->getUrl("func=deleteListingConfirm;listingId=".$self->session->form->process("listingId")),
		$self->formatURL("viewDetail",$self->session->form->process("listingId"));
	return $self->processStyle($output);
}

#-------------------------------------------------------------------
sub www_deleteListingConfirm {
	my $self = shift;
        return $self->session->privilege->insufficient() unless($self->canEdit);
	my $listing = $self->session->db->getRow("Matrix_listing","listingId",$self->session->form->process("listingId"));
	WebGUI::Asset::Wobject::Collaboration->new($self->session, $listing->{forumId})->purge;
	$self->session->db->write("delete from Matrix_listing where listingId=".$self->session->db->quote($self->session->form->process("listingId")));
	$self->session->db->write("delete from Matrix_listingData where listingId=".$self->session->db->quote($self->session->form->process("listingId")));
	$self->session->db->write("delete from Matrix_rating where listingId=".$self->session->db->quote($self->session->form->process("listingId")));
	$self->session->db->write("delete from Matrix_ratingSummary where listingId=".$self->session->db->quote($self->session->form->process("listingId")));
	my $inbox = WebGUI::Inbox->new($self->session);
	$inbox->addMessage({
		status=>'completed',
		subject=>"Listing Deleted",
		message=>"Your listing, ".$listing->{productName}.", has been deleted from the matrix.",
		userId=>$listing->{maintainerId}
		});
	my $message = $inbox->getMessage($listing->{approvalMessageId});
	if (defined $message) {
		$message->setCompleted;
	}
	return "";
}

#-------------------------------------------------------------------
sub getEditForm {
        my $self = shift;
        my $tabform = $self->SUPER::getEditForm();
	my $i18n = WebGUI::International->new($self->session,'Asset_Matrix');
 	$tabform->getTab("display")->interval(
 		-name=>"visitorCacheTimeout",
		-label=>$i18n->get('visitor cache timeout'),
		-hoverHelp=>$i18n->get('visitor cache timeout help'),
		-value=>$self->getValue('visitorCacheTimeout'),
		-uiLevel=>8,
		-defaultValue=>3600
	);
	$tabform->getTab("properties")->textarea(
			-name=>"categories",
			-label=>$i18n->get('categories'),
			-hoverHelp=>$i18n->get('categories description'),
			-value=>$self->getValue("categories"),
			-subtext=>$i18n->get('categories subtext'),
			);
	$tabform->getTab("properties")->integer(
			-name=>"maxComparisons",
			-label=>$i18n->get("max comparisons"),
			-hoverHelp=>$i18n->get("max comparisons description"),
			-value=>$self->getValue("maxComparisons")
			);
	$tabform->getTab("properties")->integer(
			-name=>"maxComparisonsPrivileged",
			-label=>$i18n->get("max comparisons privileged"),
			-hoverHelp=>$i18n->get("max comparisons privileged description"),
			-value=>$self->getValue("maxComparisonsPrivileged")
			);
	$tabform->getTab("properties")->interval(
			-name=>"ratingTimeout",
			-label=>$i18n->get("rating timeout"),
			-hoverHelp=>$i18n->get("rating timeout description"),
			-value=>$self->getValue("ratingTimeout")
			);
	$tabform->getTab("properties")->interval(
			-name=>"ratingTimeoutPrivileged",
			-label=>$i18n->get("rating timeout privileged"),
			-hoverHelp=>$i18n->get("rating timeout privileged description"),
			-value=>$self->getValue("ratingTimeoutPrivileged")
			);
	$tabform->getTab("security")->group(
			-name=>"groupToAdd",
			-label=>$i18n->get("group to add"),
			-hoverHelp=>$i18n->get("group to add description"),
			-value=>[$self->getValue("groupToAdd")]
			);
	$tabform->getTab("security")->group(
			-name=>"privilegedGroup",
			-label=>$i18n->get("privileged group"),
			-hoverHelp=>$i18n->get("privileged group description"),
			-value=>[$self->getValue("privilegedGroup")]
			);
	$tabform->getTab("security")->group(
			-name=>"groupToRate",
			-label=>$i18n->get("rating group"),
			-hoverHelp=>$i18n->get("rating group description"),
			-value=>[$self->getValue("groupToRate")]
			);
	$tabform->getTab("display")->template(
			-name=>"templateId",
			-value=>$self->getValue("templateId"),
			-label=>$i18n->get("main template"),
			-hoverHelp=>$i18n->get("main template description"),
			-namespace=>"Matrix"
			);
	$tabform->getTab("display")->template(
			-name=>"detailTemplateId",
			-value=>$self->getValue("detailTemplateId"),
			-label=>$i18n->get("detail template"),
			-hoverHelp=>$i18n->get("detail template description"),
			-namespace=>"Matrix/Detail"
			);
	$tabform->getTab("display")->template(
			-name=>"ratingDetailTemplateId",
			-value=>$self->getValue("ratingDetailTemplateId"),
			-label=>$i18n->get("rating detail template"),
			-hoverHelp=>$i18n->get("rating detail template description"),
			-namespace=>"Matrix/RatingDetail"
			);
	$tabform->getTab("display")->template(
			-name=>"searchTemplateId",
			-value=>$self->getValue("searchTemplateId"),
			-label=>$i18n->get("search template"),
			-hoverHelp=>$i18n->get("search template description"),
			-namespace=>"Matrix/Search"
			);
	$tabform->getTab("display")->template(
			-name=>"compareTemplateId",
			-value=>$self->getValue("compareTemplateId"),
			-label=>$i18n->get("compare template"),
			-hoverHelp=>$i18n->get("compare template description"),
			-namespace=>"Matrix/Compare"
			);
	return $tabform;
}

#-------------------------------------------------------------------
sub www_edit {  
        my $self = shift;
        return $self->session->privilege->insufficient() unless $self->canEdit;
	my $i18n = WebGUI::International->new($self->session,'Asset_Matrix');
        return $self->getAdminConsole->render($self->getEditForm->print,
					$i18n->get("edit matrix"));
}


 
#-------------------------------------------------------------------
sub www_editListing {
        my $self = shift;
        my $listing= $self->session->db->getRow("Matrix_listing","listingId",$self->session->form->process("listingId"));
	my $i18n = WebGUI::International->new($self->session,'Asset_Matrix');
	return $i18n->get('no edit rights') unless (($self->session->form->process("listingId") eq "new" && $self->session->user->isInGroup($self->get("groupToAdd"))) || $self->session->user->userId eq $listing->{maintainerId} || $self->canEdit);
        my $f = WebGUI::HTMLForm->new($self->session,-action=>$self->getUrl);
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
		-label=>$i18n->get('product name'),
		-hoverHelp=>$i18n->get('product name description'),
		-maxLength=>25
		);
	$f->text(
		-name=>"versionNumber",
		-value=>$listing->{versionNumber},
		-label=>$i18n->get('version number'),
		-hoverHelp=>$i18n->get('version number description'),
		);
	$f->url(
		-name=>"productUrl",
		-value=>$listing->{productUrl},
		-label=>$i18n->get('product url'),
		-hoverHelp=>$i18n->get('product url description'),
		);
	$f->text(
		-name=>"manufacturerName",
		-value=>$listing->{manufacturerName},
		-label=>$i18n->get('manufacturer name'),
		-hoverHelp=>$i18n->get('manufacturer name description'),
		);
	$f->url(
		-name=>"manufacturerUrl",
		-value=>$listing->{manufacturerUrl},
		-label=>$i18n->get('manufacturer url'),
		);
	$f->textarea(
		-name=>"description",
		-value=>$listing->{description},
		-label=>$i18n->get('description'),
		);
        if ($self->canEdit) {
		$f->selectBox(
			options=>$self->session->db->buildHashRef("select userId,username from users order by username"),
			name=>"maintainerId",
			value=>$listing->{maintainerId},
			label=>$i18n->get('listing maintainer'),
			hoverHelp=>$i18n->get('listing maintainer description'),
			);
	}
	my %goodBad = (
		"No"          => $i18n->get("no"),
		"Yes"         => $i18n->get("yes"),
		"Free Add On" => $i18n->get("free"),
		"Costs Extra" => $i18n->get("extra"),
		"Limited"     => $i18n->get("limited"),
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
				my $value = ($field->{value} || $field->{defaultValue} || $i18n->get("no"));
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
        return $self->processStyle($i18n->get('edit listing').$f->print);
}
 
 
#-------------------------------------------------------------------
sub www_editListingSave {
        my $self = shift;
        my $listing = $self->session->db->getRow("Matrix_listing","listingId",$self->session->form->process("listingId"));
	my $i18n = WebGUI::International->new($self->session,'Asset_Matrix');
	return $i18n->get('no edit rights') unless (($self->session->form->process("listingId") eq "new" && $self->session->user->isInGroup($self->get("groupToAdd"))) || $self->session->user->userId eq $listing->{maintainerId} || $self->canEdit);
	my %data = (
		listingId => $self->session->form->process("listingId"),
		lastUpdated => $self->session->datetime->time(),
		productName => $self->session->form->process("productName"),
		productUrl => $self->session->form->process("productUrl"),
		manufacturerName => $self->session->form->process("manufacturerName"),
		manufacturerUrl => $self->session->form->process("manufacturerUrl"),
		description => $self->session->form->process("description"),
		versionNumber=>$self->session->form->process("versionNumber")
		);
	my $isNew = 0;
	if ($self->session->form->process("listingId") eq "new") {
		$data{maintainerId} = $self->session->user->userId if ($self->session->form->process("listingId") eq "new");
		my $forum = $self->addChild({
			className=>"WebGUI::Asset::Wobject::Collaboration",
			title=>$self->session->form->process("productName"),
			menuTitle=>$self->session->form->process("productName"),
			url=>$self->session->form->process("productName"),
			groupIdView=>7,
			groupIdEdit=>3,
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
	my $listingId = $self->session->db->setRow("Matrix_listing","listingId",\%data);
	if ($data{status} eq "pending" && !$listing->{approvalMessageId}) {
		my $approvalMessage = WebGUI::Inbox->new($self->session)->addMessage({
			status=>'pending',
			groupId=>$self->get("groupIdEdit"),
			userId=>$self->get("ownerUserId"),
			subject=>"New Listing Added",
			message=>"A new listing, ".$data{productName}.", is waiting to be added.\n\n".$self->session->url->getSiteURL()."/".$self->formatURL("viewDetail",$listingId)
			});
		$self->session->db->setRow("Matrix_listing","listingId",{listingId=>$listingId, approvalMessageId=>$approvalMessage->getId});
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
			".$self->session->db->quote($self->getId).", ".$self->session->db->quote($listingId).", ".$self->session->db->quote($id).", ".$self->session->db->quote($value).")");
	}
	$a->finish;
        return $self->www_viewDetail($listingId);
}
 
#-------------------------------------------------------------------
sub www_editField {
	my $self = shift;
        return $self->session->privilege->insufficient() unless($self->canEdit);
	my $i18n = WebGUI::International->new($self->session,'Asset_Matrix');
        my $field = $self->session->db->getRow("Matrix_field","fieldId",$self->session->form->process("fieldId"));
        my $f = WebGUI::HTMLForm->new($self->session,-action=>$self->getUrl);
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
		-label=>$i18n->get('field name'),
		-hoverHelp=>$i18n->get('field name description'),
		);
	$f->text(
		-name=>"label",
		-value=>$field->{label},
		-label=>$i18n->get('field label'),
		-hoverHelp=>$i18n->get('field label description'),
		);
	$f->selectBox(
		-name=>"fieldType",
		-value=>[$field->{fieldType}],
		-label=>$i18n->get('field type'),
		-hoverHelp=>$i18n->get('field type description'),
		-options=>{
			'goodBad'  => $i18n->get('good bad'),
			'text'     => $i18n->get('text'),
			'url'      => $i18n->get('url'),
			'textarea' => $i18n->get('text area'),
			'combo'    => $i18n->get('combo'),
			}
		);
	$f->textarea(
		-name=>"description",
		-value=>$field->{description},
		-label=>$i18n->get('field description'),
		-hoverHelp=>$i18n->get('field description description'),
		);
	$f->text(
		-name=>"defaultValue",
		-value=>$field->{defaultValue},
		-label=>$i18n->get('default value'),
		-hoverHelp=>$i18n->get('default value description'),
		);
	my %cats;
	foreach my $category ($self->getCategories) {
		$cats{$category} = $category;
	}
	$f->selectBox(
		-name=>"category",
		-value=>[$field->{category}],
		-label=>$i18n->get('category'),
		-hoverHelp=>$i18n->get('category description'),
		-options=>\%cats
		);
	$f->submit;
	return $self->processStyle($i18n->get('edit field').$f->print);
}


#-------------------------------------------------------------------
sub www_editFieldSave {
	my $self = shift;
        return $self->session->privilege->insufficient() unless($self->canEdit);
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
        return $self->session->privilege->insufficient() unless($self->canEdit);
	my $i18n = WebGUI::International->new($self->session,'Asset_Matrix');
	my $output = sprintf $i18n->get('list fields'),
				$self->getUrl("func=editField;fieldId=new");
	my $sth = $self->session->db->read("select fieldId, label from Matrix_field where assetId=".$self->session->db->quote($self->getId)." order by label");
	while (my ($id, $label) = $sth->array) {
		$output .= '<a href="'.$self->getUrl("func=editField;fieldId=".$id).'">'.$label.'</a><br />';
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
			if ($lastRating != $self->session->form->process($category)) {
				$sameRating = 0;
			} 
		}
		$lastRating = $self->session->form->process($category);
	} 
	return $self->www_viewDetail("",1) if ($hasRated || $sameRating); # Throw out ratings that are all the same number, or if the user rates twice.
	$self->setRatings($self->session->form->process("listingId"),$self->session->form->paramsHashRef);
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
			next unless ($self->session->form->process($name));
			push(@list,0);	
			my $where;
			if ($fieldType ne "goodBad") {
                                $where = "("
					."a.value like ".$self->session->db->quote("%".$self->session->form->process($name)."%")
					." or a.value='Any'"
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
			my $max = $self->session->user->isInGroup($self->get("privilegedGroup")) ? $self->get("maxComparisonsPrivileged") : $self->get("maxComparisons");
			$var{isTooMany} = ($count>$max);
			$var{isTooFew} = ($count<2);
		}
	}
	$var{'isLoggedIn'} = ($self->session->user->get("userId") ne "1");
	$var{'compare.form'} = $self->getCompareForm(@list);
	$var{'form.header'} = WebGUI::Form::formHeader($self->session,{action=>$self->getUrl})
		.WebGUI::Form::hidden($self->session,{
			name=>"doit",
			value=>"1"
			})
		.WebGUI::Form::hidden($self->session,{
			name=>"func",
			value=>"search"
			});
	$var{'form.footer'} = "</form>";
	$var{'form.keyword'} = WebGUI::Form::text($self->session,{
		name=>"keyword",
		value=>$self->session->form->process("keyword")
		});
	$var{'form.submit'} = WebGUI::Form::submit($self->session,{
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
				$data->{form} = WebGUI::Form::text($self->session,{
					name=>$data->{name},
					value=>$self->session->form->process($data->{name})
					});
			} else {
				$data->{form} = WebGUI::Form::checkbox($self->session,{
					name=>$data->{name},
					value=>"1",
					checked=>$self->session->form->process($data->{name})
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
	if ($self->session->user->userId eq '1') {
		my $out = WebGUI::Cache->new($self->session,"view_".$self->getId)->get;
		return $out if $out;
	}
        my (%var);
	$var{'compare.form'} = $self->getCompareForm;
	$var{'search.url'} = $self->getUrl("func=search");
	$var{'isLoggedIn'} = ($self->session->user->userId ne "1");
	$var{'field.list.url'} = $self->getUrl('func=listFields');	
	$var{'listing.add.url'} = $self->formatURL("editListing","new");

	my $data = $self->session->db->quickHashRef("select views, productName, listingId from Matrix_listing 
		 where assetId=".$self->session->db->quote($self->getId)." and status='approved' order by views desc limit 1");
	$var{'best.views.url'} = $self->formatURL("viewDetail",$data->{listingId});
	$var{'best.views.count'} = $data->{views}; 
	$var{'best.views.name'} = $data->{productName}; 
	$data = $self->session->db->quickHashRef("select compares, productName, listingId from Matrix_listing 
		where assetId=".$self->session->db->quote($self->getId)." and status='approved'  order by compares desc limit 1");
	$var{'best.compares.url'} = $self->formatURL("viewDetail",$data->{listingId});
	$var{'best.compares.count'} = $data->{compares}; 
	$var{'best.compares.name'} = $data->{productName}; 
	$data = $self->session->db->quickHashRef("select clicks, productName, listingId from Matrix_listing 
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
		$data = $self->session->db->quickHashRef($sql." desc limit 1");
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
	$data = $self->session->db->quickHashRef("select lastUpdated, productName, listingId from Matrix_listing 
		where assetId=".$self->session->db->quote($self->getId)." and status='approved'  order by lastUpdated desc limit 1");
	my @lastUpdated;
        my $sth = $self->session->db->read("select listingId,lastUpdated,productName from Matrix_listing order by lastUpdated desc limit 20");
        while (my ($listingId, $lastUpdated, $productName) = $sth->array) {
                push(@lastUpdated, {
                        url => $self->formatURL("viewDetail",$listingId),
                        name=>$productName,
                        lastUpdated=>$self->session->datetime->epochToHuman($lastUpdated,"%z")
                        });
        }
        $var{'last_updated_loop'} = \@lastUpdated;
	$var{'best.updated.url'} = $self->formatURL("viewDetail",$data->{listingId});
	$var{'best.updated.date'} = $self->session->datetime->epochToHuman($data->{lastUpdated},"%z");; 
	$var{'best.updated.name'} = $data->{productName}; 

	# site stats
	($var{'user.count'}) = $self->session->db->quickArray("select count(*) from users");
	($var{'current.user.count'}) = $self->session->db->quickArray("select count(*)+0 from userSession where lastPageView>".($self->session->datetime->time()-600));
	($var{'listing.count'}) = $self->session->db->quickArray("select count(*) from Matrix_listing where status = 'approved' and assetId=".$self->session->db->quote($self->getId));
        $sth = $self->session->db->read("select listingId,productName from Matrix_listing where status='pending'");
        while (my ($id,$name) = $sth->array) {
                push(@{$var{pending_list}},{
                        url=>$self->formatURL("viewDetail",$id),
                        productName=>$name
                        });
        }
        $sth->finish;
       	my $out = $self->processTemplate(\%var,undef,$self->{_viewTemplate});
	if ($self->session->user->userId eq '1') {
		WebGUI::Cache->new($self->session,"view_".$self->getId)->set($out,$self->get("visitorCacheTimeout"));
	}
       	return $out;
}
 
#-------------------------------------------------------------------
sub www_viewDetail {
	my $self = shift;
	my $listingId = shift || $self->session->form->process("listingId");
	my $hasRated = shift || $self->hasRated($listingId);
	my %var;
	my $i18n = WebGUI::International->new($self->session,'Asset_Matrix');
	my $listing = $self->session->db->getRow("Matrix_listing","listingId",$listingId);
	my $forum = WebGUI::Asset::Wobject::Collaboration->new($self->session, $listing->{forumId});
	$var{"discussion"} = $forum->view;
	$var{'isLoggedIn'} = ($self->session->user->userId ne "1");
	if ($self->session->form->process("do") eq "sendEmail") {
		if ($self->session->form->process("body") ne "") {
			my $u = WebGUI::User->new($self->session, $listing->{maintainerId});
			my $mail = WebGUI::Mail::Send->create($self->session, {to=>$u->profileField("email"),subject=>$listing->{productName}." - ".$self->session->form->process("subject"),from=>$self->session->form->process("from")});
			$mail->addText($self->session->form->process("body"));
			$mail->queue;
		}
		$var{'email.wasSent'} = 1;
	} else {
		$self->incrementCounter($listingId,"views");
	}
	$var{'edit.url'} = $self->formatURL("editListing",$listingId);
	$var{id} = $listingId;
	$var{'user.canEdit'} = ($self->session->user->userId eq $listing->{maintainerId} || $self->canEdit);
	$var{'user.canApprove'} = $self->canEdit;
	$var{'approve.url'} = $self->getUrl("func=approveListing;listingId=".$listingId);
	$var{'delete.url'} = $self->getUrl("func=deleteListing;listingId=".$listingId);
	$var{'isPending'} = ($listing->{status} eq "pending");
	$var{'lastUpdated.epoch'} = $listing->{lastupdated};
	$var{'lastUpdated.date'} = $self->session->datetime->epochToHuman($listing->{lastUpdated},"%z");
	$var{description} = $listing->{description};
	$var{productName} = $listing->{productName};
	$var{productUrl} = $listing->{productUrl};
	$var{'productUrl.click'} = $self->formatURL("click",$listingId);
	$var{manufacturerName} = $listing->{manufacturerName};
	$var{manufacturerUrl} = $listing->{manufacturerUrl};
	$var{'manufacturerUrl.click'} = $self->getUrl("m=1;func=click;listingId=".$listingId);
	$var{versionNumber} = $listing->{versionNumber};
	my $f = WebGUI::HTMLForm->new($self->session,
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
		-label=>$i18n->get('your email'),
		);
	$f->selectBox(
		-name=>"subject",
		-extras=>'class="content"',
		-options=>{
			$i18n->get('report error')=>"Report an error.",
			$i18n->get('general comment')=>"General comment.",
			},
		-label=>$i18n->get('request type'),
		);
	$f->textarea(
		-rows=>4,
		-extras=>'class="content"',
		-columns=>35,
		-name=>"body",
		-label=>$i18n->get('comment'),
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
	$f = WebGUI::HTMLForm->new($self->session,
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
		-label=>'<a href="'.$self->formatURL("rate",$listingId).'">'.$i18n->get('show ratings').'</A>'
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
 
