package WebGUI::BestPractices;

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

=head1 NAME

WebGUI::BestPractices - Enable WebGUI best practice pragmas

=head1 SYNOPSIS

    use WebGUI::BestPractices;

=head1 DESCRIPTION

This module is the equivalent of adding the following to your module:

    use strict;
    use warnings;
    no warnings 'uninitialized';
    use feature;
    use namespace::autoclean;

=cut

use strict;
use warnings;
use feature ':5.10';
use namespace::autoclean ();

sub import {
    my $caller = caller;
    strict->import;
    warnings->import;
    warnings->unimport('uninitialized');
    feature->import(':5.10');
    namespace::autoclean->import( -cleanee => $caller );
}

1;
