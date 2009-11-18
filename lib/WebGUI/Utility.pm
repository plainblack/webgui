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

our @ISA = qw(Exporter);
our @EXPORT = qw(&isBetween &makeTabSafe &makeArrayTabSafe &randomizeHash &commify &randomizeArray &isInSubnet
	&formatBytes &sortHashDescending &sortHash &isIn &makeCommaSafe &makeArrayCommaSafe &randint &round &scalarEquals
	);


=head1 NAME

Package WebGUI::Utility

=head1 DESCRIPTION

This package provides miscellaneous but useful utilities to the WebGUI programmer.

=head1 SYNOPSIS

 use WebGUI::Utility;
 $string = commify($integer);
 $size = formatBytes($integer);
 $boolean = isBetween($value, $first, $second);
 $boolean = isIn($value, @array);
 $boolean = isInSubnet($ip, \@subnets);
 makeArrayCommaSafe(\@array); 
 makeArrayTabSafe(\@array); 
 $string = makeCommaSafe($string);
 $string = makeTabSafe($string);
 $integer = randint($low,$high);
 $hashRef = randomizeHash(\%hash);
 $rounded = round($number, $digits);
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

=head2 emailRegex ( )

Returns a regex object that can be used to validate email addresses.

=cut

sub emailRegex {
	return qr/^([0-9a-zA-Z]+[-._+&])*\w+@([-0-9a-zA-Z]+[.])+[a-zA-Z]{2,7}$/;
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

=head2 isInSubnet ( ipAddress, subnets ) 

Verifies whether an IP address is in a given subnet. Returns a 1 if it is, undef if there's a formatting error, or 0 if the IP is not in the list of subnets.

=head3 ipAddress

A scalar containing an IP address.

=head3 subnets

An array reference containing subnets in CIDR format. Example: 127.0.0.1/32

=cut

BEGIN {

    my $hasSubnets = eval {require Net::Subnets};
    if ($hasSubnets) {
        *isInSubnet = *_isInSubnet_subnet;
    }
    else {
        require Net::CIDR::Lite;
        *isInSubnet = *_isInSubnet_cidr;
    }

}

sub _isInSubnet_subnet {
	my $ip = shift;
	my $subnets = shift;
	# some validation
	for my $cidr ( @{ $subnets } ) {
    		my @parts = $cidr =~ /^(\d+)\.(\d+)\.(\d+)\.(\d+)\/(\d+)$/;
    		unless ( 5 == @parts ) { # cidr has 5 parts
			return undef;
    		}
    		unless ( 4 == grep { $_ <= 255 } @parts[0..3] ) { # each octet needs to be between 0 and 255
			return undef;
    		}
    		unless ( $parts[4] <= 32 ) { # the subnet needs to be less than or equal to 32, as 32 represents only 1 ip address
			return undef;
    		}
	}
	my $net = Net::Subnets->new;
	$net->subnets($subnets);
	if ($net->check(\$ip)) {
		return 1;
	}
    else {
		return 0;
	}
}

sub _isInSubnet_cidr {
	my $ip      = shift;
	my $subnets = shift;
    return 0 unless @{ $subnets };
	for my $cidr ( @{ $subnets } ) {
        my @parts = $cidr =~ /^(\d+)\.(\d+)\.(\d+)\.(\d+)\/(\d+)$/;
        unless ( 5 == @parts ) { # cidr has 5 parts
            return undef;
        }
        unless ( 4 == grep { $_ <= 255 } @parts[0..3] ) { # each octet needs to be between 0 and 255
            return undef;
        }
        unless ( $parts[4] <= 32 ) { # the subnet needs to be less than or equal to 32, as 32 represents only 1 ip address
            return undef;
        }
	}
	my $net   = Net::CIDR::Lite->new(@{ $subnets });
	if ($net->find($ip)) {
		return 1;
	} else {
		return 0;
	}
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

 A reference to the array to look through.  The array itself is modified, rather than
 returning useful data.

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

=head2 randomizeArray (  )

Don't use this function, it is depricated and will be removed at some point in the future. Instead use List::Util::shuffle()

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

=head2 scalarEquals ( $a, $b, .. )

Checks an arbitrary number of scalars for strict equality.

Lets perl do all the work for us, via clever use of hash keys.

Credit goes to davido on perlmonks: http://www.perlmonks.org/?node_id=525349

Be aware that this may actually be more strict than you want. See Utility.t 
for the full list of scalars that are considered equal and not equal.

=cut

sub scalarEquals {
    # False when < 2 defined args
    return 0 if ( grep { defined($_) } @_ ) < 2;
    
    # Use args as hash keys, all equal if we end up with only 1 key
    no warnings qw/uninitialized/;
    my %gadget;
    @gadget{@_} = ();
    return scalar keys %gadget == 1 ? 1 : 0;
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

#-------------------------------------------------------------------

=head2 sortHashDescending ( hash )

Sorts a hash in decending order by its values.  Returns a Tie::IxHash.
You must assign this to a similarly tied hash to preserve the order.

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
