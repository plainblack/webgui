package WebGUI::Fork::ProgressTree;

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

WebGUI::Fork::ProgressTree

=head1 DESCRIPTION

Renders an admin console page that polls ::Status to draw a friendly graphical
representation of how progress on a tree of assets is coming along.

=head1 SUBROUTINES

These subroutines are available from this package:

=cut

use Template;
use HTML::Entities;
use JSON;

my $template = <<'TEMPLATE';
<p>
<div id='meter'>
    <div id='meter-bar'>
        <div id='meter-text'></div>
    </div>
</div>
Current asset: <span id='focus'></span>
(<span id='finished'></span>/<span id='total'></span>).<br />
<span id='elapsed'></span> seconds elapsed.
<ul id='tree'></ul>
[% MACRO inc(file) BLOCK %]<script src="$extras/$file"></script>[% END %]
[% MACRO yui(file) BLOCK %][% inc("yui/build/$file") %][% END %]
[% yui("yahoo/yahoo-min.js") %]
[% yui("json/json-min.js") %]
[% yui("event/event-min.js") %]
[% yui("connection/connection_core-min.js") %]
[% inc("underscore/underscore-min.js") %]
<script>
(function (params) {
    var JSON = YAHOO.lang.JSON, statusUrl = params.statusUrl;

    function finish() {
        var redir = params.redirect;
        if (redir) {
            setTimeout(function() {
                // The idea here is to only allow local redirects
                var loc = window.location;
                loc.href = loc.protocol + '//' + loc.host + redir;
            }, 1000);
        }
    }
    function error(msg) {
        alert(msg);
    }
    function setHtml(id, html) {
        document.getElementById(id).innerHTML = html;
    }
    function draw(data) {
        var tree, finished = 0, total = 0, focus, pct;
        function recurse(asset, node) {
            var li = document.createElement('li'), txt, notes, ul, i;

            total += 1;

            txt = asset.url;
            if (asset.focus) {
                li.className += 'focus';
                focus = asset.url;
            }
            else if (asset.failure) {
                li.className = 'failure';
                txt += ' (' + asset.failure + ')';
                finished += 1;
            }
            else if (asset.success) {
                li.className = 'success';
                finished += 1;
            }
            li.appendChild(document.createTextNode(txt));
            if (notes = asset.notes) {
                _.each(notes, function (note) {
                    var p = document.createElement('p');
                    p.innerHTML = note;
                    li.appendChild(p);
                });
            }
            if (asset.children) {
                ul = document.createElement('ul');
                _.each(asset.children, function (child) {
                    recurse(child, ul);
                });
                li.appendChild(ul);
            }
            node.appendChild(li);
        }
        tree = document.getElementById('tree');
        tree.innerHTML = '';
        _.each(JSON.parse(data.status), function (root) {
            recurse(root, tree);
        });
        pct = Math.floor((finished/total)*100) + '%';

        setHtml('meter-text', pct);
        document.getElementById('meter-bar').style.width = pct;

        setHtml('total', total);
        setHtml('finished', finished);
        setHtml('focus', focus || 'nothing');
        setHtml('elapsed', data.elapsed);
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
                    finish();
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
}([% params %]));
</script>
TEMPLATE

my $stylesheet = <<'STYLESHEET';
<style>
#meter           { border: thin solid black; position: relative }
#meter-bar       { background-color: lime; font-size: 18pt;
                   height: 20pt; line-height: 20pt }
#meter-text      { position: absolute; top: 0; left: 0; width: 100%;
                   text-align: center }
#tree li         { color: black }
#tree li.focus   { color: cyan }
#tree li.failure { color: red }
#tree li.success { color: green }
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
    my $form    = $session->form;
    my $tt      = Template->new( { INTERPOLATE => 1 } );
    my %vars    = (
        params => JSON::encode_json( {
                statusUrl => $url->page( $process->contentPairs('Status') ),
                redirect  => scalar $form->get('proceed'),
            }
        ),
        extras => $url->extras,
    );
    $tt->process( \$template, \%vars, \my $content ) or die $tt->error;

    my $console = WebGUI::AdminConsole->new( $session, $form->get('icon') );
    $session->style->setRawHeadTags($stylesheet);
    return $console->render( $content, encode_entities( $form->get('title') ) );
} ## end sub handler

1;
