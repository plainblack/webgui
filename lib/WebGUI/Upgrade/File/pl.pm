package WebGUI::Upgrade::File::pl;
use 5.010;
use strict;
use warnings;

use WebGUI::Upgrade;
use POSIX ();

sub _runCode {
    eval sprintf <<'END_CODE', $_[0], $_[1];
use strict;
use warnings;
local @_;
local $_;
local *_runCode;
local *run;
# line 1 "%s"
%s
END_CODE
}

my $configFile;
my $quiet;
my $version;
my $file;
my $session;
my $config;
my $dbh;
my $versionTag;
sub run {
    my $class = shift;
    ($configFile, $version, $file, $quiet) = @_;
    ($session, $config, $dbh, $versionTag) = undef;
    open my $fh, '<', $file;
    my $contents = do { local $/; <$fh> };
    close $fh;
    _runCode($file, $contents);
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
    return 1;
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
    $session->user({user => 3});
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

1;

