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
	my $vars 	= {'lang_loop' => []};
	foreach my $language ( keys %$languages ) {
		my $langVars = {};
		$langVars->{ 'language_url' } 		= '?op=setLanguage;language=' . $language ;
		$langVars->{ 'language_lang' } 		= $i18n->getLanguage($language , 'label');
		$langVars->{ 'language_langAbbr' } 	= $i18n->getLanguage($language, 'languageAbbreviation');
		$langVars->{ 'language_langAbbrLoc' } 	= $i18n->getLanguage($language, 'locale');
		$langVars->{ 'language_langEng' } 	= $language;
		push(@{$vars->{lang_loop}}, $langVars);
	}
	return $template->process($vars);
}

1;

#vim:ft=perl
