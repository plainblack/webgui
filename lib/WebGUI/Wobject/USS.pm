package WebGUI::Wobject::USS;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2004 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Tie::CPHash;
use WebGUI::Attachment;
use WebGUI::DateTime;
use WebGUI::Forum;
use WebGUI::Forum::UI;
use WebGUI::Grouping;
use WebGUI::HTML;
use WebGUI::HTMLForm;
use WebGUI::HTTP;
use WebGUI::Icon;
use WebGUI::Id;
use WebGUI::International;
use WebGUI::MessageLog;
use WebGUI::Operation;
use WebGUI::Page;
use WebGUI::Paginator;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Style;
use WebGUI::Template;
use WebGUI::URL;
use WebGUI::User;
use WebGUI::Utility;
use WebGUI::Wobject;

our @ISA = qw(WebGUI::Wobject);

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
        $_[0] =~ s/&/&amp;/g;
        $_[0] =~ s/</&lt;/g;
        $_[0] =~ s/\]\]>/\]\]&gt;/g;
        return $_[0];
}

#-------------------------------------------------------------------
sub duplicate {
	WebGUI::ErrorHandler::warn("USS wobjects cannot be duplicated until after 6.3.");
	return "";
        my %row;
	tie %row, 'Tie::CPHash';
	my $w = $_[0]->SUPER::duplicate($_[1],1);
	$w = WebGUI::Wobject::USS->new({wobjectId=>$w});
        my $sth = WebGUI::SQL->read("select * from USS_submission where USS_id=".quote($_[0]->get("USS_id")));
        while (%row = $sth->hash) {
                my $newSubmissionId = WebGUI::Id::generate();
		my $file = WebGUI::Attachment->new($row{image},$_[0]->get("wobjectId"),$row{USS_submissionId});
		$file->copy($w,$newSubmissionId);
		$file = WebGUI::Attachment->new($row{attachment},$_[0]->get("wobjectId"),$row{USS_submissionId});
		$file->copy($w,$newSubmissionId);
		$row{USS_submissionId} = $newSubmissionId;
		$w->setCollateral("USS_submission","USS_submissionId",\%row);
        }
        $sth->finish;
}

#-------------------------------------------------------------------
sub getIndexerParams {
	my $self = shift;
	my $now = shift;
	return {
		USS_discussion => {
                        sql => "select  forumPost.forumPostId,
                                        forumPost.username,
                                        forumPost.subject,
                                        forumPost.message,
                                        forumPost.userId as ownerId,
                                        forumThread.forumId as forumId,
                                        USS_submission.USS_submissionId as sid,
                                        wobject.namespace as namespace,
                                        wobject.wobjectId as wid,
                                        page.urlizedTitle as urlizedTitle,
                                        page.languageId as languageId,
                                        page.pageId as pageId,
                                        page.groupIdView as page_groupIdView,
                                        wobject.groupIdView as wobject_groupIdView,
                                        7 as wobject_special_groupIdView
                                from forumPost, forumThread, USS_submission, wobject, page, USS
                                where forumPost.forumThreadId = forumThread.forumThreadId
                                        and forumThread.forumId = USS_submission.forumId
                                       and USS_submission.USS_id = USS.USS_id
					and USS.wobjectId = wobject.wobjectId
                                        and wobject.pageId = page.pageId
                                        and wobject.startDate < $now 
                                        and wobject.endDate > $now
                                        and page.startDate < $now
                                        and page.endDate > $now",
                        fieldsToIndex => ["username", "subject", "message"],
                        contentType => 'discussion',
                        url => 'WebGUI::URL::append($data{urlizedTitle},"func=viewSubmission&wid=$data{wid}&sid=$data{sid}&forumOp=viewThread&forumPostId=$data{forumPostId}&forumId=$data{forumId}")',
                        headerShortcut => 'select subject from forumPost where forumPostId = \'$data{forumPostId}\'',
                        bodyShortcut => 'select message from forumPost where forumPostId = \'$data{forumPostId}\'',
	        	},
		USS_submission => {
                        sql => "select USS_submission.title as title,
                                        USS_submission.username as username,
                                        USS_submission.content as content,
                                        USS_submission.image as image,
                                        USS_submission.attachment as attachment,
                                        USS.wobjectId as wid,
                                        USS_submission.USS_submissionId as sid,
                                        USS_submission.userId as ownerId,
                                        wobject.namespace as namespace,
                                        page.urlizedTitle as urlizedTitle,
                                        page.languageId as languageId,
                                        page.pageId as pageId,
                                        page.groupIdView as page_groupIdView,
                                        wobject.groupIdView as wobject_groupIdView,
                                        7 as wobject_special_groupIdView
                                        from wobject, page, USS_submission, USS
                                        where USS_submission.USS_id = USS.USS_id
					and USS.wobjectId = wobject.wobjectId
                                        and wobject.pageId = page.pageId
                                        and USS_submission.status = 'Approved' 
                                        and wobject.startDate < $now 
                                        and wobject.endDate > $now
                                        and page.startDate < $now
                                        and page.endDate > $now",
                        fieldsToIndex => ["username", "title", "content", "image", "attachment"],
                        contentType => 'wobjectDetail',
                        url => 'WebGUI::URL::append($data{urlizedTitle}, "func=viewSubmission&wid=$data{wid}&sid=$data{sid}")',
                        headerShortcut => 'select title from USS_submission where USS_submissionId = \'$data{sid}\'',
                        bodyShortcut => 'select content from USS_submission where USS_submissionId = \'$data{sid}\'',
                }
	};
}

#-------------------------------------------------------------------
sub name {
        return WebGUI::International::get(29,$_[0]->get("namespace"));
}

