package WebGUI::International;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2004 Plain Black LLC.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut


use strict;
use WebGUI::Cache;
use WebGUI::Session;
use WebGUI::SQL;


=head1 NAME

Package WebGUI::International

=head1 DESCRIPTION

This package provides an interface to the internationalization system.

=head1 SYNOPSIS

 use WebGUI::International;
 $string = WebGUI::International::get($internationalId,$namespace);
 %languages = WebGUI::International::getLanguages();

=head1 METHODS

These functions are available from this package:

=cut


#-------------------------------------------------------------------

=head2 get ( internationalId [ , namespace, languageId ] )

Returns the internationalized message string for the user's language.  If there is no internationalized message, this method will return the English string.

=over

=item internationalId

An integer that relates to a message in the international table in the WebGUI database.

=item namespace

A string that relates to the namespace field in the international table in the WebGUI database. Defaults to 'WebGUI'.

=item languageId

An integer that specifies the language that the user should see.  Defaults to the user's defined language. If the user hasn't specified a default language it defaults to '1' (English).

=back

=cut

sub get {
        my ($output, $language, $namespace, $cache);
	if ($_[2] ne "") {
		$language = $_[2];
	} elsif ($session{user}{language} ne "") {
		$language = $session{user}{language};
	} else {
		$language = 1;
	}
	if ($_[1] ne "") {
		$namespace = $_[1];
	} else {
		$namespace = "WebGUI";
	}
	my $cachetag = $session{config}{configFile}."-International";
	if ($session{config}{useSharedInternationalCache}) {
		$cachetag = "International";
	}
	$cache = WebGUI::Cache->new($language."_".$namespace."_".$_[0],$cachetag);
	$output = $cache->get;
	if (not defined $output) {
		($output) = WebGUI::SQL->quickArray("select message from international 
			where internationalId=$_[0] and namespace='$namespace' and languageId='$language'");
		if ($output eq "" && $language ne 1) {
			$output = get($_[0],$namespace,1);
		}
		$cache->set($output, 3600);
	}
	return $output;
}

#-------------------------------------------------------------------

=head2 getLanguages ( )

Returns a hash reference to the languages (languageId/lanugage) installed on this WebGUI system.  

=cut

sub getLanguages {
        my ($hashRef);
        $hashRef = WebGUI::SQL->buildHashRef("select languageId,language from language");
        return $hashRef;
}

1;

