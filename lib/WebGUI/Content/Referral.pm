package WebGUI::Content::Referral;

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
use WebGUI::Affiliate;


=head1 NAME

Package WebGUI::Content::Referral

=head1 DESCRIPTION

Processes referrals from other sites.

=head1 SYNOPSIS

 use WebGUI::Content::Referral;
 my $output = WebGUI::Content::Referral::handler($session);

=head1 SUBROUTINES

These subroutines are available from this package:

=cut

#-------------------------------------------------------------------

=head2 handler ( session ) 

The content handler for this package.

=cut

sub handler {
    my ($session) = @_;
    WebGUI::Affiliate::grabReferral($session);	# process affiliate tracking request
    return undef;
}

1;

