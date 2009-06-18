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
    my $self    = {};
	$self->{_session}    = $session;
    $self->{_counter}    = 1;
	bless $self, $class;
	return $self;
}

#-------------------------------------------------------------------

=head2 print ( $message )

Sends a message and increments the status bar.

=head3 $message

A message to be displayed in the status bar.

=cut

sub print {
	my $self    = shift;
	my $message = shift; ##JS string escaping?
    $self->session->log->preventDebugOutput;
    $self->{_counter} += 1;
    my $text = sprintf(<<EOJS, $self->{_counter}, $message);
<script>
parent.document.getElementById("progressMeter").style.width='%dpx';
parent.document.getElementById("progressStatus").innerHTML='%s'; 
</script>
EOJS
    $self->session->output->print($text);
    return '';
}

#-------------------------------------------------------------------

=head2 redirect ( $url )

Redirects the user out of the status page.

=head3 $url

The URL to send the user to.

=cut

sub redirect {
	my $self = shift;
	my $url  = shift;
    my $text = sprintf(<<EOJS, $url);
<script>
parent.location.href='%s';
</script>
EOJS
    $self->session->output->print($text);
    return '';
}

#-------------------------------------------------------------------

=head2 render ( $options )

Returns a templated progress bar implemented in CSS and JS.

=head3 options

A hashref of options to configure the progress bar

=head3 title

A title to display above the progress bar.

=head3 statusUrl

The URL that the progress bar should use to get status information.

=cut

sub render {
    my $self    = shift;
    my $options = shift;
    $self->session->http->setCacheControl("none");
    my %var      = %{ $options };
	$var{"icon"} = $self->{_icon};
    my $template = WebGUI::Asset::Template->new($self->session, 'YP9WaMPJHvCJl-YwrLVcPw');
    my $output   = $template->process(\%var);
    return $self->session->style->process($output,"PBtmpl0000000000000137");
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

=head2 setIcon ( icon )

Sets the _function icon to parameter.

=head3 icon

A string representing the location of the icon.

=cut

sub setIcon {
	my $self = shift;
	my $icon = shift;
	if ($icon) {
		$self->{_icon} = $icon;
	}
}


1;

