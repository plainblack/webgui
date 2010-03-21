package WebGUI::Asset::Wobject::Collaboration;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
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
use Class::C3;
use base qw(WebGUI::AssetAspect::RssFeed WebGUI::Asset::Wobject);


#-------------------------------------------------------------------
sub _computePostCount {
	my $self = shift;
	return scalar @{$self->getLineage(['descendants'], {includeOnlyClasses => ['WebGUI::Asset::Post']})};
}

#-------------------------------------------------------------------
sub _computeThreadCount {
	my $self = shift;
	return scalar @{$self->getLineage(['children'], {includeOnlyClasses => ['WebGUI::Asset::Post::Thread']})};
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
sub _visitorCacheKey {
	my $self = shift;
	my $pn = $self->session->form->process('pn');
	return "view_".$self->getId."?pn=".$pn;
}

#-------------------------------------------------------------------
sub _visitorCacheOk {
	my $self = shift;
	return ($self->session->user->isVisitor
		&& !$self->session->form->process('sortBy'));
}

#-------------------------------------------------------------------

=head2 addChild 

Extend the base method to allow only Threads as children.

=cut

sub addChild {
	my $self = shift;
	my $properties = shift;
	my @other = @_;
	if ($properties->{className} ne "WebGUI::Asset::Post::Thread") {
		$self->session->errorHandler->security("add a ".$properties->{className}." to a ".$self->get("className"));
		return undef;
	}
	return $self->next::method($properties, @other);
}


#-------------------------------------------------------------------

=head2 appendPostListTemplateVars ($var, $p)

Takes a WebGUI::Paginator object that should be full of Posts, and appends template
variables to the hash reference.

=head3 $var

A hash reference.  Template variables will be added to it.

=head3 $p

A reference to a WebGUI::Paginator object.

=cut

sub appendPostListTemplateVars {
	my $self    = shift;
    my $session = $self->session;
	my $var     = shift;
	my $p       = shift;
	my $page    = $p->getPageData;
	my $i       = 0;
    my ($icon, $datetime) = $session->quick(qw(icon datetime));
    my $isVisitor         = $session->user->isVisitor;
	foreach my $row (@$page) {
		my $post = WebGUI::Asset->new($session,$row->{assetId}, $row->{className}, $row->{revisionDate});
		$post->{_parent} = $self; # caching parent for efficiency 
		my $controls = $icon->delete('func=delete',$post->get("url"),"Delete") . $icon->edit('func=edit',$post->get("url"));
		if ($self->get("sortBy") eq "lineage") {
			if ($self->get("sortOrder") eq "desc") {
				$controls .= $icon->moveUp('func=demote',$post->get("url")).$icon->moveDown('func=promote',$post->get("url"));
			} 
            else {
				$controls .= $icon->moveUp('func=promote',$post->get("url")).$icon->moveDown('func=demote',$post->get("url"));
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
					"lastReply.url"                 => $lastPost->getThreadLinkUrl,
                    "lastReply.title"               => $lastPost->get("title"),
                    "lastReply.user.isVisitor"      => $lastPost->get("ownerUserId") eq "1",
                    "lastReply.username"            => $lastPost->get("username"),
                    "lastReply.hideProfileUrl"      => $lastPost->get("ownerUserId") eq "1" || $isVisitor,
                    "lastReply.userProfile.url"     => $lastPost->getPosterProfileUrl(),
                    "lastReply.dateSubmitted.human" => $datetime->epochToHuman($lastPost->get("creationDate"),"%z"),
                    "lastReply.timeSubmitted.human" => $datetime->epochToHuman($lastPost->get("creationDate"),"%Z"),
					);
			}
			$hasRead = $post->isMarkedRead;
		}
		my %postVars = (
			%{$post->get},
            "id"                    => $post->getId,
            "url"                   => $post->getThreadLinkUrl,
			rating_loop             => \@rating_loop,
			"content"               => $post->formatContent,
            "status"                => $post->getStatus,
            "thumbnail"             => $post->getThumbnailUrl,
            "image.url"             => $post->getImageUrl,
            "dateSubmitted.human"   => $datetime->epochToHuman($post->get("creationDate"),"%z"),
            "dateUpdated.human"     => $datetime->epochToHuman($post->get("revisionDate"),"%z"),
            "timeSubmitted.human"   => $datetime->epochToHuman($post->get("creationDate"),"%Z"),
            "timeUpdated.human"     => $datetime->epochToHuman($post->get("revisionDate"),"%Z"),
            "hideProfileUrl"        => $post->get('ownerUserId') eq '1' || $isVisitor,
            "userProfile.url"       => $post->getPosterProfileUrl,
            "user.isVisitor"        => $post->get("ownerUserId") eq "1",
        	"edit.url"              => $post->getEditUrl,
			'controls'              => $controls,
            "isSecond"              => (($i+1) == 2),
            "isThird"               => (($i+1) == 3),
            "isFourth"              => (($i+1) == 4),
            "isFifth"               => (($i+1) == 5),
			"user.hasRead"          => $hasRead,
            "user.isPoster"         => $post->isPoster,
            "avatar.url"            => $post->getAvatarUrl,
			%lastReply
		);
        $post->getTemplateMetadataVars(\%postVars);
		if ($row->{className} =~ m/^WebGUI::Asset::Post::Thread/) {
			$postVars{'rating'} = $post->get('threadRating');
		}
        push(@{$var->{post_loop}}, \%postVars );
		$i++;
	}
	$p->appendTemplateVars($var);
}

#-------------------------------------------------------------------

=head2 appendTemplateLabels ($var)

Appends a whole mess of internationalized labels for use in a template.

=head3 $var

