package WebGUI::Macro::LoginToggle;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::International;
use WebGUI::Asset::Template;

=head1 NAME

Package WebGUI::Macro::LoginToggle

=head1 DESCRIPTION

Macro for a login or logout message with link to the user depending on whether they are logged in or not.

=head2 process ( [ loginText, logoutText, templateId ] )

Note, if loginText = 'linkonly', then only the link will be returned.

=head3 loginText

Text that will be displayed to the user if they are not logged in.  If blank, an
internationalized message will be used.

=head3 logoutText

Text that will be displayed to the user if they are logged in.  If blank, an
internationalized message will be used.

=head3 templateId

The URL of a template for custom layout of the link and text.

=cut


#-------------------------------------------------------------------
sub process {
	my $session = shift;
        my @param = @_;
	my $i18n = WebGUI::International->new($session,'Macro_LoginToggle');
        my $login = $param[0] || $i18n->get(716);
        my $logout = $param[1] || $i18n->get(717);
	my %var;
        if ($session->user->isVisitor) {
		return $session->url->page("op=auth;method=init") if ($param[0] eq "linkonly");
        	$var{'toggle.url'} = $session->url->page('op=auth;method=init');
               	$var{'toggle.text'} = $login;
        } else {
		return $session->url->page("op=auth;method=logout") if ($param[0] eq "linkonly");
                $var{'toggle.url'} = $session->url->page('op=auth;method=logout');
               	$var{'toggle.text'} = $logout;
        }
	if ($param[2]) {
		return  WebGUI::Asset::Template->newByUrl($session,$param[2])->process(\%var);
	} else {
		return  WebGUI::Asset::Template->newById($session,"PBtmpl0000000000000043")->process(\%var);
	}
}


1;

