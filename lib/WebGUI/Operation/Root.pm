package WebGUI::Operation::Root;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2004 Plain Black LLC.
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
use WebGUI::Grouping;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Operation::Shared;
use WebGUI::Paginator;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_listRoots);

#-------------------------------------------------------------------
sub _submenu {
        my (%menu);
        tie %menu, 'Tie::IxHash';
	$menu{WebGUI::URL::page('op=editPage&npp=0')} = WebGUI::International::get(409);
        return menuWrapper($_[0],\%menu);
}

#-------------------------------------------------------------------
sub www_listRoots {
        return WebGUI::Privilege::adminOnly() unless(WebGUI::Grouping::isInGroup(3));
        my ($output, $p, $sth, %data, @row, $i);
        $output = helpIcon(28);
	$output .= '<h1>'.WebGUI::International::get(408).'</h1>';
        $sth = WebGUI::SQL->read("select * from page where title<>'Reserved' and parentId=0 order by title");
        while (%data = $sth->hash) {
                $row[$i] = '<tr><td valign="top" class="tableData">'
			.deleteIcon('op=deletePage',$data{urlizedTitle})
			.editIcon('op=editPage',$data{urlizedTitle})
			.cutIcon('op=cutPage',$data{urlizedTitle})
			.'</td>';
                $row[$i] .= '<td valign="top" class="tableData"><a href="'.WebGUI::URL::gateway($data{urlizedTitle}).'">'.$data{title}.'</a></td>';
                $row[$i] .= '<td valign="top" class="tableData">'.$data{urlizedTitle}.'</td></tr>';
                $i++;
        }
	$sth->finish;
        $p = WebGUI::Paginator->new(WebGUI::URL::page('op=listRoots'));
	$p->setDataByArrayRef(\@row);
        $output .= '<table border=1 cellpadding=3 cellspacing=0 align="center">';
        $output .= $p->getPage;
        $output .= '</table>';
        $output .= $p->getBarTraditional;
        return _submenu($output);
}


1;
