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

=head2 exportAsHtml 

Same as www_exportGenerate except without the output. Returns "success" if successful, otherwise returns an error message.

=cut

sub exportAsHtml {
	my $self = shift;
	my $error = $self->checkExportPath();
	if ($error) {
		return $error;
	}
	my $userId = '1';
	my $index = "index.html";
	# Change the stuff we need to change to do the export
	my $newSession = WebGUI::Session->open($self->session->config->getWebguiRoot, $self->session->config->getFilename);
	my $newSelf = WebGUI::Asset->new($newSession, $self->getId, $self->get("className"), $self->get("revisionDate"));
	my $assets = $newSelf->getLineage(["self","descendants"],{returnObjects=>1,endingLineageLength=>$newSelf->getLineageLength+$self->session->form->process("depth")});
	$newSession->user({userId=>$userId});
	foreach my $asset (@{$assets}) {
		my $url = $asset->get("url");
		unless ($asset->canView($userId)) {
			next;
		}
		my $path;
		my $filename;
		if ($url =~ /\./) {
			$url =~ /^(.*)\/(.*)$/;
			$path = $1;
			$filename = $2;
			if ($filename eq "") {
				$filename = $path;
				$path = undef;
			}
		} else {
			$path = $url;
			$filename = $index;
		}
		if($path) {
			$path = $self->session->config->get("exportPath") . "/" . $path;
			eval { mkpath($path) };
			if($@) {
				return "Couldn't create path";
			}
		} 
		$path .= "/".$filename;
                my $file = eval { FileHandle->new(">".$path) or die "$!" };
		if ($@) {
			return "couldn't open path";
		} else {
			$newSession->output->setHandle($file);
			my $content = $asset->www_view;
			unless ($content eq "chunked") {
				$newSession->output->print($content);
			}
			$file->close;
		}
	}
	$newSession->var->end;
	$newSession->close;
	return "success";
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
	$iframeUrl = $self->session->url->append($iframeUrl, 'index='.$self->session->form->process("index"));
	$iframeUrl = $self->session->url->append($iframeUrl, 'depth='.$self->session->form->process("depth"));
	$iframeUrl = $self->session->url->append($iframeUrl, 'userId='.$self->session->form->process("userId"));
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
	my $startTime =$self->session->datetime->time();	
	my $error = $self->checkExportPath();
	if ($error) {
		$self->session->output->print($error,1);
		return;
	}
	my $i18n = WebGUI::International->new($self->session, 'Asset');
	my $userId = $self->session->form->process("userId");
	my $index = $self->session->form->process("index");
	# Change the stuff we need to change to do the export
	my $newSession = WebGUI::Session->open($self->session->config->getWebguiRoot, $self->session->config->getFilename);
	my $newSelf = WebGUI::Asset->new($newSession, $self->getId, $self->get("className"), $self->get("revisionDate"));
	my $assets = $newSelf->getLineage(["self","descendants"],{returnObjects=>1,endingLineageLength=>$newSelf->getLineageLength+$self->session->form->process("depth")});
	$newSession->user({userId=>$userId});
	foreach my $asset (@{$assets}) {
		my $url = $asset->get("url");
		$self->session->output->print ( printf($i18n->get('exporting page')), $url);
		unless ($asset->canView($userId)) {
			$self->session->output->print ($i18n->get('bad user privileges')."\n");
			next;
		}
		my $path;
		my $filename;
		if ($url =~ /\./) {
			$url =~ /^(.*)\/(.*)$/;
			$path = $1;
			$filename = $2;
			if ($filename eq "") {
				$filename = $path;
				$path = undef;
			}
		} else {
			$path = $url;
			$filename = $index;
		}
		if($path) {
			$path = $self->session->config->get("exportPath") . "/" . $path;
			eval { mkpath($path) };
			if($@) {
				$self->session->output->print(printf($i18n->get('could not create path'), $path, $@), 1);
				return;
			}
		} 
		$path .= "/".$filename;
                my $file = eval { FileHandle->new(">".$path) or die "$!" };
		if ($@) {
			$self->session->output->print(printf($i18n->get('could not open path'), $path, $@),1);
			return;
		} else {
			$newSession->output->setHandle($file);
			my $content = $asset->www_view;
			unless ($content eq "chunked") {
				$newSession->output->print($content);
			}
			$file->close;
		}
		$self->session->output->print($i18n->get('done'));
	}
	$newSession->var->end;
	$newSession->close;
	$self->session->output->print(printf($i18n->get('export information'), scalar(@{$assets}), ($self->session->datetime->time()-$startTime)),1);
	$self->session->output->print('<a target="_parent" href="'.$self->getUrl.'">'.$i18n->get(493,'WebGUI').'</a>');
	return;
}




1;

