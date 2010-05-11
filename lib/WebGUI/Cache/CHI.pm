package WebGUI::Cache::CHI;

use strict;
use base 'WebGUI::Cache';
use File::Temp qw/tempdir/;
use CHI;

=head1 NAME

WebGUI::Cache::CHI - CHI cache driver

=head1 DESCRIPTION

This is a WebGUI Cache driver to the CHI cache interface. This allows WebGUI
sites to use any CHI::Driver like FastMmap and Memcached

=head1 METHODS

=cut

#----------------------------------------------------------------------------

=head2 delete ( )

Delete the current key

=cut

sub delete {
    my ( $self ) = @_;
    return $self->{_chi}->remove( $self->{_key} );
}

#----------------------------------------------------------------------------

=head2 deleteChunk ( partialKey )

Delete multiple keys from the cache

=cut

sub deleteChunk {
    my ( $self, $key ) = @_;
    $key = $self->parseKey( $key );
    for my $checkKey ( $self->{_chi}->get_keys ) {
        if ( $checkKey =~ /^\Q$key/ ) {
            $self->{_chi}->remove( $checkKey );
        }
    }
}

#----------------------------------------------------------------------------

=head2 flush ( )

Delete the entire cache namespace

=cut

sub flush {
    my ( $self ) = @_;
    $self->{_chi}->clear;
}

#----------------------------------------------------------------------------

=head2 get ( )

Get the data in the current key

=cut

sub get {
    my ( $self ) = @_;
    return $self->{_chi}->get( $self->{_key} );
}

#----------------------------------------------------------------------------

=head2 new ( session, key [, namespace] )

Create a new WebGUI::Cache object with the given key. The namespace defaults
to the current site's configuration file name

=cut

sub new { 
    my ( $class, $session, $key, $namespace ) = @_;
    $namespace ||= $session->config->getFilename;
    $key    = $class->parseKey( $key );

    # Create CHI object from config
    my $chi;
    unless ( $chi = $session->stow->get( "CHI" ) ) {
        my $cacheConf    = $session->config->get('cache');
        $cacheConf->{namespace}     = $namespace;
        $cacheConf->{is_size_aware} = 1;

        # Default values
        my $resolveConf = sub {
            my ($config) = @_;
            if ( $config->{driver} =~ /DBI/ ) {
                $config->{ dbh } = $session->db->dbh;
            }
            if ( $config->{driver} =~ /File|FastMmap|BerkeleyDB/ ) {
                $config->{ root_dir } ||= tempdir();
            }
        };

        $resolveConf->( $cacheConf );
        if ( $cacheConf->{l1_cache} ) {
            $resolveConf->( $cacheConf->{l1_cache} );
        }

        $chi = CHI->new( %{$cacheConf} );
        $session->stow->set( "CHI", $chi );
    }

    return bless { _session => $session, _key => $key, _chi => $chi }, $class;
}

#----------------------------------------------------------------------------

=head2 set ( content [, ttl ] )

Set the content to the current key. ttl is the number of seconds the cache 
should live.

=cut

sub set {
    my ( $self, $content, $ttl ) = @_;
    $ttl ||= 60;
    $self->{_chi}->set( $self->{_key}, $content, $ttl );
    return;
}

#----------------------------------------------------------------------------

=head2 stats ( )

Get the size of the cache

=cut

sub stats {
    my ( $self ) = @_;
    return $self->{_chi}->get_size;
}


1;
