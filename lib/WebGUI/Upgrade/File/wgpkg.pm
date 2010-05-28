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

=head1 NAME

WebGUI::Upgrade::File::wgpkg - Upgrade class for WebGUI packages

=cut

package WebGUI::Upgrade::File::wgpkg;
use Moose;
with 'WebGUI::Upgrade::File';

use WebGUI::Asset;
use WebGUI::Session;
use WebGUI::Storage;
use WebGUI::VersionTag;
use File::Spec;
use Try::Tiny;
use namespace::clean;

sub run {
    my $self = shift;

    my $session = WebGUI::Session->open($self->configFile);
    $session->user({userId => 3});

    my $versionTag = WebGUI::VersionTag->getWorking($session);
    (undef, undef, my $shortname) = File::Spec->splitpath($self->file);
    $shortname =~ s/\.[^.]*$//;
    $versionTag->set({name => "Upgrade to @{[$self->version]} - $shortname"});

    my $package = $class->import_package($session, $self->file);
    if (! $self->quiet) {
        printf "\tImported '%s'\n", $package->title;
    }

    $versionTag->commit;
    $session->var->end;
    $session->close;

    return $package;
}

sub import_package {
    my $class = shift;
    my ($session, $file) = @_;

    # Make a storage location for the package
    my $storage = WebGUI::Storage->createTemp( $session );
    $storage->addFileFromFilesystem( $file );

    # Import the package into the import node
    my $package = try {
        my $node = WebGUI::Asset->getImportNode($session);
        $node->importPackage( $storage, {
            overwriteLatest    => 1,
            clearPackageFlag   => 1,
            setDefaultTemplate => 1,
        } );
    }
    catch {
        $storage->delete;
        die "Error during package import on $file: $_";
    };

    $storage->delete;

    if ($package eq 'corrupt') {
        die "Corrupt package found in $file.\n";
    }

    return $package;
}

__PACKAGE__->meta->make_immutable;
1;

