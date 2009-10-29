package WebGUI::International;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
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
use WebGUI::Pluggable;
use Module::Find qw(findsubmod);

=head1 NAME

Package WebGUI::International

=head1 DESCRIPTION

This package provides an interface to the internationalization system.

=head1 SYNOPSIS

 use WebGUI::International;
 my $i = WebGUI::International->new($session, $namespace);

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
This parameter is deprecated and will be removed in the future.

=head3 language

A string that specifies the language that the user should see.  Defaults to the user's defined language. If the user hasn't specified a default language it defaults to 'English'.
This parameter is deprecated and will be removed in the future.

=cut

sub get {
    my ($self, $id, $namespace, $language) = @_;
    my $table = $self->{_table};
    $namespace = $namespace || $self->{_namespace};
    $language = $language || $self->{_language};

    # if the requested namespace and language don't match our init params,
    # we don't have its table readily available, so we need to load it.
    if ( $namespace ne $self->{_namespace} || $language ne $self->{_language} ) {
        $table = $self->_loadNamespace($language, $namespace);
        my $message = $table->{$id}{message};
        if ($message eq "" && $language ne 'English') {
            $table = $self->_loadNamespace('English', $namespace);
            return $table->{$id}{message};
        }
        return $message;
    }
    my $message = $table->{$id}{message};

    # if there is a missing message in a translation, load and cache the
    # english table, and get the message from there.
    if ($message eq "" && $language ne 'English') {
        $self->{_englishTable} ||= $self->_loadNamespace('English', $namespace);
        return $self->{_englishTable}{$id}{message};
    }

    return $message;
}

sub _loadNamespace {
    my ($self, $language, $namespace) = @_;
    $language =~ s/\W//g;
    $namespace =~ s/\W//g;
    my $package = "WebGUI::i18n::".$language."::".$namespace;
    # with preload, everything should already be in memory, so go directly for the
    # variable first
    my $table = do {
        no strict 'refs';
        ${"$package\::I18N"};
    };

    # if it wasn't there it may not be loaded or it may not be available.
    if (! $table) {
        eval { WebGUI::Pluggable::load($package); };
        if ($@) {
            if ($language eq 'English') {
                $self->session->log->error("Unable to load $package");
                return {};
            }
            else {
                return $self->_loadNamespace('English', $namespace);
            }
        }
        no strict 'refs';
        $table = ${"$package\::I18N"};
    }
    return $table;
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
    $language ||= $self->{_language};
    my $pack = "WebGUI::i18n::" . $language;
    WebGUI::Pluggable::load($pack);
    my $langInfo = do {
        no strict 'refs';
        ${"$pack\::LANGUAGE"};
    };
    $self->session->errorHandler->warn("Failed to retrieve language properties because ".$@) if ($@);
    if ($property) {
        return $langInfo->{$property};
    }
    else {
        return $langInfo;
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
    my $hashRef;
    for my $lang ( findsubmod 'WebGUI::i18n' ) {
        $lang =~ s/^WebGUI::i18n:://;
        $hashRef->{$lang} = $self->getLanguage($lang, "label");
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
    WebGUI::Pluggable::load($cmd);
	my $output = WebGUI::Pluggable::run($cmd, 'makeUrlCompliant', [$url]);
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
    $self->{_table} = $self->_loadNamespace($self->{_language}, $namespace);
    return $namespace;
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
    $namespace ||= 'WebGUI';
    $language ||= $session->scratch->getLanguageOverride() || $session->user->profileField('language');
	my $self =
        bless {
            _session   => $session,
            _namespace => $namespace,
            _language  => $language,
        }, $class;
    $self->{_table} = $self->_loadNamespace($language, $namespace);
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

