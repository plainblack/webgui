package WebGUI::Operation::Help;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2004 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Tie::IxHash;
use WebGUI::AdminConsole;
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::Session;
use WebGUI::URL;
use WebGUI::Utility;

#-------------------------------------------------------------------
sub _get {
	my $id = shift;
	my $namespace = shift;
	my $cmd = "WebGUI::Help::".$namespace;
        my $load = "use ".$cmd;
        eval($load);
        $cmd = "\$".$cmd."::HELP->{'".$id."'}";
        return eval($cmd);
}

#-------------------------------------------------------------------
sub _link {
	return WebGUI::URL::page('op=viewHelp&hid='.WebGUI::URL::escape($_[0]).'&namespace='.$_[1]);
}

#-------------------------------------------------------------------
sub _seeAlso {
	my $related = shift;
	my $namespace = shift;
	my $output;
	return $output;
}


#-------------------------------------------------------------------
sub www_viewHelp {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Grouping::isInGroup(12));
	my $ac = WebGUI::AdminConsole->new;
	$ac->setAdminFunction("help");
	my $namespace = $session{form}{namespace} || "WebGUI";
	my $help = _get($session{form}{hid},$namespace);
    	$ac->addSubmenuItem(WebGUI::URL::page('op=viewHelpIndex'),WebGUI::International::get(95));
	foreach my $row (@{$help->{related}}) {
		my $relatedHelp = _get($row->{tag},$row->{namespace});
		$ac->addSubmenuItem(_link($row->{tag},$row->{namespace}),WebGUI::International::get($relatedHelp->{title},$row->{namespace}));
	}
    	return $ac->render(
		WebGUI::Macro::negate(WebGUI::International::get($help->{body},$namespace)), 
		WebGUI::International::get(93).': '.WebGUI::International::get($help->{title},$namespace)
		);
}

#-------------------------------------------------------------------
sub www_viewHelpIndex {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Grouping::isInGroup(12));
	my %helpIndex;
	tie %helpIndex, "Tie::IxHash";
	my $i;
        my $dir = $session{config}{webguiRoot}.$session{os}{slash}."lib".$session{os}{slash}."WebGUI".$session{os}{slash}."Help";
        opendir (DIR,$dir) or WebGUI::ErrorHandler::fatalError("Can't open Help directory!");
        my @files = readdir(DIR);
        closedir(DIR);
        foreach my $file (@files) {
                if ($file =~ /(.*?)\.pm$/) {
                        my $namespace = $1;
                        my $cmd = "WebGUI::Help::".$namespace;
                        my $load = "use ".$cmd;
                        eval($load);
                        unless ($@) {
                                $cmd = "\$".$cmd."::HELP";
                                my $help = eval($cmd);
				foreach my $key (keys %{$help}) {
					$helpIndex{$key."_".$namespace} = WebGUI::International::get($help->{$key}{title},$namespace);
					$i++;
				}
                        } else {
                                WebGUI::ErrorHandler::warn("Help failed to compile: $namespace. ".$@);
                        }
                }
        }
	my $output = '<table width="100%" class="content"><tr><td valign="top">';
	my $halfway = round($i/2);
	$i = 0;
	%helpIndex = sortHash(%helpIndex);
	foreach my $key (keys %helpIndex) {
		my ($id,$namespace) = split("_",$key);
		my $help = _get($id,$namespace);
		$output .= '<p><a href="'._link($id,$namespace).'">'.$helpIndex{$key}.'</a></p>';
		$i++;
		if ($i == $halfway) {
			$output .= '</td><td valign="top">';
		}	
	}
	$output .= '</td></tr></table>';
	my $ac = WebGUI::AdminConsole->new;
	$ac->setAdminFunction("help");
	return $ac->render($output);
}

1;
