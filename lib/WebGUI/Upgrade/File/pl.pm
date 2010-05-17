package WebGUI::Upgrade::File::pl;
use 5.010;
use strict;
use warnings;

use WebGUI::Upgrade::Script ();
use Path::Class::Dir ();
use Try::Tiny;
use namespace::clean;
use Class::MOP;
use Class::MOP::Class;

sub _runScript {
    my $file = shift;
    my @res;
    my $err;
    {
        local $@;
        local *_;
        my $anon_class = Class::MOP::Class->create_anon_class;
        my $wanted = wantarray;
        eval sprintf(<<'END_CODE', $anon_class->name);
            # place this in a specific separate package to prevent namespace
            # pollution and to allow us to clean it up afterward
            package %s;
            # maintain context
            if ($wanted) {
                @res = do $file;
            }
            elsif (defined $wanted) {
                $res[0] = do $file;
            }
            else {
                do $file;
            }
            # save error as soon as possible
            $err = $@;
END_CODE
    }
    die $err
        if $err;
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
