package WebGUI::Export;


=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2004 Plain Black LLC.
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
use WebGUI::HTML;
use WebGUI::HTTP;
use WebGUI::URL;

=head1 NAME

Package WebGUI::Export

=head1 DESCRIPTION

This package provides methods to export WebGUI content.

=head1 SYNOPSIS

 use WebGUI::Export;

 # Generate an export of current page:
 $e = new WebGUI::Export();
 $html = $e->generate;

 # Generate an export of pageId 238:
 $e = new WebGUI::Export();
 $e->set(pageId=>238);
 $html = $e->generate;

 # Some more options
 $e = new WebGUI::Export(
			pageId => 1021,
                        styleId => 1000,
                        userId => 3,
                        altSiteURL => "http://www.exportsite.nl/",
			extrasURL => "http://www.webguisite.com/extras"
			);
 $e->generate;

=head1 METHODS

These methods are available from this package:

=cut

#-------------------------------------------------------------------

=head2 generate ( )

Executes the export and returns html content.

=over

=item filename 

Full path to a file. 

=back

=cut

sub generate {
	my $self = shift;
	my $fileName = shift;

	# Save current session information because we need to restore current session after
	# the export has finished.
	my %oldSession = %session;

	# Refresh session for userId, defaults to visitor
	WebGUI::Session::refreshUserInfo($self->get('userId') || 1,$session{dbh});

	# Delete all form parameters
	delete $session{form}; 

	# Admin bar
	$session{var}{adminOn} = $self->get('adminOn');

	# Set the page to export.
	WebGUI::Session::refreshPageInfo($self->get('pageId'));

	# Caching
	if($self->get('noCache')) {
		$session{page}{cacheTimeout} = 0;
               $session{page}{cacheTimeoutVisitor} = 0;
	}

	# Uploads / Extras URL
	$session{config}{uploadsURL} = $self->get('uploadsURL') || $session{config}{uploadsURL};
	$session{config}{extrasURL} = $self->get('extrasURL') || $session{config}{extrasURL};

	# Disable printing of HTTP Header if requested.
	if($self->get('noHttpHeader')) {
		WebGUI::HTTP::setNoHeader(1);
	}

	# Set alternate Site URL
	if($self->get('altSiteURL')) {
		WebGUI::URL::setSiteURL($self->get('altSiteURL'));
	} elsif ($self->get('relativeUrls')) {
		WebGUI::URL::setSiteURL("./");
		my $url = $session{page}{urlizedTitle};
		while ($url =~ /\//g) {
			WebGUI::URL::setSiteURL(WebGUI::URL::getSiteURL()."../");
		}
	}
	# !!! At this point we make URLs absolute only if altSiteURL is not set.
	
	# Set alternate Style
	$session{page}{styleId} = $self->get('styleId') || $session{page}{styleId};

	# Generate the page
	my $content = WebGUI::page(undef, undef, 1, $session{page}{urlizedTitle});

	if($self->get('stripHTML')) {
		$content = WebGUI::HTML::html2text($content);
	} elsif (not $session{url}{siteURL}) {	# Implies absolute links
		$content = WebGUI::HTML::makeAbsolute($content);
	}

	# Restore session
	%session = %oldSession;
	delete $session{page}{noHttpHeader};
	delete $session{url}{siteURL};
	return $content;
		
}
#-------------------------------------------------------------------

=head2 new (  [ options ] )

Constructor.

Options can be set when a new Export object is constructed, or
afterwards with the set method. None of the options is required.

=over

=item pageId

Sets the page to be generated. Defaults to current page.
 
=item styleId

Use this to override the default styleId.
Defaults to the page styleId. 

=item userId

Runs the export as this user. Defaults to 1 (Visitor).

=item altSiteURL

Use this to override the absolute site URL. A valid value
would be "http://www.site.com/". Setting this negates the effect
of the relativeUrls option.

=item noCache

Is set to true by default. This will make sure
that the exported page is generated and not fetched from cache.

=item noHttpHeader

Turns off the inclusion of a HTTP header. By default this option
is set to true.

=item adminOn

Turns on / off the adminbar in the generated page. Is false by
default.

=item stripHTML

Strips HTML from the document and outputs only text. Is disabled
by default.

=item relativeUrls

If set, all navigation URL's will be constructed relative. By default
all links will be made absolute. This option is negated if altSiteURL
is set.

=item extrasURL

You can specify an alternate URL for the extras location. By default
the extrasURL setting from the config file is used.

=item uploadsURL

You can specify an alternate URL for the uploads location. By default
the uploadsURL setting from the config file is used.

=back

=cut

sub new {
        my $class = shift;
        WebGUI::ErrorHandler::fatalError('WebGUI::Export->new() called with odd number of option parameters - should be of the form option => value') unless $#_ % 2;;
        my %var = @_;
        my $self = bless {}, $class;
        my %default = ( 
			uploadsURL => $session{config}{uploadsURL},
			extrasURL => $session{config}{extrasURL},
			pageId => $session{page}{pageId},
			styleId => undef,
			userId => 1,
			noCache => 1,
			noHttpHeader => 1,
			adminOn => 0,
			stripHTML => 0,
			altSiteURL => undef,
			relativeUrls => 0,
		);
        %var = ( %default, %var);
        $self->set(%var);
        return $self;
}

#-------------------------------------------------------------------

=head2 get ( key )

Gets the value for key from the class.

=over

=item key 

See documentation on the "new" constructor for an overview of all options.

=back

=cut

sub get {
        my $self = shift;
	my $key = shift;
	return $self->{"_".$key};
}

#-------------------------------------------------------------------

=head2 set ( options )

Sets properties for this export to the object.

=over

=item options

See documentation on the "new" constructor for an overview of all options.

=back

=cut

sub set {
	my $self = shift;
	my %var = @_;
	foreach (keys %var) {
		$self->{"_".$_} = $var{$_}
	}
}


1;


