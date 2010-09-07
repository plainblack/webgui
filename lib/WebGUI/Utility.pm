package WebGUI::Utility;


=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut


use Exporter;
use strict;
use Tie::IxHash;
use Net::CIDR::Lite;

our @ISA = qw(Exporter);
our @EXPORT = qw(
	&sortHash
	);


=head1 NAME

Package WebGUI::Utility

=head1 DESCRIPTION

This package provides miscellaneous but useful utilities to the WebGUI programmer.

=head1 SYNOPSIS

 use WebGUI::Utility;
 %hash = sortHash(%hash);

=head1 METHODS

These subroutines are available from this package:

=cut

#-------------------------------------------------------------------

=head2 sortHash ( hash )

Sorts a hash by its values. Returns a Tie::IxHash.  You must assign this to
a similarly tied hash to preserve the order.

=head3 hash

A hash to be sorted.

=cut

sub sortHash {
	my %hash = @_;
	tie my %newHash, 'Tie::IxHash';
	for my $key ( sort { $hash{$a} cmp $hash{$b} } keys %hash ) {
		$newHash{ $key } = $hash{ $key };
	}
	return %newHash;
}


1;
