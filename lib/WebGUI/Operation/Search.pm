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
use WebGUI::HTMLForm;
use WebGUI::International;
use WebGUI::Paginator;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_search);

#-------------------------------------------------------------------
sub www_search {
        my ($f, $p, $output, %page, @keyword, $pageId, $term, %result, $sth, @row, $i);
	$f = WebGUI::HTMLForm->new(1);
	$f->hidden("op","search");
	$f->text("keywords",'',$session{form}{keywords});
	$f->submit(WebGUI::International::get(364));
	$output = $f->print;
	if ($session{form}{keywords} ne "") {
		@keyword = split(" ",$session{form}{keywords});
		foreach $term (@keyword) {
			$sth = WebGUI::SQL->read("select pageId from page where title like '%".$term."%' and pageId > 25");
			while (($pageId) = $sth->array) {
				$result{$pageId} += 5;
			}
			$sth->finish;
                        $sth = WebGUI::SQL->read("select pageId from page where metaTags like '%".$term."%' and pageId > 25");
                        while (($pageId) = $sth->array) {
                                $result{$pageId} += 1;
                        }
                        $sth->finish;
			$sth = WebGUI::SQL->read("select pageId from page where synopsis like '%".$term."%' and pageId > 25");
                        while (($pageId) = $sth->array) {
                                $result{$pageId} += 4;
                        }
                        $sth->finish;
                        $sth = WebGUI::SQL->read("select pageId from wobject where title like '%".$term."%' and pageId > 25");
                        while (($pageId) = $sth->array) {
                                $result{$pageId} += 5;
                        }
                        $sth->finish;
                        $sth = WebGUI::SQL->read("select pageId from wobject where description like '%".$term."%' and pageId > 25");
                        while (($pageId) = $sth->array) {
                                $result{$pageId} += 2;
                        }
                        $sth->finish;
			foreach $pageId (sort{$result{$a} <=> $result{$b}} keys %result) {
				%page = WebGUI::SQL->quickHash("select pageId, title, urlizedTitle from page where pageId=$pageId");
				$row[$i] = '<li><a href="'.WebGUI::URL::gateway($page{urlizedTitle}).'">'.$page{title}.'</a>';
				$i++;
			}
		}
		if ($row[0] ne "") {
			$p = WebGUI::Paginator->new(WebGUI::URL::page('op=search'),\@row,20);
			$output .= WebGUI::International::get(365).'<p><ol>';
			$output .= $p->getPage($session{form}{pn});
			$output .= '</ol>'.$p->getBarTraditional($session{form}{pn});
			$output .= $f->print;
		} else {
			$output .= WebGUI::International::get(366);
		}
	}
        return $output;
}



1;

