package WebGUI::Wobject::USS;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2003 Plain Black LLC.
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
use WebGUI::HTML;
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::MessageLog;
use WebGUI::Operation;
use WebGUI::Paginator;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::Template;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::User;
use WebGUI::Utility;
use WebGUI::Wobject;

our @ISA = qw(WebGUI::Wobject);

# format the date according to rfc 822 (for RSS export)
my @_months = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
sub _get_rfc822_date {
        my ($time) = @_;
        
        my ($year, $mon, $mday, $hour, $min, $sec) = WebGUI::DateTime::localtime($time);
        
        my $month = $_months[$mon - 1];
        
        return sprintf("%02d %s %04d %02d:%02d:%02d GMT", 
                       $mday, $month, $year, $hour, $min, $sec);
}
  
# encode a string to include in xml (for RSS export)
sub _xml_encode {
        
        $_[0] =~ s/&/&amp;/g;
        $_[0] =~ s/</&lt;/g;
        $_[0] =~ s/\]\]>/\]\]&gt;/g;
        
        return $_[0];
}

#-------------------------------------------------------------------
sub duplicate {
        my ($sth, $file, %row, $newSubmissionId, $w);
	tie %row, 'Tie::CPHash';
	$w = $_[0]->SUPER::duplicate($_[1],1);
	my $props = WebGUI::SQL->quickHashRef("select * from wobject where wobjectId=$w");
	my $newWobject = WebGUI::Wobject::USS->new($props);
        $sth = WebGUI::SQL->read("select * from USS_submission where USS_id=".$_[0]->get("USS_id"));
        while (%row = $sth->hash) {
                $newSubmissionId = getNextId("USS_submissionId");
		$file = WebGUI::Attachment->new($row{image},$_[0]->get("wobjectId"),$row{USS_submissionId});
		$file->copy($w,$newSubmissionId);
		$file = WebGUI::Attachment->new($row{attachment},$_[0]->get("wobjectId"),$row{USS_submissionId});
		$file->copy($w,$newSubmissionId);
                WebGUI::SQL->write("insert into USS_submission (USS_submissionId, title, dateSubmitted, username, userId, content,
			image, attachment, status, views, forumId, dateUpdated, sequenceNumber, USS_id, contentType) values ($newSubmissionId, ".
			quote($row{title}).", $row{dateSubmitted}, ".quote($row{username}).", $row{userId}, ".quote($row{content}).", ".
			quote($row{image}).", ".quote($row{attachment}).", '$row{status}', $row{views}, $row{forumId}, $row{dateUpdated},
			$row{sequenceNumber}, ".$newWobject->get("USS_id").", ".quote($row{contentType}).")");
        }
        $sth->finish;
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
				autoIncrement=>1
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
	my $sth = WebGUI::SQL->read("select forumId from USS_submission where USS_id=".$_[0]->get("USS_id"));
	while (my ($forumId) = $sth->array) {
		my ($inUseElsewhere) = WebGUI::SQL->quickArray("select count(*) from USS_submission where forumId=".$forumId);
		unless ($inUseElsewhere > 1) {
			my $forum = WebGUI::Forum->new($forumId);
			$forum->purge;
		}
	}
	$sth->finish;
        WebGUI::SQL->write("delete from USS_submission where USS_id=".$_[0]->get("USS_id"));
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
sub www_approveSubmission {
	my (%submission);
	tie %submission, 'Tie::CPHash';
        if (WebGUI::Privilege::isInGroup(4,$session{user}{userId}) || WebGUI::Privilege::isInGroup(3,$session{user}{userId})) {
		%submission = WebGUI::SQL->quickHash("select * from USS_submission where USS_submissionId=$session{form}{sid}");
                WebGUI::SQL->write("update USS_submission set status='Approved' where USS_submissionId=$session{form}{sid}");
		WebGUI::MessageLog::addInternationalizedEntry($submission{userId},'',WebGUI::URL::page('func=viewSubmission&wid='.
			$session{form}{wid}.'&sid='.$session{form}{sid}),4,$_[0]->get("namespace"));
		WebGUI::MessageLog::completeEntry($session{form}{mlog});
                return WebGUI::Operation::www_viewMessageLog();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteFile {
	my ($owner) = WebGUI::SQL->quickArray("select userId from USS_submission where USS_submissionId=$session{form}{sid}");
        if ($owner == $session{user}{userId} || WebGUI::Privilege::isInGroup($_[0]->get("groupToApprove"))) {
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
	my ($owner) = WebGUI::SQL->quickArray("select userId from USS_submission where USS_submissionId=$session{form}{sid}");
        if ($owner == $session{user}{userId} || WebGUI::Privilege::isInGroup($_[0]->get("groupToApprove"))) {
		return $_[0]->confirm(WebGUI::International::get(17,$_[0]->get("namespace")),
			WebGUI::URL::page('func=deleteSubmissionConfirm&wid='.$session{form}{wid}.'&sid='.$session{form}{sid}));
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteSubmissionConfirm {
	my ($owner, $forumId) = WebGUI::SQL->quickArray("select userId,forumId from USS_submission where USS_submissionId=$session{form}{sid}");
        if ($owner == $session{user}{userId} || WebGUI::Privilege::isInGroup($_[0]->get("groupToApprove"))) {
		my ($inUseElsewhere) = WebGUI::SQL->quickArray("select count(*) from USS_submission where forumId=".$forumId);
                unless ($inUseElsewhere > 1) {
			my $forum = WebGUI::Forum->new($forumId);
			$forum->purge;
		}
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
        if (WebGUI::Privilege::isInGroup(4,$session{user}{userId}) || WebGUI::Privilege::isInGroup(3,$session{user}{userId})) {
		%submission = WebGUI::SQL->quickHash("select * from USS_submission where USS_submissionId=$session{form}{sid}");
                WebGUI::SQL->write("update USS_submission set status='Denied' where USS_submissionId=$session{form}{sid}");
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
		-helpId=>1
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
        return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::isInGroup($_[0]->get("groupToContribute")) 
		|| $submission->{userId} == $session{user}{userId} 
		|| WebGUI::Privilege::isInGroup($_[0]->get("groupToApprove")));
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
	$var{'form.submit'} = WebGUI::Form::submit();
	$var{'form.footer'} = '</form>';
	return WebGUI::Template::process(WebGUI::Template::get($_[0]->get("submissionFormTemplateId"),"USS/SubmissionForm"), \%var);
}

#-------------------------------------------------------------------
sub www_editSubmissionSave {
	my ($submission, %hash, $file, $u);
	$submission = $_[0]->getCollateral("USS_submission","USS_submissionId",$session{form}{sid});
        if ($submission->{userId} == $session{user}{userId} 
		|| ($submission->{USS_submissionId} eq "new" 
		&& WebGUI::Privilege::isInGroup($_[0]->get("groupToContribute"))) 
		|| WebGUI::Privilege::isInGroup($_[0]->get("groupToApprove"))) {
                if ($session{form}{sid} eq "new") {
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
		$hash{contentType} = $session{form}{contentType};
                $file = WebGUI::Attachment->new("",$session{form}{wid},$session{form}{sid});
		$file->save("image");
		$hash{image} = $file->getFilename if ($file->getFilename ne "");
                $file = WebGUI::Attachment->new("",$session{form}{wid},$session{form}{sid});
		$file->save("attachment");
		$hash{attachment} = $file->getFilename if ($file->getFilename ne "");
		unless ($_[0]->get("defaultStatus") eq "Approved") {
			unless (WebGUI::Privilege::isInGroup($_[0]->get("groupToApprove")) ) {
				$hash{status} = $_[0]->get("defaultStatus");
				WebGUI::MessageLog::addInternationalizedEntry('',$_[0]->get("groupToApprove"),
					WebGUI::URL::page('func=viewSubmission&wid='.$_[0]->get("wobjectId").'&sid='.
					$session{form}{sid}),3,$_[0]->get("namespace"),'pending');
			} else {
				$hash{status} = "Approved";
			}
		}
		$_[0]->setCollateral("USS_submission", "USS_submissionId", \%hash, 1, 0, "USS_id", $_[0]->get("USS_id"));
                return $_[0]->www_viewSubmission();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_moveSubmissionDown {
        return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
        $_[0]->moveCollateralDown("USS_submission","USS_submissionId",$session{form}{sid}, "USS_id", $_[0]->get("USS_id"));
        return "";
}
                                                                                                                                                             
#-------------------------------------------------------------------
sub www_moveSubmissionUp {
        return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
        $_[0]->moveCollateralUp("USS_submission","USS_submissionId",$session{form}{sid}, "USS_id", $_[0]->get("USS_id"));
        return "";
}


#-------------------------------------------------------------------
sub www_view {
	my (%var, $row, $page, $p, $constraints, @submission, @content, $image, $i, $numResults, $thumbnail, $responses);
	$numResults = $_[0]->get("submissionsPerPage");
	$var{"readmore.label"} = WebGUI::International::get(46,$_[0]->get("namespace"));
	$var{"responses.label"} = WebGUI::International::get(57,$_[0]->get("namespace"));
	$var{canPost} = WebGUI::Privilege::isInGroup($_[0]->get("groupToContribute"));
        $var{"post.url"} = WebGUI::URL::page('func=editSubmission&sid=new&wid='.$_[0]->get("wobjectId"));
	$var{"post.label"} = WebGUI::International::get(20,$_[0]->get("namespace"));
	$var{"addquestion.label"} = WebGUI::International::get(83,$_[0]->get("namespace"));
	$var{"addlink.label"} = WebGUI::International::get(89,$_[0]->get("namespace"));
        $var{"search.label"} = WebGUI::International::get(364);
	$var{"search.Form"} = WebGUI::Search::form({wid=>$_[0]->get("wobjectId"),func=>'view',search=>1});
	$var{"search.url"} = WebGUI::Search::toggleURL("wid=".$_[0]->get("wobjectId")."&func=view");
        $var{"rss.url"} = WebGUI::URL::page('func=viewRSS&wid='.$_[0]->get("wobjectId"));
	if ($session{scratch}{search}) {
                $numResults = $session{scratch}{numResults};
       		$constraints = WebGUI::Search::buildConstraints([qw(username title content)]);
	}
	if ($constraints ne "") {
        	$constraints = "status='Approved' and ".$constraints;
	} else {
		$constraints = "(status='Approved' or (userId=$session{user}{userId} and userId<>1))";
	}
        $var{canModerate} = WebGUI::Privilege::isInGroup($_[0]->get("groupToApprove"),$session{user}{userId});
	$var{"title.label"} = WebGUI::International::get(99);
	$var{"thumbnail.label"} = WebGUI::International::get(52,$_[0]->get("namespace"));
	$var{"date.label"} = WebGUI::International::get(13,$_[0]->get("namespace"));
	$var{"date.updated.label"} = WebGUI::International::get(78,$_[0]->get("namespace"));
	$var{"by.label"} = WebGUI::International::get(21,$_[0]->get("namespace"));
	$var{"submission.edit.label"} = WebGUI::International::get(27,$_[0]->get("namespace"));
	$p = WebGUI::Paginator->new(WebGUI::URL::page('func=view&wid='.$_[0]->get("wobjectId")),[],$numResults);
	$p->setDataByQuery("select USS_submissionId, content, title, userId, status, image, dateSubmitted, dateUpdated, 
		username, contentType, forumId, userDefined1, userDefined2, userDefined3, userDefined4, userDefined5 from USS_submission 
		where USS_id=".$_[0]->get("USS_Id")." and $constraints order by ".$_[0]->getValue("sortBy")." ".$_[0]->getValue("sortOrder"));
	$page = $p->getPageData;
	$i = 0;
	my $imageURL;
	foreach $row (@$page) {
		$page->[$i]->{content} = WebGUI::HTML::filter($page->[$i]->{content},$_[0]->get("filterContent"));
		$page->[$i]->{content} = WebGUI::HTML::format($page->[$i]->{content},$page->[$i]->{contentType});
                $page->[$i]->{content} =~ s/\n/\^\-\;/ unless ($page->[$i]->{content} =~ m/\^\-\;/);
                @content = split(/\^\-\;/,$page->[$i]->{content});
                if ($page->[$i]->{image} ne "") {
                        $image = WebGUI::Attachment->new($page->[$i]->{image},$_[0]->get("wobjectId"),$page->[$i]->{USS_submissionId});
                        $thumbnail = $image->getThumbnail;
			$imageURL = $image->getURL;
                } else {
                        $thumbnail = "";
			$imageURL;
                }
		($responses) = WebGUI::SQL->quickArray("select count(*) from forumPost left join forumThread on
			forumThread.forumThreadId=forumPost.forumThreadId where forumThread.forumId=".$row->{forumId});
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
                push (@submission,{
                        "submission.id"=>$page->[$i]->{USS_submissionId},
                        "submission.url"=>WebGUI::URL::page($quickurl.'viewSubmission'),
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
                        "submission.currentUser"=>($session{user}{userId} == $page->[$i]->{userId}),
                        "submission.userProfile"=>WebGUI::URL::page('op=viewProfile&uid='.$page->[$i]->{userId}),
        		"submission.edit.url"=>WebGUI::URL::page($quickurl.'editSubmission'),
                        "submission.secondColumn"=>(($i+1)%2==0),
                        "submission.thirdColumn"=>(($i+1)%3==0),
                        "submission.fourthColumn"=>(($i+1)%4==0),
                        "submission.fifthColumn"=>(($i+1)%5==0),
			'submission.controls'=>$controls
                        });
		$i++;
	}
	$var{submissions_loop} = \@submission;
	$var{firstPage} = $p->getFirstPageLink;
	$var{lastPage} = $p->getLastPageLink;
	$var{nextPage} = $p->getNextPageLink;
	$var{pageList} = $p->getPageLinks;
	$var{previousPage} = $p->getPreviousPageLink;
	$var{multiplePages} = ($p->getNumberOfPages > 1);
	return $_[0]->processTemplate($_[0]->get("templateId"),\%var);
}

#-------------------------------------------------------------------
# print out RSS 2.0 feed describing the items visible on the first page
sub www_viewRSS {
        
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
           "where USS_id = " .$session{dbh}->quote($_[0]->get("USS_id")) . " " .
           "order by ".$_[0]->getValue("sortBy")." ".$_[0]->getValue("sortOrder")." limit " . $numResults);
        
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

        $session{header}{mimetype} = 'text/xml';
        
        return $xml;
}

#-------------------------------------------------------------------
sub www_viewSubmission {
	return "" unless ($session{form}{sid});
	my ($file, @data, %var, $replies);
	my $submission = $_[0]->getCollateral("USS_submission","USS_submissionId",$session{form}{sid});
	return $_[0]->www_view unless ($submission->{USS_submissionId});
	my $callback = WebGUI::URL::page("func=viewSubmission&amp;wid=".$_[0]->get("wobjectId")."&amp;sid=".$submission->{USS_submissionId});
	if ($session{form}{forumOp}) {	
		return WebGUI::Forum::UI::forumOp({
			callback=>$callback,
			title=>$submission->{title},
			forumId=>$submission->{forumId}
			});
	}
	WebGUI::SQL->write("update USS_submission set views=views+1 where USS_submissionId=$session{form}{sid}");
	$var{title} = $submission->{title};
	$var{content} = WebGUI::HTML::filter($submission->{content},$_[0]->get("filterContent"));
	$var{content} =~ s/\^\-\;//g;
	$var{content} =~ WebGUI::HTML::format($submission->{content},$submission->{contentType});
        $var{"user.label"} = WebGUI::International::get(21,$_[0]->get("namespace"));
	$var{"user.Profile"} = WebGUI::URL::page('op=viewProfile&uid='.$submission->{userId});
	$var{"user.Id"} = $submission->{userId};
	$var{"user.username"} = $submission->{username};
	$var{"date.label"} = WebGUI::International::get(13,$_[0]->get("namespace"));
	$var{"date.epoch"} = $submission->{dateSubmitted};
	$var{"date.human"} = epochToHuman($submission->{dateSubmitted});
	$var{"date.updated.label"} = WebGUI::International::get(78,$_[0]->get("namespace"));
	$var{"date.updated.human"} = epochToHuman($submission->{dateUpdated});
	$var{"date.updated.epoch"} = $submission->{dateUpdated};
	$var{"status.label"} = WebGUI::International::get(14,$_[0]->get("namespace"));
	$var{"status.status"} = status($submission->{status});
	$var{"views.label"} = WebGUI::International::get(514);
	$var{"views.count"} = $submission->{views};
        $var{canPost} = WebGUI::Privilege::isInGroup($_[0]->get("groupToContribute"));
        $var{"post.url"} = WebGUI::URL::page('func=editSubmission&sid=new&wid='.$_[0]->get("wobjectId"));
        $var{"post.label"} = WebGUI::International::get(20,$_[0]->get("namespace"));
	@data = WebGUI::SQL->quickArray("select max(USS_submissionId) from USS_submission 
        	where USS_id=".$_[0]->get("USS_id")." and USS_submissionId<$submission->{USS_submissionId}
		and (userId=$submission->{userId} or status='Approved')");
        $var{"previous.more"} = ($data[0] ne "");
       	$var{"previous.url"} = WebGUI::URL::page('func=viewSubmission&sid='.$data[0].'&wid='.$session{form}{wid});
	$var{"previous.label"} = WebGUI::International::get(58,$_[0]->get("namespace"));
        @data = WebGUI::SQL->quickArray("select min(USS_submissionId) from USS_submission 
                where USS_id=$submission->{USS_id} and USS_submissionId>$submission->{USS_submissionId}
		and (userId=$submission->{userId} or status='Approved')");
        $var{"next.more"} = ($data[0] ne "");
        $var{"next.url"} = WebGUI::URL::page('func=viewSubmission&sid='.$data[0].'&wid='.$session{form}{wid});
	$var{"next.label"} = WebGUI::International::get(59,$_[0]->get("namespace"));
        $var{canEdit} = ($submission->{userId} == $session{user}{userId} || WebGUI::Privilege::isInGroup($_[0]->get("groupToApprove")));
        $var{"delete.url"} = WebGUI::URL::page('func=deleteSubmission&wid='.$session{form}{wid}.'&sid='.$session{form}{sid});
	$var{"delete.label"} = WebGUI::International::get(37,$_[0]->get("namespace"));
        $var{"edit.url"} = WebGUI::URL::page('func=editSubmission&wid='.$session{form}{wid}.'&sid='.$session{form}{sid});
	$var{"edit.label"} = WebGUI::International::get(27,$_[0]->get("namespace"));
        $var{canChangeStatus} = WebGUI::Privilege::isInGroup($_[0]->get("groupToApprove"),$session{user}{userId});
        $var{"approve.url"} = WebGUI::URL::page('func=approveSubmission&wid='.$session{form}{wid}.'&sid='.$session{form}{sid}.'&mlog='.$session{form}{mlog});
	$var{"approve.label"} = WebGUI::International::get(572);
        $var{"leave.url"} = WebGUI::URL::page('op=viewMessageLog');
	$var{"leave.label"} = WebGUI::International::get(573);
        $var{"deny.url"} = WebGUI::URL::page('func=denySubmission&wid='.$session{form}{wid}.'&sid='.$session{form}{sid}.'&mlog='.$session{form}{mlog});
	$var{"deny.label"} = WebGUI::International::get(574);
	$var{"canReply"} = ($_[0]->get("allowDiscussion"));
	$var{"reply.url"} = WebGUI::Forum::UI::formatNewThreadURL($callback,$submission->{forumId});
	$var{"reply.label"} = WebGUI::International::get(47,$_[0]->get("namespace"));
	$var{"search.url"} = WebGUI::Search::toggleURL();
	$var{"search.label"} = WebGUI::International::get(364);
        $var{"back.url"} = WebGUI::URL::page();
	$var{"back.label"} = WebGUI::International::get(28,$_[0]->get("namespace"));
	$var{'userDefined1.value'} = $submission->{userDefined1};
	$var{'userDefined2.value'} = $submission->{userDefined2};
	$var{'userDefined3.value'} = $submission->{userDefined3};
	$var{'userDefined4.value'} = $submission->{userDefined4};
	$var{'userDefined5.value'} = $submission->{userDefined5};
	if ($submission->{image} ne "") {
		$file = WebGUI::Attachment->new($submission->{image},$session{form}{wid},$session{form}{sid});
		$var{"image.url"} = $file->getURL;
		$var{"image.thumbnail"} = $file->getThumbnail;
	}
	if ($submission->{attachment} ne "") {
		$file = WebGUI::Attachment->new($submission->{attachment},$session{form}{wid},$session{form}{sid});
		$var{"attachment.box"} = $file->box;
		$var{"attachment.url"} = $file->getURL;
		$var{"attachment.icon"} = $file->getIcon;
		$var{"attachment.name"} = $file->getFilename;
        }	
	if ($_[0]->get("allowDiscussion")) {
		$var{"replies"} = WebGUI::Forum::UI::www_viewForum(
			{callback=>$callback,title=>$submission->{title},forumId=>$submission->{forumId}},
			$submission->{forumId});
	}
	return WebGUI::Template::process(WebGUI::Template::get($_[0]->get("submissionTemplateId"),"USS/Submission"), \%var);
}



1;

