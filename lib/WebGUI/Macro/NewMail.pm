package WebGUI::Macro::NewMail;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Inbox;

=head1 NAME

Package WebGUI::Macro::NewMail

=head1 DESCRIPTION

Macro for alerting user that new mail is waiting for them and links to the inbox

=head2 process ( )

=cut

#-------------------------------------------------------------------
sub _createURL {
	my $session = shift;
	my $text    = shift;
    my $class   = shift;
	my $url     =  '<a href="'.$session->url->page("op=account;module=inbox").'"';
    $url .= ' class="'.$class.'"' if($class);
    $url .= '>'.$text.'</a>';
    return $url;
}

#-------------------------------------------------------------------

=head2 process ( class )

=head3 class

optional css class to assign to the hyperlink

=cut


sub process {
    my $session = shift;
    my $class   = $_[0];
    
    my $count   = WebGUI::Inbox->new($session)->getUnreadMessageCount;
    my $output  = "";
    
    if($count > 0) {
       my $i18n    = WebGUI::International->new($session);
       $output = sprintf($i18n->get("private message unread display message"),$count);
       $output = _createURL($session,$output,$class);
    }
    
    return $output;
}

1;
