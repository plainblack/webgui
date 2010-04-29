package WebGUI::Cache::CHI;

use strict;
use base 'WebGUI::Cache';
use CHI;

sub delete {
    my ( $self ) = @_;
    return $self->{_chi}->remove( $self->{_key} );
}

sub deleteChunk {
    my ( $self, $key ) = @_;
    $key = $self->parseKey( $key );
    for my $checkKey ( $self->{_chi}->get_keys ) {
        if ( $checkKey =~ /^\Q$key/ ) {
            $self->{_chi}->remove( $checkKey );
        }
    }
}

sub flush {
    my ( $self ) = @_;
    $self->{_chi}->purge;
}

sub get {
    my ( $self ) = @_;
    return $self->{_chi}->get( $self->{_key} );
}

sub new { 
    my ( $class, $session, $key, $namespace ) = @_;
    my $namespace ||= $session->config->getFilename;
    $key    = $class->parseKey( $key );

    # Create CHI object from config
    my $chi;
    unless ( $chi = $session->stow->get( "CHI" ) ) {
        my $cacheConf    = $session->config->get('cache');
        $cacheConf->{namespace} = $namespace;

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

sub set {
    my ( $self, $content, $ttl ) = @_;
    $ttl ||= 60;
    $self->{_chi}->set( $self->{_key}, $content, $ttl );
    return;
}

sub stats {
    my ( $self ) = @_;
    return $self->{_chi}->get_size;
}


1;
