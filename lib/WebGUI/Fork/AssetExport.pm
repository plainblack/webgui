package WebGUI::Fork::AssetExport;

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

WebGUI::Fork::AssetExport

=head1 DESCRIPTION

Renders an admin console page that polls ::Status to draw a friendly graphical
representation of how an export is coming along.

=head1 SUBROUTINES

These subroutines are available from this package:

=cut

use Template;

my $template = <<'TEMPLATE';
<p>
Currently exporting <span id='current'></span>
(<span id='finished'></span>/<span id='total'></span>).<br />
<span id='elapsed'></span> seconds elapsed.
</p>
<ul id='tree'></ul>
[% MACRO yui(file) BLOCK %]
<script src="$extras/yui/build/$file"></script>
[% END %]
[% yui("yahoo/yahoo-min.js") %]
[% yui("json/json-min.js") %]
[% yui("event/event-min.js") %]
[% yui("connection/connection_core-min.js") %]
<script>
(function (statusUrl) {
    var JSON = YAHOO.lang.JSON;
    function error(msg) {
        alert(msg);
    }
    function draw(data) {
        var ul, old, finished = 0, total = 0, current;
        function recurse(asset, node) {
            var li = document.createElement('li'), txt, notes, ul, i;

            total += 1;

            txt = asset.url;
            if (asset.current) {
                li.className += 'current';
                current = asset.url;
            }
            else if (asset.badUserPrivileges) {
                li.className = 'error';
                txt += ' (bad user privileges)';
                finished += 1;
            }
            else if (asset.notExportable) {
                li.className = 'error';
                txt += ' (not exportable)';
                finished += 1;
            }
            else if (asset.done) {
                li.className = 'done';
                finished += 1;
            }
            li.appendChild(document.createTextNode(txt));
            if (asset.collateralNotes) {
                notes = document.createElement('p');
                notes.innerHTML = asset.collateralNotes;
                li.appendChild(notes);
            }
            if (asset.children) {
                ul = document.createElement('ul');
                for (i = 0; i < asset.children.length; i += 1) {
                    recurse(asset.children[i], ul);
                    li.appendChild(ul);
                }
            }
            node.appendChild(li);
        }
        ul = document.createElement('ul');
        old = document.getElementById('tree');
        ul.id = old.id;
        recurse(JSON.parse(data.status), ul);
        old.parentNode.replaceChild(ul, old);
        document.getElementById('total').innerHTML = total;
        document.getElementById('finished').innerHTML = finished;
        document.getElementById('current').innerHTML = current || 'nothing';
        document.getElementById('elapsed').innerHTML = data.elapsed;
    }
    function fetch() {
        var callback = {
            success: function (o) {
                var data, status;
                if (o.status != 200) {
                    error("Server returned bad response");
                    return;
                }
                data = JSON.parse(o.responseText);
                if (data.error) {
                    error(data.error);
                }
                else if (data.finished) {
                    draw(data);
                }
                else {
                    draw(data);
                    setTimeout(fetch, 1000);
                }
            },
            failure: function (o) {
                error("Could not communicate with server");
            }
        };
        YAHOO.util.Connect.asyncRequest('GET', statusUrl, callback, null);
    }
    YAHOO.util.Event.onDOMReady(fetch);
}("$statusUrl"));
</script>
TEMPLATE

my $stylesheet = <<'STYLESHEET';
<style>
#tree li         { color: black }
#tree li.current { color: cyan }
#tree li.error   { color: red }
#tree li.done    { color: green }
</style>
STYLESHEET

#-------------------------------------------------------------------

=head2 handler ( process )

See WebGUI::Operation::Fork.

=cut

sub handler {
    my $process = shift;
    my $session = $process->session;
    my $url     = $session->url;
    my $tt      = Template->new( { INTERPOLATE => 1 } );
    my %vars    = (
        statusUrl => $url->page( $process->contentPairs('Status') ),
        extras    => $session->url->extras,
    );
    $tt->process( \$template, \%vars, \my $content ) or die $tt->error;

    my $console = WebGUI::AdminConsole->new( $process->session, 'assets' );
    $session->style->setRawHeadTags($stylesheet);
    my $i18n = WebGUI::International->new( $session, 'Asset' );
    return $console->render( $content, $i18n->get('Page Export Status') );
} ## end sub handler

1;
