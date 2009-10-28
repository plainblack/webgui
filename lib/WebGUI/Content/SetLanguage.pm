package WebGUI::Content::SetLanguage;

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


use strict;
use WebGUI::Session;
use WebGUI::International;

=head1 NAME

Package WebGUI::Content::SetLanguage

=head1 DESCRIPTION

Sets or delete an scratch variable that overrides the profile field language

=head1 SYNOPSIS

use WebGUI::Content::SetLanguage;
WebGUI::Content::SetLanguage::handler();

=head1 SUBROUTINES

These subroutines are available from this package:

handler

=cut

#-------------------------------------------------------------

=head2 handler ( session, op, setLanguage )

sets or delete scratch variable in a session and returns undef

=head3 session

The current WebGUI::Session object.

=head3 op

op should be setLanguage to call the handler

=head3 language

language should be an installed language or delete

=cut


sub handler {
	my ($session) = @_;
	return undef unless $session->form->get('op') eq 'setLanguage';
	my $language = $session->form->get('language');
	#check whether a language has been given in the url
	if (!$language) { 
		$session->log->error('There is no language given to this method');
		return undef;
	}
	#make it possible to delete the language scratch variable from the session
	if ($language eq 'delete' ) {
		$session->scratch->removeLanguageOverride;
		return undef;
	}
	#set a scratch variable language or throw error if language is not installed
	else {
		return $session->scratch->setLanguageOverride($language);
	}
}
1;
