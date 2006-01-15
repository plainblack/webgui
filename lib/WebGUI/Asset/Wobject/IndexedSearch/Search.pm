package WebGUI::Asset::Wobject::IndexedSearch::Search;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2004 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
#use DBIx::FullTextSearch;
#use WebGUI::SQL;
#use WebGUI::HTML;
#use DBIx::FullTextSearch::StopList;
#use WebGUI::Utility;
#use HTML::Highlight;
#use WebGUI::Macro;

=head1 NAME

Package WebGUI::Wobject::IndexedSearch::Search

=head1 DESCRIPTION

Search implementation for WebGUI. 

=head1 SYNOPSIS

 use WebGUI::Wobject::IndexedSearch::Search;
 my $search = WebGUI::Wobject::IndexedSearch::Search->new();
 $search->indexDocument( { text => 'Index this text',
				  location => 'http://www.mysite.com/index.pl/faq#45',
				  languageId => 3,
				  namespace => 'FAQ'
				});
 my $hits = search->search("+foo -bar koo",{ namespace = ['Article', 'FAQ']} );
 
 $search->close;
			   

=head1 SEE ALSO

This package is an extension to DBIx::FullTextSearch and HTML::Highlight. 
See that packages for documentation of their methods.

=head1 METHODS

These methods are available from this package:

=cut

1;
