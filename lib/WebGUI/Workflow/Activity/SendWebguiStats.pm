package WebGUI::Workflow::Activity::SendWebguiStats; 


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
use HTTP::Request;
use HTTP::Request::Common qw(POST);
use LWP::UserAgent;
use Digest::MD5;

=head1 NAME

Package WebGUI::Workflow::Activity::SendWebguiStats

=head1 DESCRIPTION

This activity publishes information about your site to webgui.org. No private data is shared. The data is then rolled up on webgui.org/stats

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
	my $i18n = WebGUI::International->new($session, "Activity_SendWebguiStats");
	push(@{$definition}, {
		name=>$i18n->get("topicName"),
		properties=> {
			}
		});
	return $class->SUPER::definition($session,$definition);
}


#-------------------------------------------------------------------

=head2 execute ( [ object ] )

See WebGUI::Workflow::Activity::execute() for details.

=cut

sub execute {
	my $self = shift;
    my $object = shift;
    my $instance = shift;
    my $db = $self->session->db;
    my $stats = {
        webguiVersion   => $WebGUI::VERSION,
        perlVersion     => sprintf("%vd", $^V),
        apacheVersion   => 'X',
        osType          => $^O,
        siteId          => Digest::MD5::md5_base64($self->session->config->get("sitename")->[0]), # only here to identify the site if the user submits their info a second time
        userCount       => $db->quickScalar("select count(*) from users"),
        groupCount      => $db->quickScalar("select count(*) from groups"),
        assetCount      => $db->quickScalar("select count(*) from asset where state='published'"),
        packageCount    => $db->quickScalar("select count(distinct assetId) from assetData where isPackage=1"),
        assetTypes      => $db->buildArrayRefOfHashRefs("select count(*) as quantity,className from asset group by className"),
        };
    my $statsAsJson = JSON->new->encode($stats);
    my $userAgent = new LWP::UserAgent;
    $userAgent->env_proxy;
    $userAgent->agent("WebGUI/".$WebGUI::VERSION);
    $userAgent->timeout(30);
    my $request = POST 'https://www.webgui.org/stats', [ func => 'receiveStats', stats => $statsAsJson ];
    my $response = $userAgent->request($request);
    if ($response->is_error) {
        $self->session->errorHandler->error("WebGUI Stats could not be sent.");
    }
    return $self->COMPLETE;
}



1;

#vim:ft=perl
