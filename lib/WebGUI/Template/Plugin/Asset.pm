package WebGUI::Template::Plugin::Asset;

use base 'Template::Plugin';

sub new {
    my $config = ref($_[-1]) eq 'HASH' ? pop(@_) : { };
    my ($class, $context, $asset) = @_;

    my $stash = $context->stash;
    my $session = $stash->{_session};

    my $self = bless {
        _session => $session,
        _context => $context,
    }, $class;

    if ( ref $asset) {
    }
    elsif ( defined $asset ) {
        $asset = $self->_getAsset($asset);
    }
    elsif ( $stash->{_asset} ) {
        $asset = $stash->{_asset};
    }
    elsif ( $stash->{assetId} ) {
        $asset = $self->_getAsset($stash->{assetId});
    }
    else {
        $asset = $session->asset;
    }
    $self->{_asset} = $asset;

    my %properties = map { $_ => 1 } $asset->meta->get_all_properties_list;
    $self->{_callable} = \%properties;

    return $self;
}

sub _getAsset {
    my ( $self, $id ) = @_;
    my ( $asset );
    try {
        $asset = WebGUI::Asset->newByUrl( $self->session, $id );
    }
    catch {
        try {
            $asset = WebGUI::Asset->newById( $self->session, $id );
        }
        catch {
            die "Could not find asset $id to include in template: " . $_;
        };
    };
    return $asset;
}

sub DESTROY {
    # prevent AUTOLOADing
}

sub AUTOLOAD {
    my $sub = our $AUTOLOAD;
    $sub =~ s/.*:://;
    my $self = shift;
    if ($self->{_callable}{$sub}) {
        my $result = $self->{_asset}->();
        if ( eval { $result->isa('WebGUI::Asset'); 1 } ) {
            return $self->_wrap($result);
        }
        return $result;
    }
    die 'Not allowed to call ' . $sub;
}

sub _wrap {
    my $self = shift;
    my $wrap = shift;
    my $class = ref $self;
    return $class->new($self->{_context}, $wrap);
}

sub parent {
    my $self = shift;
    my $parent = $self->{_asset}->parentNode;
    return $self->_wrap($parent);
}

1;


