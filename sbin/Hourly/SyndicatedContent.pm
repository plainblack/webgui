package Hourly::SyndicatedContent;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use HTTP::Request;
use LWP::UserAgent;
use strict;
use WebGUI::SQL;
use XML::RSSLite;

#-------------------------------------------------------------------
sub getRSS {
	my ($userAgent, $request, $response, $content, %result);
    	$userAgent = new LWP::UserAgent;
       	$request = new HTTP::Request (GET => $_[0]);
	$response = $userAgent->request($request);
	$content = $response->content;
	eval{parseXML(\%result, \$content)} or print $@;
	return %result;
}

#-------------------------------------------------------------------
sub generateHTML {
	my (%rss, $html, $item);
	%rss = @_;
	$html = $rss{title};
	$html = '<a href="'.$rss{link}.'" target="_blank">'.$html.'</a>' if ($rss{link});
	$html = '<h1>'.$html.'</h1>';
	$html .= $rss{description}.'<p>' if ($rss{description});
	foreach $item (@{$rss{items}}) {
		$html .= '<li>';
		if ($item->{link}) {
			$html .= '<a href="'.$item->{link}.'" target="_blank">'.$item->{title}.'</a>';
		} else {
			$html .= $item->{title};
		}
		$html .= ' - '.$item->{description} if ($item->{description});
		$html .= '<br>';
	}
	return ($html);
}

#-------------------------------------------------------------------
sub process {
	my ($sth, @data, %rss, $html);
	$sth = WebGUI::SQL->read("select wobject.wobjectId, SyndicatedContent.rssURL, SyndicatedContent.content 
		from wobject,SyndicatedContent where wobject.wobjectId=SyndicatedContent.wobjectId and wobject.pageId<>3",$_[0]);
	while (@data = $sth->array) {
		%rss = getRSS($data[1]);
		$html = generateHTML(%rss);
		if ($html ne "") {
			WebGUI::SQL->write("update SyndicatedContent set content=".$_[0]->quote($html).", lastFetched=".time()." 
				where wobjectId=$data[0]",$_[0]);
		} elsif (substr($data[2],6) ne "Unable" && substr($data[2],7) ne "Not yet") {
			# then just leave the existing content in place
		} else {
			WebGUI::SQL->write("update SyndicatedContent set content='Unable to fetch content. Perhaps the RSS is improperly formated.', 
				lastFetched=".time()." where wobjectId=$data[0]",$_[0]);
		}
	}
	$sth->finish;
}

1;

