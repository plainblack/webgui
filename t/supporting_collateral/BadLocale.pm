package WebGUI::i18n::BadLocale;

use strict;


our $LANGUAGE = {
	label => 'BadLocale',
	toolbar => 'bullet',
};

sub makeUrlCompliant {
        my $value = shift; 
        $value =~ s/\s+$//;                     #removes trailing whitespace
        $value =~ s/^\s+//;                     #removes leading whitespace
        $value =~ s/ /-/g;                      #replaces whitespace with hyphens
        $value =~ s/\.$//;                      #removes trailing period
        $value =~ s/[^A-Za-z0-9\-\.\_\/]//g;    #removes all funky characters
        $value =~ s/^\///;                      #removes a leading /
        $value =~ s/\/$//;                      #removes a trailing /
        $value =~ s/\/\//\//g;                  #removes double /
        return $value;
}


1;
