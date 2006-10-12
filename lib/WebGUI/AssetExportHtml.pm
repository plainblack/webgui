package WebGUI::Asset;

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
use File::Path;
use FileHandle;

=head1 NAME

Package WebGUI::AssetExportHtml

=head1 DESCRIPTION

This is a mixin package for WebGUI::Asset that contains all clipboard related functions.

=head1 SYNOPSIS

 use WebGUI::Asset;

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 checkExportPath ( )

Returns a descriptive error message (HTML) if the export path is not writable, does not exist, or is not specified in the per-domain WebGUI config file.

=cut

sub checkExportPath {
	my $self = shift;
	my $error;
	if(defined $self->session->config->get("exportPath")) {
		if(-d $self->session->config->get("exportPath")) {
			unless (-w $self->session->config->get("exportPath")) {
				$error .= 'Error: The export path '.$self->session->config->get("exportPath").' is not writable.<br />
						Make sure that the webserver has permissions to write to that directory';
			}
		} else {
			eval {mkpath($self->session->config->get("exportPath"),0)};
                	if ($@) {
                        	$error .= 'Error: The export path '.$self->session->config->get("exportPath").' does not exist, and couldn\'t create it because '.$@;
                	}
		}
	} else {
		$error.= 'Error: The export path is not configured. Please set the exportPath variable in the WebGUI config file';
	}
	$error = '<p><b>'.$error.'</b></p>' if $error;
	return $error;
}

#-------------------------------------------------------------------

# Private method to do most of the work for exporting.  Returns
# ($success_flag, $description).

# Buggo: probably shouldn't be doing i18n stuff here; refactor this
# further

sub _exportAsHtml {
	my $self = shift;
	my $quiet = shift;
	my $userId = shift;
	my $index = shift;
	my $extrasUploadsAction = shift;
	my $rootUrlAction = shift;
	my $startTime = $self->session->datetime->time();

	my $exportPathError = $self->checkExportPath();
	if ($exportPathError) {
		return (0, $exportPathError);
	}

	my $exportPath = $self->session->config->get('exportPath');
	my $defaultAssetId = $self->session->setting->get('defaultPage');
	my $defaultAssetPath = undef;

	my $i18n = WebGUI::International->new($self->session, 'Asset');

	my $newSession = WebGUI::Session->open($self->session->config->getWebguiRoot, $self->session->config->getFilename);
	$newSession->user({userId=>$userId});

	my $newSelf = WebGUI::Asset->new($newSession, $self->getId, $self->get("className"), $self->get("revisionDate"));
	my $assets = $newSelf->getLineage(["self","descendants"],{returnObjects=>1,endingLineageLength=>$newSelf->getLineageLength+$self->session->form->process("depth")});

	foreach my $asset (@{$assets}) {
		my $url = $asset->get("url");
		$self->session->output->print(sprintf($i18n->get('exporting page'), $url)) unless $quiet;

		unless ($asset->canView($userId)) {
			$self->session->output->print(sprintf($i18n->get('bad user privileges')."\n")) unless $quiet;
			next;
		}

		my $path;
		my $filename;

		if ($url =~ /\./) {
			if ($url =~ /^(.*)\/(.*)$/) {
				$path = $1;
				$filename = $2;
				if ($filename eq "") {
					$filename = $path;
					$path = undef;
				}
			} else {
				$path = undef;
				$filename = $url;
			}
		} else {
			$path = $url;
			$filename = $index;
		}

		if ($asset->getId eq $defaultAssetId) {
			$defaultAssetPath = $path.'/'.$filename;
		}

		$path = $exportPath . (length($path)? "/$path" : "");
		eval { mkpath($path) };
		if($@) {
			return (0, sprintf($i18n->get('could not create path'), $path, $@));
		}
		$path .= "/".$filename;

                my $file = eval { FileHandle->new(">".$path) or die "$!" };
		if ($@) {
			return (0, sprintf($i18n->get('could not open path'), $path, $@));
		} else {
			$newSession->output->setHandle($file);
			$newSession->asset($asset);
			my $content = $asset->www_view;
			unless ($content eq "chunked") {
				$newSession->output->print($content);
			}
			$file->close;
		}

		$self->session->output->print($i18n->get('done')) unless $quiet;
	}
	$newSession->var->end;
	$newSession->close;

	if ($extrasUploadsAction eq 'symlink') {
		my ($extrasPath, $uploadsPath) = ($self->session->config->get('extrasPath'), $self->session->config->get('uploadsPath'));
		my ($extrasUrl, $uploadsUrl) = ($self->session->config->get('extrasURL'), $self->session->config->get('uploadsURL'));
		s#^/*## for ($extrasUrl, $uploadsUrl);
		my ($extrasDst, $uploadsDst) = ($exportPath.'/'.$extrasUrl, $exportPath.'/'.$uploadsUrl);

		# TODO: internationalize
		$self->session->output->print("Symlinking extras and uploads dirs.\n") unless $quiet;
		foreach my $rec ([$extrasPath, $extrasDst],
				 [$uploadsPath, $uploadsDst]) {
			my ($path, $dst) = @$rec;
			if (-l $dst) {
				next if (readlink $dst eq $path);
				unlink $dst or return (0, sprintf("Could not unlink %s: %s", $dst, $!));
			}

			eval { mkpath($dst) };
			$@ and return (0, sprintf("Could not create path %s: %s", $dst, $@));
			rmdir $dst or return (0, sprintf("Could not remove directory at path %s: %s", $dst, $!));
			symlink $path, $dst or return (0, sprintf("Could not symlink %s to %s: %s", $path, $dst, $!));
		}
	} elsif ($extrasUploadsAction eq 'none') {
		# Nothing.  This is the default.
	}

	if ($rootUrlAction eq 'symlinkDefault') {
		# TODO: internationalize
		if (defined $defaultAssetPath) {
			my ($src, $dst) = ($defaultAssetPath, $exportPath.'/'.$index);
			$self->session->output->print("Symlinking default asset.\n") unless $quiet;
			if (-l $dst and readlink $dst ne $src) {
				unlink $dst or return (0, sprintf("Could not unlink %s: %s", $dst, $!));
			}
			symlink $src, $dst or return (0, sprintf("Could not symlink %s to %s: %s", $src, $dst, $!));
		} else {
			$self->session->output->print("Not symlinking default asset; not included in exported subtree.\n") unless $quiet;
		}
	} elsif ($rootUrlAction eq 'none') {
		# Nothing.  This is the default.
	}

	return (1, sprintf($i18n->get('export information'), scalar(@{$assets}), ($self->session->datetime->time()-$startTime)));
}

