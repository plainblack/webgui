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

Utility module for making testing in WebGUI easier.

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
