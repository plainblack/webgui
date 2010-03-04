package WebGUI::Macro::a_account;

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
use WebGUI::International;
use WebGUI::Asset::Template;

=head1 NAME

Package WebGUI::Macro::a_account

=head1 DESCRIPTION

Macro for displaying a url to the current User's account page.

=head2 process ( [text,template ] )

process takes two optional parameters for customizing the content and layout
of the account link.

=head3 text

The text of the link.  If no text is displayed an internationalized default will be used.

=head3 template

The URL of a template to use for formatting the link.

=cut

#-------------------------------------------------------------------
sub process {
	my $session = shift;
	my %var;
	my  @param = @_;
	return $session->url->page("op=auth;method=init") if ($param[0] eq "linkonly");
	my $i18n = WebGUI::International->new($session,'Macro_a_account');
	$var{'account.url'} = $session->url->page('op=auth;method=init');
	$var{'account.text'} = $param[0] || $i18n->get(46);
	if ($param[1]) {
		return  WebGUI::Asset::Template->newByUrl($session, $param[1])->process(\%var);
	} else {
		return  WebGUI::Asset::Template->newById($session, "PBtmpl0000000000000037")->process(\%var);
	}
}


1;


