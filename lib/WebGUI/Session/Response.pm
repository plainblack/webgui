package WebGUI::Session::Response;

use strict;
use warnings; 

use parent qw(Plack::Response);

use IO::File::WithPath;

use Plack::Util::Accessor qw(session streaming writer streamer);

=head1 SYNOPSIS

    my $session = WebGUI::Session->open(...);
    my $response = $session->response;

=head1 DESCRIPTION

WebGUI's PSGI response utility class. Sub-classes L<Plack::Response>.

An instance of this object is created automatically when the L<WebGUI::Session>
is created.

=cut

#
#
#

=head2 stream

=cut

sub stream {
    my $self = shift;
    $self->streamer(shift);
    $self->streaming(1);
}

#
#
#

=head2 stream_write

=cut

sub stream_write {
    my $self = shift;
    if (!$self->streaming) {
        Carp::carp("stream_write can only be called inside streaming response");
        return;
    }
    $self->writer->write(@_);
}

#
#
#

=head2 sendHeader ( )

Generates and sends HTTP headers for a response.

=cut

sub sendHeader {
	my $self = shift;
	return undef if $self->{_http}{noHeader};
	return $self->_sendMinimalHeader unless defined $self->session->db(1);

    no warnings 'uninitialized';

    my $session = $self->session;
	my ($request, $config) = $session->quick(qw(request config ));
	return undef unless $request;
	my $userId = $session->get("userId");
	
	# send webgui session cookie
	my $cookieName = $config->getCookieName;
	$self->setCookie($cookieName, $session->getId, $config->getCookieTTL, $config->get("cookieDomain")) unless $session->getId eq $request->cookies->{$cookieName};

	$self->setNoHeader(1);
	my %params;
	if (!$self->isRedirect()) {
		my $cacheControl = $self->getCacheControl;
		my $date = ($userId eq "1") ? HTTP::Date::time2str($self->getLastModified) : HTTP::Date::time2str();
		# under these circumstances, don't allow caching
		if ($userId ne "1" ||  $cacheControl eq "none" || $self->session->setting->get("preventProxyCache")) {
			$self->header(
                "Cache-Control" => "private, max-age=1", 
                "Pragma"        => "no-cache",
                "Cache-Control" => "no-cache",
            );
		} 
		# in all other cases, set cache, but tell it to ask us every time so we don't mess with recently logged in users
		else {
            if ( $cacheControl eq "none" ) {
                $self->header("Cache-Control" => "private, max-age=1");
            }
            else {
                $self->header(
                    'Last-Modified' => $date,
                    'Cache-Control' => "must-revalidate, max-age=" . $cacheControl,
                );
            }
			# do an extra incantation if the HTTP protocol is really old
			if ($request->protocol =~ /(\d\.\d)/ && $1 < 1.1) {
				my $date = HTTP::Date::time2str(time() + $cacheControl);
  				$self->header( 'Expires' => $date );
			}
  		}
	}
	return undef;
}

sub _sendMinimalHeader {
	my $self = shift;
	$self->content_type('text/html; charset=UTF-8');
	$self->header(
        'Cache-Control' => 'private',
        "Pragma"        => "no-cache",
        "Cache-Control" => "no-cache",
    );
	return undef;
}

#
#
#

=head2 setCookie ( name, value [ , timeToLive, domain ] )
       
Sends a cookie to the browser.
       
=head3 name
       
The name of the cookie to set. Must be unique from all other cookies from this domain or it will overwrite that cookie.
       
=head3 value
       
The value to set.
       
=head3 timeToLive
       
The time that the cookie should remain in the browser. Defaults to "+10y" (10 years from now).
This may be "session" to indicate that the cookie is for the current browser session only.
       
=head3 domain
       
Explicitly set the domain for this cookie.
    
=cut
   
sub setCookie {
    my $self = shift;
    my $name = shift;
    my $value = shift;
    my $ttl = shift;
    my $domain = shift;
    $ttl = (defined $ttl ? $ttl : '+10y');
       
    $self->cookies->{$name} = {
        value   => $value,
        path    => '/',
        expires => $ttl ne 'session' ? $ttl : undef,
        domain  => $domain,
    };
}   

#
#
#

=head2 setRedirect ( url, [ type ] )

Sets the necessary information in the HTTP header to redirect to another URL.

=head3 url

The URL to redirect to.  To prevent infinite loops, no redirect will be set if
url is the same as the current page, as found through $session->url->page.

=head3 type

Defaults to 302 (temporary redirect), but you can optionally set 301 (permanent redirect).

=cut

sub setRedirect {
    my $self = shift;
    my $url = shift || '';
    my $type = shift || 302;
    my @params = $self->session->form->param;
    return undef if ($url eq $self->session->url->page() && scalar(@params) < 1); # prevent redirecting to self
    $self->session->log->info("Redirecting to $url");
    $self->location($url);
    $self->status($type);
    $self->session->style->setMeta({"http-equiv"=>"refresh",content=>"0; URL=".$url});
}  

#
#
#

=head2 getLastModified ( )
 
Returns the stored epoch date when the page as last modified.
 
=cut
 
sub getLastModified {
    my $self = shift;
    return $self->{_http}{lastModified};
}  

#
#
#
 
=head2 setLastModified ( epoch )
 
=head3 epoch
 
The epoch date when the page was last modified.
 
=cut
 
sub setLastModified {
    my $self = shift;
    my $epoch = shift;
    $self->{_http}{lastModified} = $epoch;
}  

#
#
#
 
=head2 getNoHeader ( )
 
Returns whether or not a HTTP header will be printed.
 
=cut
 
sub getNoHeader {
    my $self = shift;
    return $self->{_http}{noHeader};
}

#
#
#
 
=head2 setNoHeader ( boolean )
 
Disables the printing of a HTTP header. Useful in situations when content is not
returned to a browser (export to disk for example).
 
=head3 boolean
 
Any value other than 0 will disable header printing.
 
=cut
 
sub setNoHeader {
    my $self = shift;
    $self->{_http}{noHeader} = shift;
}

#
#
#
 
=head2 isRedirect ( )
 
Returns a boolean value indicating whether the current page will redirect to some other location.
 
=cut
 
sub isRedirect {
    my $self = shift;
    my $status = $self->status;
    return $status == 302 || $status == 301;
}  

#
#
#

=head2 getStreamedFile ( ) {
 
Returns the location of a file to be streamed thru mod_perl, if one has been set.
 
=cut
 
sub getStreamedFile {
    my $self = shift;
    return $self->{_http}{streamlocation} || undef;
}  

#
#
#
 
=head2 setStreamedFile ( ) {
 
Set a file to be streamed thru mod_perl.
 
=cut

sub setStreamedFile {
    my $self = shift;
    my $fn = shift;
    $self->{_http}{streamlocation} = $fn;
    # $self->body( IO::File::WithPath->new( $fn ) );  # let Plack handle the streaming, or let Plack::Middleware::XSendfile punt it; we don't want to send a 302 header and send the file, too; should be one or the other, selectable
}

#
#
#

=head2 setCacheControl  ( timeout )

Sets the cache control headers.

=head3 timeout

Either the number of seconds until the cache expires, or the word "none" to disable cache completely for this request.
    
=cut
 
sub setCacheControl {
    my $self = shift;
    my $timeout = shift;
    $self->{_http}{cacheControl} = $timeout;
}
 
#
#
#

=head2 getCacheControl  ( )

Returns the cache control setting from this object.

=cut

sub getCacheControl {
    my $self = shift;
    return $self->{_http}{cacheControl} || 1;
}   

1;
