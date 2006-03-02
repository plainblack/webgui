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
	#In the new Wobject, "rssURL" actually can refer to more than one URL.
    	my @syndicatedWobjectURLs = $self->session->db->buildArray("select distinct SyndicatedContent.rssUrl from SyndicatedContent left join asset on SyndicatedContent.assetId=asset.assetId where asset.state='published'");
    	foreach my $url(@syndicatedWobjectURLs) {
        	#Loop through the SyndicatedWobjects and split all the URLs they are syndicating off into
        	#a separate array.
        	my @urlsToSyndicate = split(/\s+/,$url);
        	foreach ((@urlsToSyndicate)) {
            		WebGUI::Asset::Wobject::SyndicatedContent::_get_rss_data($self->session,$_);
        	}
    	}
	return 1;
}




1;