A hash reference.  Template labels will be appended to it.

=cut

sub appendTemplateLabels {
	my $self = shift;
	my $var = shift;
	my $i18n = WebGUI::International->new($self->session, "Asset_Collaboration");
	$var->{"transferkarma.label"} = $i18n->get("transfer karma");
	$var->{"karmaScale.label"} = $i18n->get("karma scale");
	$var->{"close.label"} = $i18n->get("close");
	$var->{"closed.label"} = $i18n->get("closed");
	$var->{"open.label"} = $i18n->get("open");
	$var->{"critical.label"} = $i18n->get("critical");
	$var->{"cosmetic.label"} = $i18n->get("cosmetic");
	$var->{"minor.label"} = $i18n->get("minor");
	$var->{"fatal.label"} = $i18n->get("fatal");
	$var->{"severity.label"} = $i18n->get("severity");
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
	$var->{"karmaRank.label"} = $i18n->get("karma rank");
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
    $var->{"captcha_label"} = $i18n->get("captcha label");
	$var->{'keywords.label'} = $i18n->get('keywords label');
}

#-------------------------------------------------------------------

=head2 canEdit ( [ $userId ] )

Extends the base method to include adding Threads to this CS.

=head3 $userId

A userId to check for edit permissions. If $userId is false, then it checks
the current session user.

=cut

sub canEdit {
        my $self    = shift;
        my $userId  = shift     || $self->session->user->userId;
        return (
		(
			(
				$self->session->form->process("func") eq "add" || 
				(
					$self->session->form->process("assetId") eq "new" && 
					$self->session->form->process("func") eq "editSave" && 
					$self->session->form->process("class") eq "WebGUI::Asset::Post::Thread"
				)
			) && 
			$self->canStartThread( $userId )
		) || # account for new threads
		$self->next::method( $userId )
	);
}

#-------------------------------------------------------------------

=head2 canModerate  ( [ $userId ] )

Returns true if the user can edit this Collaboration System.

=head3 $userId

A userId to check for permission. If $userId is false, then it checks
the current session user.

=cut

sub canModerate {
    my $self    = shift;
    my $userId  = shift     || $self->session->user->userId;
    return $self->WebGUI::Asset::canEdit( $userId );
}

#-------------------------------------------------------------------

=head2 canPost ( [ $userId ] )

Returns true if the user can post to the CS.  Checks that the CS is committed,
that the user is in the group to post, or that the user can edit this CS.

=head3 $userId

A userId to check for edit permissions. If $userId is false, then it checks
the current session user.

=cut

sub canPost {
    my $self    = shift;
    my $userId  = shift;
    my $session = $self->session;
    my $user    = $userId
                ? WebGUI::User->new( $session, $userId )
                : $self->session->user
                ;

    # checks to make sure that the cs has been committed at least once
    if  ( $self->get("status") ne "approved" && $self->getTagCount <= 1 ) {
        return 0;
    }
    # Users in the postGroupId can post
    elsif ( $user->isInGroup( $self->get("postGroupId") ) ) {
        return 1;
    }
    # Users who can edit the collab can post
    else {
        return $self->WebGUI::Asset::canEdit( $userId );
    }
}


#-------------------------------------------------------------------

=head2 canSubscribe  ( [ $userId ] )

Returns true if the user can subscribe to the CS.  Checks that the user is registered
and that they canView the Post.

=head3 $userId

A userId to check for edit permissions. If $userId is false, then it checks
the current session user.

=cut

sub canSubscribe {
    my $self    = shift;
    my $userId  = shift;
    my $session = $self->session;
    my $user    = $userId
                ? WebGUI::User->new( $session, $userId )
                : $self->session->user
                ;
    return ($user->isRegistered && $self->canView( $userId ) );
}

#-------------------------------------------------------------------

=head2 canStartThread   ( [ $userId ] )

Returns true if the user can start a thread in the CS.  Checks that the user is in the
canStartThreadGroup or that they canEdit the CS.

=head3 $userId

A userId to check for edit permissions. If $userId is false, then it checks
the current session user.

=cut

sub canStartThread {
    my $self    = shift;
    my $userId  = shift;
    my $session = $self->session;
    my $user    = $userId
                ? WebGUI::User->new( $session, $userId )
                : $self->session->user
                ;
    return (
        $user->isInGroup($self->get("canStartThreadGroupId")) 
        || $self->WebGUI::Asset::canEdit( $userId )
    );
}


#-------------------------------------------------------------------

=head2 canView ( [ $userId ] )

Extends the base method to also allow users who canPost to the CS.

=head3 $userId

A userId to check for edit permissions. If $userId is false, then it checks
the current session user.

=cut

sub canView {
	my $self = shift;
        my $userId  = shift     || $self->session->user->userId;
	return $self->next::method( $userId ) || $self->canPost( $userId );
}

#-------------------------------------------------------------------

=head2 commit 

Extend the base method to handle making a cron job for fetching mail for the CS.  The
cron job is created even if the CS does not have email enabled.  The cron is disabled
in that case.

=cut

