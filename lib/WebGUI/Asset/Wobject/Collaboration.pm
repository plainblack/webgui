package WebGUI::Asset::Wobject::Collaboration;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Tie::CPHash;
use WebGUI::DateTime;
use WebGUI::Grouping;
use WebGUI::HTML;
use WebGUI::HTTP;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Paginator;
use WebGUI::Privilege;
use WebGUI::Search;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Style;
use WebGUI::URL;
use WebGUI::Utility;
use WebGUI::Asset::Wobject;
use WebGUI::Asset::USS_submission;

our @ISA = qw(WebGUI::Asset::Wobject);


#-------------------------------------------------------------------
sub appendTemplateLabels {
	my $self = shift;
	my $var = shift;
	my $i18n = WebGUI::International->new("Collaboration");
	$var->{'question.label'} = WebGUI::International::get(85,"USS");
	$var->{'title.label'} = WebGUI::International::get(35,"USS");
	$var->{'link.header.label'} = WebGUI::International::get(90,"USS");
        $var->{'visitorName.label'} = WebGUI::International::get(438);
	$var->{'question.header.label'} = WebGUI::International::get(84,"USS");
        $var->{'submission.header.label'} = WebGUI::International::get(19,"USS");
        $var->{'body.label'} = WebGUI::International::get(31,"USS");
	$var->{'answer.label'} = WebGUI::International::get(86,"USS");
        $var->{'description.label'} = WebGUI::International::get(85);
	$var->{'contentType.label'} = WebGUI::International::get(1007);
	$var->{'startDate.label'} = WebGUI::International::get(497);
	$var->{'endDate.label'} = WebGUI::International::get(498);
        $var->{'url.label'} = WebGUI::International::get(91,"USS");
        $var->{'newWindow.label'} = WebGUI::International::get(92,"USS");
        $var->{'newpost.header'} = WebGUI::International::get(1064);
        $var->{'sticky.label'} = WebGUI::International::get(1013);
        $var->{'subscribe.label'} = WebGUI::International::get(873);
        $var->{'lock.label'} = WebGUI::International::get(1012);
        $var->{'message.label'} = WebGUI::International::get(230);
        $var->{'subject.label'} = WebGUI::International::get(229);
	$var->{'image.label'} = WebGUI::International::get(32,"USS");
	$var->{'attachment.label'} = WebGUI::International::get(33,"USS");
        $var->{"user.label"} = "User";
	$var->{"title.label"} = "Title";
	$var->{"subject.label"} = "Subject";
	$var->{"status.label"} = "Status";
	$var->{"date.label"} = "Date";
	$var->{"approve.label"} = "Approve";
	$var->{"delete.label"} = "Delete";
	$var->{"deny.label"} = "Deny";
	$var->{"edit.label"} = "Edit";
	$var->{"reply.label"} = "Reply";
	$var->{"views.label"} = "Views";
	$var->{"rating.label"} = "Rating";
	$var->{"rate.label"} = "Rate";
	$var->{"layout.label"} = "Layout";
	$var->{"nested.label"} = "Nested";
	$var->{"threaded.label"} = "Threaded";
	$var->{"flat.label"} = "Flat";
	$var->{"lock.label"} = "Lock";
	$var->{"unlock.label"} = "Unlock";
	$var->{"stick.label"} = "Make Sticky";
	$var->{"unstick.label"} = "Unstick";
	$var->{"subscribe.label"} = "Subscribe";
	$var->{"unsubscribe.label"} = "Unsubscribe";
	$var->{"previous.label"} = "Previous";
	$var->{"next.label"} = "Next";
	$var->{"next.label"} = "Search";
	$var->{"back.label"} = "Back";
	$var->{"add.label"} = "Add";
}

#-------------------------------------------------------------------
sub canModerate {
	my $shift;
	return WebGUI::Grouping::isInGroup($self->get("moderateGroupId")) || $self->canEdit;
}

#-------------------------------------------------------------------
sub canPost {
	my $shift;
	return WebGUI::Grouping::isInGroup($self->get("postGroupId")) || $self->canModerate;
}


#-------------------------------------------------------------------
sub canSubscribe {
        my $self = shift;
        return ($session{user}{userId} ne "1" && $self->canView);
}

#-------------------------------------------------------------------
sub canView {
	my $shift;
	return $self->SUPER::canView || $self->canPost;
}

#-------------------------------------------------------------------
sub createSubscriptionGroup {
	my $self = shift;
	my $group = WebGUI::Group->new("new");
	$group->name($self->getId);
	$group->description("The group to store subscriptions for the collaboration system ".$self->getId);
	$group->isEditable(0);
	$group->showInForms(0);
	$group->deleteGroups([3]); # admins don't want to be auto subscribed to this thing
	$self->update({
		subscriptionGroupId=>$group->groupId
		});
}

#-------------------------------------------------------------------

=head2 decrementReplies ( )

Deccrements this reply counter.

=cut

sub decrementReplies {
        my $self = shift;
	$self->update({replies=>$self->get("replies")-1});
}


#-------------------------------------------------------------------

=head2 decrementThreads ( )

