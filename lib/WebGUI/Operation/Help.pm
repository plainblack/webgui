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

use Exporter;
use strict;
use Tie::IxHash;
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::Session;
use WebGUI::URL;
use WebGUI::Utility;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_viewHelp &www_viewHelpIndex);

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
	return '<a href="'.WebGUI::URL::page('op=viewHelp&hid='.WebGUI::URL::escape($_[0]).'&namespace='.$_[1]).'">'.$_[2].'</a>';
}

#-------------------------------------------------------------------
sub _seeAlso {
	my $related = shift;
	my $namespace = shift;
	my $output;
	foreach my $row (@{$related}) {
		my $help = _get($row->{tag},$row->{namespace});
		$output .= '<li>'._link($row->{tag},$row->{namespace},WebGUI::International::get($help->{title},$row->{namespace}));
	}
	return $output;
}


#-------------------------------------------------------------------
sub www_viewHelp {
	my $namespace = $session{form}{namespace} || "WebGUI";
	my $help = _get($session{form}{hid},$namespace);
    my $output = '<h1>'.WebGUI::International::get(93).': '.WebGUI::International::get($help->{title},$namespace).'</h1>';
	$output .= WebGUI::International::get($help->{body},$namespace);
	$output .= '<p><b>'.WebGUI::International::get(94).':<ul>';
	$output .= _seeAlso($help->{related},$namespace);
    $output .= '<li><a href="'.WebGUI::URL::page('op=viewHelpIndex').'">'.WebGUI::International::get(95).'</a></ul></b>';
    return WebGUI::Macro::negate($output);
}

#-------------------------------------------------------------------
sub www_viewHelpIndex {
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
	my $output = '<h1>Help Index</h1><table width="100%" class="content"><tr><td valign="top">';
	my $halfway = round($i/2);
	$i = 0;
	%helpIndex = sortHash(%helpIndex);
	foreach my $key (keys %helpIndex) {
		my ($id,$namespace) = split("_",$key);
		my $help = _get($id,$namespace);
		$output .= _link($id,$namespace,$helpIndex{$key});
		$output .= '<ul style="padding-left: 20px; margin: 2px; font-size: smaller;">';
		$output .= _seeAlso($help->{related},$namespace);
		$output .= '</ul>';
		$output .= "<br>";
		$i++;
		if ($i == $halfway) {
			$output .= '</td><td valign="top">';
		}	
	}
	$output .= '</td></tr></table>';
	return $output;
}

1;
