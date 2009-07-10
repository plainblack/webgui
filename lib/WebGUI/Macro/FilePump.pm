package WebGUI::Macro::FilePump;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::FilePump::Bundle;
use Path::Class;
use WebGUI::International;

=head1 NAME

Package WebGUI::Macro::Build

=head1 DESCRIPTION

Macro to access FilePump bundle information.

=head2 process( $session, $bundleName, $type )

Deliver the bundle files.  If in admin mode, give raw links to the files.
If not in admin mode, give links to the bundled, minified files.

=over 4

=item *

A session variable

=item *

$bundleName, the name of a File Pump bundle.

=item *

$type, the type of files from the Bundle that you are accessing.  
Either JS or javascript, or CSS or css (case-insensitive).

=back

=cut


#-------------------------------------------------------------------
sub process {
	my $session    = shift;
	my $bundleName = shift;
	my $type       = shift;
    $type          = lc $type;
	my $output     = "";

    my $bundleId = WebGUI::FilePump::Bundle->getAllIds($session, {
        constraints => [ { 'bundleName = ?' => [$bundleName]}, ], 
        limit       => 1,
    });
    return '' unless $bundleId and $bundleId->[0];

    my $bundle = WebGUI::FilePump::Bundle->new($session, $bundleId->[0]);
    return '' unless $bundle;
    
    my $bundleDir = $bundle->getPathClassDir;
    
    # Sometimes, when migrating sites, restoring from backup, etc., you can
    # get into the situation where the bundle is defined in the db but doesn't
    # exist on the filesystem. In this case, simply generate a warning and 
    # trigger a bundle rebuild.
    if (!-e $bundleDir) {
        $session->log->warn("Bundle is marked as built, but does not exist on filesystem. Attempting to rebuild: $bundleDir");
        my ($code, $error) = $bundle->build;
        if ($error) {
            my $i18n = WebGUI::International->new($session, 'FilePump');
            $error = sprintf $i18n->get('build error'), $error;
            $session->log->error("Rebuild failed with error: $error");
            return $error;
        } else {
            $session->log->warn("Rebuild succeeded, continuing with macro processing");
        }
    }
    
    my $uploadsDir = Path::Class::Dir->new($session->config->get('uploadsPath'));
    my $extrasDir  = Path::Class::Dir->new($session->config->get('extrasPath'));
    my $uploadsUrl = Path::Class::Dir->new($session->config->get('uploadsURL'));
    my $extrasUrl  = Path::Class::Dir->new($session->config->get('extrasURL'));

    ##Normal mode
    if (! $session->var->isAdminOn) {
        # Built files live at /path/to/uploads/filepump/bundle.timestamp/ which is
        # a sub-dir of uploadsDir, so resolve the dir relative to uploads
        my $dir = $bundle->getPathClassDir->relative($uploadsDir);
        if ($type eq 'js' || $type eq 'javascript') {
            my $file = $uploadsUrl->file($dir, $bundle->bundleUrl . '.js');
            return sprintf qq|<script type="text/javascript" src="%s"></script>\n|, $file->stringify;
        }
        elsif ($type eq 'css') {
            my $file = $uploadsUrl->file($dir, $bundle->bundleUrl . '.css');
            return sprintf qq|<link rel="stylesheet" type="text/css" href="%s">\n|, $file->stringify;
        }
        else {
            return '';
        }
    }
    ##Admin/Design mode
    else {
        my $template;
        my $files;
        if ($type eq 'js' || $type eq 'javascript') {
            $template = qq|<script type="text/javascript" src="%s"></script>\n|;
            $files    = $bundle->get('jsFiles');
        }
        elsif ($type eq 'css') {
            $template = qq|<link rel="stylesheet" type="text/css" href="%s">\n|;
            $files    = $bundle->get('cssFiles');
        }
        else {
            return '';
        }
        foreach my $file (@{ $files }) {
            my $uri    = URI->new($file->{uri});
            my $scheme = $uri->scheme;
            my $url = '';
            if ($scheme eq 'asset') {
                $url = $uri->opaque;
            }
            elsif ($scheme eq 'file') {
                my $file = $bundle->resolveFilePath($uri->path);
                
                # Un-built files live inside either uploads or extras
                if ($uploadsDir->subsumes($file)) {
                    my $relFile = $file->relative($uploadsDir);
                    $url = $uploadsUrl->file($relFile)->stringify;
                } elsif ($extrasDir->subsumes($file)) {
                    my $relFile = $file->relative($extrasDir);
                    $url = $extrasUrl->file($relFile)->stringify;
                } else {
                    $session->log->warn("Invalid file: $file");
                    next;
                }
            }
            elsif ($scheme eq 'http' or $scheme eq 'https') {
                $url = $uri->as_string;
            }
            $url =~ tr{/}{/}s;
            $output .= sprintf $template, $url;
        }
        return $output;
    }
	return '';
}

1;

#vim:ft=perl
