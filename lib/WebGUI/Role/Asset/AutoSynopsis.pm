package WebGUI::Role::Asset::AutoSynopsis;

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
use Moose::Role;
use WebGUI::HTML;

=head1 NAME

Package WebGUI::AssetAspect::AutoSynopsis

=head1 DESCRIPTION

This is a role which provides a method for an asset to create a synopsis based on user submitted content.

=head1 SYNOPSIS

 with 'WebGUI::Role::Asset::AutoSynopsis';

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 getSynopsisAndContent ($synopsis, $body)

Returns a synopsis taken from the body of the Post, based on either the separator
macro, the first html paragraph, or the first physical line of text as defined by
newlines.

Returns both the synopsis, and the original body content.

=head3 $synopsis

If passed in, it returns that instead of the calculated synopsis.

=head3 $body

Body of the Post to use a source for the synopsis.

=cut

sub getSynopsisAndContent {
	my $self = shift;
	my $synopsis = shift;
	my $body = shift;
	unless ($synopsis) {
           my @content;
           if( $body =~ /\^\-\;/ ) {
               my @pieces = WebGUI::HTML::splitSeparator($body);
               $content[0] = shift @pieces;
               $content[1] = join '', @pieces;
           }
           elsif( $body =~ /<p>/ ) {
               @content = WebGUI::HTML::splitTag($body);
           }
           else {
       	       @content = split("\n",$body);
           }
           shift @content if $content[0] =~ /^\s*$/;
           $synopsis = WebGUI::HTML::filter($content[0],"all");
	}
	return ($synopsis,$body);
}

1;
