package WebGUI::Operation::Search;

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
use WebGUI::International;
use WebGUI::Paginator;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::Shortcut;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::Utility;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_search);

#-------------------------------------------------------------------
sub www_search {
        my ($p, $output, %page, @keyword, $pageId, $term, %result, $sth, @data, @row, $i);
	tie %result,'Tie::IxHash';
	$output = formHeader();
	$output .= WebGUI::Form::hidden("op","search");
	$output .= WebGUI::Form::text("keywords",40,100,$session{form}{keywords});
	$output .= WebGUI::Form::submit(WebGUI::International::get(364));
	$output .= '</form>';
	if ($session{form}{keywords} ne "") {
		@keyword = split(" ",$session{form}{keywords});
		foreach $term (@keyword) {
			$sth = WebGUI::SQL->read("select pageId from page where title like '%".$term."%' and pageId > 25");
			while (@data = $sth->array) {
				$result{$data[0]} += 5;
			}
			$sth->finish;
                        $sth = WebGUI::SQL->read("select pageId from page where metaTags like '%".$term."%' and pageId > 25");
                        while (@data = $sth->array) {
                                $result{$data[0]} += 1;
                        }
                        $sth->finish;
                        $sth = WebGUI::SQL->read("select pageId from widget where title like '%".$term."%' and pageId > 25");
                        while (@data = $sth->array) {
                                $result{$data[0]} += 5;
                        }
                        $sth->finish;
                        $sth = WebGUI::SQL->read("select pageId from widget where description like '%".$term."%' and pageId > 25");
                        while (@data = $sth->array) {
                                $result{$data[0]} += 2;
                        }
                        $sth->finish;
                        $sth = WebGUI::SQL->read("select widget.pageId from Article,widget where Article.widgetId=widget.widgetId and Article.body like '%".$term."%'");
                        while (@data = $sth->array) {
                                $result{$data[0]} += 2;
                        }
                        $sth->finish;
			%result = sortHashDescending(%result);
			foreach $pageId (keys %result) {
				%page = WebGUI::SQL->quickHash("select pageId, title, urlizedTitle from page where pageId=$pageId");
				$row[$i] = '<li><a href="'.$session{ENV}{SCRIPT_NAME}.'/'.$page{urlizedTitle}.'">'.$page{title}.'</a>';
				$i++;
			}
		}
		if ($row[0] ne "") {
			$p = WebGUI::Paginator->new(WebGUI::URL::page('op=search'),\@row,20);
			$output .= WebGUI::International::get(365).'<p><ol>';
			$output .= $p->getPage($session{form}{pn});
			$output .= '</ol>'.$p->getBarTraditional($session{form}{pn});
		} else {
			$output .= WebGUI::International::get(366);
		}
	}
        return $output;
}



1;

