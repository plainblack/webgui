package WebGUI::Operation::Cache;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
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
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::Form;

#-------------------------------------------------------------------
sub _submenu {
	my $workarea = shift;
	my $title = shift;
	$title = WebGUI::International::get($title) if ($title);
	my $ac = WebGUI::AdminConsole->new("cache");
	if ($session{setting}{trackPageStatistics}) {
		$ac->addSubmenuItem( WebGUI::URL::page('op=manageCache'), WebGUI::International::get('manage cache'));
	}
        return $ac->render($workarea, $title);
}


#-------------------------------------------------------------------
sub www_flushCache {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	my $cache = WebGUI::Cache->new();
	$cache->flush;
	return www_manageCache();
}

#-------------------------------------------------------------------
sub www_manageCache {
        return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
        my ($output, $data);
	my $cache = WebGUI::Cache->new();
	my $flushURL =  WebGUI::URL::page('op=flushCache');
        $output .= '<table>';
        $output .= '<tr><td align="right" class="tableHeader">'.WebGUI::International::get('cache type').':</td><td class="tableData">'.ref($cache).'</td></tr>';
        $output .= '<tr><td align="right" valign="top" class="tableHeader">'.WebGUI::International::get('cache statistics').':</td><td class="tableData"><pre>'.$cache->stats.'</pre></td></tr>';
        $output .= '<tr><td align="right" valign="top" class="tableHeader">&nbsp;</td><td class="tableData">'.
			WebGUI::Form::button({
				value=>WebGUI::International::get("clear cache"),
				extras=>qq{onclick="document.location.href='$flushURL';"},
			}).
		   '</td></tr>';

	$output .= "</table>";
        return _submenu($output);
}


1;

