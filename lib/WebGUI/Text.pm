package WebGUI::Text;

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

use Text::CSV_XS;
use base 'Exporter';

our @EXPORT_OK = qw(
	joinCSV readCSV splitCSV
	
	);

our %EXPORT_TAGS = (
	"csv"	=> [qw( joinCSV readCSV splitCSV )],
	
	);


# use a single CSV object instead of reconstructing one repeatedly
my $csv = Text::CSV_XS->new( { binary => 1 } );

=head1 NAME

WebGUI::Text - Routines for manipulating text.


=head1 SYNOPSIS

 use WebGUI::Text qw(:csv);
 my $string	= joinCSV(@array);
 my @array	= splitCSV($string);
 
 while(my $row = readCSV($fileHandle) {
     my @fields = @{ $row };
     doSomethingWith(@fields);
 }


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
	my @inputColumns    = @_;
    $csv->combine(@inputColumns);
    my $joinedLine      = $csv->string;
    if(my $errorString = $csv->error_diag) {
        warn "Problems parsing @inputColumns: $errorString";
        return;
    }
    return $joinedLine;
}



#-------------------------------------------------------------------

=head2 readCSV ( $fileHandle )

Reads a record from the passed filehandle and returns an arrayref of the columns read.

=cut

sub readCSV {
    my $fileHandle = shift;
    my $row = $csv->getline($fileHandle);
    return $row;
}

#-------------------------------------------------------------------

=head2 splitCSV ( $string )

Splits a CSV string and fixes any escaping done.

=cut

sub splitCSV {
	my $inputString = shift;
    $csv->parse($inputString);
    my @splitColumns = $csv->fields;
    if(my $errorString = $csv->error_diag) {
        warn "Problems parsing $inputString: $errorString";
        return;
    }
    return @splitColumns;
}


=head1 BUGS

=over 4

=item *

None known.

=back


=head1 SEE ALSO

=over 4

=item *

RFC 4180 (http://tools.ietf.org/html/rfc4180)

=item *

L<Text::CSV_XS>

=back

=cut

1;
