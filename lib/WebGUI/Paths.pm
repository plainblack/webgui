package WebGUI::Paths;

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

our $VERSION = '0.0.1';

=head1 NAME

Package WebGUI::Paths

=head1 DESCRIPTION

Locations for WebGUI files

=head1 METHODS

These methods are available from this class:

=cut

use File::Spec ();
use Cwd ();
my $root;
BEGIN {
    $root = Cwd::realpath(File::Spec->catdir(
        File::Spec->catpath((File::Spec->splitpath(__FILE__))[0,1], ''),
        (File::Spec->updir) x 2
    ));
}

use constant {
    CONFIG_BASE        => File::Spec->catdir($root, 'etc'),
    LOG_CONFIG         => File::Spec->catfile($root, 'etc', 'log.conf'),
    SPECTRE_CONFIG     => File::Spec->catfile($root, 'etc', 'spectre.conf'),
    UPGRADES_PATH      => File::Spec->catfile($root, 'var', 'upgrades'),
    PRELOAD_CUSTOM     => File::Spec->catfile($root, 'sbin', 'preload.custom'),
    PRELOAD_EXCLUSIONS => File::Spec->catfile($root, 'sbin', 'preload.exclude'),
    EXTRAS             => File::Spec->catdir($root, 'www', 'extras'),
    DEFAULT_UPLOADS    => File::Spec->catdir($root, 'www', 'uploads'),
    DEFAULT_SQL        => File::Spec->catdir($root, 'var', 'create.sql'),
};

sub siteConfigs {
    opendir my $dh, CONFIG_BASE;
    my @configs;
    while (my $file = readdir $dh) {
        my $fullPath = Cwd::realpath(File::Spec->catfile(CONFIG_BASE, $file));
        if (-d $fullPath
            || $file !~ /\.conf$/
            || $fullPath eq Cwd::realpath(LOG_CONFIG)
            || $fullPath eq Cwd::realpath(SPECTRE_CONFIG)
        ) {
            next;
        }
        push @configs, $fullPath;
    }
    return @configs;
}



1;
