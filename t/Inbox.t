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
use lib "$FindBin::Bin/lib";
use WebGUI::Test;
use WebGUI::Session;

use WebGUI::Inbox;

use Test::More tests => 3; # increment this value for each test you create

my $session = WebGUI::Test->session;

# Begin tests...
my $inbox = WebGUI::Inbox->new($session); 
ok(defined ($inbox), 'new("new") -- object reference is defined');

my $message_body = 'Test message';

my $new_message = {
    message => $message_body,
    groupId => 3,
    userId => 1,
    
};

my $message = $inbox->addMessage($new_message);
ok(defined($message), 'addMessage returned a response');
ok($message->{_properties}{message} eq $message_body, 'Message body set');
