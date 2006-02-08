package WebGUI::Workflow::Activity::CleanTempStorage;


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
use File::Path;
use File::stat;


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

=head2 recurseFileSystem ( path )

Recurses the filesystem deleting files older than the specified time.

=head3 path

The starting path.

=cut

sub recurseFileSystem {
	my $self = shift;
	my $path = shift;
        my (@filelist, $file);
        if (opendir(DIR,$path)) {
                @filelist = readdir(DIR);
                closedir(DIR);
                foreach $file (@filelist) {
                        unless ($file eq "." || $file eq "..") {
                                $self->recurseFileSystem($path."/".$file);
                                if ($self->checkFileAge($path."/".$file)) {
                                        rmtree($path."/".$file);
                                }
                        }
                }
        }
}



#-------------------------------------------------------------------

=head2 execute (  )

See WebGUI::Workflow::Activity::execute() for details.

=cut

sub execute {
	my $self = shift;
	$self->recurseFileSystem($self->session->config->get("uploadsPath")."/temp");
}


#-------------------------------------------------------------------

=head2 getEditForm ( )

See WebGUI::Workflow::Activity::getEditForm() for details.

=cut 

sub getEditForm {
	my $self = shift;
	my $form = $self->SUPER::getEditForm();
	$form->interval(
		-name=>"storageTimeout",
		-label=>"Storage Timeout",
		-defaultValue=>6*60*60,
		-value=>$self->get("storageTimeout")
		);
	return $form;
}

#-------------------------------------------------------------------

=head2 getName ( session )

See WebGUI::Workflow::Activity::getName() for details.

=cut

sub getName {
	my $session = shift;
	return "Clean Temp Storage";
}



1;


