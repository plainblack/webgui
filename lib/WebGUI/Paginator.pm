package WebGUI::Paginator;

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
use WebGUI::International;
use WebGUI::Utility;
use List::Util qw/min/;

=head1 NAME

Package WebGUI::Paginator

=head1 DESCRIPTION

Package that paginates rows of arbitrary data for display on the web.

=head1 SYNOPSIS

 use WebGUI::Paginator;
 $p = WebGUI::Paginator->new($self->session,$self->getUrl('thisParameter=thatValue'));
 $p->setDataByArrayRef(\@array);
 $p->setDataByQuery($sql);

 $p->appendTemplateVars($hashRef);
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
 $integer = $p->getRowCount;

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 _setDataByQuery ( query [, dbh, unconditional, placeholders, dynamicPageNumberKey, dynamicPageNumberValue ] )

Private method which retrieves a data set from a database and replaces whatever data set was passed in through the constructor.

This method should only ever be called by the public setDataByQuery method and is only called in the case that dynamicPageNumberKey is set.

The public setDataByQuery method is not capable of efficiently handling requests that dynamically set the page number by value
due to the fact that only one page of results is ever returned.   In this method, all the results are returned making this possible.

=head3 query

An SQL query that will retrieve a data set.

=head3 dbh

A WebGUI::SQL database handler. Defaults to the WebGUI site handler.

=head3 unconditional

A boolean indicating that the query should be read unconditionally. Defaults to "0". If set to "1" and the unconditional read results in an error, the error will be returned by this method.

=head3 placeholders

An array reference containing a list of values to be used in the placeholders defined in the SQL statement.

=head3 dynamicPageNumberKey

One of the field names being returned from this query. If this is set, the paginator will dynamically assign a page number based upon this key matching the dynamicPageNumberValue. Note that this only applies if the default page number is 1.

=head3 dynamicPageNumberValue

A value to match the dynamicPageNumberKey.

=cut

sub _setDataByQuery {
	my ($sth, $rowCount, @row);
	my ($self, $sql, $dbh, $unconditional, $placeholders, $dynamicPageNumberKey, $dynamicPageNumberValue) = @_;
    $dbh ||= $self->session->dbSlave;
	if ($unconditional) {
		$sth = $dbh->unconditionalRead($sql,$placeholders);
		return $sth->errorMessage if ($sth->errorCode > 0);
	} else {
		$sth = $dbh->read($sql,$placeholders);
	}
	my $defaultPageNumber = $self->getPageNumber;
	$self->{_columnNames} = [ $sth->getColumnNames ];  
	my $pageCount = 1;
	while (my $data = $sth->hashRef) {
		$rowCount++;
		if ($rowCount/$self->{_rpp} > $pageCount) {	
			$pageCount++;
		}
		if (defined $dynamicPageNumberKey && $defaultPageNumber == 1) {
			if ($data->{$dynamicPageNumberKey} eq $dynamicPageNumberValue) {
				$self->{_pn} = $pageCount;
				$dynamicPageNumberKey = undef;
			}
			push(@row,$data);
		} else {
			if ($pageCount == $self->getPageNumber) {
				push(@row,$data);	
			} else {
				push(@row,{});
			}
		}
	}
	$self->{_totalRows} = $sth->rows;
	$sth->finish;
	$self->{_rowRef} = \@row;
    #Purposely do not set $self->{_setByQuery} = 1 so the data is processed appropriately
	return "";
}

#-------------------------------------------------------------------

=head2 appendTemplateVars ( hashRef )

Adds paginator template vars to a hash reference.

=head3 hashRef

The hash reference to append the variables to.

=cut

