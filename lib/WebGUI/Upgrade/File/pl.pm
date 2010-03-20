package WebGUI::Upgrade::File::pl;
use 5.010;
use strict;
use warnings;

use WebGUI::Upgrade ();
use WebGUI::Upgrade::File::wgpkg ();
use POSIX ();
use Path::Class::Dir ();
use Exporter qw(import);

sub _runCode {
    eval sprintf <<'END_CODE', $_[0], $_[1];
package WebGUI::Upgrade::File::pl::script;
use strict;
use warnings;
local @_;
local $_;
use WebGUI::Upgrade::File::pl qw(:script);
# line 1 "%s"
%s
;
use namespace::clean;
END_CODE
}
our @EXPORT_OK = qw(
    report
    done
    config
    session
    dbh
    version_tag
    rm_lib
    collateral
    import_package
);
our %EXPORT_TAGS = (
    script => \@EXPORT_OK,
);

my $configFile;
my $quiet;
my $version;
my $file;
my $session;
my $config;
my $dbh;
my $collateral;
my $versionTag;
sub run {
    my $class = shift;
    ($configFile, $version, $file, $quiet) = @_;
    ($session, $config, $dbh, $versionTag, $collateral) = undef;
    open my $fh, '<', $file;
    my $contents = do { local $/; <$fh> };
    close $fh;

    my @res;
    if (wantarray) {
        @res = _runCode($file, $contents);
    }
    else {
        $res[0] = _runCode($file, $contents);
    }

    my $error = $@;
    if ($session) {
        require WebGUI::VersionTag;
        if (WebGUI::VersionTag->getWorking($session, 'nocreate')) {
            version_tag()->commit;
        }
        $session->var->end;
        $session->close;
    }
    die $error
        if $error;
    return (wantarray ? @res : $res[0]);
}

sub report {
    print @_ unless $quiet;
}

sub done () {
    print "Done.\n" unless $quiet;
}

sub config () {
    require WebGUI::Config;
    $config ||= WebGUI::Config->new($configFile, 1);
    return $config;
}

sub session () {
    return $session
        if $session;

    require WebGUI::Session;
    $session = WebGUI::Session->open(config);
    $session->user({userId => 3});
    return $session;
}

sub dbh () {
    return $dbh
        if $dbh;

    $dbh = WebGUI::Upgrade->dbhForConfig(config);
    return $dbh;
}

sub version_tag {
    my $name = shift;
    require WebGUI::VersionTag;
    if ($versionTag) {
        if ($name) {
            $versionTag->commit;
        }
        else {
            return $versionTag;
        }
    }
    if (! $name) {
        (undef, undef, my $shortname) = File::Spec->splitpath($file);
        $shortname =~ s/\.[^.]*$//;
        $name = $shortname;
    }
    $versionTag = WebGUI::VersionTag->getWorking(session);
    $versionTag->set({name => "Upgrade to $version - $name"});
    return $versionTag;
}

sub rm_lib {
    my @modules = @_;
    for my $module (@modules) {
        $module =~ s{::}{/}g;
        $module .= '.pm';
        for my $inc (@INC) {
            my $fullPath = File::Spec->catfile($inc, $module);
            unlink $fullPath;
        }
    }
}

sub collateral () {
    if (! $collateral) {
        (my $vol, my $dir, my $shortname) = File::Spec->splitpath($file);
        $shortname =~ s/\.[^.]*$//;
        my $path = File::Spec->catpath($vol, File::Spec->catdir($dir, $shortname), '');
        $collateral = Path::Class::Dir->new($path);
    }
    return $collateral;
}

sub import_package {
    my $fullPath = collateral->file(@_);
    require WebGUI::Upgrade::File::wgpkg;
    WebGUI::Upgrade::File::wgpkg->import_package(session, $fullPath);
}

1;

