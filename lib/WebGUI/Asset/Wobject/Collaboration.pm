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
use Tie::IxHash;
use WebGUI::DateTime;
use WebGUI::Group;
use WebGUI::Grouping;
use WebGUI::HTML;
use WebGUI::HTTP;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Paginator;
use WebGUI::Privilege;
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
		my $post = WebGUI::Asset::Wobject::Collaboration->new($row->{assetId}, $row->{className}, $row->{revisionDate});
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
		my %lastReply;
		if ($post->get("className") =~ /Thread/) {
			my $lastPost = $post->getLastPost();
			if ($self->get("displayLastReply")) {
				%lastReply = (
					"lastReply.url"=>$lastPost->getUrl.'#'.$lastPost->getId,
                        		"lastReply.title"=>$lastPost->get("title"),
                        		"lastReply.user.isVisitor"=>$lastPost->get("ownerUserId") eq "1",
                        		"lastReply.username"=>$lastPost->get("username"),
                       	 		"lastReply.userProfile.url"=>$lastPost->WebGUI::Asset::Post::getPosterProfileUrl(),
                        		"lastReply.dateSubmitted.human"=>epochToHuman($lastPost->get("dateSubmitted"),"%z"),
                        		"lastReply.timeSubmitted.human"=>epochToHuman($lastPost->get("dateSubmitted"),"%Z")
					);
			}
		}
		my $url;
		if ($post->get("status") eq "pending" || $post->get("status") eq "denied") {
			$url = $post->getUrl("revision=".$post->get("revisionDate"))."#".$post->getId;
		} else {
			$url = $post->getUrl."#".$post->getId;
		}
		my $avatarUrl;
		if ($self->get('avatarsEnabled')) {
			#ownerUserId from post
			#Create user object.
			my $user = WebGUI::User->new($post->get('ownerUserId'));
			#Get avatar field, storage Id.
			my $storageId = $user->get("avatar");
			my $avatar = WebGUI::Storage->get($storageId);
			#Get url from storage object.
			$avatarUrl = $avatar->getUrl;
		}
                push(@{$var->{post_loop}}, {
			%{$post->get},
                        "id"=>$post->getId,
                        "url"=>$url,
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
                	"user.isPoster"=>$post->isPoster,
                	"avatar.url"=>$avatarUrl,
			%lastReply
                        });
		$i++;
	}
	$p->appendTemplateVars($var);
}

