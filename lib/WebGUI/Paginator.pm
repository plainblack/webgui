package WebGUI::Paginator;

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
use WebGUI::International;
use WebGUI::Session;
use WebGUI::URL;

=head1 NAME

 Package WebGUI::Paginator

=head1 SYNOPSIS

 use WebGUI::Paginator;
 $p = WebGUI::Paginator->new("/index.pl/page_name?this=that",\@row);
 $html = $p->getBar;
 $html = $p->getBarAdvanced;
 $html = $p->getBarSimple;
 $html = $p->getBarTraditional;
 $html = $p->getFirstPageLink;
 $html = $p->getLastPageLink;
 $html = $p->getNextPageLink;
 $integer = $p->getNumberOfPages;
 $html = $p->getPage;
 $arrayRef = $p->getPageData;
 $integer = $p->getPageNumber;
 $html = $p->getPageLinks;
 $html = $p->getPreviousPageLink;

=head1 DESCRIPTION

 Package that paginates rows of arbitrary data for display on the web.

=head1 METHODS

 These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 getBar ( [ pageNumber ] )

 Returns the pagination bar including First, Previous, Next, and
 last links. If there's only one page, nothing is returned.

=item pageNumber
 
 Defaults to the page you're currently viewing. This is mostly here 
 as an override and probably has no real use.

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

 Defaults to the page you're currently viewing. This is mostly here
 as an override and probably has no real use.

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

 Defaults to the page you're currently viewing. This is mostly here
 as an override and probably has no real use.

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

 Defaults to the page you're currently viewing. This is mostly here
 as an override and probably has no real use.

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

 Defaults to the page you're currently viewing. This is mostly here
 as an override and probably has no real use.

=cut

sub getFirstPageLink {
        my ($text, $pn);
	$pn = $_[1] || $_[0]->getPageNumber;
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

 Defaults to the page you're currently viewing. This is mostly here
 as an override and probably has no real use.

=cut

sub getLastPageLink {
        my ($text, $pn);
	$pn = $_[1] || $_[0]->getPageNumber;
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

 Defaults to the page you're currently viewing. This is mostly here
 as an override and probably has no real use.

=cut

sub getNextPageLink {
        my ($text, $pn);
	$pn = $_[1] || $_[0]->getPageNumber;
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
	my $pageCount = int(($#{$_[0]->{_rowRef}}+1)/$_[0]->{_rpp});
	$pageCount++ unless (($#{$_[0]->{_rowRef}}+1)%$_[0]->{_rpp} == 0);
	return $pageCount;
}


#-------------------------------------------------------------------

=head2 getPage ( [ pageNumber ] )

 Returns the data from the page specified as a string. 

 NOTE: This is really only useful if you passed in an array reference
 of strings when you created this object.

=item pageNumber

 Defaults to the page you're currently viewing. This is mostly here
 as an override and probably has no real use.

=cut

sub getPage {
	return join("",@{$_[0]->getPageData($_[1])});
}


#-------------------------------------------------------------------

=head2 getPageData ( [ pageNumber ] )

 Returns the data from the page specified as an array reference.

=item pageNumber

 Defaults to the page you're currently viewing. This is mostly here
 as an override and probably has no real use.

=cut

sub getPageData {
	my ($i, @pageRows, $allRows, $pageCount, $pageNumber, $rowsPerPage, $pageStartRow, $pageEndRow);
        $pageNumber = $_[1] || $_[0]->getPageNumber;
        $pageCount = $_[0]->getNumberOfPages;
        return [] if ($pageNumber > $pageCount);
        $rowsPerPage = $_[0]->{_rpp};
        $pageStartRow = ($pageNumber*$rowsPerPage)-$rowsPerPage;
        $pageEndRow = $pageNumber*$rowsPerPage;
	$allRows = $_[0]->{_rowRef};
        for ($i=$pageStartRow; $i<$pageEndRow; $i++) {
		$pageRows[$i-$pageStartRow] = $allRows->[$i] if ($i <= $#{$_[0]->{_rowRef}});
        }
	return \@pageRows;
}

#-------------------------------------------------------------------

=head2 getPageNumber ( )

 Returns the current page number. If no page number can be found
 then it returns 1.

=cut

sub getPageNumber {
        return $session{form}{$_[0]->{_pn}} || 1;
}

#-------------------------------------------------------------------

=head2 getPageLinks ( [ pageNumber ] )

 Returns links to all pages in this paginator.

=item pageNumber

 Defaults to the page you're currently viewing. This is mostly here
 as an override and probably has no real use.

=cut

sub getPageLinks {
        my ($i, $output, $pn);
	$pn = $_[1] || $_[0]->getPageNumber;
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

 Defaults to the page you're currently viewing. This is mostly here
 as an override and probably has no real use.

=cut

sub getPreviousPageLink {
	my ($text, $pn);
	$pn = $_[1] || $_[0]->getPageNumber;
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
        bless {_url => $currentURL, _rpp => $rowsPerPage, _rowRef => $rowRef, _pn => $formVar}, $class;
}

#-------------------------------------------------------------------
sub setDataByQuery {
	my ($sth, $pageCount, $rowCount, $dbh, $sql, $self, @row, $data);
	($self, $sql, $dbh) = @_;
	$dbh |= $session{dbh};
	$sth = WebGUI::SQL->read($sql);
	$pageCount = 1;
	while ($data = $sth->hashRef) {
		$rowCount++;
		if ($rowCount/$self->{_rpp} > $pageCount) {	
			$pageCount++;
		}
		if ($pageCount == $self->getPageNumber) {
			push(@row,$data);	
		} else {
			push(@row,{});
		}
	}
	$sth->finish;
	$self->{_rowRef} = \@row;
}

1;


