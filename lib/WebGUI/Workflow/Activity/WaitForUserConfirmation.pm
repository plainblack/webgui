package WebGUI::Workflow::Activity::WaitForUserConfirmation;

use warnings;
use strict;

use base 'WebGUI::Workflow::Activity';
use WebGUI::Asset::Template;
use WebGUI::International;
use WebGUI::Inbox::Message;
use WebGUI::Macro;
use Kwargs;
use Tie::IxHash;

#-----------------------------------------------------------------

=head2 confirm ( $instance, $token )

Returns true (and sets the workflow as done) if the token matches the one we
generated for the email.

=cut

sub confirm {
    my ($self, $instance, $token) = @_;
    my $id = $self->getId;
    return 0 unless $token eq $instance->getScratch("$id-token");
    $instance->setScratch("$id-status", 'done');
    return 1;
}

#-----------------------------------------------------------------

=head2 definition ( )

See WebGUI::Workflow::Activity::definition for details.

=cut

sub definition {
    my ($class, $session, $def) = @_;
    my $i18n = WebGUI::International->new(
        $session, 'Activity_WaitForUserConfirmation'
    );

    tie my %props, 'Tie::IxHash', (
        emailFrom => {
            fieldType    => 'user',
            defaultValue => 3,
        },
        emailSubject => {
            fieldType    => 'text',
            defaultValue => 'Confirmation Email',
        },
        template => {
            fieldType => 'textarea',
            defaultValue => $i18n->get('your template goes here'),
        },
        templateParser => {
            fieldType    => 'templateParser',
            defaultValue => $session->config->get('defaultTemplateParser'),
        },
        okMessage => {
            fieldType => 'HTMLArea',
        },
        waitBetween => {
            fieldType    => 'interval',
            defaultValue => 60*5
        },
        expireAfter => {
            fieldType    => 'interval',
            defaultValue => 60*60*24*7,
        },
        doOnExpire => {
            fieldType => 'workflow',
            type      => 'WebGUI::User',
            none      => 1,
        }
    );

    for my $key (keys %props) {
        $props{$key}{label} = $i18n->get("$key label");
        $props{$key}{hoverHelp} = $i18n->get("$key hoverHelp");
    }

    push @$def, {
        name       => $i18n->get('topicName'),
        properties => \%props,
    };

    return $class->SUPER::definition( $session, $def );
}

#-----------------------------------------------------------------

=head2 execute ( )

See WebGUI::Workflow::Activity::execute for details.

=cut

sub execute {
    my ($self, $object, $instance) = @_;
    my $id      = $self->getId;
    my $statk   = "$id-status";
    my $start   = "$id-started";
    my $status  = $instance->getScratch($statk);
    my $subject = $self->get('emailSubject');
    my $parser  = $self->get('templateParser');
    WebGUI::Macro::process(\$subject);
    my $body    = WebGUI::Asset::Template->processRaw(
        $self->session,
        $self->get('template'),
        $self->getTemplateVariables($object, $instance),
        $parser,
    );
    WebGUI::Macro::process(\$body);
    unless ($status) {
        $instance->setScratch($start => $self->now);
        $self->sendEmail(
            from    => $self->get('emailFrom'),
            to      => $object->userId,
            subject => $subject,
            body    => $body,
        );
        $instance->setScratch($statk => 'waiting');
        return $self->wait;
    }
    return $self->COMPLETE if $status eq 'done' || $status eq 'expired';
    if ($status eq 'waiting') {
        my $end = $instance->getScratch($start) + $self->get('expireAfter');
        if ($self->now > $end) {
            $self->expire($instance);
            $instance->setScratch($statk => 'expired');
            return $self->COMPLETE;
        }
        return $self->wait;
    }
    $self->session->log->error("Unknown status: $status");
    return $self->ERROR;
}

#-----------------------------------------------------------------

=head2 expire ( $instance )

Deletes the workflow instance and kicks off a configured workflow if there is
one.

=cut

sub expire {
    my ($self, $instance) = @_;
    if (my $id = $self->get('doOnExpire')) {
        $self->changeWorkflow($id, $instance);
    }
    else {
        $instance->delete();
    }
}

#-----------------------------------------------------------------

=head2 getTemplateVariables ( $object, $instance )

Returns the variables to be used in rendering the email template.

=cut

sub getTemplateVariables {
    my ($self, $object, $instance) = @_;

    my $user = $object->get;

    # Kill all humans. I means references. Currently there seems to be a bug
    # in _rewriteVars in some of the template plugins that disallows us from
    # using arrayrefs with just strings in them, which is a common occurrence
    # in profile fields. When that bug gets fixed, we can (and should) take
    # this out.
    delete @{$user}{grep {ref $user->{$_} } keys %$user};

    return {
        user => $user,
        link => $self->link($instance),
    }
}

#-----------------------------------------------------------------

=head2 link ( $instance )

Returns the URL that needs to be visited by the user.

=cut

sub link {
    my ($self, $instance) = @_;
    my $url   = $self->session->url;
    my $aid   = $self->getId;
    my $iid   = $instance->getId;
    my $token = $instance->getScratch("$aid-token");
    $instance->setScratch("$aid-token", $token = $self->token) unless $token;
    my $path  = $url->page(
        "op=confirmUserEmail;instanceId=$iid;token=$token;activityId=$aid"
    );
    return $url->getSiteURL . $url->gateway($path);
}

#-----------------------------------------------------------------

=head2 now ( )

Just returns the current time, nice for testing.

=cut

sub now { time }

#-----------------------------------------------------------------

=head2 sendEmail ( { from, to, subject, body } )

Takes a user to send email from, to, with a subject and a body all as
keywords. Mostly here for testing, it just calls
WebGUI::Inbox::Message->create() with proper arguments. 'from' and 'to' are
userIds, not user objects.

=cut

sub sendEmail {
    my ($self, $from, $to, $subject, $body) = kwn @_, 1,
        qw(from to subject body);

    WebGUI::Inbox::Message->create(
        $self->session, {
            message => $body,
            subject => $subject,
            status  => 'pending',
            userId  => $to,
            sentBy  => $from,
        }
    );
}

#-----------------------------------------------------------------

=head2 token ( )

Returns a random string to use as a token in the confirmation link

=cut

sub token {
    my $self = shift;
    $self->session->id->generate;
}

#-----------------------------------------------------------------

=head2 wait ( )

Waits for the configured waitBetween interval.

=cut

sub wait {
    my $self = shift;
    return $self->WAITING($self->get('waitBetween'));
}

1;
