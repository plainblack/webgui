package WebGUI::Macro;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001 Plain Black Software.
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
                if ($file ne "." && $file ne ".." && $file =~ /\.pm/) {
                        $file =~ s/\.pm//;
                        $cmd = "require WebGUI::Macro::".$file;
                        eval($cmd);
                        $cmd = "WebGUI::Macro::".$file."::process";
			$output = &$cmd($output);
                }
        }
        closedir(DIR);
  #---script url---
  # slash has to go last because it is also used as the end character for configurable widgets 
        if ($output =~ /\^\//) {
                $output =~ s/\^\//$session{env}{SCRIPT_NAME}/g;
        }
	return $output;
}

1;