Deccrements this thread counter.

=cut

sub decrementThreads {
        my $self = shift;
	$self->update({threads=>$self->get("threads")-1});
}


#-------------------------------------------------------------------
sub definition {
	my $class = shift;
        my $definition = shift;
        push(@{$definition}, {
                tableName=>'Collaboration',
                className=>'WebGUI::Asset::Wobject::Collaboration',
                properties=>{
			threadsPerPage =>{
				fieldType=>"integer",
				defaultValue=>30
				},
			postsPerPage =>{
				fieldType=>"integer",
				defaultValue=>10
				},
			archiveAfter =>{
				fieldType=>"interval",
				defaultValue=>31536000
				},
			subscriptionGroupId =>{
				fieldType=>"hidden",
				defaultValue=>undef
				},
			lastPostDate =>{
				fieldType=>"hidden",
				defaultValue=>undef
				},
			lastPostId =>{
				fieldType=>"hidden",
				defaultValue=>undef
				},
			rating =>{
				fieldType=>"hidden",
				defaultValue=>undef
				},
			replies =>{
				fieldType=>"hidden",
				defaultValue=>undef
				},
			views =>{
				fieldType=>"hidden",
				defaultValue=>undef
				},
			threads =>{
				fieldType=>"hidden",
				defaultValue=>undef
				},
			useContentFilter =>{
				fieldType=>"yesNo",
				defaultValue=>1
				},
			filterCode =>{
				fieldType=>"filterContent",
				defaultValue=>'javascript'
				},
			allowRichEdit =>{
				fieldType=>"yesNo",
				defaultValue=>1
				},
			attachmentsPerPost =>{
				fieldType=>"integer",
				defaultValue=>0
				},
			editTimeout =>{
				fieldType=>"interval",
				defaultValue=>3600
				},
			addEditStampToPosts =>{
				fieldType=>"yesNo",
				defaultValue=>0
				},
			usePreview =>{
				fieldType=>"yesNo",
				defaultValue=>1
				},
			sortOrder =>{
				fieldType=>"selectList",
				defaultValue=>'desc'
				},
			sortBy =>{
				fieldType=>"selectList",
				defaultValue=>'dateUpdated'
				},
			notificationTemplateId =>{
				fieldType=>"template",
				defaultValue=>undef
				},
			searchTemplateId =>{
				fieldType=>"template",
				defaultValue=>undef
				},
			postFormTemplateId =>{
				fieldType=>"template",
				defaultValue=>undef
				},
			threadTemplateId =>{
				fieldType=>"template",
				defaultValue=>undef
				},
			collaborationTemplateId =>{
				fieldType=>"template",
				defaultValue=>undef
				},
			karmaPerPost =>{
				fieldType=>"integer",
				defaultValue=>0
				},
			moderatePosts =>{
				fieldType=>"yesNo",
				defaultValue=>0
				},
			moderateGroupId =>{
				fieldType=>"group",
				defaultValue=>'4'
				},
			postGroupId =>{
				fieldType=>"group",
				defaultValue=>'2'
				}
			}
		});
        return $class->SUPER::definition($definition);
}

#-------------------------------------------------------------------
sub duplicate {
	my $self = shift;
	my $newAsset = $self->SUPER::duplicate;
	$newAsset->createSubscriptionGroup;
	return $newAsset;
}



