package WebGUI::Utility;


=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2003 Plain Black LLC.
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

our @ISA = qw(Exporter);
our @EXPORT = qw(&makeTabSafe &makeArrayTabSafe &randomizeHash &commify &randomizeArray 
	&sortHashDescending &sortHash &isIn &makeCommaSafe &makeArrayCommaSafe &randint &round);


=head1 NAME

Package WebGUI::Utility

=head1 DESCRIPTION

This package provides miscellaneous but useful utilities to the WebGUI programmer.

=head1 SYNOPSIS

 use WebGUI::Utility;
 $string = commify($integer);
 $boolean = isIn($value, @array);
 makeArrayCommaSafe(\@array); 
 makeArrayTabSafe(\@array); 
 $string = makeCommaSafe($string);
 $string = makeTabSafe($string);
 $integer = randint($low,$high);
 randomizeArray(\@array);
 $hashRef = randomizeHash(\%hash);
 $hash = sortHash(%hash);
 $hash = sortHashDescending(%hash);

=head1 METHODS

These subroutines are available from this package:

=cut


#-------------------------------------------------------------------

=head2 commify ( integer )

Returns a number with commas applied at each third character.

=over

=item integer

Any old number will do.

=back

=cut

sub commify {
	my $text = reverse $_[0];
	$text =~ s/(\d\d\d)(?=\d)(?!\d*\.)/$1,/g;
	return scalar reverse $text;
}

#-------------------------------------------------------------------

=head2 isIn ( value, list )

Returns a boolean value as to whether the value is in the array.

=over

=item value

The value to check for.

=item list

An array to look for the value in.

=back

=cut

sub isIn {
	my $key = shift;
	$_ eq $key and return 1 for @_;
	return 0;
}

#-------------------------------------------------------------------

=head2 makeArrayCommaSafe ( array )

Searches through an array looking for commas and replaces them with semi-colons. Also replaces carriage returns with spaces. This is useful for exporting comma separated data.

=over

=item array

A reference to the array to look through.

=back

=cut

sub makeArrayCommaSafe {
	my $array = $_[0];
	$_ = makeCommaSafe($_) for @$array;
}

#-------------------------------------------------------------------

=head2 makeArrayTabSafe ( array )

Searches through an array looking for tabs and replaces them with four spaces. Also replaces carriage returns with a space. This is useful for exporting tab separated data.

=over

=item array

 A reference to the array to look through.

=back

=cut

sub makeArrayTabSafe {
	my $array = $_[0];
	$_ = makeTabSafe($_) for @$array;
}

#-------------------------------------------------------------------

=head2 makeCommaSafe ( text )

Replaces commas with semi-colons and carriage returns with spaces.

=over

=item text

The text to search through.

=back

=cut

sub makeCommaSafe {
	my $text = $_[0];
	$text =~ tr/,\r\n/; /;
	return $text;
}

#-------------------------------------------------------------------

=head2 makeTabSafe ( text )

Replaces tabs with four spaces and carriage returns with a space each.

=over

=item text

The text to search through.

=back

=cut

sub makeTabSafe {
	my $text = $_[0];
	$text =~ tr/\r\n/ /;
	$text =~ s/\t/    /g;
	return $text;
}

#-------------------------------------------------------------------

=head2 randint ( low, high )

Returns an integer between the low and high number.

=over

=item low

The lowest possible value. Defaults to 0.

=item high

The highest possible value. Defaults to 1.

=back

=cut

sub randint {
	my ($low, $high) = @_;
	$low = 0 unless defined $low;
	$high = 1 unless defined $high;
	($low, $high) = ($high,$low) if $low > $high;
	return $low + int( rand( $high - $low + 1 ) );
}

#-------------------------------------------------------------------

=head2 randomizeArray ( array )

Resorts an array in random order.

=over

=item array

A reference to the array to randomize.

=back

=cut

sub randomizeArray {
	my $array = shift;
	if ($#$array > 0) {
		for (my $i = @$array; --$i; ) {
			my $j = int rand ($i+1);
			next if $i == $j;
			@$array[$i,$j] = @$array[$j,$i];
		}
	}
}

#-------------------------------------------------------------------

=head2 randomizeHash ( hashRef )

Resorts a hash tied to IxHash in random order. Returns a hash reference.

=over

=item hashRef

A reference hash to randomize.

=back

=cut

sub randomizeHash {
	my $hash = $_[0];
	my @keys = keys %$hash;
	randomizeArray(\@keys);
	tie my %temp, 'Tie::IxHash';
	foreach my $key (@keys) {
		$temp{$key} = $hash->{$key};
	}
	return \%temp;
}

#-------------------------------------------------------------------

=head2 round ( real )

Returns an integer after rounding a real number.

=over

=item real

Any floating point number.

=back

=cut

sub round {
	my $significantDigits = $_[1] || 0;
        return sprintf(('%.'.$significantDigits.'f'), $_[0]);
}

#-------------------------------------------------------------------

=head2 sortHash ( hash )

Sorts a hash by its values. Returns a hash.

=over

=item hash

A hash to be sorted.

=back

=cut

sub sortHash {
	my %hash = @_;
	tie my %newHash, 'Tie::IxHash';
	for my $key ( sort { $hash{$a} cmp $hash{$b} } keys %hash ) {
		$newHash{ $key } = $hash{ $key };
	}
	return %newHash;
}

#-------------------------------------------------------------------

=head2 sortHashDecending ( hash )

Sorts a hash in decending order by its values. Returns a hash.

=over

=item hash

A hash to be sorted.

=back

=cut


sub sortHashDescending {
	my %hash = @_;
	tie my %newHash, 'Tie::IxHash';
	for my $key ( sort { $hash{$b} cmp $hash{$a} } keys %hash ) {
		$newHash{ $key } = $hash{ $key };
	}
	return %newHash;
}

1;


