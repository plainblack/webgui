package WebGUI::Operation::Search;

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
use strict;
use WebGUI::HTMLForm;
use WebGUI::International;
use WebGUI::Paginator;
use WebGUI::Privilege;
use WebGUI::Search;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;

our @ISA = qw(Exporter);
our @EXPORT = qw(&www_search);

#-------------------------------------------------------------------
sub www_search {
        my ($constraints, $p, $output, %page, $sth, @row, $i, $url);
	$url = WebGUI::URL::page('op=search');
	$url = WebGUI::URL::append($url,'all='.$session{form}{all}) if ($session{form}{all} ne "");
	$url = WebGUI::URL::append($url,'exactPhrase='.$session{form}{exactPhrase}) if ($session{form}{exactPhrase} ne "");
	$url = WebGUI::URL::append($url,'atLeastOne='.$session{form}{atLeastOne}) if ($session{form}{atLeastOne} ne "");
	$url = WebGUI::URL::append($url,'without='.$session{form}{without}) if ($session{form}{without} ne "");
	$output = WebGUI::Search::form({op=>'search'});
        $constraints = WebGUI::Search::buildConstraints([qw(page.synopsis page.title page.menuTitle page.metaTags 
		page.urlizedTitle wobject.description wobject.title wobject.namespace)]);
        if ($constraints ne "") {
		tie %page, 'Tie::CPHash';
                $sth = WebGUI::SQL->read("select page.urlizedTitle,page.title,wobject.wobjectId,page.pageId from page,wobject where $constraints 
			and page.pageId=wobject.pageId and (page.pageId > 999 or page.pageId<=1) 
			and page.pageId<>$session{page}{pageId} order by lastEdited");
                while (%page = $sth->hash) {
			if (WebGUI::Privilege::canViewPage($page{pageId})) {
				$row[$i] = '<li><a href="'.WebGUI::URL::gateway($page{urlizedTitle}).'#'.$page{wobjectId}.'">'.$page{title}.'</a>';
				$i++;
			}
                }
                $sth->finish;
        }
	if ($row[0] ne "") {
		$p = WebGUI::Paginator->new($url,\@row,$session{form}{numResults});
		$output .= '<p/>'.WebGUI::International::get(365).'<p><ol>';
		$output .= $p->getPage($session{form}{pn});
		$output .= '</ol>'.$p->getBarTraditional($session{form}{pn});
	} elsif ($session{form}{exactPhrase} ne "" || $session{form}{all} ne "" || $session{form}{without} ne "" || $session{form}{atLeastOne} ne "") {
		$output .= '<p/>'.WebGUI::International::get(366).'<p/>';
	}
        return $output;
}



1;

