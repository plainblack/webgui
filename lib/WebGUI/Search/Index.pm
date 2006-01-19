package WebGUI::Search::Index;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2006 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use warnings;
use Plucene::Analysis::SimpleAnalyzer;
use Plucene::Document;
use Plucene::Document::Field;
use Plucene::Index::Reader;
use Plucene::Index::Writer;
use Plucene::Index::Term;
use File::Spec::Functions qw(catfile);
use WebGUI::Utility;

=head1 NAME

Package WebGUI::Search::Index

=head1 DESCRIPTION

A package for working with the WebGUI Search Engine.

=head1 SYNOPSIS

 use WebGUI::Search::Index;

=head1 METHODS

These methods are available from this package:

=cut


#-------------------------------------------------------------------

=head2 addDate ( key, epoch )

Adds a date field to the index which may later be used to search on date ranges.

=head3 key

A unique label to store this data.

=head3 epoch

A date represented as the number of seconds since January 1, 1970.

=cut

sub addDate {
	my $self = shift;
	my $key = shift;
	my $epoch = shift;
	$self->addKeyword($key, toBase36($epoch*1000));
}

#-------------------------------------------------------------------

=head2 addKeyword ( key, text )

Adds some text that is stored and indexed, but not tokenized. This is best for single word items like keys.

=head3 key

A unique label to store this data.

=head3 text

A string of text.

=cut

sub addKeyword {
	my $self = shift;
	my $key = shift;
	my $text = shift;
	$self->{_doc}->add(Plucene::Document::Field->Keyword($key=>$text));
}

#-------------------------------------------------------------------

=head2 addRawText ( text ) 

This should be used when you're just dumping a big block of raw text into the search indexer. It doesn't store the raw text, just indexes it for key words.

=head3 text

A string of text.

=cut

sub addRawText {
	my $self = shift;
	$self->{_raw} .= ' '.shift;
}


#-------------------------------------------------------------------

=head2 addText ( key, text )

Adds some text that is stored, indexed, and tokenized. This is best for simple phrases like titles and subjects.

=head3 key

A unique label to store this data.

=head3 text

A string of text.

=cut

sub addText {
	my $self = shift;
	my $key = shift;
	my $text = shift;
	$self->{_doc}->add(Plucene::Document::Field->Text($key => $text));
	$self->addRawText($text);
}

#-------------------------------------------------------------------

=head2 addUnindexed ( key, text )

Adds some text that is stored but not indexed or tokenized. This should be used sparingly, if ever, and is just a way to store extra metadata with search content that will not actually be used in search matches.

=head3 key

A unique label to store this data.

=head3 text

A string of text.

=cut

sub addUnindexed {
	my $self = shift;
	my $key = shift;
	my $text = shift;
	$self->{_doc}->add(Plucene::Document::Field->UnIndexed($key=>$text));
}

#-------------------------------------------------------------------

=head2 addUnstored ( key, text )

Adds some text that is indexed and tokenized, but is not stored verbatim. This is best for big test blocks like descriptions.

=head3 key

A unique label to store this data.

=head3 text

A string of text.

=cut

sub addUnstored {
	my $self = shift;
	my $key = shift;
	my $text = shift;
	$self->{_doc}->add(Plucene::Document::Field->UnStored($key => $text));
	$self->addRawText($text);
}

#-------------------------------------------------------------------

=head2 commit ( )

Writes the data added using the various add methods to the index. This is the last thing should do and it must be done or the index will not be created.

=cut

sub commit {
	my $self = shift;
	my $writer = Plucene::Index::Writer->new( $self->{_path}, Plucene::Analysis::SimpleAnalyzer->new(), -e catfile($self->{_path}, "segments") ? 0 : 1);
	$self->{_doc}->add(Plucene::Document::Field->UnStored(_raw_=> $self->{_raw}));
	$writer->add_document($self->{_doc});
	undef $writer;
	$self->DESTROY;
}

#-------------------------------------------------------------------

=head2 delete ( )

Deletes this indexed item.

=cut

sub delete {
	my $self = shift;
	# note: currently this method does nothing because stuff is actually deleted when you call the constructor
	$self->DESTROY;
}

#-------------------------------------------------------------------

=head2 DESTROY ( ) 

Deconstructor.

=cut

sub DESTROY {
	my $self = shift;
	delete $self->{_doc};
	undef $self;
}

#-------------------------------------------------------------------

=head2 getId ( )

Returns the ID used to create this object.

=cut

sub getId {
	my $self = shift;
	return $self->{_id};
}

#-------------------------------------------------------------------

=head2 new ( session , id )

Constructor.

=head3 session

A reference to the current session.

=head3 id

The unique ID for this record in the index. Should be the assetId for the content you're indexing.

=cut

sub new {
	my $class = shift;
	my $session = shift;
	my $id = shift;
	my $doc = Plucene::Document->new;
	my $self = {_path => "/tmp/plucy1", _p=>$session->config->get("uploadsPath")."/assetindex", _session=>$session, _doc=>$doc, _id=>$id};
	bless $self;
	if (-f $self->{_path}."/segments") { # don't make the following checks unless the index has been initialized
		my $reader = Plucene::Index::Reader->open($self->{_path}); 
        	my $term = Plucene::Index::Term->new({ field => 'id', text => $self->getId });
		if ($reader->doc_freq($term)) { # delete the existing index if it already exists
        		$reader->delete_term(Plucene::Index::Term->new({ field => "id", text => $self->getId }));
        		$reader->close;
		}
	}
	$doc->add(Plucene::Document::Field->Keyword(id => $id)); # create a new index for this id
	return $self;
}


#-------------------------------------------------------------------

=head2 optimize ( session )

=cut

sub optimize {
	my $class = shift;
	my $session = shift;
	Plucene::Index::Writer->new( "/tmp/plucy1", Plucene::Analysis::SimpleAnalyzer->new(), -e catfile("/tmp/plucy1", "segments") ? 0 : 1)->optimize;
}


#-------------------------------------------------------------------

=head2 session ( )

Returns a reference to the current session.

=cut

sub session {
	my $self = shift;
	return $self->{_session};
}







1;
