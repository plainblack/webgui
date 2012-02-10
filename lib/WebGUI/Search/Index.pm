package WebGUI::Search::Index;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2012 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use HTML::Entities;

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

=head2 addFile ( path ) 

Use an external filter defined in the config file as searchIndexerPlugins to pull keywords from a file and
add them to the index.

=head3 path

The path to the filename to index, including the filename.

=cut

sub addFile {
    my $self = shift;
    my $path = shift;
    my $keywords = $self->getKeywordsForFile($path);
    return unless $keywords =~ /\S/;
    return $self->addKeywords($keywords)
}

#-------------------------------------------------------------------

=head2 addKeywords ( text )

Add more text to the keywords index for this asset.

=head3 text

A string (or array of strings) of text. You may optionally also put HTML here, and it will be automatically filtered.

=cut

sub addKeywords {
	my $self = shift;
	my $text = join(" ", @_);

    $text = $self->_filterKeywords($text);
	my ($keywords) = $self->session->db->quickArray("select keywords from assetIndex where assetId=? and url=?",[$self->getId, $self->asset->get('url')]);
	$self->session->db->write("update assetIndex set keywords =? where assetId=? and url=?", [$keywords.' '.$text, $self->getId, $self->asset->get('url')]);
}


#-------------------------------------------------------------------

=head2 addRecord ( %fields )

Adds a duplicate record for the current asset, along with fields that are overridden.

=head3 %fields

A hash of fields to override in the record.  Entries for url and keywords are mandatory, and
no record will be added unless they exist in the hash.

The lineage entry cannot be overridden.

=cut

sub addRecord {
    my $self   = shift;
    my %fields = @_;
    return unless $fields{url} and $fields{keywords};
    my $asset  = $self->asset;
    ##Get the asset's record from the database.
    my %defaults = $self->session->db->quickHash('select * from assetIndex where assetId=? and url=?', [$asset->get('assetId'), $asset->get('url')]);
    $fields{keywords} = $self->_filterKeywords($fields{keywords});
    %fields           = (%defaults, %fields);
    $fields{assetId}  = $asset->getId;
    $fields{lineage}  = $defaults{lineage};
    my $add = $self->session->db->prepare("replace into assetIndex (assetId, url, title, creationDate, revisionDate, 
        ownerUserId, groupIdView, groupIdEdit, lineage, className, synopsis, keywords, subId) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? )");
    $add->execute([@fields{qw/assetId url title creationDate revisionDate ownerUserId groupIdView groupIdEdit lineage className synopsis keywords subId/}]);
}


#-------------------------------------------------------------------

=head2 asset ( )

Returns a reference to the asset object we're indexing.

=cut

sub asset {
	my $self = shift;
	return $self->{_asset};
}


#-------------------------------------------------------------------

=head2 create ( asset )

Constructor that also creates the initial index of an asset.

=cut

sub create {
	my $class = shift;
	my $asset = shift;
	my $self = $class->new($asset);
	$self->delete;

	my $url = $asset->get("url");
	$url =~ s/\/|\-|\_/ /g;

	my $description = WebGUI::HTML::filter($asset->get('description'), "all");
    my $keywords = join(" ",$asset->get("title"), $asset->get("menuTitle"), $asset->get("synopsis"), $url,
        $description, WebGUI::Keyword->new($self->session)->getKeywordsForAsset({asset=>$asset}));
    $keywords = $self->_filterKeywords($keywords);

	my $synopsis = $asset->get("synopsis") || substr($description,0,255);
	my $add = $self->session->db->prepare("insert into assetIndex (assetId, title, url, creationDate, revisionDate, 
		ownerUserId, groupIdView, groupIdEdit, lineage, className, synopsis, keywords) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? )");
	$add->execute([$asset->getId, $asset->get("title"), $asset->get("url"), $asset->get("creationDate"),
		$asset->get("revisionDate"), $asset->get("ownerUserId"), $asset->get("groupIdView"), $asset->get("groupIdEdit"), 
		$asset->get("lineage"), $asset->get("className"), $synopsis, $keywords]);
	return $self;
}


#-------------------------------------------------------------------

=head2 delete ( )

Deletes this indexed asset.

=cut

sub delete {
	my $self = shift;
	my $delete = $self->session->db->prepare("delete from assetIndex where assetId=?");
	$delete->execute([$self->getId]);
}

#-------------------------------------------------------------------

=head2 _filterKeywords ( $keywords )

Perform filtering and cleaning up of the keywords before submitting them.  Ideographic characters are padded
so that they are still searchable.  HTML entities are decoded.

=head3 $keywords

A string containing keywords.

=cut

sub _filterKeywords {
    my $self     = shift;
    my $keywords = shift;

    $keywords = WebGUI::HTML::filter($keywords, "all");
    $keywords = HTML::Entities::decode_entities($keywords);
    utf8::upgrade($keywords);

    # split into 'words'.  Ideographic characters (such as Chinese) are
    # treated as distinct words.  Everything else is space delimited.
    my @words = grep { $_ ne '' } split /\s+|(\p{Ideographic})/, $keywords;

    # remove punctuation characters at the start and end of each word.
    for my $word ( @words ) {
        $word =~ s/\A\p{isPunct}+//;
        $word =~ s/\p{isPunct}+\z//;
        # we add padding to ideographic characters to avoid minimum word length limits on indexing
        if ($word =~ /\p{Ideographic}/) {
            $word = q{''}.$word.q{''};
        }
    }

    $keywords = join q{ }, @words;
    return $keywords;
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

=head2 getKeywordsForFile ( path ) 

Use an external filter defined in the config file as searchIndexerPlugins to get keywords
from a file.

=head3 path

The path to the filename to index, including the filename.

=cut

sub getKeywordsForFile {
    my $self = shift;
    my $path = shift;
    my $filters = $self->session->config->get("searchIndexerPlugins");
    my $content;
    if ($path =~ m/\.(\w+)$/) {
        my $type = lc($1);
        if ($filters->{$type}) {
            open my $fh, "$filters->{$type} $path |" or return undef; # open pipe to filter
            $content = do { local $/; <$fh> };  # slurp file
            close $fh;
        }
    }
    return $content;
}


#-------------------------------------------------------------------

=head2 setIsPublic ( boolean )

Sets the status of whether this asset will appear in public searches.

=cut

sub setIsPublic {
	my $self = shift;
	my $boolean = shift;
	my $set = $self->session->db->prepare("update assetIndex set isPublic=? where assetId=?");
	$set->execute([$boolean, $self->getId]);
}

#-------------------------------------------------------------------

=head2 new ( asset )

Constructor.

=head3 asset

A reference to an asset object.

=cut

sub new {
	my $class = shift;
	my $asset = shift;
	my $self = {_asset=>$asset, _session=>$asset->session, _id=>$asset->getId};
	bless $self, $class;
}


#-------------------------------------------------------------------

=head2 session ( )

Returns a reference to the current session.

=cut

sub session {
	my $self = shift;
	return $self->{_session};
}

#-------------------------------------------------------------------

=head2 updateSynopsis ( text )

Overrides the asset's default synopsis with a new chunk of text.

NOTE: This doesn't change the asset itself, only the synopsis in the search index.

=head3 text

The text to put in place of the current synopsis.

=cut

sub updateSynopsis {
	my $self = shift;
	my $text = shift;
	my $add = $self->session->db->prepare("update assetIndex set synopsis=? where assetId=?");
	$add->execute([$text,$self->getId]);
}



1;

