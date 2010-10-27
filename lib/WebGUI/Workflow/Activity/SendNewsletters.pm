package WebGUI::Workflow::Activity::SendNewsletters; 


=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
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
use WebGUI::Mail::Send;

=head1 NAME

Package WebGUI::Workflow::Activity::SendNewsletters

=head1 DESCRIPTION

Process subscription requests from all Newsletters and send emails.

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
	my $i18n = WebGUI::International->new($session, "Asset_Newsletter");
	push(@{$definition}, {
		name=>$i18n->get("send activity name"),
		properties=> { }
		});
	return $class->SUPER::definition($session,$definition);
}


#-------------------------------------------------------------------

=head2 execute ( )

See WebGUI::Workflow::Activity::execute() for details.

=cut

sub execute {
	my $self = shift;
    my ($db,$log) = $self->session->quick(qw(db log));
    
    my $time = time();
    my $newsletter = undef;

    $log->info("Getting subscriptions");
    my $subscriptionResultSet = $db->read("select assetId, userId, subscriptions, lastTimeSent
        from Newsletter_subscriptions where lastTimeSent < unix_timestamp() - 60*60*23
        order by assetId, userId"); # only sending to people who haven't been sent to in the past 23 hours
    while (my ($assetId, $userId, $subscriptions, $lastTimeSent) = $subscriptionResultSet->array) {
       
        # get user object
        $log->info("Getting user $userId");
        my $user = WebGUI::User->new($self->session, $userId);
        next if ($user->isVisitor);
        my $emailAddress = $user->get("email");
        next if ($emailAddress eq "");


        # get newsletter asset
        unless (defined $newsletter && $newsletter->getId eq $assetId) { # cache newsletter object
            $log->info("Getting newsletter asset $assetId");
            $newsletter = WebGUI::Asset->newById($self->session, $assetId);
        }

        # find matching threads
        my @threads = ();
        my %foundThreads;
        $log->info("Find threads in $assetId matching $userId subscriptions.");
        foreach my $subscription (split("\n", $subscriptions)) {
            $log->info("Found subscription $subscription");
            my ($fieldId, $value) = split("~", $subscription);
            $log->info("Searching for threads that match $subscription");
            my $matchingThreads = $db->read("select metaData_values.assetId from metaData_values
                left join asset using (assetId) where fieldId=? and value like ? and creationDate > ?
                and className like ?  and lineage like ? and state = ?", 
                [$fieldId, '%'.$value.'%', $lastTimeSent, 'WebGUI::Asset::Post::Thread%', $newsletter->get("lineage").'%', 'published']); 
            while (my ($threadId) = $matchingThreads->array) {
                next
                    if $foundThreads{$threadId};
                my $thread = eval { WebGUI::Asset->newById($self->session, $threadId); };
                if (! Exception::Class->caught()) {
                    $log->info("Found thread $threadId");
                    push(@threads, $thread);
                    $foundThreads{$threadId} = 1;
                }
                else {
                    $log->error("Couldn't instanciate thread $threadId: $@");
                }    
            }
        }
        unless (scalar(@threads)) { # don't send a message if there aren't matching threads
            $log->info("No threads found matching $userId subscriptions.");
            next;
        }

        # build newsletter
        $log->info("Building newsletter for $userId.");
	    my $siteurl = $self->session->url->getSiteURL();
        my @threadLoop = ();
        foreach my $thread (@threads) {
            push(@threadLoop, {
                title       => $thread->getTitle,
                synopsis    => $thread->get("synopsis"),
                body        => $thread->get("content"),
                url         => $siteurl.$thread->getUrl,
                });
        }
        my %var = (
            title       => $newsletter->getTitle,
            description => $newsletter->get("description"),
            header      => $newsletter->get("newsletterHeader"),
            footer      => $newsletter->get("newsletterFooter"),
            thread_loop => \@threadLoop,
            );
        my $template = WebGUI::Asset->newById($self->session, $newsletter->get("newsletterTemplateId"));
        my $content = $template->process(\%var);
        
        # send newsletter
        $log->info("Sending newsletter for $userId.");
	    my $setting = $self->session->setting;
	    my $returnAddress = $setting->get("mailReturnPath");
	    my $companyAddress = $setting->get("companyEmail");
	    my $listAddress = $newsletter->get("mailAddress");
	    my $from = $listAddress || $companyAddress;
	    my $replyTo = $listAddress || $returnAddress || $companyAddress;
	    my $sender = $listAddress || $companyAddress;
	    my $returnPath = $returnAddress || $sender;
	    my $listId = $sender;
	    $listId =~ s/\@/\./;
	    my $domain = $newsletter->get("mailAddress");
	    $domain =~ s/.*\@(.*)/$1/;
	    my $messageId = "cs-".$self->getId.'@'.$domain;
	    my $subject = $newsletter->get("mailPrefix").$newsletter->getTitle;
		my $mail = WebGUI::Mail::Send->create($self->session, {
            to          => "<".$emailAddress.">",
			from        => "<".$from.">",
			returnPath  => "<".$returnPath.">",
			replyTo     => "<".$replyTo.">",
			subject     => $subject,
			messageId   => '<'.$messageId.'>'
			});
		$mail->addHeaderField("List-ID", $newsletter->getTitle." <".$listId.">");
		$mail->addHeaderField("List-Help", "<mailto:".$companyAddress.">, <".$setting->get("companyURL").">");
		$mail->addHeaderField("List-Unsubscribe", "<".$siteurl.$newsletter->getUrl("func=mySubscriptions").">");
		$mail->addHeaderField("List-Owner", "<mailto:".$companyAddress.">, <".$setting->get("companyURL")."> (".$setting->get("companyName").")");
		$mail->addHeaderField("Sender", "<".$sender.">");
		if ($listAddress eq "") {
			$mail->addHeaderField("List-Post", "No");
		} else {
			$mail->addHeaderField("List-Post", "<mailto:".$listAddress.">");
		}
		$mail->addHeaderField("List-Archive", "<".$siteurl.$newsletter->getUrl.">");
		$mail->addHeaderField("X-Unsubscribe-Web", "<".$siteurl.$newsletter->getUrl("func=mySubscriptions").">");
		$mail->addHeaderField("X-Archives", "<".$siteurl.$newsletter->getUrl.">");
		$mail->addHtml($content);
		$mail->queue;

        # mark sent
        $log->info("Email sent.");
        $db->write("update Newsletter_subscriptions set lastTimeSent = ?", [time()]);

        # timeout if we're taking too long
        if (time() - $time > $self->getTTL ) {
            $log->info("Oops. Ran out of time. Will continue building newsletters in a bit.");
            $subscriptionResultSet->finish;
            return $self->WAITING(1);
        }
    }
	return $self->COMPLETE;
}



1;


