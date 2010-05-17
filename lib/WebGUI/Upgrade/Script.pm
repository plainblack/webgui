package WebGUI::Upgrade::Script;
use 5.010;
use strict;
use warnings;
use feature ();

use Sub::Exporter;
use WebGUI::Upgrade ();
use Scope::Guard;
use Scalar::Util qw(weaken);

my $exporter = Sub::Exporter::build_exporter({
    groups => {
        default => \&_build_exports,
    },
});

my $caller_upgrade_file;
sub import {
    my ($class, @args) = @_;
    my $extra = shift @args if ref $args[0] eq 'HASH';
    $extra ||= {};
    if ( !$extra->{into} ) {
        $extra->{into_level} ||= 0;
        $extra->{into_level}++;
    }

    $caller_upgrade_file = File::Spec->rel2abs( (caller 0)[1] );

    feature->import(':5.10');
    strict->import;
    warnings->import;
    warnings->unimport('uninitialized');
    $class->$exporter( $extra, @args );
}

our @cleanups;

sub _build_exports {
    my $configFile = $ENV{WEBGUI_CONFIG} || die 'WEBGUI_CONFIG environment variable must be specified';
    my $version    = $ENV{WEBGUI_UPGRADE_VERSION} || die 'WEBGUI_UPGRADE_VERSION must be set';
    my $quiet      = $ENV{WEBGUI_UPGRADE_QUIET};

    my $session;
    my $config;
    my $dbh;
    my $collateral;
    my $versionTag;
    my $upgrade_file = $caller_upgrade_file;

    my $session_sub;
    my $config_sub;
    my $dbh_sub;
    my $collateral_sub;
    my $version_tag_sub;

    my $run_cleanup = 0;
    my $cleanup = sub {
        return
            if $run_cleanup++;
        if ($session) {
            require WebGUI::VersionTag;
            if (WebGUI::VersionTag->getWorking($session, 'nocreate')) {
                $version_tag_sub->()->commit;
            }
            $session->var->end;
            $session->close;
        }
        undef $session;
        undef $versionTag;
    };
    my $cleanup_guard = Scope::Guard->new( $cleanup );

    push @cleanups, $cleanup;
    weaken $cleanups[-1];

    $config_sub = sub () {
        return $config
            if $config;
        require WebGUI::Config;
        $config = WebGUI::Config->new($configFile, 1);
        return $config;
    },
    $session_sub = sub () {
        return $session
            if $session && ! $session->closed;

        require WebGUI::Session;
        $session = WebGUI::Session->open($config_sub->());
        $session->user({userId => 3});
        return $session;
    };
    $dbh_sub = sub () {
        return $dbh
            if $dbh;

        $dbh = WebGUI::Upgrade->dbhForConfig($config_sub->());
        return $dbh;
    };
    $version_tag_sub = sub (;$) {
        my $name = shift;
        require WebGUI::VersionTag;
        if ($versionTag) {
            if ($name) {
                $versionTag->commit;
            }
            elsif ( ! $versionTag->get('isCommitted') ) {
                return $versionTag;
            }
        }
        if (! $name) {
            no warnings 'uninitialized';
            (undef, undef, my $shortname) = File::Spec->splitpath($upgrade_file);
            $shortname =~ s/\.[^.]*$//;
            $name = $shortname;
        }
        $versionTag = WebGUI::VersionTag->getWorking($session_sub->());
        $versionTag->set({name => "Upgrade to $version - $name"});
        return $versionTag;
    };
    $collateral_sub = sub () {
        return $collateral
            if $collateral;
        (my $vol, my $dir, my $shortname) = File::Spec->splitpath( $upgrade_file );
        $shortname =~ s/\.[^.]*$//;
        my $path = File::Spec->catpath($vol, File::Spec->catdir($dir, $shortname), '');
        $collateral = Path::Class::Dir->new($path);
        return $collateral;
    };
    return {
        config      => $config_sub,
        session     => $session_sub,
        dbh         => $dbh_sub,
        version_tag => $version_tag_sub,
        collateral  => $collateral_sub,

        _cleanup => sub {
            undef $cleanup_guard;
        },
        quiet => sub () {
            return $quiet;
        },
        report => sub (@) {
            print @_
                unless $quiet;
        },
        done => sub () {
            print "Done.\n"
                unless $quiet;
        },
        sql => sub (@) {
            my $sql = shift;
            my $dbh = $dbh_sub->();
            my $sth = $dbh->prepare($sql);
            $sth->execute(@_);
        },
        rm_lib => sub (@) {
            my @modules = @_;
            for my $module (@modules) {
                $module =~ s{::}{/}g;
                $module .= '.pm';
                for my $inc (@INC) {
                    my $fullPath = File::Spec->catfile($inc, $module);
                    unlink $fullPath;
                }
            }
        },
        import_package => sub (@) {
            my $fullPath = $collateral_sub->()->file(@_);
            require WebGUI::Upgrade::File::wgpkg;
            WebGUI::Upgrade::File::wgpkg->import_package($session_sub->(), $fullPath);
        },
        root_asset => sub () {
            require WebGUI::Asset;
            return WebGUI::Asset->getRoot($session_sub->());
        },
        import_node => sub () {
            require WebGUI::Asset;
            return WebGUI::Asset->getImportNode($session_sub->());
        },
        asset => sub ($) {
            require WebGUI::Asset;
            my $session = $session_sub->();
            my $assetId = shift;
            my $asset;
            if ($session->id->valid($assetId)) {
                try {
                    $asset = WebGUI::Asset->newById($session, $assetId);
                };
            }
            if ( ! $asset ) {
                $asset = WebGUI::Asset->newByUrl($session, $assetId);
            }
            return $asset;
        },
        clear_cache => sub () {
            my $session = $session_sub->();
            my $cache = $session->cache;
            $cache->clear;
        },
    };
}

