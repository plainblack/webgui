
package HTML::Highlight;

use locale;

use strict;
use Carp;

BEGIN {
	use vars qw ($VERSION @ISA);
	$VERSION     = 0.20;
	@ISA         = ();
}

END { }

my $MIN_SECTION_LENGTH = 60;
my $DEFAULT_SECTION_LENGTH = 80;

sub new {
	$_ = shift;
	my $class = ref($_) || $_;

	croak ('HTML::Highlight - even number of parameters expected.')
		if (@_ % 2);	

	# set the defaults
	my $self = {
		words => [],
		wildcards => [],
		colors => [
		'#ffff66',
        '#A0FFFF',
        '#99ff99',
		'#ff9999',
		'#ff66ff'
		],
		czech_language => 0,
		debug => 0
	};

	bless ($self, $class);

	# get parameters, overiding the defaults
	for (my $i = 0; $i <= $#_; $i += 2)	{
		exists ( $self->{lc($_[$i])} ) or 
			croak ('HTML::Highlight - invalid parameter ' . $_[$i] . '.');
    	$self->{lc($_[$i])} = $_[($i + 1)];
	}

	croak ('HTML::Highlight - "words" and "wildcards" parameters must be references to arrays')
		if (ref($self->{words}) ne 'ARRAY' or ref($self->{wildcards}) ne 'ARRAY');

	require CzFast if ($self->{czech_language});

	return $self;
}


sub highlight {
	my $self = shift;
	my $document = shift;

	croak ('HTML::Highlight - no document defined')
		if (not defined($document));
	return '' if (length($document) == 0);

	my $doc = $document;

    for (my $i = 0, my $cindex = 0; $i < @{$self->{words}}; $i++, $cindex++) {
    	my $color;
        my $out;
		if ($self->{colors}->[$cindex]) {
			$color = $self->{colors}->[$cindex];
        }
        else {
			$cindex = 0;
			$color = $self->{colors}->[$cindex];
		}
        while($doc) {
            if ($doc !~ /(.*?)(<.*?>)(.*)/s) {
                $out .= $self->_highlight($doc, $i, $color);
                last;
            }
            else {
                my $str = $1;
                my $html = $2;
                my $rest = $3;
                $out .= $self->_highlight($str, $i, $color);
                $out .= $html;
                $doc = $rest;
            }
        }
        $doc = $out;
    }

return $doc;
}

sub preview_context {
	my $self = shift;
	my $document = shift;
	my $sectlen = shift;

	$self->{context} = {};
	$self->{sectlen} = $sectlen >= $MIN_SECTION_LENGTH ?
					   $sectlen : $DEFAULT_SECTION_LENGTH;
	$self->{sections} = [];

	$document =~ s/<.*?>//g;

	for (my $i = 0; $i < @{$self->{words}}; $i++) {
		my $pattern = $self->{czech_language} ?
					  &CzFast::czregexp($self->{words}->[$i]) :
					  $self->{words}->[$i];

        my $wildcard = $self->{wildcards}->[$i];
		my $regexp;

        if ($wildcard eq '%') {
			$regexp = "${pattern}\\w*";
		}
		elsif ($wildcard eq '*') {
			$regexp = "${pattern}s?";
		}
		else {
			$regexp = $pattern;
		}

		if (not $self->{context}->{$pattern}
        	and not grep (/$regexp/i, values %{$self->{context}})) {
			my $chars = int(($self->{sectlen} - length($pattern)) / 2);
			print "Chars: $chars\n" if ($self->{debug});
			if ($document =~ /(?:^|\W)(.{0,$chars})(\W+|^)($regexp)(\W+|$)(.{0,$chars})(?:\W|$)/si) {
				my $section = $1.$2.$3.$4.$5;
				$self->{context}->{$pattern} = $section;
				push(@{$self->{sections}}, $section);
			}
		}
	}

	return $self->{sections};
}

#########################
#### private methods ####
#########################

sub _highlight {
	my $self = shift;
	my $str = shift;
    my $word = shift;
	my $color = shift;

    my $pattern = $self->{words}->[$word];
	$pattern = &CzFast::czregexp($pattern) if ($self->{czech_language});

	my $wildcard = $self->{wildcards}->[$word];
	my $regexp;

    if ($wildcard eq '%') {
		my $pat = $self->{czech_language} ? &_cz_pattern : '\w*';
		$regexp = "${pattern}$pat";
	}
	elsif ($wildcard eq '*') {
		$regexp = "${pattern}s?";
	}
	else {
		$regexp = $pattern;
	}

	print "$str: $pattern | $wildcard | $regexp | $color\n" if ($self->{debug});
	$str =~ s!(\W+|^)($regexp)!$1<span style="background-color: $color">$2</span>!sig;
	return $str;
}

sub _cz_pattern {
	my @chars;
    my $pat = '(';
	foreach my $char ('a'..'z') {
		push(@chars, &CzFast::czregexp($char));
	}
	$pat .= join('|',@chars);
	$pat .= ')*';
	return $pat;
}


