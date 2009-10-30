package WebGUI::Macro::PickLanguage; # edit this line to match your own macro name

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
use WebGUI::Asset::Template;

=head1 NAME

Package WebGUI::Macro::PickLanguage

=head1 DESCRIPTION

This macro makes a link for each installed language so when clicked the SetLanguage contetntHandler is called and sets the language in the scratch. The link text is the label from the language.

=head2 process( $session )

The main macro class, Macro.pm, will call this subroutine and pass it

=over 4

=item *

A session variable

=item templateId

This macro takes a templateId to show the links

=back

=cut


#-------------------------------------------------------------------
sub process {
	my $session 	= shift;
	my $templateId 	= shift || "_aE16Rr1-bXBf8SIaLZjCg";
	my $template 	= WebGUI::Asset::Template->new($session, $templateId);
        return "Could not instanciate template with id [$templateId]" unless $template;
	my $i18n 	= WebGUI::International->new($session);
	my $languages 	= $i18n->getLanguages();
	my @lang_loop 	= ();
	foreach my $language ( keys %$languages ) {
		push @lang_loop, {
			language_url 		=> '?op=setLanguage;language=' . $language, 
			language_lang		=> $i18n->getLanguage($language , 'label'),
			language_langAbbr 	=> $i18n->getLanguage($language, 'languageAbbreviation'),
			language_langAbbrLoc 	=> $i18n->getLanguage($language, 'locale'),
			language_langEng 	=> $language,
		};
	}
	my %vars = (
		lang_loop	 	=> \@lang_loop,
		delete_url		=> '?op=setLanguage;language=delete;',
		delete_label		=> $i18n->get('delete',"Macro_PickLanguage"),
	);

	return $template->process(\%vars);
}

1;

#vim:ft=perl
