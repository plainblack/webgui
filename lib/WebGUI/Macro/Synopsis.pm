package WebGUI::Macro::Synopsis;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2003 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;

#-------------------------------------------------------------------
sub traversePageTreeSynopsis {
	my ($sth, $output, $parent_id, $current_level, $max_level);
	($parent_id, $current_level, $max_level) = @_;
	$max_level = 99 unless ($max_level);
	if ($max_level && ($current_level >= $max_level)) {
		return;
	}
	 $sth = WebGUI::SQL->read("select urlizedTitle, menuTitle, pageId, synopsis, hideFromNavigation from page where parentId='$parent_id' order by sequenceNumber");
	while (my ($urltitle, $menutitle, $pageid, $synopsis, $hideFromNavigation) = $sth->array) {
		if (!WebGUI::Privilege::canViewPage($pageid) or $hideFromNavigation) {
			next;
		}
		$urltitle = WebGUI::URL::gateway($urltitle);
		my $subsynopsis = traversePageTreeSynopsis($pageid,$current_level+1,$max_level);
		$output .= qq{
			<div class="synopsis">
				<div class="synopsis_title">
					<a href="$urltitle">$menutitle</a>
				</div>
				<div class="synopsis_summary">
					$synopsis
				</div>
				<div class="synopsis_sub">
					$subsynopsis
				</div>
			</div>
		};
	}
        $sth->finish;
        return $output;
}


#-------------------------------------------------------------------
sub process {
	if ($_[0]) {
		return traversePageTreeSynopsis($session{page}{pageId},0,$_[0]);
	} else {
		return $session{page}{synopsis};
	}
}

1;


