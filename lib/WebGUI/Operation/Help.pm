package WebGUI::Operation::Help;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
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
use WebGUI::Asset::Template;
use WebGUI::Macro;
use WebGUI::Session;
use WebGUI::URL;
use WebGUI::Utility;

#-------------------------------------------------------------------
sub _get {
	my $id = shift;
	my $namespace = shift;
	$namespace =~ s/[^\w\d\s]//g;
	$id =~ s/[^\w\d\s\/]//g;
	my $cmd = "WebGUI::Help::".$namespace;
        my $load = "use ".$cmd;
        eval($load);
        $cmd = "\$".$cmd."::HELP->{'".$id."'}";
        return eval($cmd);
}

#-------------------------------------------------------------------
sub _link {
	return WebGUI::URL::page('op=viewHelp;hid='.WebGUI::URL::escape($_[0]).';namespace='.$_[1]);
}

#-------------------------------------------------------------------
sub www_viewHelp {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Grouping::isInGroup(7));
	my $ac = WebGUI::AdminConsole->new("help");
	my $namespace = $session{form}{namespace} || "WebGUI";
        my $i18n = WebGUI::International->new($namespace);
	my $help = _get($session{form}{hid},$namespace);
	foreach my $row (@{$help->{related}}) {
		my $relatedHelp = _get($row->{tag},$row->{namespace});
		$ac->addSubmenuItem(_link($row->{tag},$row->{namespace}),WebGUI::International::get($relatedHelp->{title},$row->{namespace}));
	}
        my %vars;
        $vars{body} = $i18n->get($help->{body});
        foreach my $row (@{ $help->{fields} }) {
                push @{ $vars{fields} }, 
                        { 'title' =>       WebGUI::International::get($row->{title},$row->{namespace}),
                          'description' => WebGUI::International::get($row->{description},$row->{namespace}), }
        }
        my $body = WebGUI::Asset::Template->new("PBtmplHelp000000000001")->process(\%vars);
    	$ac->addSubmenuItem(WebGUI::URL::page('op=viewHelpIndex'),WebGUI::International::get(95));
    	return $ac->render(
		WebGUI::Macro::process($body), 
		WebGUI::International::get(93).': '.$i18n->get($help->{title})
		);
}

#-------------------------------------------------------------------
sub www_viewHelpIndex {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Grouping::isInGroup(7));
        my @helpIndex;
	my $i;
        my $dir = $session{config}{webguiRoot}.$session{os}{slash}."lib".$session{os}{slash}."WebGUI".$session{os}{slash}."Help";
        opendir (DIR,$dir) or WebGUI::ErrorHandler::fatal("Can't open Help directory!");
        my @files = grep { /\.pm$/} readdir(DIR);
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
                                        push @helpIndex, [$namespace, $key,
                                                          WebGUI::International::get($help->{$key}{title},$namespace)];
					$i++;
				}
                        } else {
                                WebGUI::ErrorHandler::error("Help failed to compile: $namespace. ".$@);
                        }
                }
        }
	my $output = '<table width="100%" class="content"><tr><td valign="top">';
	my $halfway = round($i/2);
	$i = 0;
        @helpIndex = sort { $a->[2] cmp $b->[2] } @helpIndex;
        foreach my $helpEntry (@helpIndex) {
                my ($namespace, $id, $title) = @{ $helpEntry };
                $output .= '<p><a href="'._link($id,$namespace).'">'.$title.'</a></p>';
                $i++;
                if ($i == $halfway) {
                        $output .= '</td><td valign="top">';
                }	
	}
	$output .= '</td></tr></table>';
	return WebGUI::AdminConsole->new("help")->render($output);
}

1;
