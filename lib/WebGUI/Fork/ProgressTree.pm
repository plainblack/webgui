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

=head1 SYNOPSIS

    package MyClass;

    # User has requested we do some work
    sub www_doWork {
        my ( $self ) = @_;

        # Get the assets that need work
        my @assetIds = ();

        # Start the fork with our "doWork" sub
        my $process = WebGUI::Fork->start(
            $self->session, 'MyClass', 'doWork',
            { assetIds => \@assetIds },
        );

        # Get the URL for a status page
        my $statusUrl = $process->contentPairs( 'ProgressTree', {
            title   => 'Doing Work',
            icon    => 'assets',
            proceed => '/home?message=Work%20Done',
        } );

        # Go to the status page
        $self->session->response->location( $statusUrl );
        return 'redirect';
    }

    # Do the work of our WebGUI::Fork
    sub doWork {
        my ( $process, $args ) = @_;
        # All the Assets we need to work on
        my $assetIds = $args->{ assetIds };

        # Build a tree and update process status
        my $tree = WebGUI::ProgressTree->new( $process->session, $assetIds );
        $process->update( sub { $tree->json } );

        # Do the actual work
        for my $id ( @$assetIds ) {
            # ... Do something

            # Update our tree and process again
            $tree->update( $id, "Done!" );
            $process->update( sub { $tree->json } );
        }
    }

=head1 SEE ALSO

=over 4

=item WebGUI::ProgressTree

Stores the data for the asset tree we are working on

=back

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
                YAHOO.util.Dom.addClass(li, 'focus');
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
                YAHOO.WebGUI.Fork.redirect(params);
            },
            error  : function (msg) {
                alert(msg)
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

sub handler {
    my $process = shift;
    my $session = $process->session;
    my $url     = $session->url;
    WebGUI::Fork::ProgressBar::renderBar($process, $template, {
            css => [ $url->extras('Fork/ProgressTree.css') ],
            js  => [ $url->extras('underscore/underscore-min.js') ],
        }
    );
}

1;
