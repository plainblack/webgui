package WebGUI::Asset::Wobject::USS;

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
sub definition {
	my $class = shift;
        my $definition = shift;
        push(@{$definition}, {
                tableName=>'USS',
                className=>'WebGUI::Asset::Wobject::USS',
                properties=>{
			templateId =>{
				fieldType=>"template",
				defaultValue=>'PBtmpl0000000000000066'
				},
			submissionsPerPage=>{
				fieldType=>"integer",
				defaultValue=>50
				},
			groupToContribute=>{
				fieldType=>"group",
				defaultValue=>2
				},
 			groupToApprove=>{
				fieldType=>"group",
				defaultValue=>4
				},
 			defaultStatus=>{
				fieldType=>"selectList",
				defaultValue=>"Approved"
				},
			submissionTemplateId=>{
				fieldType=>"template",
				defaultValue=>undef
				}, 
			submissionFormTemplateId=>{
				fieldType=>"template",
				defaultValue=>undef
				}, 
			karmaPerSubmission=>{
				fieldType=>"integer",
				defaultValue=>0
				},
			filterContent=>{
				fieldType=>"filterContent",
				defaultValue=>"javascript"
				},
			sortBy=>{
				fieldType=>"selectList",
				defaultValue=>"dateUpdated"
				},
			sortOrder=>{
				fieldType=>"selectList",
				defaultValue=>"desc"
				},
			USS_id=>{
				fieldType=>"hidden",
				autoId=>1
				},
			submissionFormTemplateId=>{
				fieldType=>"template",
				defaultValue=>undef
				}
			}
		});
        return $class->SUPER::definition($definition);
}

#-------------------------------------------------------------------
sub getEditForm {
	my $self = shift;
	my $tabform = $self->SUPER::getEditForm;
   	$tabform->getTab("display")->template(
      		-value=>$self->getValue('templateId'),
      		-namespace=>"USS"
   		);
        $tabform->getTab("display")->template(
                -name=>"submissionTemplateId",
                -value=>$self->getValue("submissionTemplateId"),
                -namespace=>"USS"."/Submission",
                -label=>WebGUI::International::get(73,"USS"),
                -afterEdit=>'func=edit&wid='.$self->get("wobjectId")
                );
        $tabform->getTab("display")->template(
                -name=>"submissionFormTemplateId",
                -value=>$self->getValue("submissionFormTemplateId"),
                -namespace=>"USS"."/SubmissionForm",
                -label=>WebGUI::International::get(87,"USS"),
                -afterEdit=>'func=edit&wid='.$self->get("wobjectId")
                );
        $tabform->getTab("security")->group(
		-name=>"groupToApprove",
		-label=>WebGUI::International::get(1,"USS"),
		-value=>[$self->getValue("groupToApprove")]
		);
        $tabform->getTab("security")->group(
		-name=>"groupToContribute",
		-label=>WebGUI::International::get(2,"USS"),
		-value=>[$self->getValue("groupToContribute")]
		);
        $tabform->getTab("display")->integer(
		-name=>"submissionsPerPage",
		-label=>WebGUI::International::get(6,"USS"),
		-value=>$self->getValue("submissionsPerPage")
		);
        $tabform->getTab("security")->selectList(
		-name=>"defaultStatus",
		-options=>{
			Approved=>$self->status('Approved'),
			Denied=>$self->status('Denied'),
			Pending=>$self->status('Pending')
			},
		-label=>WebGUI::International::get(563),
		-value=>[$self->getValue("defaultStatus")]
		);
        if ($session{setting}{useKarma}) {
                $tabform->getTab("properties")->integer(
			-name=>"karmaPerSubmission",
			-label=>WebGUI::International::get(30,"USS"),
			-value=>$self->getValue("karmaPerSubmission")
			);
        } else {
                $tabform->getTab("properties")->hidden("karmaPerSubmission",$self->getValue("karmaPerSubmission"));
        }
	$tabform->getTab("display")->filterContent(
		-value=>$self->getValue("filterContent")
		);
	$tabform->getTab("display")->selectList(
		-name=>"sortBy",
		-value=>[$self->getValue("sortBy")],
		-options=>{
			lineage=>WebGUI::International::get(88,"USS"),
			dateUpdated=>WebGUI::International::get(78,"USS"),
			dateSubmitted=>WebGUI::International::get(13,"USS"),
			title=>WebGUI::International::get(35,"USS")
			},
		-label=>WebGUI::International::get(79,"USS")
		);
	$tabform->getTab("display")->selectList(
		-name=>"sortOrder",
		-value=>[$self->getValue("sortOrder")],
		-options=>{
			asc=>WebGUI::International::get(81,"USS"),
			desc=>WebGUI::International::get(82,"USS")
			},
		-label=>WebGUI::International::get(80,"USS")
		);
	return $tabform;
}