#-------------------------------------------------------------------
sub new {
        my $class = shift;
        my $property = shift;
        my $self = WebGUI::Wobject->new(
                -properties=>$property,
		-useDiscussion=>1,
		-useMetaData=>1,
                -extendedProperties=>{
			submissionsPerPage=>{
				defaultValue=>50
				},
			groupToContribute=>{
				defaultValue=>2
				},
 			groupToApprove=>{
				defaultValue=>4
				},
 			defaultStatus=>{
				defaultValue=>"Approved"
				},
			submissionTemplateId=>{
				defaultValue=>1
				}, 
			submissionFormTemplateId=>{
				defaultValue=>1
				}, 
			karmaPerSubmission=>{
				defaultValue=>0
				},
			filterContent=>{
				defaultValue=>"javascript"
				},
			sortBy=>{
				defaultValue=>"dateUpdated"
				},
			sortOrder=>{
				defaultValue=>"desc"
				},
			USS_id=>{
				autoId=>1
				},
			submissionFormTemplateId=>{
				defaultValue=>1
				}
			},
		-useTemplate=>1
                );
        bless $self, $class;
}

#-------------------------------------------------------------------
sub purge {
	my $sth = WebGUI::SQL->read("select forumId,pageId from USS_submission where USS_id=".quote($_[0]->get("USS_id")));
	while (my ($forumId, $pageId) = $sth->array) {
		my ($inUseElsewhere) = WebGUI::SQL->quickArray("select count(*) from USS_submission where forumId=".quote($forumId));
		unless ($inUseElsewhere > 1) {
			my $forum = WebGUI::Forum->new($forumId);
			$forum->purge;
		}
		my $page  = WebGUI::Page->new($pageId);
		$page->purge;
	}
	$sth->finish;
        WebGUI::SQL->write("delete from USS_submission where USS_id=".quote($_[0]->get("USS_id")));
	$_[0]->SUPER::purge();
}

#-------------------------------------------------------------------
sub status {
        if ($_[0] eq "Approved") {
                return WebGUI::International::get(560);
        } elsif ($_[0] eq "Denied") {
                return WebGUI::International::get(561);
        } elsif ($_[0] eq "Pending") {
                return WebGUI::International::get(562);
        }
}

#-------------------------------------------------------------------
# NOTE: Not a method. Used by the page tree.
sub viewSubmissionAsPage {
	my $params = shift;
	my $properties = WebGUI::SQL->getRow("wobject","wobjectId",$params->{wobjectId});
	my $w = WebGUI::Wobject::USS->new($properties);
	return $w->www_viewSubmission($params->{submissionId});
}


