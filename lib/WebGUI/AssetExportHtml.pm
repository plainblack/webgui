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

=head2 exportAsHtml ( hashref )

Executes the export and returns html content.

=head3 params

A hashref containing one of the following properties:

=head4 stripHtml

A boolean indicating whether the resulting output should be stripped of HTML tags.

=head4 userId

The unique id of the user to become when exporting this page. Defaults to '1' (Visitor).

=cut

sub exportAsHtml {
	my $self = shift;
	my $params = shift;
	my $userId = $params->{userId} || 1;
	my $stripHtml = $params->{stripHtml} || undef;

	# Change the stuff we need to change to do the export
	my $session = WebGUI::Session->open($self->session->config->getWebguiRoot, $self->session->config->getFilename);
	$session->user({userId=>$userId}) unless ($userId eq $self->session->user->profileField("userId"));
	$self->{_properties}{cacheTimeout} = $self->{_properties}{cacheTimeoutVisitor} = 1;

	# Generate the page
	my $content = $self->www_view;
	if($stripHtml) {
		$content = WebGUI::HTML::html2text($content);
	}

	return $content;
}


#-------------------------------------------------------------------

=head2 www_export

Displays the export page administrative interface

=cut

sub www_export {
	my $self = shift;
	return $self->session->privilege->insufficient() unless ($self->session->user->isInGroup(13));
        $self->getAdminConsole->setHelp("page export", "Asset");
	my $i18n = WebGUI::International->new($self->session);
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
	$f->text(
			-label=>$i18n->get('Extras URL'),
			-hoverHelp=>$i18n->get('Extras URL description'),
			-name=>"extrasURL",
			-value=>$self->session->config->get("extrasURL")
		);
	$f->text(
                        -label=>$i18n->get('Uploads URL'),
                        -hoverHelp=>$i18n->get('Uploads URL description'),
                        -name=>"uploadsURL",
                        -value=>$self->session->config->get("uploadsURL")
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
	my $i18n = WebGUI::International->new($self->session);
	my $iframeUrl = $self->getUrl('func=exportGenerate');
	$iframeUrl = $self->session->url->append($iframeUrl, 'index='.$self->session->form->process("index"));
	$iframeUrl = $self->session->url->append($iframeUrl, 'depth='.$self->session->form->process("depth"));
	$iframeUrl = $self->session->url->append($iframeUrl, 'userId='.$self->session->form->process("userId"));
	$iframeUrl = $self->session->url->append($iframeUrl, 'extrasURL='.$self->session->form->process("extrasURL"));
	$iframeUrl = $self->session->url->append($iframeUrl, 'uploadsURL='.$self->session->form->process("uploadsURL"));
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
	$self->session->request->print($self->session->http->getHeader());
	my $startTime =$self->session->datetime->time();	
	my $error = $self->checkExportPath();
	if ($error) {
		$self->session->request->print($error);
		return;
	}
	my $i18n = WebGUI::International->new($self->session);
	my $userId = $self->session->form->process("userId");
	my $extrasURL = $self->session->form->process("extrasURL");
	my $uploadsURL = $self->session->form->process("uploadsURL");
	my $index = $self->session->form->process("index");
	my $assets = $self->getLineage(["self","descendants"],{returnObjects=>1,endingLineageLength=>$self->getLineageLength+$self->session->form->process("depth")});
	foreach my $asset (@{$assets}) {
		my $url = $asset->get("url");
		$self->session->request->printf( $i18n->get('exporting page'), $url);
		unless ($asset->canView($userId)) {
			$self->session->request->print ($i18n->get('bad user privileges')."\n");
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
				$self->session->request->printf($i18n->get('could not create path'), $path, $@);
				return;
			}
		} 
		$path .= "/".$filename;
                eval { open(FILE, "> $path") or die "$!" };
		if ($@) {
			$self->session->request->printf($i18n->get('could not open path'), $path, $@);
			return;
		} else {
			print FILE $asset->exportAsHtml({userId=>$userId,extrasUrl=>$extrasURL,uploadsUrl=>$uploadsURL});
			close(FILE);
		}
		$self->session->request->print($i18n->get('done'));
	}
	$self->session->request->printf($i18n->get('export information'), scalar(@{$assets}), ($self->session->datetime->time()-$startTime));
	$self->session->request->print('<a target="_parent" href="'.$self->getUrl.'">'.$i18n->get(493).'</a>');
	return;
}




1;

