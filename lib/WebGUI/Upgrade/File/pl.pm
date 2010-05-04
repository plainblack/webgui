package WebGUI::Upgrade::File::pl;
use 5.010;
use strict;
use warnings;

use WebGUI::Upgrade::Script ();
use Path::Class::Dir ();
use Try::Tiny;
use namespace::clean;

sub _runScript {
    my $file = shift;
    my @res;
    my $err;
    {
        local *_;
        my $guard = WebGUI::Upgrade::Script->cleanup_guard;
        # place this in a specific separate package to prevent namespace
        # pollution and to allow us to clean it up afterward
        package
            WebGUI::Upgrade::File::pl::script;
        # maintain context
        if (wantarray) {
            @res = do $file;
        }
        elsif (defined wantarray) {
            $res[0] = do $file;
        }
        else {
            do $file;
        }
        # save error as soon as possible
        $err = $@;
    }
    {
        # delete entire namespace that script was run in
        no strict 'refs';
        delete ${'WebGUI::Upgrade::File::pl::'}{'script::'};
    }
    die $@
        if $@;
    return (wantarray ? @res : $res[0]);
}

sub run {
    my $class = shift;
    my ($configFile, $version, $file, $quiet) = @_;

    local $ENV{WEBGUI_CONFIG}           = $configFile;
    local $ENV{WEBGUI_UPGRADE_VERSION}  = $version;
    local $ENV{WEBGUI_UPGRADE_QUIET}    = $quiet;
    return _runScript($file);
}

1;
