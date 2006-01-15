package WebGUI::Operation::Cache;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::AdminConsole;
use WebGUI::Cache;
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


#-------------------------------------------------------------------

=head2 www_flushCache ( duration )


This method can be called directly, but is usually called from
www_manageCache. It flushes the cache.  Afterwards, it calls
www_manageCache.

=head3 duration

Text description of how long the subscription lasts.

=cut

sub www_flushCache {
	my $session = shift;
        return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));
	my $cache = WebGUI::Cache->new($session,);
	$cache->flush;
	return www_manageCache();
}

#-------------------------------------------------------------------

=head2 www_manageCache ( )

Display information about the current cache type and cache statistics.  Also
provides an option to clear the cache.

=cut

sub www_manageCache {
	my $session = shift;
        return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));
        my ($output, $data);
	my $cache = WebGUI::Cache->new($session);
	my $flushURL =  $session->url->page('op=flushCache');
	my $i18n = WebGUI::International->new($session);
        $output .= '<table>';
        $output .= '<tr><td align="right" class="tableHeader">'.$i18n->get('cache type').':</td><td class="tableData">'.ref($cache).'</td></tr>';
        $output .= '<tr><td align="right" valign="top" class="tableHeader">'.$i18n->get('cache statistics').':</td><td class="tableData"><pre>'.$cache->stats.'</pre></td></tr>';
        $output .= '<tr><td align="right" valign="top" class="tableHeader">&nbsp;</td><td class="tableData">'.
			WebGUI::Form::button($session,{
				value=>$i18n->get("clear cache"),
				extras=>qq{onclick="document.location.href='$flushURL';"},
			}).
		   '</td></tr>';

	$output .= "</table>";
        return _submenu($output);
}


1;

