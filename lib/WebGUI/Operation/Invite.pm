package WebGUI::Operation::Invite;

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
use WebGUI::Session;
use WebGUI::User;
use WebGUI::Form;
use WebGUI::Mail::Send;
use WebGUI::Operation::Auth;

=head1 NAME

Package WebGUI::Operation::Invite

=head1 DESCRIPTION

Operation handler for handling user invitations.

=cut

#-------------------------------------------------------------------

=head2 www_inviteUser ( )

Form for inviting a user.

=cut

sub www_inviteUser {
	my $session = shift;
	return $session->privilege->insufficient() unless ($session->user->isInGroup(2));
    my $formError = shift;
    my $vars = {};
	my $i18n = WebGUI::International->new($session, 'Invite');
    $vars->{inviteFormError} = $i18n->get($formError);
    $vars->{formHeader} = WebGUI::Form::formHeader($session).WebGUI::Form::hidden($session, {name => "op", value => "inviteUserSave"});
    $vars->{formFooter} = WebGUI::Form::formFooter($session, {});
    $vars->{title}             = $i18n->get('invite a friend title');
    $vars->{emailAddressLabel} = $i18n->get('480', 'WebGUI');
    $vars->{emailAddressForm}  = WebGUI::Form::email(
                                      $session,
                                      {
                                          name  => "invite_email",
                                          value => $session->form->get('invite_email'),
                                      },
                                 );
    $vars->{subjectLabel}      = $i18n->get('229', 'WebGUI');
    $vars->{subjectForm}       = WebGUI::Form::text(
                                      $session,
                                      {
                                          name  => "invite_subject",
                                          value => $session->form->get('invite_subject'),
                                      },
                                 );
    $vars->{messageLabel}      = $i18n->get('351', 'WebGUI');
    $vars->{messageForm}       = WebGUI::Form::textarea(
                                      $session,
                                      {
                                          name  => "invite_message",
                                          value => $session->form->get('invite_message') || $i18n->get('default invite'),
                                      },
                                 );
    $vars->{submitButton}      = WebGUI::Form::submit(
                                      $session,
                                      {value => $i18n->get('submit', 'WebGUI')},
                                 );
    my $output = WebGUI::Asset::Template->new($session,"PBtmpl00000userInvite1")->process($vars);
   	return $session->style->userStyle($output);
}

#-------------------------------------------------------------------

=head2 www_inviteUserSave ( )

Post process the form, check for required fields, handle inviting users who are already
members (determined by email address) and send the email.

=cut

sub www_inviteUserSave {
	my $session = shift;
	return $session->privilege->insufficient() unless ($session->user->isInGroup(2));

    #Mandatory field checks
    my $hisEmailAddress = $session->form->get('invite_email');
    return www_inviteUser($session, 'missing email') unless $hisEmailAddress;
    my $message = $session->form->get('invite_message');
    return www_inviteUser($session, 'missing message') unless $message;
    my $subject = $session->form->get('invite_subject');
    return www_inviteUser($session, 'missing subject') unless $subject;

    my $i18n = WebGUI::International->new($session, 'Invite');

    #User existance check.
    my $existingUser = WebGUI::User->newByEmail($session, $hisEmailAddress);
    use Data::Dumper;
    if (defined $existingUser) {
        my $output = sprintf qq!<h1>%s</h1>\n<p>%s</p><a href="%s">%s</a>!,
            $i18n->get('already a member'),
            $session->setting->get('userInvitationsEmailExists'),
            $session->url->getBackToSiteURL(),
            $i18n->get('493', 'WebGUI');
        return $session->style->userStyle($output);
    }
    my $myEmailAddress = $session->user->profileField('email');
    my $invitation = WebGUI::Mail::Send->create(
        $session,
        {
            to      => $hisEmailAddress,
            from    => $myEmailAddress,
            subject => $subject,
        },
    );

    ##No sneaky attack paths...
    $message = WebGUI::HTML::filter($message);

    ##Append the invitation url.
    my $inviteId = $session->id->generate();
    my $inviteUrl = $session->url->append($session->url->getSiteURL, 'op=acceptInvite;code='.$inviteId);
    $message .= "\n$inviteUrl\n";

    ##Create the invitation record.
    $session->db->setRow(
        'userInvitations',
        'inviteId',
        {
            userId   => $session->user->userId,
            dateSent => WebGUI::DateTime->new($session, time)->toMysqlDate,
            email    => $hisEmailAddress,
        },
        $inviteId,
    );

    $invitation->addText($message);
    $invitation->send;

    my $output = sprintf qq!<p>%s</p><a href="%s">%s</a>!,
        $i18n->get('invitation sent'),
        $session->url->getBackToSiteURL(),
        $i18n->get('493', 'WebGUI');
    return $session->style->userStyle($output);

}

#-------------------------------------------------------------------

=head2 www_acceptInvite ( )

Validate the invitation code.  If valid, send the user over to the
create account page.  Otherwise, scourge and flay them.

=cut

sub www_acceptInvite {
	my $session = shift;
	return $session->privilege->insufficient() if ($session->user->isInGroup(2));

    my $i18n = WebGUI::International->new($session, 'Invite');

    my $inviteId = $session->form->get('code');
    my ($validInviteId) = $session->db->quickArray('select userId from userInvitations where inviteId=?',[$inviteId]);

    if (!$validInviteId) {
        my $output = sprintf qq!<h1>%s</h1>\n<p>%s</p><a href="%s">%s</a>!,
            $i18n->get('invalid invite code'),
            $i18n->get('invalid invite code message'),
            $session->url->getBackToSiteURL(),
            $i18n->get('493', 'WebGUI');
        return $session->style->userStyle($output);
    }
    ##Everything looks good.  Sign them up!
    my $auth = WebGUI::Operation::Auth::getInstance($session);
    return $session->style->userStyle($auth->createAccount());
}

1;
