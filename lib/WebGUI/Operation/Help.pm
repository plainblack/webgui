package WebGUI::Operation::Help;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black Software.
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
use Tie::CPHash;
use WebGUI::International;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::Utility;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_viewHelp &www_viewHelpIndex);

#-------------------------------------------------------------------
sub _helpLink {
	return '<a href="'.WebGUI::URL::page('op=viewHelp&hid='.$_[0].'&namespace='.$_[1]).'">'.$_[2].'</a>';
}

#-------------------------------------------------------------------
sub _seeAlso {
	my ($item, $seeAlso, @items, $namespace, $helpId, $titleId, $output);
	$seeAlso = $_[0];
	$seeAlso =~ s/\n//g; #removes line feeds
	$seeAlso =~ s/\r//g; #removes carriage returns
	$seeAlso =~ s/ //g; #removes spaces
	@items = split(/;/,$seeAlso);
	foreach $item (@items) {
		($helpId,$namespace) = split(/,/,$item);
		($titleId) = WebGUI::SQL->quickArray("select titleId from help where helpId=$helpId 
			and namespace='$namespace'");
		$output .= '<li>'._helpLink($helpId,$namespace,WebGUI::International::get($titleId,$namespace));
	}
	return $output;
}

#-------------------------------------------------------------------
sub www_viewHelp {
        my ($output, %help, $namespace);
	$namespace = $session{form}{namespace} || "WebGUI";
	tie %help, 'Tie::CPHash';
	%help = WebGUI::SQL->quickHash("select * from help where helpId=$session{form}{hid} and namespace='$namespace'");
        $output = '<h1>'.WebGUI::International::get(93).': '.
		WebGUI::International::get($help{titleId},$help{namespace}).'</h1>';
	$output .= WebGUI::International::get($help{bodyId},$help{namespace});
	$output .= '<p><b>'.WebGUI::International::get(94).':<ul>';
	$output .= _seeAlso($help{seeAlso});
        $output .= '<li><a href="'.WebGUI::URL::page('op=viewHelpIndex').'">'.WebGUI::International::get(95).'</a></ul>';
        return $output;
}

#-------------------------------------------------------------------
sub www_viewHelpIndex {
	my ($sth, %help, $output, $key, %index, $title, $seeAlso, %sortedIndex, $i, $midpoint);
	tie %help, 'Tie::CPHash';
	tie %sortedIndex, 'Tie::IxHash';
	$output = '<h1>'.WebGUI::International::get(95).'</h1>';
	$sth = WebGUI::SQL->read("select helpId,namespace,titleId,seeAlso from help");
	while (%help = $sth->hash) {
		$title = WebGUI::International::get($help{titleId},$help{namespace});
		$index{$title} = _helpLink($help{helpId},$help{namespace},$title);
		$seeAlso = _seeAlso($help{seeAlso});
		if ($seeAlso ne "") {
			$index{$title} .= '<span style="font-size: 11px"><ul>'.$seeAlso.'</ul></span>';
		}
		$i++;
	}
	$midpoint = round($i/2);
	$sth->finish;
	foreach $key (sort {$a cmp $b} keys %index) {
                $sortedIndex{$key}=$index{$key};
        }
	$i = 0;
	$output .= '<table width="100%"><tr><td width="50%" valign="top" class="content">';
	foreach $key (keys %sortedIndex) {
		if ($i == $midpoint) {
			$output .= '</td><td width="50%" valign="top" class="content">';
		}
		$output .= $sortedIndex{$key}.'<p>';
		$i++;
	}
	$output .= '</table>';
	return $output;
}

1;

