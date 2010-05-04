package WebGUI::i18n::English;

use strict;


our $LANGUAGE = {
    label                   => 'English',
    toolbar                 => 'bullet',
    languageAbbreviation    => 'en',        # used by plugins such as javascript helpers and third-party perl modules
    locale                  => 'US',        # same as above
};

sub makeUrlCompliant {
        my $value = shift; 
        $value =~ s/\s+$//;                     #removes trailing whitespace
        $value =~ s/^\s+//;                     #removes leading whitespace
        $value =~ s/ /-/g;                      #replaces whitespace with hyphens
        $value =~ s/\.$//;                      #removes trailing period
        $value =~ s/[^\w\-\.\_\/]//g;           #removes characters that would interfere with the url
        $value =~ s/^\///;                      #removes a leading /
        $value =~ s/\/$//;                      #removes a trailing /
        $value =~ s/\/\//\//g;                  #removes double /
        return $value;
}


1;
