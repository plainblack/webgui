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
sub _load {
	my $session = shift;
	my $namespace = shift;
	$namespace =~ s/[^\w\d\s]//g;
	my $cmd = "WebGUI::Help::".$namespace;
        my $load = sprintf 'use %-s; $%-s::HELP;', $cmd, $cmd;
	my $hash = eval($load);
	unless ($@) {
		return $hash
	}
	else {
		$session->errorHandler->error("Help failed to compile: $namespace. ".$@);
		return {};
	}
}

#-------------------------------------------------------------------
sub _get {
	my $session = shift;
	my $id = shift;
	my $namespace = shift;
	my $help = _load($namespace);
	if (keys %{ $help } ) {
		return $help->{$id};
	}
	else {
		return "Unable to load help for $namespace -> $id\n";
	}
}

#-------------------------------------------------------------------
sub _link {
	my $session = shift;
	return $session->url->page('op=viewHelp;hid='.$session->url->escape($_[0]).';namespace='.$_[1]);
}

#-------------------------------------------------------------------
sub _linkTOC {
	my $session = shift;
	return $session->url->page('op=viewHelpChapter;namespace='.$_[0]);
}

#-------------------------------------------------------------------
sub _getHelpFilesList {
	my $session = shift;
        my $dir = join '/', $session->config->getWebguiRoot,"lib","WebGUI","Help";
        opendir (DIR,$dir) or $session->errorHandler->fatal("Can't open Help directory!");
	my @files;
	foreach my $file (readdir DIR) {
		next unless $file =~ /.pm$/;
		my $modName;
		($modName = $file) =~ s/\.pm$//;
		push @files, [ $file, $modName ];
	}
        closedir(DIR);
	return @files;
}

#-------------------------------------------------------------------
sub _getHelpName {
	my $session = shift;
	my $file = shift;
	my $helpName;
	if ($file =~ /^Asset_/) {
		$helpName = 'assetName';
	}
	elsif ($file =~ /^Macro_/) {
		$helpName = 'macroName';
	}
	else {
		$helpName = 'topicName';
	}
	return WebGUI::International::get($helpName,$file);
}

#-------------------------------------------------------------------
sub www_viewHelp {
	my $session = shift;
	return $session->privilege->insufficient() unless (WebGUI::Grouping::isInGroup(7));
	my $ac = WebGUI::AdminConsole->new($session,"help");
	my $namespace = $session->form->process("namespace") || "WebGUI";
        my $i18n = WebGUI::International->new($namespace);
	my $help = _get($session->form->process("hid"),$namespace);
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
    	$ac->addSubmenuItem($session->url->page('op=viewHelpIndex'),WebGUI::International::get(95));
    	$ac->addSubmenuItem($session->url->page('op=viewHelpTOC'),WebGUI::International::get('help contents'));
	WebGUI::Macro::process($session,\$body);
    	return $ac->render(
		$body, 
		WebGUI::International::get(93).': '.$i18n->get($help->{title})
		);
}

#-------------------------------------------------------------------
sub www_viewHelpIndex {
	my $session = shift;
	return $session->privilege->insufficient() unless (WebGUI::Grouping::isInGroup(7));
        my @helpIndex;
	my $i;
	my @files = _getHelpFilesList();
        foreach my $fileSet (@files) {
		my $namespace = $fileSet->[1];
		my $help = _load($namespace);
		foreach my $key (keys %{$help}) {
			push @helpIndex, [$namespace, $key,
					WebGUI::International::get($help->{$key}{title},$namespace)];
			$i++;
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
	my $ac = WebGUI::AdminConsole->new($session,"help");
    	$ac->addSubmenuItem($session->url->page('op=viewHelpTOC'),WebGUI::International::get('help contents'));
	return $ac->render($output, join ': ',WebGUI::International::get(93), WebGUI::International::get('help index'));
}

#-------------------------------------------------------------------
sub www_viewHelpTOC {
	my $session = shift;
	return $session->privilege->insufficient() unless (WebGUI::Grouping::isInGroup(7));
        my @helpIndex;
	my $i;
	my @files = _getHelpFilesList();
	my $third = round(@files/3 + 0.50);
	my @entries;
	foreach my $fileSet (@files) {
		my $file = $fileSet->[1];
		push @entries, [_getHelpName($file), $file];
	}
	$i = 0;
	my $output = '<table width="100%" class="content"><tr><td valign="top">';
	@entries = sort { $a->[0] cmp $b->[0] } @entries;
        foreach my $helpEntry (@entries) {
		my ($helpName, $helpFile) = @{ $helpEntry };
                $output .= '<p><a href="'._linkTOC($helpFile).'">'.$helpName."</a></p>\n";
                $i++;
                if ($i % $third == 0) {
                        $output .= '</td><td valign="top">';
                }	
	}
	$output .= '</td></tr></table>';
	my $ac = WebGUI::AdminConsole->new($session,"help");
    	$ac->addSubmenuItem($session->url->page('op=viewHelpIndex'),WebGUI::International::get(95));
	return $ac->render($output, join ': ',WebGUI::International::get(93), WebGUI::International::get('help toc'));
}

#-------------------------------------------------------------------
sub www_viewHelpChapter {
	my $session = shift;
	return $session->privilege->insufficient() unless (WebGUI::Grouping::isInGroup(7));
	my $namespace = $session->form->process("namespace");
	my $help = _load($namespace);
	my @entries = sort keys %{ $help };
	my $output = '';
        foreach my $id (@entries) {
                $output .= '<p><a href="'._link($id,$namespace).'">'.WebGUI::International::get($help->{$id}{title},$namespace).'</a></p>';
	}
	my $ac = WebGUI::AdminConsole->new($session,"help");
    	$ac->addSubmenuItem($session->url->page('op=viewHelpIndex'),WebGUI::International::get(95));
    	$ac->addSubmenuItem($session->url->page('op=viewHelpTOC'),WebGUI::International::get('help contents'));
	return $ac->render($output, join ': ',WebGUI::International::get(93), _getHelpName($namespace));
}

1;
