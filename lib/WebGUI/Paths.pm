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
use Carp qw(croak);
use Cwd qw(realpath);
use File::Spec::Functions qw(catdir splitpath catpath splitpath updir catfile);
use Try::Tiny;

use namespace::clean;

=head1 NAME

Package WebGUI::Paths

=head1 DESCRIPTION

Locations for WebGUI files

=head1 METHODS

These methods are available from this class:

=cut

my $root;
BEGIN {
    $root = realpath(catdir(
        catpath((splitpath(__FILE__))[0,1], ''), (updir) x 2
    ));
}

use constant {
    CONFIG_BASE        => catdir($root, 'etc'),
    LOG_CONFIG         => catfile($root, 'etc', 'log.conf'),
    SPECTRE_CONFIG     => catfile($root, 'etc', 'spectre.conf'),
    UPGRADES_PATH      => catfile($root, 'var', 'upgrades'),
    PRELOAD_CUSTOM     => catfile($root, 'sbin', 'preload.custom'),
    PRELOAD_EXCLUSIONS => catfile($root, 'sbin', 'preload.exclude'),
    EXTRAS             => catdir($root, 'www', 'extras'),
    DEFAULT_UPLOADS    => catdir($root, 'www', 'uploads'),
    DEFAULT_SQL        => catdir($root, 'var', 'create.sql'),
};

sub siteConfigs {
    opendir my $dh, CONFIG_BASE;
    my @configs;
    while ( my $file = readdir $dh ) {
        my $fullPath = realpath( catfile( CONFIG_BASE, $file ) );
        if (   -d $fullPath
            || $file !~ /\.conf$/
            || $fullPath eq realpath(LOG_CONFIG)
            || $fullPath eq realpath(SPECTRE_CONFIG) )
        {
            next;
        }
        push @configs, $fullPath;
    }
    return @configs;
} ## end sub siteConfigs

sub preloadPaths {
    my @paths;
    try {
        @paths = grep {
            (-d) ? 1 : do {
                warn "WARNING: Not adding lib directory '$path' from @{[PRELOAD_CUSTOM]}: Directory does not exist.\n";
                0;
            }
        } _readTextLines(PRELOAD_CUSTOM);
    };
    return @paths;
}

sub includePreloads {
    unshift @INC, preloadPaths();
}

sub preloadExclude {
    my @excludes = _readTextLines(PRELOAD_EXCLUDE);
    return @excludes;
}

sub preloadAll {
    require WebGUI::Pluggable;

    WebGUI::Pluggable::findAndLoad( 'WebGUI', {
        exclude     => \( preloadExclude() ),
        onLoadFail  => sub { warn sprintf 'Error loading %s: %s', @_ },
    });
}

no namespace::clean;

sub _readTextLines {
    my $file = shift;
    my @lines;
    open my $fh, '<', $file or croak "Cannot open $file: $!";
    while (my $line = <$fh>) {
        $line =~ s/#.*//;
        $line =~ s/^\s+//;
        $line =~ s/\s+$//;
        next
            if !$line;
        push @lines, $line;
    }
    return @lines;
}

use namespace::clean;

1;