1;

__END__

=head1 NAME

B<HTML::Highlight - A module to highlight words or patterns in HTML documents>

=head1 SYNOPSIS

	use HTML::Highlight;

	# create the highlighter object
	
	my $hl = new HTML::Highlight (
		words => [
			'word',
			'any',
			'car',
			'some phrase'
		],
		wildcards => [
			undef,
			'%',
			'*',
			undef
		],
		colors => [
			'#FF0000',
			'red',
			'green',
			'rgb(255, 0, 0)'
		],
		czech_language => 0,
		debug => 0
	);

	# Remember that you don't need to specify your own colors.
	# The default colors should be optimal.

	# Now you can use the object to highlight patterns in a document
	# by passing content of the document to its highlight() method.
	# The highlighter object "remembers" its configuration.

	my $highlighted_document = $hl->highlight($document);


=head1 MOTIVATION

This module was originaly created to work together with fulltext
indexing module DBIx::TextIndex to highlight search results. 

A need for a highlighter that takes wildcard matches and HTML tags into
account and supports czech language (or other Slavic languages) was
the motivation to create this module.

=head1 DESCRIPTION

This module provides Google-like highlighting of words or patterns in HTML
documents. This feature is typically used to highlight search results.


=item The construcutor:

	my $hl = new HTML::Highlight (
		words => [],
		wildcards => [],
		colors => [],
		czech_language => 0,
		debug => 0
	);

This is a constructor of the highlighter object. It takes an array of 
even number of parameters.


The B<words> parameter is a reference to an array of words to highlight.

The B<wildcards> parameter is a reference to an array of wildcards, that
are applied to corresponding words in the B<words> array.

A wildcard can be either undef or one of '%' or '*'.

B<The "%" character> means "match any characters":

	"%" applied to 'car' ==> matches "car", "cars", "careful", ...


B<The "*" character> means "match also plural form of the word":

	"*" applied to 'car' ==> matches only "car" or "cars"


B<An undefined wildcard> means "match exactly the corresponding word":

	undefined wildcard applied to 'car' ==> matches only "car"

	
		
The B<colors> parameter is a reference to an array of CSS color
identificators, that are used to highlight the corresponding words in
the B<words> array.

Default Google-like colors are used if you don't specify your own
colors. Number of colors can be lower than number of words - in this case
the colors are rotated and some of the words are therefore
highlighted using the same color.

The highlighter takes HTML tags into account and therefore does not
"highlight" a word or a pattern inside a tag.

A support for diacritics insenstive matching for ISO-8859-2 languages (for
for example the czech language) can be activated using the B<czech_language>
option. This feature requires a module B<CzFast> that is available on CPAN in
a directory of author TRIPIE or at http://geocities.com/tripiecz/.

B<Your system's locales must be set correctly to use the
czech_language feature.>


=item highlight

	my $hl_document = $hl->highlight($document);

The only parameter is a document in that you want
to highlight the words that were passed to the constructor of the
highlighter object. The method returns a version of the document in which
the words are highlighted.


=item preview_context

	my $sections = $hl->preview_context($document, $num);


This method takes two parameters. The first one is the document you
want to scan for the words that were passed to the constructor of the
highlighter object. The second parameter is an optional integer
that specifies maximum number of characters in each of the context
sections (see below). This parameter defaults to 80
characters if it's not specified. Minimum allowed value of this 
parameter is 60.

The method returns a reference to an array of sections of the document
in which the words that were passed to the constructor appear. 
HTML tags are removed before the document is proccessed and are 
not present in the ouput. 
This feature is typically used in search engines to preview a context 
in which words from a search query appear in the resulting documents.
The words are always in the middle of each of the sections. The
number of sections this method returns is equal to the number of words
passed to the constructor of the highlighter object. 
That means only the first occurence of each of the words is taken into
account.

=head1 SUPPORT

No official support is provided, but I welcome any comments, patches
and suggestions on my email. 

=head1 BUGS

I am aware of no bugs.

=head1 AVAILABILITY

	http://geocities.com/tripiecz/

=head1 AUTHOR

B<Tomas Styblo>, tripie@cpan.org, CPAN-ID TRIPIE

Prague, the Czech republic

=head1 LICENSE

HTML::Highlight  - A module to highlight words or patterns in HTML documents

Copyright (C) 2000 Tomas Styblo (tripie@cpan.org)

This module is free software; you can redistribute it and/or modify it
under the terms of either:

a) the GNU General Public License as published by the Free Software
Foundation; either version 1, or (at your option) any later version,
or

b) the "Artistic License" which comes with this module.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See either
the GNU General Public License or the Artistic License for more details.

You should have received a copy of the Artistic License with this
module, in the file Artistic.  If not, I'll be glad to provide one.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
USA

=head1 SEE ALSO                                                                                                
                                                                                                               
perl(1).                                                                                                       

=cut
