package WebGUI::Utility;


=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2006 Plain Black Corporation.
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
our @EXPORT = qw(&isBetween &makeTabSafe &makeArrayTabSafe &randomizeHash &commify &randomizeArray 
	&formatBytes &sortHashDescending &sortHash &isIn &makeCommaSafe &makeArrayCommaSafe &randint &round
	);


=head1 NAME

Package WebGUI::Utility

=head1 DESCRIPTION

This package provides miscellaneous but useful utilities to the WebGUI programmer.

=head1 SYNOPSIS

 use WebGUI::Utility;
 $string = commify($integer);
 $size = formatBytes($integer);
 $boolean = isIn($value, @array);
 makeArrayCommaSafe(\@array); 
 makeArrayTabSafe(\@array); 
 $string = makeCommaSafe($string);
 $string = makeTabSafe($string);
 $integer = randint($low,$high);
 randomizeArray(\@array);
 $hashRef = randomizeHash(\%hash);
 %hash = sortHash(%hash);
 %hash = sortHashDescending(%hash);

=head1 METHODS

These subroutines are available from this package:

=cut


#-------------------------------------------------------------------

=head2 commify ( integer )

Returns a number with commas applied at each third character.

=head3 integer

Any old number will do.

=cut

sub commify {
	my $text = reverse $_[0];
	$text =~ s/(\d\d\d)(?=\d)(?!\d*\.)/$1,/g;
	return scalar reverse $text;
}


#-------------------------------------------------------------------

=head2 formatBytes ( integer )

Returns a formatted file size like "3MB" or "44kB".

=head3 integer

An integer representing the number of bytes to format.

=cut

sub formatBytes {
	my $size = shift;
        if ($size > 1048576) {
                return round($size/1048576).' MB';
        } elsif ($size > 1024) {
                return round($size/1024).' kB';
        } else {
		return $size.' B';
        }
}


#-------------------------------------------------------------------

=head2 isBetween ( value, first, second )

Returns true if value is between two other values (inclusive). Otherwise returns false.

=head3 value

An integer to compare against first and second.

=head3 first

An integer to compare value against.

=head3 second

Another integer to compare value against.

=cut

sub isBetween {
	my $value = shift;
	my $first = shift;
	my $second = shift;
	if ($first > $second) {
		($first,$second) = ($second,$first);
	}
	if ($value >= $first && $value <= $second) {
		return 1;
	}
	return 0;
}

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

=head2 makeArrayCommaSafe ( array )

Searches through an array looking for commas and replaces them with semi-colons. Also replaces carriage returns with spaces. This is useful for exporting comma separated data.

=head3 array

A reference to the array to look through.

=cut

sub makeArrayCommaSafe {
	my $array = $_[0];
	$_ = makeCommaSafe($_) for @$array;
}

#-------------------------------------------------------------------

=head2 makeArrayTabSafe ( array )

Searches through an array looking for tabs and replaces them with four spaces. Also replaces carriage returns with a space. This is useful for exporting tab separated data.

=head3 array

 A reference to the array to look through.

=cut

sub makeArrayTabSafe {
	my $array = $_[0];
	$_ = makeTabSafe($_) for @$array;
}

#-------------------------------------------------------------------

=head2 makeCommaSafe ( text )

Replaces commas with semi-colons and carriage returns with spaces.

=head3 text

The text to search through.

=cut

sub makeCommaSafe {
	my $text = $_[0];
	$text =~ tr/,\r\n/; /;
	return $text;
}

#-------------------------------------------------------------------

=head2 makeTabSafe ( text )

Replaces tabs with four spaces and carriage returns with a space each.

=head3 text

The text to search through.

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

=head3 low

The lowest possible value. Defaults to 0.

=head3 high

The highest possible value. Defaults to 1.

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

=head3 array

A reference to the array to randomize.

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

=head3 hashRef

A reference hash to randomize.

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

Sorts a hash by its values. Returns a hash.

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

#-------------------------------------------------------------------

=head2 sortHashDecending ( hash )

Sorts a hash in decending order by its values. Returns a hash.

=head3 hash

A hash to be sorted.

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


