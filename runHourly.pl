#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

BEGIN {
        unshift (@INC, "./lib");
}

use DBI;
use HTTP::Request;
use LWP::UserAgent;
use strict;
use Data::Config;
use WebGUI::SQL;
use RSSLite;

my $config = new Data::Config './etc/WebGUI.conf';
our $dbh = DBI->connect($config->param('dsn'), $config->param('dbuser'), $config->param('dbpass'));

deleteExpiredSessions();
updateSyndicatedContent();

$dbh->disconnect();

#-------------------------------------------------------------------
sub deleteExpiredSessions {
	WebGUI::SQL->write("delete from userSession where expires<".time(),$dbh);
}

#-------------------------------------------------------------------
sub getRSS {
	my ($userAgent, $request, $response, $content, %result);
    	$userAgent = new LWP::UserAgent;
       	$request = new HTTP::Request (GET => $_[0]);
	$response = $userAgent->request($request);
	$content = $response->content;
	parseXML(\%result, \$content);
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
sub updateSyndicatedContent {
	my ($sth, @data, %rss, $html);
	$sth = WebGUI::SQL->read("select wobject.wobjectId, SyndicatedContent.rssURL, SyndicatedContent.content from wobject,SyndicatedContent where wobject.wobjectId=SyndicatedContent.wobjectId and wobject.pageId<>3",$dbh);
	while (@data = $sth->array) {
		%rss = getRSS($data[1]);
		$html = generateHTML(%rss);
		if ($html ne "") {
			WebGUI::SQL->write("update SyndicatedContent set content=".$dbh->quote($html).", lastFetched=".time()." where wobjectId=$data[0]",$dbh);
		} elsif (substr($data[2],6) ne "Unable" && substr($data[2],7) ne "Not yet") {
			# then just leave the existing content in place
		} else {
			WebGUI::SQL->write("update SyndicatedContent set content='Unable to fetch content. Perhaps the RSS is improperly formated.', lastFetched=".time()." where wobjectId=$data[0]",$dbh);
		}
	}
	$sth->finish;
}

