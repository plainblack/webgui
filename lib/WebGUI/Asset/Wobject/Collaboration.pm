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

our @ISA = qw(WebGUI::Asset::Wobject);


#-------------------------------------------------------------------
sub appendPostListTemplateVars {
	my $self = shift;
	my $var = shift;
	my $sql = shift;
	my $p = shift;
	$p->setDataByQuery($sql);
	my $page = $p->getPageData;
	my $i = 0;
	foreach my $row (@$page) {
		my $post = WebGUI::Asset::Wobject::Collaboration->newByPropertyHashRef($row);
		$post->{_parent} = $self; # caching parent for efficiency 
		my $controls = deleteIcon('func=delete',$post->get("url"),"Delete").editIcon('func=edit',$post->get("url"));
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
		my @rating_loop;
		for (my $i=0;$i<=$post->get("rating");$i++) {
			push(@rating_loop,{'rating_loop.count'=>$i});
		}
                push(@{$var->{post_loop}}, {
			%{$post->get},
                        "id"=>$post->getId,
                        "url"=>$post->getUrl,
			rating_loop=>\@rating_loop,
			"content"=>$post->formatContent,
                        "status"=>$post->getStatus,
                        "thumbnail"=>$post->getThumbnailUrl,
                        "image.url"=>$post->getImageUrl,
                        "dateSubmitted.human"=>epochToHuman($post->get("dateSubmitted"),"%z"),
                        "dateUpdated.human"=>epochToHuman($post->get("dateUpdated"),"%z"),
                        "timeSubmitted.human"=>epochToHuman($post->get("dateSubmitted"),"%Z"),
                        "timeUpdated.human"=>epochToHuman($post->get("dateUpdated"),"%Z"),
                        "userProfile.url"=>$post->getPosterProfileUrl,
                        "user.isVisitor"=>$post->get("ownerUserId") eq "1",
        		"edit.url"=>$post->getEditUrl,
			'controls'=>$controls,
			'inDateRange'=>$inDateRange,
                        "isSecond"=>(($i+1)%2==0),
                        "isThird"=>(($i+1)%3==0),
                        "isFourth"=>(($i+1)%4==0),
                        "isFifth"=>(($i+1)%5==0),
                	"user.isPoster"=>$post->isPoster
                        });
		$i++;
	}
	$p->appendTemplateVars($var);
}

#-------------------------------------------------------------------
sub appendTemplateLabels {
	my $self = shift;
	my $var = shift;
	my $i18n = WebGUI::International->new("Collaboration");
	$var->{"add.label"} = "Add";
	$var->{"addlink.label"} = "Add a link.";
	$var->{"addquestion.label"} = "Add a question.";
        $var->{'all.label'} = "All Words";
        $var->{'atleastone.label'} = "At Least One";
	$var->{"approve.label"} = "Approve";
	$var->{'answer.label'} = "Answer";
	$var->{'attachment.label'} = "Attachment";
	$var->{"by.label"} = "By";
        $var->{'body.label'} = "Body";
	$var->{"back.label"} = "Back";
	$var->{'contentType.label'} = "Content Type";
	$var->{"date.label"} = "Date";
	$var->{"delete.label"} = "Delete";
        $var->{'description.label'} = "Description";
	$var->{"deny.label"} = "Deny";
	$var->{"edit.label"} = "Edit";
	$var->{'endDate.label'} = "End Date";
        $var->{'exactphrase.label'} = "Exact Phrase";
	$var->{"layout.flat.label"} = "Flat";
	$var->{'image.label'} = "Image";
	$var->{'link.header.label'} = "Edit Link";
	$var->{"lastReply.label"} = "Last Reply";
	$var->{"lock.label"} = "Lock";
	$var->{"layout.label"} = "Layout";
        $var->{'message.header.label'} = "Edit Message";
        $var->{'message.label'} = "Message";
	$var->{"next.label"} = "Next";
        $var->{'newWindow.label'} = "Open in new window?";
	$var->{"layout.nested.label"} = "Nested";
	$var->{"previous.label"} = "Previous";
	$var->{"post.label"} = "Add a post.";
	$var->{'question.label'} = "Question";
	$var->{'question.header.label'} = "Edit Question";
	$var->{"rating.label"} = "Rating";
	$var->{"rate.label"} = "Rate";
	$var->{"reply.label"} = "Reply";
	$var->{"replies.label"} = "Replies";
	$var->{"readmore.label"} = "Read More";
	$var->{"responses.label"} = "Responses";
        $var->{'results.label'} = "Results";
        $var->{"search.label"} = "Search";
        $var->{'subject.label'} = "Subject";
	$var->{"subscribe.label"} = "Subscribe";
        $var->{'submission.header.label'} = "Edit Submission";
	$var->{'startDate.label'} = "Start Date";
	$var->{"stick.label"} = "Make Sticky";
	$var->{"subject.label"} = "Subject";
	$var->{"status.label"} = "Status";
	$var->{"thumbnail.label"} = "Thumbnail";
	$var->{"title.label"} = "Title";
	$var->{"layout.threaded.label"} = "Threaded";
	$var->{"unlock.label"} = "Unlock";
	$var->{"unstick.label"} = "Unstick";
	$var->{"unsubscribe.label"} = "Unsubscribe";
        $var->{'url.label'} = "URL";
        $var->{"user.label"} = "User";
	$var->{"views.label"} = "Views";
        $var->{'visitorName.label'} = "Visitor Name";
        $var->{'without.label'} = "Without";
}

