package WebGUI::Macro::Include;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use FileHandle;
use WebGUI::Macro;

#-------------------------------------------------------------------
sub _replacement {
        my (@param, $temp, $file);
        @param = WebGUI::Macro::getParams($_[0]);
        if ($param[0] =~ /passwd/ || $param[0] =~ /shadow/ || $param[0] =~ /WebGUI.conf/) {
                $temp = "SECURITY VIOLATION";
        } else {
                $file = FileHandle->new($param[0],"r");
                if ($file) {
                        while (<$file>) {
                                $temp .= $_;
                        }
                        $file->close;
                } else {
                        $temp = "INCLUDED FILE DOES NOT EXIST";
                }
        }
        return $temp;
}

#-------------------------------------------------------------------
sub process {
	my ($output, $temp);
	$output = $_[0];
        $output =~ s/\^Include\((.*?)\)\;/_replacement($1)/ge;
	return $output;
}

1;


