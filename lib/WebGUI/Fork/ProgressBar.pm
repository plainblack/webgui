package WebGUI::Fork::ProgressBar;

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
use warnings;

=head1 NAME

WebGUI::Fork::ProgressBar

=head1 DESCRIPTION

Renders an admin console page that polls ::Status to draw a simple progress
bar along with some kind of message.

=head1 SUBROUTINES

These subroutines are available from this package:

=cut

use Template;
use HTML::Entities;
use JSON;

my $template = <<'TEMPLATE';
<p id='message'></p>
<div id='meter'></div>
<p>Time elapsed: <span id='elapsed'></span> seconds.</p>
<script>
(function (params) {
    var bar = new YAHOO.WebGUI.Fork.ProgressBar();
    YAHOO.util.Event.onDOMReady(function () {
        bar.render('meter');
        YAHOO.WebGUI.Fork.poll({
            url    : params.statusUrl,
            draw   : function (data) {
                var status = YAHOO.lang.JSON.parse(data.status);
                bar.update(status.finished, status.total);
                document.getElementById('message').innerHTML = status.message;
                document.getElementById('elapsed').innerHTML = data.elapsed;
            },
            finish : function() {
                YAHOO.WebGUI.Fork.redirect(params.redirect);
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

=head2 renderBar ( process, template )

Renders $template, passing a "params" variable to it that is JSON of a
statusUrl to poll and a page to redirect to. Includes WebGUI.Fork.redirect,
poll, and ProgressBar js and CSS (as well as all their YUI dependancies), and
puts the whole template inside an adminConsole rendered based off some form
parameters.

=cut

sub renderBar {
    my ( $process, $template ) = @_;
    my $session = $process->session;
    my $url     = $session->url;
    my $form    = $session->form;
    my $style   = $session->style;
    my $tt      = Template->new;
    my %vars    = (
        params => JSON::encode_json( {
                statusUrl => $url->page( $process->contentPairs('Status') ),
                redirect  => scalar $form->get('proceed'),
            }
        ),
    );
    $tt->process( \$template, \%vars, \my $content ) or die $tt->error;

    my $console = WebGUI::AdminConsole->new( $session, $form->get('icon') );
    $style->setLink( $url->extras("Fork/ProgressBar.css"), { rel => 'stylesheet' } );
    $style->setScript( $url->extras("$_.js") )
        for ( (
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
        );
    return $console->render( $content, encode_entities( $form->get('title') ) );
} ## end sub renderBar

1;