#-------------------------------------------------------------------
sub getIcon {
	my $self = shift;
	my $small = shift;
	return $session{config}{extrasURL}.'/assets/small/userSubmissionSystem.gif' if ($small);
	return $session{config}{extrasURL}.'/assets/userSubmissionSystem.gif';
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
sub getName {
        return WebGUI::International::get(29,"USS");
}


#-------------------------------------------------------------------
sub status {
	my $self = shift;
	my $status = shift;
        if ($status eq "Approved") {
                return WebGUI::International::get(560);
        } elsif ($status eq "Denied") {
                return WebGUI::International::get(561);
        } elsif ($status eq "Pending") {
                return WebGUI::International::get(562);
        }
}

#-------------------------------------------------------------------
sub view {
	my $self = shift;
	my $numResults = $self->get("submissionsPerPage");
	my %var;
	$var{"readmore.label"} = WebGUI::International::get(46,"USS");
	$var{"responses.label"} = WebGUI::International::get(57,"USS");
	$var{canPost} = WebGUI::Grouping::isInGroup($self->get("groupToContribute"));
        $var{"post.url"} = $self->getUrl('func=add&class=WebGUI::Asset::USS_submission');
	$var{"post.label"} = WebGUI::International::get(20,"USS");
	$var{"addquestion.label"} = WebGUI::International::get(83,"USS");
	$var{"addlink.label"} = WebGUI::International::get(89,"USS");
        $var{"search.label"} = WebGUI::International::get(364);
	$var{"search.Form"} = WebGUI::Search::form({func=>'view',search=>1});
	$var{"search.url"} = WebGUI::Search::toggleURL("func=view");
        $var{"rss.url"} = WebGUI::URL::page('func=viewRSS',1);
        $var{canModerate} = WebGUI::Grouping::isInGroup($self->get("groupToApprove"),$session{user}{userId});
	$var{"title.label"} = WebGUI::International::get(99);
	$var{"thumbnail.label"} = WebGUI::International::get(52,"USS");
	$var{"date.label"} = WebGUI::International::get(13,"USS");
	$var{"date.updated.label"} = WebGUI::International::get(78,"USS");
	$var{"by.label"} = WebGUI::International::get(21,"USS");
	$var{"submission.edit.label"} = WebGUI::International::get(27,"USS");
	WebGUI::Style::setLink($var{"rss.url"},{ rel=>'alternate', type=>'application/rss+xml', title=>'RSS' });
	my $constraints;
	if ($session{scratch}{search}) {
                $numResults = $session{scratch}{numResults};
       		$constraints = WebGUI::Search::buildConstraints([qw(USS_submission.username asset.synopsis asset.title USS_submission.content USS_submission.userDefined1 USS_submission.userDefined2 USS_submission.userDefined3 USS_submission.userDefined4 USS_submission.userDefined5)]);
	}
	if ($constraints ne "") {
        	$constraints = "USS_submission.status='Approved' and ".$constraints;
	} else {
		$constraints = "(USS_submission.status='Approved' or (USS_submission.userId=".quote($session{user}{userId})." and USS_submission.userId<>'1')";
		if ($var{canModerate}) {
			$constraints .= " or USS_submission.status='Pending'"; 
		}
		$constraints .= ")";
	}
	my $p = WebGUI::Paginator->new($self->getUrl,$numResults);
	my $sql = "select * from USS_submission left join asset on USS_submission.assetId=asset.assetId 
		where asset.parentId=".quote($self->getId)." and asset.state='published' and asset.className='WebGUI::Asset::USS_submission' and $constraints 
		order by ".$self->getValue("sortBy")." ".$self->getValue("sortOrder");
	$p->setDataByQuery($sql);
	my $page = $p->getPageData;
	my $i = 0;
	my $imageURL = "";
	foreach my $row (@$page) {
		my $submission = WebGUI::Asset::USS_submission->newByPropertyHashRef($row);
		my $body = WebGUI::HTML::filter($submission->get("content"),$self->get("filterContent"));
		$body = WebGUI::HTML::format($body,$submission->get("contentType"));
		my $controls = deleteIcon('func=delete',$submission->getUrl,WebGUI::International::get(17,"USS")).editIcon('func=edit',$submission->getUrl);
		if ($self->get("sortBy") eq "lineage") {
			if ($self->get("sortOrder") eq "desc") {
				$controls .= moveUpIcon('func=demote',$submission->getUrl).moveDownIcon('func=promote',$submission->getUrl);
			} else {
				$controls .= moveUpIcon('func=promote',$submission->getUrl).moveDownIcon('func=demote',$submission->getUrl);
			}
		}
		my $inDateRange;
		if ($submission->get("startDate") < WebGUI::DateTime::time() && $submission->get("endDate") > WebGUI::DateTime::time()) {
		  	$inDateRange = 1;
		} else { 
			$inDateRange = 0; 
		}
                push(@{$var{submissions_loop}}, {
                        "submission.id"=>$submission->getId,
                        "submission.url"=>$submission->getUrl,
                        "submission.content"=>$submission->get("synopsis"),
			"submission.content.full"=>$submission->get("content"),
			"submission.responses"=>$submission->getResponseCount,
                        "submission.title"=>$submission->get("title"),
                        "submission.userDefined1"=>$submission->get("userDefined1"),
                        "submission.userDefined2"=>$submission->get("userDefined2"),
                        "submission.userDefined3"=>$submission->get("userDefined3"),
                        "submission.userDefined4"=>$submission->get("userDefined4"),
                        "submission.userDefined5"=>$submission->get("userDefined5"),
                        "submission.userId"=>$submission->get("userId"),
                        "submission.username"=>$submission->get('username'),
                        "submission.status"=>$self->status($submission->get("status")),
                        "submission.thumbnail"=>$submission->getThumbnailUrl,
                        "submission.image"=>$submission->getImageUrl,
                        "submission.date"=>epochToHuman($submission->get("dateSubmitted")),
                        "submission.date.updated"=>epochToHuman($submission->get("dateUpdated")),
                        "submission.userProfile"=>WebGUI::URL::page('op=viewProfile&uid='.$submission->get("userId")),
        		"submission.edit.url"=>$submission->getUrl("func=edit"),
                        "submission.secondColumn"=>(($i+1)%2==0),
                        "submission.thirdColumn"=>(($i+1)%3==0),
                        "submission.fourthColumn"=>(($i+1)%4==0),
                        "submission.fifthColumn"=>(($i+1)%5==0),
			'submission.controls'=>$submission->getToolbar,
			'submission.inDateRange'=>$inDateRange,
                	"submission.currentUser"=>($session{user}{userId} eq $submission->get("userId") && $session{user}{userId} ne "1")
                        });
		$i++;
	}
	$p->appendTemplateVars(\%var);
	return $self->processTemplate(\%var,$self->get("templateId"));
}

#-------------------------------------------------------------------
sub www_edit {
        my $self = shift;
	return $self->getAdminConsole->render(WebGUI::Privilege::insufficient()) unless $self->canEdit;
	$self->getAdminConsole->setHelp("user submission system add/edit");
        return $self->getAdminConsole->render($self->getEditForm->print,WebGUI::International::get("18","USS"));
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



1;

