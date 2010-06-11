package WebGUI::Test::MockAsset;

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

Package WebGUI::Test::MockAsset

=head1 DESCRIPTION

Creates fake WebGUI::Asset objects and sets them up to be returned by WebGUI::Asset's normal constructors.

=head1 METHODS

=head2 new ( [ $class ], [ $id ] )

Creates a new mock asset.  If not specified, the class will default to L<WebGUI::Asset>.  In addition to the methods listed, it will also include all of the methods from L<Test::MockObject>.  The object will automatically be cleaned up and will no longer be returned once it goes out of scope.

=head2 mock_id ( $assetId, [ $asset_or_sub ] )

As an object method, sets the asset ID for the object, and also sets the asset to be returned for that ID.

As a class method, also accepts a second parameter.  If the second parameter is a sub, it will be called when the given asset ID is requested.  For any other type, the given object will be returned.

=head2 unmock_id ( [ $assetId ] )

As an object method, the mocking set up for the object by mock_id will be removed.

As a class method, mocking will be removed for the given asset ID.

=head2 mock_url ( $assetUrl, [ $asset_or_sub ] )

Works the same as mock_id, except for asset URLs instead of IDs.

=head2 unmock_url ( [ $assetUrl ] )

Works the same as unmock_id, except for asset URLs instead of IDs.

=cut

use strict;
use warnings;

use Test::MockObject::Extends;
use WebGUI::Asset;
use Package::Stash;
use Scalar::Util qw(weaken);

my $CLASS = __PACKAGE__;

my %mocked_assetIds;
my %mocked_assetUrls;

{
    my $asset_meta = WebGUI::Asset->meta;
    $asset_meta->make_mutable;
    for my $method (qw(newById newPending)) {
        $asset_meta->add_around_method_modifier($method, sub {
            my $orig = shift;
            my $assetId = $_[2];
            if ($assetId && exists $mocked_assetIds{$assetId}) {
                my $asset = $mocked_assetIds{$assetId};
                return $asset->()
                    if ref $asset eq 'CODE';
                return $asset;
            }
            goto $orig;
        });
    }
    for my $method (qw(newByUrl)) {
        $asset_meta->add_around_method_modifier($method, sub {
            my $orig = shift;
            my $assetUrl = $_[2];
            if ($assetUrl && exists $mocked_assetUrls{$assetUrl}) {
                my $asset = $mocked_assetUrls{$assetUrl};
                return $asset->()
                    if ref $asset eq 'CODE';
                return $asset;
            }
            goto $orig;
        });
    }
    $asset_meta->make_immutable;
}

sub new {
    my $class = shift;
    my $mock = shift;
    my $id = shift;

    $mock ||= 'WebGUI::Asset';
    $mock = Test::MockObject::Extends->new($mock);

    my $mocked_id;
    my $mocked_url;

    my @ns_path = map { $_ . '::' } split /::/, ref $mock;
    my $ns_last = pop @ns_path;
    my $ns_root = do {
        no strict 'refs';
        \%{ join('', @ns_path) };
    };

    my $stash = Package::Stash->new(ref $mock);
    $stash->add_package_symbol('&DESTROY', sub {
        my $self = shift;
        $self->unmock_id;
        $self->unmock_url;

        if ( my $super = $self->can('SUPER::DESTROY') ) {
            $self->$super;
        }

        undef $self;

        # remove our namespace
        delete $ns_root->{ $ns_last };
    });
    $stash->add_package_symbol('&mock_id', sub {
        my $self = shift;
        $self->unmock_id;
        $mocked_id = shift;
        $CLASS->mock_id($mocked_id, $self);

        $self->set_always('assetId', $mocked_id);
        $self->set_always('getId', $mocked_id);

        return $self;
    });
    $stash->add_package_symbol('&unmock_id', sub {
        my $self = shift;
        if ($mocked_id) {
            $CLASS->unmock_id($mocked_id);
        }
        return $self;
    });
    $stash->add_package_symbol('&mock_url', sub {
        my $self = shift;
        $self->unmock_url;
        $mocked_url = shift;
        $CLASS->mock_url($mocked_url, $self);

        $self->set_always('url', $mocked_url);

        return $self;
    });
    $stash->add_package_symbol('&unmock_url', sub {
        my $self = shift;
        if ($mocked_url) {
            $CLASS->unmock_url($mocked_url);
        }
        return $self;
    });

    return $mock;
}

sub mock_id {
    my $class = shift;
    my $id = shift;
    my $asset = shift;
    $mocked_assetIds{$id} = $asset;
    weaken $mocked_assetIds{$id};
    return;
}

sub unmock_id {
    my $class = shift;
    my $id = shift;
    delete $mocked_assetIds{$id};
    return;
}

sub mock_url {
    my $class = shift;
    my $url = shift;
    my $asset = shift;
    $mocked_assetUrls{$url} = $asset;
    weaken $mocked_assetUrls{$url};
    return;
}

sub unmock_url {
    my $class = shift;
    my $url = shift;
    delete $mocked_assetUrls{$url};
    return;
}

1;
