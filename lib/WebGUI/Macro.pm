package WebGUI::Macro;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict qw(vars subs);
use WebGUI::ErrorHandler;
use WebGUI::Session;

#-------------------------------------------------------------------
sub getParams {
        my ($data, @param);
        $data = $_[0];
        push(@param, $+) while $data =~ m {
                "([^\"\\]*(?:\\.[^\"\\]*)*)",?
                |       ([^,]+),?
                |       ,
        }gx;
        push(@param, undef) if substr($data,-1,1) eq ',';
	return @param;
}

#-------------------------------------------------------------------
sub process {
        my (@files, $file, $cmd, $output, $macroDir);
	$output = $_[0];
	if ($^O =~ /Win/i) {
		$macroDir = "\\lib\\WebGUI\\Macro";
	} else {
		$macroDir = "/lib/WebGUI/Macro";
	}
        opendir (DIR,$session{config}{webguiRoot}.$macroDir) or WebGUI::ErrorHandler::fatalError("Can't open macro directory!");
        @files = readdir(DIR);
        foreach $file (@files) {
                if ($file =~ /(.*?)\.pm$/) {
                        $cmd = "use WebGUI::Macro::".$1;
                        eval($cmd);
                        $cmd = "WebGUI::Macro::".$1."::process";
			$output = &$cmd($output);
                }
        }
        closedir(DIR);
	return $output;
}

1;

