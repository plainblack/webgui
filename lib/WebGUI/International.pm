package WebGUI::International;

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


use strict qw(vars subs);
use WebGUI::Session;


=head1 NAME

Package WebGUI::International

=head1 DESCRIPTION

This package provides an interface to the internationalization system.

=head1 SYNOPSIS

 use WebGUI::International;
 $string = WebGUI::International::get($internationalId,$namespace);
 $hashRef = WebGUI::International::getLanguage($lang);
 $hashRef = WebGUI::International::getLanguages();
 $url = WebGUI::International::makeUrlCompliant($url);

This package can also be used in object-oriented (OO) style.

 use WebGUI::International;
 my $i = WebGUI::International->new($namespace);
 $string = $i->get($internationalId);
 $url = $i->makeUrlCompliant($url);

=head1 METHODS

These functions/methods are available from this package:

=cut


#-------------------------------------------------------------------

=head2 get ( internationalId [ , namespace, languageId ] )

Returns the internationalized message string for the user's language.  If there is no internationalized message, this method will return the English string.

=head3 internationalId

An integer that relates to a message in the international table in the WebGUI database.

=head3 namespace

A string that relates to the namespace field in the international table in the WebGUI database. Defaults to 'WebGUI'.

=head3 languageId

An integer that specifies the language that the user should see.  Defaults to the user's defined language. If the user hasn't specified a default language it defaults to '1' (English).

=cut

sub get {
        my ($id, $language, $namespace);
	if (ref($_[0]) eq "WebGUI::International") {
		$id = $_[1];
		$namespace = $_[2] || $_[0]->{_namespace} || "WebGUI";
		$language = $_[3] || $_[0]->{_language} || $self->session->user->profileField("language") || "English";
	} else {
		$id = $_[0];
		$namespace = $_[1] || "WebGUI";
		$language = $_[2] || $self->session->user->profileField("language") || "English";
	}
	$id =~ s/[^\w\d\s\/]//g;
	$language =~ s/[^\w\d\s\/]//g;
	$namespace =~ s/[^\w\d\s\/]//g;
	my $cmd = "WebGUI::i18n::".$language."::".$namespace;
	my $load = "use ".$cmd;
	eval($load);
	$self->session->errorHandler->warn($cmd." failed to compile because ".$@) if ($@);
	$cmd = "\$".$cmd."::I18N->{'".$id."'}{message}";
	my $output = eval($cmd);	
	$self->session->errorHandler->warn("Couldn't get value from ".$cmd." because ".$@) if ($@);
	$output = get($id,$namespace,"English") if ($output eq "" && $language ne "English");
	return $output;
}


#-------------------------------------------------------------------

=head2 getLanguage ( [ languageId , propertyName] )

Returns a hash reference to a particular language's properties.

=head3 languageId

Defaults to "English". The language to retrieve the properties for.

=head3 propertyName

If this is specified, only the value of the property will be returned, instead of the hash reference to all properties. The valid values are "toolbar", "languageAbbreviation", "locale", and "label".

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
		$self->session->errorHandler->warn("Failed to retrieve language properties because ".$@) if ($@);
		if ($property) {
			return $hashRef->{$property};
		} else {
			return $hashRef;
		}
	} else {
		$self->session->errorHandler->warn("Language failed to compile: $language. ".$@);
	}
}


#-------------------------------------------------------------------

=head2 getLanguages ( )

Returns a hash reference to the languages (languageId/lanugage) installed on this WebGUI system.  

=cut

sub getLanguages {
        my ($hashRef);
	my $dir = $self->session->config->getWebguiRoot."/lib/WebGUI/i18n";
	opendir (DIR,$dir) or $self->session->errorHandler->fatal("Can't open I18N directory! ".$dir);
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

=head2 makeUrlCompliant ( url [ , language ] )

Manipulates a URL to make sure it will work on the internet. It removes things like non-latin characters, etc.

=head3 url

The URL to manipulate.

=head3 languageId

Specify a default language. Defaults to user preference.

=cut

sub makeUrlCompliant {
        my ($language, $url);
	if (ref($_[0]) eq "WebGUI::International") {
		$url = $_[1];
		$language = $_[2] || $_[0]->{_language} || $self->session->user->profileField("language") || "English";
	} else {
		$url = $_[0];
		$language = $_[1] || $self->session->user->profileField("language") || "English";
	}
	my $cmd = "WebGUI::i18n::".$language;
	my $load = "use ".$cmd;
	eval($load);
	$self->session->errorHandler->warn($cmd." failed to compile because ".$@) if ($@);
	$cmd = $cmd."::makeUrlCompliant";
	my $output = eval{&$cmd($url)};	
	$self->session->errorHandler->fatal("Couldn't execute ".$cmd." because ".$@.". Maybe your languagepack misses the makeUrlCompliant method?") if ($@);
	return $output;
}


#-------------------------------------------------------------------

=head2 new ( [ namespace, languageId ] ) 

The constructor for the International function if using it in OO mode.

=head3 namespace

Specify a default namespace. Defaults to "WebGUI".

=head3 languageId

Specify a default language. Defaults to user preference.

=cut

sub new {
	my $class = shift;
	my $namespace = shift;
	my $language = shift;
	bless({_namespace=>$namespace,_language=>$language},$class);
}


1;

