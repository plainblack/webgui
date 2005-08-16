my $toVersion = "6.7.1";

use lib "../../lib";
use File::Path;
use Getopt::Long;
use strict;
use WebGUI::Asset;
use WebGUI::Asset::Wobject::Folder;
use WebGUI::Asset::Snippet;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Group;

my $configFile;
my $quiet;

GetOptions(
    'configFile=s'=>\$configFile,
	'quiet'=>\$quiet
);

WebGUI::Session::open("../..",$configFile);
WebGUI::Session::refreshUserInfo(3);

WebGUI::SQL->write("insert into webguiVersion values (".quote($toVersion).",'upgrade',".time().")");
fixForumRichEdit();


WebGUI::Session::close();


#-------------------------------------------------
sub fixForumRichEdit {
        print "\tFixing the forum rich editor properties.\n" unless ($quiet);
	my $validElements = 'a[name|href|target|title],strong/b[class],em/i[class],strike[class],u[class],p[dir|class|align],ol,ul,li,br,img[class|src|border=0|alt|title|hspace|vspace|width|height|align],sub,sup,blockquote[dir|style],table[border=0|cellspacing|cellpadding|width|height|class|align],tr[class|rowspan|width|height|align|valign],td[dir|class|colspan|rowspan|width|height|align|valign],div[dir|class|align],span[class|align],pre[class|align],address[class|align],h1[dir|class|align],h2[dir|class|align],h3[dir|class|align],h4[dir|class|align],h5[dir|class|align],h6[dir|class|align],hr';
	WebGUI::SQL->write("update RichEdit set validElements=".quote($prepend)." where assetId='PBrichedit000000000002'");
	WebGUI::SQL->write("update assetData set endDate=".(time()+60*60*24*365*20)." where assetId='PBrichedit000000000002'");
}


