#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use lib "../../lib";
use strict;
use Getopt::Long;
use WebGUI::Session;


my $toVersion = "7.3.16"; # make this match what version you're going to
my $quiet; # this line required


my $session = start(); # this line required

trackEmails($session);
fixCss($session);

finish($session); # this line required


#-------------------------------------------------
sub trackEmails {
	my $session = shift;
	print "\tTrack email messages for future debugging purposes.\n" unless ($quiet);
    $session->db->write("alter table Post add column originalEmail mediumtext");
}

#-------------------------------------------------
sub fixCss {
	my $session = shift;
	print "\tFixing default css 03 template.\n" unless ($quiet);
    my $css = <<STOP;
body, html {
        margin:0px;
        background-color:#b53018;
        padding:0px;
}
body a {
        color:#EE963E;font-weight:bold;
 letter-spacing:1px;
 font-size:8pt;
}
#main {
        width:98%;
        /*min-width:790px;*/
        margin:0px;
        padding:0px;
        padding-top:20px;
        padding-bottom:20px;
        position:relative;
}
#header { 
        background: url('^FileUrl(style3/header_bg.jpg);') repeat-x;
        width:100%;
        margin:0px;
        height:115px;
}
#headerTitle {
        background: url('^FileUrl(style3/header_left.jpg);') no-repeat left top;
        height:100%;
        width:100%;
}
#headerRight {
        background: url('^FileUrl(style3/header_right.jpg);') no-repeat right top;
        width:100%;
        height:100%;
        text-align:right;
        position:relative;
}
#headerRight #title {
        position:absolute;
        top:25px;
        left:20px;
        font-family:arial;
        text-align:left;
}
#title h1 {
        text-transform:uppercase;
        margin-bottom:0px;
        font-weight:normal;
        font-size:26pt;
        margin-top:0px;
        color:white;
}
#title h1 a {
        color:white;
        text-decoration:none; font-size: 26pt; font-weight: normal; 
}
#title h2 {
        margin:0px;
        font-size:12pt;
        color:#bebebe;
        padding-left:20px;
}
#title img {
        z-index:5;
}
#login {
        position:absolute;
        font-size:8pt;
        top:45%;
        right:150px;
        color:white;
        z-index:6;
        font-family:arial;
}
#login a {
        color:white; font-weight: normal; letter-spacing: 0px;
}
.loginBox {
        font-size:8pt;
        margin:0px;
        display:inline;
}
.loginBox input {
        font-size:8pt;
}

#mainBody {
        width:100%;
        margin:0px;
        height:500px;
        background: #fff;
        position:relative;
	z-index:0;
}
#main > #mainBody {
        height:auto;
        min-height:500px;
}
#contentArea {
        z-index:2;
        position:relative;
        padding-top:50px;
        padding-left:10px;
        padding-right:20px;
        padding-bottom:20px;
        -moz-box-sizing:border-box;
        font-family:verdana;
        font-size:9pt;

}
html #main #mainBody #contentArea {
        height:1%;
}
#topCorner {
        width:100%;
        height:214px;
        position:absolute;
        top:0px;
        left:0px;
        background: url('^FileUrl(style3/main_top_bg.jpg);') repeat-x;
        z-index:1;
}
#bottomCorner {
        width:100%;
        height:211px;
        position:absolute;
        bottom:59px;
        right:0px;
        background: url('^FileUrl(style3/main_bottom.jpg);') no-repeat right;
        z-index:1;
}
* html #bottomCorner {
	bottom:58px;
}

#footer {
        width:100%;
        margin:0px;
        background:#000 url('^FileUrl(style3/footer_right.jpg);') no-repeat right top;
        height:57px;
        border-top:solid #B53018 2px;
        text-align:right;
        position:relative;
		z-index:0;
}
#footer #copyright {
        color:#3b3b3b;
        font-family:arial;
        position:absolute;
        top:20px;
        left:30px;
        font-size:8pt;
}

STOP
    my $asset = WebGUI::Asset->new($session, "7.0-style0000000000051", "WebGUI::Asset::Snippet");
    if (defined $asset) {
            $asset->addRevision({snippet=>$css});
    }
}



# ---- DO NOT EDIT BELOW THIS LINE ----

#-------------------------------------------------
sub start {
	my $configFile;
	$|=1; #disable output buffering
	GetOptions(
    		'configFile=s'=>\$configFile,
        	'quiet'=>\$quiet
	);
	my $session = WebGUI::Session->open("../..",$configFile);
	$session->user({userId=>3});
	my $versionTag = WebGUI::VersionTag->getWorking($session);
	$versionTag->set({name=>"Upgrade to ".$toVersion});
	$session->db->write("insert into webguiVersion values (".$session->db->quote($toVersion).",'upgrade',".$session->datetime->time().")");
	updateTemplates($session);
	return $session;
}

#-------------------------------------------------
sub finish {
	my $session = shift;
	my $versionTag = WebGUI::VersionTag->getWorking($session);
	$versionTag->commit;
	$session->close();
}

#-------------------------------------------------
sub updateTemplates {
	my $session = shift;
	return undef unless (-d "templates-".$toVersion);
        print "\tUpdating templates.\n" unless ($quiet);
	opendir(DIR,"templates-".$toVersion);
	my @files = readdir(DIR);
	closedir(DIR);
	my $importNode = WebGUI::Asset->getImportNode($session);
	my $newFolder = undef;
	foreach my $file (@files) {
		next unless ($file =~ /\.tmpl$/);
		open(FILE,"<templates-".$toVersion."/".$file);
		my $first = 1;
		my $create = 0;
		my $head = 0;
		my %properties = (className=>"WebGUI::Asset::Template");
		while (my $line = <FILE>) {
			if ($first) {
				$line =~ m/^\#(.*)$/;
				$properties{id} = $1;
				$first = 0;
			} elsif ($line =~ m/^\#create$/) {
				$create = 1;
			} elsif ($line =~ m/^\#(.*):(.*)$/) {
				$properties{$1} = $2;
			} elsif ($line =~ m/^~~~$/) {
				$head = 1;
			} elsif ($head) {
				$properties{headBlock} .= $line;
			} else {
				$properties{template} .= $line;	
			}
		}
		close(FILE);
		if ($create) {
			$newFolder = createNewTemplatesFolder($importNode) unless (defined $newFolder);
			my $template = $newFolder->addChild(\%properties, $properties{id});
		} else {
			my $template = WebGUI::Asset->new($session,$properties{id}, "WebGUI::Asset::Template");
			if (defined $template) {
				my $newRevision = $template->addRevision(\%properties);
			}
		}
	}
}

#-------------------------------------------------
sub createNewTemplatesFolder {
	my $importNode = shift;
	my $newFolder = $importNode->addChild({
		className=>"WebGUI::Asset::Wobject::Folder",
		title => $toVersion." New Templates",
		menuTitle => $toVersion." New Templates",
		url=> $toVersion."_new_templates",
		groupIdView=>"12"
		});
	return $newFolder;
}



