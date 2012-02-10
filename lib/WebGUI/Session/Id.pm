package WebGUI::Session::Id;


=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2012 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use WebGUI::GUID;

=head1 NAME

Package WebGUI::Session::Id;

=head1 DESCRIPTION

This module is deprecated, and will be removed during the WebGUI 8.x series.

This package generates global unique ids, sometimes called GUIDs. A global unique ID is guaranteed to be unique everywhere and at everytime.

B<NOTE:> There is no such thing as perfectly unique ID's, but the chances of a duplicate ID are so minute that they are effectively unique.

=head1 SYNOPSIS

 my $id = $session->id->generate;

=head1 METHODS

These methods are available from this class:

=cut

=head2 new

Object contructor

=cut

sub new {
    my $class = shift;
    return bless {}, $class;
}

for my $sub (qw(fromHex getValidator generate toHex valid)) {
    no strict 'refs';
    *{$sub} = sub {
        goto &{"WebGUI::GUID::$sub"};
    };
}

1;

