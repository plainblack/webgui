#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use FindBin;
use strict;
use lib "$FindBin::Bin/../lib";

use WebGUI::Test;
use WebGUI::Macro;
use WebGUI::Session;
use WebGUI::Macro_Config;
use WebGUI::Image;
use WebGUI::Storage::Image;

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

unless ($session->config->get('macros')->{'Thumbnail'}) {
	Macro_Config::insert_macro($session, 'Thumbnail', 'Thumbnail');
}

my $square = WebGUI::Image->new($session, 100, 100);
$square->setBackgroundColor('1111FF');

##Create a storage location
my $storage = WebGUI::Storage::Image->get($session);

##Save the image to the location

##Initialize an Image Asset with that filename and storage location

##Call the Thumbnail Macro with that Asset's URL and see if it returns
##the correct URL.

##Do a file existance check.

##Load the image into some parser and check a few pixels to see if they're blue-ish.

##->Get('pixel[x,y]') hopefully returns color in hex triplets