sub appendTemplateVars {
	my $self = shift;
	my $var = shift;
	$var->{'pagination.isFirstPage'} = ($self->getPageNumber == 1);
	$var->{'pagination.isLastPage'} = ($self->getPageNumber == $self->getNumberOfPages);
	($var->{'pagination.firstPageUrl'},
	$var->{'pagination.firstPageText'},
	$var->{'pagination.firstPage'}) = $self->getFirstPageLink;
    
    ($var->{'pagination.lastPageUrl'},
    $var->{'pagination.lastPageText'},
	$var->{'pagination.lastPage'}) = $self->getLastPageLink;
	
	($var->{'pagination.nextPageUrl'},
	$var->{'pagination.nextPageText'},
	$var->{'pagination.nextPage'}) = $self->getNextPageLink;
	
	($var->{'pagination.previousPageUrl'},
	$var->{'pagination.previousPageText'},
	$var->{'pagination.previousPage'}) = $self->getPreviousPageLink;
	
	$var->{'pagination.pageNumber'} = $self->getPageNumber;
	$var->{'pagination.pageCount'} = $self->getNumberOfPages;
	$var->{'pagination.pageCount.isMultiple'} = ($self->getNumberOfPages > 1);
	($var->{'pagination.pageLoop'},$var->{'pagination.pageList'}) = $self->getPageLinks;
	($var->{'pagination.pageLoop.upTo10'},$var->{'pagination.pageList.upTo10'}) = $self->getPageLinks(10);
	($var->{'pagination.pageLoop.upTo20'},$var->{'pagination.pageList.upTo20'}) = $self->getPageLinks(20);
}


#-------------------------------------------------------------------

=head2 getBar ( )

Returns the pagination bar including First, Previous, Next, and last links. If there's only one page, nothing is returned.

=cut

sub getBar {
        my ($output);
        if ($_[0]->getNumberOfPages > 1) {
                $output = '<div class="pagination">';
                $output .= $_[0]->getFirstPageLink;
                $output .= ' &middot; ';
                $output .= $_[0]->getPreviousPageLink;
                $output .= ' &middot; ';
                $output .= $_[0]->getNextPageLink;
                $output .= ' &middot; ';
                $output .= $_[0]->getLastPageLink;
                $output .= '</div>';
                return $output;
        } else {
                return "";
        }
}


#-------------------------------------------------------------------

=head2 getBarAdvanced ( )

Returns the pagination bar including First, Previous, Page Numbers, Next, and Last links. If there's only one page, nothing is returned.

=cut

sub getBarAdvanced {
        my ($output);
        if ($_[0]->getNumberOfPages > 1) {
                $output = '<div class="pagination">';
                $output .= $_[0]->getFirstPageLink;
                $output .= ' &middot; ';
                $output .= $_[0]->getPreviousPageLink;
                $output .= ' &middot; ';
                $output .= $_[0]->getPageLinks;
                $output .= ' &middot; ';
                $output .= $_[0]->getNextPageLink;
                $output .= ' &middot; ';
                $output .= $_[0]->getLastPageLink;
                $output .= '</div>';
                return $output;
        } else {
                return "";
        }
}


#-------------------------------------------------------------------

=head2 getBarSimple ( )

Returns the pagination bar including only Previous and Next links. If there's only one page, nothing is returned.

=cut 

sub getBarSimple {
	my ($output);
	if ($_[0]->getNumberOfPages > 1) {
		$output = '<div class="pagination">';
		$output .= $_[0]->getPreviousPageLink;
		$output .= ' &middot; ';
		$output .= $_[0]->getNextPageLink;
		$output .= '</div>';
		return $output;
	} else {
		return "";
	}
}


#-------------------------------------------------------------------

=head2 getBarTraditional ( )

Returns the pagination bar including Previous, Page Numbers, and Next links. If there's only one page, nothing is returned.

=cut

sub getBarTraditional {
        my ($output);
        if ($_[0]->getNumberOfPages > 1) {
                $output = '<div class="pagination">';
                $output .= $_[0]->getPreviousPageLink;
                $output .= ' &middot; ';
                $output .= $_[0]->getPageLinks;
                $output .= ' &middot; ';
                $output .= $_[0]->getNextPageLink;
                $output .= '</div>';
                return $output;
        } else {
                return "";
        }
}


