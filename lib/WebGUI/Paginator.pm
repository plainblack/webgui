package WebGUI::Paginator;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2002 Plain Black Software.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use WebGUI::International;
use WebGUI::URL;

=head1 NAME

 Package WebGUI::Paginator

=head1 SYNOPSIS

 use WebGUI::Paginator;
 $p = WebGUI::Paginator->new("/index.pl/page_name?this=that",\@row);
 $p->getBar(2);
 $p->getBarAdvanced(2);
 $p->getBarSimple(2);
 $p->getBarTraditional(2);
 $p->getFirstPageLink(2);
 $p->getLastPageLink(2);
 $p->getNextPageLink(2);
 $p->getNumberOfPages;
 $p->getPage(2);
 $p->getPageLinks(2);
 $p->getPreviousPageLink(2);

=head1 DESCRIPTION

 Package that paginates rows of data for display on the web.

=head1 METHODS

 These methods are available from this class:

=cut


#-------------------------------------------------------------------
sub _generatePages {
	my (@page, $row, @rows, $rowRef, $pn, $i, $itemsPerPage);
	$rowRef = $_[0];
	@rows = @{$rowRef};
	$itemsPerPage = $_[1];
	foreach $row (@rows) {
		$page[$pn] .= $row;
		$i++;
		if ($i >= $itemsPerPage) {
			$i = 0;
			$pn++;
		}
	}
	return \@page;
}


#-------------------------------------------------------------------

=head2 getBar ( [ pageNumber ] )

 Returns the pagination bar including First, Previous, Next, and
 last links. If there's only one page, nothing is returned.

=item pageNumber

 The page number you're currently looking at. If omited, page one
 is assumed.

=cut

sub getBar {
        my ($output);
        if ($_[0]->getNumberOfPages > 1) {
                $output = '<div class="pagination">';
                $output .= $_[0]->getFirstPageLink($_[1]);
                $output .= ' &middot; ';
                $output .= $_[0]->getPreviousPageLink($_[1]);
                $output .= ' &middot; ';
                $output .= $_[0]->getNextPageLink($_[1]);
                $output .= ' &middot; ';
                $output .= $_[0]->getLastPageLink($_[1]);
                $output .= '</div>';
                return $output;
        } else {
                return "";
        }
}


#-------------------------------------------------------------------

=head2 getBarAdvanced ( [ pageNumber ] )

 Returns the pagination bar including First, Previous, Page Numbers,
 Next, and Last links. If there's only one page, nothing is 
 returned.

=item pageNumber

 The page number you're currently looking at. If omited, page one
 is assumed.

=cut

sub getBarAdvanced {
        my ($output);
        if ($_[0]->getNumberOfPages > 1) {
                $output = '<div class="pagination">';
                $output .= $_[0]->getFirstPageLink($_[1]);
                $output .= ' &middot; ';
                $output .= $_[0]->getPreviousPageLink($_[1]);
                $output .= ' &middot; ';
                $output .= $_[0]->getPageLinks($_[1]);
                $output .= ' &middot; ';
                $output .= $_[0]->getNextPageLink($_[1]);
                $output .= ' &middot; ';
                $output .= $_[0]->getLastPageLink($_[1]);
                $output .= '</div>';
                return $output;
        } else {
                return "";
        }
}


#-------------------------------------------------------------------

=head2 getBarSimple ( [ pageNumber ] )

 Returns the pagination bar including only Previous and Next links.
 If there's only one page, nothing is returned.

=item pageNumber

 The page number you're currently looking at. If omited, page one
 is assumed.

=cut 

sub getBarSimple {
	my ($output);
	if ($_[0]->getNumberOfPages > 1) {
		$output = '<div class="pagination">';
		$output .= $_[0]->getPreviousPageLink($_[1]);
		$output .= ' &middot; ';
		$output .= $_[0]->getNextPageLink($_[1]);
		$output .= '</div>';
		return $output;
	} else {
		return "";
	}
}


#-------------------------------------------------------------------

=head2 getBarTraditional ( [ pageNumber ] )

 Returns the pagination bar including Previous, Page Numbers,
 and Next links. If there's only one page, nothing is
 returned.

=item pageNumber

 The page number you're currently looking at. If omited, page one
 is assumed.

=cut

sub getBarTraditional {
        my ($output);
        if ($_[0]->getNumberOfPages > 1) {
                $output = '<div class="pagination">';
                $output .= $_[0]->getPreviousPageLink($_[1]);
                $output .= ' &middot; ';
                $output .= $_[0]->getPageLinks($_[1]);
                $output .= ' &middot; ';
                $output .= $_[0]->getNextPageLink($_[1]);
                $output .= '</div>';
                return $output;
        } else {
                return "";
        }
}


#-------------------------------------------------------------------

=head2 getFirstPageLink ( [ pageNumber ] )

 Returns a link to the first page's data.

