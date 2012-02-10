package WebGUI::Template::Plugin::Asset;

use base 'Template::Plugin';
use WebGUI::Template::Proxy::Asset;

sub new {
    my $config = ref($_[-1]) eq 'HASH' ? pop(@_) : { };
    my ($class, $context, $asset) = @_;

    my $stash = $context->stash;
    my $session = $stash->{_session};

    if ( ref $asset) {
    }
    elsif ( defined $asset ) {
        $asset = $class->_getAsset($session, $asset);
    }
    elsif ( $stash->{_asset} ) {
        $asset = $stash->{_asset};
    }
    elsif ( $stash->{assetId} ) {
        $asset = $class->_getAsset($session, $stash->{assetId});
    }
    else {
        $asset = $session->asset;
    }

    return WebGUI::Template::Proxy::Asset->_new($context, $asset);
}

sub _getAsset {
    my ( $class, $session, $id ) = @_;
    my ( $asset );
    try {
        $asset = WebGUI::Asset->newByUrl( $session, $id );
    }
    catch {
        try {
            $asset = WebGUI::Asset->newById( $session, $id );
        }
        catch {
            die "Could not find asset $id to include in template: " . $_;
        };
    };
    return $asset;
}

1;

