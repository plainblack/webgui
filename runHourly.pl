#-------------------------------------------------------------------
# WebGUI is Copyright 2001 Plain Black Software.
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
use XML::RSS;

my $config = new Data::Config './etc/WebGUI.conf';
our $dbh = DBI->connect($config->param('dsn'), $config->param('dbuser'), $config->param('dbpass'));

deleteExpiredSessions();
updateSyndicatedContent();

$dbh->disconnect();

#-------------------------------------------------------------------
sub deleteExpiredSessions {
	WebGUI::SQL->write("delete from session where expires<".time(),$dbh);
}

#-------------------------------------------------------------------
sub getRSS {
	my ($rss, $userAgent, $request, $response);
    	$userAgent = new LWP::UserAgent;
       	$request = new HTTP::Request (GET => $_[0]);
	$response = $userAgent->request($request);
	$rss = new XML::RSS;
	$rss->parse($response->content);
	return $rss;
}

#-------------------------------------------------------------------
sub generateHTML {
	my ($rss, $image, $content, $copyright, $title, $link, $description, $name, $url, $item, $html, $width, $height);
	$rss = $_[0];
  #-- image
    	$url = $rss->{'image'}->{'url'};
    	if ($url) {
      		$link = $rss->{'image'}->{'link'} || "";
      		$title = $rss->{'image'}->{'title'} || "";
      		$width = $rss->{'image'}->{'width'} || "";
      		$height = $rss->{'image'}->{'height'} || "";
      		$width = 'width="'.$width.'"' if ($width);
      		$height = 'height="'.$height.'"' if ($height);
      		$image = '<img src="'.$url.'" alt="'.$title.'" border=0 $width $height>';
      		$image = '<a target="_NEWSITEM" href="'.$link.'">'.$image.'</a>' if ($link);
	}
  #-- items
    	$html = ($image) ? '<div align="center">'.$image.'</div>' : "";
    	foreach $item (@{$rss->{'items'}}) {
        	next unless defined($item->{'title'}) && defined($item->{'link'});
        	$title = $item->{'title'} if (defined ($item->{'title'}));
        	$description = $item->{'description'} if (defined ($item->{'description'}));
        	$url = $item->{'link'} if (defined ($item->{'link'}));
        	$html .= "<li><a target='_NEWSITEM' href='$url'>$title</a><br>\n";
    	}
  #-- form
    	$title = $rss->{'textinput'}->{'title'};
    	if ($title) {
      		$link = $rss->{'textinput'}->{'link'};
      		$description = $rss->{'textinput'}->{'description'};
      		$name = $rss->{'textinput'}->{'name'};
      		$html .= '<p><form method="get" action="'.$link.'">';
      		$html .= $description.'<br>';
      		$html .= '<input type="text" name="'.$name.'"><br>';
      		$html .= '<input type="submit" value="'.$title.'"></form>';
    	}
    	$copyright = $rss->{'channel'}->{'copyright'};
  #-- copyright
    	if ($copyright) {
        	$html .= "<p><sub>$copyright</sub></p>";
      	}
  #-- title
    	$title = $rss->{'channel'}->{'title'};
    	$title =~ s/^\s*//;
	return ($html);
}

#-------------------------------------------------------------------
sub updateSyndicatedContent {
	my ($sth, @data, $rss, $html);
	$sth = WebGUI::SQL->read("select widget.widgetId, SyndicatedContent.rssURL, SyndicatedContent.content from widget,SyndicatedContent where widget.WidgetId=SyndicatedContent.widgetId and widget.pageId<>3",$dbh);
	while (@data = $sth->array) {
		$rss = getRSS($data[1]);
		$html = generateHTML($rss);
		if ($html ne "") {
			WebGUI::SQL->write("update SyndicatedContent set content=".$dbh->quote($html).", lastFetched=".time()." where widgetId=$data[0]",$dbh);
		} elsif (substr($data[2],6) ne "Unable" && substr($data[2],7) ne "Not yet") {
			# then just leave the existing content in place
		} else {
			WebGUI::SQL->write("update SyndicatedContent set content='Unable to fetch content. Perhaps the RSS is improperly formated.', lastFetched=".time()." where widgetId=$data[0]",$dbh);
		}
	}
	$sth->finish;
}

