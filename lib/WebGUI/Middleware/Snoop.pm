package WebGUI::Middleware::Snoop;
use strict;
use parent qw(Plack::Middleware);

=head1 NAME

WebGUI::Middleware::Snoop - sample middleware port of WebGUI::URL::Snoop

=head1 DESCRIPTION

This is PSGI middleware for WebGUI.

It was ported from L<WebGUI::URL::Snoop>, back when we still had URL handlers.

L<WebGUI::URL::Snoop> described itself as "A URL handler that should never be called."

You might find this middleware useful as a template for creating other simple classes.

=cut

sub call {
    my $self = shift;
    my $env  = shift;
    
    my $path = $env->{PATH_INFO};
    if ($path =~ qr{^/abcdefghijklmnopqrstuvwxyz$}) {
        my $snoop = q|<html><head><title>Snoopy</title></head><body><div style="width: 600px; padding: 200px;">&#87;&#104;&#121;&#32;&#119;&#111;&#117;&#108;&#100;&#32;&#121;&#111;&#117;&#32;&#116;&#121;&#112;&#101;&#32;&#105;&#110;&#32;&#116;&#104;&#105;&#115;&#32;&#85;&#82;&#76;&#63;&#32;&#82;&#101;&#97;&#108;&#108;&#121;&#46;&#32;&#87;&#104;&#97;&#116;&#32;&#119;&#101;&#114;&#101;&#32;&#121;&#111;&#117;&#32;&#101;&#120;&#112;&#101;&#99;&#116;&#105;&#110;&#103;&#32;&#116;&#111;&#32;&#115;&#101;&#101;&#32;&#104;&#101;&#114;&#101;&#63;&#32;&#89;&#111;&#117;&#32;&#114;&#101;&#97;&#108;&#108;&#121;&#32;&#110;&#101;&#101;&#100;&#32;&#116;&#111;&#32;&#103;&#101;&#116;&#32;&#97;&#32;&#108;&#105;&#102;&#101;&#46;&#32;&#65;&#114;&#101;&#32;&#121;&#111;&#117;&#32;&#115;&#116;&#105;&#108;&#108;&#32;&#104;&#101;&#114;&#101;&#63;&#32;&#83;&#101;&#114;&#105;&#111;&#117;&#115;&#108;&#121;&#44;&#32;&#121;&#111;&#117;&#32;&#110;&#101;&#101;&#100;&#32;&#116;&#111;&#32;&#103;&#111;&#32;&#100;&#111;&#32;&#115;&#111;&#109;&#101;&#116;&#104;&#105;&#110;&#103;&#32;&#101;&#108;&#115;&#101;&#46;&#32;&#73;&#32;&#116;&#104;&#105;&#110;&#107;&#32;&#121;&#111;&#117;&#114;&#32;&#98;&#111;&#115;&#115;&#32;&#105;&#115;&#32;&#99;&#97;&#108;&#108;&#105;&#110;&#103;&#46;</div></body></html>|;
        return [ 200, [ 'Content-Type' => 'text/html' ], [ $snoop ] ];
    } else {
        return $self->app->($env);
    }
}

1;