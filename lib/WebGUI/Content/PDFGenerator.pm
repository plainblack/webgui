package WebGUI::Content::PDFGenerator;

use warnings;
use strict;

use List::Util qw(first);
use Scope::Guard qw(guard);
use WebGUI::Session;
use WebGUI::Content::Asset;
use WebGUI::Cache;

=head1 NAME

WebGUI::Content::PDFGenerator

=head1 DESCRIPTION

Generates a PDF of the requested URL when op=generatePdf.

=head1 PREREQUISITES

This handler depends on wkpdftohtml, which does not ship with WebGUI and is,
as of this writing, still in active development. This handler was written for
version 0.9.9. It is available from http://code.google.com/p/wkhtmltopdf/.
Compiling is rather difficult, but static binaries are available for the most
popular platforms.

=head1 INSTALLATION

Enable this content handler in your WebGUI config file, placing it somewhere
before WebGUI::Content::Operation, and add a pdfGen section to your config
file at the top level. This must contain the path to your wkhtmltopdf
executable, a cache timeout (how many seconds to cache the pdf), and
optionally the userId of a user to view the page as (defaults to Visitor). It
can also contain additional command line arguments to pass to wkhtmltopdf.

    "pdfGen" : {
        "exe" : "/usr/local/bin/wkhtmltopdf",
        "args" : "--orientation Landscape",
        "userId" : "_f7d61hs6djh0fjnxqw21",
        "cacheTimeout" : 3600 # 1 hour cache timeout
    },
    "contentHandlers" : [
        #...
        "WebGUI::Content::PDFGenerator",
        #...
        "WebGUI::Content::Operation",
        #...
        "WebGUI::Content::NotFound"
   ],

=cut

#-------------------------------------------------------------------
# Return the cached pdf, generating if necessary.

sub cache {
    my $asset   = shift;
    my $session = $asset->session;
    my $key     = [
        'PDFGen', $session->url->getRequestedUrl, $asset->get('revisionDate'),
    ];
    my $cache   = WebGUI::Cache->new($session, $key);
    my $content = $cache->get;
    unless ($content) {
        $content = generate($asset);
        $cache->set($content, $session->config->get('pdfGen/cacheTimeout'));
    }
    return $content;
}

#-------------------------------------------------------------------
# Generate the pdf unconditionally and return it as a string.

sub generate {
    my $asset   = shift;
    my $session = $asset->session;
    my $url     = $session->url;
    my $c       = $session->config;
    my $o       = $c->get('pdfGen');
    my $login   = WebGUI::Session->open($c->getWebguiRoot, $c->getFilename);
    my $guard   = guard { $login->var->end; $login->close };
    $login->user({ userId => $o->{userId} || 1 });
    my @args = (
        $o->{exe}, @{$o->{args} || []},
        '--cookie', $c->get('cookieName'), $login->getId,
        $url->getSiteURL . $url->gateway($url->getRequestedUrl),
        '-'
    );

    # We're using backticks because trying to run external programs from a
    # mod_perl process is extremely tricky any other way, but TODO: figure out
    # use a real call and pass an array of args, as that would be safer.
    my $cmd = join ' ', @args;
    `$cmd`;
}

#-------------------------------------------------------------------
# Figure out which asset we need to check permissions for

sub getRequestedAsset {
    my $session  = shift;
    my $assetUrl = $session->url->getRequestedUrl;
    my $perms    = WebGUI::Content::Asset::getUrlPermutations($assetUrl);
    foreach my $url (@$perms) {
        if (my $asset = WebGUI::Content::Asset::getAsset($session, $url)) {
            return $asset;
        }
    }
}

#-------------------------------------------------------------------
# Top-level handler.

sub handler {
    my $session = shift;
    my $op = $session->form->get('op');
    return undef unless $op && $op eq 'generatePdf';
    my $asset = getRequestedAsset($session);
    return $session->privilege->noAccess unless $asset->canView;
    $session->http->setMimeType('application/pdf');
    return cache($asset);
}

1;
