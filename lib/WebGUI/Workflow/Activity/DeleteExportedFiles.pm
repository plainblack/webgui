package WebGUI::Workflow::Activity::DeleteExportedFiles;


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
use File::Spec::Functions qw/canonpath/;
require Storable;

=head1 NAME

Package WebGUI::Workflow::Activity::DeleteExportedFiles

=head1 DESCRIPTION

Deletes an asset's exported files.  This must be added to a workflow
that passes the filenames to delete as auxiliary data.

=head1 SYNOPSIS

See WebGUI::Workflow::Activity for details on how to use any activity.

=cut


#-------------------------------------------------------------------

=head2 definition 

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift;
	my $i18n = WebGUI::International->new($session, "Workflow_Activity_DeleteExportedFiles");
	push(@{$definition},
	     {
	      name => $i18n->get('activityName'),
	      properties => {}
	     });
	return $class->SUPER::definition($session,$definition);
}


#-------------------------------------------------------------------
# Can use these from other places.  Buggo: POD?
use constant DELETE_FILES_SCRATCH => 'Workflow_Activity_DeleteExportedFiles_deleteFiles';
use constant PRUNE_DIRS_SCRATCH => 'Workflow_Activity_DeleteExportedFiles_pruneDirs';

#-------------------------------------------------------------------

=head2 _canonExportPath 

=cut

sub _canonExportPath {
	my $self = shift;
	my $path = shift;
	$self->session->config->get('exportPath').'/'.canonpath($path);
}

#-------------------------------------------------------------------

=head2 _pruneOfFile 

=cut

sub _pruneOfFile {
	my $self = shift;
	my $filename = shift;
	my $dirname = $filename;
	if ($dirname =~ s(/[^/]+\z)()g) {
		return ($dirname) unless glob(quotemeta($self->_canonExportPath($dirname)).'/*');
	}

	return ();
}

#-------------------------------------------------------------------

=head2 execute 

=cut

sub execute {
	my $self = shift;
	my $object = shift;
	my $instance = shift;

	unless ($self->session->config->get('exportPath')) {
		$self->session->log->warn("DeleteExportedFiles: no export path, so not doing anything");
		return $self->COMPLETE;
	}

	my $time = time;
	my $filesRef = Storable::thaw($instance->getScratch(DELETE_FILES_SCRATCH));
	unless ($filesRef) {
		$self->session->log->error("DeleteExportedFiles: can't find list of files to delete");
		return $self->ERROR;
	}

	my @files = @$filesRef;
	my @dirs = @{$instance->getScratch(PRUNE_DIRS_SCRATCH) || []};

    my $ttl = $self->getTTL;
	while (defined(my $filename = shift @files)) {
		my $cfilename = $self->_canonExportPath($filename);
		unlink $cfilename or $self->session->log->warn("DeleteExportedFiles: Couldn't unlink $filename: $!"), next;
		push @dirs, $self->_pruneOfFile($filename);
		goto pause if (time - $time > $ttl);
	}

	while (defined(my $dirname = shift @dirs)) {
		my $cdirname = $self->_canonExportPath($dirname);
		rmdir $cdirname or $self->session->log->warn("DeleteExportedFiles: couldn't rmdir $dirname: $!"), next;
		push @dirs, $self->_pruneOfFile($dirname);
		goto pause if (time - $time > $ttl);
	}

    done:
	$instance->deleteScratch(DELETE_FILES_SCRATCH);
	$instance->deleteScratch(PRUNE_DIRS_SCRATCH);
	return $self->COMPLETE;

    pause:
	$instance->setScratch(DELETE_FILES_SCRATCH, Storable::freeze(\@files));
	$instance->setScratch(PRUNE_DIRS_SCRATCH, Storable::freeze(\@dirs));
	return $self->WAITING(1);
}

1;


