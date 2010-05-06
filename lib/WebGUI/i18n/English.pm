package WebGUI::i18n::English;

use strict;


our $LANGUAGE = {
    label                   => 'English',
    toolbar                 => 'bullet',
    languageAbbreviation    => 'en',        # used by plugins such as javascript helpers and third-party perl modules
    locale                  => 'US',        # same as above
};

sub makeUrlCompliant {
    my $url = shift;
    return $url;
}


1;
