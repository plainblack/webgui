package WebGUI::Page;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use HTML::Template;
use strict;
use Tie::IxHash;
use WebGUI::ErrorHandler;
use WebGUI::HTMLForm;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Template;


#-------------------------------------------------------------------
sub _newPositionFormat {
	return "<tmpl_var page.position".($_[0]+1).">";
}

#-------------------------------------------------------------------
sub countTemplatePositions {
        my ($template, $i);
        $template = getTemplate($_[0]);
        $i = 1;
        while ($template =~ m/page\.position$i/) {
                $i++;
        }
        return $i-1;
}

#-------------------------------------------------------------------
sub drawTemplate {
	my $template = getTemplate($_[0]);
	$template =~ s/\n//g;
	$template =~ s/\r//g;
	$template =~ s/\'/\\\'/g;
	$template =~ s/\<table.*?\>/\<table cellspacing=0 cellpadding=3 width=100 height=80 border=1\>/ig;
	$template =~ s/\<tmpl_var\s+page\.position(\d+)\>/$1/ig;
	return $template;
}

#-------------------------------------------------------------------
sub getTemplateList {
	return WebGUI::Template::getList("Page");
}

#-------------------------------------------------------------------
sub getTemplate {
	my $template = WebGUI::Template::get($_[0],"Page");
	$template =~ s/\^(\d+)\;/_newPositionFormat($1)/eg; #compatibility with old-style templates
        return $template;
}

#-------------------------------------------------------------------
sub getTemplatePositions {
	my (%hash, $template, $i);
	tie %hash, "Tie::IxHash";
	for ($i=1; $i<=countTemplatePositions($_[0]); $i++) {
		$hash{$i} = $i;
	}
	return \%hash;
}


1;

