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
sub loadTemplates {
        my ($templateDir, @files, $file, $use, @template, $i);
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
                        $template[$i] = $file;
                        $use = "require WebGUI::Template::".$template[$i];
                        eval($use);
			if ($@) {
				WebGUI::ErrorHandler::fatalError("Template load failed: ".$@);
			}
                        $i++;
                }
        }
        closedir(DIR);
        return @template;
}

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
        my (@templates, $cmd, $template, $namespace, %list);
        @templates = loadTemplates();
        foreach $template (@templates) {
        	#$cmd = "WebGUI::Template::".$template."::namespace";
                #$namespace = $$cmd;
                $cmd = "WebGUI::Template::".$template."::name";
                $list{$template} = &$cmd();
        }
        return %list;
}

#-------------------------------------------------------------------
sub getPositions {
	my ($cmd, %hash);
	tie %hash, "Tie::IxHash";
	$cmd = "use WebGUI::Template::".$_[0];
	eval($cmd);
	$cmd = "WebGUI::Template::".$_[0]."::getPositions";
	%hash = &$cmd;
	return %hash;
}


1;

