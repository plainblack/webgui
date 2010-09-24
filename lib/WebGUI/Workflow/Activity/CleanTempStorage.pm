package WebGUI::Workflow::Activity::CleanTempStorage;


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
use File::Path;
use File::stat;
use WebGUI::Asset;


=head1 NAME

Package WebGUI::Workflow::Activity::CleanTempStorage

=head1 DESCRIPTION

This activity cleans out temp storage after it's been sitting there a while.

=head1 SYNOPSIS

See WebGUI::Workflow::Activity for details on how to use any activity.

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 checkFileAge ( pathToFile ) 

Returns a boolean indicating whether the file is old enough to deleted or not.

=head3 pathToFile

The fully qualified path to the filename.

=cut

sub checkFileAge {
	my $self = shift;
	my $path = shift;
        my ($filestat, $flag);
        $filestat = stat($path) or print "No $path: $!";
        if ((time()-$filestat->mtime) > $self->get("storageTimeout")) {
                $flag = 1;
        } else {
                $flag = 0;
        }
        return $flag;
}

#-------------------------------------------------------------------

=head2 definition ( session, definition )

See WebGUI::Workflow::Activity::definition() for details.

=cut 

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift;
	my $i18n = WebGUI::International->new($session, "Workflow_Activity_CleanTempStorage");
	push(@{$definition}, {
		name=>$i18n->get("activityName"),
		properties=> {
			storageTimeout => {
				fieldType=>"interval",
				label=>$i18n->get("storage timeout"),
				defaultValue=>6*60*60,
				hoverHelp=>$i18n->get("storage timeout help")
				}
			}
		});
	return $class->SUPER::definition($session,$definition);
}


#-------------------------------------------------------------------

=head2 execute (  )

See WebGUI::Workflow::Activity::execute() for details.

=cut

sub execute {
    my $self  = shift;
    my $start = time();
    my $stop  = $start + $self->getTTL;

    # kill temporary assets
    my $tempspace = WebGUI::Asset->getTempspace($self->session);
    my $childIter = $tempspace->getLineageIterator(["children"], {
        statesToInclude => [qw(trash clipboard published)],
        statusToInclude => [qw(pending archived approved)],
        });
    while ( 1 ) {
        my $child;
        eval { $child = $childIter->() };
        if ( my $x = WebGUI::Error->caught('WebGUI::Error::ObjectNotFound') ) {
            $self->session->log->error($x->full_message);
            next;
        }
        last unless $child;
        if (time() - $child->get("revisionDate") > $self->get("storageTimeout")) {
            unless ($child->purge) {
                return $self->ERROR;
            }
        }
        # taking too long, give up
        return $self->WAITING(1) if (time() > $stop);
    }

    # kill temporary files
	return $self->recurseFileSystem($stop, $self->session->config->get("uploadsPath")."/temp");
}


#-------------------------------------------------------------------

=head2 recurseFileSystem ( path )

Recurses the filesystem deleting files older than the specified time.

=head3 path

The starting path.

=cut

sub recurseFileSystem {
	my $self = shift;
    my $stop = shift;
	my $path = shift;
    if (opendir(DIR,$path)) {
        my @filelist = readdir(DIR);
        closedir(DIR);
        foreach my $file (@filelist) {
            unless ($file eq "." || $file eq "..") {
                # taking too long, time to abort
                return $self->WAITING(1) if (time() > $stop);             

                # must search for children
                $self->recurseFileSystem($stop, $path."/".$file);

                # if it's old enough, let's kill it
                if ($self->checkFileAge($path."/".$file)) {
                    rmtree($path."/".$file);
                }
            }
        }
    }
	return $self->COMPLETE;
}


1;


