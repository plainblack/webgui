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
use WebGUI::Session;


=head1 NAME

Package WebGUI::International

=head1 DESCRIPTION

This package provides an interface to the internationalization system.

=head1 SYNOPSIS

 use WebGUI::International;
 $string = WebGUI::International::get($internationalId,$namespace);
 $hashRef = WebGUI::International::getLanguage($lang);
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
		$id = $_[1];
		$namespace = $_[2] || $_[0]->{_namespace} || "WebGUI";
		$language = $_[3] || $_[0]->{_language} || $session{user}{language} || "English";
	} else {
		$id = $_[0];
		$namespace = $_[1] || "WebGUI";
		$language = $_[2] || $session{user}{language} || "English";
	}
	my $cmd = "WebGUI::i18n::".$language."::".$namespace;
	my $load = "use ".$cmd;
	eval($load);
	WebGUI::ErrorHandler::warn($cmd." failed to compile because ".$@) if ($@);
	$cmd = "\$".$cmd."::I18N->{'".$id."'}";
	my $output = eval($cmd);	
	WebGUI::ErrorHandler::warn("Couldn't get value from ".$cmd." because ".$@) if ($@);
	$output = get($id,$namespace,"English") if ($output eq "" && $language ne "English");
	return $output;
}


#-------------------------------------------------------------------

=head2 getLanguage ( [ languageId , propertyName] )

Returns a hash reference to a particular language's properties.

=over

=item languageId

Defaults to "English". The language to retrieve the properties for.

=item propertyName

If this is specified, only the value of the property will be returned, instead of the hash reference to all properties. The valid values are "charset", "toolbar", and "label".

=back

=cut

sub getLanguage {
	my $language = shift || "English";
	my $property = shift;
	my $cmd = "WebGUI::i18n::".$language;
	my $load = "use ".$cmd;
	eval($load);
	unless ($@) {
		$cmd = "\$".$cmd."::LANGUAGE";
		my $hashRef = eval($cmd);	
		WebGUI::ErrorHandler::warn("Failed to retrieve language properties because ".$@) if ($@);
		if ($property) {
			return $hashRef->{$property};
		} else {
			return $hashRef;
		}
	} else {
		WebGUI::ErrorHandler::warn("Language failed to compile: $language. ".$@);
	}
}


#-------------------------------------------------------------------

=head2 getLanguages ( )

Returns a hash reference to the languages (languageId/lanugage) installed on this WebGUI system.  

=cut

sub getLanguages {
        my ($hashRef);
	my $dir = $session{config}{webguiRoot}.$session{os}{slash}."lib".$session{os}{slash}."WebGUI".$session{os}{slash}."i18n";
	opendir (DIR,$dir) or WebGUI::ErrorHandler::fatalError("Can't open I18N directory!");
	my @files = readdir(DIR);
	closedir(DIR);
	foreach my $file (@files) {
		if ($file =~ /(.*?)\.pm$/) {
			my $language = $1;
			$hashRef->{$language} = getLanguage($language,"label");
		}
	}
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

