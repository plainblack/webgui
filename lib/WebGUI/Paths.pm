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
use namespace::autoclean -also => qr/^_/;

=head1 NAME

Package WebGUI::Paths

=head1 DESCRIPTION

Locations for WebGUI files

=head1 METHODS

These methods are available from this class:

=cut

BEGIN {
    use Sub::Name qw(subname);
    my $root = realpath(catdir(
        catpath((splitpath(__FILE__))[0,1], ''), (updir) x 2
    ));
    my %paths = (
        configBase         => catdir($root, 'etc'),
        logConfig          => catfile($root, 'etc', 'log.conf'),
        spectreConfig      => catfile($root, 'etc', 'spectre.conf'),
        upgrades           => catfile($root, 'docs', 'upgrades'),
        preloadCustom      => catfile($root, 'sbin', 'preload.custom'),
        preloadExclusions  => catfile($root, 'sbin', 'preload.exclude'),
        extras             => catdir($root, 'www', 'extras'),
        defaultUploads     => catdir($root, 'www', 'uploads'),
        defaultCreateSQL   => catdir($root, 'docs', 'create.sql'),
        var                => catdir($root, 'var'),
    );
    for my $sub (keys %paths) {
        my $path = $paths{$sub};
        no strict 'refs';
        *{$sub} = subname $sub => sub () { $path };
    }
}

sub siteConfigs {
    my $class = shift;
    opendir my $dh, $class->configBase;
    my @configs;
    while ( my $file = readdir $dh ) {
        my $fullPath = realpath( catfile( $class->configBase, $file ) );
        if (   -d $fullPath
            || $file !~ /\.conf$/
            || $fullPath eq realpath($class->logConfig)
            || $fullPath eq realpath($class->spectreConfig) )
        {
            next;
        }
        push @configs, $fullPath;
    }
    return @configs;
} ## end sub siteConfigs

sub preloadPaths {
    my $class = shift;
    my @paths;
    try {
        @paths = grep {
            (-d) ? 1 : do {
                warn "WARNING: Not adding lib directory '$path' from @{[$class->preloadCustom]}: Directory does not exist.\n";
                0;
            }
        } _readTextLines($class->preloadCustom);
    };
    return @paths;
}

sub includePreloads {
    my $class = shift;
    unshift @INC, $class->preloadPaths;
}

sub preloadExclude {
    my $class = shift;
    my @excludes = _readTextLines($class->preloadExclude);
    return @excludes;
}

sub preloadAll {
    my $class = shift;
    require WebGUI::Pluggable;

    WebGUI::Pluggable::findAndLoad( 'WebGUI', {
        exclude     => \( $class->preloadExclude ),
        onLoadFail  => sub { warn sprintf 'Error loading %s: %s', @_ },
    });
}

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

1;
