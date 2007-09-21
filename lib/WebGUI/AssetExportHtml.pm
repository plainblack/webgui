package WebGUI::Asset;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2007 Plain Black Corporation.
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

Returns a descriptive error message (HTML) if the export path is not 
writable, does not exist, or is not specified in the per-domain WebGUI 
config file.

=cut

sub checkExportPath {
	my $self = shift;
	my $error;
	if (defined $self->session->config->get("exportPath")) {
		if (-d $self->session->config->get("exportPath")) {
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
	my $self                = shift;
	my $quiet               = shift;
	my $userId              = shift;
	my $index               = shift;
	my $extrasUploadsAction = shift;
	my $rootUrlAction       = shift;
	my $startTime           = $self->session->datetime->time();

	my $exportPathError     = $self->checkExportPath();
	if ($exportPathError) {
		return (0, $exportPathError);
	}

	my $exportPath          = $self->session->config->get('exportPath');
	my $defaultAssetId      = $self->session->setting->get('defaultPage');
	my $defaultAssetPath    = undef;

	my $i18n = WebGUI::International->new($self->session, 'Asset');

	# Get a list of the asset IDs we need, reverse sorted by URL
	my $tempSession = WebGUI::Session->open($self->session->config->getWebguiRoot, $self->session->config->getFilename);
	$tempSession->user({userId=>$userId});
	my $newSelf = WebGUI::Asset->new($tempSession, $self->getId, $self->get("className"), $self->get("revisionDate"));
    	my $assetIds = $newSelf->getLineage(["self","descendants"],{ 
        	endingLineageLength => $newSelf->getLineageLength+$self->session->form->process("depth"),
                orderByClause       => 'assetData.url DESC',
            	});
    	$tempSession->var->end;
    	$tempSession->close;
    
    	# We're going to walk up the URL branch, making the deepest paths first
	foreach my $assetId (@{$assetIds}) {
        	my $assetSession = WebGUI::Session->open($self->session->config->getWebguiRoot, $self->session->config->getFilename);
        	$assetSession->user({userId=>$userId});
		my $asset = WebGUI::Asset->newByDynamicClass($assetSession, $assetId);
		my $url = $asset->get("url");

		# notify we can't output because user selected can't view the page
		unless ($asset->canView($userId)) {
			$self->session->output->print(sprintf($i18n->get('bad user privileges')."\n") . $asset->getUrl) unless $quiet;
			next;
		}

		# find out where we're exporting
		my $pathData = $self->_translateUrlToPath($url, $index);
		if (my $error = $pathData->{'error'}) {
			return (0, $error);
		}
		my $path        = $exportPath . '/'. $pathData->{'path'};
		my $filename    = $pathData->{'filename'};

		# this is needed for symlinking
		if ($asset->getId eq $defaultAssetId) {
			$defaultAssetPath = (length($pathData->{'path'}) ? $pathData->{'path'}."/" : "") . $pathData->{'filename'};
		}

		# see if path already exists, if not, create it
        	unless (-d $path) {
        		eval { mkpath($path) };
        		if($@) {
            			return (0, sprintf($i18n->get('could not create path'), $path, $@));
        		}
		}

		# output which page we're exporting
		my $pathWithFilename = $path.'/'.$filename;
		$pathWithFilename =~ s{//}{/}g;
		unless ($quiet) {
			$self->session->output->print(sprintf($i18n->get('exporting page'), $pathWithFilename));
		}

		# write the file
        	#open my $fileHandle, ">", $pathWithFilename;
		my $fileHandle = FileHandle->new(">".$pathWithFilename);
        	if (defined $fileHandle) {
            		$assetSession->output->setHandle($fileHandle);
            		$assetSession->asset($asset);
            		my $content = $asset->exportHtml_view;
			# chunked content will have already been printed, so no need to print again
            		unless ($content eq "chunked") {
                		$assetSession->output->print($content);
            		}
        		$fileHandle->close;
        	} 
		else {
            		return (0, sprintf($i18n->get('could not open path'), $pathWithFilename, $!));
        	}
		$assetSession->var->end;
		$assetSession->close;
		$self->session->db->write("UPDATE asset SET lastExportedAs = ? WHERE assetId = ?", [$pathWithFilename, $asset->getId]);
		$self->session->output->print($i18n->get('done')) unless $quiet;
	}
    
    	# symlink?
    	if ($extrasUploadsAction eq 'symlink') {
		my ($extrasPath, $uploadsPath) = ($self->session->config->get('extrasPath'), $self->session->config->get('uploadsPath'));
		my ($extrasUrl, $uploadsUrl) = ($self->session->config->get('extrasURL'), $self->session->config->get('uploadsURL'));
		s#^/*## for ($extrasUrl, $uploadsUrl);
		my ($extrasDst, $uploadsDst) = ($exportPath.'/'.$extrasUrl, $exportPath.'/'.$uploadsUrl);

		$self->session->output->print($i18n->get('extrasUploads symlinking')."\n") unless $quiet;
		foreach my $rec ([$extrasPath, $extrasDst], [$uploadsPath, $uploadsDst]) {
			my ($path, $dst) = @$rec;
			if (-l $dst) {
				next if (readlink $dst eq $path);
				unlink $dst or return (0, sprintf($i18n->get('could not unlink'), $dst, $!));
			}

			eval { mkpath($dst) };
			$@ and return (0, sprintf($i18n->get('could not create'), $dst, $@));
			rmdir $dst or return (0, sprintf($i18n->get('could not rmdir'), $dst, $!));
			symlink $path, $dst or return (0, sprintf($i18n->get('could not symlink'), $path, $dst, $!));
		}
	} 
	elsif ($extrasUploadsAction eq 'none') {
		# Nothing.  This is the default.
	}

	if ($rootUrlAction eq 'symlinkDefault') {
		if (defined $defaultAssetPath) {
			my ($src, $dst) = ($defaultAssetPath, $exportPath.'/'.$index);
			$self->session->output->print($i18n->get('rootUrl symlinking default')."\n") unless $quiet;
			if (-l $dst) {
				last if (readlink $dst eq $src);
				unlink $dst or return (0, sprintf($i18n->get('could not unlink'), $dst, $!));
			}
			symlink $src, $dst or return (0, sprintf($i18n->get('could not symlink'), $src, $dst, $!));
		} else {
			$self->session->output->print($i18n->get('rootUrl default not present')."\n") unless $quiet;
		}
	} elsif ($rootUrlAction eq 'none') {
		# Nothing.  This is the default.
	}

	return (1, sprintf($i18n->get('export information'), scalar(@{$assetIds}), ($self->session->datetime->time()-$startTime)));
}

#-------------------------------------------------------------------

=head2 _translateUrlToPath ( url, index )

Translates a url into an appropriate path and filename for exporting

=head3 url 

URL of the asset we need an export path for

=head3 index

index filename passed in from the UI

=cut

sub _translateUrlToPath {
	my $self    = shift;
	my $url     = shift;
	my $index   = shift;
	my $dataRef;

    # Ignore trailing slashes
    $url =~ s{/+$}{}g;

    # If there is not a dot in the URL, this is easy
	if ($url !~ m{[.]}) {					
		$dataRef->{'path'       } = $url;
		$dataRef->{'filename'   } = $index;
	}
    # There is a dot 
    else {
        # The last part after a slash is the "name"
        my ($path,$name) = $url =~ m{(?:(.*)  /)?  ([^/]+)  $}x;   # NOTE: Might be more efficient to use index() and substr()

        # If it ends in a known file type handled by apache, use that 
        if ($name =~ m{[.](?:html|htm|txt|pdf|jpg|css|gif|png|doc|xls|xml|rss|bmp|mp3|js|fla|flv|swf)$}) {
            $dataRef->{'path'       } = $path;
            $dataRef->{'filename'   } = $name;
        }
        else {
            # It doesn't end in a known file type
            # Make a directory for it
            $dataRef->{'path'       } = $url;
            $dataRef->{'filename'   } = $index;
        }
    }
	
	return $dataRef;
}	

#-------------------------------------------------------------------

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

=head2 exportHtml_view ( )

View method for static export.  This is like www_view, and defaults to
just calling www_view, but this needs to be overridden if www_view
depends on there being an actual HTTP response on the other end.

=cut

sub exportHtml_view {
	my $self = shift;
	$self->www_view(@_);
}

#-------------------------------------------------------------------

=head2 www_export

Displays the export page administrative interface

=cut

sub www_export {
	my $self = shift;
	return $self->session->privilege->insufficient() unless ($self->session->user->isInGroup(13));
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

	# TODO: maybe add copy options to these boxes alongside symlink
	$f->selectBox(
		        -label => $i18n->get('extrasUploads form label'),
		        -hoverHelp => $i18n->get('extrasUploads form hoverHelp'),
		        -name => "extrasUploadsAction",
		        -options => { 'symlink' => $i18n->get('extrasUploads form option symlink'),
				      'none' => $i18n->get('extrasUploads form option none') },
		        -value => ['none'],
		     );
	$f->selectBox(
		        -label => $i18n->get('rootUrl form label'),
		        -hoverHelp => $i18n->get('rootUrl form hoverHelp'),
		        -name => "rootUrlAction",
		        -options => { 'symlinkDefault' => $i18n->get('rootUrl form option symlinkDefault'),
				      'none' => $i18n->get('rootUrl form option none') },
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

	my $output = '<iframe src="'.$iframeUrl.'" title="'.$i18n->get('Page Export Status').'" width="700" height="500"></iframe>';
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
	$self->session->style->useEmptyStyle(1);
	$self->session->http->sendHeader;

	my $i18n = WebGUI::International->new($self->session, 'Asset');
	my ($success, $description) =
	    $self->_exportAsHtml(0, $self->session->form->process('userId'),
				 $self->session->form->process('index'),
				 $self->session->form->process('extrasUploadsAction'),
				 $self->session->form->process('rootUrlAction'));
	if (!$success) {	
		$self->session->output->print($description,1);
		return "chunked";
	}

	$self->session->output->print($description,1);
	$self->session->output->print('<a target="_parent" href="'.$self->getUrl.'">'.$i18n->get(493,'WebGUI').'</a>');
	return "chunked";
}

1;
