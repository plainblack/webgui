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

This package can also be used in object-oriented (OO) style.

 use WebGUI::International;
 my $i = WebGUI::International->new($namespace);
 $i->get($internationalId);

=head1 METHODS

These functions/methods are available from this package:

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
        my ($id, $language, $namespace);
	if (ref($_[0]) eq "WebGUI::International") {
		$id = $_[1] || 0;
		$namespace = $_[2] || $_[0]->{_namespace} || "WebGUI";
		$language = $_[3] || $_[0]->{_language} || $session{user}{language} || 1;
	} else {
		$id = $_[0] || 0;
		$namespace = $_[1] || "WebGUI";
		$language = $_[2] || $session{user}{language} || 1;
	}
	my $cachetag = $session{config}{configFile}."-International";
	if ($session{config}{useSharedInternationalCache}) {
		$cachetag = "International";
	}
	my $cache = WebGUI::Cache->new($language."_".$namespace."_".$id,$cachetag);
	my $output = $cache->get;
	if (not defined $output) {
		($output) = WebGUI::SQL->quickArray("select message from international 
			where internationalId=$id and namespace='$namespace' and languageId='$language'");
		if ($output eq "" && $language ne 1) {
			$output = get($id,$namespace,1);
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


#-------------------------------------------------------------------

=head2 new ( [ namespace, languageId ] ) 

The constructor for the International function if using it in OO mode.

=over

=item namespace

Specify a default namespace. Defaults to "WebGUI".

=item languageId

Specify a default language. Defaults to user preference.

=back

=cut

sub new {
	my $class = shift;
	my $namespace = shift;
	my $language = shift;
	bless({_namespace=>$namespace,_language=>$language},$class);
}


1;