#-------------------------------------------------------------------
sub www_approveSubmission {
	my (%submission);
	tie %submission, 'Tie::CPHash';
        if (WebGUI::Grouping::isInGroup(4,$session{user}{userId}) || WebGUI::Grouping::isInGroup(3,$session{user}{userId})) {
		%submission = WebGUI::SQL->quickHash("select * from USS_submission where USS_submissionId=".quote($session{form}{sid}));
                WebGUI::SQL->write("update USS_submission set status='Approved' where USS_submissionId=".quote($session{form}{sid}));
		WebGUI::MessageLog::addInternationalizedEntry($submission{userId},'',WebGUI::URL::page('func=viewSubmission&wid='.
			$session{form}{wid}.'&sid='.$session{form}{sid}),4,$_[0]->get("namespace"));
		WebGUI::MessageLog::completeEntry($session{form}{mlog});
                return WebGUI::Operation::www_viewMessageLog();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_copy {
	return "Copying of User Submission Systems has been disabled until 6.3.";
}


#-------------------------------------------------------------------
sub www_deleteFile {
	my ($owner) = WebGUI::SQL->quickArray("select userId from USS_submission where USS_submissionId=".quote($session{form}{sid}));
        if ($owner eq $session{user}{userId} || WebGUI::Grouping::isInGroup($_[0]->get("groupToApprove"))) {
		$_[0]->setCollateral("USS_submission","USS_submissionId",{
			$session{form}{file}=>'',
		 	USS_submissionId=>$session{form}{sid}
			},0,0);
                return $_[0]->www_editSubmission();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteSubmission {
	my ($owner) = WebGUI::SQL->quickArray("select userId from USS_submission where USS_submissionId=".quote($session{form}{sid}));
        if ($owner eq $session{user}{userId} || WebGUI::Grouping::isInGroup($_[0]->get("groupToApprove"))) {
		return $_[0]->confirm(WebGUI::International::get(17,$_[0]->get("namespace")),
			WebGUI::URL::page('func=deleteSubmissionConfirm&wid='.$session{form}{wid}.'&sid='.$session{form}{sid}));
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteSubmissionConfirm {
	my ($owner, $forumId, $pageId) = WebGUI::SQL->quickArray("select userId,forumId,pageId from USS_submission where USS_submissionId=".quote($session{form}{sid}));
        if ($owner eq $session{user}{userId} || WebGUI::Grouping::isInGroup($_[0]->get("groupToApprove"))) {
		my ($inUseElsewhere) = WebGUI::SQL->quickArray("select count(*) from USS_submission where forumId=".quote($forumId));
                unless ($inUseElsewhere > 1) {
			my $forum = WebGUI::Forum->new($forumId);
			$forum->purge;
		}
		my $page = WebGUI::Page->new($pageId);
		$page->purge;
		$_[0]->deleteCollateral("USS_submission","USS_submissionId",$session{form}{sid});
		my $file = WebGUI::Attachment->new("",$session{form}{wid},$session{form}{sid});
		$file->deleteNode;
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_denySubmission {
	my (%submission);
	tie %submission, 'Tie::CPHash';
        if (WebGUI::Grouping::isInGroup(4,$session{user}{userId}) || WebGUI::Grouping::isInGroup(3,$session{user}{userId})) {
		%submission = WebGUI::SQL->quickHash("select * from USS_submission where USS_submissionId=".quote($session{form}{sid}));
                WebGUI::SQL->write("update USS_submission set status='Denied' where USS_submissionId=".quote($session{form}{sid}));
                WebGUI::MessageLog::addInternationalizedEntry($submission{userId},'',WebGUI::URL::page('func=viewSubmission&wid='.
			$session{form}{wid}.'&sid='.$session{form}{sid}),5,$_[0]->get("namespace"));
                WebGUI::MessageLog::completeEntry($session{form}{mlog});
                return WebGUI::Operation::www_viewMessageLog();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_edit {
	my $layout = WebGUI::HTMLForm->new;
	my $privileges = WebGUI::HTMLForm->new;
	my $properties = WebGUI::HTMLForm->new;
        $layout->template(
                -name=>"submissionTemplateId",
                -value=>$_[0]->getValue("submissionTemplateId"),
                -namespace=>$_[0]->get("namespace")."/Submission",
                -label=>WebGUI::International::get(73,$_[0]->get("namespace")),
                -afterEdit=>'func=edit&wid='.$_[0]->get("wobjectId")
                );
        $layout->template(
                -name=>"submissionFormTemplateId",
                -value=>$_[0]->getValue("submissionFormTemplateId"),
                -namespace=>$_[0]->get("namespace")."/SubmissionForm",
                -label=>WebGUI::International::get(87,$_[0]->get("namespace")),
                -afterEdit=>'func=edit&wid='.$_[0]->get("wobjectId")
                );
        $privileges->group(
		-name=>"groupToApprove",
		-label=>WebGUI::International::get(1,$_[0]->get("namespace")),
		-value=>[$_[0]->getValue("groupToApprove")]
		);
        $privileges->group(
		-name=>"groupToContribute",
		-label=>WebGUI::International::get(2,$_[0]->get("namespace")),
		-value=>[$_[0]->getValue("groupToContribute")]
		);
        $layout->integer(
		-name=>"submissionsPerPage",
		-label=>WebGUI::International::get(6,$_[0]->get("namespace")),
		-value=>$_[0]->getValue("submissionsPerPage")
		);
        $privileges->selectList(
		-name=>"defaultStatus",
		-options=>{
			Approved=>status('Approved'),
			Denied=>status('Denied'),
			Pending=>status('Pending')
			},
		-label=>WebGUI::International::get(563),
		-value=>[$_[0]->getValue("defaultStatus")]
		);
        if ($session{setting}{useKarma}) {
                $properties->integer(
			-name=>"karmaPerSubmission",
			-label=>WebGUI::International::get(30,$_[0]->get("namespace")),
			-value=>$_[0]->getValue("karmaPerSubmission")
			);
        } else {
                $properties->hidden("karmaPerSubmission",$_[0]->getValue("karmaPerSubmission"));
        }
	$layout->filterContent(
		-value=>$_[0]->getValue("filterContent")
		);
	$layout->selectList(
		-name=>"sortBy",
		-value=>[$_[0]->getValue("sortBy")],
		-options=>{
			sequenceNumber=>WebGUI::International::get(88,$_[0]->get("namespace")),
			dateUpdated=>WebGUI::International::get(78,$_[0]->get("namespace")),
			dateSubmitted=>WebGUI::International::get(13,$_[0]->get("namespace")),
			title=>WebGUI::International::get(35,$_[0]->get("namespace"))
			},
		-label=>WebGUI::International::get(79,$_[0]->get("namespace"))
		);
	$layout->selectList(
		-name=>"sortOrder",
		-value=>[$_[0]->getValue("sortOrder")],
		-options=>{
			asc=>WebGUI::International::get(81,$_[0]->get("namespace")),
			desc=>WebGUI::International::get(82,$_[0]->get("namespace"))
			},
		-label=>WebGUI::International::get(80,$_[0]->get("namespace"))
		);
	return $_[0]->SUPER::www_edit(
		-layout=>$layout->printRowsOnly,
		-privileges=>$privileges->printRowsOnly,
		-properties=>$properties->printRowsOnly,
		-headingId=>18,
		-helpId=>"user submission system add/edit"
		);
}


#-------------------------------------------------------------------
sub www_editSubmission {
        my ($output, $submission, $f, @submission, $sth);
        $submission = $_[0]->getCollateral("USS_submission","USS_submissionId",$session{form}{sid});
	my %var;
	if ($submission->{USS_submissionId} eq "new") {
		$submission->{userId} = $session{user}{userId};
		$submission->{contentType} = "mixed";
		$var{'submission.isNew'} = 1;
	}
        return WebGUI::Privilege::insufficient() unless (WebGUI::Grouping::isInGroup($_[0]->get("groupToContribute")) 
		|| $submission->{userId} eq $session{user}{userId} 
		|| WebGUI::Grouping::isInGroup($_[0]->get("groupToApprove")));
	$var{'link.header.label'} = WebGUI::International::get(90,$_[0]->get("namespace"));
	$var{'question.header.label'} = WebGUI::International::get(84,$_[0]->get("namespace"));
        $var{'submission.header.label'} = WebGUI::International::get(19,$_[0]->get("namespace"));
	$var{'user.isVisitor'} = ($session{user}{userId} == 1);
        $var{'visitorName.label'} = WebGUI::International::get(438);
	$var{'visitorName.form'} = WebGUI::Form::text({
		name=>"visitorName"
		});
        $var{'form.header'} = WebGUI::Form::formHeader()
		.WebGUI::Form::hidden({
			name=>"wid",
			value=>$session{form}{wid}
			})
                .WebGUI::Form::hidden({
			name=>"sid",
			value=>$submission->{USS_submissionId}
			})
		.WebGUI::Form::hidden({
                	name=>"func",
			value=>"editSubmissionSave"
			});
        $var{'url.label'} = WebGUI::International::get(91,$_[0]->get("namespace"));
        $var{'newWindow.label'} = WebGUI::International::get(92,$_[0]->get("namespace"));
	$var{'userDefined1.form'} = WebGUI::Form::text({
		name=>"userDefined1",
		value=>$submission->{userDefined1}
		});
	$var{'userDefined1.form.yesNo'} = WebGUI::Form::yesNo({
		name=>"userDefined1",
		value=>$submission->{userDefined1}
		});
	$var{'userDefined1.form.textarea'} = WebGUI::Form::textarea({
		name=>"userDefined1",
		value=>$submission->{userDefined1}
		});
	$var{'userDefined2.form'} = WebGUI::Form::text({
		name=>"userDefined2",
		value=>$submission->{userDefined2}
		});
	$var{'userDefined2.form.yesNo'} = WebGUI::Form::yesNo({
		name=>"userDefined2",
		value=>$submission->{userDefined2}
		});
	$var{'userDefined2.form.textarea'} = WebGUI::Form::textarea({
		name=>"userDefined2",
		value=>$submission->{userDefined2}
		});
	$var{'userDefined3.form'} = WebGUI::Form::text({
		name=>"userDefined3",
		value=>$submission->{userDefined3}
		});
	$var{'userDefined3.form.yesNo'} = WebGUI::Form::yesNo({
		name=>"userDefined3",
		value=>$submission->{userDefined3}
		});
	$var{'userDefined3.form.textarea'} = WebGUI::Form::textarea({
		name=>"userDefined3",
		value=>$submission->{userDefined3}
		});
	$var{'userDefined4.form'} = WebGUI::Form::text({
		name=>"userDefined4",
		value=>$submission->{userDefined4}
		});
	$var{'userDefined4.form.yesNo'} = WebGUI::Form::yesNo({
		name=>"userDefined4",
		value=>$submission->{userDefined4}
		});
	$var{'userDefined4.form.textarea'} = WebGUI::Form::textarea({
		name=>"userDefined4",
		value=>$submission->{userDefined4}
		});
	$var{'userDefined5.form'} = WebGUI::Form::text({
		name=>"userDefined5",
		value=>$submission->{userDefined5}
		});
	$var{'userDefined5.form.yesNo'} = WebGUI::Form::yesNo({
		name=>"userDefined5",
		value=>$submission->{userDefined5}
		});
	$var{'userDefined5.form.textarea'} = WebGUI::Form::textarea({
		name=>"userDefined5",
		value=>$submission->{userDefined5}
		});
	$var{'userDefined1.form.htmlarea'} = WebGUI::Form::HTMLArea({
		name=>"userDefined1",
		value=>$submission->{userDefined1}
		});
	$var{'userDefined2.form.htmlarea'} = WebGUI::Form::HTMLArea({
		name=>"userDefined2",
		value=>$submission->{userDefined2}
		});
	$var{'userDefined3.form.htmlarea'} = WebGUI::Form::HTMLArea({
		name=>"userDefined3",
		value=>$submission->{userDefined3}
		});
	$var{'userDefined4.form.htmlarea'} = WebGUI::Form::HTMLArea({
		name=>"userDefined4",
		value=>$submission->{userDefined4}
		});
	$var{'userDefined5.form.htmlarea'} = WebGUI::Form::HTMLArea({
		name=>"userDefined5",
		value=>$submission->{userDefined5}
		});
	$var{'userDefined1.value'} = $submission->{userDefined1};
	$var{'userDefined2.value'} = $submission->{userDefined2};
	$var{'userDefined3.value'} = $submission->{userDefined3};
	$var{'userDefined4.value'} = $submission->{userDefined4};
	$var{'userDefined5.value'} = $submission->{userDefined5};
	$var{'question.label'} = WebGUI::International::get(85,$_[0]->get("namespace"));
	$var{'title.label'} = WebGUI::International::get(35,$_[0]->get("namespace"));
	$var{'title.form'} = WebGUI::Form::text({
		name=>"title",
		value=>$submission->{title}
		});
	$var{'title.form.textarea'} = WebGUI::Form::textarea({
		name=>"title",
		value=>$submission->{title}
		});
	$var{'title.value'} = $submission->{title};
        $var{'body.label'} = WebGUI::International::get(31,$_[0]->get("namespace"));
	$var{'answer.label'} = WebGUI::International::get(86,$_[0]->get("namespace"));
        $var{'description.label'} = WebGUI::International::get(85);
	$var{'body.value'} = $submission->{content};
	$var{'body.form'} = WebGUI::Form::HTMLArea({
		name=>"body",
		value=>$submission->{content}
		});
	$var{'body.form.textarea'} = WebGUI::Form::textarea({
		name=>"body",
		value=>$submission->{content}
		});
	$var{'image.label'} = WebGUI::International::get(32,$_[0]->get("namespace"));
        if ($submission->{image} ne "") {
		$var{'image.form'} = '<a href="'.WebGUI::URL::page('func=deleteFile&amp;file=image&amp;wid='.$session{form}{wid}
			.'&amp;sid='.$submission->{USS_submissionId}).'">'.WebGUI::International::get(391).'</a>';
        } else {
		$var{'image.form'} = WebGUI::Form::file({
			name=>"image"
			});
        }
	$var{'attachment.label'} = WebGUI::International::get(33,$_[0]->get("namespace"));
        if ($submission->{attachment} ne "") {
		$var{'attachment.form'} = '<a href="'.WebGUI::URL::page('func=deleteFile&amp;file=attachment&amp;wid='
			.$session{form}{wid}.'&amp;sid='.$submission->{USS_submissionId}).'">'.WebGUI::International::get(391).'</a>';
        } else {
		$var{'attachment.form'} = WebGUI::Form::file({
			name=>"attachment"
			});
        }
	$var{'contentType.label'} = WebGUI::International::get(1007);
        $var{'contentType.form'} = WebGUI::Form::contentType({
                name=>'contentType',
                value=>[$submission->{contentType}]
                });
	$var{'startDate.label'} = WebGUI::International::get(497);
	$var{'endDate.label'} = WebGUI::International::get(498);
	$var{'startDate.form'} = WebGUI::Form::dateTime({
		name  => 'startDate',
		value => ($submission->{startDate} || $_[0]->get("startDate"))
		});
	$var{'endDate.form'} = WebGUI::Form::dateTime({
		name  => 'endDate',
		value => ($submission->{endDate} || $_[0]->get("endDate"))
		});
	$var{'form.submit'} = WebGUI::Form::submit();
	$var{'form.footer'} = WebGUI::Form::formFooter();
	return $_[0]->processTemplate($_[0]->get("submissionFormTemplateId"),\%var,"USS/SubmissionForm");
}

#-------------------------------------------------------------------
sub www_editSubmissionSave {
	my ($submission, %hash, $file, $u);
	$submission = $_[0]->getCollateral("USS_submission","USS_submissionId",$session{form}{sid});
        if ($submission->{userId} eq $session{user}{userId} 
		|| ($submission->{USS_submissionId} eq "new" 
		&& WebGUI::Grouping::isInGroup($_[0]->get("groupToContribute"))) 
		|| WebGUI::Grouping::isInGroup($_[0]->get("groupToApprove"))) {
                if ($session{form}{sid} eq "new") {
			my $parentPage = WebGUI::Page->new($_[0]->get("pageId"));
                	my $newPage = $parentPage->add;
			$hash{pageId} = $submission->{pageId} = $newPage->get("pageId");
			my $forum = WebGUI::Forum->create({
				masterForumId=>$_[0]->get("forumId"),
				forumId=>"new"
				});
			$hash{forumId} = $forum->get("forumId");
			$hash{USS_id} = $_[0]->get("USS_id");
			$hash{username} = $session{form}{visitorName} || $session{user}{alias};
			$hash{userId} = $session{user}{userId};
			$hash{dateSubmitted} = WebGUI::DateTime::time();
			$hash{USS_submissionId} = "new";
			if ($session{setting}{useKarma}) {
                        	$u = WebGUI::User->new($session{user}{userId});
                        	$u->karma($_[0]->get("karmaPerSubmission"),$_[0]->get("namespace")." (".$_[0]->get("wobjectId")
                                	."/".$session{form}{sid}.")","User submission.");
			}
			$session{form}{sid} = $_[0]->setCollateral("USS_submission","USS_submissionId",\%hash,1,0,"USS_id",$_[0]->get("USS_id"));
        	        my %pageVars = %{$parentPage->get};
                	delete $pageVars{pageId};
	                delete $pageVars{nestedSetLeft};
        	        delete $pageVars{nestedSetRight};
               	 	delete $pageVars{depth};
                	delete $pageVars{parentId};
	                delete $pageVars{sequenceNumber};
        	        $pageVars{hideFromNavigation} = 1;
			$pageVars{isSystem} = 1;
                	$pageVars{subroutine} = "viewSubmissionAsPage";
                	$pageVars{subroutinePackage} = "WebGUI::Wobject::USS";
                	$pageVars{subroutineParams} = "{wobjectId=>'".$_[0]->wid."',submissionId=>'".$session{form}{sid}."'}";
                	$pageVars{urlizedTitle} .= "/".$_[0]->get("title")."/".$session{form}{title};
                	$pageVars{urlizedTitle} = WebGUI::Page::makeUnique(WebGUI::URL::urlize($pageVars{urlizedTitle},-999));
                	$newPage->set(\%pageVars);
			%hash = ();
                }
                $hash{title} = WebGUI::HTML::filter($session{form}{title},'all') || WebGUI::International::get(16,$_[0]->get("namespace"));
		$hash{USS_submissionId} = $session{form}{sid};
		$hash{dateUpdated} = WebGUI::DateTime::time();
		$hash{content} = $session{form}{body};
		$hash{userDefined1} = $session{form}{userDefined1};
		$hash{userDefined2} = $session{form}{userDefined2};
		$hash{userDefined3} = $session{form}{userDefined3};
		$hash{userDefined4} = $session{form}{userDefined4};
		$hash{userDefined5} = $session{form}{userDefined5};
		$hash{startDate} = WebGUI::DateTime::humanToEpoch($session{form}{startDate});
		$hash{endDate} = WebGUI::DateTime::humanToEpoch($session{form}{endDate}); 
		$hash{contentType} = $session{form}{contentType};
                $file = WebGUI::Attachment->new("",$session{form}{wid},$session{form}{sid});
		$file->save("image");
		$hash{image} = $file->getFilename if ($file->getFilename ne "");
                $file = WebGUI::Attachment->new("",$session{form}{wid},$session{form}{sid});
		$file->save("attachment");
		$hash{attachment} = $file->getFilename if ($file->getFilename ne "");
		unless ($_[0]->get("defaultStatus") eq "Approved") {
			unless (WebGUI::Grouping::isInGroup($_[0]->get("groupToApprove")) ) {
				$hash{status} = $_[0]->get("defaultStatus");
				WebGUI::MessageLog::addInternationalizedEntry('',$_[0]->get("groupToApprove"),
					WebGUI::URL::page('func=viewSubmission&wid='.$_[0]->get("wobjectId").'&sid='.
					$session{form}{sid}),3,$_[0]->get("namespace"),'pending');
			} else {
				$hash{status} = "Approved";
			}
		}
		my %pageVars;
                $pageVars{title} = $pageVars{menuTitle} = $hash{title};
		my $page = WebGUI::Page->new($submission->{pageId});
               	$page->set(\%pageVars);
		$_[0]->setCollateral("USS_submission", "USS_submissionId", \%hash, 1, 0, "USS_id", $_[0]->get("USS_id"));
                return $_[0]->www_viewSubmission();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_moveSubmissionDown {
        return WebGUI::Privilege::insufficient() unless ($_[0]->canEdit);
        $_[0]->moveCollateralDown("USS_submission","USS_submissionId",$session{form}{sid}, "USS_id", $_[0]->get("USS_id"));
        return "";
}
                                                                                                                                                             
#-------------------------------------------------------------------
sub www_moveSubmissionUp {
        return WebGUI::Privilege::insufficient() unless ($_[0]->canEdit);
        $_[0]->moveCollateralUp("USS_submission","USS_submissionId",$session{form}{sid}, "USS_id", $_[0]->get("USS_id"));
        return "";
}


#-------------------------------------------------------------------
sub www_view {
	$_[0]->logView() if ($session{setting}{passiveProfilingEnabled});
	my (%var, $row, $page, $p, $constraints, @submission, @content, $image, $i, $numResults, $thumbnail, $responses);
	$numResults = $_[0]->get("submissionsPerPage");
	$var{"readmore.label"} = WebGUI::International::get(46,$_[0]->get("namespace"));
	$var{"responses.label"} = WebGUI::International::get(57,$_[0]->get("namespace"));
	$var{canPost} = WebGUI::Grouping::isInGroup($_[0]->get("groupToContribute"));
        $var{"post.url"} = WebGUI::URL::page('func=editSubmission&sid=new&wid='.$_[0]->get("wobjectId"));
	$var{"post.label"} = WebGUI::International::get(20,$_[0]->get("namespace"));
	$var{"addquestion.label"} = WebGUI::International::get(83,$_[0]->get("namespace"));
	$var{"addlink.label"} = WebGUI::International::get(89,$_[0]->get("namespace"));
        $var{"search.label"} = WebGUI::International::get(364);
	$var{"search.Form"} = WebGUI::Search::form({wid=>$_[0]->get("wobjectId"),func=>'view',search=>1});
	$var{"search.url"} = WebGUI::Search::toggleURL("wid=".$_[0]->get("wobjectId")."&func=view");
        $var{"rss.url"} = WebGUI::URL::page('func=viewRSS&wid='.$_[0]->get("wobjectId"));
	WebGUI::Style::setLink($var{"rss.url"},{ rel=>'alternate', type=>'application/rss+xml', title=>'RSS' });
	if ($session{scratch}{search}) {
                $numResults = $session{scratch}{numResults};
       		$constraints = WebGUI::Search::buildConstraints([qw(USS_submission.username USS_submission.title USS_submission.content)]);
	}
	if ($constraints ne "") {
        	$constraints = "USS_submission.status='Approved' and ".$constraints;
	} else {
		$constraints = "(USS_submission.status='Approved' or (USS_submission.userId=".quote($session{user}{userId})." and USS_submission.userId<>1))";
	}
        $var{canModerate} = WebGUI::Grouping::isInGroup($_[0]->get("groupToApprove"),$session{user}{userId});
	$var{"title.label"} = WebGUI::International::get(99);
	$var{"thumbnail.label"} = WebGUI::International::get(52,$_[0]->get("namespace"));
	$var{"date.label"} = WebGUI::International::get(13,$_[0]->get("namespace"));
	$var{"date.updated.label"} = WebGUI::International::get(78,$_[0]->get("namespace"));
	$var{"by.label"} = WebGUI::International::get(21,$_[0]->get("namespace"));
	$var{"submission.edit.label"} = WebGUI::International::get(27,$_[0]->get("namespace"));
	$p = WebGUI::Paginator->new(WebGUI::URL::page('func=view&wid='.$_[0]->get("wobjectId")),$numResults);
	$p->setDataByQuery("select USS_submission.USS_submissionId, USS_submission.content, USS_submission.title, 
		USS_submission.userId, USS_submission.status, USS_submission.image, USS_submission.dateSubmitted, 
		USS_submission.dateUpdated, USS_submission.username, USS_submission.contentType, USS_submission.forumId, 
		USS_submission.userDefined1, USS_submission.userDefined2, USS_submission.userDefined3, 
		USS_submission.userDefined4, USS_submission.userDefined5, USS_submission.startDate, 
		USS_submission.endDate, page.urlizedTitle 
		from USS_submission left join page on USS_submission.pageId=page.pageId
		where USS_submission.USS_id=".quote($_[0]->get("USS_Id"))." 
		and $constraints order by USS_submission.".$_[0]->getValue("sortBy")." ".$_[0]->getValue("sortOrder"));
	$page = $p->getPageData;
	$i = 0;
	my $imageURL = "";
	foreach $row (@$page) {
		$page->[$i]->{content} = WebGUI::HTML::filter($page->[$i]->{content},$_[0]->get("filterContent"));
                $page->[$i]->{content} =~ s/\n/\^\-\;/ unless ($page->[$i]->{content} =~ m/\^\-\;/);
		$page->[$i]->{content} = WebGUI::HTML::format($page->[$i]->{content},$page->[$i]->{contentType});
                @content = split(/\^\-\;/,$page->[$i]->{content});
                if ($page->[$i]->{image} ne "") {
                        $image = WebGUI::Attachment->new($page->[$i]->{image},$_[0]->get("wobjectId"),$page->[$i]->{USS_submissionId});
                        $thumbnail = $image->getThumbnail;
			$imageURL = $image->getURL;
                } else {
                        $thumbnail = "";
			$imageURL = "";
                }
		($responses) = WebGUI::SQL->quickArray("select count(*) from forumPost left join forumThread on
			forumThread.forumThreadId=forumPost.forumThreadId where forumThread.forumId=".quote($row->{forumId}),WebGUI::SQL->getSlave);
		my $quickurl = 'wid='.$_[0]->get("wobjectId").'&amp;sid='.$page->[$i]->{USS_submissionId}.'&amp;func=';
		my $controls = deleteIcon($quickurl.'deleteSubmission')
			.editIcon($quickurl.'editSubmission');
		if ($_[0]->get("sortBy") eq "sequenceNumber") {
			if ($_[0]->get("sortOrder") eq "desc") {
				$controls .= moveUpIcon($quickurl.'moveSubmissionDown')
					.moveDownIcon($quickurl.'moveSubmissionUp');
			} else {
				$controls .= moveUpIcon($quickurl.'moveSubmissionUp')
					.moveDownIcon($quickurl.'moveSubmissionDown');
			}
		}
		my $inDateRange;
		if ($page->[$i]->{startDate} < WebGUI::DateTime::time() &&
		    $page->[$i]->{endDate}   > WebGUI::DateTime::time())
		{
		  $inDateRange = 1;
		}
		else { $inDateRange = 0; }
                push (@submission,{
                        "submission.id"=>$page->[$i]->{USS_submissionId},
                        "submission.url"=>WebGUI::URL::gateway($page->[$i]->{urlizedTitle}),
                        "submission.content"=>$content[0],
			"submission.content.full"=>join("\n",@content),
			"submission.responses"=>$responses,
                        "submission.title"=>$page->[$i]->{title},
                        "submission.userDefined1"=>$page->[$i]->{userDefined1},
                        "submission.userDefined2"=>$page->[$i]->{userDefined2},
                        "submission.userDefined3"=>$page->[$i]->{userDefined3},
                        "submission.userDefined4"=>$page->[$i]->{userDefined4},
                        "submission.userDefined5"=>$page->[$i]->{userDefined5},
                        "submission.userId"=>$page->[$i]->{userId},
                        "submission.username"=>$page->[$i]->{username},
                        "submission.status"=>$page->[$i]->{status},
                        "submission.thumbnail"=>$thumbnail,
                        "submission.image"=>$imageURL,
                        "submission.date"=>epochToHuman($page->[$i]->{dateSubmitted}),
                        "submission.date.updated"=>epochToHuman($page->[$i]->{dateUpdated}),
                        "submission.currentUser"=>($session{user}{userId} eq $page->[$i]->{userId} && $session{user}{userId} != 1),
                        "submission.userProfile"=>WebGUI::URL::page('op=viewProfile&uid='.$page->[$i]->{userId}),
        		"submission.edit.url"=>WebGUI::URL::page($quickurl.'editSubmission'),
                        "submission.secondColumn"=>(($i+1)%2==0),
                        "submission.thirdColumn"=>(($i+1)%3==0),
                        "submission.fourthColumn"=>(($i+1)%4==0),
                        "submission.fifthColumn"=>(($i+1)%5==0),
			'submission.controls'=>$controls,
			'submission.inDateRange'=>$inDateRange
                        });
		$i++;
	}
	$var{submissions_loop} = \@submission;
	$p->appendTemplateVars(\%var);
	return $_[0]->processTemplate($_[0]->get("templateId"),\%var);
}

#-------------------------------------------------------------------
# print out RSS 2.0 feed describing the items visible on the first page
sub www_viewRSS {
	$_[0]->logView() if ($session{setting}{passiveProfilingEnabled});        
        my $wid = $_[0]->get("wobjectId");
        my $numResults = $_[0]->get("submissionsPerPage");
        
        my $encTitle = _xml_encode($_[0]->get("title"));
        my $encDescription = _xml_encode($_[0]->get("description"));  
        my $encUrl = _xml_encode(WebGUI::URL::page("wid=$wid"));
        
        my $xml = qq~<?xml version="1.0"?>
<rss version="2.0">
<channel>
<title>$encTitle</title>
<link>$encUrl</link>
<description>$encDescription</description>
~;
        
        my $res = WebGUI::SQL->read
          ("select USS_submissionId, content, title, " .
           "dateSubmitted, username from USS_submission " .
           "where USS_id = " .quote($_[0]->get("USS_id")) . " and status='Approved' " .
           "order by ".$_[0]->getValue("sortBy")." ".$_[0]->getValue("sortOrder")." limit " . $numResults,WebGUI::SQL->getSlave);
        
        while (my $row = $res->{_sth}->fetchrow_arrayref()) {
                my ($sid, $content, $title, $dateSubmitted, $username) = 
                  @{$row};

                my $encUrl = _xml_encode
                  (WebGUI::URL::page
                   ("wid=$wid&func=viewSubmission&sid=$sid"));    
                my $encTitle = _xml_encode($title);
                my $encPubDate = _xml_encode
                  (_get_rfc822_date($dateSubmitted));
                my $encDescription = _xml_encode($content);
                
                $xml .= qq~
<item>
<title>$encTitle</title>
<link>$encUrl</link>
<description>$encDescription</description>
<guid isPermaLink="true">$encUrl</guid>
<pubDate>$encPubDate</pubDate>
</item>
~;
        }

        $xml .=qq~
</channel>
</rss>
~;
	WebGUI::HTTP::setMimeType("text/xml");
        return $xml;
}

#-------------------------------------------------------------------
sub www_viewSubmission {
	my $self = shift;
	my $submissionId = shift || $session{form}{sid};
	$self->logView() if ($session{setting}{passiveProfilingEnabled});
	return "" unless ($submissionId);
	my ($file, @data, %var, $replies);
	my $submission = $self->getCollateral("USS_submission","USS_submissionId",$submissionId);
	return "" unless ($submission->{USS_submissionId});
        return "" unless ($submission->{status} eq 'Approved' ||
                ($submission->{userId} eq $session{user}{userId} && $session{user}{userId} != 1) ||
                WebGUI::Grouping::isInGroup($self->getValue("groupToApprove")));
	my $parentsPage = WebGUI::Page->new($self->get("pageId"));
	my $callback = WebGUI::URL::gateway($parentsPage->get("urlizedTitle"),"func=viewSubmission&amp;wid=".$self->wid."&amp;sid=".$submission->{USS_submissionId});
	if ($session{form}{forumOp} ne "" && $session{form}{forumOp} ne "viewForum") {	
		return WebGUI::Forum::UI::forumOp({
			callback=>$callback,
			title=>$submission->{title},
			forumId=>$submission->{forumId}
			});
	}
	WebGUI::SQL->write("update USS_submission set views=views+1 where USS_submissionId=".quote($submissionId));
	$var{title} = $submission->{title};
	$var{content} = WebGUI::HTML::filter($submission->{content},$self->get("filterContent"));
	$var{content} =~ s/\^\-\;//g;
	$var{content} = WebGUI::HTML::format($var{content},$submission->{contentType});
        $var{"user.label"} = WebGUI::International::get(21,$self->get("namespace"));
	$var{"user.Profile"} = WebGUI::URL::page('op=viewProfile&uid='.$submission->{userId});
	$var{"user.Id"} = $submission->{userId};
	$var{"user.username"} = $submission->{username};
	$var{"date.label"} = WebGUI::International::get(13,$self->get("namespace"));
	$var{"date.epoch"} = $submission->{dateSubmitted};
	$var{"date.human"} = epochToHuman($submission->{dateSubmitted});
	$var{"date.updated.label"} = WebGUI::International::get(78,$self->get("namespace"));
	$var{"date.updated.human"} = epochToHuman($submission->{dateUpdated});
	$var{"date.updated.epoch"} = $submission->{dateUpdated};
	$var{"status.label"} = WebGUI::International::get(14,$self->get("namespace"));
	$var{"status.status"} = status($submission->{status});
	$var{"views.label"} = WebGUI::International::get(514);
	$var{"views.count"} = $submission->{views};
        $var{canPost} = WebGUI::Grouping::isInGroup($self->get("groupToContribute"));
        $var{"post.url"} = WebGUI::URL::gateway($parentsPage->get("urlizedTitle"),'func=editSubmission&sid=new&wid='.$self->wid);
        $var{"post.label"} = WebGUI::International::get(20,$self->get("namespace"));
	@data = WebGUI::SQL->quickArray("select USS_submissionId from USS_submission 
        	where USS_id=".quote($self->get("USS_id"))." and dateSubmitted<".quote($submission->{dateSubmitted})."
		and (userId=".quote($submission->{userId})." or status='Approved') order by dateSubmitted desc",WebGUI::SQL->getSlave);
        $var{"previous.more"} = ($data[0] ne "");
	if ($var{"previous.more"}) {
		my $previousSubmission = $self->getCollateral("USS_submission","USS_submissionId",$data[0]);
		my $previousPage = WebGUI::Page->new($previousSubmission->{pageId});
       		$var{"previous.url"} = WebGUI::URL::gateway($previousPage->get("urlizedTitle"));
	}
	$var{"previous.label"} = WebGUI::International::get(58,$self->get("namespace"));
        @data = WebGUI::SQL->quickArray("select USS_submissionId from USS_submission 
                where USS_id=".quote($submission->{USS_id})." and dateSubmitted>".quote($submission->{dateSubmitted})."
		and (userId=".quote($submission->{userId})." or status='Approved') order by dateSubmitted asc",WebGUI::SQL->getSlave);
        $var{"next.more"} = ($data[0] ne "");
	if ($var{"next.more"}) {
		my $nextSubmission = $self->getCollateral("USS_submission","USS_submissionId",$data[0]);
		my $nextPage = WebGUI::Page->new($nextSubmission->{pageId});
	        $var{"next.url"} = WebGUI::URL::gateway($nextPage->get("urlizedTitle"));
	}
	$var{"next.label"} = WebGUI::International::get(59,$self->get("namespace"));
        $var{canEdit} = (($submission->{userId} eq $session{user}{userId} || WebGUI::Grouping::isInGroup($self->get("groupToApprove"))) && $session{user}{userId} != 1);
        $var{"delete.url"} = WebGUI::URL::gateway($parentsPage->get("urlizedTitle"),'func=deleteSubmission&wid='.$self->wid.'&sid='.$submissionId);
	$var{"delete.label"} = WebGUI::International::get(37,$self->get("namespace"));
        $var{"edit.url"} = WebGUI::URL::gateway($parentsPage->get("urlizedTitle"),'func=editSubmission&wid='.$self->wid.'&sid='.$submissionId);
	$var{"edit.label"} = WebGUI::International::get(27,$self->get("namespace"));
        $var{canChangeStatus} = WebGUI::Grouping::isInGroup($self->get("groupToApprove"),$session{user}{userId});
        $var{"approve.url"} = WebGUI::URL::gateway($parentsPage->get("urlizedTitle"),'func=approveSubmission&wid='.$self->wid.'&sid='.$submissionId.'&mlog='.$session{form}{mlog});
	$var{"approve.label"} = WebGUI::International::get(572);
        $var{"leave.url"} = WebGUI::URL::page('op=viewMessageLog');
	$var{"leave.label"} = WebGUI::International::get(573);
        $var{"deny.url"} = WebGUI::URL::gateway($parentsPage->get("urlizedTitle"),'func=denySubmission&wid='.$self->wid.'&sid='.$submissionId.'&mlog='.$session{form}{mlog});
	$var{"deny.label"} = WebGUI::International::get(574);
	$var{"canReply"} = ($self->get("allowDiscussion"));
	$var{"reply.url"} = WebGUI::Forum::UI::formatNewThreadURL($callback,$submission->{forumId});
	$var{"reply.label"} = WebGUI::International::get(47,$self->get("namespace"));
	$var{"search.url"} = WebGUI::Search::toggleURL("",$parentsPage->get("urlizedTitle"));
	$var{"search.label"} = WebGUI::International::get(364);
        $var{"back.url"} = WebGUI::URL::gateway($parentsPage->get("urlizedTitle"));
	$var{"back.label"} = WebGUI::International::get(28,$self->get("namespace"));
	$var{'userDefined1.value'} = $submission->{userDefined1};
	$var{'userDefined2.value'} = $submission->{userDefined2};
	$var{'userDefined3.value'} = $submission->{userDefined3};
	$var{'userDefined4.value'} = $submission->{userDefined4};
	$var{'userDefined5.value'} = $submission->{userDefined5};
	if ($submission->{image} ne "") {
		$file = WebGUI::Attachment->new($submission->{image},$self->wid,$submissionId);
		$var{"image.url"} = $file->getURL;
		$var{"image.thumbnail"} = $file->getThumbnail;
	}
	if ($submission->{attachment} ne "") {
		$file = WebGUI::Attachment->new($submission->{attachment},$self->wid,$submissionId);
		$var{"attachment.box"} = $file->box;
		$var{"attachment.url"} = $file->getURL;
		$var{"attachment.icon"} = $file->getIcon;
		$var{"attachment.name"} = $file->getFilename;
        }	
	if ($self->get("allowDiscussion")) {
		$var{"replies"} = WebGUI::Forum::UI::www_viewForum(
			{callback=>$callback,title=>$submission->{title},forumId=>$submission->{forumId}},
			$submission->{forumId});
	}
	return $self->processTemplate($self->get("submissionTemplateId"),\%var,"USS/Submission");
}



1;

