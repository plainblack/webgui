package WebGUI::Operation::Root;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use Exporter;
use strict;
use Tie::CPHash;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Paginator;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_listRoots);

#-------------------------------------------------------------------
sub www_listRoots {
        my ($output, $p, $sth, %data, @row, $i);
        if (WebGUI::Privilege::isInGroup(3)) {
                $output = helpIcon(28);
		$output .= '<h1>'.WebGUI::International::get(408).'</h1>';
		$output .= '<div align="center"><a href="'.WebGUI::URL::page('op=editPage&npp=0').
			'">'.WebGUI::International::get(409).'</a></div>';
                $output .= '<table border=1 cellpadding=5 cellspacing=0 align="center">';
                $sth = WebGUI::SQL->read("select * from page where title<>'Reserved' and parentId=0 order by title");
                while (%data = $sth->hash) {
                        $row[$i] = '<tr><td valign="top" class="tableData">'.
				'<a href="'.WebGUI::URL::gateway($data{urlizedTitle}.'?op=deletePage').'">'.
				'<img src="'.$session{config}{extras}.'/delete.gif" border=0></a>'.
                                '<a href="'.WebGUI::URL::gateway($data{urlizedTitle}.'?op=cutPage').'">'.
                                '<img src="'.$session{config}{extras}.'/cut.gif" border=0></a>'.
				'<a href="'.WebGUI::URL::gateway($data{urlizedTitle}.'?op=editPage').'">'.
				'<img src="'.$session{config}{extras}.'/edit.gif" border=0></a>'.
                                '<a href="'.WebGUI::URL::gateway($data{urlizedTitle}).'">'.
                                '<img src="'.$session{config}{extras}.'/view.gif" border=0></a>'.
				'</td>';
                        $row[$i] .= '<td valign="top" class="tableData">'.$data{title}.'</td>';
                        $row[$i] .= '<td valign="top" class="tableData">'.$data{urlizedTitle}.'</td></tr>';
                        $i++;
                }
		$sth->finish;
                $p = WebGUI::Paginator->new(WebGUI::URL::page('op=listRoots'),\@row);
                $output .= '<table border=1 cellpadding=5 cellspacing=0 align="center">';
                $output .= $p->getPage($session{form}{pn});
                $output .= '</table>';
                $output .= $p->getBarTraditional($session{form}{pn});
                return $output;
        } else {
                return WebGUI::Privilege::adminOnly();
        }
}


1;
