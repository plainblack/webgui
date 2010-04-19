package WebGUI::Operation::Cache;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::AdminConsole;
use WebGUI::International;
use WebGUI::Form;

=head1 NAME

Package WebGUI::Operation::Cache

=head1 DESCRIPTION

Operational handler for caching functions.

=cut

#-------------------------------------------------------------------

=head2 _submenu ( $workarea [,$title ] )

Internal subroutine for rendering output with an Admin Console.  Returns
the rendered output.

=head3 $workarea

The output that should be wrapped with an Admin Console.

=head3 $title

An optional title for the Admin Console.  If it evaluates to true,  the title
is looked up in the i18n table in the WebGUI namespace.

=cut

sub _submenu {
    my $session = shift;
    my $workarea = shift;
    my $title = shift;
    my $i18n = WebGUI::International->new($session);
    $title = $i18n->get($title) if ($title);
    my $ac = WebGUI::AdminConsole->new($session,"cache");
    if ($session->setting->get("trackPageStatistics")) {
        $ac->addSubmenuItem( $session->url->page('op=manageCache'), $i18n->get('manage cache'));
    }
    return $ac->render($workarea, $title);
}


#----------------------------------------------------------------------------

=head2 canView ( session [, user] )

Returns true if the user can use this Operation. user defaults to the current
user.

=cut

sub canView {
    my $session     = shift;
    my $user        = shift || $session->user;
    return $user->isInGroup( $session->setting->get("groupIdAdminCache") );
}

#-------------------------------------------------------------------

=head2 www_flushCache ( duration )


This method can be called directly, but is usually called from
www_manageCache. It flushes the cache.  Afterwards, it calls
www_manageCache.

=head3 duration

Text description of how long the subscription lasts.

=cut

sub www_flushCache {
    my $session     = shift;
    return $session->privilege->adminOnly unless canView($session);

    # Flush the cache
    $session->cache->flush;

    return www_manageCache($session);
}

#-------------------------------------------------------------------

=head2 www_manageCache ( )

Display information about the current cache type and cache statistics.  Also
provides an option to clear the cache.

=cut

sub www_manageCache {
    my $session     = shift;
    return $session->privilege->adminOnly unless canView($session);
    my $flushURL    = $session->url->page('op=flushCache');
    my $i18n        = WebGUI::International->new($session);
    my $output =
        WebGUI::Form::formHeader($session)
         .WebGUI::Form::button($session, {
            value   => $i18n->get("clear cache"),
            extras  => qq{onclick="document.location.href='$flushURL';"},
        }) 
         .WebGUI::Form::formFooter($session)
        ;

    return _submenu($session,$output);
}


1;

