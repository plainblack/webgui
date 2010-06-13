#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

# this test can take two parameters
# first is an xml file, second indicates
# the percentage of items to test.
# the xml file can be downloaded from
# http://www.user-agents.org/
# the percent will default to 25 and
# should be passed as a whole number
# so 100 will test all items, 75 will
# test 75% or 3 out of four items

use FindBin;
use strict;
use lib "$FindBin::Bin/lib";
use lib '/data/WebGUI/t/lib';

use WebGUI::Test;
use WebGUI::Session;

use Test::More; 

my $session = WebGUI::Test->session;

# this test is for code in the WebGUI::Session::Env Module

my @testArray = (
    {
           agent => "",
           output => 1,
           comment => "blank user agent"
    },
    {
           agent => "&lt;a href='http://www.unchaos.com/'> UnChaos &lt;/a> From Chaos To Order Hybrid Web Search Engine.(vadim_goncharunchaos.com)",
           output => 1,
           comment => "UnChaos hybrid search engine"
    },
    {
           agent => "(DreamPassport/3.0; isao/MyDiGiRabi)",
           output => 0,
           comment => "DreamCast DreamPassport browser"
    },
    {
           agent => "Privoxy web proxy",     # I think proxy's whould be considered browsers?
           output => 0,
           comment => "s.also Privoxy/3.0 (Anonymous)"
    },
    {
           agent => "123spider-Bot (Version: 1.02&#44; powered by www.123spider.de",
           output => 1,
           comment => "123spider.de (Germany) web directory link checking"
    },
    {
           agent => "1st ZipCommander (Net) - http://www.zipcommander.com/",
           output => 0,
           comment => "1st ZipCommander Net - IE based browser"
    },
    {
           agent => "2Bone_LinkChecker/1.0 libwww-perl/5.64",
           output => 1,
           comment => "2Bone online link checker"
    },
    {
           agent => "A-Online Search",
           output => 1,
           comment => "A-Online.at robot - now Jet2Web Search"
    },
    {
           agent => "Advanced Browser (http://www.avantbrowser.com)",
           output => 0,
           comment => "Avant Browser - IE based browser"
    },
    {
           agent => "AESOP_com_SpiderMan",
           output => 1,
           comment => "Aesop robot"
    },
    {
           agent => "Mozilla/5.0 (compatible; SpurlBot/0.2)",
           output => 1,
           comment => "Spurl.net bookmark service & search engine (84.40.30.xxx)"
    },
    {
           agent => "Mozilla/5.0 (compatible;MAINSEEK_BOT)",
           output => 1,
           comment => "Mozilla/5.0 (compatible;MAINSEEK_BOT)"
    },
    {
           agent => "Mozilla/5.0 (Macintosh; U; PPC Mac OS X Mach-O; en-US; rv:1.0.1) Gecko/20021219 Chimera/0.6",
           output => 0,
           comment => "Chimera browser (Mozilla/Gecko engine) - now Camino Mac PowerPC"
    },
    {
           agent => "Mozilla/5.0 (Macintosh; U; PPC Mac OS X; en-US) AppleWebKit/xx (KHTML like Gecko) OmniWeb/v5xx.xx",
           output => 0,
           comment => "OmniWeb 5.x.x Mac OS X browser"
    },
    {
           agent => "Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:x.x.x) Gecko/20041107 Firefox/x.x",
           output => 0,
           comment => "Firefox browser (Mozilla/Gecko engine) - ex Firebird WinXP"
    },
    {
           agent => "Mozilla/5.0 (Windows; U; Windows NT 5.1; fr; rv:1.8.1) VoilaBot BETA 1.2 (support.voilabotorange-ftgroup.com)",
           output => 1,
           comment => "Voila.fr robot"
    },
    {
           agent => "Mozilla/5.0 (Windows;) NimbleCrawler 1.12 obeys UserAgent NimbleCrawler For problems contact: crawlerhealth",
           output => 1,
           comment => "Healthline health related search robot (72.5.115.xx)"
    },
    {
           agent => "Mozilla/5.0 (X11; U; Linux i686; de-AT; rv:1.8.0.2) Gecko/20060309 SeaMonkey/1.0",
           output => 0,
           comment => "SeaMonkey browser suite (ex Mozilla) on Linux"
    },
    {
           agent => "Mozilla/5.0 [en] (compatible; Gulper Web Bot 0.2.4 www.ecsl.cs.sunysb.edu/~maxim/cgi-bin/Link/GulperBot)",
           output => 1,
           comment => "Yuntis : Collaborative Web Resource Categorization and Ranking Project robot"
    },
);

sub transType {
    return 0 if $_[0] =~ /(B|P)/;   # browser or proxy
    return 1;
}

sub getAddress {     # There are precious few that have an IP that can be gotten out of the XML so I decided to skip this.
   my $x = '69.42.78.32';
   #if( $_[0]{Comment} =~ /\d\.\d\.\d/ ) {
   #    print $_[0]{Comment},"\t|\t",$_[0]{Description},"\n";
   #    $x = $_[0]{Comment};
   #    $x =~ s/x/2/;
   #}
   return $x;
}

sub testCount {

    if( @ARGV ) {
        if( $ARGV[0] =~ /\.xml$/ && -r $ARGV[0] ) {
             my $infile = shift @ARGV ;
	     my $percent = shift @ARGV || 25;
	     use XML::Simple;
	     my $xml = new XML::Simple;
	     my $data = $xml->XMLin($infile);
	     # use Data::Dumper;
	     # print Dumper $data;
	     @testArray = ();
	     my $c = 1;
	     my $div = 20;
             my $n = $div * $percent / 100;
	     foreach my $set (@{$data->{'user-agent'}}) {
                 $c = 1 if $c > $div;
	         if( $c <= $n ) {
		     push @testArray, {
		         agent =>  $set->{String},
			 output =>  transType($set->{Type}),
			 type =>  $set->{Type},
			 comment => $set->{Description},
			 # comment => $set->{String},   # this is handy for fine tuning the code: it shows the string that failed...
			 address => getAddress($set),
		     };
		 }
		 $c ++;
	     }
	     # use Data::Dumper;
	     # print Dumper \@testArray;
	}
    }
    return scalar(@testArray);
}


plan tests => testCount() ;

foreach my $testSet (@testArray) {
    $session->request->env->{HTTP_USER_AGENT} = $testSet->{agent};
    $session->request->env->{REMOTE_ADDR} = $testSet->{address} || '69.42.78.32';
    my $output = $session->env->requestNotViewed;
    is($output, $testSet->{output}, $testSet->{comment});
}