#-------------------------------------------------------------------

=head2 getColumnNames ( )

Returns an array containing the column names

=cut

sub getColumnNames {
    my $self = shift;
	if(ref $self->{_columnNames} eq 'ARRAY') {
		return @{$self->{_columnNames}};
	}
}


#-------------------------------------------------------------------

=head2 getFirstPageLink ( )

Returns a link to the first page's data.

=cut

sub getFirstPageLink {
	my ($self) = @_;
        my ($text, $pn, $ctext);
	$pn = $self->getPageNumber;
	my $i18n = WebGUI::International->new($self->session);
        $ctext = $i18n->get(404);
        $text = '|&lt;'.$ctext;
        if ($pn > 1) {
			my $url = $self->session->url->append($self->{_url},($self->{_formVar}.'=1'));
			return wantarray ? ($url,$ctext,'<a href="'.$url.'">'.$text.'</a>') : '<a href="'.$url.'">'.$text.'</a>';
        } else {
                return wantarray ? (undef,$ctext,$text) : $text;
        }
}


#-------------------------------------------------------------------

=head2 getLastPageLink (  )

Returns a link to the last page's data.

=cut

sub getLastPageLink {
	my ($self) = @_;
        my ($text, $pn, $ctext);
	$pn = $self->getPageNumber;
	my $i18n = WebGUI::International->new($self->session);
        $ctext = $i18n->get(405);
        $text = $ctext.'&gt;|';
        if ($pn != $self->getNumberOfPages) {
			my $url = $self->session->url->append($self->{_url},($self->{_formVar}.'='.$self->getNumberOfPages));
			return wantarray ? ($url,$ctext,'<a href="'.$url.'">'.$text.'</a>') : '<a href="'.$url.'">'.$text.'</a>';
        } else {
                return wantarray ? (undef,$ctext,$text) : $text;
        }
}


#-------------------------------------------------------------------

=head2 getNextPageLink (  )

Returns a link to the next page's data.

=cut

sub getNextPageLink {
    my ($self) = @_;
    my ($text, $pn, $ctext);
    $pn = $self->getPageNumber;
    my $i18n = WebGUI::International->new($self->session);
    $ctext = $i18n->get(92);
    $text = $ctext.'&raquo;';
    my $url = undef;
    if ($pn < $self->getNumberOfPages) {
        $url = $self->session->url->append($self->{_url},($self->{_formVar}.'='.($pn+1)));
        $text = '<span id="nextPageLink"><a href="'.$url.'">' . $text . '</a></span>';
    }
    return wantarray ? ($url, $ctext, $text) : $text;
}


#-------------------------------------------------------------------

=head2 getNumberOfPages ( )

Returns the number of pages in this paginator.

=cut

sub getNumberOfPages {
	my $self = shift;
    my $rowCount = $self->{_totalRows};
	my $pageCount = int($rowCount/$self->{_rpp});
	$pageCount++ unless ($rowCount % $self->{_rpp} == 0);
	return $pageCount;
}


#-------------------------------------------------------------------

=head2 getPage ( [ pageNumber ] )

Returns the data from the page specified as a string. 

B<NOTE:> This is really only useful if you passed in an array reference of strings when you created this object.

=head3 pageNumber

Defaults to the page you're currently viewing. This is mostly here as an override and probably has no real use.

=cut

sub getPage {
	return join("",@{$_[0]->getPageData($_[1])});
}


#-------------------------------------------------------------------

=head2 getPageData ( [ pageNumber ] )

Returns the data from the specified page as an array reference.

=head3 pageNumber

Defaults to the page you're currently viewing. This is mostly here as an override and probably has no real use.

=cut

