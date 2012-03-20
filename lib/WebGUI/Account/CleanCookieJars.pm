package WebGUI::Workflow::Activity::CleanCookieJars;


=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2012 Plain Black Corporation.
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
use WebGUI::International;
use WebGUI::Storage;
use File::Basename ();
use File::Spec;

=head1 NAME

Package WebGUI::Workflow::Activity::CleanCookieJars

=head1 DESCRIPTION

Cleans up stale cookie jars

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
        my $i18n       = WebGUI::International->new( $session, "WorkFlow_Activity_CleanCookieJars" );
	push(@{$definition}, {
		name       => $i18n->get("activity cleanup cookie jars"),
		properties => {}
	});
	return $class->SUPER::definition($session,$definition);
}


#-------------------------------------------------------------------

=head2 execute (  )

See WebGUI::Workflow::Activity::execute() for details.

=cut

sub execute {
    my $self    = shift;
    my $session = $self->session;
    # keep track of how much time it's taking
    my $start   = time;
    my $limit   = 2_500;   # may need tweeking
    my $timeLimit = $self->getTTL;

    my $get_proxy = $session->db->read('select assetId, revisionDate, cookieJarStorageId from HttpProxy');
    STORAGEID: while (1) {
	my ($assetId, $revisionDate, $storageId,) = $get_proxy->array();
	last STORAGEID unless $storageId;
	print "Working on $assetId, $revisionDate, $storageId\n";
	my $storage = WebGUI::Storage->get($session, $storageId);
	next unless $storage;
	opendir my $directory, $storage->getPath;
	FILE: while (my $file = readdir($directory)) {
	    next FILE if $file =~ /^\./;
	    my $whole_file = $storage->getPath($file);
	    if (-M $whole_file >=1) {
		unlink $whole_file;
	    }
	    $limit--;
	    last if ! $limit or time > $start + $timeLimit;
	}

    }
    return $self->WAITING(1) if ! $limit or time > $start + $timeLimit;
    return $self->COMPLETE;
}

1;


