package WebGUI::Macro::Synopsis;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Session;


#-------------------------------------------------------------------
sub traversePageTreeSynopsis {
	my ($sth, $output, $parent_id, $current_level, $max_level);
	($parent_id, $current_level, $max_level) = @_;
	if ($max_level && ($current_level >= $max_level)) {
		return;
	}
	$sth = WebGUI::SQL->read("select urlizedTitle, menuTitle, pageId, synopsis from page where parentId='$parent_id' order by sequenceNumber");
	while (my ($urltitle, $menutitle, $pageid, $synopsis) = $sth->array) {
		if (!WebGUI::Privilege::canViewPage($pageid)) {
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
	my ($output) = @_;
	# Singleton
	if ($output =~ /\^Synopsis\;/) {
	        $output =~ s/\^Synopsis;/$session{page}{synopsis}/g;
		return $output;
	}
	# Tree
	$output =~ s/\^Synopsis\((\d+)\)\;/traversePageTreeSynopsis($session{page}{pageId},0,$1)/eg;
	return $output;
}

1;


