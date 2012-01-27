package WebGUI::Fork::ProgressBar;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2012 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use warnings;

=head1 NAME

WebGUI::Fork::ProgressBar

=head1 DESCRIPTION

Renders an admin console page that polls ::Status to draw a simple progress
bar along with some kind of message.

=head1 SYNOPSIS

    # Make our fork routine update our status
    sub doInFork {
        my ( $process, $args ) = @_;
        my $status = {
            message     => 'Starting up...',                # A message to the user
            total       => scalar @{$args->{stuffToDo}},    # How many tasks we have to do
            finished    => 0,                               # How many tasks we've done
        };
        $process->update( sub { JSON->new->encode( $status ) } );
            # Using a subref causes Fork to compute JSON only when needed

        for my $thing ( @{$args->{stuffToDo}} ) {
            # Do The work
            # ...

            # Update status
            $status->{finished}++;
            $process->update( sub { JSON->new->encode( $status ) } );
        }

        # All done!
        $process->finish;
    }

=head1 SUBROUTINES

These subroutines are available from this package:

=cut

use Template;
use HTML::Entities;
use JSON;
use URI;

my $blank = <<'TEMPLATE';
<html>
    <head>
        <title>[% title %]</title>
        [% FOREACH sheet IN stylesheets %]
        <link rel='stylesheet' href='[% sheet %]'></link>
        [% END %]
        [% FOREACH script IN scripts %]
        <script src='[% script %]'></script>
        [% END %]
    </head>
    <div><a href='[% bookmark.url %]'>[% bookmark.label %]</a></div>
    [% content %]
</html>
TEMPLATE

my $template = <<'TEMPLATE';
<div id='loading'>[% i18n('WebGUI', 'Loading...') %]</div>
<div id='ui' style='display: none'>
    <p id='message'></p>
    <div id='meter'></div>
    <p>
        [% i18n('Fork_ProgressBar', 'time elapsed') %]:
        <span id='elapsed'></span> [% i18n('Fork_ProgressBar', 'seconds') %].
    </p>
</div>
<script>
(function (params) {
    var bar = new YAHOO.WebGUI.Fork.ProgressBar();
    YAHOO.util.Event.onDOMReady(function () {
        bar.render('meter');
        YAHOO.WebGUI.Fork.poll({
            url    : params.statusUrl,
            draw   : function (data) {
                var status = YAHOO.lang.JSON.parse(data.status);
                bar.update(status.current, status.total);
                document.getElementById('message').innerHTML = status.message;
                document.getElementById('elapsed').innerHTML = data.elapsed;
            },
            first  : function () {
                document.getElementById('loading').style.display = 'none';
                document.getElementById('ui').style.display = 'block';
            },
            finish : function(data) {
                YAHOO.WebGUI.Fork.redirect(data.redirect || params.redirect);
            },
            error  : function (msg) {
                alert(msg);
            }
        });
    });
}([% params %]));
</script>
TEMPLATE

#-------------------------------------------------------------------

=head2 handler ( process )

See WebGUI::Operation::Fork.

=cut

sub handler { renderBar( shift, $template ) }

#-------------------------------------------------------------------

=head2 renderBar ( process, template, extras )

Renders $template, passing a "params" variable to it that is JSON of a
statusUrl to poll and a page to redirect to and an i18n function. Includes
WebGUI.Fork.redirect, poll, and ProgressBar js and CSS (as well as all their
YUI dependancies), and puts the whole template inside an adminConsole rendered
based off some form parameters. Extras is a hashref, optionally containing two
keys (css and js) which will be added to the page.

=cut

sub renderBar {
    my ( $process, $template, $extras ) = @_;
    my $session = $process->session;
    my $url     = $session->url;
    my $style   = $session->style;
    my $f       = $session->form->paramsHashRef;
    my $tt      = Template->new;
    my $dialog  = delete $f->{dialog};

    my %params  = (
        statusUrl => $url->page( $process->contentPairs('Status') ),
    );
    if ($dialog) {
        $params{message} = $f->{message};
    }
    else {
        $params{redirect} = $f->{proceed};
    }

    my %vars = (
        i18n   => sub {
            my ($namespace, $key) = @_;
            return WebGUI::International->new($session, $namespace)->get($key);
        },
        params => JSON::encode_json(\%params),
    );
    $tt->process( \$template, \%vars, \my $content ) or die $tt->error;

    my @sheets = (
        $url->extras("Fork/ProgressBar.css"),
        @{ $extras->{css} || []}
    );
    my @scripts = ( (
        map { $url->extras("$_.js") } (
            map {"yui/build/$_"}
            qw(
            yahoo/yahoo-min
            dom/dom-min
            json/json-min
            event/event-min
            connection/connection_core-min
            )
        ),
        'Fork/ProgressBar',
        'Fork/poll',
        'Fork/redirect'
        ),
        @{ $extras->{js} || []}
    );
    my $link  = URI->new($url->page);
    my $title = encode_entities( $f->{title} );
    my $label = 
        WebGUI::International->new( $session, 'Fork_ProgressBar' )
        ->get('link to this page');

    if ($dialog) {
        $link->query_form($f);
        my %vars = (
            content     => $content,
            scripts     => \@scripts,
            stylesheets => \@sheets,
            title       => $title,
            bookmark    => {
                url   => $link,
                label => $label,
            }
        );
        $tt->process( \$blank, \%vars, \my $styled ) or die $tt->error;
        return $styled;
    }
    else {
        $style->setLink($_, { rel => 'stylesheet' }) for @sheets;
        $style->setScript($_) for @scripts;
        if ( $session->var->isAdminOn ) {
            my $console = WebGUI::AdminConsole->new( $session, $f->{icon} );
            my $style   = $session->style;
            $link->query_form($f);
            $console->addSubmenuItem( $link->as_string, $label );
            return $console->render( $content, $title );
        }
        else {
            return $session->style->userStyle( $content );
        }
    }
} ## end sub renderBar

1;