#-------------------------------------------------------------------
sub getEditForm {
	my $self = shift;
	my $tabform = $self->SUPER::getEditForm;
   	$tabform->getTab("display")->template(
      		-value=>$self->getValue('collaborationTemplateId'),
      		-namespace=>"Collaboration",
		-label=>"Collaboration System Template"
   		);
        $tabform->getTab("display")->template(
                -name=>"threadTemplateId",
                -value=>$self->getValue("threadTemplateId"),
                -namespace=>"Collaboration/Thread",
                -label=>"Thread Template"
                );
        $tabform->getTab("display")->template(
                -name=>"postFormTemplateId",
                -value=>$self->getValue("postFormTemplateId"),
                -namespace=>"Collaboration/PostForm",
                -label=>"Post Form Template"
                );
        $tabform->getTab("display")->template(
                -name=>"searchTemplateId",
                -value=>$self->getValue("SearchTemplateId"),
                -namespace=>"Collaboration/Search",
                -label=>"Search Template"
                );
        $tabform->getTab("display")->template(
                -name=>"notificationTemplateId",
                -value=>$self->getValue("notificationTemplateId"),
                -namespace=>"Collaboration/Notification",
                -label=>"Notification Template"
                );
        $tabform->getTab("security")->group(
		-name=>"moderateGroupId",
		-label=>"Who can moderate?",
		-value=>[$self->getValue("moderateGroupId")]
		);
        $tabform->getTab("security")->group(
		-name=>"postGroupId",
		-label=>"Who can post?",
		-value=>[$self->getValue("postGroupId")]
		);
        $tabform->getTab("display")->integer(
		-name=>"threadsPerPage",
		-label=>"Threads Per Page",
		-value=>$self->getValue("threadsPerPage")
		);
        $tabform->getTab("display")->integer(
		-name=>"postsPerPage",
		-label=>"Posts Per Page",
		-value=>$self->getValue("postsPerPage")
		);
        if ($session{setting}{useKarma}) {
                $tabform->getTab("properties")->integer(
			-name=>"karmaPerPost",
			-label=>"Karma Per Post",
			-value=>$self->getValue("karmaPerPost")
			);
        } else {
                $tabform->getTab("properties")->hidden("karmaPerPost",$self->getValue("karmaPerPost"));
        }
	$tabform->getTab("security")->filterContent(
		-value=>$self->getValue("filterCode"),
		-name=>"filterCode",
		-label=>"Filter Code"
		);
	$tabform->getTab("display")->selectList(
		-name=>"sortBy",
		-value=>[$self->getValue("sortBy")],
		-options=>{
			lineage=>"Sequence",
			dateUpdated=>"Date Updated",
			dateSubmitted=>"Date Submitted",
			title=>"Title"
			},
		-label=>"Sort By"
		);
	$tabform->getTab("display")->selectList(
		-name=>"sortOrder",
		-value=>[$self->getValue("sortOrder")],
		-options=>{
			asc=>"Ascending"
			desc=>"Descending"
			},
		-label=>"Sort Order"
		);
        $tabform->getTab("properties")->interval(
		-name=>"archiveAfter",
		-label=>"Archive After",
		-value=>$self->getValue("archiveAfter")
		);
        $tabform->getTab("properties")->integer(
		-name=>"attachmentsPerPost",
		-label=>"Attachments Per Post",
		-value=>$self->getValue("attachmentsPerPost")
		);
        $tabform->getTab("security")->interval(
		-name=>"editTimeout",
		-label=>"Edit Timeout",
		-value=>$self->getValue("editTimeout")
		);
        $tabform->getTab("security")->yesNo(
		-name=>"addEditStampToPosts",
		-label=>"Add edit stamp to posts?",
		-value=>$self->getValue("addEditStampToPosts")
		);
        $tabform->getTab("display")->yesNo(
		-name=>"allowRichEdit",
		-label=>"Allow rich edit?",
		-value=>$self->getValue("allowRichEdit")
		);
        $tabform->getTab("display")->yesNo(
		-name=>"useContentFilter",
		-label=>"Use content filter?",
		-value=>$self->getValue("useContentFilter")
		);
        $tabform->getTab("display")->yesNo(
		-name=>"usePreview",
		-label=>"Use preview?",
		-value=>$self->getValue("usePreview")
		);
        $tabform->getTab("security")->yesNo(
		-name=>"moderatePosts",
		-label=>"Moderate posts?",
		-value=>$self->getValue("moderatePosts")
		);
	return $tabform;
}

#-------------------------------------------------------------------
sub getIcon {
	my $self = shift;
	my $small = shift;
	return $session{config}{extrasURL}.'/assets/small/collaboration.gif' if ($small);
	return $session{config}{extrasURL}.'/assets/collaboration.gif';
}


#-------------------------------------------------------------------
sub getName {
        return "Collaboration System";
}


#-------------------------------------------------------------------

=head2 getNewThreadUrl(  )

Formats the url to start a new thread.

=cut

sub getNewThreadUrl {
	my $self = shift;
	$self->getUrl("func=add&class=WebGUI::Asset::Post::Thread");
}

#-------------------------------------------------------------------

=head2 getRssUrl (  )

Formats the url to start a new thread.

=cut

sub getRssUrl {
	my $self = shift;
	$self->getUrl("func=viewRSS");
}

#-------------------------------------------------------------------

=head2 getSearchUrl (  )

Formats the url to the forum search engine.

=cut

sub getSearchUrl {
	my $self = shift;
	return $self->getUrl("func=search");
}

#-------------------------------------------------------------------

=head2 getSortByUrl ( sortBy )

Formats the url to change the default sort.

=head3 sortBy

The sort by string. Can be views, rating, date replies, or lastreply.

=cut

sub getSortByUrl {
	my $self = shift;
	my $sortBy = shift;
	return $self->getUrl("sortBy=".$sortBy);
}

#-------------------------------------------------------------------

=head2 getSubscribeUrl (  )

Formats the url to subscribe to the forum.

=cut

sub getSubscribeUrl {
	my $self = shift;
	return $self->getUrl("func=subscribe");
}

#-------------------------------------------------------------------

=head2 getUnsubscribeUrl ( )

Formats the url to unsubscribe from the forum.

=cut

sub getUnsubscribeUrl {
	my $self = shift;
	return $self->getUrl("func=unsubscribe");
}


#-------------------------------------------------------------------

=head2 incrementReplies ( lastPostDate, lastPostId )

Increments this forum's reply counter.

=head3 lastPostDate

The date of the post being added.

=head3 lastPostId

The unique identifier of the post being added.

=cut

sub incrementReplies {
        my ($self, $lastPostDate, $lastPostId) = @_;
        $self->update({replies=>$self->get("replies")+1, lastPostId=>$lastPostId, lastPostDate=>$lastPostDate});
}

#-------------------------------------------------------------------

=head2 incrementThreads ( lastPostDate, lastPostId )

