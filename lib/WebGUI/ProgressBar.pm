package WebGUI::ProgressBar;

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

=cut

use strict;

=head1 NAME

Package WebGUI::ProgressBar

=head1 DESCRIPTION

Render a progress bar for the user inside a nice style.

=head1 SYNOPSIS

 use WebGUI::ProgressBar;

 my $pb = WebGUI::ProgressBar->new($session);
 $pb->start($title, $iconUrl);
 $pb->update($message);
 $pb->finish($redirectUrl); 

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 new ( session )

Constructor.

=head3 session

A reference to the current session.

=cut

sub new {
	my $class   = shift;
	my $session = shift;
    my $recordCount = shift;
    my $self    = {};
	$self->{_session}    = $session;
    $self->{_counter}    = 1;
	bless $self, $class;
	return $self;
}

#-------------------------------------------------------------------

=head2 finish ( $url )

Redirects the user out of the status page.

=head3 $url

The URL to send the user to.

=cut

sub finish {
	my $self = shift;
	my $url  = shift;
    my $text = sprintf(<<EOJS, $url);
<script>
parent.location.href='%s';
</script>
EOJS
    local $| = 1;
    $self->session->output->print($text . $self->{_foot}, 1); # skipMacros
    return 'chunked';
}

#-------------------------------------------------------------------

=head2 session ( )

Returns a reference to the current session.

=cut

sub session {
	my $self = shift;
	return $self->{_session};
}

#-------------------------------------------------------------------

=head2 start ( title, icon )

Returns a templated progress bar implemented in CSS and JS.

=head3 title

A title to display above the progress bar.

=head3 icon

The url to the icon you want to display.

=cut

sub start {
    my ($self, $title, $icon) = @_;
    $self->session->http->setCacheControl("none");
    my %var      =  (
        title   => $title,
        icon    => $icon
        );
    my $template = WebGUI::Asset::Template->newById($self->session, 'YP9WaMPJHvCJl-YwrLVcPw');
    my $output = $self->session->style->process($template->process(\%var).'~~~', "PBtmpl0000000000000137");
    my ($head, $foot) = split '~~~', $output;
    local $| = 1; # Tell modperl not to buffer the output
    $self->session->http->sendHeader;
    $self->session->output->print($head, 1); #skipMacros
    $self->{_foot} = $foot;
    return '';
}

#-------------------------------------------------------------------

=head2 update ( $message )

Sends a message and increments the status bar.

=head3 $message

A message to be displayed in the status bar.

=cut

sub update {
	my $self    = shift;
	my $message = shift;
    $message    =~ s/'/\\'/g; ##Encode single quotes for JSON;
    $self->session->log->preventDebugOutput;
    $self->{_counter} += 1;
    
    my $modproxy_buffer_breaker = 'BUFFER BREAKER ' x 1000;
    my $text = sprintf(<<EOJS, $self->{_counter}, $message);
<script type="text/javascript">
/* $modproxy_buffer_breaker */
updateWgProgressBar('%dpx', '%s'); 
</script>
EOJS
    local $| = 1; # Tell modperl not to buffer the output
    $self->session->output->print($text, 1); #skipMacros
    if ($self->{_counter} > 600) {
        $self->{_counter} = 1;
    }
    return '';
}

1;

