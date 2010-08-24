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
	&sortHash &isIn &round
	);


=head1 NAME

Package WebGUI::Utility

=head1 DESCRIPTION

This package provides miscellaneous but useful utilities to the WebGUI programmer.

=head1 SYNOPSIS

 use WebGUI::Utility;
 $boolean = isIn($value, @array);
 $rounded = round($number, $digits);
 %hash = sortHash(%hash);

=head1 METHODS

These subroutines are available from this package:

=cut

#-------------------------------------------------------------------

=head2 isIn ( value, list )

Returns a boolean value as to whether the value is in the array.

=head3 value

The value to check for.

=head3 list

An array to look for the value in.

=cut

sub isIn {
	my $key = shift;
	$_ eq $key and return 1 for @_;
	return 0;
}

#-------------------------------------------------------------------

=head2 round ( float [, significantDigits ] )

Returns an integer after rounding a floating point number.

=head3 float

Any floating point number.

=head3 significantDigits

The number of digits to leave after the decimal point. Defaults to 0.

B<NOTE:> If you set this higher than 0 then you'll get back another floating point number rather than an integer.

=cut

sub round {
	my $significantDigits = $_[1] || 0;
        return sprintf(('%.'.$significantDigits.'f'), $_[0]);
}

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
