package WebGUI::Macro::H_homeLink;

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
use WebGUI::Asset;
use WebGUI::Asset::Template;
use WebGUI::International;

=head1 NAME

Package WebGUI::Macro::H_homeLink

=head1 DESCRIPTION

Returns a templated link for the default page, determined by the WebGUI settings.

=head2 process ( [label, templateUrl] )

=head3 label

The text to present to the user as a link to the home page.  If left blank, an
internationalized label will be used.  If the label is the word "linkonly",
the macro will just return the bare link, with no templating.

=head3 templateUrl

A URL for a template to use to style the link.  This can be used to add
images or other stuff.  If left blank, a default template will
be used.

=cut


#-------------------------------------------------------------------
sub process {
	my $session = shift;
        my ($label, $templateUrl) = @_;
	my $home = WebGUI::Asset->getDefault($session);
	if ($label ne "linkonly") {
		my %var;
       		$var{'homelink.url'} = $home->getUrl;
       		if ($label ne "") {
               		$var{'homeLink.text'} = $label;
       		} else {
			my $i18n = WebGUI::International->new($session,'Macro_H_homeLink');
               		$var{'homeLink.text'} = $i18n->get(47);
       		}
		if ($templateUrl) {
         		return WebGUI::Asset::Template->newByUrl($session,$templateUrl)->process(\%var);
		} else {
         		return WebGUI::Asset::Template->newById($session,"PBtmpl0000000000000042")->process(\%var);
		}
	}
	return $home->getUrl;
}


1;

