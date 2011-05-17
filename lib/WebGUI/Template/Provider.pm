package WebGUI::Template::Provider;

use strict;
use base 'Template::Provider';

use WebGUI::Asset;
use Try::Tiny;

=head1 NAME

WebGUI::Template::Provider - Allow WebGUI assets inside Templates

=head1 SYNOPSIS

    use Template;
    use WebGUI::Template::Provider;

    my $template = <<ENDHTML;
        [% INCLUDE asset:/asset/url %]
        [% INSERT template:TEMPLATE_ID %]
    ENDHTML

    my $provider = WebGUI::Template::Provider->new( $session );
    my $t = Template->new( LOAD_TEMPLATES => [ $provider ] );
    $t->process( $template, $vars );

=cut

sub new {
    my ( $class, $session, $options ) = @_;
    my $self = $class->SUPER::new( $options );
    $self->session( $session );
    return $self;
}

sub session {
    my ( $self, $newSession ) = @_;
    if ( $newSession ) {
        $self->{_session} = $newSession;
    }
    return $self->{_session};
}

sub _template_modified {
    my ( $self, $path ) = @_;
    if ( $path =~ /^(?:asset|template):(\S+)/ ) {
        my $id = $1;
        my $asset = $self->getAsset( $id );
        return $asset->getLastModified;
    }
    else {
        return $self->SUPER::_template_modified( @_[1..$#_] );
    }
}

sub _template_content {
    my ( $self, $path ) = @_;
    if ( $path =~ /^(asset|template):(\S+)/ ) {
        my $type = $1;
        my $id = $2;
        my $asset = eval { $self->getAsset( $id ) };
        if ( $@ ) {
            return wantarray ? ( "", $@, 0 ) : "";
        }

        my $content = $type eq 'template' ? $asset->template : $asset->view;
        return wantarray ? ( $content, "", $asset->getLastModified ) : $content;
    }
    else {
        return $self->SUPER::_template_content( @_[1..$#_] );
    }
}

sub getAsset {
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

1;
