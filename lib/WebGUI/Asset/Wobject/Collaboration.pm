package WebGUI::Asset::Wobject::Collaboration;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Tie::IxHash;
use WebGUI::Group;
use WebGUI::Cache;
use WebGUI::HTML;
use WebGUI::International;
use WebGUI::Paginator;
use WebGUI::Utility;
use WebGUI::Asset::Wobject;
use WebGUI::Workflow::Cron;

our @ISA = qw(WebGUI::Asset::Wobject);


#-------------------------------------------------------------------
sub appendPostListTemplateVars {
	my $self = shift;
	my $var = shift;
	my $p = shift;
	my $page = $p->getPageData;
	my $i = 0;
	foreach my $row (@$page) {
		my $post = WebGUI::Asset->new($self->session,$row->{assetId}, $row->{className}, $row->{revisionDate});
		$post->{_parent} = $self; # caching parent for efficiency 
		my $controls = $self->session->icon->delete('func=delete',$post->get("url"),"Delete").$self->session->icon->edit('func=edit',$post->get("url"));
		if ($self->get("sortBy") eq "lineage") {
			if ($self->get("sortOrder") eq "desc") {
				$controls .= $self->session->icon->moveUp('func=demote',$post->get("url")).$self->session->icon->moveDown('func=promote',$post->get("url"));
			} else {
				$controls .= $self->session->icon->moveUp('func=promote',$post->get("url")).$self->session->icon->moveDown('func=demote',$post->get("url"));
			}
		}
		my @rating_loop;
		for (my $i=0;$i<=$post->get("rating");$i++) {
			push(@rating_loop,{'rating_loop.count'=>$i});
		}
		my %lastReply;
		my $hasRead = 0;
		if ($post->get("className") =~ /Thread/) {
			if ($self->get("displayLastReply")) {
				my $lastPost = $post->getLastPost();
				%lastReply = (
					"lastReply.url"=>$lastPost->getUrl.'#'.$lastPost->getId,
                        		"lastReply.title"=>$lastPost->get("title"),
                        		"lastReply.user.isVisitor"=>$lastPost->get("ownerUserId") eq "1",
                        		"lastReply.username"=>$lastPost->get("username"),
                       	 		"lastReply.userProfile.url"=>$lastPost->WebGUI::Asset::Post::getPosterProfileUrl(),
                        		"lastReply.dateSubmitted.human"=>$self->session->datetime->epochToHuman($lastPost->get("dateSubmitted"),"%z"),
                        		"lastReply.timeSubmitted.human"=>$self->session->datetime->epochToHuman($lastPost->get("dateSubmitted"),"%Z")
					);
			}
			$hasRead = $post->isMarkedRead;
		}
		my $url;
		if ($post->get("status") eq "pending") {
			$url = $post->getUrl("revision=".$post->get("revisionDate"))."#".$post->getId;
		} else {
			$url = $post->getUrl."#".$post->getId;
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
                        "dateSubmitted.human"=>$self->session->datetime->epochToHuman($post->get("dateSubmitted"),"%z"),
                        "dateUpdated.human"=>$self->session->datetime->epochToHuman($post->get("dateUpdated"),"%z"),
                        "timeSubmitted.human"=>$self->session->datetime->epochToHuman($post->get("dateSubmitted"),"%Z"),
                        "timeUpdated.human"=>$self->session->datetime->epochToHuman($post->get("dateUpdated"),"%Z"),
                        "userProfile.url"=>$post->getPosterProfileUrl,
                        "user.isVisitor"=>$post->get("ownerUserId") eq "1",
        		"edit.url"=>$post->getEditUrl,
			'controls'=>$controls,
                        "isSecond"=>(($i+1)%2==0),
                        "isThird"=>(($i+1)%3==0),
                        "isFourth"=>(($i+1)%4==0),
                        "isFifth"=>(($i+1)%5==0),
			"user.hasRead" => $hasRead,
                	"user.isPoster"=>$post->isPoster,
                	"avatar.url"=>$post->getAvatarUrl,
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
	my $i18n = WebGUI::International->new($self->session, "Asset_Collaboration");
	$var->{"add.label"} = $i18n->get("add");
	$var->{"addlink.label"} = $i18n->get("addlink");
	$var->{"addquestion.label"} = $i18n->get("addquestion");
	$var->{'answer.label'} = $i18n->get("answer");
	$var->{'attachment.label'} = $i18n->get("attachment");
	$var->{'archive.label'} = $i18n->get("archive");
	$var->{'unarchive.label'} = $i18n->get("unarchive");
	$var->{"by.label"} = $i18n->get("by");
        $var->{'body.label'} = $i18n->get("body");
	$var->{"back.label"} = $i18n->get("back");
	$var->{'compensation.label'} = $i18n->get("compensation");
	$var->{'contentType.label'} = $i18n->get("contentType");
	$var->{"date.label"} = $i18n->get("date");
	$var->{"delete.label"} = $i18n->get("delete");
        $var->{'description.label'} = $i18n->get("description");
	$var->{"edit.label"} = $i18n->get("edit");
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
        $var->{"search.label"} = $i18n->get("search");
        $var->{'subject.label'} = $i18n->get("subject");
	$var->{"subscribe.label"} = $i18n->get("subscribe");
        $var->{'submission.header.label'} = $i18n->get("edit submission");
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
}

#-------------------------------------------------------------------
sub canEdit {
        my $self = shift;
        return ((($self->session->form->process("func") eq "add" || ($self->session->form->process("assetId") eq "new" && $self->session->form->process("func") eq "editSave" && $self->session->form->process("class") eq "WebGUI::Asset::Post::Thread")) && $self->canPost) || # account for new posts
                $self->SUPER::canEdit());
}

#-------------------------------------------------------------------
sub canPost {
	my $self = shift;
	return $self->session->user->isInGroup($self->get("postGroupId")) || $self->canEdit;
}


#-------------------------------------------------------------------
sub canSubscribe {
        my $self = shift;
        return ($self->session->user->userId ne "1" && $self->canView);
}

#-------------------------------------------------------------------
sub canView {
	my $self = shift;
	return $self->SUPER::canView || $self->canPost;
}

#-------------------------------------------------------------------
sub commit {
	my $self = shift;
	$self->SUPER::commit;
	my $cron = undef;
	if ($self->get("getMailCronId")) {
		$cron = WebGUI::Workflow::Cron->new($self->session, $self->get("getMailCronId"));
	}
	my $i18n = WebGUI::International->new($self->session, "Asset_Collaboration");
	unless (defined $cron) {
		$cron = WebGUI::Workflow::Cron->create($self->session, {
			title=>$self->getTitle." ".$i18n->get("mail"),
			minuteOfHour=>"*/".($self->get("getMailInterval")/60),
			className=>"WebGUI::Asset::Wobject::Collaboration",
			methodName=>"new",
			parameters=>$self->getId,
			workflowId=>"csworkflow000000000001"
			});
		$self->update({getMailCronId=>$cron->getId});
	}
	if ($self->get("getMail")) {
		$cron->set({enabled=>1,title=>$self->getTitle." ".$i18n->get("mail"), minuteOfHour=>"*/".($self->get("getMailInterval")/60)});
	} else {
		$cron->set({enabled=>0,title=>$self->getTitle." ".$i18n->get("mail"), minuteOfHour=>"*/".($self->get("getMailInterval")/60)});
	}
}

#-------------------------------------------------------------------
sub createSubscriptionGroup {
	my $self = shift;
	my $group = WebGUI::Group->new($self->session, "new");
	$group->name($self->getId);
	$group->description("The group to store subscriptions for the collaboration system ".$self->getId);
	$group->isEditable(0);
	$group->showInForms(0);
	$group->deleteGroups([3]); # admins don't want to be auto subscribed to this thing
	$self->update({
		subscriptionGroupId=>$group->getId
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
	my $session = shift;
        my $definition = shift;
	my $i18n = WebGUI::International->new($session,"Asset_Collaboration");
        push(@{$definition}, {
		assetName=>$i18n->get('assetName'),
		icon=>'collaboration.gif',
                tableName=>'Collaboration',
                className=>'WebGUI::Asset::Wobject::Collaboration',
                properties=>{
			visitorCacheTimeout => {
				tab => "display",
				fieldType => "interval",
				defaultValue => 3600,
				uiLevel => 8,
				label => $i18n->get("visitor cache timeout"),
				hoverHelp => $i18n->get("visitor cache timeout help")
				},
			approvalWorkflow =>{
				fieldType=>"workflow",
				defaultValue=>"pbworkflow000000000003"
				},
			mailServer=>{
				fieldType=>"text",
				defaultValue=>undef
				},
			mailAccount=>{
				fieldType=>"text",
				defaultValue=>undef
				},
			mailPassword=>{
				fieldType=>"password",
				defaultValue=>undef
				},
			mailAddress=>{
				fieldType=>"email",
				defaultValue=>undef
				},
			mailPrefix=>{
				fieldType=>"text",
				defaultValue=>undef
				},
			getMailCronId=>{
				fieldType=>"hidden",
				defaultValue=>undef,
				noFormPost=>1
				},
			getMail=>{
				fieldType=>"yesNo",
				defaultValue=>0
				},
			getMailInterval=>{
				fieldType=>"interval",
				defaultValue=>300
				},
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
				fieldType=>"selectBox",
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
				fieldType=>"selectBox",
				defaultValue=>'desc'
				},
			sortBy =>{
				fieldType=>"selectBox",
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
				namespace=>'Collaboration',
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
			avatarsEnabled =>{
				fieldType=>"yesNo",
				defaultValue=>0
				},
			postGroupId =>{
				fieldType=>"group",
				defaultValue=>'2'
				},
			defaultKarmaScale => {
				fieldType=>"integer",
				defaultValue=>1
				}
			}
		});
        return $class->SUPER::definition($session, $definition);
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
	my $i18n = WebGUI::International->new($self->session,"Asset_Collaboration");
	$tabform->addTab("mail",$i18n->get("mail"), 9);
	$tabform->getTab("mail")->yesNo(
		name=>"getMail",
		value=>$self->getValue("getMail"),
		label=>$i18n->get("get mail"),
		hoverHelp=>$i18n->get("get mail help"),
		);
	$tabform->getTab("mail")->text(
		name=>"mailServer",
		value=>$self->getValue("mailServer"),
		label=>$i18n->get("mail server"),
		hoverHelp=>$i18n->get("mail server help"),
		);
	$tabform->getTab("mail")->text(
		name=>"mailAccount",
		value=>$self->getValue("mailAccount"),
		label=>$i18n->get("mail account"),
		hoverHelp=>$i18n->get("mail account help"),
		);
	$tabform->getTab("mail")->password(
		name=>"mailPassword",
		value=>$self->getValue("mailPassword"),
		label=>$i18n->get("mail password"),
		hoverHelp=>$i18n->get("mail password help"),
		);
	$tabform->getTab("mail")->email(
		name=>"mailAddress",
		value=>$self->getValue("mailAddress"),
		label=>$i18n->get("mail address"),
		hoverHelp=>$i18n->get("mail address help"),
		);
	$tabform->getTab("mail")->interval(
		name=>"getMailInterval",
		value=>$self->getValue("getMailInterval"),
		label=>$i18n->get("get mail interval"),
		hoverHelp=>$i18n->get("get mail interval help"),
		);
	$tabform->getTab("mail")->text(
		name=>"mailPrefix",
		value=>$self->getValue("mailPrefix"),
		label=>$i18n->get("mail prefix"),
		hoverHelp=>$i18n->get("mail prefix help"),
		);
 	$tabform->getTab("display")->interval(
 		-name=>"visitorCacheTimeout",
		-label=>$i18n->get('visitor cache timeout'),
		-hoverHelp=>$i18n->get('visitor cache timeout help'),
		-value=>$self->getValue('visitorCacheTimeout'),
		-uiLevel=>8,
		-defaultValue=>3600
	);
   	$tabform->getTab("display")->yesNo(
      		-value=>$self->getValue('displayLastReply'),
		-label=>$i18n->get('display last reply'),
		-hoverHelp=>$i18n->get('display last reply description'),
		-name=>"displayLastReply"
   		);
   	$tabform->getTab("display")->template(
      		-value=>$self->getValue('collaborationTemplateId'),
      		-namespace=>"Collaboration",
		-label=>$i18n->get('system template'),
		-hoverHelp=>$i18n->get('system template description'),
		-name=>"collaborationTemplateId"
   		);
        $tabform->getTab("display")->template(
                -name=>"threadTemplateId",
                -value=>$self->getValue("threadTemplateId"),
                -namespace=>"Collaboration/Thread",
		-label=>$i18n->get('thread template'),
		-hoverHelp=>$i18n->get('thread template description'),
                );
        $tabform->getTab("display")->template(
                -name=>"postFormTemplateId",
                -value=>$self->getValue("postFormTemplateId"),
                -namespace=>"Collaboration/PostForm",
		-label=>$i18n->get('post template'),
		-hoverHelp=>$i18n->get('post template description'),
                );
        $tabform->getTab("display")->template(
                -name=>"searchTemplateId",
                -value=>$self->getValue("SearchTemplateId"),
                -namespace=>"Collaboration/Search",
		-label=>$i18n->get('search template'),
		-hoverHelp=>$i18n->get('search template description'),
                );
        $tabform->getTab("display")->template(
                -name=>"notificationTemplateId",
                -value=>$self->getValue("notificationTemplateId"),
                -namespace=>"Collaboration/Notification",
		-label=>$i18n->get('notification template'),
		-hoverHelp=>$i18n->get('notification template description'),
                );
        $tabform->getTab("display")->template(
                -name=>"rssTemplateId",
                -value=>$self->getValue("rssTemplateId"),
                -namespace=>"Collaboration/RSS",
		-label=>$i18n->get('rss template'),
		-hoverHelp=>$i18n->get('rss template description'),
                );
        $tabform->getTab("security")->group(
		-name=>"postGroupId",
		-label=>$i18n->get('who posts'),
		-hoverHelp=>$i18n->get('who posts description'),
		-value=>[$self->getValue("postGroupId")]
		);
        $tabform->getTab("security")->workflow(
		-name=>"approvalWorkflow",
		-type=>"WebGUI::VersionTag",
		-label=>$i18n->get('approval workflow'),
		-hoverHelp=>$i18n->get('approval workflow description'),
		-value=>[$self->getValue("approvalWorkflow")]
		);
        $tabform->getTab("display")->integer(
		-name=>"threadsPerPage",
		-label=>$i18n->get('threads/page'),
		-hoverHelp=>$i18n->get('threads/page description'),
		-value=>$self->getValue("threadsPerPage")
		);
        $tabform->getTab("display")->integer(
		-name=>"postsPerPage",
		-label=>$i18n->get('posts/page'),
		-hoverHelp=>$i18n->get('posts/page description'),
		-value=>$self->getValue("postsPerPage")
		);
        if ($self->session->setting->get("useKarma")) {
                $tabform->getTab("properties")->integer(
			-name=>"karmaPerPost",
			-label=>$i18n->get('karma/post'),
			-hoverHelp=>$i18n->get('karma/post description'),
			-value=>$self->getValue("karmaPerPost")
			);
                $tabform->getTab("properties")->integer(
			-name=>"karmaSpentToRate",
			-label=>$i18n->get('karma spent to rate'),
			-hoverHelp=>$i18n->get('karma spent to rate description'),
			-value=>$self->getValue("karmaSpentToRate")
			);
                $tabform->getTab("properties")->integer(
			-name=>"karmaRatingMultiplier",
			$i18n->get('karma rating multiplier'),
			-hoverHelp=>$i18n->get('karma rating multiplier description'),
			-value=>$self->getValue("karmaRatingMultiplier")
			);
                $tabform->getTab("properties")->integer(
			-name=>"defaultKarmaScale",
			$i18n->get("default karma scale"),
			-hoverHelp=>$i18n->get('default karma scale help'),
			-value=>$self->getValue("defaultKarmaScale")
			);
        } else {
                $tabform->getTab("properties")->hidden(
			-name=>"defaultKarmaScale",
			-value=>$self->getValue("defaultKarmaScale")
			);
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
		-label=>$i18n->get('filter code'),
		-hoverHelp=>$i18n->get('filter code description'),
		);
	my %options;
	tie %options, 'Tie::IxHash';
	%options = (
			lineage=>$i18n->get('sequence'),
			dateUpdated=>$i18n->get('date updated'),
			dateSubmitted=>$i18n->get('date submitted'),
			title=>$i18n->get('title'),
			userDefined1=>$i18n->get('user defined 1'),
			userDefined2=>$i18n->get('user defined 2'),
			userDefined3=>$i18n->get('user defined 3'),
			userDefined4=>$i18n->get('user defined 4'),
			userDefined5=>$i18n->get('user defined 5'),
			);
	$options{karmaRank} = $i18n->get("karma rank") if ($self->session->setting->get("useKarma"));
	$tabform->getTab("display")->selectBox(
		-name=>"sortBy",
		-value=>[$self->getValue("sortBy")],
		-options=>\%options,
		-label=>$i18n->get('sort by'),
		-hoverHelp=>$i18n->get('sort by description'),
		);
	$tabform->getTab("display")->selectBox(
		-name=>"sortOrder",
		-value=>[$self->getValue("sortOrder")],
		-options=>{
			asc=>$i18n->get('ascending'),
			desc=>$i18n->get('descending'),
			},
		-label=>$i18n->get('sort order'),
		-hoverHelp=>$i18n->get('sort order description'),
		);
        $tabform->getTab("properties")->interval(
		-name=>"archiveAfter",
		-label=>$i18n->get('archive after'),
		-hoverHelp=>$i18n->get('archive after description'),
		-value=>$self->getValue("archiveAfter")
		);
        $tabform->getTab("properties")->integer(
		-name=>"attachmentsPerPost",
		-label=>$i18n->get('attachments/post'),
		-hoverHelp=>$i18n->get('attachments/post description'),
		-value=>$self->getValue("attachmentsPerPost")
		);
        $tabform->getTab("security")->interval(
		-name=>"editTimeout",
		-label=>$i18n->get('edit timeout'),
		-hoverHelp=>$i18n->get('edit timeout description'),
		-value=>$self->getValue("editTimeout")
		);
        $tabform->getTab("security")->yesNo(
		-name=>"allowReplies",
		-label=>$i18n->get('allow replies'),
		-hoverHelp=>$i18n->get('allow replies description'),
		-value=>$self->getValue("allowReplies")
		);
        $tabform->getTab("security")->yesNo(
		-name=>"addEditStampToPosts",
		-label=>$i18n->get('edit stamp'),
		-hoverHelp=>$i18n->get('edit stamp description'),
		-value=>$self->getValue("addEditStampToPosts")
		);
        $tabform->getTab("display")->selectBox(
		-name=>"richEditor",
		-label=>$i18n->get('rich editor'),
		-hoverHelp=>$i18n->get('rich editor description'),
		-options=>$self->session->db->buildHashRef("select distinct(assetData.assetId), assetData.title from asset, assetData where asset.className='WebGUI::Asset::RichEdit' and asset.assetId=assetData.assetId order by assetData.title"),
		-value=>[$self->getValue("richEditor")]
		);
        $tabform->getTab("display")->yesNo(
		-name=>"useContentFilter",
		-label=>$i18n->get('content filter'),
		-hoverHelp=>$i18n->get('content filter description'),
		-value=>$self->getValue("useContentFilter")
		);
        $tabform->getTab("properties")->yesNo(
		-name=>"usePreview",
		-label=>$i18n->get('use preview'),
		-hoverHelp=>$i18n->get('use preview description'),
		-value=>$self->getValue("usePreview")
		);
        $tabform->getTab("properties")->yesNo(
		-name=>"avatarsEnabled",
		-label=>$i18n->get('enable avatars'),
		-hoverHelp=>$i18n->get('enable avatars description'),
		-value=>$self->getValue("avatarsEnabled")
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
	return $self->session->user->isInGroup($self->get("subscriptionGroupId"));	
}

#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
	my $self = shift;
	$self->SUPER::prepareView();
	my $template = WebGUI::Asset::Template->new($self->session, $self->get("collaborationTemplateId"));
	$template->prepare;
	$self->{_viewTemplate} = $template;
}


#-------------------------------------------------------------------
sub processPropertiesFromFormPost {
	my $self = shift;
        my $updatePrivs = ($self->session->form->process("groupIdView") ne $self->get("groupIdView") || $self->session->form->process("groupIdEdit") ne $self->get("groupIdEdit"));
	$self->SUPER::processPropertiesFromFormPost;
	if ($self->get("subscriptionGroupId") eq "") {
		$self->createSubscriptionGroup;
	}
        if ($updatePrivs) {
                foreach my $descendant (@{$self->getLineage(["descendants"],{returnObjects=>1})}) {
                        $descendant->update({
                                groupIdView=>$self->get("groupIdView"),
                                groupIdEdit=>$self->get("groupIdEdit")
                                });
                }
        }
	$self->session->scratch->delete($self->getId."_sortBy");
        $self->session->scratch->delete($self->getId."_sortDir");
}


#-------------------------------------------------------------------
sub purge {
	my $self = shift;
	my $group = WebGUI::Group->new($self->session, $self->get("subscriptionGroupId"));
	$group->delete;
	if ($self->get("getMailCronId")) {
		my $cron = WebGUI::Workflow::Cron->new($self->session, $self->get("getMailCronId"));
		$cron->delete if defined $cron;
	}
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

=head2 recalculateRating ( )

Calculates the rating of this forum from its threads and stores the new value in the forum properties.

=cut

sub recalculateRating {
        my $self = shift;
        my ($count) = $self->session->db->quickArray("select count(*) from Thread left join asset on Thread.assetId=asset.assetId 
		left join Post on Thread.assetId=Post.assetId where asset.parentId=".$self->session->db->quote($self->getId)." and Post.rating>0");
        $count = $count || 1;
        my ($sum) = $self->session->db->quickArray("select sum(Post.rating) from Thread left join asset on Thread.assetId=asset.assetId 
		left join Post on Thread.assetId=Post.assetId where asset.parentId=".$self->session->db->quote($self->getId)." and Post.rating>0");
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
	my $group = WebGUI::Group->new($self->session,$self->get("subscriptionGroupId"));
	$group->addUsers([$self->session->user->userId]);
}

#-------------------------------------------------------------------

=head2 unsubscribe (  )

Unsubscribes a user from this collaboration system

=cut

sub unsubscribe {
	my $self = shift;
	my $group = WebGUI::Group->new($self->session,$self->get("subscriptionGroupId"));
	$group->deleteUsers([$self->session->user->userId],[$self->get("subscriptionGroupId")]);
}


#-------------------------------------------------------------------
sub view {
	my $self = shift;
	if ($self->session->user->userId eq '1' && !$self->session->form->process("sortBy")) {
		my $out = WebGUI::Cache->new($self->session,"view_".$self->getId)->get;
		return $out if $out;
	}
	my $scratchSortBy = $self->getId."_sortBy";
	my $scratchSortOrder = $self->getId."_sortDir";
	my $sortBy = $self->session->form->process("sortBy") || $self->session->scratch->get($scratchSortBy) || $self->get("sortBy");
	my $sortOrder = $self->session->scratch->get($scratchSortOrder) || $self->get("sortOrder");
	if ($sortBy ne $self->session->scratch->get($scratchSortBy) && $self->session->form->process("func") ne "editSave") {
		$self->session->scratch->set($scratchSortBy,$self->session->form->process("sortBy"));
	} elsif ($self->session->form->process("sortBy") && $self->session->form->process("func") ne "editSave") {
                if ($sortOrder eq "asc") {
                        $sortOrder = "desc";
                } else {
                        $sortOrder = "asc";
                }
                $self->session->scratch->set($scratchSortOrder, $sortOrder);
	}
	$sortBy ||= "dateUpdated";
	$sortOrder ||= "desc";
	my %var;
	$var{'user.canPost'} = $self->canPost;
        $var{"add.url"} = $self->getNewThreadUrl;
        $var{"rss.url"} = $self->getRssUrl;
        $var{'user.isModerator'} = $self->canEdit;
        $var{'user.isVisitor'} = ($self->session->user->userId eq '1');
	$var{'user.isSubscribed'} = $self->isSubscribed;
	$var{'sortby.title.url'} = $self->getSortByUrl("title");
	$var{'sortby.username.url'} = $self->getSortByUrl("username");
	$var{'sortby.date.url'} = $self->getSortByUrl("dateSubmitted");
	$var{'sortby.lastreply.url'} = $self->getSortByUrl("lastPostDate");
	$var{'sortby.views.url'} = $self->getSortByUrl("views");
	$var{'sortby.replies.url'} = $self->getSortByUrl("replies");
	$var{'sortby.rating.url'} = $self->getSortByUrl("rating");
	$self->session->style->setLink($var{"rss.url"},{ rel=>'alternate', type=>'application/rss+xml', title=>'RSS' });
	$var{"search.url"} = $self->getSearchUrl;
	$var{"subscribe.url"} = $self->getSubscribeUrl;
	$var{"unsubscribe.url"} = $self->getUnsubscribeUrl;
	my $sql = "select asset.assetId,asset.className,assetData.revisionDate as revisionDate
		from Thread
		left join asset on Thread.assetId=asset.assetId
		left join Post on Post.assetId=Thread.assetId and Thread.revisionDate = Post.revisionDate
		left join assetData on assetData.assetId=Thread.assetId and Thread.revisionDate = assetData.revisionDate
		where asset.parentId=".$self->session->db->quote($self->getId)." and asset.state='published' and 
		asset.className='WebGUI::Asset::Post::Thread' and assetData.revisionDate=(SELECT max(revisionDate) from assetData 
			where assetData.assetId=asset.assetId) and (assetData.status='approved'  
			or assetData.tagId=".$self->session->db->quote($self->session->scratch->get("versionTag")).") 
		group by assetData.assetId order by Thread.isSticky desc, ".$sortBy." ".$sortOrder;
	my $p = WebGUI::Paginator->new($self->session,$self->getUrl,$self->get("threadsPerPage"));
	$p->setDataByQuery($sql);
	$self->appendPostListTemplateVars(\%var, $p);
	$self->appendTemplateLabels(\%var);
       	my $out = $self->processTemplate(\%var,undef,$self->{_viewTemplate});
	if ($self->session->user->userId eq '1' && !$self->session->form->process("sortBy")) {
		WebGUI::Cache->new($self->session,"view_".$self->getId)->set($out,$self->get("visitorCacheTimeout"));
	}
       	return $out;
}

#-------------------------------------------------------------------

=head2 www_search ( )

The web method to display and use the forum search interface.

=cut

sub www_search {
	my $self = shift;
	my $i18n = WebGUI::International->new($self->session, 'Asset_Collaboration');
        my %var;
        $var{'form.header'} = WebGUI::Form::formHeader($self->session,{action=>$self->getUrl})
         	.WebGUI::Form::hidden($self->session,{ name=>"func", value=>"search" })
        	.WebGUI::Form::hidden($self->session,{ name=>"doit", value=>1 });
        $var{'query.form'} = WebGUI::Form::text($self->session,{
                name=>'query',
                value=>$self->session->form->process("query","text")
                });
        $var{'form.search'} = WebGUI::Form::submit($self->session,{value=>$i18n->get(170,'WebGUI')});
        $var{'form.footer'} = WebGUI::Form::formFooter($self->session);
        $var{'back.url'} = $self->getUrl;
	$self->appendTemplateLabels(\%var);
        $var{doit} = $self->session->form->process("doit");
        if ($self->session->form->process("doit")) {
		my $search = WebGUI::Search->new($self->session);
		$search->search({
				keywords=>$self->session->form->process("query","text"),
				lineage=>[$self->get("lineage")],
				classes=>["WebGUI::Asset::Post", "WebGUI::Asset::Post::Thread"]
				});
		my $p = $search->getPaginatorResultSet($self->getUrl("func=search;doit=1"), $self->get("threadsPerPage"));
		$self->appendPostListTemplateVars(\%var, $p);
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
	my $self = shift;
        my ($time) = @_;
        my ($year, $mon, $mday, $hour, $min, $sec) = $self->session->datetime->localtime($time);
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
	my $disableCache = ($self->session->form->process("sortBy") ne "");
	return $self->SUPER::www_view($disableCache);
}


#-------------------------------------------------------------------
# print out RSS 2.0 feed describing the items visible on the first page
sub www_viewRSS {
	my $self = shift;
	 return $self->session->privilege->noAccess() unless $self->canView;
	my %var;

	$self->logView() if ($self->session->setting->get("passiveProfilingEnabled"));        
	# Set the required channel variables
	$var{'title'} = _xml_encode($self->get("title"));
	$var{'link'} = _xml_encode($self->getUrl);
	$var{'description'} = _xml_encode($self->get("description"));
	# Set some of the optional channel variables
	$var{'generator'} = "WebGUI ".$WebGUI::VERSION;
	$var{'lastBuildDate'} = _xml_encode($self->_get_rfc822_date($self->get("dateUpdated")));
	$var{'webMaster'} = $self->session->setting->get("companyEmail");
	$var{'docs'} = "http://blogs.law.harvard.edu/tech/rss";

	my $sth = $self->session->db->read("select asset.assetId, asset.className, max(assetData.revisionDate) 
		from Thread
		left join asset on Thread.assetId=asset.assetId
		left join Post on Post.assetId=Thread.assetId and Thread.revisionDate=Post.revisionDate
		left join assetData on assetData.assetId=Thread.assetId and Thread.revisionDate=assetData.revisionDate
		where asset.parentId=".$self->session->db->quote($self->getId)." and asset.state='published' 
			and asset.className='WebGUI::Asset::Post::Thread' 
			and (assetData.status='approved'
			 or assetData.tagId=".$self->session->db->quote($self->session->scratch->get("versionTag")).")
		group by assetData.assetId
		order by ".$self->getValue("sortBy")." ".$self->getValue("sortOrder"));
	my $i = 1;
        while (my ($id, $class, $version)  = $sth->array) {
		my $post = WebGUI::Asset::Wobject::Collaboration->new($self->session, $id, $class, $version);
		my $encUrl = _xml_encode($self->session->url->getSiteURL().$post->getUrl);

		my @attachmentLoop = ();
		unless ($post->get("storageId") eq "") {
			my $storage = $post->getStorageLocation;
			foreach my $filename (@{ $storage->getFiles }) {
				push @attachmentLoop, {
					'attachment.url' => $storage->getUrl($filename),
					'attachment.path' =>  $storage->getPath($filename),
					'attachment.length' => $storage->getFileSize($filename),
				};
			}
		}
		push(@{$var{'item_loop'}}, {
		    author => _xml_encode($post->get('username')),
		    title => _xml_encode($post->get("title")),
		    link => $encUrl,
		    description => _xml_encode($post->get("synopsis")),
		    guid => $encUrl,
		    pubDate => _xml_encode($self->_get_rfc822_date($post->get("dateUpdated"))),
		    attachmentLoop => \@attachmentLoop,
		    });
		$i++;
		last if ($i == $self->get("threadsPerPage"));
        }

	$self->session->http->setMimeType("text/xml");
	my $output = $self->processTemplate(\%var,$self->get("rssTemplateId"));
	WebGUI::Macro::process($self->session,\$output);
	return $output;
}




1;

