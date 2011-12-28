package WebGUI::ICal;

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

Package WebGUI::ICal

=head1 DESCRIPTION

This package wraps Data::ICal so the PRODUCT_ID parameter in the generated iCal feeds are set appropriately.

=head1 SYNOPSIS

 use WebGUI::ICal;

=cut


use WebGUI;
use base 'Data::ICal';

=head2 product_id 

Override the method from Data::ICal to set it to be the WebGUI version and status.

=cut

sub product_id {
    return 'WebGUI '. $WebGUI::VERSION . '-' . $WebGUI::STATUS;
}

1;