#-------------------------------------------------------------------
sub appendTemplateLabels {
	my $self = shift;
	my $var = shift;
	my $i18n = WebGUI::International->new("Asset_Collaboration");
	$var->{"add.label"} = $i18n->get("add");
	$var->{"addlink.label"} = $i18n->get("addlink");
	$var->{"addquestion.label"} = $i18n->get("addquestion");
        $var->{'all.label'} = $i18n->get("all");
        $var->{'atleastone.label'} = $i18n->get("atleastone");
	$var->{"approve.label"} = $i18n->get("approve");
	$var->{'answer.label'} = $i18n->get("answer");
	$var->{'attachment.label'} = $i18n->get("attachment");
	$var->{"by.label"} = $i18n->get("by");
        $var->{'body.label'} = $i18n->get("body");
	$var->{"back.label"} = $i18n->get("back");
	$var->{'compensation.label'} = $i18n->get("compensation");
	$var->{'contentType.label'} = $i18n->get("contentType");
	$var->{"date.label"} = $i18n->get("date");
	$var->{"delete.label"} = $i18n->get("delete");
        $var->{'description.label'} = $i18n->get("description");
	$var->{"deny.label"} = $i18n->get("deny");
	$var->{"edit.label"} = $i18n->get("edit");
	$var->{'endDate.label'} = $i18n->get("endDate");
        $var->{'exactphrase.label'} = $i18n->get("exactPhrase");
	$var->{'image.label'} = $i18n->get("image");
	$var->{"job.header.label"} = $i18n->get("edit job");
	$var->{"job.title.label"} = $i18n->get("job title");
	$var->{"job.description.label"} = $i18n->get("job description");
	$var->{"job.requirements.label"} = $i18n->get("job requirements");
	$var->{"location.label"} = $i18n->get("location");
	$var->{"layout.flat.label"} = $i18n->get("flatLayout");
	$var->{'link.header.label'} = $i18n->get("edit link");
	$var->{"lastReply.label"} = $i18n->get("lastReply");
	$var->{"lock.label"} = $i18n->get("lock");
	$var->{"layout.label"} = $i18n->get("layout");
        $var->{'message.header.label'} = $i18n->get("edit message");
        $var->{'message.label'} = $i18n->get("message");
	$var->{"next.label"} = $i18n->get("next");
        $var->{'newWindow.label'} = $i18n->get("new window");
	$var->{"layout.nested.label"} = $i18n->get("nested");
	$var->{"previous.label"} = $i18n->get("previous");
	$var->{"post.label"} = $i18n->get("post");
	$var->{'question.label'} = $i18n->get("question");
	$var->{'question.header.label'} = $i18n->get("edit question");
	$var->{"rating.label"} = $i18n->get("rating");
	$var->{"rate.label"} = $i18n->get("rate");
	$var->{"reply.label"} = $i18n->get("reply");
	$var->{"replies.label"} = $i18n->get("replies");
	$var->{"readmore.label"} = $i18n->get("read more");
	$var->{"responses.label"} = $i18n->get("responses");
        $var->{'results.label'} = $i18n->get("results");
        $var->{"search.label"} = $i18n->get("search");
        $var->{'subject.label'} = $i18n->get("subject");
	$var->{"subscribe.label"} = $i18n->get("subscribe");
        $var->{'submission.header.label'} = $i18n->get("edit submission");
	$var->{'startDate.label'} = $i18n->get("start date");
	$var->{"stick.label"} = $i18n->get("sticky");
	$var->{"status.label"} = $i18n->get("status");
	$var->{"synopsis.label"} = $i18n->get("synopsis");
	$var->{"thumbnail.label"} = $i18n->get("thumbnail");
	$var->{"title.label"} = $i18n->get("title");
	$var->{"unlock.label"} = $i18n->get("unlock");
	$var->{"unstick.label"} = $i18n->get("unstick");
	$var->{"unsubscribe.label"} = $i18n->get("unsubscribe");
        $var->{'url.label'} = $i18n->get("url");
        $var->{"user.label"} = $i18n->get("user");
	$var->{"views.label"} = $i18n->get("views");
        $var->{'visitorName.label'} = $i18n->get("visitor");
        $var->{'without.label'} = $i18n->get("without");
}

#-------------------------------------------------------------------
sub canEdit {
        my $self = shift;
        return ((($session{form}{func} eq "add" || ($session{form}{assetId} eq "new" && $session{form}{func} eq "editSave" && $session{form}{class} eq "WebGUI::Asset::Post::Thread")) && $self->canPost) || # account for new posts
                $self->SUPER::canEdit());
}

