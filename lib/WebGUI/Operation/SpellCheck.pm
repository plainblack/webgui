package WebGUI::Operation::SpellCheck;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use File::Path qw(mkpath);
# Optional, but if unavailable, spell checking will have no effect.
my $spellerAvailable;
BEGIN {
    eval {
        require Text::Aspell;
    };
    $spellerAvailable = 1
        unless $@;
};

=head1 NAME

Package WebGUI::Operation::SpellCheck

=head1 DESCRIPTION

Operation for server side spellchecking functions.

=cut

#-------------------------------------------------------------------

=head2 _getSpeller ( session , language )

Returns an instanciated Text::Aspell object.

=head3 session

An instanciated session object.

=head3 language

The language code to use for spell checking.

=cut

sub _getSpeller {
    my $session = shift;
    my $lang = shift;
    die "Server side spellcheck not available\n"
        unless $spellerAvailable;
    # Get language
    my $speller = Text::Aspell->new;
    die "Language not available in server side spellcheck"
        unless ($lang ~~ [map {m/^.*?:([^:]*):.*?$/} $speller->list_dictionaries]);

    # User homedir
    my $homeDir = $session->config->get('uploadsPath').'/dictionaries/';

    my $userId = $session->user->userId;
    if (length($userId) < 22) {
        $homeDir .= "oldIds/$userId";
    }
    else {
        $userId =~ m/^(.{2})(.{2})/;
        $homeDir .= "$1/$2/$userId";
    }
    mkpath($homeDir) unless (-e $homeDir);

    # Set speller options.
    $speller->set_option('home-dir', $homeDir);
    $speller->set_option('lang', $lang);
    return $speller;
}

#-------------------------------------------------------------------

=head2 addWord ( $session, $language, $word )

Adds a word sent by the tinymce spellchecker plugin to the personal dictionary
of the the current user.

=head3 $session

The instanciated session object

=head3 $language

The dictionary language to use.

=head3 $word

The word to add to the dictionary.

=cut

sub addWord {
    my $session = shift;
    my $language = shift;
    my $word = shift;
    die "You must be logged in to add words to your dictionary.\n:"
        if ($session->user->isVisitor);
    my $speller = _getSpeller($session, $language);
    $speller->add_to_personal($word);
    $speller->save_all_word_lists;
    return 1;
}

#-------------------------------------------------------------------

=head2 checkWords ( $session, $language, \@words )

Check the spelling on a list of words and returns a list of misspelled words as an array reference

=head3 $session

The instanciated session object

=head3 $language

The dictionary language to use.

=head3 \@word

The words to check the spelling of as an array reference.

=cut

sub checkWords {
    my $session = shift;
    my $language = shift;
    my $words = shift;
    my $speller = _getSpeller($session, $language);
    my @result;
    foreach my $word (@$words) {
        unless ($speller->check($word)) {
            push(@result, $word);
        }
    }
    return \@result;
}

#-------------------------------------------------------------------

=head2 getSuggestions ( $session, $language, $word )

Returns a list of suggested words for a misspelled word sent by the
tinyMCE spellchecker as an array reference.

=head3 $session

The instanciated session object.

=head3 $language

The dictionary language to use.

=head3 $word

The misspelled word to get suggestions for.

=cut

sub getSuggestions {
    my $session = shift;
    my $language = shift;
    my $word = shift;
    my $speller = _getSpeller($session, $language);
    my @result = $speller->suggest($word);
    return \@result;
}

#-------------------------------------------------------------------

=head2 www_spellCheck ( session )

Fetches the JSON data sent by the TinyMCE spell checker and dispatches
to the correct sub to handle each request type.  Encodes the result
as a JSON string to be sent back to the client.

=head3 session

The instanciated session object.

=cut

sub www_spellCheck {
    my $session = shift;
    # JSON data is sent directly as POST data, read it into a scalar then decode
    my $data = '';
    while ($session->request->read(my $buffer, 1024)) {
        $data .= $buffer;
    }

    # work around TinyMCE JSON encoding bug
    $data =~ s/([^\\](?:\\\\)*)\\'/$1'/g;

    my $params = JSON->new->decode($data);

    my $result;
    # dispatch to different subs based on the 'method' in the JSON data
    my %dispatch = (
        checkWords      => \&checkWords,
        getSuggestions  => \&getSuggestions,
        addWord         => \&addWord,
    );
    if (exists $dispatch{$params->{method}}) {
        eval {
            # get results from sub and build result data
            $result = { result => $dispatch{$params->{method}}->($session, @{ $params->{params} }) };
        };
        if ($@) {
            $result = {error => {errstr => $@}};
        }
    }
    else {
        $result = {error => {errstr => "Invalid request"}};
    }
    # add request id and send to client as JSON blob
    $result->{id} = $params->{id};
    $session->http->setMimeType("text/plain; charset=utf-8");
    return JSON->new->encode($result);
}

1;