sub getPageData {
    my $self       = shift;
    my $pageNumber = shift || $self->getPageNumber;
    my $allRows    = $self->{_rowRef};

    my $pageCount = $self->getNumberOfPages;
    return [] if ($pageNumber > $pageCount);

    if($self->{_setByQuery}) {
        #Return the cached page
        return $allRows if($pageNumber == $self->getPageNumber);
        return [];
    }

    #Handle setByArrayRef or the old setDataByQuery method
    my $rowsPerPage  = $self->{_rpp};
    my $pageStartRow = ($pageNumber*$rowsPerPage)-$rowsPerPage;
    my $pageEndRow   = min($pageNumber*$rowsPerPage, $#{$allRows}+1);
    my @pageRows     = ();
    for (my $i=$pageStartRow; $i<$pageEndRow; $i++) {
       $pageRows[$i-$pageStartRow] = $allRows->[$i] if ($i <= $#{$self->{_rowRef}});
    }
    return \@pageRows;
}

#-------------------------------------------------------------------

=head2 getPageIterator (  )

Returns the iterator that was created by setDataByCallback

=cut

sub getPageIterator {
    my $self = shift;
    return $self->{_iteratorObj};
}

#-------------------------------------------------------------------

=head2 getPageLinks ( [ limit ] )

Returns links to all pages in this paginator.

=head3 limit

An integer representing the maximum number of page links to return. By default, all page links will be returned.

=cut

sub getPageLinks {
	my $self = shift;
	my $limit = shift;
	my $pn = $self->getPageNumber;
	my @pages;
	my @pages_loop;
	for (my $i=0; $i<$self->getNumberOfPages; $i++) {
		my $altTag;
        my $first = $i * $self->{_rpp};
        my $last = (($i+1) * $self->{_rpp})-1;
        $last = $self->{_totalRows} - 1 if $last >= $self->{_totalRows};
		if ($self->{abKey}) {
			if ($self->{abInitialOnly}) {
				$altTag = ' title="'.substr($self->{_rowRef}[$first]->{$self->{abKey}},0,1).'-'.substr($self->{_rowRef}[$last]->{$self->{abKey}},0,1).'"';
			} else {
				$altTag = ' title="'.$self->{_rowRef}[$first]->{$self->{abKey}}.' - '.$self->{_rowRef}[$last]->{$self->{abKey}}.'"';
			}
		}
		if ($i+1 == $pn) {
			push @pages, $i+1;
			push @pages_loop, { 
                "pagination.url"        => '', 
                "pagination.text"       => $i+1,
                'pagination.range'      => ($first+1) . "-" . ($last+1),
                'pagination.activePage' => "true",
            };
		} else {
			push @pages, '<span><a href="'.$self->session->url->append($self->{_url},($self->{_formVar}.'='.($i+1))).'"'.$altTag.'>'.($i+1).'</a></span>';
			push @pages_loop, { 
                "pagination.url"    => $self->session->url->append($self->{_url},($self->{_formVar}.'='.($i+1))), 
                "pagination.text"   => $i+1,
                'pagination.range'  => ($first+1) . "-" . ($last+1),
            };
		}
	}
	if ($limit) {
		my $output;
		my $i = 1;
		my $minPage = $self->getPageNumber - round($limit/2);
		my $start = ($minPage > 0) ? $minPage : 1;
		my $maxPage = $start + $limit - 1;
		my $end = ($maxPage < $self->getPageNumber) ? $self->getPageNumber : $maxPage;
        if ($maxPage > $self->getNumberOfPages) {
            $end = $self->getNumberOfPages;
            $start = $self->getNumberOfPages - $limit + 1;
        }
		my @temp;
		foreach my $page (@pages) {
			if ($i <= $end && $i >= $start) {
				$output .= $page.' ';
				push(@temp, $pages_loop[$i-1]);
			}
			$i++;
		}
		return wantarray ? (\@temp,$output) : $output;
	} else {
		return wantarray ? (\@pages_loop,join(" ",@pages)) : join(" ",@pages);
	}
}


#-------------------------------------------------------------------

=head2 getPageNumber ( )

Returns the current page number. If no page number can be found then it returns 1.

=cut

sub getPageNumber {
        return $_[0]->{_pn};
}

#-------------------------------------------------------------------

=head2 getPreviousPageLink ( )

Returns a link to the previous page's data. 

=cut

sub getPreviousPageLink {
    my ($self) = @_;
    my ($text, $pn, $ctext);
    $pn = $self->getPageNumber;
    my $i18n = WebGUI::International->new($self->session);
    $ctext = $i18n->get(91);
    $text = '&laquo;'.$ctext;
    my $url = undef;
    if ($pn > 1) {
        $url = $self->session->url->append($self->{_url},($self->{_formVar}.'='.($pn-1)));
        $text = '<span id="previousPageLink"><a href="'.$url.'">'.$text.'</a></span>';
    }
    return wantarray ? ($url, $ctext, $text) : $text;
}


#-------------------------------------------------------------------

=head2 getRowCount ( )

Returns a count of the total number of rows in the paginator.

=cut

sub getRowCount {
	return $_[0]->{_totalRows};
}


#-------------------------------------------------------------------

=head2 new ( session, baseUrl [, paginateAfter, formVar, pageNumber ] )

Constructor.

=head3 session

A reference to the current session.

=head3 baseUrl

The URL of the current page including attributes. The page number will be appended to this in all links generated by the paginator.

=head3 paginateAfter

The number of rows to display per page. If left blank it defaults to 25.

=head3 formVar

Specify the form variable the paginator should use in its links.  Defaults to "pn".

=head3 pageNumber 

By default the page number will be determined by looking at $self->session->form->process("pn"). If that is empty the page number will be defaulted to "1". If you'd like to override the page number specify it here.

=cut

sub new {
    my $class       = shift;
    my $session     = shift;
    my $currentURL  = shift;
    my $rowsPerPage = shift || 25;
    my $formVar     = shift || "pn";
    my $pn          = shift || $session->form->process($formVar) || 1;
    bless {_session=>$session, _url => $currentURL, _rpp => $rowsPerPage, _formVar => $formVar, _pn => $pn}, $class;
}

#-------------------------------------------------------------------

=head2 session ( )

Returns a reference to the current session.

=cut

sub session {
	my $self = shift;
	$self->{_session};
}


#-------------------------------------------------------------------

=head2 setBaseUrl ( url ) 

Override the baseUrl set in the constructor.

=head3 url

The new URL.

=cut

sub setBaseUrl {
    my ($self, $url) = @_;
    $self->{_url} = $url;    
}


#-------------------------------------------------------------------

=head2 setDataByArrayRef ( arrayRef )

Provide the paginator with data by giving it an array reference.

=head3 arrayRef

The array reference that contains the data to be paginated.

=cut

sub setDataByArrayRef {
	my $self = shift;
	my $rowRef = shift;
	$self->{_rowRef} = $rowRef;
	$self->{_totalRows} = $#{$rowRef} + 1;
    $self->{_setByQuery} = 0;
}


#-------------------------------------------------------------------

=head2 setDataByCallback ( callback )

Provide the paginator with data by giving it a callback.  This interface does not support
having alphabetical keys ala C<setAlphabeticalKey> because the data is never stored in
the Paginator object.

=head3 callback

A callback to invoke that returns an iterator.  The callback method should
accept two optional parameters, an offset to start, and the rows per page
to return.  The iterator should return the total number of rows in
the query, without limits, when the first argument it is passed is 'rowCount'.

=cut

sub setDataByCallback {
	my $self     = shift;
	my $callback = shift;

    my $pageNumber  = $self->getPageNumber;
    my $rowsPerPage = $self->{_rpp};
    my $start       = ( ($pageNumber - 1) * $rowsPerPage );

    my $obj = $callback->($start, $rowsPerPage);
    $self->{_totalRows} = $obj->('rowCount');

    $self->{_iteratorObj}   = $obj;
    $self->{_setByQuery}    = 0;
    $self->{_setByArrayRef} = 0;
    $self->{_setByCallback} = 1;
    return '';
}


#-------------------------------------------------------------------

=head2 setDataByQuery ( query [, dbh, unconditional, placeholders, dynamicPageNumberKey, dynamicPageNumberValue ] )

Retrieves a data set from a database and replaces whatever data set was passed in through the constructor.

B<NOTE:> This retrieves only the current page's data for efficiency.

=head3 query

An SQL query that will retrieve a data set.

=head3 dbh

A WebGUI::SQL database handler. Defaults to the WebGUI site handler.

=head3 unconditional

A boolean indicating that the query should be read unconditionally. Defaults to "0". If set to "1" and the unconditional read results in an error, the error will be returned by this method.

=head3 placeholders

An array reference containing a list of values to be used in the placeholders defined in the SQL statement.

=head3 dynamicPageNumberKey

One of the field names being returned from this query. If this is set, the paginator will dynamically assign a page number based upon this key matching the dynamicPageNumberValue. Note that this only applies if the default page number is 1.

=head3 dynamicPageNumberValue

A value to match the dynamicPageNumberKey.

=cut

sub setDataByQuery {
    my $self = shift;
	my ($sql, $dbh, $unconditional, $placeholders, $dynamicPageNumberKey, $dynamicPageNumberValue) = @_;
    
    #Set paginator info
    my $pageNumber = $self->getPageNumber;
    my $rowsPerPage = $self->{_rpp};
    
	$dbh ||= $self->session->dbSlave;
    
    #Handle dynamicPageNumber requests or custom limits, or non-mysql the old way as it winds up being most efficient
    if ($dbh->getDriver ne 'mysql' || (defined $dynamicPageNumberKey && $pageNumber == 1) || $sql =~ m/limit/i) {
        return $self->_setDataByQuery(@_);
    }

    #Calculate where to start
    my $start = ( ($pageNumber - 1) * $rowsPerPage );
    
    #Set the query limits, but only for select queries
    if ($sql =~ s/^\s*SELECT\s/SELECT SQL_CALC_FOUND_ROWS /i) {
        $sql =~ s/;?\s*$/ LIMIT $start,$rowsPerPage/;
    }
    
    #$self->session->errorHandler->warn($sql);    
    #Get only the data necessary from the database
	my $sth;
	if ($unconditional) {
		$sth = $dbh->unconditionalRead($sql,$placeholders);
		return $sth->errorMessage if (defined $sth->errorCode);
	} else {
		$sth = $dbh->read($sql,$placeholders);
	}
    
    #Get total rows from last query
	($self->{_totalRows}) = $dbh->quickArray("select found_rows()");
	$self->{_columnNames} = [ $sth->getColumnNames ];
	
    my @row = ();
	while (my $data = $sth->hashRef) {
        push(@row,$data);	
    }
    
	$self->{_rowRef} = \@row;
    $self->{_setByQuery} = 1;
    $self->{_setByArrayRef} = 0;
	return "";
}

#-------------------------------------------------------------------

=head2 setAlphabeticalKey ( string, abInitialOnly )

Provide the paginator with a key of your data so it can display 
alphabetic helpers in the "alt" tag of the page links.  This only works well
when _all_ the data is provided to the Paginator.  This means that the
setDataByQuery and setDataByCallback methods cannot use this.

=head3 keyName

The name of the key your data is ordered by. This is assuming that
your pageData is an arrayRef of hashRefs.

=head3 abInitialOnly

A boolean indicating whether to abbreviate the key to the initial letter.

=cut

sub setAlphabeticalKey {
	my $self = shift;
	$self->{abKey} = shift;
	$self->{abInitialOnly} = shift;
	return 1;
}

#-------------------------------------------------------------------

=head2 setPageNumber ( pageNumber )

Sets the page number.  This is really a convenience method for testing.
Returns the page number that was set.

=head3 pageNumber

Sets the pageNumber.  Setting the pageNumber outside of the set of
pages would cause the Paginator to behave poorly.

=cut

sub setPageNumber {
	my $self = shift;
    $self->{_pn} = shift;
}

1;

