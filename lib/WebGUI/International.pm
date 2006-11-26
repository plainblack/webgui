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

=head1 NAME

Package WebGUI::International

=head1 DESCRIPTION

This package provides an interface to the internationalization system.

=head1 SYNOPSIS

 use WebGUI::International;
 $string = WebGUI::International::get($session,$internationalId,$namespace);
 $hashRef = WebGUI::International::getLanguage($session,$lang);
 $hashRef = WebGUI::International::getLanguages($session);
 $url = WebGUI::International::makeUrlCompliant($session,$url);

This package can also be used in object-oriented (OO) style.

 use WebGUI::International;
 my $i = WebGUI::International->new($session,$namespace);

 $string = $i->get($internationalId);
 $string = $i->get($internationalId, $otherNamespace);

 $url = $i->makeUrlCompliant($url);

 $hashRef = $i->getLanguage($lang);

 $hashRef = $i->getLanguages();

=head1 METHODS

These functions/methods are available from this package:

=cut


#-------------------------------------------------------------------

=head2 echo ( internationalId [ , namespace, language ] )

This method is used to help developers work with i18n before i18n files
have been created.  echo simply returns the internationId.

=cut

sub echo {
	my ($self, $id, $namespace, $language) = @_;
	return $id;

}

#-------------------------------------------------------------------

=head2 get ( internationalId [ , namespace, language ] )

Returns the internationalized message string for the user's language.
If there is no internationalized message, this method will return
the English string.

=head3 internationalId

An integer that relates to a message in the international table in the WebGUI database.

=head3 namespace

A string that relates to the namespace field in the international table in the WebGUI database. Defaults to 'WebGUI'.

=head3 language

A string that specifies the language that the user should see.  Defaults to the user's defined language. If the user hasn't specified a default language it defaults to 'English'.

=cut

my $safeRe = qr/[^\.\w\d\s\/]/;

sub get {
	my ($self, $id, $namespace, $language) = @_;
	$namespace = $namespace || $self->{_namespace} || "WebGUI";
	$language = $language || $self->{_language} || $self->session->user->profileField("language") || "English";
	$id =~ s/$safeRe//g;
	$language =~ s/$safeRe//g;
	$namespace =~ s/$safeRe//g;
	my $cmd = "WebGUI::i18n::".$language."::".$namespace;

	use Data::Dumper;
	if (defined *{"$cmd\::I18N"}) {  ##Symbol table lookup
		our $table;
		*table = *{"$cmd\::I18N"};  ##Create alias into symbol table
		return $table->{$id}->{message};  ##return key
	}
	my $load = "use ".$cmd;
	eval($load);
	$self->session->errorHandler->warn($cmd." failed to compile because ".$@) if ($@);
	$cmd = "\$".$cmd."::I18N->{'".$id."'}{message}";
	my $output = eval($cmd);	
	$self->session->errorHandler->warn("Couldn't get value from ".$cmd." because ".$@) if ($@);
	$output = $self->get($id,$namespace,"English") if ($output eq "" && $language ne "English");
	return $output;
}


#-------------------------------------------------------------------

=head2 getLanguage ( [ language , propertyName] )

Returns a hash reference to a particular language's properties.

=head3 language

Defaults to "English". The language to retrieve the properties for.

=head3 propertyName

If this is specified, only the value of the property will be returned, instead of the hash reference to all properties. The valid values are "toolbar", "languageAbbreviation", "locale", and "label".

=cut

sub getLanguage {
	my ($self, $language, $property) = @_;
	$language = $language || $self->{_language} || "English";
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

=head2 getNamespace ( ) 

Returns the default namespace set in the object when created.

=cut

sub getNamespace {
	my ($self) = @_;
	return $self->{_namespace};
}

#-------------------------------------------------------------------

=head2 getLanguages ( )

Returns a hash reference to the languages installed on this WebGUI system.  

=cut

sub getLanguages {
	my ($self) = @_;
        my ($hashRef);
	my $dir = $self->session->config->getWebguiRoot."/lib/WebGUI/i18n";
	opendir (DIR,$dir) or $self->session->errorHandler->fatal("Can't open I18N directory! ".$dir);
	my @files = readdir(DIR);
	closedir(DIR);
	foreach my $file (@files) {
		if ($file =~ /(.*?)\.pm$/) {
			my $language = $1;
			$hashRef->{$language} = $self->getLanguage($language,"label");
		}
	}
        return $hashRef;
}


#-------------------------------------------------------------------

=head2 makeUrlCompliant ( url [ , language ] )

Manipulates a URL to make sure it will work on the internet. It removes things like non-latin characters, etc.

=head3 url

The URL to manipulate.

=head3 language

Specify a default language. Defaults to user preference or "English".

=cut

sub makeUrlCompliant {
	my ($self, $url, $language) = @_;
	$language = $language || $self->{_language} || $self->session->user->profileField("language") || "English";
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

=head2 setNamespace ( namespace ) 

Set the default namespace for pulling internationalized labels.

=head3 namespace

The namespace to make the new default.

=cut

sub setNamespace {
	my ($self, $namespace) = @_;
	$self->{_namespace} = $namespace;
}

#-------------------------------------------------------------------

=head2 new ( session, [ namespace, language ] ) 

The constructor for the International function if using it in OO mode.  Note
that namespace and languages are defaults; they may be overridden in
all accessor methods, (get, getLanguage).

=head3 session

The current user's session variable

=head3 namespace

Specify a default namespace.

=head3 language

Specify a default language. Defaults to user preference or "English".

=cut

sub new {
	my ($class, $session, $namespace, $language) = @_;
	my $self = bless { _session   => $session, _namespace => $namespace, _language  => ($language || $session->user->profileField('language')) }, $class;
	return $self;
}

#-------------------------------------------------------------------

=head2 session ( ) 

Returns the internally stored session variable

=cut

sub session {
	return $_[0]->{_session};
}

1;

