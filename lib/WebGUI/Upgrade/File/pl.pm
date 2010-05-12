package WebGUI::Upgrade::File::pl;
use 5.010;
use strict;
use warnings;

use WebGUI::Upgrade::Script ();
use Path::Class::Dir ();
use Try::Tiny;
use namespace::clean;

my $namespace = 0;
my $namespacePrefix = __PACKAGE__ . '::__ANON__::';
sub _runScript {
    my $file = shift;
    my @res;
    my $err;
    {
        local $@;
        local *_;
        my $guard = WebGUI::Upgrade::Script->cleanup_guard;
        my $wanted = wantarray;
        eval sprintf(<<'END_CODE', $namespacePrefix . $namespace);
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
    {
        # delete entire namespace that script was run in
        no strict 'refs';
        delete ${ $namespacePrefix }{ $namespace . '::' };
    }
    $namespace++;
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
