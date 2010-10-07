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
use WebGUI::Fork::ProgressBar;

my $template = <<'TEMPLATE';
<div id='loading'>[% i18n('WebGUI', 'Loading...') %]</div>
<div id='ui' style='display: none'>
    <div id='meter'></div>
    [% i18n('Fork_ProgressBar', 'current asset') %]: <span id='focus'></span>
    (<span id='finished'></span>/<span id='total'></span>).<br />
    [% i18n('Fork_ProgressBar', 'time elapsed') %]: 
    <span id='elapsed'></span> 
    [% i18n('Fork_ProgressBar', 'seconds') %].
    <ul id='tree'></ul>
</div>
<script>
(function (params) {
    var bar = new YAHOO.WebGUI.Fork.ProgressBar();

    function setHtml(id, html) {
        document.getElementById(id).innerHTML = html;
    }
    function draw(data) {
        var tree, finished = 0, total = 0, focus, pct;
        function recurse(asset, node) {
            var li = document.createElement('li'), txt, notes, ul, i;

            total += 1;

            txt = asset.url;
            if (asset.success) {
                li.className = 'success';
                finished += 1;
            }
            else if (asset.failure) {
                li.className = 'failure';
                txt += ' (' + asset.failure + ')';
                finished += 1;
            }
            if (asset.focus) {
                li.className += 'focus';
                focus = asset.url;
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
        bar.update(finished, total);
        setHtml('total', total);
        setHtml('finished', finished);
        setHtml('focus', focus || 'nothing');
        setHtml('elapsed', data.elapsed);
    }
    YAHOO.util.Event.onDOMReady(function () {
        bar.render('meter');
        YAHOO.WebGUI.Fork.poll({
            url    : params.statusUrl,
            draw   : draw,
            first  : function () {
                document.getElementById('loading').style.display = 'none';
                document.getElementById('ui').style.display = 'block';
            },
            finish : function () {
                YAHOO.WebGUI.Fork.redirect(params.redirect);
            },
            error  : function (msg) {
                alert(msg)
            }
        });
    });
}([% params %]));
</script>
TEMPLATE

my $stylesheet = <<'STYLESHEET';
<style>
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
    my $style   = $session->style;
    my $url     = $session->url;
    $style->setRawHeadTags($stylesheet);
    $style->setScript($url->extras('underscore/underscore-min.js'));
    WebGUI::Fork::ProgressBar::renderBar($process, $template);
}

1;
