package WebGUI::Macro::SQL;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2003 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Macro;
use WebGUI::Session;
use WebGUI::SQL;

#-------------------------------------------------------------------
sub process {
	my ($output, @data, $rownum, $temp);
	my ($statement, $format) = WebGUI::Macro::getParams(shift);
	$format = '^0;' if ($format eq "");
	if ($statement =~ /^\s*select/i || $statement =~ /^\s*show/i || $statement =~ /^\s*describe/i) {
		my $sth = WebGUI::SQL->unconditionalRead($statement);
		unless ($sth->errorCode < 1) { 
			return '<p><b>SQL Macro Failed:</b> '.$sth->errorMessage.'<p>';
		} else {
			while (@data = $sth->array) {
                		$temp = $format; 
	                        $temp =~ s/\^(\d+)\;/$data[$1]/g; 
        	                $rownum++;
                	        $temp =~ s/\^rownum\;/$rownum/g;
				$output .= $temp;
	                }
			$sth->finish;
			return $output;
		}
	} else {
		return "Cannot execute this type of query.";
	}
}


1;