=item pageNumber

 The page number you're currently looking at. If omited, page one
 is assumed.

=cut

sub getFirstPageLink {
        my ($text, $pn);
	$pn = $_[1] || 1;
        $text = '|&lt;'.WebGUI::International::get(404);
        if ($pn > 1) {
                return '<a href="'.
			WebGUI::URL::append($_[0]->{_url},($_[0]->{_pn}.'=1'))
			.'">'.$text.'</a>';
        } else {
                return $text;
        }
}


#-------------------------------------------------------------------

=head2 getLastPageLink ( [ pageNumber ] )

 Returns a link to the last page's data.

=item pageNumber

 The page number you're currently looking at. If omited, page one
 is assumed.

=cut

sub getLastPageLink {
        my ($text, $pn);
	$pn = $_[1] || 1;
        $text = WebGUI::International::get(405).'&gt;|';
        if ($pn != $_[0]->getNumberOfPages) {
                return '<a href="'.
			WebGUI::URL::append($_[0]->{_url},($_[0]->{_pn}.'='.$_[0]->getNumberOfPages))
			.'">'.$text.'</a>';
        } else {
                return $text;
        }
}


#-------------------------------------------------------------------

=head2 getNextPageLink ( [ pageNumber ] )

 Returns a link to the next page's data.

=item pageNumber

 The page number you're currently looking at. If omited, page one 
 is assumed.

=cut

sub getNextPageLink {
        my ($text, $pn);
	$pn = $_[1] || 1;
        $text = WebGUI::International::get(92).'&raquo;';
        if ($pn < $_[0]->getNumberOfPages) {
                return '<a href="'.WebGUI::URL::append($_[0]->{_url},($_[0]->{_pn}.'='.($pn+1))).'">'.$text.'</a>';
        } else {
                return $text;
        }
}


#-------------------------------------------------------------------

=head2 getNumberOfPages ( )

 Returns the number of pages in this paginator.

=cut

sub getNumberOfPages {
	return $#{$_[0]->{_pageRef}}+1;
}


#-------------------------------------------------------------------

=head2 getPage ( [ pageNumber ] )

 Returns the data from the page specified. 

=item pageNumber

 The page number you wish to view. If omitted, page one is assumed.

=cut

sub getPage {
        my ($pn);
	$pn = $_[1] || 1;
	return $_[0]->{_pageRef}[$pn-1];
}


#-------------------------------------------------------------------

=head2 getPageLinks ( [ pageNumber ] )

 Returns links to all pages in this paginator.

=item pageNumber

 The page number you're currently looking at. If omited, page one
 is assumed.

=cut

sub getPageLinks {
        my ($i, $output, $pn);
	$pn = $_[1] || 1;
	for ($i=0; $i<$_[0]->getNumberOfPages; $i++) {
		if ($i+1 == $pn) {
			$output .= ' '.($i+1).' ';
		} else {
			$output .= ' <a href="'.
				WebGUI::URL::append($_[0]->{_url},($_[0]->{_pn}.'='.($i+1)))
				.'">'.($i+1).'</a> ';
		}
	}
	return $output;
}


#-------------------------------------------------------------------

=head2 getPreviousPageLink ( [ pageNumber ] )

 Returns a link to the previous page's data. 

=item pageNumber

 The page number you're currently looking at. If omitted, page one
 is assumed.

=cut

sub getPreviousPageLink {
	my ($text, $pn);
	$pn = $_[1] || 1;
	$text = '&laquo;'.WebGUI::International::get(91);
	if ($pn > 1) {
		return '<a href="'.WebGUI::URL::append($_[0]->{_url},($_[0]->{_pn}.'='.($pn-1))).'">'.$text.'</a>';
        } else {
        	return $text;
        }
}


#-------------------------------------------------------------------

=head2 new ( currentURL, rowArrayRef [, paginateAfter, alternateFormVar ] )

 Constructor.

=item currentURL

 The URL of the current page including attributes. The page number
 will be appended to this in all links generated by the paginator.

=item rowArrayRef

 An array reference to all the rows of data for this page.

=item paginateAfter

 The number of rows to display per page. If left blank it defaults
 to 50.

=item alternateFormVar

 By default the paginator uses a form variable of "pn" to denote the
 page number. If you wish it to use some other variable, then specify
 it here.

=cut

sub new {
        my ($class, $currentURL, $rowsPerPage, $rowRef, $formVar, $pageRef);
	$class = shift;
	$currentURL = shift;
	$rowRef = shift;
	$rowsPerPage = shift || 25;
	$formVar = shift || "pn";
	$pageRef = _generatePages($rowRef,$rowsPerPage);
        bless {_url => $currentURL, _rpp => $rowsPerPage, _rowRef => $rowRef,
		_pn => $formVar, _pageRef => $pageRef}, $class;
}




1;


