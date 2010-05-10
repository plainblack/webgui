package WebGUI::Upgrade::Script;
use 5.010;
use strict;
use warnings;
use feature ();

use Sub::Exporter;
use WebGUI::Upgrade ();

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

    $caller_upgrade_file = (caller 0)[1];

    feature->import(':5.10');
    strict->import;
    warnings->import;
    warnings->unimport('uninitialized');
    $class->$exporter( $extra, @args );
}

my @cleanups;

sub _build_exports {
    my $configFile = $ENV{WEBGUI_CONFIG} || die 'WEBGUI_CONFIG environment variable must be specified';
    my $version    = $ENV{WEBGUI_UPGRADE_VERSION};
    my $quiet      = $ENV{WEBGUI_UPGRADE_QUIET};

    my $session;
    my $config;
    my $dbh;
    my $collateral;
    my $versionTag;
    my $upgrade_file = File::Spec->rel2abs( $caller_upgrade_file );

    my $subs;

    my $cleanup = sub {
        if ($session) {
            require WebGUI::VersionTag;
            if (WebGUI::VersionTag->getWorking($session, 'nocreate')) {
                $subs->{version_tag}->()->commit;
            }
            $session->var->end;
            $session->close;
        }
        undef $session;
        undef $versionTag;
    };
    my $cleanup_installed = 0;
    my $check_cleanup = sub {
        push @cleanups, $cleanup
            unless $cleanup_installed++;
    };

    $subs = {
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
        config => sub () {
            return $config
                if $config;
            $check_cleanup->();
            require WebGUI::Config;
            $config = WebGUI::Config->new($configFile, 1);
            return $config;
        },
        session => sub () {
            return $session
                if $session && ! $session->closed;

            $check_cleanup->();
            require WebGUI::Session;
            $session = WebGUI::Session->open($subs->{config}->());
            $session->user({userId => 3});
            return $session;
        },
        dbh => sub () {
            return $dbh
                if $dbh;

            $check_cleanup->();
            $dbh = WebGUI::Upgrade->dbhForConfig($subs->{config}->());
            return $dbh;
        },
        version_tag => sub (;$) {
            my $name = shift;
            $check_cleanup->();
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
            $versionTag = WebGUI::VersionTag->getWorking($subs->{session}->());
            $versionTag->set({name => "Upgrade to $version - $name"});
            return $versionTag;
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
        collateral => sub () {
            return $collateral
                if $collateral;
            (my $vol, my $dir, my $shortname) = File::Spec->splitpath( $upgrade_file );
            $shortname =~ s/\.[^.]*$//;
            my $path = File::Spec->catpath($vol, File::Spec->catdir($dir, $shortname), '');
            $collateral = Path::Class::Dir->new($path);
            return $collateral;
        },
        import_package => sub (@) {
            my $fullPath = $subs->{collateral}->()->file(@_);
            require WebGUI::Upgrade::File::wgpkg;
            WebGUI::Upgrade::File::wgpkg->import_package($subs->{session}->(), $fullPath);
        },
        root_asset => sub () {
            require WebGUI::Asset;
            return WebGUI::Asset->getRoot($subs->{session}->());
        },
        import_node => sub () {
            require WebGUI::Asset;
            return WebGUI::Asset->getImportNode($subs->{session}->());
        },
        asset => sub ($) {
            require WebGUI::Asset;
            my $session = $subs->session->();
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
    };
    return $subs;
}

sub cleanup_guard {
    my $class = shift;
    my @previous_cleanups = @cleanups;
    @cleanups = ();
    return Scope::Guard->new(sub {
        $class->cleanup;
        @cleanups = @previous_cleanups;
    });
}

sub cleanup {
    $_->() for @cleanups;
    @cleanups = ();
}

END {
    __PACKAGE__->cleanup;
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

=head1 METHODS

These methods are primarily of interest to someone wrapping an upgrade script.

=head2 cleanup

Performs all needed cleanup

=head2 cleanup_guard

Returns a guard object that when destroyed will run all of the cleanup
functions that have been added since it was created.

=cut
