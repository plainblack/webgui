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
        my (@files, $file, $cmd, $output);
	$output = $_[0];
        opendir (DIR,"../lib/WebGUI/Macro") or WebGUI::ErrorHandler::fatalError("Can't open macro directory!");
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
  # slash hash to go last because it is also used as the end character.
        if ($output =~ /\^\//) {
                $output =~ s/\^\//$session{env}{SCRIPT_NAME}/g;
        }
	return $output;
}

1;