Increments the thread counter for this forum.

=head3 lastPostDate

The date of the post that was just added.

=head3 lastPostId

The unique identifier of the post that was just added.

=cut

sub incrementThreads {
        my ($self, $lastPostDate, $lastPostId) = @_;
        $self->update({threads=>$self->get("threads")+1, lastPostId=>$lastPostId, lastPostDate=>$lastPostDate});
}

#-------------------------------------------------------------------

=head2 incrementViews ( )

Increments the views counter on this forum.

=cut

sub incrementViews {
        my ($self) = @_;
        $self->update({views=>$self->get("views")+1});
}

#-------------------------------------------------------------------

=head2 isSubscribed (  )

Returns a boolean indicating whether the user is subscribed to the forum.

=cut

sub isSubscribed {
        my $self = shift;
	return WebGUI::Grouping::isInGroup($self->get("subscriptionGroupId"));	
}

#-------------------------------------------------------------------
sub processPropertiesFromFormPost {
	my $self = shift;
	$self->SUPER::processPropertiesFromFormPost;
	if ($session{form}{func} eq "add") {
		$self->createSubscriptionGroup;
	}
}


#-------------------------------------------------------------------
sub purge {
	my $self = shift;
	my $group = WebGUI::Group->new($self->get("subscriptionGroupId"));
	$group->delete;
	$self->SUPER::purge;
}

#-------------------------------------------------------------------

=head2 recalculateRating ( )

Calculates the rating of this forum from its threads and stores the new value in the forum properties.

=cut

