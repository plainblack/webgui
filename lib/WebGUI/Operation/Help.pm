package WebGUI::Operation::Help;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
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
use WebGUI::Utility;

#-------------------------------------------------------------------
sub _load {
	my $session = shift; use WebGUI; WebGUI::dumpSession($session);
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
	my $session = shift; use WebGUI; WebGUI::dumpSession($session);
	my $id = shift;
	my $namespace = shift;
	my $help = _load($session,$namespace);
	if (keys %{ $help } ) {
		return $help->{$id};
	}
	else {
		return "Unable to load help for $namespace -> $id\n";
	}
}

#-------------------------------------------------------------------
sub _link {
	my $session = shift; use WebGUI; WebGUI::dumpSession($session);
	return $session->url->page('op=viewHelp;hid='.$session->url->escape($_[0]).';namespace='.$_[1]);
}

#-------------------------------------------------------------------
sub _linkTOC {
	my $session = shift; use WebGUI; WebGUI::dumpSession($session);
	return $session->url->page('op=viewHelpChapter;namespace='.$_[0]);
}

#-------------------------------------------------------------------
sub _getHelpFilesList {
	my $session = shift; use WebGUI; WebGUI::dumpSession($session);
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
	my $session = shift; use WebGUI; WebGUI::dumpSession($session);
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
	my $i18n = WebGUI::International->new($session);
	return $i18n->get($helpName,$file);
}

#-------------------------------------------------------------------
sub _related {
	my ($session, $related) = @_;
	if (ref $related eq 'CODE') {
		return $related->($session);
	}
	else {
		return @{ $related };
	}
}

#-------------------------------------------------------------------
sub www_viewHelp {
	my $session = shift; use WebGUI; WebGUI::dumpSession($session);
	return $session->privilege->insufficient() unless ($session->user->isInGroup(7));
	my $ac = WebGUI::AdminConsole->new($session,"help");
	my $namespace = $session->form->process("namespace") || "WebGUI";
        my $i18n = WebGUI::International->new($session, $namespace);
	my $help = _get($session,$session->form->process("hid"),$namespace);
	my @related = _related($session, $help->{related});
	foreach my $row (@related) {
		my $relatedHelp = _get($session,$row->{tag},$row->{namespace});
		$ac->addSubmenuItem(_link($row->{tag},$row->{namespace}),$i18n->get($relatedHelp->{title},$row->{namespace}));
	}
        my %vars;
        $vars{body} = $i18n->get($help->{body});
        foreach my $row (@{ $help->{fields} }) {
                push @{ $vars{fields} }, 
                        { 'title' =>       $i18n->get($row->{title},$row->{namespace}),
                          'description' => $i18n->get($row->{description},$row->{namespace}), }
        }
        my $body = WebGUI::Asset::Template->new($session,"PBtmplHelp000000000001")->process(\%vars);
    	$ac->addSubmenuItem($session->url->page('op=viewHelpIndex'),$i18n->get(95, 'WebGUI'));
    	$ac->addSubmenuItem($session->url->page('op=viewHelpTOC'),$i18n->get('help contents', 'WebGUI'));
	WebGUI::Macro::process($session,\$body);
    	return $ac->render(
		$body, 
		$i18n->get(93, 'WebGUI').': '.$i18n->get($help->{title})
		);
}

#-------------------------------------------------------------------
sub www_viewHelpIndex {
	my $session = shift; use WebGUI; WebGUI::dumpSession($session);
	return $session->privilege->insufficient() unless ($session->user->isInGroup(7));
	my $i18n = WebGUI::International->new($session);
        my @helpIndex;
	my $i;
	my @files = _getHelpFilesList($session,);
        foreach my $fileSet (@files) {
		my $namespace = $fileSet->[1];
		my $help = _load($session,$namespace);
		foreach my $key (keys %{$help}) {
			push @helpIndex, [$namespace, $key,
					$i18n->get($help->{$key}{title},$namespace)];
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
    	$ac->addSubmenuItem($session->url->page('op=viewHelpTOC'),$i18n->get('help contents'));
	return $ac->render($output, join ': ',$i18n->get(93), $i18n->get('help index'));
}

#-------------------------------------------------------------------
sub www_viewHelpTOC {
	my $session = shift; use WebGUI; WebGUI::dumpSession($session);
	return $session->privilege->insufficient() unless ($session->user->isInGroup(7));
        my @helpIndex;
	my $i;
	my @files = _getHelpFilesList($session,);
	my $third = round(@files/3 + 0.50);
	my @entries;
	foreach my $fileSet (@files) {
		my $file = $fileSet->[1];
		push @entries, [_getHelpName($session,$file), $file];
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
	my $i18n = WebGUI::International->new($session);
	my $ac = WebGUI::AdminConsole->new($session,"help");
    	$ac->addSubmenuItem($session->url->page('op=viewHelpIndex'),$i18n->get(95));
	return $ac->render($output, join ': ',$i18n->get(93), $i18n->get('help toc'));
}

#-------------------------------------------------------------------
sub www_viewHelpChapter {
	my $session = shift; use WebGUI; WebGUI::dumpSession($session);
	return $session->privilege->insufficient() unless ($session->user->isInGroup(7));
	my $namespace = $session->form->process("namespace");
	my $help = _load($session,$namespace);
	my @entries = sort keys %{ $help };
	my $output = '';
	my $i18n = WebGUI::International->new($session);
        foreach my $id (@entries) {
                $output .= '<p><a href="'._link($id,$namespace).'">'.$i18n->get($help->{$id}{title},$namespace).'</a></p>';
	}
	my $ac = WebGUI::AdminConsole->new($session,"help");
    	$ac->addSubmenuItem($session->url->page('op=viewHelpIndex'),$i18n->get(95));
    	$ac->addSubmenuItem($session->url->page('op=viewHelpTOC'),$i18n->get('help contents'));
	return $ac->render($output, join ': ',$i18n->get(93), _getHelpName($session,$namespace));
}

1;
