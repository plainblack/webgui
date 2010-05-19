package WebGUI::Upgrade::Script;
use 5.010;
use strict;
use warnings;
use feature ();

use Sub::Exporter;
use Sub::Name;
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

    # save this in a lexical so _build_exports can pull it out
    $caller_upgrade_file = File::Spec->rel2abs( (caller 0)[1] );

    feature->import(':5.10');
    strict->import;
    warnings->import;
    warnings->unimport('uninitialized');
    $class->$exporter( $extra, @args );
}

my @cleanups;

sub _build_exports {
    my $configFile   = $ENV{WEBGUI_CONFIG} || die 'WEBGUI_CONFIG environment variable must be specified';
    my $version      = $ENV{WEBGUI_UPGRADE_VERSION} || die 'WEBGUI_UPGRADE_VERSION must be set';
    my $quiet        = $ENV{WEBGUI_UPGRADE_QUIET};
    my $upgrade_file = $caller_upgrade_file;
    (my $vol, my $dir, my $shortname) = File::Spec->splitpath( $upgrade_file );
    $shortname =~ s/\.[^.]*$//;

    # need to be able to reference these directly in the cleanup code
    my $session;
    my $versionTag;

    # these subs are kept separate so the others can call them
    my $config_sub = sub () {
        state $config = do {
            require WebGUI::Config;
            WebGUI::Config->new($configFile, 1);
        };
        return $config;
    };
    my $session_sub = sub () {
        return $session
            if $session && ! $session->closed;

        require WebGUI::Session;
        $session = WebGUI::Session->open($config_sub->());
        $session->user({userId => 3});
        return $session;
    };
    my $version_tag_sub = sub (;$) {
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
        $name ||= $shortname;
        $versionTag = WebGUI::VersionTag->getWorking($session_sub->());
        $versionTag->set({name => "Upgrade to $version - $name"});
        return $versionTag;
    };
    my $dbh_sub = sub () {
        state $dbh = do {
            WebGUI::Upgrade->dbhForConfig($config_sub->());
        };
        return $dbh;
    };
    my $collateral_sub = sub () {
        state $collateral = do {
            my $path = File::Spec->catpath($vol, File::Spec->catdir($dir, $shortname), '');
            Path::Class::Dir->new($path);
        };
        return $collateral;
    };

    my $cleanup = sub {
        state $has_run = 0;
        return
            if $has_run++;
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

    # we keep a weakened copy around.  this prevents us from keeping a
    # copy if the guard gets freed, but otherwise allows us to call it
    # manually in END.
    push @cleanups, $cleanup;
    weaken $cleanups[-1];

    my $subs = {
        # this closes over the guard, keeping it alive until the sub is either
        # run or deleted.  WebGUI::Upgrade::File::pl will end up deleting
        # the sub when it cleans up the temporary namespace it uses.
        _cleanup => sub {
            undef $cleanup_guard;
        },
        config      => $config_sub,
        session     => $session_sub,
        version_tag => $version_tag_sub,
        dbh         => $dbh_sub,
        collateral  => $collateral_sub,
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
    # give the subs some names to help with diagnostics
    my $sub_package = $shortname;
    $sub_package =~ s/\W//g;
    for my $sub_name ( keys %$subs ) {
        subname join('::', __PACKAGE__, $sub_package, $sub_name) => $subs->{$sub_name};
    }
    return $subs;
}

END {
    for my $cleanup (@cleanups) {
        # could be a weakened ref that went away
        next
            unless $cleanup;
        $cleanup->();
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
