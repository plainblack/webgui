package WebGUI::Asset;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2005 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use WebGUI::Session;
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
	my $error;
	if(defined $session{config}{exportPath}) {
		if(-d $session{config}{exportPath}) {
			unless (-w $session{config}{exportPath}) {
				$error .= 'Error: The export path '.$session{config}{exportPath}.' is not writable.<br />
						Make sure that the webserver has permissions to write to that directory';
			}
		} else {
			eval {mkpath($session{config}{exportPath},0)};
                	if ($@) {
                        	$error .= 'Error: The export path '.$session{config}{exportPath}.' does not exist, and couldn\'t create it because '.$@;
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

=head4 extrasUrl

The URL where the page will be able to find the WebGUI extras folder. Defaults to the extrasURL in the config file.

=head4 stripHtml

A boolean indicating whether the resulting output should be stripped of HTML tags.

=head4 uploadsUrl

The URL where the page will be able to find the files uploaded to WebGUI. Defaults to the uploadsURL in the config file.

=head4 userId

The unique id of the user to become when exporting this page. Defaults to '1' (Visitor).

=cut

sub exportAsHtml {
	my $self = shift;
	my $params = shift;
	my $uploadsUrl = $params->{uploadsUrl} || $session{config}{uploadsUrl};
	my $extrasUrl = $params->{extrasUrl} || $session{config}{extrasUrl};
	my $userId = $params->{userId} || 1;
	my $stripHtml = $params->{stripHtml} || undef;

	# Save current session information because we need to restore current session after the export has finished.
	my %oldSession = %session;

	# Change the stuff we need to change to do the export
	WebGUI::Session::refreshUserInfo($userId) unless ($userId == $session{user}{userId});
	delete $session{form}; 
	$session{var}{adminOn} = $self->get('adminOn');
	$self->WebGUI::Session::refreshPageInfo;
	$self->{_properties}{cacheTimeout} = $self->{_properties}{cacheTimeoutVisitor} = 1;
	$session{config}{uploadsURL} = $uploadsUrl;
	$session{config}{extrasURL} = $extrasUrl;

	# Generate the page
	my $content = $self->www_view;
	if($stripHtml) {
		$content = WebGUI::HTML::html2text($content);
	}

	# Restore session
	%session = %oldSession;
	delete $session{page}{noHttpHeader};
	return $content;
}


#-------------------------------------------------------------------

=head2 www_export

Displays the export page administrative interface

=cut

sub www_export {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless (WebGUI::Grouping::isInGroup(13));
        $self->getAdminConsole->setHelp("page export", "Asset");
        my $f = WebGUI::HTMLForm->new(-action=>$self->getUrl);
        $f->hidden(
		-name => "func",
		-value => "exportStatus"
		);
	$f->integer(
			-label=>WebGUI::International::get('Depth',"Asset"),
			-hoverHelp=>WebGUI::International::get('Depth description',"Asset"),
			-name=>"depth",
			-value=>99,
		);
	$f->selectBox(
			-label=>WebGUI::International::get('Export as user',"Asset"),
			-hoverHelp=>WebGUI::International::get('Export as user description',"Asset"),
			-name=>"userId",
			-options=>WebGUI::SQL->buildHashRef("select userId, username from users"),
			-value=>[1],
		);
	$f->text(
			-label=>WebGUI::International::get("directory index","Asset"),
			-hoverHelp=>WebGUI::International::get("directory index description","Asset"),
			-name=>"index",
			-value=>"index.html"
		);
	$f->text(
			-label=>WebGUI::International::get('Extras URL',"Asset"),
			-hoverHelp=>WebGUI::International::get('Extras URL description',"Asset"),
			-name=>"extrasURL",
			-value=>$session{config}{extrasURL}
		);
	$f->text(
                        -label=>WebGUI::International::get('Uploads URL',"Asset"),
                        -hoverHelp=>WebGUI::International::get('Uploads URL description',"Asset"),
                        -name=>"uploadsURL",
                        -value=>$session{config}{uploadsURL}
                );
        $f->submit;
        $self->getAdminConsole->render($self->checkExportPath.$f->print,WebGUI::International::get('Export Page',"Asset"));
}


#-------------------------------------------------------------------

=head2 www_exportStatus

Displays the export status page

=cut

sub www_exportStatus {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless (WebGUI::Grouping::isInGroup(13));
	my $iframeUrl = $self->getUrl('func=exportGenerate');
	$iframeUrl = WebGUI::URL::append($iframeUrl, 'index='.$session{form}{index});
	$iframeUrl = WebGUI::URL::append($iframeUrl, 'depth='.$session{form}{depth});
	$iframeUrl = WebGUI::URL::append($iframeUrl, 'userId='.$session{form}{userId});
	$iframeUrl = WebGUI::URL::append($iframeUrl, 'extrasURL='.$session{form}{extrasURL});
	$iframeUrl = WebGUI::URL::append($iframeUrl, 'uploadsURL='.$session{form}{uploadsURL});
	my $output = '<iframe src="'.$iframeUrl.'" title="'.WebGUI::International::get('Page Export Status',"Asset").'" width="410" height="200"></iframe>';
        $self->getAdminConsole->render($output,WebGUI::International::get('Page Export Status',"Asset"),"Asset");
}

#-------------------------------------------------------------------

=head2 www_exportPageGenerate

Executes the export process and displays real time status. This operation is displayed by exportPageStatus in an IFRAME.

=cut

sub www_exportGenerate {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless (WebGUI::Grouping::isInGroup(13));
	# This routine is called in an IFRAME and prints status output directly to the browser.
	$|++;				# Unbuffered data output
        $session{page}{empty} = 1;      # Write directly to the browser
	print WebGUI::HTTP::getHeader();
	my $startTime = time();	
	my $error = $self->checkExportPath();
	if ($error) {
		print $error;
		return;
	}
	my $userId = $session{form}{userId};
	my $extrasURL = $session{form}{extrasURL};
	my $uploadsURL = $session{form}{uploadsURL};
	my $index = $session{form}{index};
	my $assets = $self->getLineage(["self","descendants"],{returnObjects=>1,endingLineageLength=>$self->getLineageLength+$session{form}{depth}});
	foreach my $asset (@{$assets}) {
		my $url = $asset->get("url");
		printf WebGUI::International::get('exporting page', 'Asset'), $url;
		unless ($asset->canView($userId)) {
			print WebGUI::International::get('bad user privileges', 'Asset')."\n";
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
			$path = $session{config}{exportPath} . "/" . $path;
			eval { mkpath($path) };
			if($@) {
				printf WebGUI::International::get('could not create path', 'Asset'), $path, $@;
				return;
			}
		} 
		$path .= "/".$filename;
                eval { open(FILE, "> $path") or die "$!" };
		if ($@) {
			printf WebGUI::International::get('could not open path', 'Asset'), $path, $@;
			return;
		} else {
			print FILE $self->exportAsHtml({userId=>$userId,extrasUrl=>$extrasURL,uploadsUrl=>$uploadsURL});
			close(FILE);
		}
		print WebGUI::International::get('done','Asset');
	}
	printf WebGUI::International::get('export information','Asset'), scalar(@{$assets}), (time()-$startTime);
	print '<a target="_parent" href="'.$self->getUrl.'">'.WebGUI::International::get(493,"Asset").'</a>';
	return;
}




1;

