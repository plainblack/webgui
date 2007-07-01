package WebGUI::Text;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2007 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut


use strict;
#use warnings;

use base 'Exporter';

our @EXPORT_OK = qw(
	joinCSV splitCSV
	
	);

our %EXPORT_TAGS = (
	"csv"	=> [qw( joinCSV splitCSV )],
	
	);


=head1 NAME

WebGUI::Text - Routines for manipulating text.


=head1 SYNOPSIS

 use WebGUI::Text qw(:csv);
 my $string	= joinCSV(@array);
 my @array	= splitCSV($string);


=head1 DESCRIPTION

Some convenience routines that can be exported to work with text data.


=head1 METHODS

=cut


#-------------------------------------------------------------------

=head2 joinCSV ( @array )

Join an array of data together to create a properly formatted and escaped CSV 
string according to the de-facto standard outlined by RFC 4180.

=cut

sub joinCSV {
	my @input	= @_;
	my @fixed;	# The properly escaped data
	for my $i (@input) {
		# Ignore all characters that aren't ASCII printable characters
		$i =~ s/[^\x09\x20-\x7e]//g;
		
		# All strings with these chars in them must be quoted
		if ($i =~ /[",\n\t]/ || $i =~ /^\s|\s$/s) {
			# " must be doubled ("")
			$i =~ s/"/""/g;
			
			$i = qq{"$i"};
		}
		
		push @fixed, $i;
	}
	
	return join ",",@fixed;
}



#-------------------------------------------------------------------

=head2 splitCSV ( $string )

Splits a CSV string and fixes any escaping done.

=cut

sub splitCSV {
	my $s	= shift;
	
	# Split on ,
	# Negative LIMIT so that empty trailing fields are preserved
	my @array = split /,/, $s, -1; 
	
	for (my $i = 0; $i < @array; $i++) {
		# Fix quoted strings being used to escape commas.
		# If it begins with a " but doesn't end with an odd number of "
		#  shift, add to previous, and try again
		if ($array[$i] =~ /^"/s && length(($array[$i] =~ m/("*)$/s)[0]) % 2 == 0 ) {
			# If there are no more elements, this line is erroneous
			if ($i+1 > @array) { warn "Error parsing CSV line."; return; }
			$array[$i] .= ",".splice(@array,$i+1,1);
			redo;
		}
		
		# Remove quotes on end of string
		$array[$i] =~ s/^"|"$//sg;
		
		# Fix doubled quotes
		$array[$i] =~ s/""/"/g;
	}
	
	return @array;
}


=head1 BUGS

=over 4

=item *

splitCSV doesn't properly handle quoted fields with no text inside (...,"",...)

=back



=head1 SEE ALSO

=over 4

=item *

RFC 4180 (http://tools.ietf.org/html/rfc4180)

=back

=cut

1;
