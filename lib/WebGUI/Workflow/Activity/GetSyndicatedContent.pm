package WebGUI::Workflow::Activity::GetSyndicatedContent;


=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2006 Plain Black Corporation.
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

	my @syndicatedUrls = @{$self->getSyndicatedUrls($instance)};
	my @arrayCopy = @syndicatedUrls;	# copy we can delete elements from inside the foreach loop
	my $time = time();

    	foreach my $urls (@syndicatedUrls) {
        	#Loop through the SyndicatedWobjects and split all the URLs they are syndicating off into
        	#a separate array.
        	my @urlsToSyndicate = split(/\s+/,$urls);

        	foreach my $url (@urlsToSyndicate) {
			# We could timeout in here but I don't see a good way to handle that right now
			# May need to fix this in the future.
            		my $returnValue = WebGUI::Asset::Wobject::SyndicatedContent::_get_rss_data($self->session, $url);
			unless (defined $returnValue) {
				$self->session->errorHandler->error("GetSyndicatedContent Workflow Activity: _get_rss_data returned undef while trying to process syndicated content url $url, which usually indicates an improper URL, or a malformed document");
				next;
			}
        	}
		
		# Delete this element from the array
		splice(@arrayCopy,0,1);

		# Check for timeout
		last unless (time() - $time <= 60);
    	}

	# See if we're done
	if (scalar(@arrayCopy) > 0) {
		$instance->setScratch("syndicatedUrls", objToJson(@arrayCopy));
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
	
	unless ($syndicatedUrls) { 
		my $urls = $self->session->db->buildArrayRef("select 
					   			distinct SyndicatedContent.rssUrl from SyndicatedContent 
					   		left join 
								asset on SyndicatedContent.assetId=asset.assetId 
					   		where
								asset.state='published'"
		);
		
		$instance->setScratch("syndicatedUrls", objToJson($urls));
		return $urls;
	}

	return jsonToObj($syndicatedUrls);
}


1;


