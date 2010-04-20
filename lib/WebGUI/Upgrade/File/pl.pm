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
package
    WebGUI::Upgrade::File::pl::script;
use 5.010;
use strict;
use warnings;
no warnings 'uninitialized';
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
    quiet
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

=head2 quiet

Returns the value of the quiet flag.

=cut

sub quiet () {
    return $quiet;
}

=head2 report ( $message )

Outputs $message unless quiet mode has been enabled.

=cut

sub report {
    print @_ unless $quiet;
}

=head2 done

Reports that the current step has been completed.

=cut

sub done () {
    print "Done.\n" unless $quiet;
}

=head2 config

Returns the WebGUI::Config object for the site.

=cut

sub config () {
    require WebGUI::Config;
    $config ||= WebGUI::Config->new($configFile, 1);
    return $config;
}

=head2 session

Returns a session for the site.

=cut

sub session () {
    return $session
        if $session;

    require WebGUI::Session;
    $session = WebGUI::Session->open(config);
    $session->user({userId => 3});
    return $session;
}

=head2 dbh

Returns a database handle for the site's database.

=cut

sub dbh () {
    return $dbh
        if $dbh;

    $dbh = WebGUI::Upgrade->dbhForConfig(config);
    return $dbh;
}

=head2 version_tag ( [ $name ] )

If $name is specified, creates a new version tag with that name,
sets it as the active version tag, and returns it

If $name is not specified, returns the current working version tag,
creating it if needed.

The actual name of the version tag will automatically include a
note specifying that it is an upgrade version tag.

=cut

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

=head2 rm_lib ( $module )

Deletes the specified Perl module.  The module should be specified
as a colon separated name, and it will be removed from all include
paths.

=cut

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

=head2 collateral

Returns a Path::Class::Dir object for the upgrade script's collateral
path.  The collateral path is the same as the name of the upgrade
script with the extension stripped off.

=cut

sub collateral () {
    if (! $collateral) {
        (my $vol, my $dir, my $shortname) = File::Spec->splitpath($file);
        $shortname =~ s/\.[^.]*$//;
        my $path = File::Spec->catpath($vol, File::Spec->catdir($dir, $shortname), '');
        $collateral = Path::Class::Dir->new($path);
    }
    return $collateral;
}

=head2 import_package ( $package_file )

Imports the specified package from the upgrade script's collateral path.

=cut

sub import_package {
    my $fullPath = collateral->file(@_);
    require WebGUI::Upgrade::File::wgpkg;
    WebGUI::Upgrade::File::wgpkg->import_package(session, $fullPath);
}

1;

