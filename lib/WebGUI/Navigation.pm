package WebGUI::Navigation;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2002 Plain Black LLC.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut


use strict;
use Tie::CPHash;
use Tie::IxHash;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;


=head1 NAME

Package WebGUI::Navigation

=head1 SYNOPSIS

 use WebGUI::Navigation;
 $pageTree = WebGUI::Navigation::tree($pageParentId,$depthToTraverse);

 $html = WebGUI::Navigation::drawHorizontal($tree);
 $html = WebGUI::Navigation::drawVertical($tree);

=head1 DESCRIPTION

A package used to generate navigation.

=head1 METHODS

These methods are available from this package:

=cut

#-------------------------------------------------------------------

=head2 drawHorizontal ( tree [ , seperator, class ] )

Draws a vertical navigation system. Returns HTML.

=over

=item tree

The hash reference created by the tree method in this package.

=item seperator

A string containing HTML to seperate each navigation item. Defaults to "&middot;".

=item class

A stylesheet class for each link in the navigation. Defaults to "horizontalMenu".

=back

=cut

sub drawHorizontal {
        my ($output, $i, $pageId, $first);
        my ($tree, $seperator, $class) = @_;
        $class = "horizontalMenu" unless ($class);
	$seperator = $seperator || '&middot;';
	$first = 1;
        foreach $pageId (keys %{$tree}) {
		if ($first) {
			$first = 0;
		} else {
			$output .= ' '.$seperator.' ';
		}
                $output .= '<a class="'.$class.'" href="'.$tree->{$pageId}{url}.'">';
		if ($pageId == $session{page}{pageId}) {
                       $output .= '<span class="selectedMenuItem">'.$tree->{$pageId}{title}.'</span>';
		} else {
                       $output .= $tree->{$pageId}{title};
               	}
                $output .= '</a>';
        }
        return $output;
}

#-------------------------------------------------------------------

=head2 drawVertical ( tree [, bullet, class, spacing, indent ] )

Draws a vertical navigation system. Returns HTML.

=over

=item tree

The hash reference created by the tree method in this package.

=item bullet

A string containing HTML to generate a bullet that will be placed in front of each tree item. Defaults to none.

=item class

A stylesheet class for each link in the navigation. Defaults to "verticalMenu".

=item spacing

An integer with the linespacing for the navigation. Defaults to 1.

=item indent

An integer with the about of indenting to start with. Defaults to 0.

=back

=cut

sub drawVertical {
	my ($output, $i, $padding, $leading, $pageId);
	my ($tree, $bullet, $class, $spacing, $indent) = @_;
	$class = "verticalMenu" unless ($class);
	$spacing = 1 unless ($spacing);
        for ($i=1;$i<=$indent;$i++) {
                $padding .= "&nbsp;&nbsp;&nbsp;";
        }
        for ($i=1;$i<=$spacing;$i++) {
                $leading .= "<br>";
        }
	foreach $pageId (keys %{$tree}) {
		$output .= $padding.$bullet.'<a class="'.$class.'" href="'.$tree->{$pageId}{url}.'">';
                if ($pageId == $session{page}{pageId}) {
                       $output .= '<span class="selectedMenuItem">'.$tree->{$pageId}{title}.'</span>';
                } else {
                       $output .= $tree->{$pageId}{title};
                }
		$output .= '</a>'.$leading;
		$output .= drawVertical($tree->{$pageId}{sub}, $bullet, $class, $spacing, ($indent+1));
	}
        return $output;
}

#-------------------------------------------------------------------

=head2 tree ( parentId [, toLevel ] )

Generates and returns a hash reference containing a page tree with keys of "url", "title", and "sub" with orignating keys of page ids.  The tree looks like this:

 root
  |-pageId
  |  |-url
  |  |-title
  |  |-synopsis
  |  `-sub (pageId)
  |     |-url
  |     |-title
  |     |-synopsis
  |     `-sub (pageId)
  |        `-etc
  `-pageId
     `-etc

=over

=item parentId

The page id of where you'd like to start the tree.

=item toLevel

The depth the tree should be traversed. Defaults to "0". If set to "0" the entire tree will be traversed.

=back

=cut

sub tree {
        my ($sth, %data, %tree);
	tie %tree, 'Tie::IxHash';
	tie %data, 'Tie::CPHash';
	my ($parentId, $toLevel, $depth) = @_;
        $toLevel = 99 if ($toLevel > 100 || $toLevel < 1);
        if ($depth < $toLevel) {
                $sth = WebGUI::SQL->read("select urlizedTitle, menuTitle, pageId, synopsis from page 
			where parentId='$parentId' order by sequenceNumber");
                while (%data = $sth->hash) {
                        if (WebGUI::Privilege::canViewPage($data{pageId})) {
				$tree{$data{pageId}}{url} = WebGUI::URL::gateway($data{urlizedTitle}); 
				$tree{$data{pageId}}{title} = $data{menuTitle}; 
				$tree{$data{pageId}}{synopsis} = $data{synopsis}; 
                                $tree{$data{pageId}}{sub} = tree($data{pageId},$toLevel,($depth+1));
                        }
                }
                $sth->finish;
        }
        return \%tree;
}




1;