sub commit {
    my $self = shift;
    $self->next::method;
    my $cron = undef;
    if ($self->get("getMailCronId")) {
        $cron = WebGUI::Workflow::Cron->new($self->session, $self->get("getMailCronId"));
    }
    my $i18n = WebGUI::International->new($self->session, "Asset_Collaboration");
    unless (defined $cron) {
            $cron = WebGUI::Workflow::Cron->create($self->session, {
                    title=>$self->getTitle." ".$i18n->get("mail"),
                    minuteOfHour=>"*/".($self->get("getMailInterval")/60),
                    className=>(ref $self),
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

=head2 createSubscriptionGroup 

Creates a group to hold users who want to receive posts to this CS by email.

=cut

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
sub definition {
	my $class = shift;
	my $session = shift;
        my $definition = shift;
	my $i18n = WebGUI::International->new($session,"Asset_Collaboration");
	my $useKarma = $session->setting->get('useKarma');

    # obtain the groupIdEdit default value. Try to get it from the parent asset
    # if it exists. If not, default to the value specified in WebGUI::Asset's
    # definition.
    my $groupIdEdit;
    if($session->asset) {
        $groupIdEdit = $session->asset->get('groupIdEdit');
    }
    else {
        $groupIdEdit = '4';
    }


	my %sortByOptions;
	tie %sortByOptions, 'Tie::IxHash';
	%sortByOptions = (lineage=>$i18n->get('sequence'),
			  "assetData.revisionDate"=>$i18n->get('date updated'),
			  creationDate=>$i18n->get('date submitted'),
			  title=>$i18n->get('title'),
			  userDefined1=>$i18n->get('user defined 1'),
			  userDefined2=>$i18n->get('user defined 2'),
			  userDefined3=>$i18n->get('user defined 3'),
			  userDefined4=>$i18n->get('user defined 4'),
			  userDefined5=>$i18n->get('user defined 5'),
			  ($useKarma? (karmaRank=>$i18n->get('karma rank')) : ()),
			 );

	my %properties;
	tie %properties, 'Tie::IxHash';
	%properties = (
		visitorCacheTimeout => {
			tab => "display",
			fieldType => "interval",
			defaultValue => 3600,
			uiLevel => 8,
			label => $i18n->get("visitor cache timeout"),
			hoverHelp => $i18n->get("visitor cache timeout help")
			},
		autoSubscribeToThread => {
			fieldType=>"yesNo",
			defaultValue=>1,
			tab=>'mail',
			label=>$i18n->get("auto subscribe to thread"),
			hoverHelp=>$i18n->get("auto subscribe to thread help"),
			},
		requireSubscriptionForEmailPosting => {
			fieldType=>"yesNo",
			defaultValue=>1,
			tab=>'mail',
			label=>$i18n->get("require subscription for email posting"),
			hoverHelp=>$i18n->get("require subscription for email posting help"),
			},
		approvalWorkflow =>{
			fieldType=>"workflow",
			defaultValue=>"pbworkflow000000000003",
			type=>'WebGUI::VersionTag',
			tab=>'security',
			label=>$i18n->get('approval workflow'),
			hoverHelp=>$i18n->get('approval workflow description'),
			},
		threadApprovalWorkflow =>{
			fieldType=>"workflow",
			defaultValue=>"pbworkflow000000000003",
			type=>'WebGUI::VersionTag',
			tab=>'security',
			label=>$i18n->get('thread approval workflow'),
			hoverHelp=>$i18n->get('thread approval workflow description'),
			},
		thumbnailSize => {
			fieldType => "integer",
			defaultValue => 0,
			tab => "display",
			label => $i18n->get("thumbnail size"),
			hoverHelp => $i18n->get("thumbnail size help")
			},
		maxImageSize => {
			fieldType => "integer",
			defaultValue => 0,
			tab => "display",
			label => $i18n->get("max image size"),
			hoverHelp => $i18n->get("max image size help")
			},
		mailServer=>{
			fieldType=>"text",
			defaultValue=>undef,
			tab=>'mail',
			label=>$i18n->get("mail server"),
			hoverHelp=>$i18n->get("mail server help"),
			},
		mailAccount=>{
			fieldType=>"text",
			defaultValue=>undef,
			tab=>'mail',
			label=>$i18n->get("mail account"),
			hoverHelp=>$i18n->get("mail account help"),
			},
		mailPassword=>{
			fieldType=>"password",
			defaultValue=>undef,
			tab=>'mail',
			label=>$i18n->get("mail password"),
			hoverHelp=>$i18n->get("mail password help"),
			},
		mailAddress=>{
			fieldType=>"email",
			defaultValue=>undef,
			tab=>'mail',
			label=>$i18n->get("mail address"),
			hoverHelp=>$i18n->get("mail address help"),
			},
		mailPrefix=>{
			fieldType=>"text",
			defaultValue=>undef,
			tab=>'mail',
			label=>$i18n->get("mail prefix"),
			hoverHelp=>$i18n->get("mail prefix help"),
			},
		getMailCronId=>{
			fieldType=>"hidden",
			defaultValue=>undef,
			noFormPost=>1
			},
		getMail=>{
			fieldType=>"yesNo",
			defaultValue=>0,
			tab=>'mail',
			label=>$i18n->get("get mail"),
			hoverHelp=>$i18n->get("get mail help"),
			},
		getMailInterval=>{
			fieldType=>"interval",
			defaultValue=>300,
			tab=>'mail',
			label=>$i18n->get("get mail interval"),
			hoverHelp=>$i18n->get("get mail interval help"),
			},
		displayLastReply =>{
			fieldType=>"yesNo",
			defaultValue=>0,
			tab=>'display',
			label=>$i18n->get('display last reply'),
			hoverHelp=>$i18n->get('display last reply description'),
			},
		allowReplies =>{
			fieldType=>"yesNo",
			defaultValue=>1,
			tab=>'security',
			label=>$i18n->get('allow replies'),
			hoverHelp=>$i18n->get('allow replies description'),
			},
		threadsPerPage =>{
			fieldType=>"integer",
			defaultValue=>30,
			tab=>'display',
			label=>$i18n->get('threads/page'),
			hoverHelp=>$i18n->get('threads/page description'),
			},
		postsPerPage =>{
			fieldType=>"integer",
			defaultValue=>10,
			tab=>'display',
			label=>$i18n->get('posts/page'),
			hoverHelp=>$i18n->get('posts/page description'),
			},
                archiveEnabled => {
                    fieldType       => "yesNo",
                    defaultValue    => 1,
                    tab             => 'properties',
                    label           => $i18n->get('editForm archiveEnabled label'),
                    hoverHelp       => $i18n->get('editForm archiveEnabled description'),
                },
		archiveAfter =>{
			fieldType=>"interval",
			defaultValue=>31536000,
			tab=>'properties',
			label=>$i18n->get('archive after'),
			hoverHelp=>$i18n->get('archive after description'),
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
			defaultValue=>1,
			tab=>'display',
			label=>$i18n->get('content filter'),
			hoverHelp=>$i18n->get('content filter description'),
			},
		filterCode =>{
			fieldType=>"filterContent",
			defaultValue=>'most',
			tab=>'security',
			label=>$i18n->get('filter code'),
			hoverHelp=>$i18n->get('filter code description'),
			},
		replyFilterCode =>{
			fieldType=>"filterContent",
			defaultValue=>'most',
			tab=>'security',
			label=>$i18n->get('reply filter code'),
			hoverHelp=>$i18n->get('reply filter code description'),
			},
		richEditor =>{
			fieldType=>"selectRichEditor",
			defaultValue=>"PBrichedit000000000002",
			tab=>'display',
			label=>$i18n->get('rich editor'),
			hoverHelp=>$i18n->get('rich editor description'),
			},
		replyRichEditor =>{
			fieldType=>"selectRichEditor",
			defaultValue=>"PBrichedit000000000002",
			tab=>'display',
			label=>$i18n->get('reply rich editor'),
			hoverHelp=>$i18n->get('reply rich editor description'),
			},
		attachmentsPerPost =>{
			fieldType=>"integer",
			defaultValue=>0,
			tab=>'properties',
			label=>$i18n->get('attachments/post'),
			hoverHelp=>$i18n->get('attachments/post description'),
			},
		editTimeout =>{
			fieldType=>"interval",
			defaultValue=>3600,
			tab=>'security',
			label=>$i18n->get('edit timeout'),
			hoverHelp=>$i18n->get('edit timeout description'),
			},
		addEditStampToPosts =>{
			fieldType=>"yesNo",
			defaultValue=>0,
			tab=>'security',
			label=>$i18n->get('edit stamp'),
			hoverHelp=>$i18n->get('edit stamp description'),
			},
		usePreview =>{
			fieldType=>"yesNo",
			defaultValue=>1,
			tab=>'properties',
			label=>$i18n->get('use preview'),
			hoverHelp=>$i18n->get('use preview description'),
			},
		sortOrder =>{
			fieldType=>"selectBox",
			defaultValue=>'desc',
			tab=>'display',
			options=>{ asc => $i18n->get('ascending'),
				   desc => $i18n->get('descending') },
			label=>$i18n->get('sort order'),
			hoverHelp=>$i18n->get('sort order description'),
			},
		sortBy =>{
			fieldType=>"selectBox",
			defaultValue=>'assetData.revisionDate',
			tab=>'display',
			options=>\%sortByOptions,
			label=>$i18n->get('sort by'),
			hoverHelp=>$i18n->get('sort by description'),
			},
		notificationTemplateId =>{
			fieldType=>"template",
			namespace=>"Collaboration/Notification",
			defaultValue=>'PBtmpl0000000000000027',
			tab=>'mail',
			label=>$i18n->get('notification template'),
			hoverHelp=>$i18n->get('notification template description'),
			},
		searchTemplateId =>{
			fieldType=>"template",
			namespace=>"Collaboration/Search",
			defaultValue=>'PBtmpl0000000000000031',
			tab=>'display',
			label=>$i18n->get('search template'),
			hoverHelp=>$i18n->get('search template description'),
			},
		postFormTemplateId =>{
			fieldType=>"template",
			namespace=>"Collaboration/PostForm",
			defaultValue=>'PBtmpl0000000000000029',
			tab=>'display',
			label=>$i18n->get('post template'),
			hoverHelp=>$i18n->get('post template description'),
			},
		threadTemplateId =>{
			fieldType=>"template",
			namespace=>"Collaboration/Thread",
			defaultValue=>'PBtmpl0000000000000032',
			tab=>'display',
			label=>$i18n->get('thread template'),
			hoverHelp=>$i18n->get('thread template description'),
			},
		collaborationTemplateId =>{
			fieldType=>"template",
			namespace=>'Collaboration',
			defaultValue=>'PBtmpl0000000000000026',
			tab=>'display',
			label=>$i18n->get('system template'),
			hoverHelp=>$i18n->get('system template description'),
			},
		karmaPerPost =>{
			fieldType=>"integer",
			defaultValue=>0,
			tab=>'properties',
			visible=>$useKarma,
			label=>$i18n->get('karma/post'),
			hoverHelp=>$i18n->get('karma/post description'),
			},
		karmaSpentToRate => {
			fieldType => "integer",
			defaultValue=> 0,
			tab=>'properties',
			visible => $useKarma,
			label => $i18n->get('karma spent to rate'),
			hoverHelp => $i18n->get('karma spent to rate description'),
			},
		karmaRatingMultiplier => {
			fieldType => "integer",
			defaultValue=> 1,
			tab=>'properties',
			visible => $useKarma,
			label=>$i18n->get('karma rating multiplier'),
			hoverHelp=>$i18n->get('karma rating multiplier description'),
			},
		avatarsEnabled =>{
			fieldType=>"yesNo",
			defaultValue=>0,
			tab=>'properties',
			label=>$i18n->get('enable avatars'),
			hoverHelp=>$i18n->get('enable avatars description'),
			},
		enablePostMetaData =>{
			fieldType=>"yesNo",
			defaultValue=>0,
			tab=>'meta',
			label=>$i18n->get('enable metadata'),
			hoverHelp=>$i18n->get('enable metadata description'),
			},
		postGroupId =>{
			fieldType=>"group",
			defaultValue=>'2',
			tab=>'security',
			label=>$i18n->get('who posts'),
			hoverHelp=>$i18n->get('who posts description'),
			},
		canStartThreadGroupId =>{
			fieldType=>"group",
			defaultValue=>'2',
			tab=>'security',
			label=>$i18n->get('who threads'),
			hoverHelp=>$i18n->get('who threads description'),
			},
		defaultKarmaScale => {
			fieldType=>"integer",
			defaultValue=>1,
			tab=>'properties',
			visible=>$useKarma,
			label=>$i18n->get("default karma scale"),
			hoverHelp=>$i18n->get('default karma scale help'),
			},
        useCaptcha => {
            fieldType=>"yesNo",
            defaultValue=>'0',
            tab=>'security',
            label=>$i18n->get('use captcha label'),
            hoverHelp=>$i18n->get('use captcha hover help'),
        },
        subscriptionGroupId =>{
            fieldType=>"subscriptionGroup",
            tab=>'security',
            label=>$i18n->get("subscription group label"),
            hoverHelp=>$i18n->get("subscription group hoverHelp"),
            noFormPost=>1,
            defaultValue=>undef,
        },
        groupToEditPost=>{
            tab=>"security",
            label=>$i18n->get('group to edit label'),
            excludeGroups=>[1,7],
            hoverHelp=>$i18n->get('group to edit hoverhelp'),
            uiLevel=>6,
            fieldType=>'group',
            filter=>'fixId',
            defaultValue=>$groupIdEdit, # groupToEditPost should default to groupIdEdit
        },
        postReceivedTemplateId =>{
            fieldType=>'template',
            namespace=>'Collaboration/PostReceived',
            tab=>'display',
            label=>$i18n->get('post received template'),
            hoverHelp=>$i18n->get('post received template hoverHelp'),
            defaultValue=>'default_post_received1',
        },
        );

        push(@{$definition}, {
		assetName=>$i18n->get('assetName'),
		autoGenerateForms=>1,
		icon=>'collaboration.gif',
                tableName=>'Collaboration',
                className=>'WebGUI::Asset::Wobject::Collaboration',
                properties=>\%properties,
		});
        return $class->next::method($session, $definition);
}

#-------------------------------------------------------------------

=head2 duplicate 

Extend the base method to handle making a subscription group for the new CS, and
to build a new Cron job.  It also recalculates the number of threads and replies.

=cut

sub duplicate {
	my $self = shift;
	my $newAsset = $self->next::method(@_);
	$newAsset->createSubscriptionGroup;
    my $i18n = WebGUI::International->new($self->session, "Asset_Collaboration");
    my $newCron = WebGUI::Workflow::Cron->create($self->session, {
            title=>$self->getTitle." ".$i18n->get("mail"),
            minuteOfHour=>"*/".($self->get("getMailInterval")/60),
            className=>(ref $self),
            methodName=>"new",
            parameters=>$self->getId,
            workflowId=>"csworkflow000000000001"
    });
    $newAsset->update({getMailCronId=>$newCron->getId});
    $newAsset->incrementReplies('','');
    return $newAsset;
}

#-------------------------------------------------------------------

=head2 duplicateBranch.

Extend the base method to recalculate the number of threads and replies.

=cut

sub duplicateBranch {
    my $self = shift;
    my $newAsset = $self->next::method(@_);
    $newAsset->incrementReplies('','');
    return $newAsset;
}

#-------------------------------------------------------------------

=head2 getEditTabs

Add a tab for the mail interface.

=cut

sub getEditTabs {
	my $self = shift;
	my $i18n = WebGUI::International->new($self->session,"Asset_Collaboration");
	return ($self->next::method, ['mail', $i18n->get('mail'), 9]);
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

=head2 getRssFeedItems 

Returns an array ref of Posts for use in making the feeds for this CS.

=cut

sub getRssFeedItems {
	my $self = shift;

	# XXX copied and reformatted this query from www_viewRSS, but why is it constructed like this?
	# And it's duplicated inside view, too!  Eeeagh!  And it uses the versionTag scratch var...
	my ($sortBy, $sortOrder) = ($self->getValue('sortBy'), $self->getValue('sortOrder'));
	
    my @postIds = $self->session->db->buildArray(<<"SQL", [$self->getId, $self->session->scratch->get('versionTag')]);
  SELECT asset.assetId
    FROM Thread
         LEFT JOIN asset ON Thread.assetId = asset.assetId
         LEFT JOIN Post ON Post.assetId = Thread.assetId AND Post.revisionDate = Thread.revisionDate
         LEFT JOIN assetData ON assetData.assetId = Thread.assetId
                                AND assetData.revisionDate = Thread.revisionDate
   WHERE asset.parentId = ? AND asset.state = 'published' AND asset.className = 'WebGUI::Asset::Post::Thread'
         AND (assetData.status = 'approved' OR assetData.tagId = ?)
   GROUP BY assetData.assetId
   ORDER BY $sortBy $sortOrder
SQL
	my $siteUrl = $self->session->url->getSiteURL();
	my $datetime = $self->session->datetime;

    my @posts;
    my $rssLimit = $self->get('itemsPerFeed');
    for my $postId (@postIds) {
		my $post = WebGUI::Asset->new($self->session, $postId, 'WebGUI::Asset::Post::Thread');
		my $postUrl = $siteUrl . $post->getUrl;
		# Buggo: this is an abuse of 'author'.  'author' is supposed to be an email address.
		# But this is how it was in the original Collaboration RSS, so.
        
        # Create the attachment template loop
        my $storage = $post->getStorageLocation;
        my $attachmentLoop = [];
        if ($post->get('storageId')) {
            for my $file (@{$storage->getFiles}) {
                push @{$attachmentLoop}, {
                    'attachment.url'        => $storage->getUrl($file),
                    'attachment.path'       => $storage->getPath($file),
                    'attachment_thumbnail'  => $storage->getThumbnailUrl($file),
                    'attachment.length'     => $storage->getFileSize($file),
                };
            }
        }
        
        push @posts, {
            author          => $post->get('username'),
		    title           => $post->get('title'),
		    'link'          => $postUrl,
            guid            => $postUrl,
		    description     => $post->get('synopsis'),
            epochDate       => $post->get('creationDate'),
		    pubDate         => $datetime->epochToMail($post->get('creationDate')),
		    attachmentLoop  => $attachmentLoop,
			userDefined1 => $post->get("userDefined1"),
			userDefined2 => $post->get("userDefined2"),
			userDefined3 => $post->get("userDefined3"),
			userDefined4 => $post->get("userDefined4"),
			userDefined5 => $post->get("userDefined5"),
		 };

         last if $rssLimit <= scalar(@posts);
	}

    return \@posts;
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

=head2 getSortBy

Retrieves the field to sort by

=cut

sub getSortBy {
    my $self = shift;
    my $scratchSortBy = $self->getId."_sortBy";
    my $sortBy = $self->session->scratch->get($scratchSortBy) || $self->getValue("sortBy");
    # XXX: This should be fixed in an upgrade and in the definition, NOT HERE
    if ( $sortBy eq "rating" ) {
        $sortBy = "threadRating";
    }
    return $sortBy;
}

#-------------------------------------------------------------------

=head2 getSortOrder

Retrieves the direction to sort in

=cut

sub getSortOrder {
    my $self = shift;
    my $scratchSortOrder = $self->getId."_sortDir";
    my $sortOrder = $self->session->scratch->get($scratchSortOrder) || $self->getValue("sortOrder");
    return $sortOrder;
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

=head2 getThreadsPaginator

Returns a WebGUI::Paginator object containing all the threads in this
Collaboration System

=cut

sub getThreadsPaginator {
    my $self  = shift;

    my $scratchSortBy    = $self->getId."_sortBy";
    my $scratchSortOrder = $self->getId."_sortDir";
    my $sortBy    = $self->session->form->process("sortBy")   
                 || $self->session->scratch->get($scratchSortBy)
                 || $self->get("sortBy");
    my $sortOrder = $self->session->form->process("sortOrder")
                 || $self->session->scratch->get($scratchSortOrder)
                 || $self->get("sortOrder");
    if ($sortBy ne $self->session->scratch->get($scratchSortBy) && $self->session->form->process("func") ne "editSave") {
        $self->session->scratch->set($scratchSortBy,$self->session->form->process("sortBy"));
        $self->session->scratch->set($scratchSortOrder, $sortOrder);
    }
    elsif ($self->session->form->process("sortBy") && $self->session->form->process("func") ne "editSave" && ! $self->session->form->process('sortOrder')) {
        if ($sortOrder eq "asc") {
            $sortOrder = "desc";
        }
        else {
            $sortOrder = "asc";
        }
        $self->session->scratch->set($scratchSortOrder, $sortOrder);
    }
    $sortBy ||= "assetData.revisionDate";
    $sortOrder ||= "desc";
    # Sort by the thread rating instead of the post rating.  other places don't care about threads.
    if ($sortBy eq 'rating') {
        $sortBy = 'threadRating';
    } 
    $sortBy = join('.', map { $self->session->db->dbh->quote_identifier($_) } split(/\./, $sortBy));

    my $sql = "
        select 
            asset.assetId,
            asset.className,
            assetData.revisionDate as revisionDate 
        from Thread 
            left join asset on Thread.assetId=asset.assetId 
            left join Post on Post.assetId=Thread.assetId and Thread.revisionDate = Post.revisionDate 
            left join assetData on assetData.assetId=Thread.assetId and Thread.revisionDate = assetData.revisionDate 
        where 
            asset.parentId=".$self->session->db->quote($self->getId)." 
            and asset.state='published' 
            and asset.className='WebGUI::Asset::Post::Thread' 
            and assetData.revisionDate=(
                select
                    max(revisionDate) 
                from 
                    assetData 
                where 
                    assetData.assetId=asset.assetId 
                    and (status='approved' or status='archived')
            ) 
            and status='approved'
        group by 
            assetData.assetId 
        order by 
            Thread.isSticky desc, 
        ".$sortBy."
        ".$sortOrder;
    my $p     = WebGUI::Paginator->new($self->session,$self->getUrl,$self->get("threadsPerPage"));
    $p->setDataByQuery($sql);

    return $p;
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

=head2 getViewTemplateVars 

Returns a hash reference full of template variables that are used in
several CS templates.

=cut

sub getViewTemplateVars {
	my $self = shift;
	my %var;
	$var{'user.canPost'} = $self->canPost;
	$var{'user.canStartThread'} = $self->canStartThread;
    $var{"add.url"} = $self->getNewThreadUrl;
    $var{"rss.url"} = $self->getRssFeedUrl;
    $var{'user.isModerator'} = $self->canModerate;
    $var{'user.isVisitor'} = ($self->session->user->isVisitor);
	$var{'user.isSubscribed'} = $self->isSubscribed;
	$var{'sortby.title.url'} = $self->getSortByUrl("title");
	$var{'sortby.username.url'} = $self->getSortByUrl("username");
	$var{'karmaIsEnabled'} = $self->session->setting->get("useKarma");
	$var{'sortby.karmaRank.url'} = $self->getSortByUrl("karmaRank");
	$var{'sortby.date.url'} = $self->getSortByUrl("creationDate");
	$var{'sortby.lastreply.url'} = $self->getSortByUrl("lastPostDate");
	$var{'sortby.views.url'} = $self->getSortByUrl("views");
	$var{'sortby.replies.url'} = $self->getSortByUrl("replies");
	$var{'sortby.rating.url'} = $self->getSortByUrl("rating");
	$var{"search.url"} = $self->getSearchUrl;
	$var{"subscribe.url"} = $self->getSubscribeUrl;
	$var{"unsubscribe.url"} = $self->getUnsubscribeUrl;
	$var{"collaborationAssetId"} = $self->getId;

    # Get the threads in this CS
    my $p = $self->getThreadsPaginator;
	$self->appendPostListTemplateVars(\%var, $p);
	$self->appendTemplateLabels(\%var);

    return \%var;
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
	my $threads = $self->_computeThreadCount;
        my $replies = $self->_computePostCount;
        $self->update({replies=>$replies, threads=>$threads, lastPostId=>$lastPostId, lastPostDate=>$lastPostDate});
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
        $self->update({threads=>$self->_computeThreadCount, lastPostId=>$lastPostId, lastPostDate=>$lastPostDate});
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
    $self->next::method;
    my $template = WebGUI::Asset::Template->new($self->session, $self->get("collaborationTemplateId"));
    if (!$template) {
        WebGUI::Error::ObjectNotFound::Template->throw(
            error      => qq{Template not found},
            templateId => $self->get("collaborationTemplateId"),
            assetId    => $self->getId,
        );
    }
    $template->prepare($self->getMetaDataAsTemplateVariables);
    $self->{_viewTemplate} = $template;
}


#-------------------------------------------------------------------

=head2 processPropertiesFromFormPost 

Extend the base method to handle creating subscription groups, propagating
group privileges to all descendants and clearing scratch variables for sort key
and direction.

=cut

sub processPropertiesFromFormPost {
	my $self = shift;
        my $updatePrivs = ($self->session->form->process("groupIdView") ne $self->get("groupIdView") || $self->session->form->process("groupIdEdit") ne $self->get("groupIdEdit"));
	$self->next::method;
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

=head2 purge 

Extend the base method to delete the subscription group and cron job for emails.

=cut

sub purge {
	my $self = shift;
	my $group = WebGUI::Group->new($self->session, $self->get("subscriptionGroupId"));
	if ($group) {
        $group->delete;
    }
	if ($self->get("getMailCronId")) {
		my $cron = WebGUI::Workflow::Cron->new($self->session, $self->get("getMailCronId"));
		$cron->delete if defined $cron;
	}
	$self->next::method;
}

#-------------------------------------------------------------------

=head2 purgeCache ( )

Extend the base method to delete view and visitor caches.

=cut

sub purgeCache {
	my $self = shift;
	WebGUI::Cache->new($self->session,"view_".$self->getId)->delete;
	WebGUI::Cache->new($self->session,$self->_visitorCacheKey)->delete;
	$self->next::method;
}

#-------------------------------------------------------------------

=head2 recalculateRating ( )

Calculates the rating of this forum from its threads and stores the new value in the forum properties.

=cut

sub recalculateRating {
    my $self = shift;
    
    # Get the number of threads
    my ($count) 
        = $self->session->db->quickArray(
            "select count(*) from Thread 
                left join asset on Thread.assetId=asset.assetId 
                left join Post on Thread.assetId=Post.assetId 
                    AND Thread.revisionDate = (SELECT MAX(revisionDate) FROM Thread t WHERE t.assetId=asset.assetId)
                where asset.parentId=?",
            [$self->getId]
        );  
    $count = $count || 1;
    
    # Get the ratings of all the threads
    my ($sum) 
        = $self->session->db->quickArray(
            "SELECT SUM(Thread.threadRating) 
                FROM Thread 
                LEFT JOIN asset ON Thread.assetId=asset.assetId 
                LEFT JOIN Post ON Thread.assetId=Post.assetId
                    AND Thread.revisionDate = (SELECT MAX(revisionDate) FROM Thread t WHERE t.assetId=asset.assetId)
                WHERE asset.parentId=?",
            [$self->getId]
        );

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

=head2 sumReplies ( )

Calculates the number of replies to this collaboration system and updates the counter to reflect that. Also updates thread count since it needs to know that to calculate reply count.

=cut

sub sumReplies {
        my $self = shift;
	my $threads = $self->_computeThreadCount;
	my $replies = $self->_computePostCount;
	$self->update({replies=>$replies, threads=>$threads});
}

#-------------------------------------------------------------------

=head2 sumThreads ( )

Calculates the number of threads in this collaboration system and updates the counter to reflect that.

=cut

sub sumThreads {
        my $self = shift;
	$self->update({threads=>$self->_computeThreadCount});
}

#-------------------------------------------------------------------

=head2 subscribe ( )

Subscribes a user to this collaboration system.

=cut

sub subscribe {
	my $self = shift;
    my $group;
    my $subscriptionGroup = $self->get('subscriptionGroupId');
    if ($subscriptionGroup) {
	    $group = WebGUI::Group->new($self->session,$subscriptionGroup);
    }
    if (!$group) {
        $self->createSubscriptionGroup;
	    $group = WebGUI::Group->new($self->session,$self->get('subscriptionGroupId'));
    }
    $group->addUsers([$self->session->user->userId]);
}

#-------------------------------------------------------------------

=head2 unsubscribe (  )

Unsubscribes a user from this collaboration system

=cut

sub unsubscribe {
	my $self = shift;
	my $group = WebGUI::Group->new($self->session,$self->get("subscriptionGroupId"));
	return
        unless $group;
    $group->deleteUsers([$self->session->user->userId],[$self->get("subscriptionGroupId")]);
}


#-------------------------------------------------------------------

=head2 view 

Render the CS, and handle local caching.

=cut

sub view {
	my $self = shift;
	if ($self->_visitorCacheOk) {
		my $out = WebGUI::Cache->new($self->session,$self->_visitorCacheKey)->get;
		$self->session->errorHandler->debug("HIT") if $out;
		return $out if $out;
	}

	# If the asset is not called through the normal prepareView/view cycle, first call prepareView.
	# This happens for instance in the viewDetail method in the Matrix. In that case the Collaboration
	# is called through the api.
	$self->prepareView unless ($self->{_viewTemplate});
    my $out = $self->processTemplate($self->getViewTemplateVars,undef,$self->{_viewTemplate});
	if ($self->_visitorCacheOk) {
		WebGUI::Cache->new($self->session,$self->_visitorCacheKey)->set($out,$self->get("visitorCacheTimeout"));
	}
    return $out;
}

#-------------------------------------------------------------------

=head2 www_edit 

Override the master class to add an "Unarchive All" link.

=cut

sub www_edit {
    my $self = shift;
    return $self->session->privilege->insufficient() unless $self->canEdit;
    return $self->session->privilege->locked() unless $self->canEditIfLocked;
    my $i18n = WebGUI::International->new($self->session, 'Asset_Collaboration');
    $self->getAdminConsole->addConfirmedSubmenuItem($self->getUrl('func=unarchiveAll'),$i18n->get("unarchive all"),$i18n->get("unarchive confirm"));
    return $self->getAdminConsole->render($self->getEditForm->print,$i18n->get("assetName"));
}

#-------------------------------------------------------------------

=head2 www_search ( )

The web method to display and use the forum search interface.

=cut

sub www_search {
    my $self    = shift;
    my $session = $self->session;
	my $i18n    = WebGUI::International->new($session, 'Asset_Collaboration');
    my $var     = {};
	
    my $query   = $self->session->form->process("query","text");
    $var->{'form.header'} = WebGUI::Form::formHeader($self->session,{
        action=> $self->getUrl("func=search;doit=1"),
        method=> 'GET',
    });
    $var->{'query.form'}  = WebGUI::Form::text($self->session,{
        name  => 'query',
        value => $query
    });
    $var->{'form.search'} = WebGUI::Form::submit($self->session,{
        value => $i18n->get(170,'WebGUI')
    });
    $var->{'form.footer'} = WebGUI::Form::formFooter($self->session);
    $var->{'back.url'   } = $self->getUrl;
	
    $self->appendTemplateLabels($var);
    $var->{'doit'       } = $self->session->form->process("doit");
    if ($self->session->form->process("doit")) {
        my $search = WebGUI::Search->new($self->session);
		$search->search({
            keywords=>$query,
            lineage=>[$self->get("lineage")],
            classes=>["WebGUI::Asset::Post", "WebGUI::Asset::Post::Thread"]
        });
        my $p = $search->getPaginatorResultSet($self->getUrl("func=search;doit=1;query=".$query), $self->get("threadsPerPage"));
        $self->appendPostListTemplateVars($var, $p);
    }
    return  $self->processStyle($self->processTemplate($var, $self->get("searchTemplateId")));
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

#----------------------------------------------------------------------------

=head2 www_unarchiveAll ( )

Unarchive all the threads in this collaboration system

=cut

sub www_unarchiveAll {
    my ( $self ) = @_;
    my $session     = $self->session;
    return $session->privilege->insufficient() unless $self->canEdit;
    my $pb      = WebGUI::ProgressBar->new($session);
    my $i18n     = WebGUI::International->new($session, 'Asset_Collaboration');
    $pb->start($i18n->get('unarchive all'), $self->getUrl('func=edit'));
    my $threadIds = $self->getLineage(['children'],{
        includeOnlyClasses      => [ 'WebGUI::Asset::Post::Thread' ],
        statusToInclude         => [ 'archived' ],
    } );
    ASSET: foreach my $threadId (@$threadIds) {
        my $thread = WebGUI::Asset->newPending($session, $threadId);
        if (!$thread || !$thread->canEdit) {
            next ASSET;
        }
        $thread->unarchive;
    }
    return $pb->finish( $self->getUrl('func=edit') );
}

#-------------------------------------------------------------------

=head2 www_unsubscribe (  )

The web method to unsubscribe from a collaboration.

=cut

sub www_unsubscribe {
    my $self = shift;
    if($self->canSubscribe){
        $self->unsubscribe;
        return $self->www_view;
    }else{
        return $self->session->privilege->noAccess;
    } 
}

#-------------------------------------------------------------------

=head2 www_view 

Extend the base method to handle the visitor cache timeout.

=cut

sub www_view {
	my $self = shift;
	my $disableCache = ($self->session->form->process("sortBy") ne "");
	$self->session->http->setCacheControl($self->get("visitorCacheTimeout")) if ($self->session->user->isVisitor && !$disableCache);
	return $self->next::method(@_);
}

#-------------------------------------------------------------------

=head2 www_viewRSS ( )

Deprecated. Use www_viewRss() instead.

=cut

sub www_viewRSS {
	my $self = shift;
	return $self->www_viewRss;
}

1;