sub recalculateRating {
        my $self = shift;
        my ($count) = WebGUI::SQL->quickArray("select count(*) from Thread left join asset on Thread.assetId=asset.assetId 
		where asset.parentId=".quote($self->getId)." and Thread.rating>0");
        $count = $count || 1;
        my ($sum) = WebGUI::SQL->quickArray("select sum(Thread.rating) from Thread left join asset on Thread.assetId=asset.assetId where asset.parentId=".quote($self->getId)." and Thread.rating>0");
        my $average = round($sum/$count);
        $self->update({rating=>$average});
}


#-------------------------------------------------------------------

=head2 setLastPost ( lastPostDate, lastPostId )

Sets the pertinent details for the last post. Can also be done directly using the set method.

=head3 lastPostDate

The epoch date of the post.

=head3 lastPostId

The asset id of the post.

=cut

sub setLastPost {
        my ($self, $postDate, $postId) = @_;
        $self->update({
                lastPostId=>$postId,
                lastPostDate=>$postDate
                });
}


#-------------------------------------------------------------------

=head2 subscribe ( )

Subscribes a user to this collaboration system.

=cut

sub subscribe {
	my $self = shift;
	unless ($self->isSubscribed) {
		WebGUI::Grouping::addUsersToGroups([$session{user}{userId}],[$self->get("subscriptionGroupId")]);
        }
}

#-------------------------------------------------------------------

=head2 unsubscribe (  )

Unsubscribes a user from this collaboration system

=cut

sub unsubscribe {
	my $self = shift;
	if ($self->isSubscribed) {
		WebGUI::Grouping::deleteUsersFromGroups([$session{user}{userId}],[$self->get("subscriptionGroupId")]);
        }
}


#-------------------------------------------------------------------
sub view {
	my $self = shift;
	my $scratchSortBy = $self->getId."_sortBy";
	my $scratchSortDir = $self->getId."_sortDir";
        if($session{scratch}{$scratchSortBy} ne $session{form}{sortBy}){
                WebGUI::Session::setScratch($scratchSortBy,$session{form}{sortBy});
                WebGUI::Session::setScratch($scratchSortDir, "desc");
        }else{
                my $sortDir;
                if($session{scratch}{$scratchSortDir} eq "asc"){
                        $sortDir = "desc";
                }else{
                        $sortDir = "asc";
                }
                WebGUI::Session::setScratch($scratchSortDir, $sortDir);
        }
	my $numResults = $self->get("threadsPerPage");
	my %var;
	$var{"readmore.label"} = "Read More";
	$var{"responses.label"} = "Responses";
	$var{"post.label"} = "Add a post.";
	$var{"addquestion.label"} = "Add a question.";
	$var{"addlink.label"} = "Add a link.";
        $var{"search.label"} = "Search";
	$var{"title.label"} = WebGUI::International::get(99);
	$var{"thumbnail.label"} = WebGUI::International::get(52,"USS");
	$var{"date.label"} = WebGUI::International::get(13,"USS");
	$var{"date.updated.label"} = WebGUI::International::get(78,"USS");
	$var{"by.label"} = WebGUI::International::get(21,"USS");
	$var{"submission.edit.label"} = WebGUI::International::get(27,"USS");
	$var{canPost} = $self->canPost;
        $var{"post.url"} = $self->getNewThreadUrl;
        $var{"rss.url"} = $self->getRssUrl;
        $var{canModerate} = $self->canModerate;
	WebGUI::Style::setLink($var{"rss.url"},{ rel=>'alternate', type=>'application/rss+xml', title=>'RSS' });
	#$var{"search.Form"} = WebGUI::Search::form({func=>'view',search=>1});
	#$var{"search.url"} = WebGUI::Search::toggleURL("func=view");
	my $constraints;
	#if ($session{scratch}{search}) {
        #        $numResults = $session{scratch}{numResults};
       #		$constraints = WebGUI::Search::buildConstraints([qw(Post.username asset.synopsis asset.title Post.content Post.userDefined1 Post.userDefined2 Post.userDefined3 Post.userDefined4 Post.userDefined5)]);
#	}
#	if ($constraints ne "") {
 #       	$constraints = "Post.status='approved' and ".$constraints;
#	} else {
		$constraints = "(Post.status='approved' or (asset.ownerUserId=".quote($session{user}{userId})." and asset.ownerUserId<>'1')";
		if ($var{canModerate}) {
			$constraints .= " or Post.status='pending'"; 
		}
		$constraints .= ")";
	#}
	my $p = WebGUI::Paginator->new($self->getUrl,$numResults);
	my $sql = "select * 
		from Thread
		left join asset on Thread.assetId=asset.assetId
		left join Post on Post.assetId=asset.assetId 
		where Thread.parentId=".quote($self->getId)." and asset.state='published' and asset.className='WebGUI::Asset::Post::Thread' and $constraints 
		order by ".$self->getValue("sortBy")." ".$self->getValue("sortOrder");
	$p->setDataByQuery($sql);
	my $page = $p->getPageData;
	my $i = 0;
	my $imageURL = "";
	foreach my $row (@$page) {
		my $post = WebGUI::Asset::Post->newByPropertyHashRef($row);
		$post->{_parent} = $self; # caching parent for efficiency 
		my $controls = deleteIcon('func=delete',$post->get("url"),"Delete").editIcon('func=edit',$post->get("ur"));
		if ($self->get("sortBy") eq "lineage") {
			if ($self->get("sortOrder") eq "desc") {
				$controls .= moveUpIcon('func=demote',$post->get("url")).moveDownIcon('func=promote',$post->get("url"));
			} else {
				$controls .= moveUpIcon('func=promote',$post->get("url")).moveDownIcon('func=demote',$post->get("url"));
			}
		}
		my $inDateRange;
		if ($post->get("startDate") < WebGUI::DateTime::time() && $post->get("endDate") > WebGUI::DateTime::time()) {
		  	$inDateRange = 1;
		} else { 
			$inDateRange = 0; 
		}
                push(@{$var{submissions_loop}}, {
                        "id"=>$post->getId,
                        "url"=>$post->getUrl,
                        "synopsis"=>$post->get("synopsis"),
			"content"=>$self->formatContent,
			"reply.count"=>$post->get("replies"),
                        "title"=>$post->get("title"),
                        "userDefined1"=>$post->get("userDefined1"),
                        "userDefined2"=>$post->get("userDefined2"),
                        "userDefined3"=>$post->get("userDefined3"),
                        "userDefined4"=>$post->get("userDefined4"),
                        "userDefined5"=>$post->get("userDefined5"),
                        "userId"=>$post->get("userId"),
                        "username"=>$post->get('username'),
                        "status"=>$self->status($post->get("status")),
                      #  "thumbnail"=>$submission->getThumbnailUrl,
                       # "submission.image"=>$submission->getImageUrl,
                        "date.submitted"=>epochToHuman($post->get("dateSubmitted")),
                        "date.updated"=>epochToHuman($post->get("dateUpdated")),
                        "userProfile.url"=>$post->getUserProfileUrl,
        		"edit.url"=>$post->getEditUrl,
			'controls'=>$controls,
			'inDateRange'=>$inDateRange,
                        "isSecond"=>(($i+1)%2==0),
                        "isThird"=>(($i+1)%3==0),
                        "isFourth"=>(($i+1)%4==0),
                        "isFifth"=>(($i+1)%5==0),
                	"currentUserIsPoster"=>$post->isPoster
                        });
		$i++;
	}
	$p->appendTemplateVars(\%var);
	return $self->processTemplate(\%var,$self->get("collaborationTemplateId"));
}

#-------------------------------------------------------------------
sub www_edit {
        my $self = shift;
	return $self->getAdminConsole->render(WebGUI::Privilege::insufficient()) unless $self->canEdit;
#	$self->getAdminConsole->setHelp("user submission system add/edit");
        return $self->getAdminConsole->render($self->getEditForm->print,"Edit Collaboration System");
}

#-------------------------------------------------------------------

=head2 www_search ( )

The web method to display and use the forum search interface.

=cut

sub www_search {
	my $self = shift;
        WebGUI::Session::setScratch($self->getId."_all",$session{form}{all});
        WebGUI::Session::setScratch($self->getId."_atLeastOne",$session{form}{atLeastOne});
        WebGUI::Session::setScratch($self->getId."_exactPhrase",$session{form}{exactPhrase});
        WebGUI::Session::setScratch($self->getId."_without",$session{form}{without});
        WebGUI::Session::setScratch($self->getId."_numResults",$session{form}{numResults});
        my %var;
        $var{'callback.label'} = WebGUI::International::get(1039);
        $var{'form.begin'} = WebGUI::Form::formHeader({action=>$self->getUrl});
        $var{'form.begin'} .= WebGUI::Form::hidden({ name=>"forumOp", value=>"search" });
        $var{'form.begin'} .= WebGUI::Form::hidden({ name=>"doit", value=>1 });
        $var{'form.begin'} .= WebGUI::Form::hidden({ name=>"forumId", value=>$session{form}{forumId} });
        $var{'search.label'} = WebGUI::International::get(364);
        $var{'all.label'} = WebGUI::International::get(530);
        $var{'all.form'} = WebGUI::Form::text({
                name=>'all',
                value=>$session{scratch}{all},
                size=>($session{setting}{textBoxSize}-5)
                });
        $var{'exactphrase.label'} = WebGUI::International::get(531);
        $var{'exactphrase.form'} = WebGUI::Form::text({
                name=>'exactPhrase',
                value=>$session{scratch}{exactPhrase},
                size=>($session{setting}{textBoxSize}-5)
                });
        $var{'atleastone.label'} = WebGUI::International::get(532);
        $var{'atleastone.form'} = WebGUI::Form::text({
                name=>'atLeastOne',
                value=>$session{scratch}{atLeastOne},
                size=>($session{setting}{textBoxSize}-5)
                });
        $var{'without.label'} = WebGUI::International::get(533);
        $var{'without.form'} = WebGUI::Form::text({
                name=>'without',
                value=>$session{scratch}{without},
                size=>($session{setting}{textBoxSize}-5)
                });
        $var{'results.label'} = WebGUI::International::get(529);
        my %results;
        tie %results, 'Tie::IxHash';
        %results = (10=>'10', 25=>'25', 50=>'50', 100=>'100');
        my $numResults = $session{scratch}{numResults} || 25;
        $var{'results.form'} = WebGUI::Form::selectList({
                name=>"numResults",
                options=>\%results,
                value=>[$numResults]
                });
        $var{'form.search'} = WebGUI::Form::submit({value=>WebGUI::International::get(170)});
        $var{'form.end'} = WebGUI::Form::formFooter();
        $var{'thread.list.url'} = formatForumURL($caller->{callback},$forum->get("forumId"));
        $var{'thread.list.label'} = WebGUI::International::get(1019);
        $var{doit} = $session{form}{doit};
        if ($session{form}{doit}) {
                $var{'post.subject.label'} = WebGUI::International::get(229);
                $var{'post.date.label'} = WebGUI::International::get(245);
                $var{'post.user.label'} = WebGUI::International::get(244);
                my $constraints = WebGUI::Search::buildConstraints([qw(a.subject a.username a.message)]);
                my $query = "select a.forumPostId, a.subject, a.userId, a.username, a.dateOfPost from forumPost a left join forumThread b
                        on a.forumThreadId=b.forumThreadId where b.forumId=".quote($forum->get("forumId"))." and
                        (a.status='approved' or a.status='archived') and $constraints order by a.dateOfPost desc";
                my $p = WebGUI::Paginator->new(WebGUI::URL::append($caller->{callback},"forumOp=search&amp;doit=1&amp;forumId=".quote($forum->get("forumId"))), $numResults);
                $p->setDataByQuery($query) if $constraints;
                my @post_loop;
                foreach my $row (@{$p->getPageData}) {
                        push(@post_loop,{
                                'post.subject'=>$row->{subject},
                                'post.url'=>formatThreadURL($caller->{callback},$row->{forumPostId}),
                                'post.user.name'=>$row->{username},
                                'post.user.id'=>$row->{userId},
                                'post.user.profile'=>formatUserProfileURL($row->{userId}),
                                'post.epoch'=>$row->{dateOfPost},
                                'post.date'=>formatPostDate($row->{dateOfPost}),
                                'post.time'=>formatPostTime($row->{dateOfPost})
                                });
                }
                $var{post_loop} = \@post_loop;
                $var{firstPage} = $p->getFirstPageLink;
                $var{lastPage} = $p->getLastPageLink;
                $var{nextPage} = $p->getNextPageLink;
                $var{pageList} = $p->getPageLinks;
                $var{previousPage} = $p->getPreviousPageLink;
                $var{multiplePages} = ($p->getNumberOfPages > 1);
                $var{numberOfPages} = $p->getNumberOfPages;
                $var{pageNumber} = $p->getPageNumber;
        }
        return WebGUI::Template::process($forum->get("searchTemplateId"),"Forum/Search", \%var);
}

#-------------------------------------------------------------------

=head2 www_subscribe (  )

The web method to subscribe to a collaboration.

=cut

sub www_subscribe {
	my $self = shift;
	$self->subscribe if $self->canSubscribe;
        return $self->www_view;
}

#-------------------------------------------------------------------

=head2 www_unsubscribe (  )

The web method to unsubscribe from a collaboration.

=cut

sub www_unsubscribe {
	my $self = shift;
	$self->unsubscribe if $self->canSubscribe;
	return $self->www_view;
}

#-------------------------------------------------------------------
# format the date according to rfc 822 (for RSS export)
my @_months = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
sub _get_rfc822_date {
        my ($time) = @_;
        my ($year, $mon, $mday, $hour, $min, $sec) = WebGUI::DateTime::localtime($time);
        my $month = $_months[$mon - 1];
        return sprintf("%02d %s %04d %02d:%02d:%02d GMT", 
                       $mday, $month, $year, $hour, $min, $sec);
}
  
#-------------------------------------------------------------------
# encode a string to include in xml (for RSS export)
sub _xml_encode {
	my $text = shift;
        $text =~ s/&/&amp;/g;
        $text =~ s/</&lt;/g;
        $text =~ s/\]\]>/\]\]&gt;/g;
        return $text;
}