=head2 exportAsHtml 

Same as www_exportGenerate except without the output. Returns
"success" if successful, otherwise returns an error message.

=cut

sub exportAsHtml {
	my $self = shift;
	my ($success, $description) = $self->_exportAsHtml(1, '1', 'index.html');
	return $success? "success" : $description;
}

#-------------------------------------------------------------------

=head2 www_export

Displays the export page administrative interface

=cut

sub www_export {
	my $self = shift;
	return $self->session->privilege->insufficient() unless ($self->session->user->isInGroup(13));
        $self->getAdminConsole->setHelp("page export", "Asset");
	my $i18n = WebGUI::International->new($self->session, "Asset");
        my $f = WebGUI::HTMLForm->new($self->session,-action=>$self->getUrl);
        $f->hidden(
		-name => "func",
		-value => "exportStatus"
		);
	$f->integer(
			-label=>$i18n->get('Depth'),
			-hoverHelp=>$i18n->get('Depth description'),
			-name=>"depth",
			-value=>99,
		);
	$f->selectBox(
			-label=>$i18n->get('Export as user'),
			-hoverHelp=>$i18n->get('Export as user description'),
			-name=>"userId",
			-options=>$self->session->db->buildHashRef("select userId, username from users"),
			-value=>[1],
		);
	$f->text(
			-label=>$i18n->get("directory index"),
			-hoverHelp=>$i18n->get("directory index description"),
			-name=>"index",
			-value=>"index.html"
		);
	# TODO: internationalize
	# TODO: maybe add copy options to these boxes alongside symlink
	$f->selectBox(
		        -label => "Extras and uploads directories",
		        -hoverHelp => "What action to take regarding the extras and uploads directories, which are often referenced by parts of the site.  Symlink means to use a symbolic link (not available on all systems) to the original directory.  None means to do nothing, and ignore the extras and uploads directories; this will probably cause references to them to break in the exported site unless you've prepared the directories already.",
		        -name => "extrasUploadsAction",
		        -options => { 'symlink' => 'Symlink',
				      'none' => 'None' },
		        -value => ['none'],
		     );
	$f->selectBox(
		        -label => "Root URL",
		        -hoverHelp => "What action to take regarding queries to the root URL.  Symlink Default means to create a symbolic link from the root-URL index file to the index file of the default asset (not available on all systems).  None means to do nothing, which usually causes queries to the root URL to be rejected in the exported site.",
		        -name => "rootUrlAction",
		        -options => { 'symlinkDefault' => 'Symlink Default',
				      'none' => 'None' },
		        -value => ['none'],
		     );
        $f->submit;
        $self->getAdminConsole->render($self->checkExportPath.$f->print,$i18n->get('Export Page'));
}


#-------------------------------------------------------------------

=head2 www_exportStatus

Displays the export status page

=cut

sub www_exportStatus {
	my $self = shift;
	return $self->session->privilege->insufficient() unless ($self->session->user->isInGroup(13));
	my $i18n = WebGUI::International->new($self->session, "Asset");
	my $iframeUrl = $self->getUrl('func=exportGenerate');
	foreach my $formVar (qw/index depth userId extrasUploadsAction rootUrlAction/) {
		$iframeUrl = $self->session->url->append($iframeUrl, $formVar.'='.$self->session->form->process($formVar));
	}

	my $output = '<iframe src="'.$iframeUrl.'" title="'.$i18n->get('Page Export Status').'" width="410" height="200"></iframe>';
        $self->getAdminConsole->render($output,$i18n->get('Page Export Status'),"Asset");
}

#-------------------------------------------------------------------

=head2 www_exportGenerate

Executes the export process and displays real time status. This operation is displayed by exportStatus in an IFRAME.

=cut

sub www_exportGenerate {
	my $self = shift;
	return $self->session->privilege->insufficient() unless ($self->session->user->isInGroup(13));
	# This routine is called in an IFRAME and prints status output directly to the browser.
	$|++;				# Unbuffered data output
	$self->session->http->sendHeader;

	my $i18n = WebGUI::International->new($self->session, 'Asset');
	my ($success, $description) =
	    $self->_exportAsHtml(0, $self->session->form->process('userId'),
				 $self->session->form->process('index'),
				 $self->session->form->process('extrasUploadsAction'),
				 $self->session->form->process('rootUrlAction'));
	if (!$success) {	
		$self->session->output->print($description,1);
		return;
	}

	$self->session->output->print($description,1);
	$self->session->output->print('<a target="_parent" href="'.$self->getUrl.'">'.$i18n->get(493,'WebGUI').'</a>');
	return;
}

1;
