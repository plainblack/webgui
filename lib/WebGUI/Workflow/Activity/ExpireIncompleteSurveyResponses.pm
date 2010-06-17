package WebGUI::Workflow::Activity::ExpireIncompleteSurveyResponses;


=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2008 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use base 'WebGUI::Workflow::Activity';
use WebGUI::Asset;
use WebGUI::DateTime;
use DateTime::Duration;
use WebGUI::Mail::Send;

=head1 NAME

Package WebGUI::Workflow::Activity::ExpireIncompleteSurveyResponses

=head1 DESCRIPTION

This activity deletes the survey responses for which the allowed time has expired and emails the survey user.

=head1 SYNOPSIS

See WebGUI::Workflow::Activity for details on how to use any activity.

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 definition ( session, definition )

See WebGUI::Workflow::Activity::definition() for details.

=cut 

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift;
	my $i18n = WebGUI::International->new($session, "Workflow_Activity_ExpireIncompleteSurveyResponses");
	push(@{$definition}, {
		name        =>  $i18n->get("name"),
		properties  => {
            deleteExpired=>{
                fieldType=>"yesNo",
                defaultValue=>0,
                label=>$i18n->get("Delete expired survey responses"),
                hoverHelp=>$i18n->get("delete expired")
                },
            emailUsers=>{
                fieldType=>"yesNo",
                defaultValue=>0,
                label=>$i18n->get("Email users that responses were deleted"),
                hoverHelp=>$i18n->get("email users")
                },
            emailTemplateId => {
                fieldType => "template",
                defaultValue => 'ExpireIncResptmpl00001',
                namespace => "ExpireIncompleteSurveyResponses",
                label => $i18n->get('Email template sent to user'),
                hoverHelp => $i18n->get('email template'),
                },
            from => {
                fieldType=>"text",
                label=>$i18n->get("from"),
                defaultValue=>$session->setting->get("companyEmail"),
                hoverHelp=>$i18n->get("from mouse over"),
                },
            subject => {
                fieldType=>"text",
                label=>$i18n->get("subject"),
                defaultValue=>"Expired Survey",
                hoverHelp=>$i18n->get("subject mouse over"),
                },
			}
		});
	return $class->SUPER::definition($session,$definition);
}


#-------------------------------------------------------------------

=head2 execute ( [ object ] )

Finds all the expired Survey Responses on the system.  If delete is selected, they are removed.  Then if
email is selected, the users are emailed the template. 

=cut

sub execute {
	my $self = shift;
    my $session = $self->session;

    my $refs = $self->session->db->buildArrayRefOfHashRefs( $self->getSql );
    for my $ref (@{$refs}) {
        if($self->get("deleteExpired")){
            $session->log->debug("deleting response: $ref->{Survey_responseId} ");
            $self->session->db->write("delete from Survey_response where Survey_responseId = ?",[$ref->{Survey_responseId}]);
        }else{
            # Mark response as expired (with appropriate completeCode)
            my $completeCode = $ref->{doAfterTimeLimit} eq 'restartSurvey' ? 4 : 3;
            $self->session->db->write("update Survey_response set isComplete = ?, endDate = ? where Survey_responseId = ?",
                [$completeCode, scalar time, $ref->{Survey_responseId}]
            );
        }
        if($self->get("emailUsers") == 1 && $ref->{email} =~ /\@/){
            my $var = { 
                    to  =>  $ref->{email},
                    from => $self->get("from"),
                    firstName => $ref->{firstName},
                    lastName => $ref->{lastName},
                    surveyTitle => $ref->{title},
                    surveyUrl => $ref->{url},
                    responseId => $ref->{Survey_responseId},
                    deleted => $self->get("deleteExpired"),
                    companyName => $self->session->setting->get("companyName"),
                    username => $ref->{username},
                    userId => $ref->{userId},
                };
            my $template = WebGUI::Asset->newByDynamicClass($self->session,$self->get('emailTemplateId')); 
            my $message = $template->processTemplate($var, $self->get("emailTemplateId"));
            WebGUI::Macro::process($self->session,\$message);
            my $mail = WebGUI::Mail::Send->create($self->session,{
                to      => $ref->{email},
                subject => $self->get("subject"),
                from    => $self->get('from'),
            });
            $mail->addHtml($message);
            $mail->addFooter;
            $mail->queue;
        }
    }
	return $self->COMPLETE;
}

=head2 getSql

Returns the SQL used to look up incomplete survey responses.

Factored out into a separate subroutine for the sake of testability.

=cut

sub getSql {

    return <<END_SQL;
select  
    r.Survey_responseId, r.username, r.userId, r.startDate, 
    upd.email, upd.firstName, upd.lastName, 
    s.timeLimit, s.doAfterTimeLimit, 
    ad.title, ad.url  
from 
    Survey_response r, Survey s, assetData ad, userProfileData upd
where 
    r.isComplete = 0 
    and s.timeLimit > 0 
    and ( unix_timestamp() - r.startDate ) > ( s.timeLimit * 60 ) 
    and r.assetId = s.assetId 
    and ad.assetId = s.assetId 
    and ad.revisionDate = s.revisionDate 
    and s.revisionDate = r.revisionDate
    and upd.userId = r.userId
END_SQL

}

1;