#-------------------------------------------------------------------
# print out RSS 2.0 feed describing the items visible on the first page
sub www_viewRSS {
	my $self = shift;
	$self->logView() if ($session{setting}{passiveProfilingEnabled});        
        my $encTitle = _xml_encode($self->get("title"));
        my $encDescription = _xml_encode($self->get("description"));  
        my $encUrl = _xml_encode($self->getUrl);
        my $xml = qq~<?xml version="1.0"?>
<rss version="2.0">
<channel>
<title>$encTitle</title>
<link>$encUrl</link>
<description>$encDescription</description>
~;
	my $sth = WebGUI::SQL->read("select * 
		from Thread
		left join asset on Thread.assetId=asset.parentId
		left join Post on Post.assetId=asset.assetId 
		where Thread.parentId=".quote($self->getId)." and asset.state='published' 
			and asset.className='WebGUI::Asset::Post::Thread' and Post.status='approved'
		order by ".$self->getValue("sortBy")." ".$self->getValue("sortOrder"));
	my $i = 1;
        while (my $data = $sth->hashref) {
		my $post = WebGUI::Asset::Post::Thread->newByPropertyHashRef($data);

                my $encUrl = _xml_encode($post->getUrl);
                my $encTitle = _xml_encode($post->get("title"));
                my $encPubDate = _xml_encode(_get_rfc822_date($post->get("dateUpdated")));
                my $encDescription = _xml_encode($self->get("synopsis"));
                $xml .= qq~
<item>
<title>$encTitle</title>
<link>$encUrl</link>
<description>$encDescription</description>
<guid isPermaLink="true">$encUrl</guid>
<pubDate>$encPubDate</pubDate>
</item>
~;
		$i++;
		last if ($i == $$self->get("threadsPerPage");
        }

        $xml .=qq~
</channel>
</rss>
~;
	WebGUI::HTTP::setMimeType("text/xml");
        return $xml;
}



1;

package WebGUI::Search;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2005 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut


use strict;
use Tie::IxHash;
use WebGUI::HTMLForm;
use WebGUI::International;
use WebGUI::Session;
use WebGUI::SQL;


=head1 NAME

Package WebGUI::Search

=head1 DESCRIPTION

A package built to take the hassle out of creating advanced search functionality in WebGUI applications.

=head1 SYNOPSIS

 use WebGUI::Search;
 $sql = WebGUI::Search::buildConstraints(\@fields);
 $html = WebGUI::Search::form(\%hidden);

=head1 METHODS

These methods are available from this package:

=cut


#-------------------------------------------------------------------

=head2 buildConstraints ( fieldList ) { [ all, atLeastOne, exactPhrase, without ] }

Generates and returns the constraints to an SQL where clause based upon input from the user.

=head3 fieldList

An array reference that contains a list of the fields (table columns) to be considered when searching.

=head3 all

A form param with a comma or space separated list of key words to search for in the fields of the fieldList. All the words listed here must be found to be true.

=head3 atLeastOne

A form param with a comma or space separated list of key words to search for in the fields of the fieldList. Any of the words may match in any of the fields for this to be true.

=head3 exactPhrase

A form param with a phrase to search for in the fields of the fieldList. The exact phrase must be found in one of the fields to be true.

=head3 without

A form param with a comma or space separated list of key words to search for in the fields of the fieldList. None of the words may be found in any of the fields for this to be true.

=cut

sub buildConstraints {
	my ($field, $all, $allSub, $exactPhrase, $atLeastOne, $without, @words, $word, $sql);
	if ($session{scratch}{all} ne "") {
		$session{scratch}{all} =~ s/,/ /g;
		$session{scratch}{all} =~ s/\s+/ /g;
		@words = split(/ /,$session{scratch}{all});
		foreach $word (@words) {
			$all .= " and " if ($all ne "");
			$all .= "(";
			foreach $field (@{$_[0]}) {
				$allSub .= " or " if ($allSub ne "");
				$allSub .= " $field like ".quote("%".$word."%");
			}
			$all .= $allSub;
			$allSub = "";
			$all .= ")";
		}
	}
        if ($session{scratch}{exactPhrase} ne "") {
		foreach $field (@{$_[0]}) {
			$exactPhrase .= " or " if ($exactPhrase ne "");
                	$exactPhrase .= " $field like ".quote("%".$session{scratch}{exactPhrase}."%");
		}
        }
        if ($session{scratch}{atLeastOne} ne "") {
                $session{scratch}{atLeastOne} =~ s/,/ /g;
                $session{scratch}{atLeastOne} =~ s/\s+/ /g;
                @words = split(/ /,$session{scratch}{atLeastOne});
                foreach $word (@words) {
			foreach $field (@{$_[0]}) {
                        	$atLeastOne .= " or " if ($atLeastOne ne "");
                        	$atLeastOne .= " $field like ".quote("%".$word."%");
			}
                }
        }
        if ($session{scratch}{without} ne "") {
                $session{scratch}{without} =~ s/,/ /g;
                $session{scratch}{without} =~ s/\s+/ /g;
                @words = split(/ /,$session{scratch}{without});
                foreach $word (@words) {
			foreach $field (@{$_[0]}) {
                        	$without .= " and " if ($without ne "");
                        	$without .= " $field not like ".quote("%".$word."%");
			}
                }
        }
	$sql = "($all) " if ($all ne "");
	$sql .= " and " if ($sql ne "" && $exactPhrase ne "");
	$sql .= " ($exactPhrase) " if ($exactPhrase ne "");
	$sql .= " and " if ($sql ne "" && $atLeastOne ne "");
	$sql .= " ($atLeastOne) " if ($atLeastOne ne "");
	$sql .= " and " if ($sql ne "" && $without ne "");
	$sql .= " ($without) " if ($without ne "");
	return $sql;
}

#-------------------------------------------------------------------

=head2 form ( hiddenFields ) { [ numResults ] }

Generates and returns the advanced search form.

=head3 hiddenFields

A hash reference that contains any name/value pairs that should be included as hidden fields in the search form.

=head3 numResults

A form param that can optionally specify the number of results to display. Defaults to 25.

=cut

sub form {
	WebGUI::Session::setScratch("all",$session{form}{all});
	WebGUI::Session::setScratch("atLeastOne",$session{form}{atLeastOne});
	WebGUI::Session::setScratch("exactPhrase",$session{form}{exactPhrase});
	WebGUI::Session::setScratch("without",$session{form}{without});
	WebGUI::Session::setScratch("numResults",$session{form}{numResults});
        my ($key, $numResults, $output, $f, $resultsText, %results);
        tie %results, 'Tie::IxHash';
        $numResults = $session{scratch}{numResults} || 25;
        $resultsText = WebGUI::International::get(529);
        %results = (10=>'10 '.$resultsText, 25=>'25 '.$resultsText, 50=>'50 '.$resultsText, 100=>'100 '.$resultsText);
        $f = WebGUI::HTMLForm->new(1);
        foreach $key (keys %{$_[0]}) {
                $f->hidden($key,${$_[0]}{$key});
        }
        $output = '<table width="100%" class="tableMenu"><tr><td align="right" width="15%">';
        $output .= '<h1>'.WebGUI::International::get(364).'</h1>';
        $output .= '</td>';
        $f->raw('<td valign="top" width="70%" align="center">');
        $f->raw('<table>');
        $f->raw('<tr><td class="tableData">'.WebGUI::International::get(530).'</td><td class="tableData">');
        $f->text('all','',$session{scratch}{all},'','','',($session{setting}{textBoxSize}-5));
        $f->raw('</td></tr>');
        $f->raw('<tr><td class="tableData">'.WebGUI::International::get(531).'</td><td class="tableData">');
        $f->text('exactPhrase','',$session{scratch}{exactPhrase},'','','',($session{setting}{textBoxSize}-5));
        $f->raw('</td></tr>');
        $f->raw('<tr><td class="tableData">'.WebGUI::International::get(532).'</td><td class="tableData">');
        $f->text('atLeastOne','',$session{scratch}{atLeastOne},'','','',($session{setting}{textBoxSize}-5));
        $f->raw('</td></td>');
        $f->raw('<tr><td class="tableData">'.WebGUI::International::get(533).'</td><td class="tableData">');
        $f->text('without','',$session{scratch}{without},'','','',($session{setting}{textBoxSize}-5));
        $f->raw('</td></tr>');
        $f->raw('</table>');
        $f->raw('</td><td width="15%">');
        $f->selectList("numResults",\%results,'',[$numResults]);
        $f->raw('<p/>');
        $f->submit(WebGUI::International::get(170));
        $f->raw('</td>');
        $output .= $f->print;
        $output .= '</tr></table>';
        return $output;
}

#-------------------------------------------------------------------

=head2 toggleURL ( [ pairs ] )

Returns a URL that toggles the value "search" in the user's scratch
variables on and off.

=head3 pairs

URL name value pairs (this=that&foo=bar) to be passed with this toggle.

=cut

sub toggleURL {
	my $pairs = shift;
	my $url = shift || $session{page}{urlizedTitle};
	WebGUI::Session::setScratch("search",$session{form}{search});
	if ($session{scratch}{search}) {
		$url = WebGUI::URL::gateway($url,"search=0");
	} else {
		$url = WebGUI::URL::gateway($url,"search=1");
	}
	$url = WebGUI::URL::append($url,$pairs) if ($pairs);
	return $url;
}

1;


