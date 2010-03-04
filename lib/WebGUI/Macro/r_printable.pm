package WebGUI::Macro::r_printable;

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
use WebGUI::Utility;

=head1 NAME

Package WebGUI::Macro::r_printable

=head1 DESCRIPTION

Macro for displaying a link to the user to change the page's style template
to one more suitable for printing.

=head2 process ( [text,styleId,template] )

process takes two optional parameters for customizing the content and layout
of the account link.

=head3 text

The text of the link.  If no text is displayed an internationalized
default will be used.  If the text equals 'linkonly', then only the
URL for the link will be returned instead of the templated output.

=head3 styleId

The default style to make the page printable is "Make Page Printable".  The
styleId argument can be used to override this default.

=head3 template

The URL to a template to use for formatting the link.  If omitted, a default
is used.

=cut

#-------------------------------------------------------------------
sub process {
	my $session = shift;
        my ($temp, @param);
        @param = @_;
	my $append = 'op=makePrintable';
	$temp = $session->url->page($append);
        $temp =~ s/\/\//\//;
        $temp = $session->url->append($temp,$session->env->get("QUERY_STRING"));
	if ($param[1] ne "") {
		$temp = $session->url->append($temp,'styleId='.$param[1]);
	}
	if ($param[0] ne "linkonly") {
		my %var;
		$var{'printable.url'} = $temp;
       		if ($param[0] ne "") {
               		$var{'printable.text'} = $param[0];
       		} else {
			my $i18n = WebGUI::International->new($session,'Macro_r_printable');
               		$var{'printable.text'} = $i18n->get(53);
       		}
		if ($param[2]) {
         		$temp =  WebGUI::Asset::Template->newByUrl($session,$param[2])->process(\%var);
		} else {
         		$temp =  WebGUI::Asset::Template->newById($session,"PBtmpl0000000000000045")->process(\%var);
		}
	}
	return $temp;
}


1;