#-------------------------------------------------------------------
sub canModerate {
	my $self = shift;
	return WebGUI::Grouping::isInGroup($self->get("moderateGroupId")) || $self->canEdit;
}

#-------------------------------------------------------------------
sub canPost {
	my $self = shift;
	return WebGUI::Grouping::isInGroup($self->get("postGroupId")) || $self->canModerate;
}


#-------------------------------------------------------------------
sub canSubscribe {
        my $self = shift;
        return ($session{user}{userId} ne "1" && $self->canView);
}

#-------------------------------------------------------------------
sub canView {
	my $self = shift;
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
			allowReplies =>{
				fieldType=>"yesNo",
				defaultValue=>1
				},
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
		-label=>"Collaboration System Template",
		-name=>"collaborationTemplateId"
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
			asc=>"Ascending",
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
		-name=>"allowReplies",
		-label=>"Allow replies?",
		-value=>$self->getValue("allowReplies")
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
        $tabform->getTab("properties")->yesNo(
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
	my %var;
	$var{'user.canPost'} = $self->canPost;
        $var{"add.url"} = $self->getNewThreadUrl;
        $var{"rss.url"} = $self->getRssUrl;
        $var{'user.isModerator'} = $self->canModerate;
        $var{'user.isVisitor'} = ($session{user}{userId} eq '1');
	$var{'user.isSubscribed'} = $self->isSubscribed;
	$var{'sortby.date.url'} = $self->getSortByUrl("dateSubmitted");
	$var{'sortby.lastreply.url'} = $self->getSortByUrl("lastreply");
	$var{'sortby.views.url'} = $self->getSortByUrl("views");
	$var{'sortby.replies.url'} = $self->getSortByUrl("replies");
	$var{'sortby.rating.url'} = $self->getSortByUrl("rating");
	WebGUI::Style::setLink($var{"rss.url"},{ rel=>'alternate', type=>'application/rss+xml', title=>'RSS' });
	$var{"search.url"} = $self->getSearchUrl;
	$var{"subscribe.url"} = $self->getSubscribeUrl;
	$var{"unsubscribe.url"} = $self->getUnsubscribeUrl;
	my $constraints = "(Post.status='approved' or (asset.ownerUserId=".quote($session{user}{userId})." and asset.ownerUserId<>'1')";
	if ($var{canModerate}) {
		$constraints .= " or Post.status='pending'"; 
	}
	$constraints .= ")";
	my $sql = "select * 
		from Thread
		left join asset on Thread.assetId=asset.assetId
		left join Post on Post.assetId=asset.assetId 
		where asset.parentId=".quote($self->getId)." and asset.state='published' and asset.className='WebGUI::Asset::Post::Thread' and $constraints 
		order by ".$self->getValue("sortBy")." ".$self->getValue("sortOrder");
	my $p = WebGUI::Paginator->new($self->getUrl,$self->get("threadsPerPage"));
	$self->appendPostListTemplateVars(\%var, $sql, $p);
	$self->appendTemplateLabels(\%var);
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
        $var{'form.begin'} = WebGUI::Form::formHeader({action=>$self->getUrl})
         	.WebGUI::Form::hidden({ name=>"func", value=>"search" })
        	.WebGUI::Form::hidden({ name=>"doit", value=>1 });
        $var{'all.form'} = WebGUI::Form::text({
                name=>'all',
                value=>$session{scratch}{$self->getId."_all"},
                size=>($session{setting}{textBoxSize}-5)
                });
        $var{'exactphrase.form'} = WebGUI::Form::text({
                name=>'exactPhrase',
                value=>$session{scratch}{$self->getId."_exactPhrase"},
                size=>($session{setting}{textBoxSize}-5)
                });
        $var{'atleastone.form'} = WebGUI::Form::text({
                name=>'atLeastOne',
                value=>$session{scratch}{$self->getId."_atLeastOne"},
                size=>($session{setting}{textBoxSize}-5)
                });
        $var{'without.form'} = WebGUI::Form::text({
                name=>'without',
                value=>$session{scratch}{$self->getId."_without"},
                size=>($session{setting}{textBoxSize}-5)
                });
        my %results;
        tie %results, 'Tie::IxHash';
        %results = (10=>'10', 25=>'25', 50=>'50', 100=>'100');
        my $numResults = $session{scratch}{$self->getId."_numResults"} || $self->get("threadsPerPage");
        $var{'results.form'} = WebGUI::Form::selectList({
                name=>"numResults",
                options=>\%results,
                value=>[$numResults]
                });
        $var{'form.search'} = WebGUI::Form::submit({value=>WebGUI::International::get(170)});
        $var{'form.end'} = WebGUI::Form::formFooter();
        $var{'back.url'} = $self->getUrl;
        $var{doit} = $session{form}{doit};
        if ($session{form}{doit}) {
                my @fieldsToSearch = qw(asset.title asset.synopsis Post.content Post.username Post.userDefined1 Post.userDefined2 Post.userDefined3 Post.userDefined4 Post.userDefined5);
		my $all;
		if ($session{scratch}{$self->getId."_all"} ne "") {
			$session{scratch}{$self->getId."_all"} =~ s/,/ /g;
			$session{scratch}{$self->getId."_all"} =~ s/\s+/ /g;
			my @words = split(/ /,$session{scratch}{$self->getId."_all"});
			foreach my $word (@words) {
				$all .= " and " if ($all ne "");
				$all .= "(";
				my $allSub;
				foreach my $field (@fieldsToSearch) {
					$allSub .= " or " if ($allSub ne "");
					$allSub .= " $field like ".quote("%".$word."%");
				}
				$all .= $allSub;
				$allSub = "";
				$all .= ")";
			}
		}
		my $exactPhrase;
	        if ($session{scratch}{$self->getId."_exactPhrase"} ne "") {
			foreach my $field (@fieldsToSearch) {
				$exactPhrase .= " or " if ($exactPhrase ne "");
       		         	$exactPhrase .= " $field like ".quote("%".$session{scratch}{$self->getId."_exactPhrase"}."%");
			}
     	  	}
		my $atLeastOne;
        	if ($session{scratch}{$self->getId."_atLeastOne"} ne "") {
	                $session{scratch}{$self->getId."_atLeastOne"} =~ s/,/ /g;
       	         	$session{scratch}{$self->getId."_atLeastOne"} =~ s/\s+/ /g;
                	my @words = split(/ /,$session{scratch}{$self->getId."_atLeastOne"});
                	foreach my $word (@words) {
				foreach my $field (@fieldsToSearch) {
                        		$atLeastOne .= " or " if ($atLeastOne ne "");
                        		$atLeastOne .= " $field like ".quote("%".$word."%");
				}
                	}
        	}
		my $without;
        	if ($session{scratch}{$self->getId."_without"} ne "") {
                	$session{scratch}{$self->getId."_without"} =~ s/,/ /g;
                	$session{scratch}{$self->getId."_without"} =~ s/\s+/ /g;
                	my @words = split(/ /,$session{scratch}{$self->getId."_without"});
                	foreach my $word (@words) {
				foreach my $field (@fieldsToSearch) {
                        		$without .= " and " if ($without ne "");
                        		$without .= " $field not like ".quote("%".$word."%");
				}
                	}
        	}
		# please note that the SQL generated here-in is not for the feint of heart, mind, or stomach
		# this is for trained professionals only and should not be attempted at home
		my $sql = "select *
			from asset
			left join Post on Post.assetId=asset.assetId
			left join Thread on Thread.assetId=asset.assetId
			where (asset.className='WebGUI::Asset::Post' or asset.className='WebGUI::Asset::Post::Thread')
				and asset.lineage  like ".quote($self->get("lineage").'%')."
				and asset.assetId<>".quote($self->getId)."
				and (
					Post.status in ('approved','archived')";
		$sql .= "		or Post.status='pending'" if ($self->canModerate);
		$sql .= "		or (asset.ownerUserId=".quote($session{user}{userId})." and asset.ownerUserId<>'1')
					)
				and ";
		$sql .= "($all) " if ($all ne "");
		$sql .= " and " if ($sql ne "" && $exactPhrase ne "");
		$sql .= " ($exactPhrase) " if ($exactPhrase ne "");
		$sql .= " and " if ($sql ne "" && $atLeastOne ne "");
		$sql .= " ($atLeastOne) " if ($atLeastOne ne "");
		$sql .= " and " if ($sql ne "" && $without ne "");
		$sql .= " ($without) " if ($without ne "");
		$sql .= " order by Post.dateSubmitted desc";
		my $p = WebGUI::Paginator->new($self->getUrl("func=search&doit=1"),$numResults);
		$self->appendPostListTemplateVars(\%var, $sql, $p);
        }
        return  $self->processStyle($self->processTemplate(\%var, $self->get("searchTemplateId")));
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
		where asset.parentId=".quote($self->getId)." and asset.state='published' 
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
		last if ($i == $self->get("threadsPerPage"));
        }

        $xml .=qq~
</channel>
</rss>
~;
	WebGUI::HTTP::setMimeType("text/xml");
        return $xml;
}



1;



