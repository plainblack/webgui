#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use FindBin;
use strict;
use lib "$FindBin::Bin/../lib";
use WebGUI::Test;
use WebGUI::Session;

# load your modules here

use Test::More;

my $session = WebGUI::Test->session;

## Test the url to path/file translation
my $index = "home.html";
my $urlMap = {
	'index.html'  	      => {
			  		path 	 => undef,
			  		filename => 'index.html',
			     	 },

	
	'index.html/'         => {
			 		path	 => undef,
			  		filename => 'index.html',
			     	 },

	'foo/page.html'       => {
					path 	 => 'foo',
					filename => 'page.html',
			     	},

	
	'foo'		      => {
					path	 => 'foo',
					filename => $index,
			     	 },

	'index.html/foo'      => {
					path	 => 'index.html/foo',
		 			filename => $index,
			     	 },

	'index.html/foo.html' => {
					path	 => 'index.html',
					filename => 'foo.html',
				 },
};

# two tests for each key in the urlMap hashRef plus any other tests that are added later.
plan tests => (0 + scalar(keys %{$urlMap}) * 2);

foreach my $urlToTest ( keys %{$urlMap} ) {
	my $expectedPath     = $urlMap->{$urlToTest}->{'path'};
	my $expectedFilename = $urlMap->{$urlToTest}->{'filename'};

	# we need a dummy asset to test this private method.
	my $asset = WebGUI::Asset->newByPropertyHashRef($session,{className=>'WebGUI::Asset'});

	# test this url
	my $dataRef = $asset->_translateUrlToPath($urlToTest, $index);
	my $returnedPath     = $dataRef->{'path'};
	my $returnedFilename = $dataRef->{'filename'};

	is ($returnedPath, $expectedPath, "path $expectedPath was returned for url $urlToTest");
	is ($returnedFilename, $expectedFilename, "filename $expectedFilename was returned for url $urlToTest");
}

## Test something else


