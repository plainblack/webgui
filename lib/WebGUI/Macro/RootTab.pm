package WebGUI::Macro::RootTab;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Navigation;
use WebGUI::Session;
use WebGUI::SQL;

#-------------------------------------------------------------------
sub _draw {
        my ($tree, $root) = @_;
        #my $output;# = '<table class="rootTab"><tr>';
        my $output;# = '<div class="rootTabs">';
        foreach my $key (keys %{$tree}) {
                $output .= ' <span class="';
                if ($root == $key) {
                        $output .= "rootTabOn";
                } else {
                        $output .= "rootTabOff";
                }
                $output .= '">';
                $output .= '<a href="'.$tree->{$key}{url}.'">'.$tree->{$key}{title}.'</a>';
                $output .= '</span> ';
        }
        #$output .= '</div>';
        #$output .= '</tr></table>';
        return $output;
}

#-------------------------------------------------------------------
sub _findRoot {
        my ($pageId,$parentId) = WebGUI::SQL->quickArray("select pageId,parentId from page where pageId=$_[0]");
        if ($parentId == 0) {
                return $pageId;
        } else {
                return _findRoot($parentId);
        }
}


#-------------------------------------------------------------------
sub process {
        my $root = _findRoot($session{page}{pageId});
        my $tree = WebGUI::Navigation::tree(0,1);
        return _draw($tree,$root);
}


1;

