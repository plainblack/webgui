package WebGUI::Template;

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
use Tie::IxHash;
use WebGUI::ErrorHandler;
use WebGUI::Session;

#-------------------------------------------------------------------
sub calculatePositions {
        my (%positions, $string);
        $string = "A";
        $positions{A} = "A";
        while ($string ne $_[0]) {
                $string = ++$string;
                $positions{$string} = $string;
        }
        return %positions;
}

#-------------------------------------------------------------------
sub getList {
        my (@files, $file, $namespace, $cmd, %list, $templateDir);
	if ($^O =~ /Win/i) {
		$templateDir = "\\lib\\WebGUI\\Template";
	} else {
		$templateDir = "/lib/WebGUI/Template";
	}
        opendir (DIR,$session{config}{webguiRoot}.$templateDir) or WebGUI::ErrorHandler::fatalError("Can't open template directory!");
        @files = readdir(DIR);
        foreach $file (@files) {
                if ($file ne "." && $file ne ".." && $file =~ /\.pm/) {
                        $file =~ s/\.pm//;
                        $cmd = "require WebGUI::Template::".$file;
                        eval($cmd);
			$cmd = "WebGUI::Template::".$file."::namespace";
			$namespace = $$cmd;
                        $cmd = "WebGUI::Template::".$file."::name";
			$list{$namespace} = &$cmd();
                }
        }
        closedir(DIR);
	return %list;
}

#-------------------------------------------------------------------
sub getPositions {
	my ($cmd, %hash);
	tie %hash, "Tie::IxHash";
	$cmd = "require WebGUI::Template::".$_[0];
	eval($cmd);
	$cmd = "WebGUI::Template::".$_[0]."::getPositions";
	%hash = &$cmd;
	return %hash;
}


1;

