package WebGUI::Workflow::Activity::GetSyndicatedContent;


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
use WebGUI::Asset::Wobject::SyndicatedContent;
use JSON;

=head1 NAME

Package WebGUI::Workflow::Activity::GetSyndicatedContent;

=head1 DESCRIPTION

Prefetches syndicated content URLs so that the pages can be served up more quickly.

=head1 SYNOPSIS

See WebGUI::Workflow::Activity for details on how to use any activity.

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 definition ( session, definition )

See WebGUI::Workflow::Activity::defintion() for details.

=cut 

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift;
	my $i18n = WebGUI::International->new($session, "Asset_SyndicatedContent");
	push(@{$definition}, {
		name=>$i18n->get("get syndicated content"),
		properties=> { }
		});
	return $class->SUPER::definition($session,$definition);
}


#-------------------------------------------------------------------

=head2 execute (  )

See WebGUI::Workflow::Activity::execute() for details.

=cut

sub execute {
    my $self = shift;
    my $object = shift;
    my $instance = shift;
    unless (defined $instance) {
        $self->session->errorHandler->error("Could not instanciate Workflow Instance in GetSyndicatedContent Activity");
        return $self->ERROR;
    }

    # start time to check for timeouts
    my $time = time();

    my @syndicatedUrls = @{$self->getSyndicatedUrls($instance)};
    while (my $url = shift(@syndicatedUrls)) {
        # Get RSS data, which will be stored in the cache
        $self->session->errorHandler->info("GetSyndicatedContent workflow: Caching $url");
        my $returnValue = WebGUI::Asset::Wobject::SyndicatedContent::_get_rss_data($self->session, $url);
        if (!defined $returnValue) {
            $self->session->errorHandler->warn("GetSyndicatedContent Workflow Activity: _get_rss_data returned undef while trying to process syndicated content url $url, which usually indicates an improper URL, or a malformed document");
            next;
        }
        # Check for timeout
        last
            if (time() - $time > 55);
    }

    # if there are urls left, we need to process again
    if (scalar(@syndicatedUrls) > 0) {
        $instance->setScratch("syndicatedUrls", JSON::encode_json(\@syndicatedUrls));
        return $self->WAITING;
    }
    $instance->deleteScratch("syndicatedUrls");
    return $self->COMPLETE;
}

#---------------------------------------------------------------------

=head2 getWobjectUrls ( )

Returns URLs from all of the Syndicated Content Wobjects from scratch or fetches them from the db if needed

=head3 session

A reference to the current webgui session

=cut

sub getSyndicatedUrls {
    my $self = shift;
    my $instance = shift;
    my $syndicatedUrls = $instance->getScratch("syndicatedUrls");
    if ($syndicatedUrls) {
        return JSON::decode_json($syndicatedUrls);
    }

    my $urls = [];
    my $assets = WebGUI::Asset->getRoot($self->session)->getLineage(['descendants'], {
        includeOnlyClasses => ['WebGUI::Asset::Wobject::SyndicatedContent'],
        returnObjects   => 1,
    });
    foreach my $asset (@$assets) {
        push @$urls, split(/\s+/, $asset->getRssUrl);
    }
    $instance->setScratch("syndicatedUrls", JSON::encode_json($urls));
    return $urls;
}


1;