#-------------------------------------------------------------------
sub canModerate {
	my $self = shift;
	return WebGUI::Grouping::isInGroup($self->get("moderateGroupId"));
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
		assetName=>WebGUI::International::get('assetName',"Asset_Collaboration"),
		icon=>'collaboration.gif',
                tableName=>'Collaboration',
                className=>'WebGUI::Asset::Wobject::Collaboration',
                properties=>{
			displayLastReply =>{
				fieldType=>"yesNo",
				defaultValue=>0
				},
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
				noFormPost=>1,
				fieldType=>"hidden",
				defaultValue=>undef
				},
			lastPostDate =>{
				noFormPost=>1,
				fieldType=>"hidden",
				defaultValue=>undef
				},
			lastPostId =>{
				noFormPost=>1,
				fieldType=>"hidden",
				defaultValue=>undef
				},
			rating =>{
				noFormPost=>1,
				fieldType=>"hidden",
				defaultValue=>undef
				},
			replies =>{
				noFormPost=>1,
				fieldType=>"hidden",
				defaultValue=>undef
				},
			views =>{
				noFormPost=>1,
				fieldType=>"hidden",
				defaultValue=>undef
				},
			threads =>{
				noFormPost=>1,
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
			richEditor =>{
				fieldType=>"selectList",
				defaultValue=>"PBrichedit000000000002"
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
			rssTemplateId =>{
				fieldType=>"template",
				defaultValue=>'PBtmpl0000000000000142'
				},
			notificationTemplateId =>{
				fieldType=>"template",
				defaultValue=>'PBtmpl0000000000000027'
				},
			searchTemplateId =>{
				fieldType=>"template",
				defaultValue=>'PBtmpl0000000000000031'
				},
			postFormTemplateId =>{
				fieldType=>"template",
				defaultValue=>'PBtmpl0000000000000029'
				},
			threadTemplateId =>{
				fieldType=>"template",
				defaultValue=>'PBtmpl0000000000000032'
				},
			collaborationTemplateId =>{
				fieldType=>"template",
				defaultValue=>'PBtmpl0000000000000026'
				},
			karmaPerPost =>{
				fieldType=>"integer",
				defaultValue=>0
				},
			karmaSpentToRate => {
				fieldType => "integer",
				defaultValue=> 0
				},
			karmaRatingMultiplier => {
				fieldType => "integer",
				defaultValue=> 0
				},
			moderatePosts =>{
				fieldType=>"yesNo",
				defaultValue=>0
				},
			avatarsEnabled =>{
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
   	$tabform->getTab("display")->yesNo(
      		-value=>$self->getValue('displayLastReply'),
		-label=>WebGUI::International::get('display last reply', 'Asset_Collaboration'),
		-hoverHelp=>WebGUI::International::get('display last reply description', 'Asset_Collaboration'),
		-name=>"displayLastReply"
   		);
   	$tabform->getTab("display")->template(
      		-value=>$self->getValue('collaborationTemplateId'),
      		-namespace=>"Collaboration",
		-label=>WebGUI::International::get('system template', 'Asset_Collaboration'),
		-hoverHelp=>WebGUI::International::get('system template description', 'Asset_Collaboration'),
		-name=>"collaborationTemplateId"
   		);
        $tabform->getTab("display")->template(
                -name=>"threadTemplateId",
                -value=>$self->getValue("threadTemplateId"),
                -namespace=>"Collaboration/Thread",
		-label=>WebGUI::International::get('thread template', 'Asset_Collaboration'),
		-hoverHelp=>WebGUI::International::get('thread template description', 'Asset_Collaboration'),
                );
        $tabform->getTab("display")->template(
                -name=>"postFormTemplateId",
                -value=>$self->getValue("postFormTemplateId"),
                -namespace=>"Collaboration/PostForm",
		-label=>WebGUI::International::get('post template', 'Asset_Collaboration'),
		-hoverHelp=>WebGUI::International::get('post template description', 'Asset_Collaboration'),
                );
        $tabform->getTab("display")->template(
                -name=>"searchTemplateId",
                -value=>$self->getValue("SearchTemplateId"),
                -namespace=>"Collaboration/Search",
		-label=>WebGUI::International::get('search template', 'Asset_Collaboration'),
		-hoverHelp=>WebGUI::International::get('search template description', 'Asset_Collaboration'),
                );
        $tabform->getTab("display")->template(
                -name=>"notificationTemplateId",
                -value=>$self->getValue("notificationTemplateId"),
                -namespace=>"Collaboration/Notification",
		-label=>WebGUI::International::get('notification template', 'Asset_Collaboration'),
		-hoverHelp=>WebGUI::International::get('notification template description', 'Asset_Collaboration'),
                );
        $tabform->getTab("display")->template(
                -name=>"rssTemplateId",
                -value=>$self->getValue("rssTemplateId"),
                -namespace=>"Collaboration/RSS",
		-label=>WebGUI::International::get('rss template', 'Asset_Collaboration'),
		-hoverHelp=>WebGUI::International::get('rss template description', 'Asset_Collaboration'),
                );
        $tabform->getTab("security")->group(
		-name=>"moderateGroupId",
		-label=>WebGUI::International::get('who moderates', 'Asset_Collaboration'),
		-hoverHelp=>WebGUI::International::get('who moderates description', 'Asset_Collaboration'),
		-value=>[$self->getValue("moderateGroupId")]
		);
        $tabform->getTab("security")->group(
		-name=>"postGroupId",
		-label=>WebGUI::International::get('who posts', 'Asset_Collaboration'),
		-hoverHelp=>WebGUI::International::get('who posts description', 'Asset_Collaboration'),
		-value=>[$self->getValue("postGroupId")]
		);
        $tabform->getTab("display")->integer(
		-name=>"threadsPerPage",
		-label=>WebGUI::International::get('threads/page', 'Asset_Collaboration'),
		-hoverHelp=>WebGUI::International::get('threads/page description', 'Asset_Collaboration'),
		-value=>$self->getValue("threadsPerPage")
		);
        $tabform->getTab("display")->integer(
		-name=>"postsPerPage",
		-label=>WebGUI::International::get('posts/page', 'Asset_Collaboration'),
		-hoverHelp=>WebGUI::International::get('posts/page description', 'Asset_Collaboration'),
		-value=>$self->getValue("postsPerPage")
		);
        if ($session{setting}{useKarma}) {
                $tabform->getTab("properties")->integer(
			-name=>"karmaPerPost",
			-label=>WebGUI::International::get('karma/post', 'Asset_Collaboration'),
			-hoverHelp=>WebGUI::International::get('karma/post description', 'Asset_Collaboration'),
			-value=>$self->getValue("karmaPerPost")
			);
                $tabform->getTab("properties")->integer(
			-name=>"karmaSpentToRate",
			-label=>WebGUI::International::get('karma spent to rate', 'Asset_Collaboration'),
			-hoverHelp=>WebGUI::International::get('karma spent to rate description', 'Asset_Collaboration'),
			-value=>$self->getValue("karmaSpentToRate")
			);
                $tabform->getTab("properties")->integer(
			-name=>"karmaRatingMultiplier",
			-label=>WebGUI::International::get('karma rating multiplier', 'Asset_Collaboration'),
			-hoverHelp=>WebGUI::International::get('karma rating multiplier description', 'Asset_Collaboration'),
			-value=>$self->getValue("karmaRatingMultiplier")
			);
        } else {
                $tabform->getTab("properties")->hidden(
			-name=>"karmaPerPost",
			-value=>$self->getValue("karmaPerPost")
			);
                $tabform->getTab("properties")->hidden(
			-name=>"karmaSpentToRate",
			-value=>$self->getValue("karmaSpentToRate")
			);
                $tabform->getTab("properties")->hidden(
			-name=>"karmaRatingMultiplier",
			-value=>$self->getValue("karmaRatingMultiplier")
			);
        }
	$tabform->getTab("security")->filterContent(
		-value=>$self->getValue("filterCode"),
		-name=>"filterCode",
		-label=>WebGUI::International::get('filter code', 'Asset_Collaboration'),
		-hoverHelp=>WebGUI::International::get('filter code description', 'Asset_Collaboration'),
		);
	my %options;
	tie %options, 'Tie::IxHash';
	%options = (
			lineage=>WebGUI::International::get('sequence', 'Asset_Collaboration'),
			dateUpdated=>WebGUI::International::get('date updated', 'Asset_Collaboration'),
			dateSubmitted=>WebGUI::International::get('date submitted', 'Asset_Collaboration'),
			title=>WebGUI::International::get('title', 'Asset_Collaboration'),
			userDefined1=>WebGUI::International::get('user defined 1', 'Asset_Collaboration'),
			userDefined2=>WebGUI::International::get('user defined 2', 'Asset_Collaboration'),
			userDefined3=>WebGUI::International::get('user defined 3', 'Asset_Collaboration'),
			userDefined4=>WebGUI::International::get('user defined 4', 'Asset_Collaboration'),
			userDefined5=>WebGUI::International::get('user defined 5', 'Asset_Collaboration'),
			);
	$tabform->getTab("display")->selectList(
		-name=>"sortBy",
		-value=>[$self->getValue("sortBy")],
		-options=>\%options,
		-label=>WebGUI::International::get('sort by', 'Asset_Collaboration'),
		-hoverHelp=>WebGUI::International::get('sort by description', 'Asset_Collaboration'),
		);
	$tabform->getTab("display")->selectList(
		-name=>"sortOrder",
		-value=>[$self->getValue("sortOrder")],
		-options=>{
			asc=>WebGUI::International::get('ascending', 'Asset_Collaboration'),
			desc=>WebGUI::International::get('descending', 'Asset_Collaboration'),
			},
		-label=>WebGUI::International::get('sort order', 'Asset_Collaboration'),
		-hoverHelp=>WebGUI::International::get('sort order description', 'Asset_Collaboration'),
		);
        $tabform->getTab("properties")->interval(
		-name=>"archiveAfter",
		-label=>WebGUI::International::get('archive after', 'Asset_Collaboration'),
		-hoverHelp=>WebGUI::International::get('archive after description', 'Asset_Collaboration'),
		-value=>$self->getValue("archiveAfter")
		);
        $tabform->getTab("properties")->integer(
		-name=>"attachmentsPerPost",
		-label=>WebGUI::International::get('attachments/post', 'Asset_Collaboration'),
		-hoverHelp=>WebGUI::International::get('attachments/post description', 'Asset_Collaboration'),
		-value=>$self->getValue("attachmentsPerPost")
		);
        $tabform->getTab("security")->interval(
		-name=>"editTimeout",
		-label=>WebGUI::International::get('edit timeout', 'Asset_Collaboration'),
		-hoverHelp=>WebGUI::International::get('edit timeout description', 'Asset_Collaboration'),
		-value=>$self->getValue("editTimeout")
		);
        $tabform->getTab("security")->yesNo(
		-name=>"allowReplies",
		-label=>WebGUI::International::get('allow replies', 'Asset_Collaboration'),
		-hoverHelp=>WebGUI::International::get('allow replies description', 'Asset_Collaboration'),
		-value=>$self->getValue("allowReplies")
		);
        $tabform->getTab("security")->yesNo(
		-name=>"addEditStampToPosts",
		-label=>WebGUI::International::get('edit stamp', 'Asset_Collaboration'),
		-hoverHelp=>WebGUI::International::get('edit stamp description', 'Asset_Collaboration'),
		-value=>$self->getValue("addEditStampToPosts")
		);
        $tabform->getTab("display")->selectList(
		-name=>"richEditor",
		-label=>WebGUI::International::get('rich editor', 'Asset_Collaboration'),
		-hoverHelp=>WebGUI::International::get('rich editor description', 'Asset_Collaboration'),
		-options=>WebGUI::SQL->buildHashRef("select distinct(assetData.assetId), assetData.title from asset, assetData where asset.className='WebGUI::Asset::RichEdit' and asset.assetId=assetData.assetId order by assetData.title"),
		-value=>[$self->getValue("richEditor")]
		);
        $tabform->getTab("display")->yesNo(
		-name=>"useContentFilter",
		-label=>WebGUI::International::get('content filter', 'Asset_Collaboration'),
		-hoverHelp=>WebGUI::International::get('content filter description', 'Asset_Collaboration'),
		-value=>$self->getValue("useContentFilter")
		);
        $tabform->getTab("properties")->yesNo(
		-name=>"usePreview",
		-label=>WebGUI::International::get('use preview', 'Asset_Collaboration'),
		-hoverHelp=>WebGUI::International::get('use preview description', 'Asset_Collaboration'),
		-value=>$self->getValue("usePreview")
		);
        $tabform->getTab("properties")->yesNo(
		-name=>"avatarsEnabled",
		-label=>WebGUI::International::get('enable avatars', 'Asset_Collaboration'),
		-hoverHelp=>WebGUI::International::get('enable avatars description', 'Asset_Collaboration'),
		-value=>$self->getValue("avatarsEnabled")
		);
        $tabform->getTab("security")->yesNo(
		-name=>"moderatePosts",
		-label=>WebGUI::International::get('moderate', 'Asset_Collaboration'),
		-hoverHelp=>WebGUI::International::get('moderate description', 'Asset_Collaboration'),
		-value=>$self->getValue("moderatePosts")
		);
	return $tabform;
}


#-------------------------------------------------------------------

=head2 getNewThreadUrl(  )

Formats the url to start a new thread.

=cut

sub getNewThreadUrl {
	my $self = shift;
	$self->getUrl("func=add;class=WebGUI::Asset::Post::Thread");
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

Increments the reply counter for this forum.

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
        my $updatePrivs = ($session{form}{groupIdView} ne $self->get("groupIdView") || $session{form}{moderateGroupId} ne $self->get("moderateGroupId"));
	$self->SUPER::processPropertiesFromFormPost;
	if ($self->get("subscriptionGroupId") eq "") {
		$self->createSubscriptionGroup;
	}
        if ($updatePrivs) {
                foreach my $descendant (@{$self->getLineage(["descendants"],{returnObjects=>1})}) {
                        $descendant->update({
                                groupIdView=>$self->get("groupIdView"),
                                groupIdEdit=>$self->get("moderateGroupId")
                                });
                }
        }
	WebGUI::Session::deleteScratch($self->getId."_sortBy");
        WebGUI::Session::deleteScratch($self->getId."_sortDir");
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
		left join Post on Thread.assetId=Post.assetId where asset.parentId=".quote($self->getId)." and Post.rating>0");
        $count = $count || 1;
        my ($sum) = WebGUI::SQL->quickArray("select sum(Post.rating) from Thread left join asset on Thread.assetId=asset.assetId 
		left join Post on Thread.assetId=Post.assetId where asset.parentId=".quote($self->getId)." and Post.rating>0");
        my $average = round($sum/$count);
        $self->update({rating=>$average});
}


#-------------------------------------------------------------------

=head2 setLastPost ( id, date )

Sets the most recent post in this collaboration system.

=head3 id

The assetId of the most recent post.

=head3 date

The date of the most recent post.

=cut

sub setLastPost {
        my $self = shift;
        my $id = shift;
        my $date = shift;
        $self->update({lastPostId=>$id, lastPostDate=>$date});
}

#-------------------------------------------------------------------

=head2 subscribe ( )

Subscribes a user to this collaboration system.

=cut

sub subscribe {
	my $self = shift;
	WebGUI::Cache->new("wobject_".$self->getId."_".$session{user}{userId})->delete;
	WebGUI::Grouping::addUsersToGroups([$session{user}{userId}],[$self->get("subscriptionGroupId")]);
}

#-------------------------------------------------------------------

=head2 unsubscribe (  )

Unsubscribes a user from this collaboration system

=cut

sub unsubscribe {
	my $self = shift;
	WebGUI::Cache->new("wobject_".$self->getId."_".$session{user}{userId})->delete;
	WebGUI::Grouping::deleteUsersFromGroups([$session{user}{userId}],[$self->get("subscriptionGroupId")]);
}


#-------------------------------------------------------------------
sub view {
	my $self = shift;
	my $scratchSortBy = $self->getId."_sortBy";
	my $scratchSortOrder = $self->getId."_sortDir";
	my $sortBy = $session{form}{sortBy} || $session{scratch}{$scratchSortBy} || $self->get("sortBy");
	my $sortOrder = $session{scratch}{$scratchSortOrder} || $self->get("sortOrder");
	if ($sortBy ne $session{scratch}{$scratchSortBy} && $session{form}{func} ne "editSave") {
		WebGUI::Session::setScratch($scratchSortBy,$session{form}{sortBy});
	} elsif ($session{form}{sortBy} && $session{form}{func} ne "editSave") {
                if ($sortOrder eq "asc") {
                        $sortOrder = "desc";
                } else {
                        $sortOrder = "asc";
                }
                WebGUI::Session::setScratch($scratchSortOrder, $sortOrder);
	}
	$sortBy ||= "dateUpdated";
	$sortOrder ||= "desc";
	my %var;
	$var{'user.canPost'} = $self->canPost;
        $var{"add.url"} = $self->getNewThreadUrl;
        $var{"rss.url"} = $self->getRssUrl;
        $var{'user.isModerator'} = $self->canModerate;
        $var{'user.isVisitor'} = ($session{user}{userId} eq '1');
	$var{'user.isSubscribed'} = $self->isSubscribed;
	$var{'sortby.title.url'} = $self->getSortByUrl("title");
	$var{'sortby.username.url'} = $self->getSortByUrl("username");
	$var{'sortby.date.url'} = $self->getSortByUrl("dateSubmitted");
	$var{'sortby.lastreply.url'} = $self->getSortByUrl("lastPostDate");
	$var{'sortby.views.url'} = $self->getSortByUrl("views");
	$var{'sortby.replies.url'} = $self->getSortByUrl("replies");
	$var{'sortby.rating.url'} = $self->getSortByUrl("rating");
	WebGUI::Style::setLink($var{"rss.url"},{ rel=>'alternate', type=>'application/rss+xml', title=>'RSS' });
	$var{"search.url"} = $self->getSearchUrl;
	$var{"subscribe.url"} = $self->getSubscribeUrl;
	$var{"unsubscribe.url"} = $self->getUnsubscribeUrl;
	my $constraints = "(assetData.status='approved' or (assetData.ownerUserId=".quote($session{user}{userId})." and assetData.ownerUserId<>'1') or assetData.tagId=".quote($session{scratch}{versionTag});
	if ($var{'user.isModerator'}) {
		$constraints .= " or assetData.status='pending'"; 
	}
	$constraints .= ")";
	my $sql = "select asset.assetId,asset.className,max(assetData.revisionDate) as revisionDate
		from Thread
		left join asset on Thread.assetId=asset.assetId
		left join Post on Post.assetId=Thread.assetId and Thread.revisionDate = Post.revisionDate
		left join assetData on assetData.assetId=Thread.assetId and Thread.revisionDate = assetData.revisionDate
		where asset.parentId=".quote($self->getId)." and asset.state='published' and asset.className='WebGUI::Asset::Post::Thread' and $constraints 
		group by assetData.assetId order by Thread.isSticky desc, ".$sortBy." ".$sortOrder;
	my $p = WebGUI::Paginator->new($self->getUrl,$self->get("threadsPerPage"));
	$self->appendPostListTemplateVars(\%var, $sql, $p);
	$self->appendTemplateLabels(\%var);
	return $self->processTemplate(\%var,$self->get("collaborationTemplateId"));
}

#-------------------------------------------------------------------
#sub www_edit {
#        my $self = shift;
#	return WebGUI::Privilege::insufficient() unless $self->canEdit;
#	$self->getAdminConsole->setHelp("collaboration add/edit", "Asset_Collaboration");
#        return $self->getAdminConsole->render($self->getEditForm->print,"Edit Collaboration System");
#}

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
        $var{'form.header'} = WebGUI::Form::formHeader({action=>$self->getUrl})
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
        $var{'form.footer'} = WebGUI::Form::formFooter();
        $var{'back.url'} = $self->getUrl;
	$self->appendTemplateLabels(\%var);
        $var{doit} = $session{form}{doit};
        if ($session{form}{doit}) {
                my @fieldsToSearch = qw(assetData.title assetData.synopsis Post.content Post.username Post.userDefined1 Post.userDefined2 Post.userDefined3 Post.userDefined4 Post.userDefined5);
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
		my $sql = "select asset.assetId, asset.className, max(assetData.revisionDate) as revisionDate
			from asset
			left join assetData on assetData.assetId=asset.assetId
			left join Post on Post.assetId=assetData.assetId and assetData.revisionDate = Post.revisionDate
			where (asset.className='WebGUI::Asset::Post' or asset.className='WebGUI::Asset::Post::Thread')
				and asset.lineage  like ".quote($self->get("lineage").'%')."
				and asset.assetId<>".quote($self->getId)."
				and (
					assetData.status in ('approved','archived')
				 or assetData.tagId=".quote($session{scratch}{versionTag});
		$sql .= "		or assetData.status='pending'" if ($self->canModerate);
		$sql .= "		or (assetData.ownerUserId=".quote($session{user}{userId})." and assetData.ownerUserId<>'1')
					) ";
		$sql .= " and ($all) " if ($all ne "");
		$sql .= " and " if ($sql ne "" && $exactPhrase ne "");
		$sql .= " ($exactPhrase) " if ($exactPhrase ne "");
		$sql .= " and " if ($sql ne "" && $atLeastOne ne "");
		$sql .= " ($atLeastOne) " if ($atLeastOne ne "");
		$sql .= " and " if ($sql ne "" && $without ne "");
		$sql .= " ($without) " if ($without ne "");
		$sql .= " group by assetData.assetId order by Post.dateSubmitted desc";
		my $p = WebGUI::Paginator->new($self->getUrl("func=search;doit=1"),$numResults);
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
sub www_view {
	my $self = shift;
	my $disableCache = ($session{form}{sortBy} ne "");
	return $self->SUPER::www_view($disableCache);
}


#-------------------------------------------------------------------
# print out RSS 2.0 feed describing the items visible on the first page
sub www_viewRSS {
	my $self = shift;
	my %var;

	$self->logView() if ($session{setting}{passiveProfilingEnabled});        
	# Set the required channel variables
	$var{'title'} = _xml_encode($self->get("title"));
	$var{'link'} = _xml_encode($self->getUrl);
	$var{'description'} = _xml_encode($self->get("description"));
	# Set some of the optional channel variables
	$var{'generator'} = "WebGUI ".$WebGUI::VERSION;
	$var{'lastBuildDate'} = _xml_encode(_get_rfc822_date($self->get("dateUpdated")));
	$var{'webMaster'} = $WebGUI::Session::session{setting}{companyEmail};
	$var{'docs'} = "http://blogs.law.harvard.edu/tech/rss";

	my $sth = WebGUI::SQL->read("select asset.assetId, asset.className, max(assetData.revisionDate) 
		from Thread
		left join asset on Thread.assetId=asset.assetId
		left join Post on Post.assetId=Thread.assetId and Thread.revisionDate=Post.revisionDate
		left join assetData on assetData.assetId=Thread.assetId and Thread.revisionDate=assetData.revisionDate
		where asset.parentId=".quote($self->getId)." and asset.state='published' 
			and asset.className='WebGUI::Asset::Post::Thread' 
			and (assetData.status='approved'
			 or assetData.tagId=".quote($session{scratch}{versionTag}).")
		group by assetData.assetId
		order by ".$self->getValue("sortBy")." ".$self->getValue("sortOrder"));
	my $i = 1;
        while (my ($id, $class, $version)  = $sth->array) {
		my $post = WebGUI::Asset::Wobject::Collaboration->new($id, $class, $version);
		my $encUrl = _xml_encode(WebGUI::URL::getSiteURL().$post->getUrl);

		push(@{$var{'item_loop'}}, {
		    title => _xml_encode($post->get("title")),
		    link => $encUrl,
		    description => _xml_encode($post->get("synopsis")),
		    guid => $encUrl,
		    pubDate => _xml_encode(_get_rfc822_date($post->get("dateUpdated")))
		    });
		$i++;
		last if ($i == $self->get("threadsPerPage"));
        }

	WebGUI::HTTP::setMimeType("text/xml");
	return $self->processTemplate(\%var,$self->get("rssTemplateId"));
}




1;