END {
    for (@cleanups) {
        next
            unless $_;
        $_->();
    }
}

1;

__END__

=head1 NAME

WebGUI::Upgrade::Script - Functions for WebGUI upgrade scripts

=head1 SYNOPSIS

    use WebGUI::Upgrade::Script;
    report "Performing upgrade...";
    config->set('config/item', 'new value');
    done;

=head1 DESCRIPTION

This module exports a number of functions to simplify upgrade scripts.  The
WEBGUI_CONFIG, WEBGUI_UPGRADE_VERSION, and WEBGUI_UPGRADE_QUIET variables
will be used to set up the subs.

In addition to the upgrade subs, it has a number of methods available to
code that is wrapping an upgrade script.

Some cleanup needs to be done after running an upgrade script.  This will
be done on program exit by default, but can also be managed manually with
the methods.

=head1 EXPORTED SUBROUTINES

=head2 quiet

Returns the value of the quiet flag.

=head2 report ( $message )

Outputs $message unless quiet mode has been enabled.

=head2 done

Reports that the current step has been completed.

=head2 config

Returns the WebGUI::Config object for the site.

=head2 session

Returns a session for the site.

=head2 dbh

Returns a database handle for the site's database.

=head2 version_tag ( [ $name ] )

If $name is specified, creates a new version tag with that name,
sets it as the active version tag, and returns it

If $name is not specified, returns the current working version tag,
creating it if needed.

The actual name of the version tag will automatically include a
note specifying that it is an upgrade version tag.

=head2 rm_lib ( $module )

Deletes the specified Perl module.  The module should be specified
as a colon separated name, and it will be removed from all include
paths.

=head2 collateral

Returns a Path::Class::Dir object for the upgrade script's collateral
path.  The collateral path is the same as the name of the upgrade
script with the extension stripped off.

=head2 import_package ( $package_file )

Imports the specified package from the upgrade script's collateral path.

=head2 root_asset

Returns the site's root asset.

=head2 import_node

Returns the site's import node.

=head2 asset ( $assetId_or_URL )

Returns an asset based on an asset ID or URL.

=cut
