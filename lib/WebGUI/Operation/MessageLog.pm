package WebGUI::Operation::MessageLog;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2003 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use Exporter;
use strict qw(vars subs);
use URI;
use WebGUI::DateTime;
use WebGUI::ErrorHandler;
use WebGUI::FormProcessor;
use WebGUI::HTMLForm;
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::Mail;
use WebGUI::MessageLog;
use WebGUI::Paginator;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::User;
use WebGUI::Utility;
use WebGUI::Operation::Profile;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_viewMessageLog &www_viewMessageLogMessage);

#-------------------------------------------------------------------
sub www_viewMessageLog {
        my (%status, @data, $output, $sth, @row, $i, $p);
        if (WebGUI::Privilege::isInGroup(2,$session{user}{userId})) {
		%status = (notice=>WebGUI::International::get(551),pending=>WebGUI::International::get(552),completed=>WebGUI::International::get(350));
                $output = '<h1>'.WebGUI::International::get(159).'</h1>';
                $sth = WebGUI::SQL->read("select messageLogId,subject,url,dateOfEntry,status from messageLog where userId=$session{user}{userId} order by dateOfEntry desc");
                while (@data = $sth->array) {
                        $row[$i] = '<tr><td class="tableData">';
                        $row[$i] .= '<a href="'.WebGUI::URL::page('op=viewMessageLogMessage&mlog='.$data[0]).'">'.$data[1].'</a>';
			$row[$i] .= '</td><td class="tableData">';
                        if ($data[2] ne "") {
				$data[2] = WebGUI::URL::append($data[2],'mlog='.$data[0]);
                                $row[$i] .= '<a href="'.$data[2].'">';
                        }
                        $row[$i] .= $status{$data[4]};
                        if ($data[2] ne "") {
                                $row[$i] .= '</a>';
                        }
                        $row[$i] .= '</td><td class="tableData">'.epochToHuman($data[3]).'</td></tr>';
                        $i++;
                }
                $sth->finish;
                $p = WebGUI::Paginator->new(WebGUI::URL::page('op=viewMessageLog'),\@row);
                $output .= '<table width="100%" cellspacing=1 cellpadding=2 border=0>';
                $output .= '<tr><td class="tableHeader">'.WebGUI::International::get(351).'</td>
			<td class="tableHeader">'.WebGUI::International::get(553).'</td>
			<td class="tableHeader">'.WebGUI::International::get(352).'</td></tr>';
                if ($p->getPage($session{form}{pn}) eq "") {
                        $output .= '<tr><td rowspan=2 class="tableData">'.WebGUI::International::get(353).'</td></tr>';
                } else {
                        $output .= $p->getPage($session{form}{pn});
                }
                $output .= '</table>';
                $output .= $p->getBarSimple($session{form}{pn});
		$output .= WebGUI::Operation::Profile::accountOptions();
        } else {
                $output = WebGUI::Privilege::insufficient();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_viewMessageLogMessage {
        my (%status, %data, $output, $sth, @row, $i, $p);
	tie %data, 'Tie::CPHash';
        if (WebGUI::Privilege::isInGroup(2,$session{user}{userId})) {
        	%status = (notice=>WebGUI::International::get(551),pending=>WebGUI::International::get(552),completed=>WebGUI::International::get(350));
                $output = '<h1>'.WebGUI::International::get(159).'</h1>';
                %data = WebGUI::SQL->quickHash("select * from messageLog where messageLogId=$session{form}{mlog} and userId=$session{user}{userId}");
		$output .= '<b>'.$data{subject}.'</b><br>';
		$output .= epochToHuman($data{dateOfEntry}).'<br>';
                if ($data{url} ne "" && $data{status} eq 'pending') {
                	$data{url} = WebGUI::URL::append($data{url},'mlog='.$data{messageLogId});
                        $output .= '<a href="'.$data{url}.'">';
                }
		$output .= $status{$data{status}}.'<br>';
		if ($data{url} ne "") {
			$output .= '</a>';
		}
		unless ($data{message} =~ /\<div\>/ig || $data{message} =~ /\<br\>/ig || $data{message} =~ /\<p\>/ig) {
                        $data{message} =~ s/\n/\<br\>/g;
                }
		$output .= '<br>'.$data{message}.'<p>';
		if ($data{url} ne "" && $data{status} eq 'pending') {
                        $output .= '<a href="'.$data{url}.'">'.WebGUI::International::get(554).'</a> &middot; ';
                }
		$output .= '<a href="'.WebGUI::URL::page('op=viewMessageLog').'">'.WebGUI::International::get(354).'</a><p>';
        $output .= WebGUI::Operation::Profile::_accountOptions();
        } else {
                $output = WebGUI::Privilege::insufficient();
        }
        return $output;
}